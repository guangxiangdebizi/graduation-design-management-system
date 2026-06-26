package dao;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import util.SQLHelper;
import util.DictionaryUtil;

public class StatsDao {
    public Map<String, Integer> selectionStats(int totalStudents) {
        return selectionStats(totalStudents, null, null);
    }

    public int approvedSelectionCount(String college, String major) {
        boolean scoped = hasScope(college, major);
        Object val = scoped
            ? SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT x.student_id) FROM ("
                + "SELECT student_id,topic_id FROM topic_assignments "
                + "UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
                + ") x "
                + "JOIN topics t ON x.topic_id=t.id "
                + "JOIN users u ON x.student_id=u.id "
                + "WHERE 1=1 "
                + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
                college, major, college, major)
            : SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT student_id) FROM ("
                + "SELECT student_id FROM topic_assignments "
                + "UNION SELECT student_id FROM topic_selections WHERE status='approved'"
                + ") x");
        return val == null ? 0 : ((Number) val).intValue();
    }

    public Map<String, Integer> selectionStats(int totalStudents, String college, String major) {
        Map<String, Integer> stats = new LinkedHashMap<String, Integer>();
        boolean scoped = hasScope(college, major);
        Object pending = scoped
            ? SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT s.student_id) FROM topic_selections s "
                + "JOIN topics t ON s.topic_id=t.id "
                + "JOIN users u ON s.student_id=u.id "
                + "WHERE s.status='pending' "
                + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
                college, major, college, major)
            : SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT student_id) FROM topic_selections WHERE status='pending'");
        int approvedCount = approvedSelectionCount(college, major);
        int pendingCount = pending == null ? 0 : ((Number) pending).intValue();
        stats.put("已选题", approvedCount);
        stats.put("待审批", pendingCount);
        stats.put("未选题", Math.max(0, totalStudents - approvedCount - pendingCount));
        return stats;
    }

    public Map<String, Integer> docPassStats() {
        return docPassStats(null, null);
    }

    public Map<String, Integer> docPassStats(String college, String major) {
        Map<String, Integer> stats = new LinkedHashMap<String, Integer>();
        for (Map.Entry<String, String> e : DictionaryUtil.items("document_type").entrySet()) {
            stats.put(e.getValue(), countReviewed(e.getKey(), college, major));
        }
        return stats;
    }

    public Map<String, Integer> defenseStats(int approvedStudents) {
        return defenseStats(approvedStudents, null, null);
    }

    public Map<String, Integer> defenseStats(int approvedStudents, String college, String major) {
        Map<String, Integer> stats = new LinkedHashMap<String, Integer>();
        boolean scoped = hasScope(college, major);
        Object scored = scoped
            ? SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT d.student_id) FROM defense_schedules d "
                + "JOIN users u ON d.student_id=u.id "
                + "JOIN ("
                + "  SELECT student_id,topic_id FROM topic_assignments "
                + "  UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
                + ") x ON x.student_id=u.id "
                + "JOIN topics t ON x.topic_id=t.id "
                + "WHERE d.score IS NOT NULL "
                + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
                college, major, college, major)
            : SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT d.student_id) "
                + "FROM defense_schedules d "
                + "JOIN ("
                + "  SELECT student_id FROM topic_assignments "
                + "  UNION SELECT student_id FROM topic_selections WHERE status='approved'"
                + ") x ON x.student_id=d.student_id "
                + "WHERE d.score IS NOT NULL");
        Object pending = scoped
            ? SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT d.student_id) FROM defense_schedules d "
                + "JOIN users u ON d.student_id=u.id "
                + "JOIN ("
                + "  SELECT student_id,topic_id FROM topic_assignments "
                + "  UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
                + ") x ON x.student_id=u.id "
                + "JOIN topics t ON x.topic_id=t.id "
                + "WHERE d.score IS NULL "
                + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
                college, major, college, major)
            : SQLHelper.queryScalar(
                "SELECT COUNT(DISTINCT d.student_id) "
                + "FROM defense_schedules d "
                + "JOIN ("
                + "  SELECT student_id FROM topic_assignments "
                + "  UNION SELECT student_id FROM topic_selections WHERE status='approved'"
                + ") x ON x.student_id=d.student_id "
                + "WHERE d.score IS NULL");
        int scoredCount = scored == null ? 0 : ((Number) scored).intValue();
        int pendingCount = pending == null ? 0 : ((Number) pending).intValue();
        stats.put("已评分", scoredCount);
        stats.put("待评分", pendingCount);
        stats.put("未安排", Math.max(0, approvedStudents - scoredCount - pendingCount));
        return stats;
    }

    public List<Object[]> scoreDistribution() {
        return scoreDistribution(null, null);
    }

    public List<Object[]> scoreDistribution(String college, String major) {
        boolean scoped = hasScope(college, major);
        String sql =
            "SELECT CASE "
            + "WHEN score>=90 THEN '90-100' "
            + "WHEN score>=80 THEN '80-89' "
            + "WHEN score>=70 THEN '70-79' "
            + "WHEN score>=60 THEN '60-69' "
            + "ELSE '60以下' END AS grade_range, COUNT(*) "
            + "FROM documents d ";
        if (scoped) {
            sql += "JOIN topics t ON d.topic_id=t.id "
                + "JOIN users u ON d.student_id=u.id ";
        }
        sql += "WHERE d.doc_type='final' AND d.status='reviewed' AND d.score IS NOT NULL ";
        if (scoped) {
            sql += "AND t.college=? AND t.major=? AND u.college=? AND u.major=? ";
        }
        sql += "GROUP BY grade_range "
            + "ORDER BY FIELD(grade_range,'90-100','80-89','70-79','60-69','60以下')";
        List<Object[]> rows = scoped
            ? SQLHelper.queryList(sql, college, major, college, major)
            : SQLHelper.queryList(sql);
        return rows == null ? new ArrayList<Object[]>() : rows;
    }

    private int countReviewed(String docType) {
        return countReviewed(docType, null, null);
    }

    private int countReviewed(String docType, String college, String major) {
        boolean scoped = hasScope(college, major);
        Object val = scoped
            ? SQLHelper.queryScalar(
                "SELECT COUNT(*) FROM documents d "
                + "JOIN topics t ON d.topic_id=t.id "
                + "JOIN users u ON d.student_id=u.id "
                + "WHERE d.doc_type=? AND d.status='reviewed' "
                + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
                docType, college, major, college, major)
            : SQLHelper.queryScalar(
                "SELECT COUNT(*) FROM documents WHERE doc_type=? AND status='reviewed'", docType);
        return val == null ? 0 : ((Number) val).intValue();
    }

    private boolean hasScope(String college, String major) {
        return college != null && !college.trim().isEmpty()
            && major != null && !major.trim().isEmpty();
    }
}
