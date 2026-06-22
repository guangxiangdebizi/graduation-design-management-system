package util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 学院/专业/班级 层级配置
 */
public class CollegeUtil {

    // 专业对应的班级后缀
    public static String getClassSuffix(String college, String major) {
        return college + "_" + major;
    }

    public static Map<String, String> getColleges() {
        Map<String, String> map = new LinkedHashMap<String, String>();
        java.util.List<Object[]> rows = dbutil.SQLHelper.queryList(
            "SELECT code,name FROM colleges WHERE status=1 ORDER BY sort_order,code");
        for (Object[] row : rows) {
            map.put((String) row[0], (String) row[1]);
        }
        return map;
    }

    public static Map<String, Map<String, String>> getMajorGroups() {
        Map<String, Map<String, String>> groups = new LinkedHashMap<String, Map<String, String>>();
        for (String collegeCode : getColleges().keySet()) {
            groups.put(collegeCode, getMajorsByCollege(collegeCode));
        }
        return groups;
    }

    // 根据学院代码获取学院名称
    public static String getCollegeName(String code) {
        if (code == null || code.trim().isEmpty()) {
            return "";
        }
        Object val = dbutil.SQLHelper.queryScalar(
            "SELECT name FROM colleges WHERE code=? AND status=1", code);
        return val == null ? code : String.valueOf(val);
    }

    // 根据学院和专业代码获取专业名称
    public static String getMajorName(String collegeCode, String majorCode) {
        Map<String, String> majors = getMajorsByCollege(collegeCode);
        if (majors != null) {
            return majors.getOrDefault(majorCode, majorCode);
        }
        return majorCode;
    }

    // 获取某学院的专业列表
    public static Map<String, String> getMajorsByCollege(String collegeCode) {
        Map<String, String> map = new LinkedHashMap<String, String>();
        if (collegeCode == null || collegeCode.trim().isEmpty()) {
            return map;
        }
        java.util.List<Object[]> rows = dbutil.SQLHelper.queryList(
            "SELECT major_code,major_name FROM majors "
            + "WHERE college_code=? AND status=1 ORDER BY sort_order,id",
            collegeCode);
        for (Object[] row : rows) {
            map.put((String) row[0], (String) row[1]);
        }
        return map;
    }

    // 生成班级选项（基于年级）
    public static String generateClassOptions(String college, String major, String selectedClass, int grade) {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 4; i++) {
            String className = major + grade + "级" + i + "班";
            String selected = className.equals(selectedClass) ? "selected" : "";
            sb.append("<option value=\"").append(className).append("\" ").append(selected).append(">").append(className).append("</option>");
        }
        return sb.toString();
    }
}
