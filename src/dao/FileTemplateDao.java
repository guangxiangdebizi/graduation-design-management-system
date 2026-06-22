package dao;

import java.util.ArrayList;
import java.util.List;
import bean.FileTemplate;
import dbutil.SQLHelper;
import util.DateUtil;
import util.DictionaryUtil;

public class FileTemplateDao {
    private static final String BASE_SQL =
        "SELECT f.id,f.template_name,f.doc_type,f.description,f.file_path,"
        + "f.original_filename,f.file_size,f.uploader_id,u.real_name,f.status,f.created_at "
        + "FROM file_templates f JOIN users u ON f.uploader_id=u.id ";

    public List<FileTemplate> findAll(String type, boolean onlyEnabled) {
        return findAllInternal(type, onlyEnabled, 0, 0);
    }

    public List<FileTemplate> findAll(String type, int page, int pageSize) {
        return findAllInternal(type, true, page, pageSize);
    }

    public int countAll(String type) {
        String sql = "SELECT COUNT(*) FROM file_templates WHERE status=1";
        List<Object> params = new ArrayList<Object>();
        if (type != null && !type.trim().isEmpty()) {
            sql += " AND doc_type=?";
            params.add(type.trim());
        }
        Object val = params.isEmpty()
            ? SQLHelper.queryScalar(sql)
            : SQLHelper.queryScalar(sql, params.toArray());
        return val == null ? 0 : ((Number) val).intValue();
    }

    private List<FileTemplate> findAllInternal(String type, boolean onlyEnabled,
            int page, int pageSize) {
        String sql = BASE_SQL + "WHERE 1=1";
        List<Object> params = new ArrayList<Object>();
        if (type != null && !type.trim().isEmpty()) {
            sql += " AND f.doc_type=?";
            params.add(type.trim());
        }
        if (onlyEnabled) {
            sql += " AND f.status=1";
        }
        sql += " ORDER BY f.created_at DESC,f.id DESC";
        if (page > 0 && pageSize > 0) {
            sql += " LIMIT ? OFFSET ?";
            params.add(pageSize);
            params.add((page - 1) * pageSize);
        }
        List<Object[]> rows = params.isEmpty()
            ? SQLHelper.queryList(sql)
            : SQLHelper.queryList(sql, params.toArray());
        return mapList(rows);
    }

    public FileTemplate findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(BASE_SQL + "WHERE f.id=?", id);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public FileTemplate findByPath(String path) {
        List<Object[]> rows = SQLHelper.queryList(BASE_SQL + "WHERE f.file_path=?", path);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public int insert(FileTemplate template) {
        return SQLHelper.executeInsert(
            "INSERT INTO file_templates(template_name,doc_type,description,file_path,"
            + "original_filename,file_size,uploader_id,status) VALUES(?,?,?,?,?,?,?,1)",
            template.getTemplateName(), template.getDocType(), template.getDescription(),
            template.getFilePath(), template.getOriginalFilename(), template.getFileSize(),
            template.getUploaderId());
    }

    public int delete(int id) {
        return SQLHelper.executeUpdate("DELETE FROM file_templates WHERE id=?", id);
    }

    public int updateStatus(int id, int status) {
        return SQLHelper.executeUpdate(
            "UPDATE file_templates SET status=? WHERE id=?", status, id);
    }

    private List<FileTemplate> mapList(List<Object[]> rows) {
        List<FileTemplate> list = new ArrayList<FileTemplate>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private FileTemplate mapRow(Object[] row) {
        FileTemplate f = new FileTemplate();
        f.setId(((Number) row[0]).intValue());
        f.setTemplateName((String) row[1]);
        f.setDocType((String) row[2]);
        f.setDescription((String) row[3]);
        f.setTypeName(f.getDocType() == null ? "通用" : DictionaryUtil.label("document_type", f.getDocType()));
        f.setFilePath((String) row[4]);
        f.setOriginalFilename((String) row[5]);
        f.setFileSize(row[6] == null ? 0L : ((Number) row[6]).longValue());
        f.setUploaderId(((Number) row[7]).intValue());
        f.setUploaderName((String) row[8]);
        f.setStatus(((Number) row[9]).intValue());
        f.setCreatedAt(DateUtil.toDate(row[10]));
        return f;
    }
}
