package dzy.test;

import java.sql.*;
import java.util.ResourceBundle;

public class JDBCTest07 {
    public static void main(String[] args) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResourceBundle bundle = ResourceBundle.getBundle("jdbc");
        try {
            String sqlDriver = bundle.getString("driver");
            String sqlUrl = bundle.getString("url");
            String sqlUser = bundle.getString("user");
            String sqlPwd = bundle.getString("password");
            Class.forName(sqlDriver);
            conn = DriverManager.getConnection(sqlUrl, sqlUser, sqlPwd);
            // 关闭自动提交
            conn.setAutoCommit(false);
            String sql = "update t_user set loginName = ? where id = ?";
            ps = conn.prepareStatement(sql);

            // 事件1
            String loginName = "tom";
            int uId = 1;
            ps.setString(1, loginName);
            ps.setInt(2, uId);
            int count = ps.executeUpdate();

            // 手动制造崩溃测试事务效果
            String s = null;
            s.toString();

            // 事件2
            loginName = "jack";
            uId = 2;
            ps.setString(1, loginName);
            ps.setInt(2, uId);
            count += ps.executeUpdate();
            System.out.println(count == 2 ? "操作成功" : "操作失败");

            conn.commit();
        }catch (Exception e) {
            // 若操作不成功，手动回滚
            if (conn != null) {
                try {
                    conn.rollback();
                }catch (Exception e2) {
                    e2.printStackTrace();
                }
            }
            e.printStackTrace();
        }finally {
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