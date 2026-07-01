package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.UserDao;
import util.OperationLogUtil;
import util.ValidationUtil;
import util.WebUtil;

@WebServlet("/profile.action")
public class ProfileController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User loginUser = (User) request.getSession().getAttribute("loginUser");
        User profileUser = new UserDao().findById(loginUser.getId());
        if (profileUser == null) {
            request.getSession().invalidate();
            WebUtil.redirect(request, response, "/login.jsp?error=account_changed");
            return;
        }
        profileUser.setPassword(null);
        request.setAttribute("profileUser", profileUser);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User loginUser = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        if ("profile".equals(action)) {
            updateProfile(request, response, loginUser);
        } else if ("password".equals(action)) {
            updatePassword(request, response, loginUser);
        } else {
            WebUtil.redirect(request, response, "/profile.action");
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        if (!ValidationUtil.isValidEmail(email)) {
            WebUtil.redirect(request, response, "/profile.action?msg=email_invalid");
            return;
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            WebUtil.redirect(request, response, "/profile.action?msg=phone_invalid");
            return;
        }

        UserDao dao = new UserDao();
        if (dao.updateProfile(loginUser.getId(), email, phone) <= 0) {
            WebUtil.redirect(request, response, "/profile.action?msg=error");
            return;
        }
        User refreshed = dao.findById(loginUser.getId());
        if (refreshed != null) {
            refreshed.setPassword(null);
            request.getSession().setAttribute("loginUser", refreshed);
        }
        OperationLogUtil.log(loginUser.getId(), "UPDATE", "profile", "修改个人资料");
        WebUtil.redirect(request, response, "/profile.action?msg=profile_ok");
    }

    private void updatePassword(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        UserDao dao = new UserDao();
        if (!dao.validatePassword(loginUser.getId(), oldPassword)) {
            WebUtil.redirect(request, response, "/profile.action?msg=old_password_wrong");
            return;
        }
        if (!ValidationUtil.isValidPassword(newPassword)) {
            WebUtil.redirect(request, response, "/profile.action?msg=password_invalid");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            WebUtil.redirect(request, response, "/profile.action?msg=password_mismatch");
            return;
        }
        if (dao.updatePassword(loginUser.getId(), newPassword) <= 0) {
            WebUtil.redirect(request, response, "/profile.action?msg=error");
            return;
        }
        OperationLogUtil.log(loginUser.getId(), "UPDATE", "profile", "修改登录密码");
        WebUtil.redirect(request, response, "/profile.action?msg=password_ok");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
