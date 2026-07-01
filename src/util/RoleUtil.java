package util;

import bean.User;

public class RoleUtil {
    public static boolean hasRole(User user, String requiredRole) {
        return user != null && hasRole(user.getRole(), requiredRole);
    }

    public static boolean hasRole(String actualRole, String requiredRole) {
        if (actualRole == null || requiredRole == null) {
            return false;
        }
        if (actualRole.equals(requiredRole)) {
            return true;
        }
        return "director".equals(actualRole) && "teacher".equals(requiredRole);
    }
}
