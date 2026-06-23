package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.Announcement;
import bean.DefenseSchedule;
import bean.Document;
import bean.TopicSelection;
import bean.User;
import bean.UserScope;
import bean.UserSearchCriteria;
import dao.AnnouncementDao;
import dao.DefenseScheduleDao;
import dao.DocumentDao;
import dao.SelectionDao;
import dao.TopicDao;
import dao.UserDao;
import util.ScopeUtil;

@WebServlet("/dashboard.action")
public class DashboardController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.setAttribute("pageTitle", "仪表盘");
        String role = user.getRole();
        if ("admin".equals(role) || "director".equals(role)) {
            prepareAdminOrDirector(request, response, user);
            if (response.isCommitted()) {
                return;
            }
        } else if ("teacher".equals(role)) {
            prepareTeacher(request, user);
        } else {
            prepareStudent(request, user);
        }
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    private void prepareAdminOrDirector(HttpServletRequest request,
            HttpServletResponse response, User user) throws IOException {
        boolean director = "director".equals(user.getRole());
        UserScope directorScope = director ? ScopeUtil.directorScope(user) : null;
        if (director && directorScope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        UserDao userDao = new UserDao();
        TopicDao topicDao = new TopicDao();
        SelectionDao selectionDao = new SelectionDao();
        AnnouncementDao announcementDao = new AnnouncementDao();

        int teacherCount;
        int studentCount;
        int topicCount;
        int selectedCount;
        List<Announcement> announcements;
        if (director) {
            UserSearchCriteria teacherCriteria = new UserSearchCriteria();
            teacherCriteria.setRole("teacher");
            teacherCriteria.setCollege(directorScope.getCollege());
            teacherCriteria.setMajor(directorScope.getMajor());
            UserSearchCriteria studentCriteria = new UserSearchCriteria();
            studentCriteria.setRole("student");
            studentCriteria.setCollege(directorScope.getCollege());
            studentCriteria.setMajor(directorScope.getMajor());
            teacherCount = userDao.countAll(teacherCriteria);
            studentCount = userDao.countAll(studentCriteria);
            topicCount = topicDao.countByMajor(directorScope.getCollege(), directorScope.getMajor());
            selectedCount = selectionDao.countApprovedStudents(
                directorScope.getCollege(), directorScope.getMajor());
            announcements = announcementDao.findVisible(
                directorScope.getCollege(), directorScope.getMajor());
        } else {
            teacherCount = userDao.countByRole("teacher");
            studentCount = userDao.countByRole("student");
            topicCount = topicDao.countAll();
            selectedCount = selectionDao.countApprovedStudents();
            announcements = announcementDao.findAll();
        }

        request.setAttribute("teacherCount", Integer.valueOf(teacherCount));
        request.setAttribute("studentCount", Integer.valueOf(studentCount));
        request.setAttribute("topicCount", Integer.valueOf(topicCount));
        request.setAttribute("selectedCount", Integer.valueOf(selectedCount));
        request.setAttribute("announcements", announcements);
        request.setAttribute("directorScope", directorScope);

        if (director) {
            request.setAttribute("myTopics",
                Integer.valueOf(topicDao.findByTeacher(user.getId()).size()));
            request.setAttribute("pendingSel",
                Integer.valueOf(selectionDao.countPendingByTeacher(user.getId())));
            request.setAttribute("pendingDirectorSel",
                Integer.valueOf(selectionDao.countPendingByDirector(
                    directorScope.getCollege(), directorScope.getMajor())));
            request.setAttribute("pendingDoc",
                Integer.valueOf(new DocumentDao().countPendingByTeacher(user.getId())));
            request.setAttribute("pendingList",
                selectionDao.findByTeacher(user.getId(), "pending"));
        } else {
            request.setAttribute("myTopics", Integer.valueOf(0));
            request.setAttribute("pendingSel", Integer.valueOf(0));
            request.setAttribute("pendingDirectorSel", Integer.valueOf(0));
            request.setAttribute("pendingDoc", Integer.valueOf(0));
            request.setAttribute("pendingList", new ArrayList<TopicSelection>());
        }
    }

    private void prepareTeacher(HttpServletRequest request, User user) {
        TopicDao topicDao = new TopicDao();
        SelectionDao selectionDao = new SelectionDao();
        DocumentDao documentDao = new DocumentDao();
        AnnouncementDao announcementDao = new AnnouncementDao();

        request.setAttribute("myTopics",
            Integer.valueOf(topicDao.findByTeacher(user.getId()).size()));
        request.setAttribute("pendingSel",
            Integer.valueOf(selectionDao.countPendingByTeacher(user.getId())));
        request.setAttribute("pendingDoc",
            Integer.valueOf(documentDao.countPendingByTeacher(user.getId())));
        request.setAttribute("pendingList",
            selectionDao.findByTeacher(user.getId(), "pending"));
        request.setAttribute("announcements",
            announcementDao.findVisible(user.getCollege(), user.getMajor()));
    }

    private void prepareStudent(HttpServletRequest request, User user) {
        SelectionDao selectionDao = new SelectionDao();
        DocumentDao documentDao = new DocumentDao();
        AnnouncementDao announcementDao = new AnnouncementDao();
        DefenseScheduleDao defenseDao = new DefenseScheduleDao();

        TopicSelection approved = selectionDao.findApprovedByStudent(user.getId());
        List<TopicSelection> selections = selectionDao.findByStudent(user.getId());
        List<Document> documents = documentDao.findByStudent(user.getId());
        List<Announcement> announcements = announcementDao.findVisible(
            user.getCollege(), user.getMajor());
        DefenseSchedule defense = defenseDao.findByStudent(user.getId());

        String selectionStatusText = "未选题";
        if (approved != null) {
            selectionStatusText = "已通过";
        } else if (!selections.isEmpty()) {
            String latestStatus = selections.get(0).getStatus();
            if ("pending".equals(latestStatus)) {
                selectionStatusText = "待审核";
            } else if ("rejected".equals(latestStatus)) {
                selectionStatusText = "已驳回";
            }
        }

        request.setAttribute("approvedSelection", approved);
        request.setAttribute("mySelections", selections);
        request.setAttribute("myDocs", documents);
        request.setAttribute("announcements", announcements);
        request.setAttribute("defense", defense);
        request.setAttribute("selectionStatusText", selectionStatusText);
    }
}
