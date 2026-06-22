package util;

/**
 * 输入校验工具类
 */
public class ValidationUtil {

    // 用户名：字母、数字、下划线，3-20位
    private static final String DEFAULT_USERNAME_REGEX = "^[a-zA-Z0-9_]{3,20}$";
    private static final String DEFAULT_STUDENT_NO_REGEX = "^[0-9]{5,20}$";
    private static final String DEFAULT_PHONE_REGEX = "^1[3-9]\\d{9}$";
    private static final String DEFAULT_EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

    public static boolean isValidUsername(String username) {
        return username != null && matches(username, "validation.username_regex", DEFAULT_USERNAME_REGEX);
    }

    public static boolean isValidPassword(String password) {
        return password != null
            && password.length() >= SystemConfigUtil.getInt("validation.password_min_length", 6);
    }

    public static boolean isValidStudentNo(String studentNo) {
        return studentNo == null || studentNo.trim().isEmpty() ||
               matches(studentNo, "validation.student_no_regex", DEFAULT_STUDENT_NO_REGEX);
    }

    public static boolean isValidPhone(String phone) {
        return phone == null || phone.trim().isEmpty() ||
               matches(phone, "validation.phone_regex", DEFAULT_PHONE_REGEX);
    }

    public static boolean isValidEmail(String email) {
        return email == null || email.trim().isEmpty() ||
               matches(email, "validation.email_regex", DEFAULT_EMAIL_REGEX);
    }

    public static boolean isValidRole(String role) {
        return DictionaryUtil.contains("role", role);
    }

    public static String sanitize(String input) {
        return EscapeUtil.html(input);
    }

    private static boolean matches(String value, String configKey, String defaultRegex) {
        String regex = SystemConfigUtil.getString(configKey, defaultRegex);
        try {
            return java.util.regex.Pattern.compile(regex).matcher(value).matches();
        } catch (Exception ex) {
            return java.util.regex.Pattern.compile(defaultRegex).matcher(value).matches();
        }
    }
}
