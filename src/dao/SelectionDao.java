package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import bean.TopicSelection;
import bean.User;
import dbutil.SQLHelper;
import util.DateUtil;
import util.PageUtil;
import util.SystemSwitchUtil;

public class SelectionDao {
    private static final String SELECT_SQL =
        "SELECT s.id,s.student_id,s.topic_id,u.real_name,u.student_no,t.title,ut.real_name,s.status,"
        + "s.apply_reason,s.review_comment,s.apply_time,s.review_time "
        + "FROM topic_selections s "
        + "JOIN users u ON s.student_id=u.id "
        + "JOIN topics t ON s.topic_id=t.id "
        + "JOIN users ut ON t.teacher_id=ut.id ";

    public List<TopicSelection> findByTeacher(int teacherId, String status) {
        String sql = SELECT_SQL + "WHERE t.teacher_id=?";
        List<Object[]> rows;
        if (status != null && status.length() > 0) {
            sql += " AND s.status=? ORDER BY s.apply_time DESC";
            rows = SQLHelper.queryList(sql, teacherId, status);
        } else {
            sql += " ORDER BY s.apply_time DESC";
            rows = SQLHelper.queryList(sql, teacherId);
        }
        return mapList(rows);
    }

    public List<TopicSelection> findByDirectorScope(String college, String major, String status) {
        String sql = SELECT_SQL
            + "WHERE t.college=? AND t.major=? AND u.college=? AND u.major=?";
        List<Object[]> rows;
        if (status != null && status.length() > 0) {
            sql += " AND s.status=? ORDER BY s.apply_time DESC";
            rows = SQLHelper.queryList(sql, college, major, college, major, status);
        } else {
            sql += " ORDER BY s.apply_time DESC";
            rows = SQLHelper.queryList(sql, college, major, college, major);
        }
        return mapList(rows);
    }

    public List<TopicSelection> findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE s.student_id=? ORDER BY s.apply_time DESC", studentId);
        return mapList(rows);
    }

    public List<TopicSelection> findApprovedStudents(int page, int pageSize) {
        int offset = PageUtil.offset(page, pageSize);
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE s.status='approved' ORDER BY s.apply_time DESC LIMIT ? OFFSET ?",
            pageSize, offset);
        return mapList(rows);
    }

    public TopicSelection findApprovedByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE s.student_id=? AND s.status='approved' LIMIT 1", studentId);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public TopicSelection findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(SELECT_SQL + "WHERE s.id=?", id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public boolean hasPendingOrApproved(int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections WHERE student_id=? AND status IN ('pending','approved')",
            studentId);
        return val != null && ((Number) val).intValue() > 0;
    }

    public int apply(int studentId, int topicId, String reason) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            // Serialize all applications for one student.
            String studentCollege;
            String studentMajor;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role,status,college,major FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"student".equals(rs.getString(1)) || rs.getInt(2) != 1) {
                        conn.rollback();
                        return 0;
                    }
                    studentCollege = rs.getString(3);
                    studentMajor = rs.getString(4);
                }
            }

            if (!SystemSwitchUtil.isEnabled(SystemSwitchUtil.SELECTION)) {
                conn.rollback();
                return -3;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM topic_selections "
                    + "WHERE student_id=? AND status IN ('pending','approved') LIMIT 1")) {
                ps.setInt(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT status,max_students,selected_count,college,major FROM topics WHERE id=? FOR UPDATE")) {
                ps.setInt(1, topicId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"open".equals(rs.getString(1))
                            || rs.getInt(3) >= rs.getInt(2)) {
                        conn.rollback();
                        return -2;
                    }
                    String topicCollege = rs.getString(4);
                    String topicMajor = rs.getString(5);
                    if (!same(studentCollege, topicCollege) || !same(studentMajor, topicMajor)) {
                        conn.rollback();
                        return -4;
                    }
                }
            }

            int id;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO topic_selections(student_id,topic_id,status,apply_reason) "
                    + "VALUES(?,?,'pending',?)", Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, studentId);
                ps.setInt(2, topicId);
                ps.setString(3, reason);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    id = rs.next() ? rs.getInt(1) : 0;
                }
            }
            conn.commit();
            return id;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int review(int id, int teacherId, String status, String comment) {
        if (!"approved".equals(status) && !"rejected".equals(status)) {
            return 0;
        }
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            String currentStatus;
            String reviewComment;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT s.status,s.review_comment "
                    + "FROM topic_selections s JOIN topics t ON s.topic_id=t.id "
                    + "WHERE s.id=? AND t.teacher_id=? FOR UPDATE")) {
                ps.setInt(1, id);
                ps.setInt(2, teacherId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                    currentStatus = rs.getString(1);
                    reviewComment = rs.getString(2);
                }
            }
            if (!"pending".equals(currentStatus)) {
                conn.rollback();
                return 0;
            }

            int updated;
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE topic_selections SET review_comment=?,review_time=NOW() "
                    + "WHERE id=? AND status='pending'")) {
                ps.setString(1, appendReviewComment(reviewComment,
                    "approved".equals(status) ? "指导教师建议通过" : "指导教师建议退回", comment));
                ps.setInt(2, id);
                updated = ps.executeUpdate();
            }
            if (updated != 1) {
                conn.rollback();
                return 0;
            }

            conn.commit();
            return 1;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int countPendingByTeacher(int teacherId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections s JOIN topics t ON s.topic_id=t.id "
            + "WHERE t.teacher_id=? AND s.status='pending'",
            teacherId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countApprovedStudents() {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections WHERE status='approved'");
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countApprovedStudents(String college, String major) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections s "
            + "JOIN topics t ON s.topic_id=t.id "
            + "JOIN users u ON s.student_id=u.id "
            + "WHERE s.status='approved' "
            + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
            college, major, college, major);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countPendingByDirector(String college, String major) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_selections s "
            + "JOIN topics t ON s.topic_id=t.id "
            + "JOIN users u ON s.student_id=u.id "
            + "WHERE s.status='pending' "
            + "AND t.college=? AND t.major=? AND u.college=? AND u.major=?",
            college, major, college, major);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public List<User> findUnselectedStudents(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT u.id,u.username,u.real_name,u.student_no,u.college,u.major,u.class_name "
            + "FROM users u "
            + "WHERE u.role='student' AND u.status=1 AND u.college=? AND u.major=? "
            + "AND NOT EXISTS ("
            + "  SELECT 1 FROM topic_selections s "
            + "  WHERE s.student_id=u.id AND s.status IN ('pending','approved')"
            + ") "
            + "ORDER BY u.student_no,u.id",
            college, major);
        List<User> list = new ArrayList<User>();
        for (Object[] row : rows) {
            User u = new User();
            u.setId(((Number) row[0]).intValue());
            u.setUsername((String) row[1]);
            u.setRealName((String) row[2]);
            u.setStudentNo((String) row[3]);
            u.setCollege((String) row[4]);
            u.setMajor((String) row[5]);
            u.setClassName((String) row[6]);
            list.add(u);
        }
        return list;
    }

    public int confirmByDirector(int id, String college, String major, String comment) {
        return reviewInDirectorScope(id, college, major, "approved", comment);
    }

    public int rejectByDirector(int id, String college, String major, String comment) {
        return reviewInDirectorScope(id, college, major, "rejected", comment);
    }

    public int manualAssign(int studentId, int topicId, String college, String major, String comment) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users "
                    + "WHERE id=? AND role='student' AND status=1 AND college=? AND major=? "
                    + "FOR UPDATE")) {
                ps.setInt(1, studentId);
                ps.setString(2, college);
                ps.setString(3, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                }
            }

            if (hasActiveSelection(conn, studentId, 0)) {
                conn.rollback();
                return -2;
            }

            int maxStudents;
            int selectedCount;
            String topicStatus;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT status,max_students,selected_count FROM topics "
                    + "WHERE id=? AND college=? AND major=? FOR UPDATE")) {
                ps.setInt(1, topicId);
                ps.setString(2, college);
                ps.setString(3, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                    topicStatus = rs.getString(1);
                    maxStudents = rs.getInt(2);
                    selectedCount = rs.getInt(3);
                }
            }
            if (!"open".equals(topicStatus) || selectedCount >= maxStudents) {
                conn.rollback();
                return -1;
            }

            int inserted;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO topic_selections(student_id,topic_id,status,apply_reason,review_comment,review_time) "
                    + "VALUES(?,?,'approved','系主任手动分配',?,NOW())")) {
                ps.setInt(1, studentId);
                ps.setInt(2, topicId);
                ps.setString(3, appendReviewComment(null, "系主任分配", comment));
                inserted = ps.executeUpdate();
            }
            if (inserted != 1) {
                conn.rollback();
                return 0;
            }
            incrementTopicSelected(conn, topicId);
            conn.commit();
            return 1;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    private List<TopicSelection> mapList(List<Object[]> rows) {
        List<TopicSelection> list = new ArrayList<TopicSelection>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private TopicSelection mapRow(Object[] row) {
        TopicSelection s = new TopicSelection();
        s.setId(((Number) row[0]).intValue());
        s.setStudentId(((Number) row[1]).intValue());
        s.setTopicId(((Number) row[2]).intValue());
        s.setStudentName((String) row[3]);
        s.setStudentNo((String) row[4]);
        s.setTopicTitle((String) row[5]);
        s.setTeacherName((String) row[6]);
        s.setStatus((String) row[7]);
        s.setApplyReason((String) row[8]);
        s.setReviewComment((String) row[9]);
        s.setApplyTime(DateUtil.toDate(row[10]));
        s.setReviewTime(DateUtil.toDate(row[11]));
        return s;
    }

    private int reviewInDirectorScope(int id, String college, String major, String status, String comment) {
        if (!"approved".equals(status) && !"rejected".equals(status)) {
            return 0;
        }
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            int studentId;
            int topicId;
            String currentStatus;
            String reviewComment;
            int maxStudents;
            int selectedCount;
            String topicStatus;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT s.student_id,s.topic_id,s.status,s.review_comment,"
                    + "t.status,t.max_students,t.selected_count "
                    + "FROM topic_selections s "
                    + "JOIN topics t ON s.topic_id=t.id "
                    + "JOIN users u ON s.student_id=u.id "
                    + "WHERE s.id=? "
                    + "AND t.college=? AND t.major=? AND u.college=? AND u.major=? "
                    + "FOR UPDATE")) {
                ps.setInt(1, id);
                ps.setString(2, college);
                ps.setString(3, major);
                ps.setString(4, college);
                ps.setString(5, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                    studentId = rs.getInt(1);
                    topicId = rs.getInt(2);
                    currentStatus = rs.getString(3);
                    reviewComment = rs.getString(4);
                    topicStatus = rs.getString(5);
                    maxStudents = rs.getInt(6);
                    selectedCount = rs.getInt(7);
                }
            }
            if (!"pending".equals(currentStatus)) {
                conn.rollback();
                return 0;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, studentId);
                ps.executeQuery().close();
            }

            if ("approved".equals(status)) {
                if (!"open".equals(topicStatus) || selectedCount >= maxStudents) {
                    conn.rollback();
                    return -1;
                }
                if (hasActiveSelection(conn, studentId, id)) {
                    conn.rollback();
                    return -2;
                }
            }

            int updated;
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE topic_selections SET status=?,review_comment=?,review_time=NOW() "
                    + "WHERE id=? AND status='pending'")) {
                ps.setString(1, status);
                ps.setString(2, appendReviewComment(reviewComment, "系主任意见", comment));
                ps.setInt(3, id);
                updated = ps.executeUpdate();
            }
            if (updated != 1) {
                conn.rollback();
                return 0;
            }
            if ("approved".equals(status)) {
                incrementTopicSelected(conn, topicId);
            }
            conn.commit();
            return 1;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    private boolean hasActiveSelection(Connection conn, int studentId, int excludedSelectionId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM topic_selections "
                + "WHERE student_id=? AND status IN ('pending','approved') AND id<>? LIMIT 1")) {
            ps.setInt(1, studentId);
            ps.setInt(2, excludedSelectionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void incrementTopicSelected(Connection conn, int topicId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE topics SET selected_count=selected_count+1,"
                + "status=CASE WHEN selected_count+1>=max_students THEN 'closed' ELSE status END "
                + "WHERE id=?")) {
            ps.setInt(1, topicId);
            ps.executeUpdate();
        }
    }

    private String appendReviewComment(String existing, String label, String comment) {
        String clean = comment == null ? "" : comment.trim();
        String line = label + "：" + (clean.isEmpty() ? "无补充意见" : clean);
        if (existing == null || existing.trim().isEmpty()) {
            return line;
        }
        return existing.trim() + "\n" + line;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception ignored) {
            }
        }
    }

    private boolean same(String left, String right) {
        if (left == null || right == null) {
            return left == right;
        }
        return left.equals(right);
    }
}
