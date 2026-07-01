package util;

import bean.Topic;
import bean.User;
import bean.UserScope;

public class ScopeUtil {
    public static UserScope adminScope(User user) {
        if (user == null || !"admin".equals(user.getRole())) {
            return null;
        }
        return new UserScope(true, null, null);
    }

    public static UserScope directorScope(User user) {
        if (user == null || !"director".equals(user.getRole())) {
            return null;
        }
        String college = clean(user.getCollege());
        String major = clean(user.getMajor());
        if (college == null || major == null) {
            return null;
        }
        return new UserScope(false, college, major);
    }

    public static boolean inDirectorScope(User user, Topic topic) {
        UserScope scope = directorScope(user);
        return scope != null && topic != null
            && same(scope.getCollege(), clean(topic.getCollege()))
            && same(scope.getMajor(), clean(topic.getMajor()));
    }

    public static String scopeText(UserScope scope) {
        if (scope == null || scope.isGlobal()) {
            return "全校";
        }
        return CollegeUtil.getCollegeName(scope.getCollege())
            + " / " + CollegeUtil.getMajorName(scope.getCollege(), scope.getMajor());
    }

    public static String clean(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private static boolean same(String left, String right) {
        if (left == null || right == null) {
            return left == right;
        }
        return left.equals(right);
    }
}
