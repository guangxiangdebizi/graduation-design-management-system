package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.Topic;
import bean.User;
import dao.TopicDao;
import util.OperationLogUtil;
import util.WebUtil;
import java.util.List;

@WebServlet("/teacher/topic.action")
public class TeacherTopicController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        TopicDao dao = new TopicDao();
        List<Topic> topics = dao.findByTeacher(user.getId());
        request.setAttribute("topics", topics);
        request.getRequestDispatcher("/teacher/topics.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        TopicDao dao = new TopicDao();

        if ("add".equals(action)) {
            Topic t = new Topic();
            t.setTitle(request.getParameter("title"));
            t.setDescription(request.getParameter("description"));
            t.setTeacherId(user.getId());
            t.setCollege(request.getParameter("college"));
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus(request.getParameter("status"));
            if (t.getMaxStudents() < 1 || !isValidStatus(t.getStatus())
                    || dao.insert(t) <= 0) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "ADD", "topic", "发布课题: " + t.getTitle());
            WebUtil.redirect(request, response, "/teacher/topic.action?msg=add_ok");
        } else if ("edit".equals(action)) {
            Topic t = new Topic();
            t.setId(Integer.parseInt(request.getParameter("id")));
            t.setTitle(request.getParameter("title"));
            t.setDescription(request.getParameter("description"));
            t.setTeacherId(user.getId());
            t.setCollege(request.getParameter("college"));
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus(request.getParameter("status"));
            Topic current = dao.findById(t.getId());
            if (current == null || current.getTeacherId() != user.getId()
                    || t.getMaxStudents() < current.getSelectedCount()
                    || !isValidStatus(t.getStatus())) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=invalid_quota");
                return;
            }
            if (current.getSelectedCount() >= t.getMaxStudents()) {
                t.setStatus("closed");
            }
            if (dao.update(t) <= 0) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "UPDATE", "topic", "编辑课题 id=" + t.getId());
            WebUtil.redirect(request, response, "/teacher/topic.action?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            int result = dao.delete(id, user.getId());
            if (result <= 0) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=delete_failed");
                return;
            }
            OperationLogUtil.log(user.getId(), "DELETE", "topic", "删除课题 id=" + id);
            WebUtil.redirect(request, response, "/teacher/topic.action?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/teacher/topic.action");
        }
    }

    private boolean isValidStatus(String status) {
        return "open".equals(status) || "closed".equals(status);
    }
}
