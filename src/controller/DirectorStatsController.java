package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import bean.UserScope;
import bean.UserSearchCriteria;
import dao.StatsDao;
import dao.UserDao;
import util.ScopeUtil;

@WebServlet("/director/stats.action")
public class DirectorStatsController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        response.setContentType("application/json;charset=UTF-8");
        UserSearchCriteria criteria = new UserSearchCriteria();
        criteria.setRole("student");
        criteria.setCollege(scope.getCollege());
        criteria.setMajor(scope.getMajor());

        StatsDao statsDao = new StatsDao();
        int studentCount = new UserDao().countAll(criteria);
        Map<String, Integer> selection = statsDao.selectionStats(
            studentCount, scope.getCollege(), scope.getMajor());
        Map<String, Integer> docPass = statsDao.docPassStats(scope.getCollege(), scope.getMajor());
        List<Object[]> scores = statsDao.scoreDistribution(scope.getCollege(), scope.getMajor());

        PrintWriter out = response.getWriter();
        out.print("{");
        out.print("\"selection\":" + mapToJson(selection) + ",");
        out.print("\"docPass\":" + mapToJson(docPass) + ",");
        out.print("\"scores\":{\"labels\":" + labelsJson(scores) + ",\"values\":" + valuesJson(scores) + "}");
        out.print("}");
        out.flush();
    }

    private String mapToJson(Map<String, Integer> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> e : map.entrySet()) {
            if (!first) {
                sb.append(",");
            }
            sb.append("\"").append(escape(e.getKey())).append("\":").append(e.getValue());
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }

    private String labelsJson(List<Object[]> rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append("\"").append(escape(String.valueOf(rows.get(i)[0]))).append("\"");
        }
        sb.append("]");
        return sb.toString();
    }

    private String valuesJson(List<Object[]> rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(((Number) rows.get(i)[1]).intValue());
        }
        sb.append("]");
        return sb.toString();
    }

    private String escape(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
