package dao;

import java.util.ArrayList;
import java.util.List;
import bean.DocumentVersion;
import dbutil.SQLHelper;
import util.DateUtil;

public class DocumentVersionDao {
    public List<DocumentVersion> findByDocument(int documentId) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT id,document_id,version_no,title,content,file_path,submit_time "
            + "FROM document_versions WHERE document_id=? ORDER BY version_no DESC",
            documentId);
        List<DocumentVersion> list = new ArrayList<DocumentVersion>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    public int saveVersion(int documentId, String title, String content, String filePath) {
        Object val = SQLHelper.queryScalar(
            "SELECT COALESCE(MAX(version_no),0) FROM document_versions WHERE document_id=?",
            documentId);
        int nextNo = val == null ? 1 : ((Number) val).intValue() + 1;
        return SQLHelper.executeInsert(
            "INSERT INTO document_versions(document_id,version_no,title,content,file_path) VALUES(?,?,?,?,?)",
            documentId, nextNo, title, content, filePath);
    }

    private DocumentVersion mapRow(Object[] row) {
        DocumentVersion v = new DocumentVersion();
        v.setId(((Number) row[0]).intValue());
        v.setDocumentId(((Number) row[1]).intValue());
        v.setVersionNo(((Number) row[2]).intValue());
        v.setTitle((String) row[3]);
        v.setContent((String) row[4]);
        v.setFilePath((String) row[5]);
        v.setSubmitTime(DateUtil.toDate(row[6]));
        return v;
    }
}
