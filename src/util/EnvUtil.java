package util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class EnvUtil {
    private static final Properties DOTENV = loadDotenv();

    public static String get(String key) {
        String value = System.getenv(key);
        if (notBlank(value)) {
            return value.trim();
        }
        value = System.getProperty(key);
        if (notBlank(value)) {
            return value.trim();
        }
        value = DOTENV.getProperty(key);
        return value == null ? null : value.trim();
    }

    public static String get(String key, String defaultValue) {
        String value = get(key);
        return notBlank(value) ? value : defaultValue;
    }

    public static int getInt(String key, int defaultValue) {
        String value = get(key);
        if (!notBlank(value)) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private static Properties loadDotenv() {
        Properties props = new Properties();
        File[] candidates = new File[] {
            new File(System.getProperty("user.dir"), ".env"),
            new File(System.getProperty("user.home"), ".graduation-design.env")
        };
        for (File file : candidates) {
            if (file.isFile()) {
                readFile(file, props);
                break;
            }
        }
        return props;
    }

    private static void readFile(File file, Properties props) {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(
                new FileInputStream(file), StandardCharsets.UTF_8));
            String line;
            while ((line = reader.readLine()) != null) {
                parseLine(line, props);
            }
        } catch (Exception ignored) {
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (Exception ignored) {
                }
            }
        }
    }

    private static void parseLine(String line, Properties props) {
        if (line == null) {
            return;
        }
        String trimmed = line.trim();
        if (trimmed.length() == 0 || trimmed.startsWith("#")) {
            return;
        }
        int idx = trimmed.indexOf('=');
        if (idx <= 0) {
            return;
        }
        String key = trimmed.substring(0, idx).trim();
        String value = trimmed.substring(idx + 1).trim();
        if ((value.startsWith("\"") && value.endsWith("\""))
                || (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length() - 1);
        }
        props.setProperty(key, value);
    }

    private static boolean notBlank(String value) {
        return value != null && value.trim().length() > 0;
    }
}
