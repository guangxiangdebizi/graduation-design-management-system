package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.Document;
import bean.TopicSelection;
import bean.User;
import dao.SelectionDao;
import dao.DocumentDao;

@WebServlet("/student/topic.action")
public class StudentTopicController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("apply".equals(action)) {
            if (dao.hasPendingOrApproved(user.getId())) {
                redirect(response, "topics.jsp?msg=already_applied");
                return;
            }
            int topicId = Integer.parseInt(request.getParameter("topicId"));
            String reason = request.getParameter("applyReason");
            dao.apply(user.getId(), topicId, reason);
            redirect(response, "my-selection.jsp?msg=apply_ok");
        } else {
            redirect(response, "topics.jsp");
        }
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
