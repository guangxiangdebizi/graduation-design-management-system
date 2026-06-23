package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.DefenseSchedule;
import bean.Document;
import bean.User;
import dao.DefenseScheduleDao;
import dao.DocumentDao;
import dao.SelectionDao;
import dao.UserDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/defense.action")
public class AdminDefenseController extends HttpServlet {
    private final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DefenseScheduleDao dao = new DefenseScheduleDao();
        UserDao userDao = new UserDao();
        SelectionDao selectionDao = new SelectionDao();
        DocumentDao documentDao = new DocumentDao();
        List<User> approvedStudents = new ArrayList<User>();
        for (User student : userDao.findAll("student")) {
            Document finalDoc = documentDao.findByStudentAndType(student.getId(), "final");
            if (selectionDao.findApprovedByStudent(student.getId()) != null
                    && finalDoc != null && "reviewed".equals(finalDoc.getStatus())) {
                approvedStudents.add(student);
            }
        }

        request.setAttribute("pageTitle", "答辩安排");
        request.setAttribute("schedules", dao.findAll());
        request.setAttribute("approvedStudents", approvedStudents);
        request.setAttribute("msg", request.getParameter("msg"));
        request.setAttribute("importSuccess", parseInt(request.getParameter("success"), 0));
        request.setAttribute("importSkipped", parseInt(request.getParameter("skipped"), 0));
        request.getRequestDispatcher("/admin/defenses.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        DefenseScheduleDao dao = new DefenseScheduleDao();

        if ("add".equals(action)) {
            DefenseSchedule ds = buildSchedule(request);
            if (!isEligible(ds)) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=defense_ineligible");
                return;
            }
            if (dao.existsByStudent(ds.getStudentId())) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=exists");
                return;
            }
            if (dao.insert(ds) <= 0) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=error");
                return;
            }
            MessageNotifyUtil.send(ds.getStudentId(), "答辩安排通知",
                "您的答辩已安排，时间: " + ds.getDefenseTime() + "，地点: " + ds.getRoom());
            OperationLogUtil.log(user.getId(), "ADD", "defense_schedule",
                "安排答辩: studentId=" + ds.getStudentId());
            WebUtil.redirect(request, response, "/admin/defense.action?msg=add_ok");
        } else if ("edit".equals(action)) {
            DefenseSchedule ds = buildSchedule(request);
            ds.setId(Integer.parseInt(request.getParameter("id")));
            if (!isEligible(ds) || dao.existsByStudentExceptId(ds.getStudentId(), ds.getId())) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=defense_ineligible");
                return;
            }
            if (dao.update(ds) <= 0) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "UPDATE", "defense_schedule",
                "更新答辩安排 id=" + ds.getId());
            WebUtil.redirect(request, response, "/admin/defense.action?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (dao.delete(id) <= 0) {
                WebUtil.redirect(request, response, "/admin/defense.action?msg=error");
                return;
            }
            OperationLogUtil.log(user.getId(), "DELETE", "defense_schedule",
                "删除答辩安排 id=" + id);
            WebUtil.redirect(request, response, "/admin/defense.action?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/admin/defense.action");
        }
    }

    private DefenseSchedule buildSchedule(HttpServletRequest request) throws IOException {
        DefenseSchedule ds = new DefenseSchedule();
        try {
            ds.setStudentId(Integer.parseInt(request.getParameter("studentId")));
            ds.setRoom(request.getParameter("room"));
            ds.setGroupName(request.getParameter("groupName"));
            ds.setComment(request.getParameter("comment"));
            String timeStr = request.getParameter("defenseTime");
            if (timeStr != null && !timeStr.isEmpty()) {
                ds.setDefenseTime(sdf.parse(timeStr));
            }
            String scoreStr = request.getParameter("score");
            if (scoreStr != null && !scoreStr.trim().isEmpty()) {
                ds.setScore(new BigDecimal(scoreStr.trim()));
            }
            return ds;
        } catch (NumberFormatException | ParseException ex) {
            throw new IOException("invalid defense data", ex);
        }
    }

    private boolean isEligible(DefenseSchedule ds) {
        User student = new UserDao().findById(ds.getStudentId());
        if (student == null || !"student".equals(student.getRole()) || student.getStatus() != 1) {
            return false;
        }
        if (new SelectionDao().findApprovedByStudent(student.getId()) == null) {
            return false;
        }
        if (ds.getScore() != null && (ds.getScore().compareTo(BigDecimal.ZERO) < 0
                || ds.getScore().compareTo(new BigDecimal("100")) > 0)) {
            return false;
        }
        Document finalDoc = new DocumentDao().findByStudentAndType(student.getId(), "final");
        return finalDoc != null && "reviewed".equals(finalDoc.getStatus());
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
