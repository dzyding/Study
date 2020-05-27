package dzy.test.utils;

import java.sql.*;
import java.util.ResourceBundle;

public class DBUtil {
    /**
     * 工具类的构造方法都是私有的。
     * 因为工具类当中的方法都是静态的，不需要 new 对象，直接才用类名调用
     */
    private DBUtil() {}

    // 包名
    private static ResourceBundle bundle = ResourceBundle.getBundle("jdbc");

    // 静态代码块在类加载时执行，并且只执行一次
    static {
        String sqlDriver = bundle.getString("driver");
        try {
            Class.forName(sqlDriver);
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 获取数据库连接对象
     */
    public static Connection getConnection() throws SQLException {
        String sqlUrl = bundle.getString("url");
        String sqlUser = bundle.getString("user");
        String sqlPwd = bundle.getString("password");
        return DriverManager.getConnection(sqlUrl, sqlUser, sqlPwd);
    }

    /**
     * 关闭
     * @param conn 数据库链接对象
     * @param stmt 数据库操作对象
     * @param rs   数据库结果集
     */
    public static void close(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            }catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            }catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (conn != null) {
            try {
                conn.close();
            }catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
