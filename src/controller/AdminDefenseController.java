package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.DefenseSchedule;
import bean.User;
import dao.DefenseScheduleDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/defense.action")
public class AdminDefenseController extends HttpServlet {
    private final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        DefenseScheduleDao dao = new DefenseScheduleDao();

        if ("add".equals(action)) {
            DefenseSchedule ds = buildSchedule(request);
            if (dao.existsByStudent(ds.getStudentId())) {
                WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=exists");
                return;
            }
            dao.insert(ds);
            MessageNotifyUtil.send(ds.getStudentId(), "答辩安排通知",
                "您的答辩已安排，时间: " + ds.getDefenseTime() + "，地点: " + ds.getRoom());
            OperationLogUtil.log(user.getId(), "ADD", "defense_schedule",
                "安排答辩: studentId=" + ds.getStudentId());
            WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=add_ok");
        } else if ("edit".equals(action)) {
            DefenseSchedule ds = buildSchedule(request);
            ds.setId(Integer.parseInt(request.getParameter("id")));
            dao.update(ds);
            OperationLogUtil.log(user.getId(), "UPDATE", "defense_schedule",
                "更新答辩安排 id=" + ds.getId());
            WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id);
            OperationLogUtil.log(user.getId(), "DELETE", "defense_schedule",
                "删除答辩安排 id=" + id);
            WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, "/admin/defenses.jsp");
        }
    }

    private DefenseSchedule buildSchedule(HttpServletRequest request) throws IOException {
        DefenseSchedule ds = new DefenseSchedule();
        ds.setStudentId(Integer.parseInt(request.getParameter("studentId")));
        ds.setRoom(request.getParameter("room"));
        ds.setGroupName(request.getParameter("groupName"));
        ds.setComment(request.getParameter("comment"));
        String timeStr = request.getParameter("defenseTime");
        if (timeStr != null && timeStr.length() > 0) {
            try {
                ds.setDefenseTime(sdf.parse(timeStr));
            } catch (ParseException e) {
                throw new IOException("invalid defense time");
            }
        }
        String scoreStr = request.getParameter("score");
        if (scoreStr != null && scoreStr.trim().length() > 0) {
            ds.setScore(new BigDecimal(scoreStr.trim()));
        }
        return ds;
    }
}
