package dao;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import bean.Document;
import dbutil.SQLHelper;
import util.DateUtil;
import util.PageUtil;

public class DocumentDao {
    private static final String BASE_SQL =
        "SELECT d.id,d.student_id,d.topic_id,d.doc_type,d.title,d.content,d.file_path,d.status,d.score,"
        + "d.feedback,d.submit_time,d.review_time,d.reviewer_id,u.real_name,u.student_no,t.title "
        + "FROM documents d "
        + "JOIN users u ON d.student_id=u.id "
        + "JOIN topics t ON d.topic_id=t.id ";

    public List<Document> findByStudent(int studentId) {
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.student_id=? ORDER BY d.doc_type", studentId);
        return mapList(rows);
    }

    public List<Document> findByStudentPaged(int studentId, int page, int pageSize) {
        int offset = PageUtil.offset(page, pageSize);
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.student_id=? ORDER BY d.doc_type LIMIT ? OFFSET ?",
            studentId, pageSize, offset);
        return mapList(rows);
    }

    public int countByStudent(int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents WHERE student_id=?", studentId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public List<Document> findByTeacher(int teacherId, String docType, String status) {
        String sql = BASE_SQL + "WHERE t.teacher_id=?";
        List<Object> params = new ArrayList<Object>();
        params.add(teacherId);
        if (docType != null && docType.length() > 0) {
            sql += " AND d.doc_type=?";
            params.add(docType);
        }
        if (status != null && status.length() > 0) {
            sql += " AND d.status=?";
            params.add(status);
        }
        sql += " ORDER BY d.submit_time DESC";
        List<Object[]> rows = SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public List<Document> findByTeacherPaged(int teacherId, String docType, String status,
            int page, int pageSize) {
        String sql = BASE_SQL + "WHERE t.teacher_id=?";
        List<Object> params = new ArrayList<Object>();
        params.add(teacherId);
        if (docType != null && docType.length() > 0) {
            sql += " AND d.doc_type=?";
            params.add(docType);
        }
        if (status != null && status.length() > 0) {
            sql += " AND d.status=?";
            params.add(status);
        }
        sql += " ORDER BY d.submit_time DESC LIMIT ? OFFSET ?";
        params.add(pageSize);
        params.add(PageUtil.offset(page, pageSize));
        List<Object[]> rows = SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public int countByTeacher(int teacherId, String docType, String status) {
        String sql = "SELECT COUNT(*) FROM documents d JOIN topics t ON d.topic_id=t.id WHERE t.teacher_id=?";
        List<Object> params = new ArrayList<Object>();
        params.add(teacherId);
        if (docType != null && docType.length() > 0) {
            sql += " AND d.doc_type=?";
            params.add(docType);
        }
        if (status != null && status.length() > 0) {
            sql += " AND d.status=?";
            params.add(status);
        }
        Object val = SQLHelper.queryScalar(sql, params.toArray());
        return val == null ? 0 : ((Number) val).intValue();
    }

    public Document findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(BASE_SQL + "WHERE d.id=?", id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public Document findByStudentAndType(int studentId, String docType) {
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.student_id=? AND d.doc_type=?", studentId, docType);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public int submit(Document doc) {
        DocumentVersionDao versionDao = new DocumentVersionDao();
        Document existing = findByStudentAndType(doc.getStudentId(), doc.getDocType());
        if (existing != null) {
            versionDao.saveVersion(existing.getId(), existing.getTitle(),
                existing.getContent(), existing.getFilePath());
            return SQLHelper.executeUpdate(
                "UPDATE documents SET title=?,content=?,file_path=?,status='submitted',submit_time=NOW() WHERE id=?",
                doc.getTitle(), doc.getContent(), doc.getFilePath(), existing.getId());
        }
        return SQLHelper.executeInsert(
            "INSERT INTO documents(student_id,topic_id,doc_type,title,content,file_path,status,submit_time) "
            + "VALUES(?,?,?,?,?,?,'submitted',NOW())",
            doc.getStudentId(), doc.getTopicId(), doc.getDocType(),
            doc.getTitle(), doc.getContent(), doc.getFilePath());
    }

    public int review(int id, int teacherId, String status, BigDecimal score, String feedback) {
        Document doc = findById(id);
        if (doc == null) {
            return 0;
        }
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT teacher_id FROM topics WHERE id=?", doc.getTopicId());
        if (rows.isEmpty()) {
            return 0;
        }
        int tid = ((Number) rows.get(0)[0]).intValue();
        if (tid != teacherId) {
            return 0;
        }
        return SQLHelper.executeUpdate(
            "UPDATE documents SET status=?,score=?,feedback=?,review_time=NOW(),reviewer_id=? WHERE id=?",
            status, score, feedback, teacherId, id);
    }

    public int countPendingByTeacher(int teacherId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents d JOIN topics t ON d.topic_id=t.id "
            + "WHERE t.teacher_id=? AND d.status='submitted'",
            teacherId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    private List<Document> mapList(List<Object[]> rows) {
        List<Document> list = new ArrayList<Document>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private Document mapRow(Object[] row) {
        Document d = new Document();
        d.setId(((Number) row[0]).intValue());
        d.setStudentId(((Number) row[1]).intValue());
        d.setTopicId(((Number) row[2]).intValue());
        d.setDocType((String) row[3]);
        d.setTitle((String) row[4]);
        d.setContent((String) row[5]);
        d.setFilePath((String) row[6]);
        d.setStatus((String) row[7]);
        d.setScore(row[8] == null ? null : new BigDecimal(row[8].toString()));
        d.setFeedback((String) row[9]);
        d.setSubmitTime(DateUtil.toDate(row[10]));
        d.setReviewTime(DateUtil.toDate(row[11]));
        d.setReviewerId(row[12] == null ? null : ((Number) row[12]).intValue());
        d.setStudentName((String) row[13]);
        d.setStudentNo((String) row[14]);
        d.setTopicTitle((String) row[15]);
        return d;
    }
}
