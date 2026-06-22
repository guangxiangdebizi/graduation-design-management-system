package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.FileTemplate;
import bean.User;
import dao.FileTemplateDao;
import util.WebUtil;

@WebServlet("/file-template-download.action")
public class FileTemplateDownloadController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            WebUtil.redirect(request, response, "/login.jsp");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "invalid template id");
            return;
        }

        FileTemplate template = new FileTemplateDao().findById(id);
        if (template == null || template.getFilePath() == null
                || template.getFilePath().contains("..")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "template not found");
            return;
        }

        String realBase = getServletContext().getRealPath("/");
        File templateBase = new File(realBase, "uploads/templates").getCanonicalFile();
        File file = new File(realBase,
            template.getFilePath().replace("/", File.separator)).getCanonicalFile();
        if (!file.getPath().startsWith(templateBase.getPath() + File.separator)
                || !file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "file not found");
            return;
        }

        response.setContentType("application/octet-stream");
        String filename = template.getOriginalFilename();
        if (filename == null || filename.trim().isEmpty()) {
            filename = file.getName();
        }
        String encoded = URLEncoder.encode(filename, "UTF-8").replace("+", "%20");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + encoded + "\"; filename*=UTF-8''" + encoded);
        try (FileInputStream in = new FileInputStream(file);
                OutputStream out = response.getOutputStream()) {
            byte[] buf = new byte[4096];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
            out.flush();
        }
    }
}
