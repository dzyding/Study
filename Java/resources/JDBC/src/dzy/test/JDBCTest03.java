package dzy.test;

import java.sql.*;
import java.sql.Connection;
import java.sql.SQLException;

public class JDBCTest03 {
    public static void main(String[] args) {
        try {
            // 注册驱动的第一种写法
            DriverManager.registerDriver(new com.mysql.cj.jdbc.Driver());
            // 第二种方式：常用的
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/dzyTest", "root", "Ding52150021");
            System.out.println(conn);

        }catch (SQLException e) {
            e.printStackTrace();
        }catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
     }
}
