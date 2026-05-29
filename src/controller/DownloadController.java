package controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.DocumentDao;
import bean.Document;
import util.WebUtil;

@WebServlet("/download.action")
public class DownloadController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            WebUtil.redirect(request, response, "/login.jsp");
            return;
        }

        String path = request.getParameter("path");
        if (path == null || path.contains("..")) {
            response.sendError(400, "invalid path");
            return;
        }
        if (path.startsWith("/")) {
            path = path.substring(1);
        }

        if (!canAccess(user, path)) {
            response.sendError(403, "forbidden");
            return;
        }

        String realBase = getServletContext().getRealPath("/");
        File file = new File(realBase, path.replace("/", File.separator));
        if (!file.exists() || !file.isFile()) {
            response.sendError(404, "file not found");
            return;
        }

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + file.getName() + "\"");
        FileInputStream in = new FileInputStream(file);
        OutputStream out = response.getOutputStream();
        byte[] buf = new byte[4096];
        int len;
        while ((len = in.read(buf)) != -1) {
            out.write(buf, 0, len);
        }
        in.close();
        out.flush();
    }

    private boolean canAccess(User user, String path) {
        if ("admin".equals(user.getRole())) {
            return path.startsWith("uploads/");
        }
        if ("teacher".equals(user.getRole())) {
            if (!path.startsWith("uploads/")) {
                return false;
            }
            DocumentDao docDao = new DocumentDao();
            for (Document d : docDao.findByTeacher(user.getId(), null, null)) {
                if (path.equals(d.getFilePath())) {
                    return true;
                }
            }
            return false;
        }
        return path.startsWith("uploads/" + user.getId() + "/");
    }
}
