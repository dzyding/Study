package dzy.test;

import java.sql.*;

public class JDBCTest05 {
    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dzyTest", "root", "Ding52150021");
            stmt = conn.createStatement();
            String sql = "select empno as a, ename, sal from emp";
            // int executeUpdate(insert/delete/update)
            // ResultSet executeQuery(select)
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                // 用下标取值
//                String empno = rs.getString(1);
//                String ename = rs.getString(2);
//                String sal = rs.getString(3);

                // 用 key 取出
                // !!!!! 这里需要写重命名以后的名字
//                String empno = rs.getString("a");
//                String ename = rs.getString("ename");
//                String sal = rs.getString("sal");

                // 用特定的类型取出
                int empno = rs.getInt("a");
                String ename = rs.getString("ename");
                double sal = rs.getDouble("sal");

                System.out.println(empno + "," + ename + "," + sal);
            }
        }catch (Exception e){
            e.printStackTrace();
        }finally {
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
}
