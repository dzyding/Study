package dzy.test;

import java.sql.*;
import java.util.ResourceBundle;

public class JDBCTest06 {
    public static void main(String[] args) {
        Connection conn = null;
        // 处理 sql 注入的主力，预编译数据库操作对象
        PreparedStatement ps = null;
        ResultSet rs = null;
        ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
        try {
            // 读取资源文件
            String sqlDriver = bundle.getString("driver");
            String sqlUrl = bundle.getString("url");
            String sqlUser = bundle.getString("user");
            String sqlPwd = bundle.getString("password");
            // 创建连接
            Class.forName(sqlDriver);
            conn = DriverManager.getConnection(sqlUrl, sqlUser, sqlPwd);
            // 获取数据库操作对象
            String sql = "select * from t_user where loginName = ? and loginPwd = ?";
            // 预处理 sql，这里会钉死 sql 语句的框架，? 为占位符，之后再进行值的填充
            ps = conn.prepareStatement(sql);
            // 假定的账号名密码
            String loginUser = "jack";
            String loginPwd = "123";
            // 对 sql 语句进行填值
            ps.setString(1, loginUser);
            ps.setString(2, loginPwd);
            // 处理结果
            rs = ps.executeQuery();
            if (rs.next()) {
                System.out.println("登录成功");
            }
        }catch (Exception e) {
            e.printStackTrace();
        }finally {
            if (rs != null) {
                try {
                    rs.close();
                }catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (ps != null) {
                try {
                    ps.close();
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
