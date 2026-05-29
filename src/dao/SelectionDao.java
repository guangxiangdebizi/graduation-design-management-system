package dao;

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
        return SQLHelper.executeInsert(
            "INSERT INTO topic_selections(student_id,topic_id,status,apply_reason) VALUES(?,?,?,?)",
            studentId, topicId, "pending", reason);
    }

    public int review(int id, int teacherId, String status, String comment) {
        TopicSelection sel = findById(id);
        if (sel == null) {
            return 0;
        }
        TopicDao topicDao = new TopicDao();
        bean.Topic topic = topicDao.findById(sel.getTopicId());
        if (topic == null || topic.getTeacherId() != teacherId) {
            return 0;
        }
        if ("approved".equals(status)) {
            if (topic.getSelectedCount() >= topic.getMaxStudents()) {
                return -1;
            }
        }
        int r = SQLHelper.executeUpdate(
            "UPDATE topic_selections SET status=?,review_comment=?,review_time=NOW() WHERE id=?",
            status, comment, id);
        if (r > 0 && "approved".equals(status)) {
            SQLHelper.executeUpdate(
                "UPDATE topics SET selected_count=selected_count+1 WHERE id=?",
                sel.getTopicId());
            bean.Topic updated = topicDao.findById(sel.getTopicId());
            if (updated != null && updated.getSelectedCount() >= updated.getMaxStudents()) {
                SQLHelper.executeUpdate(
                    "UPDATE topics SET status='closed' WHERE id=?", sel.getTopicId());
            }
        }
        return r;
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
}
