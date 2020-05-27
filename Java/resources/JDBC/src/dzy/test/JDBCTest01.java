package dzy.test;

import java.sql.*;
import java.sql.Connection;
import java.sql.Statement;

public class JDBCTest01 {
    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;
        try {
            // 1. 注册驱动
            java.sql.Driver dirver = new com.mysql.cj.jdbc.Driver();
            DriverManager.registerDriver(dirver);

            // 2. 获取连接
            /*
                url：统一资源定位符（网络中某个资源的绝对路径）
                jdbc:mysql:// 协议
             */
            String url = "jdbc:mysql://127.0.0.1:3306/dzyTest";
            String user = "root";
            String pwd = "Ding52150021";
            conn = DriverManager.getConnection(url, user, pwd);
            System.out.println("数据库连接对象 = " + conn);

            // 3. 获取数据库操作对象
            stmt = conn.createStatement();

            // 4. 执行 sql
            String sql = "insert into dept(deptno, dname, loc) values(50, '人事部', '北京')";
            // 这条语句是专门执行 DML 语句的 (insert delete update)
            // 返回数据是 "影响数据库中的记录条数"
            int count = stmt.executeUpdate(sql);
            System.out.println(count == 1 ? "保存成功" : "保存失败");

            // 5.
        }catch(SQLException e) {
            e.printStackTrace();
        }finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
            }catch (SQLException e) {
                e.printStackTrace();
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            }catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}