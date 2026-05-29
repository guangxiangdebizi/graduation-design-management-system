package util;

import java.util.HashMap;
import java.util.Map;

public class StatusUtil {
    private static final Map<String, String> LABELS = new HashMap<String, String>();

    static {
        LABELS.put("pending", "待审核");
        LABELS.put("approved", "已通过");
        LABELS.put("rejected", "已拒绝");
        LABELS.put("submitted", "已提交");
        LABELS.put("reviewed", "已审核");
        LABELS.put("draft", "草稿");
        LABELS.put("cancelled", "已取消");
        LABELS.put("open", "开放");
        LABELS.put("closed", "已关闭");
    }

    public static String label(String status) {
        if (status == null || status.isEmpty()) {
            return "";
        }
        String key = status.toLowerCase();
        if (LABELS.containsKey(key)) {
            return LABELS.get(key);
        }
        return status;
    }
}
