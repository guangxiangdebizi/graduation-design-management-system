package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import bean.DefenseSchedule;
import bean.DefenseScore;
import bean.DefenseTeacherScore;
import bean.User;
import util.CollegeUtil;
import util.DateUtil;
import util.SQLHelper;

public class DefenseScheduleDao {
    public static final int ERR_STUDENT_INVALID = -1;
    public static final int ERR_TEACHER_COUNT = -2;
    public static final int ERR_DUPLICATE_TEACHER = -3;
    public static final int ERR_TEACHER_SCOPE = -4;
    public static final int ERR_NOT_MEMBER = -5;
    public static final int ERR_SCORE_INVALID = -6;

    private static final String SELECTION_SQL =
        "SELECT student_id,topic_id FROM topic_assignments "
        + "UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'";

    private static final String AVG_SQL =
        "SELECT schedule_id,AVG(score) avg_score,COUNT(*) score_count "
        + "FROM defense_scores GROUP BY schedule_id";

    public List<DefenseSchedule> findAll() {
        String sql =
            "SELECT d.id,d.student_id,u.real_name,u.student_no,t.title,teacher.real_name,"
            + "d.defense_time,d.room,d.group_name,d.score,d.comment,d.created_at,"
            + "agg.avg_score,agg.score_count "
            + "FROM defense_schedules d "
            + "JOIN users u ON d.student_id=u.id "
            + "LEFT JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
            + "LEFT JOIN topics t ON t.id=sel.topic_id "
            + "LEFT JOIN users teacher ON t.teacher_id=teacher.id "
            + "LEFT JOIN (" + AVG_SQL + ") agg ON agg.schedule_id=d.id "
            + "ORDER BY d.created_at DESC,d.id DESC";
        return attachDetails(mapScheduleRows(SQLHelper.queryList(sql)));
    }

    public List<DefenseSchedule> findByDirectorScope(String college, String major) {
        String sql =
            "SELECT COALESCE(d.id,0),u.id,u.real_name,u.student_no,t.title,teacher.real_name,"
            + "d.defense_time,d.room,d.group_name,d.score,d.comment,d.created_at,"
            + "agg.avg_score,agg.score_count "
            + "FROM users u "
            + "JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
            + "JOIN topics t ON t.id=sel.topic_id "
            + "JOIN users teacher ON t.teacher_id=teacher.id "
            + "JOIN documents f ON f.student_id=u.id AND f.doc_type='final' AND f.status='reviewed' "
            + "LEFT JOIN defense_schedules d ON d.student_id=u.id "
            + "LEFT JOIN (" + AVG_SQL + ") agg ON agg.schedule_id=d.id "
            + "WHERE u.role='student' AND u.status=1 "
            + "AND u.college=? AND u.major=? AND t.college=? AND t.major=? "
            + "ORDER BY u.student_no,u.id";
        return attachDetails(mapScheduleRows(SQLHelper.queryList(
            sql, college, major, college, major)));
    }

    public List<User> findCommitteeTeachers(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT id,username,role,real_name,title,college,major,status "
            + "FROM users WHERE role IN ('teacher','director') AND status=1 "
            + "AND college=? AND major=? ORDER BY role,real_name,id",
            college, major);
        List<User> list = new ArrayList<User>();
        for (Object[] row : rows) {
            User u = new User();
            u.setId(((Number) row[0]).intValue());
            u.setUsername((String) row[1]);
            u.setRole((String) row[2]);
            u.setRealName((String) row[3]);
            u.setTitle((String) row[4]);
            u.setCollege((String) row[5]);
            u.setMajor((String) row[6]);
            u.setStatus(((Number) row[7]).intValue());
            u.setCollegeName(CollegeUtil.getCollegeName(u.getCollege()));
            u.setMajorName(CollegeUtil.getMajorName(u.getCollege(), u.getMajor()));
            list.add(u);
        }
        return list;
    }

    public List<DefenseTeacherScore> findScoringTasksByTeacher(int teacherId) {
        String sql =
            "SELECT d.id,d.student_id,u.real_name,u.student_no,t.title,supervisor.real_name,"
            + "s.score,s.comment,s.score_time,agg.avg_score,agg.score_count "
            + "FROM defense_committee_members m "
            + "JOIN defense_schedules d ON m.schedule_id=d.id "
            + "JOIN users u ON d.student_id=u.id "
            + "JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
            + "JOIN topics t ON t.id=sel.topic_id "
            + "JOIN users supervisor ON t.teacher_id=supervisor.id "
            + "LEFT JOIN defense_scores s ON s.schedule_id=d.id AND s.teacher_id=m.teacher_id "
            + "LEFT JOIN (" + AVG_SQL + ") agg ON agg.schedule_id=d.id "
            + "WHERE m.teacher_id=? "
            + "ORDER BY CASE WHEN s.score IS NULL THEN 0 ELSE 1 END,u.student_no,u.id";
        List<Object[]> rows = SQLHelper.queryList(sql, teacherId);
        List<DefenseTeacherScore> list = new ArrayList<DefenseTeacherScore>();
        for (Object[] row : rows) {
            DefenseTeacherScore item = new DefenseTeacherScore();
            item.setScheduleId(((Number) row[0]).intValue());
            item.setStudentId(((Number) row[1]).intValue());
            item.setStudentName((String) row[2]);
            item.setStudentNo((String) row[3]);
            item.setTopicTitle((String) row[4]);
            item.setSupervisorName((String) row[5]);
            item.setMyScore(toBigDecimal(row[6]));
            item.setMyComment((String) row[7]);
            item.setScoreTime(DateUtil.toDate(row[8]));
            item.setAverageScore(toBigDecimal(row[9]));
            item.setScoreCount(row[10] == null ? 0 : ((Number) row[10]).intValue());
            list.add(item);
        }
        return list;
    }

    public DefenseSchedule findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT d.id,d.student_id,u.real_name,u.student_no,t.title,teacher.real_name,"
            + "d.defense_time,d.room,d.group_name,d.score,d.comment,d.created_at,"
            + "agg.avg_score,agg.score_count "
            + "FROM defense_schedules d "
            + "JOIN users u ON d.student_id=u.id "
            + "LEFT JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
            + "LEFT JOIN topics t ON t.id=sel.topic_id "
            + "LEFT JOIN users teacher ON t.teacher_id=teacher.id "
            + "LEFT JOIN (" + AVG_SQL + ") agg ON agg.schedule_id=d.id "
            + "WHERE d.student_id=? LIMIT 1",
            studentId);
        if (rows.isEmpty()) {
            return null;
        }
        DefenseSchedule schedule = mapScheduleRow(rows.get(0));
        attachDetail(schedule);
        return schedule;
    }

    public DefenseSchedule findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT d.id,d.student_id,u.real_name,u.student_no,t.title,teacher.real_name,"
            + "d.defense_time,d.room,d.group_name,d.score,d.comment,d.created_at,"
            + "agg.avg_score,agg.score_count "
            + "FROM defense_schedules d "
            + "JOIN users u ON d.student_id=u.id "
            + "LEFT JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
            + "LEFT JOIN topics t ON t.id=sel.topic_id "
            + "LEFT JOIN users teacher ON t.teacher_id=teacher.id "
            + "LEFT JOIN (" + AVG_SQL + ") agg ON agg.schedule_id=d.id "
            + "WHERE d.id=? LIMIT 1",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        DefenseSchedule schedule = mapScheduleRow(rows.get(0));
        attachDetail(schedule);
        return schedule;
    }

    public int saveCommittee(int studentId, int[] teacherIds, int arrangerId,
            String college, String major) {
        if (teacherIds == null || teacherIds.length != 3) {
            return ERR_TEACHER_COUNT;
        }
        Set<Integer> unique = new LinkedHashSet<Integer>();
        for (int id : teacherIds) {
            if (id <= 0) {
                return ERR_TEACHER_COUNT;
            }
            unique.add(Integer.valueOf(id));
        }
        if (unique.size() != 3) {
            return ERR_DUPLICATE_TEACHER;
        }

        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            if (!eligibleStudent(conn, studentId, college, major)) {
                conn.rollback();
                return ERR_STUDENT_INVALID;
            }
            for (int teacherId : teacherIds) {
                if (!validCommitteeTeacher(conn, teacherId, college, major)) {
                    conn.rollback();
                    return ERR_TEACHER_SCOPE;
                }
            }

            int scheduleId = findScheduleIdForUpdate(conn, studentId);
            if (scheduleId <= 0) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO defense_schedules(student_id,comment) VALUES(?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, studentId);
                    ps.setString(2, "系主任已指定三名答辩教师");
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        scheduleId = rs.next() ? rs.getInt(1) : 0;
                    }
                }
            }
            if (scheduleId <= 0) {
                conn.rollback();
                return 0;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM defense_committee_members WHERE schedule_id=?")) {
                ps.setInt(1, scheduleId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO defense_committee_members(schedule_id,teacher_id,member_order) "
                    + "VALUES(?,?,?)")) {
                for (int i = 0; i < teacherIds.length; i++) {
                    ps.setInt(1, scheduleId);
                    ps.setInt(2, teacherIds[i]);
                    ps.setInt(3, i + 1);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM defense_scores WHERE schedule_id=? "
                    + "AND teacher_id NOT IN (?,?,?)")) {
                ps.setInt(1, scheduleId);
                ps.setInt(2, teacherIds[0]);
                ps.setInt(3, teacherIds[1]);
                ps.setInt(4, teacherIds[2]);
                ps.executeUpdate();
            }
            updateAverageScore(conn, scheduleId);
            conn.commit();
            return scheduleId;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int submitScore(int scheduleId, int teacherId, BigDecimal score, String comment) {
        if (score == null || score.compareTo(BigDecimal.ZERO) < 0
                || score.compareTo(new BigDecimal("100")) > 0) {
            return ERR_SCORE_INVALID;
        }
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);
            if (!isCommitteeMember(conn, scheduleId, teacherId)) {
                conn.rollback();
                return ERR_NOT_MEMBER;
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO defense_scores(schedule_id,teacher_id,score,comment,score_time) "
                    + "VALUES(?,?,?,?,NOW()) "
                    + "ON DUPLICATE KEY UPDATE score=VALUES(score),comment=VALUES(comment),"
                    + "score_time=NOW()")) {
                ps.setInt(1, scheduleId);
                ps.setInt(2, teacherId);
                ps.setBigDecimal(3, score);
                ps.setString(4, comment);
                ps.executeUpdate();
            }
            updateAverageScore(conn, scheduleId);
            conn.commit();
            return scheduleId;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int insert(DefenseSchedule ds) {
        return SQLHelper.executeInsert(
            "INSERT INTO defense_schedules(student_id,defense_time,room,group_name,score,comment) VALUES(?,?,?,?,?,?)",
            ds.getStudentId(), ds.getDefenseTime(), ds.getRoom(), ds.getGroupName(),
            ds.getScore(), ds.getComment());
    }

    public int update(DefenseSchedule ds) {
        return SQLHelper.executeUpdate(
            "UPDATE defense_schedules SET student_id=?,defense_time=?,room=?,group_name=?,score=?,comment=? WHERE id=?",
            ds.getStudentId(), ds.getDefenseTime(), ds.getRoom(), ds.getGroupName(),
            ds.getScore(), ds.getComment(), ds.getId());
    }

    public int delete(int id) {
        SQLHelper.executeUpdate("DELETE FROM defense_scores WHERE schedule_id=?", id);
        SQLHelper.executeUpdate("DELETE FROM defense_committee_members WHERE schedule_id=?", id);
        return SQLHelper.executeUpdate("DELETE FROM defense_schedules WHERE id=?", id);
    }

    public boolean existsByStudent(int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM defense_schedules WHERE student_id=?", studentId);
        return val != null && ((Number) val).intValue() > 0;
    }

    public boolean existsByStudentExceptId(int studentId, int id) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM defense_schedules WHERE student_id=? AND id<>?", studentId, id);
        return val != null && ((Number) val).intValue() > 0;
    }

    private boolean eligibleStudent(Connection conn, int studentId, String college,
            String major) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT u.id FROM users u "
                + "JOIN (" + SELECTION_SQL + ") sel ON sel.student_id=u.id "
                + "JOIN topics t ON t.id=sel.topic_id "
                + "JOIN documents f ON f.student_id=u.id AND f.doc_type='final' AND f.status='reviewed' "
                + "WHERE u.id=? AND u.role='student' AND u.status=1 "
                + "AND u.college=? AND u.major=? AND t.college=? AND t.major=? "
                + "LIMIT 1 FOR UPDATE")) {
            ps.setInt(1, studentId);
            ps.setString(2, college);
            ps.setString(3, major);
            ps.setString(4, college);
            ps.setString(5, major);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean validCommitteeTeacher(Connection conn, int teacherId, String college,
            String major) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM users WHERE id=? AND role IN ('teacher','director') "
                + "AND status=1 AND college=? AND major=? LIMIT 1")) {
            ps.setInt(1, teacherId);
            ps.setString(2, college);
            ps.setString(3, major);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private int findScheduleIdForUpdate(Connection conn, int studentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT id FROM defense_schedules WHERE student_id=? FOR UPDATE")) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private boolean isCommitteeMember(Connection conn, int scheduleId, int teacherId)
            throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM defense_committee_members "
                + "WHERE schedule_id=? AND teacher_id=? LIMIT 1")) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void updateAverageScore(Connection conn, int scheduleId) throws Exception {
        BigDecimal avg = null;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT AVG(score) FROM defense_scores WHERE schedule_id=?")) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    avg = rs.getBigDecimal(1);
                }
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE defense_schedules SET score=? WHERE id=?")) {
            ps.setBigDecimal(1, avg);
            ps.setInt(2, scheduleId);
            ps.executeUpdate();
        }
    }

    private List<DefenseSchedule> attachDetails(List<DefenseSchedule> schedules) {
        for (DefenseSchedule schedule : schedules) {
            attachDetail(schedule);
        }
        return schedules;
    }

    private void attachDetail(DefenseSchedule schedule) {
        if (schedule == null || schedule.getId() <= 0) {
            return;
        }
        schedule.setCommitteeMembers(findMembersBySchedule(schedule.getId()));
        schedule.setScores(findScoresBySchedule(schedule.getId()));
    }

    private List<User> findMembersBySchedule(int scheduleId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT u.id,u.username,u.role,u.real_name,u.title,u.college,u.major,u.status "
            + "FROM defense_committee_members m JOIN users u ON m.teacher_id=u.id "
            + "WHERE m.schedule_id=? ORDER BY m.member_order,m.id",
            scheduleId);
        List<User> list = new ArrayList<User>();
        for (Object[] row : rows) {
            User u = new User();
            u.setId(((Number) row[0]).intValue());
            u.setUsername((String) row[1]);
            u.setRole((String) row[2]);
            u.setRealName((String) row[3]);
            u.setTitle((String) row[4]);
            u.setCollege((String) row[5]);
            u.setMajor((String) row[6]);
            u.setStatus(((Number) row[7]).intValue());
            list.add(u);
        }
        return list;
    }

    private List<DefenseScore> findScoresBySchedule(int scheduleId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT s.id,s.schedule_id,s.teacher_id,u.real_name,s.score,s.comment,s.score_time "
            + "FROM defense_scores s JOIN users u ON s.teacher_id=u.id "
            + "WHERE s.schedule_id=? ORDER BY u.real_name,u.id",
            scheduleId);
        List<DefenseScore> list = new ArrayList<DefenseScore>();
        for (Object[] row : rows) {
            DefenseScore score = new DefenseScore();
            score.setId(((Number) row[0]).intValue());
            score.setScheduleId(((Number) row[1]).intValue());
            score.setTeacherId(((Number) row[2]).intValue());
            score.setTeacherName((String) row[3]);
            score.setScore(toBigDecimal(row[4]));
            score.setComment((String) row[5]);
            score.setScoreTime(DateUtil.toDate(row[6]));
            list.add(score);
        }
        return list;
    }

    private List<DefenseSchedule> mapScheduleRows(List<Object[]> rows) {
        List<DefenseSchedule> list = new ArrayList<DefenseSchedule>();
        for (Object[] row : rows) {
            list.add(mapScheduleRow(row));
        }
        return list;
    }

    private DefenseSchedule mapScheduleRow(Object[] row) {
        DefenseSchedule d = new DefenseSchedule();
        d.setId(row[0] == null ? 0 : ((Number) row[0]).intValue());
        d.setStudentId(((Number) row[1]).intValue());
        d.setStudentName((String) row[2]);
        d.setStudentNo((String) row[3]);
        d.setTopicTitle((String) row[4]);
        d.setTeacherName((String) row[5]);
        d.setDefenseTime(DateUtil.toDate(row[6]));
        d.setRoom((String) row[7]);
        d.setGroupName((String) row[8]);
        d.setScore(toBigDecimal(row[9]));
        d.setComment((String) row[10]);
        d.setCreatedAt(DateUtil.toDate(row[11]));
        d.setAverageScore(toBigDecimal(row[12]));
        d.setScoreCount(row[13] == null ? 0 : ((Number) row[13]).intValue());
        return d;
    }

    private BigDecimal toBigDecimal(Object value) {
        return value == null ? null : new BigDecimal(value.toString());
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
