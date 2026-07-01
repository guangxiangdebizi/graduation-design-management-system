package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.Document;
import bean.User;
import bean.UserScope;
import dao.DocumentDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.ScopeUtil;
import util.WebUtil;

@WebServlet("/director/paper-review.action")
public class DirectorPaperReviewController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        DocumentDao dao = new DocumentDao();
        List<Document> documents = dao.findFinalsForReviewerArrangement(
            scope.getCollege(), scope.getMajor());
        request.setAttribute("pageTitle", "本专业论文评阅安排");
        request.setAttribute("documents", documents);
        request.setAttribute("reviewerCandidates", dao.findPaperReviewerCandidates(
            scope.getCollege(), scope.getMajor()));
        request.setAttribute("directorScopeText", ScopeUtil.scopeText(scope));
        request.getRequestDispatcher("/director/paper-review.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        int documentId = parseInt(request.getParameter("documentId"));
        int reviewerId = parseInt(request.getParameter("reviewerId"));
        int result = new DocumentDao().arrangePaperReviewer(documentId, reviewerId,
            user.getId(), scope.getCollege(), scope.getMajor());
        if (result > 0) {
            MessageNotifyUtil.send(reviewerId, "论文评阅任务",
                "系主任已为您分配终稿论文评阅任务，请进入教师端论文评阅页面完成评分。");
            OperationLogUtil.log(user.getId(), "ARRANGE_PAPER_REVIEW", "documents",
                "指定论文评阅教师 documentId=" + documentId + ", reviewerId=" + reviewerId);
            WebUtil.redirect(request, response, "/director/paper-review.action?msg=reviewer_ok");
        } else {
            WebUtil.redirect(request, response, "/director/paper-review.action?msg=reviewer_invalid");
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
