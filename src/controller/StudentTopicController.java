package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import bean.Topic;
import dao.SelectionDao;
import dao.TopicDao;
import util.CollegeUtil;
import util.OperationLogUtil;
import util.WebUtil;
import java.util.List;

@WebServlet("/student/topic.action")
public class StudentTopicController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String college = request.getParameter("college");
        User user = (User) request.getSession().getAttribute("loginUser");
        TopicDao dao = new TopicDao();
        List<Topic> topics = dao.findOpenTopics(keyword, college);
        request.setAttribute("topics", topics);
        request.setAttribute("keyword", keyword);
        request.setAttribute("collegeFilter", college);
        request.setAttribute("collegeOptions", CollegeUtil.getColleges());
        request.setAttribute("hasApplied",
            new SelectionDao().hasPendingOrApproved(user.getId()));
        request.getRequestDispatcher("/student/topics.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("apply".equals(action)) {
            int topicId = Integer.parseInt(request.getParameter("topicId"));
            String reason = request.getParameter("applyReason");
            int result = dao.apply(user.getId(), topicId, reason);
            if (result == -1) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=already_applied");
                return;
            }
            if (result == -2) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=quota_full");
                return;
            }
            if (result <= 0) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "APPLY", "topic_selection",
                "申请选题 topicId=" + topicId);
            WebUtil.redirect(request, response, "/student/my-selection.jsp?msg=apply_ok");
        } else {
            WebUtil.redirect(request, response, "/student/topic.action");
        }
    }
}
