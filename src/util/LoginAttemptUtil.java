package util;

import javax.servlet.http.HttpSession;

public class LoginAttemptUtil {
    private static final int MAX_ATTEMPTS = 5;
    private static final long LOCK_MS = 15 * 60 * 1000L;
    private static final String ATTEMPT_PREFIX = "login_attempts_";
    private static final String LOCK_PREFIX = "login_lock_";

    public static boolean isLocked(HttpSession session, String username) {
        if (session == null || username == null) {
            return false;
        }
        Long lockUntil = (Long) session.getAttribute(LOCK_PREFIX + username);
        if (lockUntil == null) {
            return false;
        }
        if (System.currentTimeMillis() >= lockUntil) {
            session.removeAttribute(LOCK_PREFIX + username);
            session.removeAttribute(ATTEMPT_PREFIX + username);
            return false;
        }
        return true;
    }

    public static void recordFailure(HttpSession session, String username) {
        if (session == null || username == null) {
            return;
        }
        String key = ATTEMPT_PREFIX + username;
        Integer attempts = (Integer) session.getAttribute(key);
        int count = attempts == null ? 1 : attempts + 1;
        session.setAttribute(key, count);
        if (count >= MAX_ATTEMPTS) {
            session.setAttribute(LOCK_PREFIX + username, System.currentTimeMillis() + LOCK_MS);
        }
    }

    public static void clear(HttpSession session, String username) {
        if (session == null || username == null) {
            return;
        }
        session.removeAttribute(ATTEMPT_PREFIX + username);
        session.removeAttribute(LOCK_PREFIX + username);
    }
}
