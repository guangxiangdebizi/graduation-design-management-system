package dao;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import dbutil.SQLHelper;

public class StatsDao {
    public Map<String, Integer> selectionStats(int totalStudents) {
        Map<String, Integer> stats = new LinkedHashMap<String, Integer>();
        Object approved = SQLHelper.queryScalar(
            "SELECT COUNT(DISTINCT student_id) FROM topic_selections WHERE status='approved'");
        Object pending = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections WHERE status='pending'");
        int approvedCount = approved == null ? 0 : ((Number) approved).intValue();
        int pendingCount = pending == null ? 0 : ((Number) pending).intValue();
        stats.put("已选题", approvedCount);
        stats.put("待审批", pendingCount);
        stats.put("未选题", Math.max(0, totalStudents - approvedCount - pendingCount));
        return stats;
    }

    public Map<String, Integer> docPassStats() {
        Map<String, Integer> stats = new LinkedHashMap<String, Integer>();
        stats.put("开题报告", countReviewed("proposal"));
        stats.put("中期检查", countReviewed("midterm"));
        stats.put("终稿", countReviewed("final"));
        return stats;
    }

    public List<Object[]> scoreDistribution() {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT CASE "
            + "WHEN score>=90 THEN '90-100' "
            + "WHEN score>=80 THEN '80-89' "
            + "WHEN score>=70 THEN '70-79' "
            + "WHEN score>=60 THEN '60-69' "
            + "ELSE '60以下' END AS grade_range, COUNT(*) "
            + "FROM documents WHERE score IS NOT NULL GROUP BY grade_range "
            + "ORDER BY FIELD(grade_range,'90-100','80-89','70-79','60-69','60以下')");
        return rows == null ? new ArrayList<Object[]>() : rows;
    }

    private int countReviewed(String docType) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents WHERE doc_type=? AND status='reviewed'", docType);
        return val == null ? 0 : ((Number) val).intValue();
    }
}
