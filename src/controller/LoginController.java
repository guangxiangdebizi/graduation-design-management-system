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
import util.LoginAttemptUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/login.action")
public class LoginController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 输入校验
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            WebUtil.redirect(request, response, "/login.jsp?error=empty");
            return;
        }

        username = username.trim();
        HttpSession session = request.getSession(true);

        // 检查账户锁定状态
        if (LoginAttemptUtil.isLocked(session, username)) {
            WebUtil.redirect(request, response, "/login.jsp?error=locked");
            return;
        }

        UserDao dao = new UserDao();
        if (dao.validate(username, password)) {
            User user = dao.findByUsername(username);
            user.setPassword(null); // 安全：不在 session 中存储密码
            session.setAttribute("loginUser", user);
            session.setAttribute("loginTime", System.currentTimeMillis());
            LoginAttemptUtil.clear(session, username);
            OperationLogUtil.log(user.getId(), "LOGIN", user.getRole(), username + " 登录系统");

            // 登录成功后重定向到仪表盘
            WebUtil.redirect(request, response, "/dashboard.jsp");
        } else {
            LoginAttemptUtil.recordFailure(session, username);
            WebUtil.redirect(request, response, "/login.jsp?error=1");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET 请求重定向到登录页
        WebUtil.redirect(request, response, "/login.jsp");
    }
}