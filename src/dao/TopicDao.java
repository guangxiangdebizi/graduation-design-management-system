package dao;

import java.util.ArrayList;
import java.util.List;
import bean.Topic;
import dbutil.SQLHelper;
import util.DateUtil;
import util.CollegeUtil;

public class TopicDao {
    private static final String SELECT_COLS =
        "t.id,t.title,t.description,t.teacher_id,u.real_name,t.college,t.max_students,t.selected_count,t.status,t.created_at";

    public List<Topic> findAll(String keyword, String college) {
        String sql = "SELECT " + SELECT_COLS + " FROM topics t JOIN users u ON t.teacher_id=u.id WHERE 1=1";
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (t.title LIKE ? OR t.description LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (college != null && !college.isEmpty()) {
            sql += " AND t.college=?";
            params.add(college);
        }
        sql += " ORDER BY t.created_at DESC";
        List<Object[]> rows = params.isEmpty() ?
            SQLHelper.queryList(sql) :
            SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public List<Topic> findByTeacher(int teacherId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + " FROM topics t JOIN users u ON t.teacher_id=u.id WHERE t.teacher_id=? ORDER BY t.created_at DESC",
            teacherId);
        return mapList(rows);
    }

    public List<Topic> findOpenTopics(String keyword, String college) {
        String sql = "SELECT " + SELECT_COLS + " FROM topics t JOIN users u ON t.teacher_id=u.id "
            + "WHERE t.status='open' AND t.selected_count < t.max_students";
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (t.title LIKE ? OR t.description LIKE ?)";
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (college != null && !college.isEmpty()) {
            sql += " AND t.college=?";
            params.add(college);
        }
        sql += " ORDER BY t.created_at DESC";
        List<Object[]> rows = params.isEmpty() ?
            SQLHelper.queryList(sql) :
            SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public Topic findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + " FROM topics t JOIN users u ON t.teacher_id=u.id WHERE t.id=?",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public int insert(Topic topic) {
        return SQLHelper.executeInsert(
            "INSERT INTO topics(title,description,teacher_id,college,max_students,status) VALUES(?,?,?,?,?,?)",
            topic.getTitle(), topic.getDescription(), topic.getTeacherId(),
            topic.getCollege(), topic.getMaxStudents(), topic.getStatus());
    }

    public int update(Topic topic) {
        return SQLHelper.executeUpdate(
            "UPDATE topics SET title=?,description=?,college=?,max_students=?,status=? WHERE id=? AND teacher_id=?",
            topic.getTitle(), topic.getDescription(), topic.getCollege(),
            topic.getMaxStudents(), topic.getStatus(), topic.getId(), topic.getTeacherId());
    }

    public int delete(int id, int teacherId) {
        return SQLHelper.executeUpdate("DELETE FROM topics WHERE id=? AND teacher_id=?", id, teacherId);
    }

    public int countAll() {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM topics");
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countByCollege(String college) {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM topics WHERE college=?", college);
        return val == null ? 0 : ((Number) val).intValue();
    }

    private List<Topic> mapList(List<Object[]> rows) {
        List<Topic> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private Topic mapRow(Object[] row) {
        Topic t = new Topic();
        t.setId(((Number) row[0]).intValue());
        t.setTitle((String) row[1]);
        t.setDescription((String) row[2]);
        t.setTeacherId(((Number) row[3]).intValue());
        t.setTeacherName((String) row[4]);
        t.setCollege((String) row[5]);
        t.setMaxStudents(((Number) row[6]).intValue());
        t.setSelectedCount(((Number) row[7]).intValue());
        t.setStatus((String) row[8]);
        t.setCreatedAt(DateUtil.toDate(row[9]));

        // 翻译学院名称
        if (t.getCollege() != null) {
            t.setCollegeName(CollegeUtil.getCollegeName(t.getCollege()));
        }
        return t;
    }
}