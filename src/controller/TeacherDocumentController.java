package controller;

import java.io.IOException;
import java.math.BigDecimal;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.DocumentDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/document.action")
public class TeacherDocumentController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        DocumentDao dao = new DocumentDao();

        if ("review".equals(action) || "reject".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = "review".equals(action) ? "reviewed" : "rejected";
            String scoreStr = request.getParameter("score");
            BigDecimal score = scoreStr == null || scoreStr.trim().isEmpty()
                ? null : new BigDecimal(scoreStr);
            String feedback = request.getParameter("feedback");
            bean.Document doc = dao.findById(id);
            dao.review(id, user.getId(), status, score, feedback);
            if (doc != null) {
                MessageNotifyUtil.send(doc.getStudentId(), "文档审核结果",
                    "您的" + doc.getDocType() + "文档已被" + ("reviewed".equals(status) ? "审核通过" : "退回"));
            }
            OperationLogUtil.log(user.getId(),
                "review".equals(action) ? "REVIEW" : "REJECT",
                "document", "审核文档 id=" + id + " -> " + status);
            WebUtil.redirect(request, response,
                "/teacher/documents.jsp?msg=" + status + "&type=" + request.getParameter("docType"));
        } else {
            WebUtil.redirect(request, response, "/teacher/documents.jsp");
        }
    }
}
