package controller;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import bean.FileTemplate;
import bean.User;
import dao.FileTemplateDao;
import util.DictionaryUtil;
import util.FileUploadUtil;
import util.OperationLogUtil;
import util.PageUtil;
import util.WebUtil;

@WebServlet({"/admin/file-template.action", "/teacher/file-template.action", "/student/file-template.action"})
@MultipartConfig
public class FileTemplateController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String docType = normalizeDocType(request.getParameter("type"));
        int page = PageUtil.getPage(request);
        int pageSize = PageUtil.getPageSize(request);

        FileTemplateDao dao = new FileTemplateDao();
        List<FileTemplate> templates = dao.findAll(docType, page, pageSize);
        int total = dao.countAll(docType);

        request.setAttribute("templates", templates);
        request.setAttribute("total", total);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("typeFilter", docType);
        request.setAttribute("typeNames", DictionaryUtil.items("document_type"));

        String path = request.getServletPath();
        String jsp = "/teacher/file-templates.jsp";
        if (path.startsWith("/admin/")) {
            jsp = "/admin/file-templates.jsp";
        } else if (path.startsWith("/student/")) {
            jsp = "/student/file-templates.jsp";
        }
        request.getRequestDispatcher(jsp).forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        if (!"admin".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("upload".equals(action)) {
            upload(request, response, user);
        } else if ("delete".equals(action)) {
            delete(request, response, user);
        } else {
            WebUtil.redirect(request, response, "/admin/file-template.action");
        }
    }

    private void upload(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException, ServletException {
        String name = trim(request.getParameter("templateName"));
        if (name == null || name.isEmpty()) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=template_name_empty");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() <= 0) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=template_file_empty");
            return;
        }

        String uploadDir = getServletContext().getRealPath("/uploads/templates");
        String saved;
        String original = FileUploadUtil.getFileName(filePart);
        try {
            saved = FileUploadUtil.saveFile(filePart, uploadDir, "template");
        } catch (IOException ex) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=upload_invalid");
            return;
        }
        if (saved == null) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=template_file_empty");
            return;
        }

        FileTemplate template = new FileTemplate();
        template.setTemplateName(name);
        template.setDocType(normalizeDocType(request.getParameter("docType")));
        template.setDescription(trim(request.getParameter("description")));
        template.setFilePath("uploads/templates/" + saved);
        template.setOriginalFilename(original);
        template.setFileSize(filePart.getSize());
        template.setUploaderId(user.getId());

        int id = new FileTemplateDao().insert(template);
        if (id <= 0) {
            deleteUploadedFile(template.getFilePath());
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=error");
            return;
        }

        OperationLogUtil.log(user.getId(), "UPLOAD", "file_template", "上传模板 " + name);
        WebUtil.redirect(request, response, "/admin/file-template.action?msg=upload_ok");
    }

    private void delete(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=error");
            return;
        }

        FileTemplateDao dao = new FileTemplateDao();
        FileTemplate template = dao.findById(id);
        if (template == null) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=error");
            return;
        }
        if (dao.delete(id) <= 0) {
            WebUtil.redirect(request, response, "/admin/file-template.action?msg=delete_failed");
            return;
        }
        deleteUploadedFile(template.getFilePath());
        OperationLogUtil.log(user.getId(), "DELETE", "file_template",
            "删除模板 id=" + id + " " + template.getTemplateName());
        WebUtil.redirect(request, response, "/admin/file-template.action?msg=delete_ok");
    }

    private String normalizeDocType(String docType) {
        return DictionaryUtil.contains("document_type", docType) ? docType : null;
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private void deleteUploadedFile(String relativePath) {
        if (relativePath == null || relativePath.contains("..")) {
            return;
        }
        String realPath = getServletContext().getRealPath("/" + relativePath);
        if (realPath != null) {
            new File(realPath).delete();
        }
    }
}
