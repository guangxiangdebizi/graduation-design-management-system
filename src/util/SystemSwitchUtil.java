package util;

import java.util.LinkedHashMap;
import java.util.Map;

public class SystemSwitchUtil {
    public static final String TOPIC_SUBMIT = "switch.topic_submit";
    public static final String SELECTION = "switch.selection";
    public static final String SELECTION_ROUND1 = "switch.selection_round1";
    public static final String SELECTION_ROUND2 = "switch.selection_round2";
    public static final String MANUAL_ASSIGN = "switch.manual_assign";
    public static final String CURRENT_ROUND = "selection.current_round";
    public static final String UPLOAD_PROPOSAL = "switch.upload_proposal";
    public static final String UPLOAD_MIDTERM = "switch.upload_midterm";
    public static final String UPLOAD_FINAL = "switch.upload_final";

    public static Map<String, String> definitions() {
        Map<String, String> defs = new LinkedHashMap<String, String>();
        defs.put(TOPIC_SUBMIT, "教师出题开关");
        defs.put(SELECTION, "第一轮学生选题开放");
        defs.put(SELECTION_ROUND2, "第二轮学生选题开放");
        defs.put(MANUAL_ASSIGN, "强制分配阶段开放");
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
            return isFirstRoundOpen();
        }
        if (SELECTION_ROUND2.equals(key)) {
            return isSecondRoundOpen();
        }
        if (MANUAL_ASSIGN.equals(key)) {
            return isManualAssignOpen();
        }
        return SystemConfigUtil.isEnabled(key, true);
    }

    public static boolean isFirstRoundOpen() {
        return SystemConfigUtil.isEnabled(SELECTION, SystemConfigUtil.isEnabled(SELECTION_ROUND1, true));
    }

    public static boolean isSecondRoundOpen() {
        return SystemConfigUtil.isEnabled(SELECTION_ROUND2, false);
    }

    public static boolean isSelectionOpen() {
        return isSelectionOpenForRound(currentRound());
    }

    public static boolean isSelectionOpenForRound(int round) {
        return round >= 2 ? isSecondRoundOpen() : isFirstRoundOpen();
    }

    public static boolean isManualAssignOpen() {
        return SystemConfigUtil.isEnabled(MANUAL_ASSIGN, false);
    }

    public static String uploadKey(String docType) {
        if ("proposal".equals(docType)) return UPLOAD_PROPOSAL;
        if ("midterm".equals(docType)) return UPLOAD_MIDTERM;
        if ("final".equals(docType)) return UPLOAD_FINAL;
        return UPLOAD_PROPOSAL;
    }

    public static int currentRound() {
        if (isSecondRoundOpen() || isManualAssignOpen()) {
            return 2;
        }
        return 1;
    }

    public static int update(String key, boolean enabled) {
        ensureDefaults();
        String value = enabled ? "1" : "0";
        if (SELECTION.equals(key)) {
            int changed = SystemConfigUtil.update(SELECTION, value);
            int legacyChanged = SystemConfigUtil.update(SELECTION_ROUND1, value);
            if (enabled) {
                SystemConfigUtil.update(SELECTION_ROUND2, "0");
                SystemConfigUtil.update(MANUAL_ASSIGN, "0");
                SystemConfigUtil.update(CURRENT_ROUND, "1");
            } else if (!isSecondRoundOpen()) {
                SystemConfigUtil.update(CURRENT_ROUND, "1");
            }
            return changed + legacyChanged;
        }
        if (SELECTION_ROUND2.equals(key)) {
            int changed = SystemConfigUtil.update(SELECTION_ROUND2, value);
            if (enabled) {
                SystemConfigUtil.update(SELECTION, "0");
                SystemConfigUtil.update(SELECTION_ROUND1, "0");
                SystemConfigUtil.update(MANUAL_ASSIGN, "0");
                SystemConfigUtil.update(CURRENT_ROUND, "2");
            } else {
                SystemConfigUtil.update(CURRENT_ROUND, "1");
            }
            return changed;
        }
        if (MANUAL_ASSIGN.equals(key)) {
            int changed = SystemConfigUtil.update(MANUAL_ASSIGN, value);
            if (enabled) {
                SystemConfigUtil.update(SELECTION, "0");
                SystemConfigUtil.update(SELECTION_ROUND1, "0");
                SystemConfigUtil.update(SELECTION_ROUND2, "0");
                SystemConfigUtil.update(CURRENT_ROUND, "2");
            }
            return changed;
        }
        return SystemConfigUtil.update(key, value);
    }

    public static void ensureDefaults() {
        for (Map.Entry<String, String> e : definitions().entrySet()) {
            String key = e.getKey();
            String defaultValue;
            if (SELECTION.equals(key)) {
                defaultValue = SystemConfigUtil.isEnabled(SELECTION_ROUND1, true) ? "1" : "0";
            } else if (SELECTION_ROUND2.equals(key)) {
                defaultValue = "0";
            } else if (MANUAL_ASSIGN.equals(key)) {
                defaultValue = "0";
            } else {
                defaultValue = "1";
            }
            SystemConfigUtil.insertDefault(key, defaultValue, e.getValue());
        }
        SystemConfigUtil.insertDefault(SELECTION_ROUND1, "1", "第一轮学生选题开关，兼容旧配置");
        SystemConfigUtil.insertDefault(CURRENT_ROUND, "1", "当前选题轮次，第二轮开启后为 2");
    }
}
