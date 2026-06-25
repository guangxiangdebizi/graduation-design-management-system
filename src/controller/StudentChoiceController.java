package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.SelectionApplication;
import bean.SelectionChoice;
import bean.Topic;
import bean.TopicAssignment;
import bean.TopicSelection;
import bean.User;
import dao.SelectionChoiceDao;
import dao.SelectionDao;
import dao.TopicAssignmentDao;
import util.OperationLogUtil;
import util.SystemConfigUtil;
import util.SystemSwitchUtil;
import util.WebUtil;

@WebServlet("/student/choice.action")
public class StudentChoiceController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        int round = SystemSwitchUtil.currentRound();
        SelectionChoiceDao choiceDao = new SelectionChoiceDao();
        TopicAssignment assignment = new TopicAssignmentDao().findByStudent(user.getId());
        TopicSelection legacySelection = assignment == null
            ? new SelectionDao().findApprovedByStudent(user.getId()) : null;
        SelectionApplication activeApplication = choiceDao.findActiveApplication(user.getId(), round);
        List<SelectionChoice> activeChoices = activeApplication == null
            ? new ArrayList<SelectionChoice>()
            : choiceDao.findByApplication(activeApplication.getId());
        List<Topic> topics = assignment == null && legacySelection == null
            ? choiceDao.findSelectableTopics(user.getId(), round)
            : new ArrayList<Topic>();
        Map<Integer, Integer> intentCounts = choiceDao.intentCounts(topics, round);

        request.setAttribute("pageTitle", "志愿填报");
        request.setAttribute("round", Integer.valueOf(round));
        request.setAttribute("selectionOpen",
            Boolean.valueOf(SystemSwitchUtil.isEnabled(SystemSwitchUtil.SELECTION)));
        request.setAttribute("intentLimit",
            Integer.valueOf(SystemConfigUtil.getInt("selection.intent_limit", 3)));
        request.setAttribute("choiceLimit",
            Integer.valueOf(SystemConfigUtil.getInt("selection.choice_limit", 3)));
        request.setAttribute("assignment", assignment);
        request.setAttribute("legacySelection", legacySelection);
        request.setAttribute("activeApplication", activeApplication);
        request.setAttribute("activeChoices", activeChoices);
        request.setAttribute("topics", topics);
        request.setAttribute("intentCounts", intentCounts);
        request.getRequestDispatcher("/student/choices.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        if (!"submit".equals(action)) {
            WebUtil.redirect(request, response, "/student/choice.action");
            return;
        }

        List<Integer> topicIds = parseTopicIds(request);
        int result = new SelectionChoiceDao().submitChoices(
            user.getId(), SystemSwitchUtil.currentRound(), topicIds);
        if (result > 0) {
            OperationLogUtil.log(user.getId(), "SUBMIT_CHOICES", "selection_choices",
                "提交第" + SystemSwitchUtil.currentRound() + "轮志愿 applicationId=" + result);
            WebUtil.redirect(request, response, "/student/choice.action?msg=choice_ok");
            return;
        }
        WebUtil.redirect(request, response, "/student/choice.action?msg=" + message(result));
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

    private String message(int result) {
        if (result == SelectionChoiceDao.ERR_HAS_ASSIGNMENT) return "has_assignment";
        if (result == SelectionChoiceDao.ERR_SELECTION_CLOSED) return "selection_closed";
        if (result == SelectionChoiceDao.ERR_CHOICE_COUNT) return "choice_count_invalid";
        if (result == SelectionChoiceDao.ERR_DUPLICATE_CHOICE) return "duplicate_choice";
        if (result == SelectionChoiceDao.ERR_TOPIC_INVALID) return "topic_invalid";
        if (result == SelectionChoiceDao.ERR_INTENT_FULL) return "intent_full";
        if (result == SelectionChoiceDao.ERR_ALREADY_SUBMITTED) return "already_submitted";
        return "error";
    }
}

