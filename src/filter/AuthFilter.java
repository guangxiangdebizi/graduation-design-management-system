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
import dao.UserDao;
import util.CsrfUtil;
import util.RoleUtil;

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

        // 安全响应头
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "SAMEORIGIN");
        response.setHeader("X-XSS-Protection", "1; mode=block");
        response.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        response.setHeader("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; font-src 'self' https://cdn.jsdelivr.net; img-src 'self' data:;");

        String uri = request.getRequestURI();
        String ctx = request.getContextPath();
        String path = uri.substring(ctx.length());

        if (path.startsWith("/uploads/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

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

        User currentUser = new UserDao().findById(user.getId());
        if (currentUser == null || currentUser.getStatus() != 1
                || !currentUser.getRole().equals(user.getRole())) {
            session.invalidate();
            response.sendRedirect(ctx + "/login.jsp?error=account_changed");
            return;
        }

        if (path.startsWith("/admin/") && !"admin".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("/director/") && !"director".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("/teacher/") && !RoleUtil.hasRole(user, "teacher")) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }
        if (path.startsWith("/student/") && !"student".equals(user.getRole())) {
            response.sendRedirect(ctx + "/dashboard.jsp");
            return;
        }

        if (isSafeMethod(request.getMethod())) {
            CsrfUtil.getToken(session);
        }

        if (!isSafeMethod(request.getMethod()) && path.endsWith(".action")
                && !"/login.action".equals(path)) {
            if (!CsrfUtil.validate(request)) {
                String referer = request.getHeader("Referer");
                if (referer != null && referer.startsWith(request.getRequestURL().substring(0,
                        request.getRequestURL().indexOf(ctx) + ctx.length()))) {
                    response.sendRedirect(appendMsg(referer, "csrf_error"));
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid");
                }
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

    private boolean isSafeMethod(String method) {
        return "GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method)
            || "OPTIONS".equalsIgnoreCase(method);
    }

    private String appendMsg(String url, String msg) {
        String sep = url.indexOf('?') >= 0 ? "&" : "?";
        return url + sep + "msg=" + msg;
    }

    public void destroy() {
    }
}
