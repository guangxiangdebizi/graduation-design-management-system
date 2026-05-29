package dao;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import bean.DefenseSchedule;
import dbutil.SQLHelper;
import util.DateUtil;

public class DefenseScheduleDao {
    private static final String BASE_SQL =
        "SELECT d.id,d.student_id,u.real_name,u.student_no,t.title,ut.real_name,"
        + "d.defense_time,d.room,d.group_name,d.score,d.comment,d.created_at "
        + "FROM defense_schedules d "
        + "JOIN users u ON d.student_id=u.id "
        + "LEFT JOIN topic_selections s ON s.student_id=u.id AND s.status='approved' "
        + "LEFT JOIN topics t ON s.topic_id=t.id "
        + "LEFT JOIN users ut ON t.teacher_id=ut.id ";

    public List<DefenseSchedule> findAll() {
        return mapList(SQLHelper.queryList(BASE_SQL + "ORDER BY d.defense_time DESC, d.id DESC"));
    }

    public List<DefenseSchedule> findByTeacher(int teacherId) {
        String sql = BASE_SQL + "WHERE t.teacher_id=? ORDER BY d.defense_time DESC, d.id DESC";
        return mapList(SQLHelper.queryList(sql, teacherId));
    }

    public DefenseSchedule findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.student_id=? LIMIT 1", studentId);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public DefenseSchedule findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(BASE_SQL + "WHERE d.id=?", id);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
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
        return SQLHelper.executeUpdate("DELETE FROM defense_schedules WHERE id=?", id);
    }

    public boolean existsByStudent(int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM defense_schedules WHERE student_id=?", studentId);
        return val != null && ((Number) val).intValue() > 0;
    }

    private List<DefenseSchedule> mapList(List<Object[]> rows) {
        List<DefenseSchedule> list = new ArrayList<DefenseSchedule>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private DefenseSchedule mapRow(Object[] row) {
        DefenseSchedule d = new DefenseSchedule();
        d.setId(((Number) row[0]).intValue());
        d.setStudentId(((Number) row[1]).intValue());
        d.setStudentName((String) row[2]);
        d.setStudentNo((String) row[3]);
        d.setTopicTitle((String) row[4]);
        d.setTeacherName((String) row[5]);
        d.setDefenseTime(DateUtil.toDate(row[6]));
        d.setRoom((String) row[7]);
        d.setGroupName((String) row[8]);
        d.setScore(row[9] == null ? null : new BigDecimal(row[9].toString()));
        d.setComment((String) row[10]);
        d.setCreatedAt(DateUtil.toDate(row[11]));
        return d;
    }
}
