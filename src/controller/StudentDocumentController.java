package controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import bean.Document;
import bean.DocumentVersion;
import bean.TopicSelection;
import bean.User;
import dao.DocumentDao;
import dao.DocumentVersionDao;
import dao.SelectionDao;
import util.DictionaryUtil;
import util.FileUploadUtil;
import util.OperationLogUtil;
import util.SystemConfigUtil;
import util.SystemSwitchUtil;
import util.WebUtil;

@WebServlet("/student/document.action")
@MultipartConfig
public class StudentDocumentController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String docType = normalizeDocType(request.getParameter("type"));
        SelectionDao selectionDao = new SelectionDao();
        DocumentDao documentDao = new DocumentDao();
        TopicSelection approved = selectionDao.findApprovedByStudent(user.getId());
        Document current = approved == null ? null
            : documentDao.findByStudentAndType(user.getId(), docType);
        List<DocumentVersion> versions = current == null
            ? new ArrayList<DocumentVersion>()
            : new DocumentVersionDao().findByDocument(current.getId());

        request.setAttribute("approvedSelection", approved);
        request.setAttribute("currentDocument", current);
        request.setAttribute("documentVersions", versions);
        request.setAttribute("activeType", docType);
        request.setAttribute("typeNames", documentTypeNames());
        request.setAttribute("uploadOpen",
            Boolean.valueOf(SystemSwitchUtil.isEnabled(SystemSwitchUtil.uploadKey(docType))));
        request.setAttribute("uploadAccept",
            "." + SystemConfigUtil.getString("upload.allowed_extensions", "pdf,doc,docx,zip,rar")
                .replace(",", ",."));
        request.getRequestDispatcher("/student/documents.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        TopicSelection approved = new SelectionDao().findApprovedByStudent(user.getId());
        if (approved == null) {
            redirectToList(request, response, "no_topic", "proposal");
            return;
        }

        String docType = request.getParameter("docType");
        if (!DictionaryUtil.contains("document_type", docType)) {
            redirectToList(request, response, "error", "proposal");
            return;
        }
        if (!SystemSwitchUtil.isEnabled(SystemSwitchUtil.uploadKey(docType))) {
            redirectToList(request, response, "upload_closed", docType);
            return;
        }

        DocumentDao documentDao = new DocumentDao();
        Document existing = documentDao.findByStudentAndType(user.getId(), docType);
        if (!documentDao.isStageAvailable(user.getId(), docType)) {
            redirectToList(request, response, "stage_locked", docType);
            return;
        }
        if (existing != null && !"rejected".equals(existing.getStatus())) {
            redirectToList(request, response, "document_locked", docType);
            return;
        }

        Document document = new Document();
        document.setStudentId(user.getId());
        document.setTopicId(approved.getTopicId());
        document.setDocType(docType);
        document.setTitle(request.getParameter("title"));
        document.setContent(request.getParameter("content"));

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
                redirectToList(request, response, "upload_invalid", docType);
                return;
            }
        }
        document.setFilePath(filePath);

        int result = documentDao.submit(document);
        if (result <= 0) {
            deleteUploadedFile(newFilePath);
            String message = result == -2 ? "stage_locked"
                : (result == -3 ? "document_locked" : "error");
            redirectToList(request, response, message, docType);
            return;
        }

        OperationLogUtil.log(user.getId(), "SUBMIT", "document",
            "提交" + docType + "文档");
        redirectToList(request, response, "submit_ok", docType);
    }

    private void redirectToList(HttpServletRequest request, HttpServletResponse response,
            String message, String docType) throws IOException {
        WebUtil.redirect(request, response,
            "/student/document.action?msg=" + message + "&type=" + normalizeDocType(docType));
    }

    private String normalizeDocType(String docType) {
        return DictionaryUtil.contains("document_type", docType) ? docType : "proposal";
    }

    private Map<String, String> documentTypeNames() {
        return DictionaryUtil.items("document_type");
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
