package dao;

import java.util.ArrayList;
import java.util.List;
import bean.Announcement;
import dbutil.SQLHelper;
import util.CollegeUtil;
import util.DateUtil;

public class AnnouncementDao {
    private static final String SELECT_COLS =
        "a.id,a.title,a.content,a.publisher_id,u.real_name,u.role,a.is_top,"
        + "COALESCE(a.scope_type,'global'),a.college,a.major,a.created_at ";
    private static final String FROM_SQL =
        "FROM announcements a JOIN users u ON a.publisher_id=u.id ";

    public List<Announcement> findAll() {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + FROM_SQL
            + "ORDER BY a.is_top DESC, a.created_at DESC");
        return mapList(rows);
    }

    public List<Announcement> findVisible(String college, String major) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + FROM_SQL
            + "WHERE COALESCE(a.scope_type,'global')='global' "
            + "OR (a.scope_type='college' AND a.college=?) "
            + "OR (a.scope_type='major' AND a.college=? AND a.major=?) "
            + "ORDER BY a.is_top DESC, a.created_at DESC",
            college, college, major);
        return mapList(rows);
    }

    public Announcement findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + FROM_SQL + "WHERE a.id=?",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public int insert(Announcement a) {
        return SQLHelper.executeInsert(
            "INSERT INTO announcements(title,content,publisher_id,is_top,scope_type,college,major) "
            + "VALUES(?,?,?,?,?,?,?)",
            a.getTitle(), a.getContent(), a.getPublisherId(), a.getIsTop(),
            a.getScopeType(), a.getCollege(), a.getMajor());
    }

    public int update(Announcement a) {
        return SQLHelper.executeUpdate(
            "UPDATE announcements SET title=?,content=?,is_top=?,scope_type=?,college=?,major=? WHERE id=?",
            a.getTitle(), a.getContent(), a.getIsTop(), a.getScopeType(),
            a.getCollege(), a.getMajor(), a.getId());
    }

    public int delete(int id) {
        return SQLHelper.executeUpdate("DELETE FROM announcements WHERE id=?", id);
    }

    public int countAll() {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM announcements");
        return val == null ? 0 : ((Number) val).intValue();
    }

    private List<Announcement> mapList(List<Object[]> rows) {
        List<Announcement> list = new ArrayList<Announcement>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private Announcement mapRow(Object[] row) {
        Announcement a = new Announcement();
        a.setId(((Number) row[0]).intValue());
        a.setTitle((String) row[1]);
        a.setContent((String) row[2]);
        a.setPublisherId(((Number) row[3]).intValue());
        a.setPublisherName((String) row[4]);
        a.setPublisherRole((String) row[5]);
        a.setIsTop(((Number) row[6]).intValue());
        a.setScopeType((String) row[7]);
        a.setCollege((String) row[8]);
        a.setMajor((String) row[9]);
        if (a.getCollege() != null) {
            a.setCollegeName(CollegeUtil.getCollegeName(a.getCollege()));
        }
        if (a.getCollege() != null && a.getMajor() != null) {
            a.setMajorName(CollegeUtil.getMajorName(a.getCollege(), a.getMajor()));
        }
        a.setCreatedAt(DateUtil.toDate(row[10]));
        return a;
    }
}
