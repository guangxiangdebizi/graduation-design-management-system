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
import util.OperationLogUtil;
import util.WebUtil;

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
                WebUtil.redirect(request, response, "/student/topics.jsp?msg=already_applied");
                return;
            }
            int topicId = Integer.parseInt(request.getParameter("topicId"));
            TopicDao topicDao = new TopicDao();
            Topic topic = topicDao.findById(topicId);
            if (topic == null || !"open".equals(topic.getStatus())
                    || topic.getSelectedCount() >= topic.getMaxStudents()) {
                WebUtil.redirect(request, response, "/student/topics.jsp?msg=quota_full");
                return;
            }
            String reason = request.getParameter("applyReason");
            dao.apply(user.getId(), topicId, reason);
            OperationLogUtil.log(user.getId(), "APPLY", "topic_selection",
                "申请选题 topicId=" + topicId);
            WebUtil.redirect(request, response, "/student/my-selection.jsp?msg=apply_ok");
        } else {
            WebUtil.redirect(request, response, "/student/topics.jsp");
        }
    }
}
