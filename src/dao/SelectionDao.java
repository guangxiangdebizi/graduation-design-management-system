package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import bean.TopicSelection;
import dbutil.SQLHelper;
import util.DateUtil;
import util.PageUtil;

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
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role,status FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"student".equals(rs.getString(1)) || rs.getInt(2) != 1) {
                        conn.rollback();
                        return 0;
                    }
                }
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
                    "SELECT status,max_students,selected_count FROM topics WHERE id=? FOR UPDATE")) {
                ps.setInt(1, topicId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"open".equals(rs.getString(1))
                            || rs.getInt(3) >= rs.getInt(2)) {
                        conn.rollback();
                        return -2;
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

            int studentId;
            int topicId;
            String currentStatus;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT s.student_id,s.topic_id,s.status "
                    + "FROM topic_selections s JOIN topics t ON s.topic_id=t.id "
                    + "WHERE s.id=? AND t.teacher_id=? FOR UPDATE")) {
                ps.setInt(1, id);
                ps.setInt(2, teacherId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                    studentId = rs.getInt(1);
                    topicId = rs.getInt(2);
                    currentStatus = rs.getString(3);
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

            int maxStudents;
            int selectedCount;
            String topicStatus;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT max_students,selected_count,status FROM topics WHERE id=? FOR UPDATE")) {
                ps.setInt(1, topicId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                    maxStudents = rs.getInt(1);
                    selectedCount = rs.getInt(2);
                    topicStatus = rs.getString(3);
                }
            }

            if ("approved".equals(status)) {
                if (!"open".equals(topicStatus)) {
                    conn.rollback();
                    return -1;
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM topic_selections "
                        + "WHERE student_id=? AND status='approved' AND id<>? LIMIT 1")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            conn.rollback();
                            return -2;
                        }
                    }
                }
                if (selectedCount >= maxStudents) {
                    conn.rollback();
                    return -1;
                }
            }

            int updated;
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE topic_selections SET status=?,review_comment=?,review_time=NOW() "
                    + "WHERE id=? AND status='pending'")) {
                ps.setString(1, status);
                ps.setString(2, comment);
                ps.setInt(3, id);
                updated = ps.executeUpdate();
            }
            if (updated != 1) {
                conn.rollback();
                return 0;
            }

            if ("approved".equals(status)) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE topics SET selected_count=selected_count+1,"
                        + "status=CASE WHEN selected_count+1>=max_students THEN 'closed' ELSE status END "
                        + "WHERE id=?")) {
                    ps.setInt(1, topicId);
                    ps.executeUpdate();
                }
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
}
