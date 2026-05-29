package util;

import javax.servlet.http.HttpServletRequest;

public class PageUtil {
    public static final int DEFAULT_PAGE_SIZE = 10;

    public static int getPage(HttpServletRequest request) {
        return parsePositive(request.getParameter("page"), 1);
    }

    public static int getPageSize(HttpServletRequest request) {
        return parsePositive(request.getParameter("pageSize"), DEFAULT_PAGE_SIZE);
    }

    public static int offset(int page, int pageSize) {
        if (page < 1) {
            page = 1;
        }
        if (pageSize < 1) {
            pageSize = DEFAULT_PAGE_SIZE;
        }
        return (page - 1) * pageSize;
    }

    public static int totalPages(int total, int pageSize) {
        if (pageSize < 1) {
            pageSize = DEFAULT_PAGE_SIZE;
        }
        if (total <= 0) {
            return 0;
        }
        return (total + pageSize - 1) / pageSize;
    }

    private static int parsePositive(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int n = Integer.parseInt(value.trim());
            return n > 0 ? n : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
