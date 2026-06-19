package util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 学院/专业/班级 层级配置
 */
public class CollegeUtil {

    // 学院列表
    public static final Map<String, String> COLLEGES = new LinkedHashMap<>();
    static {
        COLLEGES.put("cs", "计算机学院");
        COLLEGES.put("sw", "软件学院");
        COLLEGES.put("ee", "电气学院");
        COLLEGES.put("ai", "人工智能学部");
        COLLEGES.put("ba", "经管学院");
        COLLEGES.put("arts", "文科学部");
        COLLEGES.put("science", "理学部");
    }

    // 各学院的专业列表
    public static final Map<String, Map<String, String>> MAJORS = new LinkedHashMap<>();
    static {
        // 计算机学院
        Map<String, String> csMajors = new LinkedHashMap<>();
        csMajors.put("cs", "计算机科学与技术");
        csMajors.put("cy", "软件工程");
        csMajors.put("is", "信息安全");
        csMajors.put("ai", "人工智能");
        MAJORS.put("cs", csMajors);

        // 软件学院
        Map<String, String> swMajors = new LinkedHashMap<>();
        swMajors.put("sw", "软件工程");
        swMajors.put("bigdata", "数据科学与大数据技术");
        MAJORS.put("sw", swMajors);

        // 电气学院
        Map<String, String> eeMajors = new LinkedHashMap<>();
        eeMajors.put("ee", "电气工程及其自动化");
        eeMajors.put("auto", "自动化");
        eeMajors.put("eie", "电子信息工程");
        MAJORS.put("ee", eeMajors);

        // 人工智能学部
        Map<String, String> aiMajors = new LinkedHashMap<>();
        aiMajors.put("ai", "人工智能");
        aiMajors.put("robot", "机器人工程");
        MAJORS.put("ai", aiMajors);

        // 经管学院
        Map<String, String> baMajors = new LinkedHashMap<>();
        baMajors.put("ba", "工商管理");
        baMajors.put("acc", "会计学");
        baMajors.put("ec", "电子商务");
        MAJORS.put("ba", baMajors);

        // 文科学部
        Map<String, String> artsMajors = new LinkedHashMap<>();
        artsMajors.put("chinese", "汉语言文学");
        artsMajors.put("eng", "英语");
        artsMajors.put("law", "法学");
        MAJORS.put("arts", artsMajors);

        // 理学部
        Map<String, String> scienceMajors = new LinkedHashMap<>();
        scienceMajors.put("math", "数学与应用数学");
        scienceMajors.put("phys", "物理学");
        MAJORS.put("science", scienceMajors);
    }

    // 专业对应的班级后缀
    public static String getClassSuffix(String college, String major) {
        return college + "_" + major;
    }

    // 根据学院代码获取学院名称
    public static String getCollegeName(String code) {
        return COLLEGES.getOrDefault(code, code);
    }

    // 根据学院和专业代码获取专业名称
    public static String getMajorName(String collegeCode, String majorCode) {
        Map<String, String> majors = MAJORS.get(collegeCode);
        if (majors != null) {
            return majors.getOrDefault(majorCode, majorCode);
        }
        return majorCode;
    }

    // 获取某学院的专业列表
    public static Map<String, String> getMajorsByCollege(String collegeCode) {
        return MAJORS.getOrDefault(collegeCode, new LinkedHashMap<>());
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