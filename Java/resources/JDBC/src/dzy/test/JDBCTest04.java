package dzy.test;

import java.sql.*;
import java.util.ResourceBundle;

public class JDBCTest04 {
    public static void main(String[] args) {
        // 使用资源绑定起
        ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
        Connection conn = null;
        Statement stmt = null;
        try {
            String driver = bundle.getString("driver");
            String url = bundle.getString("url");
            String user = bundle.getString("user");
            String pwd = bundle.getString("password");
            // 注册驱动
            Class.forName(driver);
            // 创建连接
            conn = DriverManager.getConnection(url, user, pwd);
            // 获取数据库操作对象
            stmt = conn.createStatement();
            // 执行sql
            String sql = "insert into dept(deptno, dname, loc) values (79, 'xxii', '湖北')";
            int count = stmt.executeUpdate(sql);
            System.out.println(count == 1 ? "操作成功" : "操作失败");
        }catch (SQLException e) {
            e.printStackTrace();
        }catch (ClassNotFoundException e) {
            e.printStackTrace();
        }finally {
            if (stmt != null) {
                try {
                    stmt.close();
                }catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                }catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
