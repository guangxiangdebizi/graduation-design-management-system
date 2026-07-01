package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import bean.SelectionChoice;
import bean.TopicAssignment;
import bean.TopicChoiceGroup;
import util.DateUtil;
import util.SQLHelper;
import util.SystemSwitchUtil;

public class TeacherChoiceReviewDao {
    public static final int ERR_FORBIDDEN = -1;
    public static final int ERR_STUDENT_ASSIGNED = -2;
    public static final int ERR_TOPIC_ASSIGNED = -3;
    public static final int ERR_CHOICE_INVALID = -4;
    public static final int ERR_REVIEW_CLOSED = -5;

    public List<TopicChoiceGroup> findChoiceGroupsByTeacher(int teacherId, int round) {
        int normalizedRound = normalizeRound(round);
        List<Object[]> rows = SQLHelper.queryList(choiceSelectSql()
            + "WHERE t.teacher_id=? AND c.round=? AND c.status='pending' "
            + "AND a.status='submitted' "
            + "AND t.status='open' AND t.selected_count < t.max_students "
            + "AND NOT EXISTS (SELECT 1 FROM topic_assignments x WHERE x.student_id=u.id) "
            + "AND NOT EXISTS (SELECT 1 FROM topic_selections x "
            + "  WHERE x.student_id=u.id AND x.status='approved') "
            + "ORDER BY t.created_at DESC,t.id,c.choice_rank,u.student_no,u.id",
            teacherId, normalizedRound);

        List<SelectionChoice> choices = mapChoices(rows);
        Map<Integer, TopicChoiceGroup> groups = new LinkedHashMap<Integer, TopicChoiceGroup>();
        for (SelectionChoice choice : choices) {
            Integer key = Integer.valueOf(choice.getTopicId());
            TopicChoiceGroup group = groups.get(key);
            if (group == null) {
                group = new TopicChoiceGroup();
                group.setTopicId(choice.getTopicId());
                group.setTopicTitle(choice.getTopicTitle());
                group.setTeacherName(choice.getTeacherName());
                group.setRound(choice.getRound());
                groups.put(key, group);
            }
            group.getChoices().add(choice);
        }
        return new ArrayList<TopicChoiceGroup>(groups.values());
    }

    public int acceptChoice(int teacherId, int choiceId, String comment) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            ChoiceSnapshot snapshot = lockChoiceForTeacher(conn, teacherId, choiceId);
            if (snapshot == null) {
                conn.rollback();
                return ERR_FORBIDDEN;
            }
            if (!isReviewOpen(snapshot.round)) {
                conn.rollback();
                return ERR_REVIEW_CLOSED;
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
            if (hasStudentAssignment(conn, snapshot.studentId)
                    || hasLegacyApprovedStudent(conn, snapshot.studentId)) {
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
                ps.setInt(6, teacherId);
                ps.setString(7, normalizeComment(comment, "指导教师接收该学生志愿"));
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

    public int rejectChoice(int teacherId, int choiceId, String comment) {
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            ChoiceSnapshot snapshot = lockChoiceForTeacher(conn, teacherId, choiceId);
            if (snapshot == null) {
                conn.rollback();
                return ERR_FORBIDDEN;
            }
            if (!isReviewOpen(snapshot.round)) {
                conn.rollback();
                return ERR_REVIEW_CLOSED;
            }
            if (!"pending".equals(snapshot.choiceStatus)
                    || !"submitted".equals(snapshot.applicationStatus)) {
                conn.rollback();
                return ERR_CHOICE_INVALID;
            }
            if (hasStudentAssignment(conn, snapshot.studentId)
                    || hasLegacyApprovedStudent(conn, snapshot.studentId)) {
                conn.rollback();
                return ERR_STUDENT_ASSIGNED;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE selection_choices SET status='not_selected' WHERE id=? AND status='pending'")) {
                ps.setInt(1, snapshot.choiceId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return 0;
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

    public TopicAssignment findAssignmentById(int id) {
        return new TopicAssignmentDao().findById(id);
    }

    private boolean isReviewOpen(int round) {
        if (SystemSwitchUtil.isManualAssignOpen()) {
            return false;
        }
        return round >= 2
            ? SystemSwitchUtil.isSecondRoundOpen()
            : SystemSwitchUtil.isFirstRoundOpen();
    }

    private int normalizeRound(int round) {
        return round >= 2 ? 2 : 1;
    }

    private String choiceSelectSql() {
        return "SELECT c.id,c.application_id,c.student_id,u.real_name,u.student_no,"
            + "c.topic_id,t.title,teacher.real_name,c.round,c.choice_rank,c.status,c.created_at,"
            + "(SELECT COUNT(*) FROM selection_choices x "
            + " WHERE x.topic_id=c.topic_id AND x.round=c.round AND x.status='pending') AS intent_count "
            + "FROM selection_choices c "
            + "JOIN selection_applications a ON c.application_id=a.id "
            + "JOIN users u ON c.student_id=u.id "
            + "JOIN topics t ON c.topic_id=t.id "
            + "JOIN users teacher ON t.teacher_id=teacher.id ";
    }

    private List<SelectionChoice> mapChoices(List<Object[]> rows) {
        List<SelectionChoice> list = new ArrayList<SelectionChoice>();
        for (Object[] row : rows) {
            SelectionChoice c = new SelectionChoice();
            c.setId(((Number) row[0]).intValue());
            c.setApplicationId(((Number) row[1]).intValue());
            c.setStudentId(((Number) row[2]).intValue());
            c.setStudentName((String) row[3]);
            c.setStudentNo((String) row[4]);
            c.setTopicId(((Number) row[5]).intValue());
            c.setTopicTitle((String) row[6]);
            c.setTeacherName((String) row[7]);
            c.setRound(((Number) row[8]).intValue());
            c.setChoiceRank(((Number) row[9]).intValue());
            c.setStatus((String) row[10]);
            c.setCreatedAt(DateUtil.toDate(row[11]));
            c.setCurrentIntentCount(row[12] == null ? 0 : ((Number) row[12]).intValue());
            list.add(c);
        }
        return list;
    }

    private ChoiceSnapshot lockChoiceForTeacher(Connection conn, int teacherId, int choiceId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT c.id,c.application_id,c.student_id,c.topic_id,c.round,c.status,"
                + "a.status,t.status,t.selected_count,t.max_students "
                + "FROM selection_choices c "
                + "JOIN selection_applications a ON c.application_id=a.id "
                + "JOIN topics t ON c.topic_id=t.id "
                + "WHERE c.id=? AND t.teacher_id=? FOR UPDATE")) {
            ps.setInt(1, choiceId);
            ps.setInt(2, teacherId);
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
