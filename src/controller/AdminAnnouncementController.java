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
import util.OperationLogUtil;
import util.WebUtil;

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
            applyScope(a, request);
            dao.insert(a);
            OperationLogUtil.log(user.getId(), "ADD", "announcement", "发布公告: " + a.getTitle());
            WebUtil.redirect(request, response, "/admin/announcements.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            Announcement a = new Announcement();
            a.setId(Integer.parseInt(request.getParameter("id")));
            a.setTitle(request.getParameter("title"));
            a.setContent(request.getParameter("content"));
            a.setIsTop("1".equals(request.getParameter("isTop")) ? 1 : 0);
            applyScope(a, request);
            dao.update(a);
            OperationLogUtil.log(user.getId(), "UPDATE", "announcement", "编辑公告 id=" + a.getId());
            WebUtil.redirect(request, response, "/admin/announcements.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id);
            OperationLogUtil.log(user.getId(), "DELETE", "announcement", "删除公告 id=" + id);
            WebUtil.redirect(request, response, "/admin/announcements.jsp?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/admin/announcements.jsp");
        }
    }

    private void applyScope(Announcement a, HttpServletRequest request) {
        String scopeType = clean(request.getParameter("scopeType"));
        if (!"college".equals(scopeType) && !"major".equals(scopeType)) {
            a.setScopeType("global");
            a.setCollege(null);
            a.setMajor(null);
            return;
        }
        String college = clean(request.getParameter("college"));
        String major = clean(request.getParameter("major"));
        if ("major".equals(scopeType) && college != null && major != null) {
            a.setScopeType("major");
            a.setCollege(college);
            a.setMajor(major);
        } else if ("college".equals(scopeType) && college != null) {
            a.setScopeType("college");
            a.setCollege(college);
            a.setMajor(null);
        } else {
            a.setScopeType("global");
            a.setCollege(null);
            a.setMajor(null);
        }
    }

    private String clean(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
