package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import bean.SelectionApplication;
import bean.SelectionChoice;
import bean.Topic;
import bean.TopicChoiceGroup;
import util.CollegeUtil;
import util.DateUtil;
import util.SQLHelper;
import util.SystemConfigUtil;
import util.SystemSwitchUtil;

public class SelectionChoiceDao {
    public static final int ERR_HAS_ASSIGNMENT = -1;
    public static final int ERR_SELECTION_CLOSED = -2;
    public static final int ERR_CHOICE_COUNT = -3;
    public static final int ERR_DUPLICATE_CHOICE = -4;
    public static final int ERR_TOPIC_INVALID = -5;
    public static final int ERR_ALREADY_SUBMITTED = -7;

    public List<Topic> findSelectableTopics(int studentId, int round) {
        List<Object[]> studentRows = SQLHelper.queryList(
            "SELECT college,major FROM users WHERE id=? AND role='student' AND status=1",
            studentId);
        if (studentRows.isEmpty()) {
            return new ArrayList<Topic>();
        }
        String college = (String) studentRows.get(0)[0];
        String major = (String) studentRows.get(0)[1];
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

    public Map<Integer, Integer> confirmedCounts(List<Topic> topics) {
        Map<Integer, Integer> counts = new LinkedHashMap<Integer, Integer>();
        if (topics == null || topics.isEmpty()) {
            return counts;
        }
        for (Topic topic : topics) {
            counts.put(Integer.valueOf(topic.getId()),
                Integer.valueOf(topic.getSelectedCount()));
        }
        return counts;
    }

    public int submitChoices(int studentId, int round, List<Integer> topicIds) {
        int normalizedRound = round >= 2 ? 2 : 1;
        int choiceLimit = SystemConfigUtil.getInt("selection.choice_limit", 3);
        if (!SystemSwitchUtil.isSelectionOpenForRound(normalizedRound)
                || SystemSwitchUtil.currentRound() != normalizedRound) {
            return ERR_SELECTION_CLOSED;
        }
        if (topicIds == null || topicIds.isEmpty() || topicIds.size() > choiceLimit) {
            return ERR_CHOICE_COUNT;
        }
        Set<Integer> unique = new HashSet<Integer>();
        for (Integer topicId : topicIds) {
            if (topicId == null || topicId.intValue() <= 0 || !unique.add(topicId)) {
                return ERR_DUPLICATE_CHOICE;
            }
        }

        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            String college;
            String major;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role,status,college,major FROM users WHERE id=? FOR UPDATE")) {
                ps.setInt(1, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !"student".equals(rs.getString(1)) || rs.getInt(2) != 1) {
                        conn.rollback();
                        return 0;
                    }
                    college = rs.getString(3);
                    major = rs.getString(4);
                }
            }

            if (hasFinalAssignment(conn, studentId)) {
                conn.rollback();
                return ERR_HAS_ASSIGNMENT;
            }
            if (hasSubmittedApplication(conn, studentId, normalizedRound)) {
                conn.rollback();
                return ERR_ALREADY_SUBMITTED;
            }

            for (Integer topicId : topicIds) {
                if (!validTopicForStudent(conn, topicId.intValue(), college, major)) {
                    conn.rollback();
                    return ERR_TOPIC_INVALID;
                }
            }

            int appId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO selection_applications(student_id,round,status) "
                    + "VALUES(?,?,'submitted')",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, studentId);
                ps.setInt(2, normalizedRound);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    appId = rs.next() ? rs.getInt(1) : 0;
                }
            }
            if (appId <= 0) {
                conn.rollback();
                return 0;
            }

            int rank = 1;
            for (Integer topicId : topicIds) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status) "
                        + "VALUES(?,?,?,?,?,'pending')")) {
                    ps.setInt(1, appId);
                    ps.setInt(2, studentId);
                    ps.setInt(3, topicId.intValue());
                    ps.setInt(4, normalizedRound);
                    ps.setInt(5, rank++);
                    ps.executeUpdate();
                }
            }
            conn.commit();
            return appId;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public SelectionApplication findActiveApplication(int studentId, int round) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT a.id,a.student_id,u.real_name,u.student_no,u.college,u.major,"
            + "a.round,a.status,a.submit_time,a.update_time "
            + "FROM selection_applications a JOIN users u ON a.student_id=u.id "
            + "WHERE a.student_id=? AND a.round=? AND a.status='submitted' "
            + "ORDER BY a.submit_time DESC LIMIT 1",
            studentId, round >= 2 ? 2 : 1);
        return rows.isEmpty() ? null : mapApplication(rows.get(0));
    }

    public List<SelectionChoice> findByApplication(int applicationId) {
        List<Object[]> rows = SQLHelper.queryList(choiceSelectSql()
            + "WHERE c.application_id=? ORDER BY c.choice_rank", applicationId);
        return mapChoices(rows);
    }

    public List<SelectionChoice> findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(choiceSelectSql()
            + "WHERE c.student_id=? ORDER BY c.round DESC,c.choice_rank", studentId);
        return mapChoices(rows);
    }

    public List<TopicChoiceGroup> findTopicChoiceGroups(String college, String major, int round) {
        int normalizedRound = round >= 2 ? 2 : 1;
        List<Object[]> rows = SQLHelper.queryList(choiceSelectSql()
            + "JOIN selection_applications a ON c.application_id=a.id "
            + "WHERE c.round=? AND c.status='pending' AND a.status='submitted' "
            + "AND t.college=? AND t.major=? AND u.college=? AND u.major=? "
            + "AND t.status='open' AND t.selected_count < t.max_students "
            + "AND NOT EXISTS (SELECT 1 FROM topic_assignments x WHERE x.student_id=u.id) "
            + "AND NOT EXISTS (SELECT 1 FROM topic_selections x "
            + "  WHERE x.student_id=u.id AND x.status='approved') "
            + "ORDER BY t.created_at DESC,t.id,c.choice_rank,u.student_no,u.id",
            normalizedRound, college, major, college, major);

        List<SelectionChoice> choices = mapChoices(rows);
        Map<Integer, TopicChoiceGroup> groupMap = new LinkedHashMap<Integer, TopicChoiceGroup>();
        for (SelectionChoice choice : choices) {
            Integer key = Integer.valueOf(choice.getTopicId());
            TopicChoiceGroup group = groupMap.get(key);
            if (group == null) {
                group = new TopicChoiceGroup();
                group.setTopicId(choice.getTopicId());
                group.setTopicTitle(choice.getTopicTitle());
                group.setTeacherName(choice.getTeacherName());
                group.setRound(choice.getRound());
                groupMap.put(key, group);
            }
            group.getChoices().add(choice);
        }
        return new ArrayList<TopicChoiceGroup>(groupMap.values());
    }

    private boolean hasFinalAssignment(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM topic_assignments WHERE student_id=? LIMIT 1")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return true;
                }
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM topic_selections WHERE student_id=? AND status='approved' LIMIT 1")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean hasSubmittedApplication(Connection conn, int studentId, int round) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM selection_applications "
                + "WHERE student_id=? AND round=? AND status='submitted' LIMIT 1")) {
            ps.setInt(1, studentId);
            ps.setInt(2, round);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean validTopicForStudent(Connection conn, int topicId, String college, String major)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT status,college,major,selected_count,max_students "
                + "FROM topics WHERE id=? FOR UPDATE")) {
            ps.setInt(1, topicId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next() || !"open".equals(rs.getString(1))) {
                    return false;
                }
                if (!same(college, rs.getString(2)) || !same(major, rs.getString(3))) {
                    return false;
                }
                if (rs.getInt(4) >= rs.getInt(5)) {
                    return false;
                }
            }
        }
        return true;
    }

    private String choiceSelectSql() {
        return "SELECT c.id,c.application_id,c.student_id,u.real_name,u.student_no,"
            + "c.topic_id,t.title,teacher.real_name,c.round,c.choice_rank,c.status,c.created_at,"
            + "(SELECT COUNT(*) FROM selection_choices x "
            + " WHERE x.topic_id=c.topic_id AND x.round=c.round AND x.status='pending') AS intent_count "
            + "FROM selection_choices c "
            + "JOIN users u ON c.student_id=u.id "
            + "JOIN topics t ON c.topic_id=t.id "
            + "JOIN users teacher ON t.teacher_id=teacher.id ";
    }

    private SelectionApplication mapApplication(Object[] row) {
        SelectionApplication app = new SelectionApplication();
        app.setId(((Number) row[0]).intValue());
        app.setStudentId(((Number) row[1]).intValue());
        app.setStudentName((String) row[2]);
        app.setStudentNo((String) row[3]);
        app.setCollege((String) row[4]);
        app.setMajor((String) row[5]);
        app.setRound(((Number) row[6]).intValue());
        app.setStatus((String) row[7]);
        app.setSubmitTime(DateUtil.toDate(row[8]));
        app.setUpdateTime(DateUtil.toDate(row[9]));
        return app;
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

    private boolean same(String left, String right) {
        if (left == null || right == null) {
            return left == right;
        }
        return left.equals(right);
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
}
