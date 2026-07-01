package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.Document;
import bean.User;
import dao.DocumentDao;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/teacher/paper-review.action")
public class TeacherPaperReviewController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        List<Document> documents = new DocumentDao().findFinalsForPaperReview(user.getId());
        request.setAttribute("pageTitle", "论文评阅评分");
        request.setAttribute("documents", documents);
        request.getRequestDispatcher("/teacher/paper-review.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        int documentId = parseInt(request.getParameter("documentId"));
        BigDecimal score;
        try {
            score = new BigDecimal(request.getParameter("score"));
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/teacher/paper-review.action?msg=invalid_score");
            return;
        }

        int result = new DocumentDao().submitPaperReview(documentId, user.getId(),
            score, request.getParameter("comment"));
        if (result > 0) {
            OperationLogUtil.log(user.getId(), "PAPER_REVIEW_SCORE", "documents",
                "提交论文评阅评分 documentId=" + documentId + ", score=" + score);
            WebUtil.redirect(request, response, "/teacher/paper-review.action?msg=score_ok");
        } else {
            WebUtil.redirect(request, response, "/teacher/paper-review.action?msg=invalid_score");
        }
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ex) {
            return 0;
        }
    }
}
