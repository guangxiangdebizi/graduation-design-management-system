package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import bean.Document;
import util.SQLHelper;
import util.DateUtil;
import util.PageUtil;

public class DocumentDao {
    private static final String BASE_SQL =
        "SELECT d.id,d.student_id,d.topic_id,d.doc_type,d.title,d.content,d.file_path,d.status,d.score,"
        + "d.feedback,d.submit_time,d.review_time,d.reviewer_id,u.real_name,u.student_no,t.title,"
        + "d.self_review,d.peer_review,d.advisor_score,d.advisor_comment,d.paper_reviewer_id,"
        + "pr.real_name,d.reviewer_score,d.reviewer_comment,d.reviewer_review_time,"
        + "t.teacher_id,teacher.real_name "
        + "FROM documents d "
        + "JOIN users u ON d.student_id=u.id "
        + "JOIN topics t ON d.topic_id=t.id "
        + "JOIN users teacher ON t.teacher_id=teacher.id "
        + "LEFT JOIN users pr ON d.paper_reviewer_id=pr.id ";

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
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM ("
                    + "SELECT student_id,topic_id FROM topic_assignments "
                    + "UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
                    + ") x WHERE student_id=? AND topic_id=?")) {
                ps.setInt(1, doc.getStudentId());
                ps.setInt(2, doc.getTopicId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            String prerequisite = prerequisiteType(doc.getDocType());
            if (prerequisite != null) {
                Object passed = queryScalar(conn,
                    "SELECT COUNT(*) FROM documents WHERE student_id=? AND doc_type=? AND status='reviewed'",
                    doc.getStudentId(), prerequisite);
                if (passed == null || ((Number) passed).intValue() == 0) {
                    conn.rollback();
                    return -2;
                }
            }

            int existingId = 0;
            String existingStatus = null;
            String oldTitle = null;
            String oldContent = null;
            String oldFilePath = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id,status,title,content,file_path,topic_id FROM documents "
                    + "WHERE student_id=? AND doc_type=? FOR UPDATE")) {
                ps.setInt(1, doc.getStudentId());
                ps.setString(2, doc.getDocType());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt(1);
                        existingStatus = rs.getString(2);
                        oldTitle = rs.getString(3);
                        oldContent = rs.getString(4);
                        oldFilePath = rs.getString(5);
                        if (rs.getInt(6) != doc.getTopicId()) {
                            conn.rollback();
                            return -1;
                        }
                    }
                }
            }

            int result;
            if (existingId > 0) {
                if (!"rejected".equals(existingStatus)) {
                    conn.rollback();
                    return -3;
                }
                saveVersion(conn, existingId, oldTitle, oldContent, oldFilePath);
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE documents SET title=?,content=?,file_path=?,status='submitted',"
                        + "score=NULL,feedback=NULL,self_review=NULL,peer_review=NULL,"
                        + "advisor_score=NULL,advisor_comment=NULL,"
                        + "reviewer_score=NULL,reviewer_comment=NULL,reviewer_review_time=NULL,"
                        + "review_time=NULL,reviewer_id=NULL,submit_time=NOW() "
                        + "WHERE id=? AND status='rejected'")) {
                    ps.setString(1, doc.getTitle());
                    ps.setString(2, doc.getContent());
                    ps.setString(3, doc.getFilePath());
                    ps.setInt(4, existingId);
                    result = ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO documents(student_id,topic_id,doc_type,title,content,file_path,"
                        + "status,submit_time) VALUES(?,?,?,?,?,?,'submitted',NOW())")) {
                    ps.setInt(1, doc.getStudentId());
                    ps.setInt(2, doc.getTopicId());
                    ps.setString(3, doc.getDocType());
                    ps.setString(4, doc.getTitle());
                    ps.setString(5, doc.getContent());
                    ps.setString(6, doc.getFilePath());
                    result = ps.executeUpdate();
                }
            }
            conn.commit();
            return result;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public int review(int id, int teacherId, String status, BigDecimal advisorScore,
            String feedback) {
        if (!"reviewed".equals(status) && !"rejected".equals(status)) {
            return 0;
        }
        boolean finalDoc = isFinalDoc(id);
        if ("reviewed".equals(status) && finalDoc
                && (advisorScore == null || !validScore(advisorScore))) {
            return 0;
        }
        String advisorComment = finalDoc && "reviewed".equals(status) ? feedback : null;
        if (!finalDoc) {
            advisorScore = null;
        }
        if ("rejected".equals(status)) {
            advisorScore = null;
            advisorComment = null;
        }
        return SQLHelper.executeUpdate(
            "UPDATE documents d JOIN topics t ON d.topic_id=t.id "
            + "SET d.status=?,d.score=?,d.feedback=?,"
            + "d.advisor_score=?,d.advisor_comment=?,d.self_review=?,"
            + "d.review_time=NOW(),d.reviewer_id=? "
            + "WHERE d.id=? AND d.status='submitted' AND t.teacher_id=?",
            status, advisorScore, feedback, advisorScore, advisorComment,
            advisorComment, teacherId, id, teacherId);
    }

    public List<Document> findFinalsForPaperReview(int reviewerId) {
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.doc_type='final' AND d.status='reviewed' "
            + "AND d.paper_reviewer_id=? ORDER BY "
            + "CASE WHEN d.reviewer_score IS NULL THEN 0 ELSE 1 END,d.submit_time DESC",
            reviewerId);
        return mapList(rows);
    }

    public int countPendingPaperReview(int reviewerId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents WHERE doc_type='final' AND status='reviewed' "
            + "AND paper_reviewer_id=? AND reviewer_score IS NULL",
            reviewerId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int submitPaperReview(int documentId, int reviewerId, BigDecimal score,
            String comment) {
        if (!validScore(score)) {
            return 0;
        }
        return SQLHelper.executeUpdate(
            "UPDATE documents SET reviewer_score=?,reviewer_comment=?,"
            + "peer_review=?,reviewer_review_time=NOW() "
            + "WHERE id=? AND doc_type='final' AND status='reviewed' "
            + "AND paper_reviewer_id=?",
            score, comment, comment, documentId, reviewerId);
    }

    public int arrangePaperReviewer(int documentId, int paperReviewerId, int directorId,
            String college, String major) {
        if (directorId <= 0) {
            return 0;
        }
        Connection conn = null;
        try {
            conn = SQLHelper.getConnection();
            conn.setAutoCommit(false);

            int supervisorId = 0;
            int studentId = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT d.student_id,t.teacher_id FROM documents d "
                    + "JOIN users u ON d.student_id=u.id "
                    + "JOIN topics t ON d.topic_id=t.id "
                    + "WHERE d.id=? AND d.doc_type='final' AND d.status='reviewed' "
                    + "AND u.role='student' AND u.status=1 "
                    + "AND u.college=? AND u.major=? AND t.college=? AND t.major=? "
                    + "FOR UPDATE")) {
                ps.setInt(1, documentId);
                ps.setString(2, college);
                ps.setString(3, major);
                ps.setString(4, college);
                ps.setString(5, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        studentId = rs.getInt(1);
                        supervisorId = rs.getInt(2);
                    }
                }
            }
            if (studentId <= 0 || supervisorId == paperReviewerId) {
                conn.rollback();
                return 0;
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM users WHERE id=? AND role IN ('teacher','director') "
                    + "AND status=1 AND college=? AND major=? LIMIT 1")) {
                ps.setInt(1, paperReviewerId);
                ps.setString(2, college);
                ps.setString(3, major);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return 0;
                    }
                }
            }

            int updated;
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE documents SET paper_reviewer_id=?,reviewer_score=NULL,"
                    + "reviewer_comment=NULL,peer_review=NULL,reviewer_review_time=NULL "
                    + "WHERE id=?")) {
                ps.setInt(1, paperReviewerId);
                ps.setInt(2, documentId);
                updated = ps.executeUpdate();
            }
            conn.commit();
            return updated;
        } catch (Exception ex) {
            rollbackQuietly(conn);
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(conn);
        }
    }

    public List<Document> findFinalsForReviewerArrangement(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            BASE_SQL + "WHERE d.doc_type='final' AND d.status='reviewed' "
            + "AND u.role='student' AND u.status=1 "
            + "AND u.college=? AND u.major=? AND t.college=? AND t.major=? "
            + "ORDER BY CASE WHEN d.paper_reviewer_id IS NULL THEN 0 ELSE 1 END,"
            + "u.student_no,u.id",
            college, major, college, major);
        return mapList(rows);
    }

    public List<bean.User> findPaperReviewerCandidates(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT id,username,role,real_name,title,college,major,status "
            + "FROM users WHERE role IN ('teacher','director') AND status=1 "
            + "AND college=? AND major=? ORDER BY role,real_name,id",
            college, major);
        List<bean.User> list = new ArrayList<bean.User>();
        for (Object[] row : rows) {
            bean.User u = new bean.User();
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

    private boolean validScore(BigDecimal score) {
        return score != null && score.compareTo(BigDecimal.ZERO) >= 0
            && score.compareTo(new BigDecimal("100")) <= 0;
    }

    public boolean isStageAvailable(int studentId, String docType) {
        String prerequisite = prerequisiteType(docType);
        if (prerequisite == null) {
            return true;
        }
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents WHERE student_id=? AND doc_type=? AND status='reviewed'",
            studentId, prerequisite);
        return val != null && ((Number) val).intValue() > 0;
    }

    private String prerequisiteType(String docType) {
        if ("proposal".equals(docType)) return null;
        if ("midterm".equals(docType)) return "proposal";
        if ("final".equals(docType)) return "midterm";
        throw new IllegalArgumentException("invalid document type");
    }

    private Object queryScalar(Connection conn, String sql, Object... params) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getObject(1) : null;
            }
        }
    }

    private boolean isFinalDoc(int id) {
        Object val = SQLHelper.queryScalar("SELECT doc_type FROM documents WHERE id=?", id);
        return "final".equals(val == null ? null : String.valueOf(val));
    }

    private void saveVersion(Connection conn, int documentId, String title,
            String content, String filePath) throws Exception {
        int nextNo = ((Number) queryScalar(conn,
            "SELECT COALESCE(MAX(version_no),0)+1 FROM document_versions "
            + "WHERE document_id=? FOR UPDATE", documentId)).intValue();
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO document_versions(document_id,version_no,title,content,file_path) "
                + "VALUES(?,?,?,?,?)")) {
            ps.setInt(1, documentId);
            ps.setInt(2, nextNo);
            ps.setString(3, title);
            ps.setString(4, content);
            ps.setString(5, filePath);
            ps.executeUpdate();
        }
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

    public int countPendingByTeacher(int teacherId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM documents d JOIN topics t ON d.topic_id=t.id "
            + "WHERE t.teacher_id=? AND d.status='submitted'",
            teacherId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public List<Object[]> findProgressByScope(String college, String major) {
        return SQLHelper.queryList(
            "SELECT u.student_no,u.real_name,u.class_name,t.title,teacher.real_name,"
            + "p.status,p.submit_time,p.review_time,"
            + "m.status,m.submit_time,m.review_time,"
            + "f.status,f.advisor_score,f.submit_time,f.review_time,"
            + "pr.real_name,f.reviewer_score,f.reviewer_review_time "
            + "FROM users u "
            + "JOIN ("
            + "  SELECT student_id,topic_id FROM topic_assignments "
            + "  UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
            + ") sel ON sel.student_id=u.id "
            + "JOIN topics t ON sel.topic_id=t.id "
            + "JOIN users teacher ON t.teacher_id=teacher.id "
            + "LEFT JOIN documents p ON p.student_id=u.id AND p.doc_type='proposal' "
            + "LEFT JOIN documents m ON m.student_id=u.id AND m.doc_type='midterm' "
            + "LEFT JOIN documents f ON f.student_id=u.id AND f.doc_type='final' "
            + "LEFT JOIN users pr ON f.paper_reviewer_id=pr.id "
            + "WHERE u.role='student' AND u.college=? AND u.major=? "
            + "AND t.college=? AND t.major=? "
            + "ORDER BY u.student_no",
            college, major, college, major);
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
        d.setSelfReview(row.length > 16 ? (String) row[16] : null);
        d.setPeerReview(row.length > 17 ? (String) row[17] : null);
        d.setAdvisorScore(row.length > 18 && row[18] != null
            ? new BigDecimal(row[18].toString()) : d.getScore());
        d.setAdvisorComment(row.length > 19 ? (String) row[19] : d.getFeedback());
        d.setPaperReviewerId(row.length > 20 && row[20] != null
            ? ((Number) row[20]).intValue() : null);
        d.setPaperReviewerName(row.length > 21 ? (String) row[21] : null);
        d.setReviewerScore(row.length > 22 && row[22] != null
            ? new BigDecimal(row[22].toString()) : null);
        d.setReviewerComment(row.length > 23 ? (String) row[23] : null);
        d.setReviewerReviewTime(row.length > 24 ? DateUtil.toDate(row[24]) : null);
        d.setTeacherId(row.length > 25 && row[25] != null
            ? ((Number) row[25]).intValue() : null);
        d.setTeacherName(row.length > 26 ? (String) row[26] : null);
        return d;
    }
}
