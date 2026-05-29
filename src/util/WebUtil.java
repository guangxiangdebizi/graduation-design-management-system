package util;

import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class WebUtil {
    public static String ctx(HttpServletRequest request) {
        return request.getContextPath();
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
            throws IOException {
        if (path == null || path.isEmpty()) {
            response.sendRedirect(ctx(request) + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("http://") || path.startsWith("https://")) {
            response.sendRedirect(path);
            return;
        }
        if (path.startsWith("/")) {
            response.sendRedirect(ctx(request) + path);
        } else {
            response.sendRedirect(path);
        }
    }
}
