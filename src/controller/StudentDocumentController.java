package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        SelectionDao selDao = new SelectionDao();
        TopicSelection approved = selDao.findApprovedByStudent(user.getId());
        if (approved == null) {
            WebUtil.redirect(request, response, "/student/documents.jsp?msg=no_topic");
            return;
        }

        Document doc = new Document();
        doc.setStudentId(user.getId());
        doc.setTopicId(approved.getTopicId());
        doc.setDocType(request.getParameter("docType"));
        doc.setTitle(request.getParameter("title"));
        doc.setContent(request.getParameter("content"));

        DocumentDao docDao = new DocumentDao();
        Document existing = docDao.findByStudentAndType(user.getId(), doc.getDocType());
        String filePath = existing != null ? existing.getFilePath() : null;

        Part filePart = request.getPart("file");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadDir = getServletContext().getRealPath("/uploads/" + user.getId());
            String saved = FileUploadUtil.saveFile(filePart, uploadDir, doc.getDocType());
            if (saved != null) {
                filePath = "uploads/" + user.getId() + "/" + saved;
            }
        }
        doc.setFilePath(filePath);

        docDao.submit(doc);
        OperationLogUtil.log(user.getId(), "SUBMIT", "document",
            "提交" + doc.getDocType() + "文档");
        WebUtil.redirect(request, response,
            "/student/documents.jsp?msg=submit_ok&type=" + doc.getDocType());
    }
}
