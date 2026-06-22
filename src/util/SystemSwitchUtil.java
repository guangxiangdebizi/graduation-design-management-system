package util;

import java.util.LinkedHashMap;
import java.util.Map;

public class SystemSwitchUtil {
    public static final String TOPIC_SUBMIT = "switch.topic_submit";
    public static final String SELECTION = "switch.selection";
    public static final String SELECTION_ROUND1 = "switch.selection_round1";
    public static final String UPLOAD_PROPOSAL = "switch.upload_proposal";
    public static final String UPLOAD_MIDTERM = "switch.upload_midterm";
    public static final String UPLOAD_FINAL = "switch.upload_final";

    public static Map<String, String> definitions() {
        Map<String, String> defs = new LinkedHashMap<String, String>();
        defs.put(TOPIC_SUBMIT, "教师出题开关");
        defs.put(SELECTION, "学生选题开关");
        defs.put(UPLOAD_PROPOSAL, "开题报告上传开关");
        defs.put(UPLOAD_MIDTERM, "中期检查上传开关");
        defs.put(UPLOAD_FINAL, "终稿上传开关");
        return defs;
    }

    public static Map<String, Boolean> currentStates() {
        ensureDefaults();
        Map<String, Boolean> states = new LinkedHashMap<String, Boolean>();
        for (String key : definitions().keySet()) {
            states.put(key, isEnabled(key));
        }
        return states;
    }

    public static Map<String, String> currentRawStates() {
        ensureDefaults();
        Map<String, String> states = new LinkedHashMap<String, String>();
        for (String key : definitions().keySet()) {
            states.put(key, isEnabled(key) ? "1" : "0");
        }
        return states;
    }

    public static boolean isEnabled(String key) {
        if (SELECTION.equals(key)) {
            return SystemConfigUtil.isEnabled(SELECTION, SystemConfigUtil.isEnabled(SELECTION_ROUND1, true));
        }
        return SystemConfigUtil.isEnabled(key, true);
    }

    public static String uploadKey(String docType) {
        if ("proposal".equals(docType)) return UPLOAD_PROPOSAL;
        if ("midterm".equals(docType)) return UPLOAD_MIDTERM;
        if ("final".equals(docType)) return UPLOAD_FINAL;
        return UPLOAD_PROPOSAL;
    }

    public static int update(String key, boolean enabled) {
        String value = enabled ? "1" : "0";
        if (SELECTION.equals(key)) {
            int changed = SystemConfigUtil.update(SELECTION, value);
            int legacyChanged = SystemConfigUtil.update(SELECTION_ROUND1, value);
            return changed + legacyChanged;
        }
        return SystemConfigUtil.update(key, value);
    }

    public static void ensureDefaults() {
        for (Map.Entry<String, String> e : definitions().entrySet()) {
            String defaultValue = SELECTION.equals(e.getKey())
                ? (SystemConfigUtil.isEnabled(SELECTION_ROUND1, true) ? "1" : "0")
                : "1";
            SystemConfigUtil.insertDefault(e.getKey(), defaultValue, e.getValue());
        }
        SystemConfigUtil.insertDefault(SELECTION_ROUND1, "1", "第一轮选题开关，兼容旧配置");
    }
}
