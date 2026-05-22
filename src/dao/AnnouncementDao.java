package dao;

import java.util.ArrayList;
import java.util.List;
import bean.Announcement;
import dbutil.SQLHelper;
import util.DateUtil;

public class AnnouncementDao {
    public List<Announcement> findAll() {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT a.id,a.title,a.content,a.publisher_id,u.real_name,a.is_top,a.created_at "
            + "FROM announcements a JOIN users u ON a.publisher_id=u.id "
            + "ORDER BY a.is_top DESC, a.created_at DESC");
        return mapList(rows);
    }

    public Announcement findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT a.id,a.title,a.content,a.publisher_id,u.real_name,a.is_top,a.created_at "
            + "FROM announcements a JOIN users u ON a.publisher_id=u.id WHERE a.id=?",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public int insert(Announcement a) {
        return SQLHelper.executeInsert(
            "INSERT INTO announcements(title,content,publisher_id,is_top) VALUES(?,?,?,?)",
            a.getTitle(), a.getContent(), a.getPublisherId(), a.getIsTop());
    }

    public int update(Announcement a) {
        return SQLHelper.executeUpdate(
            "UPDATE announcements SET title=?,content=?,is_top=? WHERE id=?",
            a.getTitle(), a.getContent(), a.getIsTop(), a.getId());
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
        a.setIsTop(((Number) row[5]).intValue());
        a.setCreatedAt(DateUtil.toDate(row[6]));
        return a;
    }
}
