package dao;

import java.util.List;
import bean.TopicAssignment;
import util.DateUtil;
import util.SQLHelper;

public class TopicAssignmentDao {
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

    public TopicAssignment findByTopic(int topicId) {
        List<Object[]> rows = SQLHelper.queryList(
            SELECT_SQL + "WHERE a.topic_id=? LIMIT 1", topicId);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
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
}

