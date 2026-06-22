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
import util.CollegeUtil;
import util.DictionaryUtil;
import util.OperationLogUtil;
import util.SystemSwitchUtil;
import util.WebUtil;
import java.util.List;
import java.util.Map;

@WebServlet("/teacher/topic.action")
public class TeacherTopicController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        TopicDao dao = new TopicDao();
        List<Topic> topics = dao.findByTeacher(user.getId());
        request.setAttribute("topics", topics);
        String teacherCollege = clean(user.getCollege());
        request.setAttribute("teacherCollege", teacherCollege);
        request.setAttribute("teacherCollegeName", CollegeUtil.getCollegeName(teacherCollege));
        request.setAttribute("teacherMajor", clean(user.getMajor()));
        request.setAttribute("majorOptions", CollegeUtil.getMajorsByCollege(teacherCollege));
        request.setAttribute("topicStatusOptions", DictionaryUtil.items("topic_status"));
        request.setAttribute("topicSubmitOpen",
            Boolean.valueOf(SystemSwitchUtil.isEnabled(SystemSwitchUtil.TOPIC_SUBMIT)));
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
            if (!SystemSwitchUtil.isEnabled(SystemSwitchUtil.TOPIC_SUBMIT)) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=topic_submit_closed");
                return;
            }
            Topic t = new Topic();
            t.setTitle(request.getParameter("title"));
            t.setDescription(request.getParameter("description"));
            t.setTeacherId(user.getId());
            t.setCollege(resolveCollege(user, request));
            t.setMajor(resolveMajor(t.getCollege(), user, request.getParameter("major")));
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus("pending");
            if (t.getMaxStudents() < 1 || dao.insert(t) <= 0) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "ADD", "topic", "提交课题审核: " + t.getTitle());
            WebUtil.redirect(request, response, "/teacher/topic.action?msg=add_ok");
        } else if ("edit".equals(action)) {
            if (!SystemSwitchUtil.isEnabled(SystemSwitchUtil.TOPIC_SUBMIT)) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=topic_submit_closed");
                return;
            }
            Topic t = new Topic();
            t.setId(Integer.parseInt(request.getParameter("id")));
            t.setTitle(request.getParameter("title"));
            t.setDescription(request.getParameter("description"));
            t.setTeacherId(user.getId());
            t.setCollege(resolveCollege(user, request));
            t.setMajor(resolveMajor(t.getCollege(), user, request.getParameter("major")));
            t.setMaxStudents(Integer.parseInt(request.getParameter("maxStudents")));
            t.setStatus("pending");
            Topic current = dao.findById(t.getId());
            if (current == null || current.getTeacherId() != user.getId()
                    || t.getMaxStudents() < current.getSelectedCount()) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=invalid_quota");
                return;
            }
            if (dao.update(t) <= 0) {
                WebUtil.redirect(request, response, "/teacher/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "UPDATE", "topic", "编辑并重新提交课题 id=" + t.getId());
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

    private String resolveCollege(User user, HttpServletRequest request) {
        String college = clean(user.getCollege());
        return college != null ? college : clean(request.getParameter("college"));
    }

    private String resolveMajor(String college, User user, String requestedMajor) {
        Map<String, String> majors = CollegeUtil.getMajorsByCollege(college);
        String requested = clean(requestedMajor);
        if (requested != null && majors.containsKey(requested)) {
            return requested;
        }
        String ownMajor = clean(user.getMajor());
        if (ownMajor != null && majors.containsKey(ownMajor)) {
            return ownMajor;
        }
        return majors.isEmpty() ? null : majors.keySet().iterator().next();
    }

    private String clean(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
