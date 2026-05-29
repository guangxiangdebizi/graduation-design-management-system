package util;

import bean.Message;
import dao.MessageDao;

public class MessageNotifyUtil {
    public static void send(int userId, String title, String content) {
        try {
            Message msg = new Message();
            msg.setSenderId(1);
            msg.setReceiverId(userId);
            msg.setTitle(title);
            msg.setContent(content);
            new MessageDao().insert(msg);
        } catch (Exception ignored) {
        }
    }
}
