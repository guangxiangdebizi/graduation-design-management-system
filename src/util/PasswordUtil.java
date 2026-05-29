package util;

import java.security.MessageDigest;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    public static String hash(String input) {
        return BCrypt.hashpw(input, BCrypt.gensalt());
    }

    public static boolean matches(String plain, String hash) {
        if (plain == null || hash == null) {
            return false;
        }
        if (hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$")) {
            try {
                return BCrypt.checkpw(plain, hash);
            } catch (IllegalArgumentException ex) {
                return false;
            }
        }
        return md5(plain).equals(hash);
    }

    public static String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }
}
