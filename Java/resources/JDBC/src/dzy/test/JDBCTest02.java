package dzy.test;

import java.sql.*;
import java.sql.Statement;
import java.sql.Connection;
import java.sql.SQLException;

public class JDBCTest02 {
    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;
        try {
            // 注册驱动
            DriverManager.registerDriver(new com.mysql.cj.jdbc.Driver());
            // 创建连接
            conn = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/dzyTest", "root", "Ding52150021");
            // 获取数据库操作对象
            stmt = conn.createStatement();
            // 执行sql
            String sql = "insert into dept(deptno, dname, loc) values (77, '隋东风', '湖北')";
            int count = stmt.executeUpdate(sql);
            System.out.println(count == 1 ? "操作成功" : "操作失败");
        }catch (SQLException e) {
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
