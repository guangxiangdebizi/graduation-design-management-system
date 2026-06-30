package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.TopicAssignment;
import bean.TopicSelection;
import bean.User;
import bean.UserScope;
import dao.SelectionChoiceDao;
import dao.SelectionDao;
import dao.TopicAssignmentDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.ScopeUtil;
import util.SystemSwitchUtil;
import util.WebUtil;

@WebServlet("/director/selection-confirm.action")
public class DirectorSelectionConfirmController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "pending";
        }
        SelectionDao selectionDao = new SelectionDao();
        TopicAssignmentDao assignmentDao = new TopicAssignmentDao();
        int round = SystemSwitchUtil.currentRound();
        if ("2".equals(request.getParameter("round"))) {
            round = 2;
        } else if ("1".equals(request.getParameter("round"))) {
            round = 1;
        }
        request.setAttribute("choiceGroups", new SelectionChoiceDao().findTopicChoiceGroups(
            scope.getCollege(), scope.getMajor(), round));
        request.setAttribute("assignments", assignmentDao.findByDirectorScope(
            scope.getCollege(), scope.getMajor()));
        request.setAttribute("selections", selectionDao.findByDirectorScope(
            scope.getCollege(), scope.getMajor(), "all".equals(status) ? null : status));
        request.setAttribute("statusFilter", status);
        request.setAttribute("currentRound", Integer.valueOf(round));
        request.setAttribute("unselectedStudents", assignmentDao.findUnassignedStudents(
            scope.getCollege(), scope.getMajor()));
        request.setAttribute("availableTopics", assignmentDao.findAssignableTopics(
            scope.getCollege(), scope.getMajor()));
        request.setAttribute("directorScopeText", ScopeUtil.scopeText(scope));
        request.setAttribute("manualAssignOpen",
            Boolean.valueOf(SystemSwitchUtil.isManualAssignOpen()));
        request.getRequestDispatcher("/director/selection-confirm.jsp").forward(request, response);
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
        SelectionDao dao = new SelectionDao();
        TopicAssignmentDao assignmentDao = new TopicAssignmentDao();
        if ("confirmChoice".equals(action)) {
            WebUtil.redirect(request, response,
                "/director/selection-confirm.action?msg=teacher_review_required");
            return;
        }

        if ("confirm".equals(action) || "reject".equals(action)) {
            int id = parseInt(request.getParameter("id"));
            String comment = request.getParameter("reviewComment");
            int result = "confirm".equals(action)
                ? dao.confirmByDirector(id, scope.getCollege(), scope.getMajor(), comment)
                : dao.rejectByDirector(id, scope.getCollege(), scope.getMajor(), comment);
            if (result == -1) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=quota_full");
                return;
            }
            if (result == -2) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=student_has_topic");
                return;
            }
            if (result <= 0) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=error");
                return;
            }
            TopicSelection selection = dao.findById(id);
            if (selection != null) {
                MessageNotifyUtil.send(selection.getStudentId(), "选题确认结果",
                    "confirm".equals(action)
                        ? "系主任已确认您的选题《" + selection.getTopicTitle() + "》。"
                        : "系主任未确认您的选题申请，请参加下一轮选题或等待强制分配。");
            }
            OperationLogUtil.log(user.getId(),
                "confirm".equals(action) ? "CONFIRM" : "REJECT",
                "topic_selection", "系主任确认本专业选题 id=" + id + " action=" + action);
            WebUtil.redirect(request, response, "/director/selection-confirm.action?msg="
                + ("confirm".equals(action) ? "approved" : "rejected"));
            return;
        }

        if ("assign".equals(action)) {
            if (!SystemSwitchUtil.isManualAssignOpen()) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=assign_closed");
                return;
            }
            int studentId = parseInt(request.getParameter("studentId"));
            int topicId = parseInt(request.getParameter("topicId"));
            int result = assignmentDao.manualAssign(studentId, topicId, user.getId(),
                scope.getCollege(), scope.getMajor(), request.getParameter("reviewComment"));
            if (result == TopicAssignmentDao.ERR_TOPIC_ASSIGNED
                    || result == TopicAssignmentDao.ERR_CHOICE_INVALID) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=topic_assigned");
                return;
            }
            if (result == TopicAssignmentDao.ERR_STUDENT_ASSIGNED) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=student_has_topic");
                return;
            }
            if (result == TopicAssignmentDao.ERR_SCOPE) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=forbidden");
                return;
            }
            if (result <= 0) {
                WebUtil.redirect(request, response,
                    "/director/selection-confirm.action?msg=error");
                return;
            }
            TopicAssignment assignment = assignmentDao.findById(result);
            MessageNotifyUtil.send(studentId, "选题分配结果",
                assignment == null ? "系主任已为您强制分配毕业设计题目。"
                    : "系主任已为您强制分配毕业设计题目《" + assignment.getTopicTitle() + "》。");
            OperationLogUtil.log(user.getId(), "ASSIGN", "topic_assignments",
                "系主任强制分配选题 studentId=" + studentId + ", topicId=" + topicId);
            WebUtil.redirect(request, response, "/director/selection-confirm.action?msg=assign_ok");
            return;
        }

        WebUtil.redirect(request, response, "/director/selection-confirm.action");
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }
}
