package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.Announcement;
import bean.User;
import dao.AnnouncementDao;

@WebServlet("/admin/announcement.action")
public class AdminAnnouncementController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        AnnouncementDao dao = new AnnouncementDao();
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");

        if ("add".equals(action)) {
            Announcement a = new Announcement();
            a.setTitle(request.getParameter("title"));
            a.setContent(request.getParameter("content"));
            a.setPublisherId(user.getId());
            a.setIsTop("1".equals(request.getParameter("isTop")) ? 1 : 0);
            dao.insert(a);
            redirect(response, "announcements.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            Announcement a = new Announcement();
            a.setId(Integer.parseInt(request.getParameter("id")));
            a.setTitle(request.getParameter("title"));
            a.setContent(request.getParameter("content"));
            a.setIsTop("1".equals(request.getParameter("isTop")) ? 1 : 0);
            dao.update(a);
            redirect(response, "announcements.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            dao.delete(Integer.parseInt(request.getParameter("id")));
            redirect(response, "announcements.jsp?msg=delete_ok");
        } else {
            redirect(response, "announcements.jsp");
        }
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
