package util;

import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;
import util.SQLHelper;

public class SystemConfigUtil {
    public static String getString(String key, String defaultValue) {
        if (key == null || key.trim().isEmpty()) {
            return defaultValue;
        }
        Object val = SQLHelper.queryScalar(
            "SELECT config_value FROM system_configs WHERE config_key=?", key);
        return val == null ? defaultValue : String.valueOf(val);
    }

    public static int getInt(String key, int defaultValue) {
        String value = getString(key, String.valueOf(defaultValue));
        try {
            return Integer.parseInt(value.trim());
        } catch (Exception ex) {
            return defaultValue;
        }
    }

    public static long getLong(String key, long defaultValue) {
        String value = getString(key, String.valueOf(defaultValue));
        try {
            return Long.parseLong(value.trim());
        } catch (Exception ex) {
            return defaultValue;
        }
    }

    public static Set<String> getCsvSet(String key, String defaultCsv) {
        String value = getString(key, defaultCsv);
        Set<String> set = new LinkedHashSet<String>();
        for (String item : Arrays.asList(value.split(","))) {
            String text = item.trim().toLowerCase();
            if (!text.isEmpty()) {
                set.add(text);
            }
        }
        return set;
    }

    public static boolean isEnabled(String key) {
        String value = getString(key, "0");
        return isTruthy(value);
    }

    public static boolean isEnabled(String key, boolean defaultValue) {
        String value = getString(key, defaultValue ? "1" : "0");
        return isTruthy(value);
    }

    private static boolean isTruthy(String value) {
        return "1".equals(value) || "true".equalsIgnoreCase(value)
            || "on".equalsIgnoreCase(value) || "yes".equalsIgnoreCase(value);
    }

    public static int update(String key, String value) {
        return SQLHelper.executeUpdate(
            "UPDATE system_configs SET config_value=? WHERE config_key=?", value, key);
    }

    public static int upsert(String key, String value, String description) {
        return SQLHelper.executeUpdate(
            "INSERT INTO system_configs(config_key,config_value,description) VALUES(?,?,?) "
            + "ON DUPLICATE KEY UPDATE config_value=VALUES(config_value),description=VALUES(description)",
            key, value, description);
    }

    public static int insertDefault(String key, String value, String description) {
        return SQLHelper.executeUpdate(
            "INSERT INTO system_configs(config_key,config_value,description) VALUES(?,?,?) "
            + "ON DUPLICATE KEY UPDATE description=VALUES(description)",
            key, value, description);
    }
}
