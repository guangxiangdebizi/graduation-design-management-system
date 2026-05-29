package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.UserDao;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/user.action")
public class AdminUserController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        UserDao dao = new UserDao();
        if ("add".equals(action)) {
            User u = buildUser(request);
            u.setStatus(1);
            dao.insert(u);
            OperationLogUtil.log(loginUser.getId(), "ADD", "user", "新增用户 " + u.getUsername());
            WebUtil.redirect(request, response, "/admin/users.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            User u = buildUser(request);
            u.setId(Integer.parseInt(request.getParameter("id")));
            u.setStatus(Integer.parseInt(request.getParameter("status")));
            String pwd = request.getParameter("password");
            u.setPassword(pwd == null || pwd.trim().isEmpty() ? null : pwd);
            dao.update(u);
            OperationLogUtil.log(loginUser.getId(), "UPDATE", "user", "编辑用户 id=" + u.getId());
            WebUtil.redirect(request, response, "/admin/users.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id);
            OperationLogUtil.log(loginUser.getId(), "DELETE", "user", "删除用户 id=" + id);
            WebUtil.redirect(request, response, "/admin/users.jsp?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/admin/users.jsp");
        }
    }

    private User buildUser(HttpServletRequest request) {
        User u = new User();
        u.setUsername(request.getParameter("username"));
        u.setPassword(request.getParameter("password"));
        u.setRole(request.getParameter("role"));
        u.setRealName(request.getParameter("realName"));
        u.setStudentNo(request.getParameter("studentNo"));
        u.setDepartment(request.getParameter("department"));
        u.setEmail(request.getParameter("email"));
        u.setPhone(request.getParameter("phone"));
        return u;
    }
}
