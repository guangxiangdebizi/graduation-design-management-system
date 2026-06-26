package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import bean.UserScope;
import dao.DocumentDao;
import util.ScopeUtil;

@WebServlet("/director/document-progress.action")
public class DirectorDocumentProgressController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }
        List<Object[]> rows = new DocumentDao().findProgressByScope(
            scope.getCollege(), scope.getMajor());
        request.setAttribute("progressRows", rows);
        request.setAttribute("directorScopeText", ScopeUtil.scopeText(scope));
        request.getRequestDispatcher("/director/document-progress.jsp").forward(request, response);
    }
}
