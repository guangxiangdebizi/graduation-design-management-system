package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/logout.action")
public class LogoutController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("loginUser");
            if (user != null) {
                OperationLogUtil.log(user.getId(), "LOGOUT", user.getRole(), user.getUsername() + " 退出系统");
            }
            session.invalidate();
        }
        WebUtil.redirect(request, response, "/login.jsp");
    }
}
