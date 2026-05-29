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

@WebServlet("/teacher/topic.action")
public class TeacherTopicController extends HttpServlet {
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
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus(request.getParameter("status"));
            dao.insert(t);
            OperationLogUtil.log(user.getId(), "ADD", "topic", "发布课题: " + t.getTitle());
            WebUtil.redirect(request, response, "/teacher/topics.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            Topic t = new Topic();
            t.setId(Integer.parseInt(request.getParameter("id")));
            t.setTitle(request.getParameter("title"));
            t.setDescription(request.getParameter("description"));
            t.setTeacherId(user.getId());
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus(request.getParameter("status"));
            dao.update(t);
            OperationLogUtil.log(user.getId(), "UPDATE", "topic", "编辑课题 id=" + t.getId());
            WebUtil.redirect(request, response, "/teacher/topics.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id, user.getId());
            OperationLogUtil.log(user.getId(), "DELETE", "topic", "删除课题 id=" + id);
            WebUtil.redirect(request, response, "/teacher/topics.jsp?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/teacher/topics.jsp");
        }
    }
}
