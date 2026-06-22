package dao;

import java.util.ArrayList;
import java.util.List;
import bean.Topic;
import dbutil.SQLHelper;
import util.DateUtil;
import util.CollegeUtil;

public class TopicDao {
    private static final String SELECT_COLS =
        "t.id,t.title,t.description,t.teacher_id,u.real_name,t.college,t.major,t.max_students,t.selected_count,"
        + "t.status,t.review_comment,t.reviewer_id,r.real_name,t.review_time,t.created_at";
    private static final String FROM_SQL =
        " FROM topics t JOIN users u ON t.teacher_id=u.id "
        + "LEFT JOIN users r ON t.reviewer_id=r.id ";

    public List<Topic> findAll(String keyword, String college) {
        return findAll(keyword, college, null, null);
    }

    public List<Topic> findAll(String keyword, String college, String status) {
        return findAll(keyword, college, null, status);
    }

    public List<Topic> findAll(String keyword, String college, String major, String status) {
        String sql = "SELECT " + SELECT_COLS + FROM_SQL + "WHERE 1=1";
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
        if (major != null && !major.isEmpty()) {
            sql += " AND t.major=?";
            params.add(major);
        }
        if (status != null && !status.isEmpty()) {
            sql += " AND t.status=?";
            params.add(status);
        }
        sql += " ORDER BY t.created_at DESC";
        List<Object[]> rows = params.isEmpty() ?
            SQLHelper.queryList(sql) :
            SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public List<Topic> findByTeacher(int teacherId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + FROM_SQL + "WHERE t.teacher_id=? ORDER BY t.created_at DESC",
            teacherId);
        return mapList(rows);
    }

    public List<Topic> findOpenTopics(String keyword, String college) {
        return findOpenTopics(keyword, college, null);
    }

    public List<Topic> findOpenTopics(String keyword, String college, String major) {
        String sql = "SELECT " + SELECT_COLS + FROM_SQL
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
        if (major != null && !major.isEmpty()) {
            sql += " AND t.major=?";
            params.add(major);
        }
        sql += " ORDER BY t.created_at DESC";
        List<Object[]> rows = params.isEmpty() ?
            SQLHelper.queryList(sql) :
            SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public Topic findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + FROM_SQL + "WHERE t.id=?",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public int insert(Topic topic) {
        return SQLHelper.executeInsert(
            "INSERT INTO topics(title,description,teacher_id,college,major,max_students,status) VALUES(?,?,?,?,?,?,?)",
            topic.getTitle(), topic.getDescription(), topic.getTeacherId(),
            topic.getCollege(), topic.getMajor(), topic.getMaxStudents(), topic.getStatus());
    }

    public int update(Topic topic) {
        return SQLHelper.executeUpdate(
            "UPDATE topics SET title=?,description=?,college=?,major=?,max_students=?,status=?,"
            + "review_comment=NULL,reviewer_id=NULL,review_time=NULL WHERE id=? AND teacher_id=?",
            topic.getTitle(), topic.getDescription(), topic.getCollege(), topic.getMajor(),
            topic.getMaxStudents(), topic.getStatus(), topic.getId(), topic.getTeacherId());
    }

    public int review(int id, int reviewerId, String status, String comment) {
        if (!"open".equals(status) && !"rejected".equals(status)) {
            return 0;
        }
        if ("open".equals(status)) {
            return SQLHelper.executeUpdate(
                "UPDATE topics SET status=CASE WHEN selected_count>=max_students THEN 'closed' ELSE 'open' END,"
                + "review_comment=?,reviewer_id=?,review_time=NOW() "
                + "WHERE id=? AND status IN ('pending','rejected','open','closed')",
                comment, reviewerId, id);
        }
        return SQLHelper.executeUpdate(
            "UPDATE topics SET status=?,review_comment=?,reviewer_id=?,review_time=NOW() "
            + "WHERE id=? AND status IN ('pending','rejected','open','closed')",
            status, comment, reviewerId, id);
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

    public int countByMajor(String college, String major) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM topics WHERE college=? AND major=?", college, major);
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
        t.setMajor((String) row[6]);
        t.setMaxStudents(((Number) row[7]).intValue());
        t.setSelectedCount(((Number) row[8]).intValue());
        t.setStatus((String) row[9]);
        t.setReviewComment((String) row[10]);
        t.setReviewerId(row[11] == null ? null : ((Number) row[11]).intValue());
        t.setReviewerName((String) row[12]);
        t.setReviewTime(DateUtil.toDate(row[13]));
        t.setCreatedAt(DateUtil.toDate(row[14]));

        // 翻译学院名称
        if (t.getCollege() != null) {
            t.setCollegeName(CollegeUtil.getCollegeName(t.getCollege()));
        }
        if (t.getCollege() != null && t.getMajor() != null) {
            t.setMajorName(CollegeUtil.getMajorName(t.getCollege(), t.getMajor()));
        }
        return t;
    }
}
