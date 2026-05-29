package util;

import java.util.UUID;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class CsrfUtil {
    public static final String TOKEN_ATTR = "_csrf_token";
    public static final String PARAM_NAME = "_csrf";

    public static String getToken(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object token = session.getAttribute(TOKEN_ATTR);
        if (token == null) {
            token = UUID.randomUUID().toString().replace("-", "");
            session.setAttribute(TOKEN_ATTR, token);
        }
        return token.toString();
    }

    public static boolean validate(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String expected = (String) session.getAttribute(TOKEN_ATTR);
        if (expected == null || expected.isEmpty()) {
            return false;
        }
        String submitted = request.getParameter(PARAM_NAME);
        if (submitted == null || submitted.isEmpty()) {
            submitted = request.getHeader("X-CSRF-Token");
        }
        return expected.equals(submitted);
    }
}
