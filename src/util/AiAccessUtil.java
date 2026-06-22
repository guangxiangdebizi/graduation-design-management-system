package util;

import bean.User;

public class AiAccessUtil {
    public static String roleFromPath(String path) {
        if (path == null) {
            return "";
        }
        if (path.startsWith("/admin/")) {
            return "admin";
        }
        if (path.startsWith("/teacher/")) {
            return "teacher";
        }
        if (path.startsWith("/student/")) {
            return "student";
        }
        return "";
    }

    public static String roleName(String role) {
        if ("admin".equals(role)) {
            return "管理员";
        }
        if ("teacher".equals(role)) {
            return "教师";
        }
        if ("student".equals(role)) {
            return "学生";
        }
        return "用户";
    }

    public static String sessionKey(User user) {
        if (user == null) {
            return "ai.chat.anonymous";
        }
        return "ai.chat." + user.getRole() + "." + user.getId();
    }
}
