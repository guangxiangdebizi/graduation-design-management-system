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
import bean.UserScope;
import dao.TopicDao;
import util.DictionaryUtil;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.ScopeUtil;
import util.WebUtil;

@WebServlet("/director/topic-review.action")
public class DirectorTopicReviewController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        String status = request.getParameter("status");
        if (status == null) {
            status = "pending";
        } else if (status.trim().isEmpty()) {
            status = "all";
        }
        List<Topic> topics = new TopicDao().findAll(
            request.getParameter("keyword"),
            scope.getCollege(),
            scope.getMajor(),
            "all".equals(status) ? null : status);
        request.setAttribute("topics", topics);
        request.setAttribute("keyword", request.getParameter("keyword"));
        request.setAttribute("statusFilter", status);
        request.setAttribute("topicStatusOptions", DictionaryUtil.items("topic_status"));
        request.setAttribute("directorScopeText", ScopeUtil.scopeText(scope));
        request.getRequestDispatcher("/director/topic-review.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        String action = request.getParameter("action");
        if ("edit".equals(action)) {
            int id;
            try {
                id = Integer.parseInt(request.getParameter("id"));
            } catch (Exception ex) {
                WebUtil.redirect(request, response, "/director/topic-review.action?msg=error");
                return;
            }
            Topic current = new TopicDao().findById(id);
            if (!ScopeUtil.inDirectorScope(user, current)) {
                WebUtil.redirect(request, response, "/director/topic-review.action?msg=error");
                return;
            }
            Topic topic = new Topic();
            topic.setId(id);
            topic.setTitle(request.getParameter("title"));
            topic.setDescription(request.getParameter("description"));
            try {
                topic.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            } catch (Exception ex) {
                WebUtil.redirect(request, response, "/director/topic-review.action?msg=invalid_quota");
                return;
            }
            if (topic.getMaxStudents() < current.getSelectedCount()
                    || new TopicDao().updateByDirector(topic, scope.getCollege(), scope.getMajor(),
                        user.getId(), request.getParameter("reviewComment")) <= 0) {
                WebUtil.redirect(request, response, "/director/topic-review.action?msg=invalid_quota");
                return;
            }
            OperationLogUtil.log(user.getId(), "UPDATE", "topic",
                "系主任调整本专业课题 id=" + id);
            WebUtil.redirect(request, response, "/director/topic-review.action?msg=edit_ok");
            return;
        }

        String status = "approve".equals(action) ? "open" : ("reject".equals(action) ? "rejected" : null);
        if (status == null) {
            WebUtil.redirect(request, response, "/director/topic-review.action?msg=error");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/director/topic-review.action?msg=error");
            return;
        }

        TopicDao dao = new TopicDao();
        Topic topic = dao.findById(id);
        if (!ScopeUtil.inDirectorScope(user, topic)
                || dao.review(id, user.getId(), status, request.getParameter("reviewComment")) <= 0) {
            WebUtil.redirect(request, response, "/director/topic-review.action?msg=error");
            return;
        }

        MessageNotifyUtil.send(topic.getTeacherId(), "课题审核结果",
            "您的课题《" + topic.getTitle() + "》已"
                + ("open".equals(status) ? "通过审核并开放选题" : "被驳回"));
        OperationLogUtil.log(user.getId(),
            "open".equals(status) ? "APPROVE" : "REJECT",
            "topic", "系主任审核本专业课题 id=" + id + " -> " + status);
        WebUtil.redirect(request, response,
            "/director/topic-review.action?msg=" + ("open".equals(status) ? "approved" : "rejected"));
    }
}
