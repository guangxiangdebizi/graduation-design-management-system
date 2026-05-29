package dbutil;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class SQLHelper {
    private static final String DEFAULT_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String DEFAULT_URL =
        "jdbc:mysql://127.0.0.1:3306/graduation_design?useSSL=false&allowPublicKeyRetrieval=true"
        + "&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8&connectionCollation=utf8mb4_unicode_ci";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PWD = "12345";

    private static final String DRIVER;
    private static final String URL;
    private static final String DB_USER;
    private static final String DB_PWD;

    static {
        Properties props = loadProperties();
        DRIVER = props.getProperty("jdbc.driver", DEFAULT_DRIVER);
        URL = props.getProperty("jdbc.url", DEFAULT_URL);
        DB_USER = props.getProperty("jdbc.username", DEFAULT_USER);
        DB_PWD = props.getProperty("jdbc.password", DEFAULT_PWD);
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static Properties loadProperties() {
        Properties props = new Properties();
        InputStream in = SQLHelper.class.getClassLoader().getResourceAsStream("jdbc.properties");
        if (in != null) {
            try {
                props.load(in);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                try {
                    in.close();
                } catch (IOException ignored) {
                }
            }
        }
        return props;
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, DB_USER, DB_PWD);
    }

    public static List<Object[]> queryList(String sql, Object... params) {
        List<Object[]> list = new ArrayList<Object[]>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params);
            rs = ps.executeQuery();
            int colCount = rs.getMetaData().getColumnCount();
            while (rs.next()) {
                Object[] row = new Object[colCount];
                for (int i = 0; i < colCount; i++) {
                    row[i] = rs.getObject(i + 1);
                }
                list.add(row);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return list;
    }

    public static int executeUpdate(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params);
            return ps.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
            return 0;
        } finally {
            closeQuietly(null, ps, conn);
        }
    }

    public static Object queryScalar(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getObject(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return null;
    }

    public static int executeInsert(String sql, Object... params) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            bindParams(ps, params);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            closeQuietly(rs, ps, conn);
        }
        return 0;
    }

    private static void bindParams(PreparedStatement ps, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }

    private static void closeQuietly(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null) {
                rs.close();
            }
        } catch (SQLException ignored) {
        }
        try {
            if (ps != null) {
                ps.close();
            }
        } catch (SQLException ignored) {
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException ignored) {
        }
    }
}
