package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.UserDao;

@WebServlet("/admin/user.action")
public class AdminUserController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        UserDao dao = new UserDao();
        if ("add".equals(action)) {
            User u = buildUser(request);
            u.setStatus(1);
            dao.insert(u);
            redirect(response, "users.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            User u = buildUser(request);
            u.setId(Integer.parseInt(request.getParameter("id")));
            u.setStatus(Integer.parseInt(request.getParameter("status")));
            String pwd = request.getParameter("password");
            u.setPassword(pwd == null || pwd.trim().isEmpty() ? null : pwd);
            dao.update(u);
            redirect(response, "users.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            dao.delete(Integer.parseInt(request.getParameter("id")));
            redirect(response, "users.jsp?msg=delete_ok");
        } else {
            redirect(response, "users.jsp");
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

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
