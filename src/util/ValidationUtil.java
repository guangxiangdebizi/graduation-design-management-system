package util;

/**
 * 输入校验工具类
 */
public class ValidationUtil {

    // 用户名：字母、数字、下划线，3-20位
    private static final java.util.regex.Pattern USERNAME_PATTERN =
        java.util.regex.Pattern.compile("^[a-zA-Z0-9_]{3,20}$");

    // 密码：至少6位
    private static final int MIN_PASSWORD_LENGTH = 6;

    // 学号/工号：数字，5-20位
    private static final java.util.regex.Pattern STUDENT_NO_PATTERN =
        java.util.regex.Pattern.compile("^[0-9]{5,20}$");

    // 手机号：中国大陆手机号
    private static final java.util.regex.Pattern PHONE_PATTERN =
        java.util.regex.Pattern.compile("^1[3-9]\\d{9}$");

    // 邮箱
    private static final java.util.regex.Pattern EMAIL_PATTERN =
        java.util.regex.Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }

    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= MIN_PASSWORD_LENGTH;
    }

    public static boolean isValidStudentNo(String studentNo) {
        return studentNo == null || studentNo.trim().isEmpty() ||
               STUDENT_NO_PATTERN.matcher(studentNo).matches();
    }

    public static boolean isValidPhone(String phone) {
        return phone == null || phone.trim().isEmpty() ||
               PHONE_PATTERN.matcher(phone).matches();
    }

    public static boolean isValidEmail(String email) {
        return email == null || email.trim().isEmpty() ||
               EMAIL_PATTERN.matcher(email).matches();
    }

    public static boolean isValidRole(String role) {
        return "admin".equals(role) || "teacher".equals(role) || "student".equals(role);
    }

    public static String sanitize(String input) {
        return EscapeUtil.html(input);
    }
}