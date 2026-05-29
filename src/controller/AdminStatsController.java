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
import dao.StatsDao;
import dao.UserDao;

@WebServlet("/admin/stats.action")
public class AdminStatsController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        StatsDao statsDao = new StatsDao();
        UserDao userDao = new UserDao();
        int studentCount = userDao.countByRole("student");
        Map<String, Integer> selection = statsDao.selectionStats(studentCount);
        Map<String, Integer> docPass = statsDao.docPassStats();
        List<Object[]> scores = statsDao.scoreDistribution();

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
