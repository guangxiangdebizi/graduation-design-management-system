package util;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import util.SQLHelper;

public class DictionaryUtil {
    public static Map<String, String> items(String dictType) {
        Map<String, String> map = new LinkedHashMap<String, String>();
        if (dictType == null || dictType.trim().isEmpty()) {
            return map;
        }
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT item_code,item_label FROM dictionary_items "
            + "WHERE dict_type=? AND status=1 ORDER BY sort_order,id",
            dictType);
        for (Object[] row : rows) {
            map.put((String) row[0], (String) row[1]);
        }
        return map;
    }

    public static boolean contains(String dictType, String code) {
        if (dictType == null || code == null) {
            return false;
        }
        Object val = SQLHelper.queryScalar(
            "SELECT 1 FROM dictionary_items WHERE dict_type=? AND item_code=? AND status=1",
            dictType, code);
        return val != null;
    }

    public static String label(String dictType, String code) {
        if (code == null || code.trim().isEmpty()) {
            return "";
        }
        if (dictType != null && !dictType.trim().isEmpty()) {
            Object val = SQLHelper.queryScalar(
                "SELECT item_label FROM dictionary_items "
                + "WHERE dict_type=? AND item_code=? AND status=1",
                dictType, code);
            if (val != null) {
                return String.valueOf(val);
            }
        }
        return label(code);
    }

    public static String label(String code) {
        if (code == null || code.trim().isEmpty()) {
            return "";
        }
        Object val = SQLHelper.queryScalar(
            "SELECT item_label FROM dictionary_items "
            + "WHERE item_code=? AND status=1 ORDER BY sort_order,id LIMIT 1",
            code);
        return val == null ? code : String.valueOf(val);
    }
}
