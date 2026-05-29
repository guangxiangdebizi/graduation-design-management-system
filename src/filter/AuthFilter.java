package filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import util.CsrfUtil;

@WebFilter("/*")
public class AuthFilter implements Filter {
    public void init(FilterConfig config) throws ServletException {
    }

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String uri = request.getRequestURI();
        String ctx = request.getContextPath();
        String path = uri.substring(ctx.length());

        if (isPublic(path)) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        if (path.startsWith("/admin/") && !"admin".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("/teacher/") && !"teacher".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("/student/") && !"student".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            CsrfUtil.getToken(session);
        }

        if ("POST".equalsIgnoreCase(request.getMethod()) && path.endsWith(".action")
                && !"/login.action".equals(path)) {
            if (!CsrfUtil.validate(request)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid");
                return;
            }
        }

        chain.doFilter(req, res);
    }

    private boolean isPublic(String path) {
        if (path.equals("/") || path.equals("/index.jsp") || path.equals("/login.jsp")) {
            return true;
        }
        if (path.equals("/login.action")) {
            return true;
        }
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/error/")) {
            return true;
        }
        return false;
    }

    public void destroy() {
    }
}
