package util;

import dao.OperationLogDao;

public class OperationLogUtil {
    public static void log(Integer userId, String action, String target, String detail) {
        try {
            new OperationLogDao().insert(userId, action, target, detail);
        } catch (Exception ignored) {
        }
    }
}
