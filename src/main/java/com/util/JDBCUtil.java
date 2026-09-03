package com.util;

import java.sql.*;

public class JDBCUtil {
    // 修改这里的配置为您自己的数据库信息
    private static final String URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String USER = "root";      // 改成您的MySQL用户名
    private static final String PASSWORD = "123456"; // 改成您的MySQL密码
    
    static {
        try {
            // MySQL 8.0+ 使用这个驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL驱动加载成功");
        } catch (ClassNotFoundException e) {
            System.out.println("错误：找不到MySQL驱动！");
            System.out.println("请确保mysql-connector-j-8.0.33.jar在WEB-INF/lib目录下");
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("数据库连接成功");
        } catch (SQLException e) {
            System.out.println("数据库连接失败！");
            System.out.println("请检查：1.MySQL服务是否启动 2.数据库名是否正确 3.用户名密码是否正确");
            System.out.println("URL: " + URL);
            System.out.println("USER: " + USER);
            e.printStackTrace();
        }
        return conn;
    }
    
    public static void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                conn.close();
                System.out.println("数据库连接已关闭");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}