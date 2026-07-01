package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.DefenseSchedule;
import bean.User;
import bean.UserScope;
import dao.DefenseScheduleDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.ScopeUtil;
import util.WebUtil;

@WebServlet("/director/defense.action")
public class DirectorDefenseController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }
        DefenseScheduleDao dao = new DefenseScheduleDao();
        List<DefenseSchedule> schedules = dao.findByDirectorScope(
            scope.getCollege(), scope.getMajor());
        request.setAttribute("pageTitle", "本专业答辩教师安排");
        request.setAttribute("schedules", schedules);
        request.setAttribute("committeeTeachers", dao.findCommitteeTeachers(
            scope.getCollege(), scope.getMajor()));
        request.setAttribute("directorScopeText", ScopeUtil.scopeText(scope));
        request.getRequestDispatcher("/director/defense.jsp").forward(request, response);
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

        int studentId = parseInt(request.getParameter("studentId"));
        int[] teacherIds = new int[] {
            parseInt(request.getParameter("teacherId1")),
            parseInt(request.getParameter("teacherId2")),
            parseInt(request.getParameter("teacherId3"))
        };

        DefenseScheduleDao dao = new DefenseScheduleDao();
        int result = dao.saveCommittee(studentId, teacherIds, user.getId(),
            scope.getCollege(), scope.getMajor());
        if (result > 0) {
            MessageNotifyUtil.send(studentId, "答辩教师安排通知",
                "系主任已为您指定三名答辩教师，请关注答辩评分结果。");
            for (int teacherId : teacherIds) {
                MessageNotifyUtil.send(teacherId, "答辩评分任务",
                    "您被指定为答辩教师，请进入教师端答辩评分页面完成评分。");
            }
            OperationLogUtil.log(user.getId(), "ARRANGE_DEFENSE", "defense_schedules",
                "指定三名答辩教师 studentId=" + studentId + ", scheduleId=" + result);
            WebUtil.redirect(request, response, "/director/defense.action?msg=arrange_ok");
            return;
        }
        WebUtil.redirect(request, response, "/director/defense.action?msg=" + message(result));
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }

    private String message(int result) {
        if (result == DefenseScheduleDao.ERR_STUDENT_INVALID) return "defense_student_invalid";
        if (result == DefenseScheduleDao.ERR_TEACHER_COUNT) return "defense_teacher_count";
        if (result == DefenseScheduleDao.ERR_DUPLICATE_TEACHER) return "defense_teacher_duplicate";
        if (result == DefenseScheduleDao.ERR_TEACHER_SCOPE) return "defense_teacher_scope";
        return "error";
    }
}
