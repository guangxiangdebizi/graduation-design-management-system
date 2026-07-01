package controller;

import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.DefenseScheduleDao;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/defense.action")
public class TeacherDefenseController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        request.setAttribute("pageTitle", "答辩评分");
        request.setAttribute("tasks", new DefenseScheduleDao().findScoringTasksByTeacher(user.getId()));
        request.getRequestDispatcher("/teacher/defense.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        int scheduleId = parseInt(request.getParameter("scheduleId"));
        BigDecimal score;
        try {
            score = new BigDecimal(request.getParameter("score"));
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/teacher/defense.action?msg=invalid_score");
            return;
        }
        int result = new DefenseScheduleDao().submitScore(
            scheduleId, user.getId(), score, request.getParameter("comment"));
        if (result > 0) {
            OperationLogUtil.log(user.getId(), "DEFENSE_SCORE", "defense_scores",
                "提交答辩评分 scheduleId=" + scheduleId + ", score=" + score);
            WebUtil.redirect(request, response, "/teacher/defense.action?msg=score_ok");
            return;
        }
        WebUtil.redirect(request, response, "/teacher/defense.action?msg=" + message(result));
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }

    private String message(int result) {
        if (result == DefenseScheduleDao.ERR_NOT_MEMBER) return "defense_not_member";
        if (result == DefenseScheduleDao.ERR_SCORE_INVALID) return "invalid_score";
        return "error";
    }
}
