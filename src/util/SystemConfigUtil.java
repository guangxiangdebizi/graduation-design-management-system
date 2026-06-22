package util;

import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;
import dbutil.SQLHelper;

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
}
