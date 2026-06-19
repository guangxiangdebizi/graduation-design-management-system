package controller;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import bean.Document;
import bean.TopicSelection;
import bean.User;
import dao.DocumentDao;
import dao.SelectionDao;
import util.FileUploadUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/student/document.action")
@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 20971520)
public class StudentDocumentController extends HttpServlet {
    private static final Set<String> DOC_TYPES =
        new HashSet<String>(Arrays.asList("proposal", "midterm", "final"));

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        TopicSelection approved = new SelectionDao().findApprovedByStudent(user.getId());
        if (approved == null) {
            WebUtil.redirect(request, response, "/student/documents.jsp?msg=no_topic");
            return;
        }

        String docType = request.getParameter("docType");
        if (!DOC_TYPES.contains(docType)) {
            WebUtil.redirect(request, response, "/student/documents.jsp?msg=error");
            return;
        }

        DocumentDao docDao = new DocumentDao();
        Document existing = docDao.findByStudentAndType(user.getId(), docType);
        if (!docDao.isStageAvailable(user.getId(), docType)) {
            WebUtil.redirect(request, response,
                "/student/documents.jsp?msg=stage_locked&type=" + docType);
            return;
        }
        if (existing != null && !"rejected".equals(existing.getStatus())) {
            WebUtil.redirect(request, response,
                "/student/documents.jsp?msg=document_locked&type=" + docType);
            return;
        }

        Document doc = new Document();
        doc.setStudentId(user.getId());
        doc.setTopicId(approved.getTopicId());
        doc.setDocType(docType);
        doc.setTitle(request.getParameter("title"));
        doc.setContent(request.getParameter("content"));

        String filePath = existing != null ? existing.getFilePath() : null;
        String newFilePath = null;
        Part filePart = request.getPart("file");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadDir = getServletContext().getRealPath("/uploads/" + user.getId());
            try {
                String saved = FileUploadUtil.saveFile(filePart, uploadDir, docType);
                if (saved != null) {
                    filePath = "uploads/" + user.getId() + "/" + saved;
                    newFilePath = filePath;
                }
            } catch (IOException ex) {
                WebUtil.redirect(request, response,
                    "/student/documents.jsp?msg=upload_invalid&type=" + docType);
                return;
            }
        }
        doc.setFilePath(filePath);

        int result = docDao.submit(doc);
        if (result <= 0) {
            deleteUploadedFile(newFilePath);
            String msg = result == -2 ? "stage_locked"
                : (result == -3 ? "document_locked" : "error");
            WebUtil.redirect(request, response,
                "/student/documents.jsp?msg=" + msg + "&type=" + docType);
            return;
        }

        OperationLogUtil.log(user.getId(), "SUBMIT", "document", "提交" + docType + "文档");
        WebUtil.redirect(request, response,
            "/student/documents.jsp?msg=submit_ok&type=" + docType);
    }

    private void deleteUploadedFile(String relativePath) {
        if (relativePath == null) {
            return;
        }
        String realPath = getServletContext().getRealPath("/" + relativePath);
        if (realPath != null) {
            new File(realPath).delete();
        }
    }
}
