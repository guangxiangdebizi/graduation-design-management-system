package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.SelectionDao;

@WebServlet("/teacher/selection.action")
public class TeacherSelectionController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("approve".equals(action) || "reject".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = "approve".equals(action) ? "approved" : "rejected";
            String comment = request.getParameter("reviewComment");
            dao.review(id, user.getId(), status, comment);
            redirect(response, "selections.jsp?msg=" + status);
        } else {
            redirect(response, "selections.jsp");
        }
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
