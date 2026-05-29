package dao;

import java.util.ArrayList;
import java.util.List;
import bean.Message;
import dbutil.SQLHelper;
import util.DateUtil;
import util.PageUtil;

public class MessageDao {
    private static final String BASE_SQL =
        "SELECT m.id,m.sender_id,m.receiver_id,su.real_name,ru.real_name,"
        + "m.title,m.content,m.is_read,m.created_at "
        + "FROM messages m "
        + "JOIN users su ON m.sender_id=su.id "
        + "JOIN users ru ON m.receiver_id=ru.id ";

    public List<Message> findInbox(int receiverId) {
        return mapList(SQLHelper.queryList(
            BASE_SQL + "WHERE m.receiver_id=? ORDER BY m.created_at DESC", receiverId));
    }

    public List<Message> findInboxPaged(int receiverId, int page, int pageSize) {
        int offset = PageUtil.offset(page, pageSize);
        return mapList(SQLHelper.queryList(
            BASE_SQL + "WHERE m.receiver_id=? ORDER BY m.created_at DESC LIMIT ? OFFSET ?",
            receiverId, pageSize, offset));
    }

    public int countInbox(int receiverId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM messages WHERE receiver_id=?", receiverId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public List<Message> findSent(int senderId) {
        return mapList(SQLHelper.queryList(
            BASE_SQL + "WHERE m.sender_id=? ORDER BY m.created_at DESC", senderId));
    }

    public Message findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(BASE_SQL + "WHERE m.id=?", id);
        return rows.isEmpty() ? null : mapRow(rows.get(0));
    }

    public int countUnread(int receiverId) {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM messages WHERE receiver_id=? AND is_read=0", receiverId);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int insert(Message msg) {
        return SQLHelper.executeInsert(
            "INSERT INTO messages(sender_id,receiver_id,title,content) VALUES(?,?,?,?)",
            msg.getSenderId(), msg.getReceiverId(), msg.getTitle(), msg.getContent());
    }

    public int markRead(int id, int receiverId) {
        return SQLHelper.executeUpdate(
            "UPDATE messages SET is_read=1 WHERE id=? AND receiver_id=?", id, receiverId);
    }

    public int delete(int id, int userId) {
        return SQLHelper.executeUpdate(
            "DELETE FROM messages WHERE id=? AND (sender_id=? OR receiver_id=?)",
            id, userId, userId);
    }

    private List<Message> mapList(List<Object[]> rows) {
        List<Message> list = new ArrayList<Message>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    private Message mapRow(Object[] row) {
        Message m = new Message();
        m.setId(((Number) row[0]).intValue());
        m.setSenderId(((Number) row[1]).intValue());
        m.setReceiverId(((Number) row[2]).intValue());
        m.setSenderName((String) row[3]);
        m.setReceiverName((String) row[4]);
        m.setTitle((String) row[5]);
        m.setContent((String) row[6]);
        m.setIsRead(((Number) row[7]).intValue());
        m.setCreatedAt(DateUtil.toDate(row[8]));
        return m;
    }
}
