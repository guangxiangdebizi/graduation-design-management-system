package dao;

import java.util.ArrayList;
import java.util.List;
import bean.OperationLog;
import dbutil.SQLHelper;
import util.DateUtil;
import util.PageUtil;

public class OperationLogDao {
    private static final String BASE_SQL =
        "SELECT l.id,l.user_id,u.username,u.real_name,l.action,l.target,l.detail,l.created_at "
        + "FROM operation_logs l LEFT JOIN users u ON l.user_id=u.id ";

    public int insert(Integer userId, String action, String target, String detail) {
        return SQLHelper.executeInsert(
            "INSERT INTO operation_logs(user_id,action,target,detail) VALUES(?,?,?,?)",
            userId, action, target, detail);
    }

    public List<OperationLog> findRecent(int limit) {
        String sql = BASE_SQL + "ORDER BY l.created_at DESC LIMIT ?";
        return mapList(SQLHelper.queryList(sql, limit));
    }

    public List<OperationLog> findFiltered(Integer userId, String action, String dateFrom,
            String dateTo, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(BASE_SQL + "WHERE 1=1");
        List<Object> params = new ArrayList<Object>();
        appendFilters(sql, params, userId, action, dateFrom, dateTo);
        sql.append(" ORDER BY l.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(PageUtil.offset(page, pageSize));
        return mapList(SQLHelper.queryList(sql.toString(), params.toArray()));
    }

    public int countFiltered(Integer userId, String action, String dateFrom, String dateTo) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM operation_logs l WHERE 1=1");
        List<Object> params = new ArrayList<Object>();
        appendFilters(sql, params, userId, action, dateFrom, dateTo);
        Object val = SQLHelper.queryScalar(sql.toString(), params.toArray());
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countAll() {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM operation_logs");
        return val == null ? 0 : ((Number) val).intValue();
    }

    private void appendFilters(StringBuilder sql, List<Object> params,
            Integer userId, String action, String dateFrom, String dateTo) {
        if (userId != null) {
            sql.append(" AND l.user_id=?");
            params.add(userId);
        }
        if (action != null && action.length() > 0) {
            sql.append(" AND l.action=?");
            params.add(action);
        }
        if (dateFrom != null && dateFrom.length() > 0) {
            sql.append(" AND l.created_at>=?");
            params.add(dateFrom);
        }
        if (dateTo != null && dateTo.length() > 0) {
            sql.append(" AND l.created_at<=?");
            params.add(dateTo + " 23:59:59");
        }
    }

    private List<OperationLog> mapList(List<Object[]> rows) {
        List<OperationLog> list = new ArrayList<OperationLog>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private OperationLog mapRow(Object[] row) {
        OperationLog log = new OperationLog();
        log.setId(((Number) row[0]).intValue());
        log.setUserId(row[1] == null ? null : ((Number) row[1]).intValue());
        log.setUsername((String) row[2]);
        log.setRealName((String) row[3]);
        log.setAction((String) row[4]);
        log.setTarget((String) row[5]);
        log.setDetail((String) row[6]);
        log.setCreatedAt(DateUtil.toDate(row[7]));
        return log;
    }
}
