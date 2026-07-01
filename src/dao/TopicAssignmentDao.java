package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import bean.Topic;
import bean.TopicAssignment;
import bean.TopicSelection;
import bean.User;
import util.CollegeUtil;
import util.DateUtil;
import util.SQLHelper;

public class TopicAssignmentDao {
    public static final int ERR_TOPIC_ASSIGNED = -1;
    public static final int ERR_STUDENT_ASSIGNED = -2;
    public static final int ERR_CHOICE_INVALID = -3;
    public static final int ERR_SCOPE = -4;

    private static final String SELECT_SQL =
        "SELECT a.id,a.student_id,s.real_name,s.student_no,a.topic_id,t.title,teacher.real_name,"
        + "a.choice_id,a.round,a.source,a.confirmed_by,conf.real_name,a.confirm_comment,a.confirm_time "
        + "FROM topic_assignments a "
        + "JOIN users s ON a.student_id=s.id "
        + "JOIN topics t ON a.topic_id=t.id "
        + "JOIN users teacher ON t.teacher_id=teacher.id "
        + "JOIN users conf ON a.confirmed_by=conf.id ";

    public TopicAssignment findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE a.student_id=? LIMIT 1", studentId);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public TopicAssignment findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE a.id=? LIMIT 1", id);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public TopicAssignment findByTopic(int topicId) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE a.topic_id=? LIMIT 1", topicId);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public List<TopicAssignment> findByDirectorScope(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL
            + "WHERE t.college=? AND t.major=? AND s.college=? AND s.major=? "
            + "ORDER BY a.confirm_time DESC",
            college, major, college, major);
        List<TopicAssignment> list = new ArrayList<TopicAssignment>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    public int countByDirectorScope(String college, String major) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topic_assignments a "
            + "JOIN topics t ON a.topic_id=t.id "
            + "JOIN users u ON a.student_id=u.id "
            + "WHERE t.college=? AND t.major=? AND u.college=? AND u.major=?",
            college, major, college, major);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public List<User> findUnassignedStudents(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT u.id,u.username,u.real_name,u.student_no,u.college,u.major,u.class_name "
            + "FROM users u "
            + "WHERE u.role='student' AND u.status=1 AND u.college=? AND u.major=? "
            + "AND NOT EXISTS (SELECT 1 FROM topic_assignments a WHERE a.student_id=u.id) "
            + "AND NOT EXISTS (SELECT 1 FROM topic_selections s "
            + "  WHERE s.student_id=u.id AND s.status='approved') "
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
            u.setCollegeName(CollegeUtil.getCollegeName(u.getCollege()));
            u.setMajorName(CollegeUtil.getMajorName(u.getCollege(), u.getMajor()));
            list.add(u);
        }
        return list;
    }

    public List<Topic> findAssignableTopics(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT t.id,t.title,t.description,t.teacher_id,u.real_name,t.college,t.major,"
            + "t.max_students,t.selected_count,t.status,t.created_at "
            + "FROM topics t JOIN users u ON t.teacher_id=u.id "
            + "WHERE t.status='open' AND t.college=? AND t.major=? "
            + "AND t.selected_count < t.max_students "
            + "ORDER BY t.created_at DESC",
            college, major);
        List<Topic> list = new ArrayList<Topic>();
        for (Object[] row : rows) {
            Topic t = new Topic();
            t.setId(((Number) row[0]).intValue());
            t.setTitle((String) row[1]);
            t.setDescription((String) row[2]);
            t.setTeacherId(((Number) row[3]).intValue());
            t.setTeacherName((String) row[4]);
            t.setCollege((String) row[5]);
            t.setMajor((String) row[6]);
            t.setMaxStudents(((Number) row[7]).intValue());
            t.setSelectedCount(((Number) row[8]).intValue());
            t.setStatus((String) row[9]);
            t.setCreatedAt(DateUtil.toDate(row[10]));
            t.setCollegeName(CollegeUtil.getCollegeName(t.getCollege()));
            t.setMajorName(CollegeUtil.getMajorName(t.getCollege(), t.getMajor()));
            list.add(t);
        }
        return list;
    }

    public int confirmChoice(int choiceId, int confirmerId, String college, String major,
            String comment) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            ChoiceSnapshot snapshot = lockChoice(conn, choiceId, college, major);
            if (snapshot == null) {
                conn.rollback();
                return ERR_SCOPE;
            }
            if (!"pending".equals(snapshot.choiceStatus)
                    || !"submitted".equals(snapshot.applicationStatus)
                    || !"open".equals(snapshot.topicStatus)) {
                conn.rollback();
                return ERR_CHOICE_INVALID;
            }
            if (snapshot.selectedCount >= snapshot.maxStudents) {
                conn.rollback();
                return ERR_TOPIC_ASSIGNED;
            }
            if (hasStudentAssignment(conn, snapshot.studentId)) {
                conn.rollback();
                return ERR_STUDENT_ASSIGNED;
            }
            if (hasLegacyApprovedStudent(conn, snapshot.studentId)) {
                conn.rollback();
                return ERR_STUDENT_ASSIGNED;
            }

            int assignmentId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,"
                    + "confirmed_by,confirm_comment) VALUES(?,?,?,?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, snapshot.studentId);
                ps.setInt(2, snapshot.topicId);
                ps.setInt(3, snapshot.choiceId);
                ps.setInt(4, snapshot.round);
                ps.setString(5, snapshot.round >= 2 ? "round2" : "round1");
                ps.setInt(6, confirmerId);
                ps.setString(7, normalizeComment(comment, "专业负责人确认志愿"));
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    assignmentId = rs.next() ? rs.getInt(1) : 0;
                }
            }
            if (assignmentId <= 0) {
                conn.rollback();
                return 0;
            }

            markStudentChoices(conn, snapshot.studentId, snapshot.round, snapshot.choiceId);
            expireApplication(conn, snapshot.applicationId, "confirmed");
            closeOtherApplicationChoices(conn, snapshot.applicationId, snapshot.choiceId);
            if (updateTopicSelected(conn, snapshot.topicId)) {
                expireTopicChoices(conn, snapshot.topicId, snapshot.choiceId);
            }

            conn.commit();
            return assignmentId;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int manualAssign(int studentId, int topicId, int confirmerId, String college,
            String major, String comment) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE id=? AND role='student' AND status=1 "
                    + "AND college=? AND major=? FOR UPDATE")) {
                ps.setInt(1, studentId);
                ps.setString(2, college);
                ps.setString(3, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return ERR_SCOPE;
                    }
                }
            }

            String topicStatus;
            int selectedCount;
            int maxStudents;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT status,selected_count,max_students "
                    + "FROM topics WHERE id=? AND college=? AND major=? FOR UPDATE")) {
                ps.setInt(1, topicId);
                ps.setString(2, college);
                ps.setString(3, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return ERR_SCOPE;
                    }
                    topicStatus = rs.getString(1);
                    selectedCount = rs.getInt(2);
                    maxStudents = rs.getInt(3);
                }
            }
            if (!"open".equals(topicStatus) || selectedCount >= maxStudents) {
                conn.rollback();
                return ERR_CHOICE_INVALID;
            }
            if (hasStudentAssignment(conn, studentId) || hasLegacyApprovedStudent(conn, studentId)) {
                conn.rollback();
                return ERR_STUDENT_ASSIGNED;
            }

            int assignmentId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,"
                    + "confirmed_by,confirm_comment) VALUES(?,?,NULL,?,'manual',?,?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, studentId);
                ps.setInt(2, topicId);
                ps.setInt(3, 2);
                ps.setInt(4, confirmerId);
                ps.setString(5, normalizeComment(comment, "第二轮后系主任强制分配"));
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    assignmentId = rs.next() ? rs.getInt(1) : 0;
                }
            }
            if (assignmentId <= 0) {
                conn.rollback();
                return 0;
            }

            expireAllStudentSubmittedApplications(conn, studentId);
            invalidateAllStudentPendingChoices(conn, studentId);
            if (updateTopicSelected(conn, topicId)) {
                expireTopicChoices(conn, topicId, 0);
            }
            conn.commit();
            return assignmentId;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public TopicSelection toTopicSelection(TopicAssignment assignment) {
        if (assignment == null) {
            return null;
        }
        TopicSelection selection = new TopicSelection();
        selection.setId(assignment.getId());
        selection.setStudentId(assignment.getStudentId());
        selection.setTopicId(assignment.getTopicId());
        selection.setStudentName(assignment.getStudentName());
        selection.setStudentNo(assignment.getStudentNo());
        selection.setTopicTitle(assignment.getTopicTitle());
        selection.setTeacherName(assignment.getTeacherName());
        selection.setStatus("approved");
        selection.setRound(assignment.getRound());
        selection.setApplyReason("三志愿选题最终确认");
        selection.setReviewComment(assignment.getConfirmComment());
        selection.setApplyTime(assignment.getConfirmTime());
        selection.setReviewTime(assignment.getConfirmTime());
        return selection;
    }

    private TopicAssignment mapRow(Object[] row) {
        TopicAssignment a = new TopicAssignment();
        a.setId(((Number) row[0]).intValue());
        a.setStudentId(((Number) row[1]).intValue());
        a.setStudentName((String) row[2]);
        a.setStudentNo((String) row[3]);
        a.setTopicId(((Number) row[4]).intValue());
        a.setTopicTitle((String) row[5]);
        a.setTeacherName((String) row[6]);
        a.setChoiceId(row[7] == null ? null : Integer.valueOf(((Number) row[7]).intValue()));
        a.setRound(((Number) row[8]).intValue());
        a.setSource((String) row[9]);
        a.setConfirmedBy(((Number) row[10]).intValue());
        a.setConfirmerName((String) row[11]);
        a.setConfirmComment((String) row[12]);
        a.setConfirmTime(DateUtil.toDate(row[13]));
        return a;
    }

    private ChoiceSnapshot lockChoice(Connection conn, int choiceId, String college, String major)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT c.id,c.application_id,c.student_id,c.topic_id,c.round,c.status,"
                + "a.status,t.status,t.selected_count,t.max_students "
                + "FROM selection_choices c "
                + "JOIN selection_applications a ON c.application_id=a.id "
                + "JOIN users u ON c.student_id=u.id "
                + "JOIN topics t ON c.topic_id=t.id "
                + "WHERE c.id=? AND t.college=? AND t.major=? AND u.college=? AND u.major=? "
                + "FOR UPDATE")) {
            ps.setInt(1, choiceId);
            ps.setString(2, college);
            ps.setString(3, major);
            ps.setString(4, college);
            ps.setString(5, major);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                ChoiceSnapshot snapshot = new ChoiceSnapshot();
                snapshot.choiceId = rs.getInt(1);
                snapshot.applicationId = rs.getInt(2);
                snapshot.studentId = rs.getInt(3);
                snapshot.topicId = rs.getInt(4);
                snapshot.round = rs.getInt(5);
                snapshot.choiceStatus = rs.getString(6);
                snapshot.applicationStatus = rs.getString(7);
                snapshot.topicStatus = rs.getString(8);
                snapshot.selectedCount = rs.getInt(9);
                snapshot.maxStudents = rs.getInt(10);
                return snapshot;
            }
        }
    }

    private boolean hasStudentAssignment(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM topic_assignments WHERE student_id=? LIMIT 1")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean hasLegacyApprovedStudent(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM topic_selections WHERE student_id=? AND status='approved' LIMIT 1")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void markStudentChoices(Connection conn, int studentId, int round, int selectedChoiceId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_choices SET status=CASE WHEN id=? THEN 'selected' ELSE 'not_selected' END "
                + "WHERE student_id=? AND round=? AND status='pending'")) {
            ps.setInt(1, selectedChoiceId);
            ps.setInt(2, studentId);
            ps.setInt(3, round);
            ps.executeUpdate();
        }
    }

    private void closeOtherApplicationChoices(Connection conn, int applicationId, int selectedChoiceId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_choices SET status='not_selected' "
                + "WHERE application_id=? AND id<>? AND status='pending'")) {
            ps.setInt(1, applicationId);
            ps.setInt(2, selectedChoiceId);
            ps.executeUpdate();
        }
    }

    private void expireTopicChoices(Connection conn, int topicId, int selectedChoiceId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_choices SET status='not_selected' "
                + "WHERE topic_id=? AND id<>? AND status='pending'")) {
            ps.setInt(1, topicId);
            ps.setInt(2, selectedChoiceId);
            ps.executeUpdate();
        }
    }

    private void expireApplication(Connection conn, int applicationId, String status) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_applications SET status=? WHERE id=? AND status='submitted'")) {
            ps.setString(1, status);
            ps.setInt(2, applicationId);
            ps.executeUpdate();
        }
    }

    private void expireAllStudentSubmittedApplications(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_applications SET status='confirmed' "
                + "WHERE student_id=? AND status='submitted'")) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
        }
    }

    private void invalidateAllStudentPendingChoices(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE selection_choices SET status='not_selected' "
                + "WHERE student_id=? AND status='pending'")) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
        }
    }

    private boolean updateTopicSelected(Connection conn, int topicId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE topics SET selected_count=selected_count+1,"
                + "status=CASE WHEN selected_count+1>=max_students THEN 'closed' ELSE 'open' END "
                + "WHERE id=?")) {
            ps.setInt(1, topicId);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT selected_count>=max_students FROM topics WHERE id=?")) {
            ps.setInt(1, topicId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        }
    }

    private String normalizeComment(String comment, String fallback) {
        String clean = comment == null ? "" : comment.trim();
        return clean.isEmpty() ? fallback : clean;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ignored) {}
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (Exception ignored) {}
        }
    }

    private static class ChoiceSnapshot {
        int choiceId;
        int applicationId;
        int studentId;
        int topicId;
        int round;
        String choiceStatus;
        String applicationStatus;
        String topicStatus;
        int selectedCount;
        int maxStudents;
    }
}
