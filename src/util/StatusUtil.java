package util;

public class StatusUtil {
    public static String label(String status) {
        if (status == null || status.isEmpty()) {
            return "";
        }
        return DictionaryUtil.label("status", status.toLowerCase());
    }
}
