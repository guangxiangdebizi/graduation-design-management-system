package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.Topic;
import bean.User;
import dao.TopicDao;
import util.CollegeUtil;
import util.DictionaryUtil;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/topic-review.action")
public class AdminTopicReviewController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String keyword = request.getParameter("keyword");
        String college = clean(request.getParameter("college"));
        String major = clean(request.getParameter("major"));
        String status = request.getParameter("status");
        if (status == null) {
            status = "pending";
        } else if (status.trim().isEmpty()) {
            status = "all";
        }
        List<Topic> topics = new TopicDao().findAll(keyword, college, major,
            "all".equals(status) ? null : status);
        request.setAttribute("topics", topics);
        request.setAttribute("keyword", keyword);
        request.setAttribute("collegeFilter", college);
        request.setAttribute("majorFilter", major);
        request.setAttribute("statusFilter", status);
        request.setAttribute("collegeOptions", CollegeUtil.getColleges());
        request.setAttribute("majorGroups", CollegeUtil.getMajorGroups());
        request.setAttribute("topicStatusOptions", DictionaryUtil.items("topic_status"));
        request.getRequestDispatcher("/admin/topic-review.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        String status = "approve".equals(action) ? "open" : ("reject".equals(action) ? "rejected" : null);
        if (status == null) {
            WebUtil.redirect(request, response, "/admin/topic-review.action?msg=error");
            return;
        }
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/admin/topic-review.action?msg=error");
            return;
        }
        String comment = request.getParameter("reviewComment");
        TopicDao dao = new TopicDao();
        Topic topic = dao.findById(id);
        if (topic == null || dao.review(id, user.getId(), status, comment) <= 0) {
            WebUtil.redirect(request, response, "/admin/topic-review.action?msg=error");
            return;
        }
        MessageNotifyUtil.send(topic.getTeacherId(), "课题审核结果",
            "您的课题《" + topic.getTitle() + "》已" + ("open".equals(status) ? "通过审核并开放选题" : "被驳回"));
        OperationLogUtil.log(user.getId(),
            "open".equals(status) ? "APPROVE" : "REJECT",
            "topic", "审核课题 id=" + id + " -> " + status);
        WebUtil.redirect(request, response,
            "/admin/topic-review.action?msg=" + ("open".equals(status) ? "approved" : "rejected"));
    }

    private String clean(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
