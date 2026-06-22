package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.Document;
import bean.User;
import dao.DocumentDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/document.action")
public class TeacherDocumentController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        String docType = normalizeDocType(request.getParameter("type"));
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "submitted";
        }

        DocumentDao dao = new DocumentDao();
        List<Document> documents = dao.findByTeacher(
            user.getId(), docType, "all".equals(status) ? null : status);
        request.setAttribute("documents", documents);
        request.setAttribute("docType", docType);
        request.setAttribute("statusFilter", status);
        request.setAttribute("typeNames", documentTypeNames());
        request.getRequestDispatcher("/teacher/documents.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        String action = request.getParameter("action");
        DocumentDao dao = new DocumentDao();

        if ("review".equals(action) || "reject".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = "review".equals(action) ? "reviewed" : "rejected";
            BigDecimal score;
            try {
                String scoreText = request.getParameter("score");
                score = scoreText == null || scoreText.trim().isEmpty()
                    ? null : new BigDecimal(scoreText);
            } catch (NumberFormatException ex) {
                redirectToList(request, response, "invalid_score");
                return;
            }
            if ("review".equals(action) && (score == null
                    || score.compareTo(BigDecimal.ZERO) < 0
                    || score.compareTo(new BigDecimal("100")) > 0)) {
                redirectToList(request, response, "invalid_score");
                return;
            }

            String feedback = request.getParameter("feedback");
            Document document = dao.findById(id);
            int result = dao.review(id, user.getId(), status, score, feedback);
            if (result <= 0 || document == null) {
                redirectToList(request, response, "error");
                return;
            }

            MessageNotifyUtil.send(document.getStudentId(), "文档审核结果",
                "您的" + document.getDocType() + "文档已被"
                + ("reviewed".equals(status) ? "审核通过" : "退回"));
            OperationLogUtil.log(user.getId(),
                "review".equals(action) ? "REVIEW" : "REJECT",
                "document", "审核文档 id=" + id + " -> " + status);
            redirectToList(request, response, status);
        } else {
            WebUtil.redirect(request, response, "/teacher/document.action");
        }
    }

    private void redirectToList(HttpServletRequest request, HttpServletResponse response,
            String message) throws IOException {
        String docType = normalizeDocType(request.getParameter("docType"));
        WebUtil.redirect(request, response,
            "/teacher/document.action?msg=" + message + "&type=" + docType);
    }

    private String normalizeDocType(String docType) {
        if ("midterm".equals(docType) || "final".equals(docType)) {
            return docType;
        }
        return "proposal";
    }

    private Map<String, String> documentTypeNames() {
        Map<String, String> names = new LinkedHashMap<String, String>();
        names.put("proposal", "开题报告");
        names.put("midterm", "中期检查");
        names.put("final", "终稿");
        return names;
    }
}
