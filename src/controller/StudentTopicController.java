package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.SelectionApplication;
import bean.SelectionChoice;
import bean.User;
import bean.Topic;
import bean.TopicAssignment;
import dao.SelectionChoiceDao;
import dao.SelectionDao;
import dao.TopicAssignmentDao;
import dao.TopicDao;
import util.OperationLogUtil;
import util.ScopeUtil;
import util.SystemSwitchUtil;
import util.WebUtil;
import java.util.List;

@WebServlet("/student/topic.action")
public class StudentTopicController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        User user = (User) request.getSession().getAttribute("loginUser");
        String college = ScopeUtil.clean(user.getCollege());
        String major = ScopeUtil.clean(user.getMajor());
        TopicDao dao = new TopicDao();
        int round = SystemSwitchUtil.currentRound();
        boolean selectionOpen = SystemSwitchUtil.isSelectionOpenForRound(round);
        SelectionChoiceDao choiceDao = new SelectionChoiceDao();
        TopicAssignment assignment = new TopicAssignmentDao().findByStudent(user.getId());
        SelectionDao selectionDao = new SelectionDao();
        bean.TopicSelection legacySelection = assignment == null
            ? selectionDao.findApprovedByStudent(user.getId()) : null;
        SelectionApplication activeApplication = choiceDao.findActiveApplication(user.getId(), round);
        List<SelectionChoice> activeChoices = activeApplication == null
            ? new ArrayList<SelectionChoice>()
            : choiceDao.findByApplication(activeApplication.getId());
        List<Topic> topics = assignment == null && legacySelection == null
            ? choiceDao.findSelectableTopics(user.getId(), round)
            : dao.findOpenTopics(keyword, college, major);
        Map<Integer, Integer> confirmedCounts = choiceDao.confirmedCounts(topics);
        request.setAttribute("topics", topics);
        request.setAttribute("keyword", keyword);
        request.setAttribute("collegeFilter", college);
        request.setAttribute("majorFilter", major);
        request.setAttribute("selectionOpen", Boolean.valueOf(selectionOpen));
        request.setAttribute("manualAssignOpen",
            Boolean.valueOf(SystemSwitchUtil.isManualAssignOpen()));
        request.setAttribute("round", Integer.valueOf(round));
        request.setAttribute("assignment", assignment);
        request.setAttribute("legacySelection", legacySelection);
        request.setAttribute("activeApplication", activeApplication);
        request.setAttribute("activeChoices", activeChoices);
        request.setAttribute("confirmedCounts", confirmedCounts);
        boolean hasChoiceApplication = activeApplication != null;
        request.setAttribute("hasApplied",
            Boolean.valueOf(assignment != null || hasChoiceApplication
                || selectionDao.hasPendingOrApproved(user.getId())));
        request.getRequestDispatcher("/student/topics.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("submitChoices".equals(action)) {
            int round = SystemSwitchUtil.currentRound();
            int result = new SelectionChoiceDao().submitChoices(
                user.getId(), round, parseTopicIds(request));
            if (result > 0) {
                OperationLogUtil.log(user.getId(), "SUBMIT_CHOICES", "selection_choices",
                    "在浏览课题页提交第" + round + "轮志愿 applicationId=" + result);
                WebUtil.redirect(request, response, "/student/topic.action?msg=choice_ok");
                return;
            }
            WebUtil.redirect(request, response, "/student/topic.action?msg=" + choiceMessage(result));
            return;
        }

        if ("apply".equals(action)) {
            if (!SystemSwitchUtil.isSelectionOpen()) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=selection_closed");
                return;
            }
            int topicId = Integer.parseInt(request.getParameter("topicId"));
            String reason = request.getParameter("applyReason");
            int result = dao.apply(user.getId(), topicId, reason);
            if (result == -1) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=already_applied");
                return;
            }
            if (result == -2) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=quota_full");
                return;
            }
            if (result == -3) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=selection_closed");
                return;
            }
            if (result == -4) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=major_mismatch");
                return;
            }
            if (result <= 0) {
                WebUtil.redirect(request, response, "/student/topic.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "APPLY", "topic_selection",
                "申请选题 topicId=" + topicId);
            WebUtil.redirect(request, response, "/student/my-selection.action?msg=apply_ok");
        } else {
            WebUtil.redirect(request, response, "/student/topic.action");
        }
    }

    private List<Integer> parseTopicIds(HttpServletRequest request) {
        List<Integer> ids = new ArrayList<Integer>();
        addTopicId(ids, request.getParameter("topic1"));
        addTopicId(ids, request.getParameter("topic2"));
        addTopicId(ids, request.getParameter("topic3"));
        return ids;
    }

    private void addTopicId(List<Integer> ids, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }
        try {
            int id = Integer.parseInt(value.trim());
            if (id > 0) {
                ids.add(Integer.valueOf(id));
            }
        } catch (NumberFormatException ignored) {
        }
    }

    private String choiceMessage(int result) {
        if (result == SelectionChoiceDao.ERR_HAS_ASSIGNMENT) return "has_assignment";
        if (result == SelectionChoiceDao.ERR_SELECTION_CLOSED) return "selection_closed";
        if (result == SelectionChoiceDao.ERR_CHOICE_COUNT) return "choice_count_invalid";
        if (result == SelectionChoiceDao.ERR_DUPLICATE_CHOICE) return "duplicate_choice";
        if (result == SelectionChoiceDao.ERR_TOPIC_INVALID) return "topic_invalid";
        if (result == SelectionChoiceDao.ERR_ALREADY_SUBMITTED) return "already_submitted";
        return "error";
    }
}
