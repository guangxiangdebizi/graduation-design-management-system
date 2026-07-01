package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.TopicAssignment;
import bean.TopicChoiceGroup;
import bean.User;
import dao.TeacherChoiceReviewDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.SystemSwitchUtil;
import util.WebUtil;

@WebServlet("/teacher/choice-review.action")
public class TeacherChoiceReviewController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        int round = parseRound(request.getParameter("round"));
        List<TopicChoiceGroup> groups = new TeacherChoiceReviewDao()
            .findChoiceGroupsByTeacher(user.getId(), round);
        request.setAttribute("choiceGroups", groups);
        request.setAttribute("currentRound", Integer.valueOf(round));
        request.setAttribute("round1Open", Boolean.valueOf(SystemSwitchUtil.isFirstRoundOpen()));
        request.setAttribute("round2Open", Boolean.valueOf(SystemSwitchUtil.isSecondRoundOpen()));
        request.setAttribute("manualAssignOpen",
            Boolean.valueOf(SystemSwitchUtil.isManualAssignOpen()));
        request.getRequestDispatcher("/teacher/choice-review.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        int choiceId = parseInt(request.getParameter("choiceId"));
        int round = parseRound(request.getParameter("round"));
        String comment = request.getParameter("reviewComment");
        TeacherChoiceReviewDao dao = new TeacherChoiceReviewDao();

        if ("acceptChoice".equals(action)) {
            int result = dao.acceptChoice(user.getId(), choiceId, comment);
            if (result > 0) {
                TopicAssignment assignment = dao.findAssignmentById(result);
                if (assignment != null) {
                    MessageNotifyUtil.send(assignment.getStudentId(), "选题匹配成功",
                        "指导教师已接收您的志愿，最终课题为《"
                        + assignment.getTopicTitle() + "》。");
                }
                OperationLogUtil.log(user.getId(), "ACCEPT_CHOICE", "topic_assignments",
                    "指导教师接收三志愿 choiceId=" + choiceId + ", assignmentId=" + result);
                WebUtil.redirect(request, response,
                    "/teacher/choice-review.action?round=" + round + "&msg=accept_ok");
                return;
            }
            WebUtil.redirect(request, response,
                "/teacher/choice-review.action?round=" + round + "&msg=" + message(result));
            return;
        }

        if ("rejectChoice".equals(action)) {
            int result = dao.rejectChoice(user.getId(), choiceId, comment);
            if (result > 0) {
                OperationLogUtil.log(user.getId(), "REJECT_CHOICE", "selection_choices",
                    "指导教师拒绝三志愿 choiceId=" + choiceId);
                WebUtil.redirect(request, response,
                    "/teacher/choice-review.action?round=" + round + "&msg=reject_ok");
                return;
            }
            WebUtil.redirect(request, response,
                "/teacher/choice-review.action?round=" + round + "&msg=" + message(result));
            return;
        }

        WebUtil.redirect(request, response, "/teacher/choice-review.action?round=" + round);
    }

    private int parseRound(String value) {
        return "2".equals(value) ? 2 : 1;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }

    private String message(int result) {
        if (result == TeacherChoiceReviewDao.ERR_FORBIDDEN) return "forbidden";
        if (result == TeacherChoiceReviewDao.ERR_STUDENT_ASSIGNED) return "student_has_topic";
        if (result == TeacherChoiceReviewDao.ERR_TOPIC_ASSIGNED) return "topic_assigned";
        if (result == TeacherChoiceReviewDao.ERR_CHOICE_INVALID) return "choice_invalid";
        if (result == TeacherChoiceReviewDao.ERR_REVIEW_CLOSED) return "review_closed";
        return "error";
    }
}
