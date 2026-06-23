package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.OperationLog;
import dao.OperationLogDao;
import util.PageUtil;

@WebServlet("/admin/logs.action")
public class AdminLogController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer filterUserId = parseUserId(request.getParameter("userId"));
        String filterAction = blankToNull(request.getParameter("action"));
        String dateFrom = blankToNull(request.getParameter("dateFrom"));
        String dateTo = blankToNull(request.getParameter("dateTo"));
        int page = PageUtil.getPage(request);
        int pageSize = PageUtil.getPageSize(request);

        OperationLogDao dao = new OperationLogDao();
        List<OperationLog> logs = dao.findFiltered(
            filterUserId, filterAction, dateFrom, dateTo, page, pageSize);
        int total = dao.countFiltered(filterUserId, filterAction, dateFrom, dateTo);

        request.setAttribute("pageTitle", "操作日志");
        request.setAttribute("logs", logs);
        request.setAttribute("total", total);
        request.setAttribute("filterUserId", filterUserId);
        request.setAttribute("filterAction", filterAction);
        request.setAttribute("dateFrom", dateFrom);
        request.setAttribute("dateTo", dateTo);
        request.setAttribute("baseUrl", buildBaseUrl(request, filterUserId,
            filterAction, dateFrom, dateTo));
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.getRequestDispatcher("/admin/logs.jsp").forward(request, response);
    }

    private Integer parseUserId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String buildBaseUrl(HttpServletRequest request, Integer userId,
            String action, String dateFrom, String dateTo) {
        StringBuilder sb = new StringBuilder();
        sb.append(request.getContextPath()).append("/admin/logs.action");
        StringBuilder query = new StringBuilder();
        if (userId != null) {
            appendQuery(query, "userId", String.valueOf(userId));
        }
        appendQuery(query, "action", action);
        appendQuery(query, "dateFrom", dateFrom);
        appendQuery(query, "dateTo", dateTo);
        if (query.length() > 0) {
            sb.append("?").append(query);
        }
        return sb.toString();
    }

    private void appendQuery(StringBuilder sb, String key, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }
        try {
            if (sb.length() > 0) {
                sb.append("&");
            }
            sb.append(URLEncoder.encode(key, "UTF-8"))
                .append("=")
                .append(URLEncoder.encode(value, "UTF-8"));
        } catch (Exception ignored) {
        }
    }
}
