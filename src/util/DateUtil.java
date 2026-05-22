package util;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

public class DateUtil {
    public static Date toDate(Object obj) {
        if (obj == null) {
            return null;
        }
        if (obj instanceof Date) {
            return (Date) obj;
        }
        if (obj instanceof java.sql.Timestamp) {
            return new Date(((java.sql.Timestamp) obj).getTime());
        }
        if (obj instanceof LocalDateTime) {
            return Date.from(((LocalDateTime) obj).atZone(ZoneId.systemDefault()).toInstant());
        }
        return null;
    }
}
