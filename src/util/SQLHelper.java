package util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.sql.DataSource;
import com.alibaba.druid.pool.DruidDataSourceFactory;

public class SQLHelper {
    private static final DataSource dataSource;

    static {
        try {
            Properties props = loadProperties();
            dataSource = DruidDataSourceFactory.createDataSource(props);
            System.out.println("[SQLHelper] Druid 连接池初始化成功");
        } catch (Exception e) {
            System.err.println("[SQLHelper] Druid 连接池初始化失败: " + e.getMessage());
            throw new RuntimeException("数据库连接池初始化失败", e);
        }
    }

    private static Properties loadProperties() {
        Properties props = new Properties();
        InputStream in = SQLHelper.class.getClassLoader().getResourceAsStream("jdbc.properties");
        if (in != null) {
            try {
                props.load(in);
            } catch (IOException e) {
                System.err.println("[SQLHelper] 加载 jdbc.properties 失败");
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
        return dataSource.getConnection();
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
            System.err.println("[SQLHelper] SQL 查询失败: " + sql);
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
            System.err.println("[SQLHelper] SQL 更新失败: " + sql);
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
            System.err.println("[SQLHelper] SQL 标量查询失败: " + sql);
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
            System.err.println("[SQLHelper] SQL 插入失败: " + sql);
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
            if (rs != null) rs.close();
        } catch (SQLException ignored) {}
        try {
            if (ps != null) ps.close();
        } catch (SQLException ignored) {}
        try {
            if (conn != null) conn.close();
        } catch (SQLException ignored) {}
    }
}
