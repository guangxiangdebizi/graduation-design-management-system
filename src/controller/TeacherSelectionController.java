package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.TopicSelection;
import bean.User;
import dao.SelectionDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/selection.action")
public class TeacherSelectionController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "pending";
        }

        List<TopicSelection> selections = new SelectionDao().findByTeacher(
            user.getId(), "all".equals(status) ? null : status);
        request.setAttribute("selections", selections);
        request.setAttribute("statusFilter", status);
        request.getRequestDispatcher("/teacher/selections.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("approve".equals(action) || "reject".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = "approve".equals(action) ? "approved" : "rejected";
            String comment = request.getParameter("reviewComment");
            int result = dao.review(id, user.getId(), status, comment);

            if (result == -1) {
                WebUtil.redirect(request, response,
                    "/teacher/selection.action?msg=quota_full");
                return;
            }
            if (result == -2) {
                WebUtil.redirect(request, response,
                    "/teacher/selection.action?msg=student_has_topic");
                return;
            }
            if (result <= 0) {
                WebUtil.redirect(request, response,
                    "/teacher/selection.action?msg=error");
                return;
            }

            TopicSelection selection = dao.findById(id);
            if (selection != null) {
                MessageNotifyUtil.send(selection.getStudentId(), "选题审批结果",
                    "您的选题申请已" + ("approved".equals(status) ? "通过" : "被拒绝"));
            }
            OperationLogUtil.log(user.getId(),
                "approve".equals(action) ? "APPROVE" : "REJECT",
                "topic_selection", "审批选题 id=" + id + " -> " + status);
            WebUtil.redirect(request, response,
                "/teacher/selection.action?msg=" + status);
        } else {
            WebUtil.redirect(request, response, "/teacher/selection.action");
        }
    }
}
