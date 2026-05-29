package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.SelectionDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/selection.action")
public class TeacherSelectionController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        SelectionDao dao = new SelectionDao();

        if ("approve".equals(action) || "reject".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = "approve".equals(action) ? "approved" : "rejected";
            String comment = request.getParameter("reviewComment");
            int result = dao.review(id, user.getId(), status, comment);
            if (result == -1) {
                WebUtil.redirect(request, response, "/teacher/selections.jsp?msg=quota_full");
                return;
            }
            bean.TopicSelection sel = dao.findById(id);
            if (sel != null) {
                MessageNotifyUtil.send(sel.getStudentId(), "选题审批结果",
                    "您的选题申请已" + ("approved".equals(status) ? "通过" : "被拒绝"));
            }
            OperationLogUtil.log(user.getId(),
                "approve".equals(action) ? "APPROVE" : "REJECT",
                "topic_selection", "审批选题 id=" + id + " -> " + status);
            WebUtil.redirect(request, response, "/teacher/selections.jsp?msg=" + status);
        } else {
            WebUtil.redirect(request, response, "/teacher/selections.jsp");
        }
    }
}
