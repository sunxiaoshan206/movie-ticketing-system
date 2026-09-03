package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL驱动加载失败: " + e.getMessage());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        
        if("login".equals(action)) {
            login(request, response);
        } else if("logout".equals(action)) {
            logout(request, response);
        } else if("register".equals(action)) {
            register(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }
    
    private void login(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        if(username == null || username.trim().isEmpty() || 
           password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 注意：这里只查询，不验证密码
            String sql = "SELECT id, username, password, user_type FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("password");
                
                // 验证密码（明文比较）
                if (dbPassword != null && dbPassword.equals(password)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", username);
                    session.setAttribute("userId", rs.getString("id"));
                    
                    // 根据 user_type 设置角色
                    int userType = rs.getInt("user_type");
                    String role = "user"; // 默认值
                    
                    if (!rs.wasNull() && userType == 1) {
                        role = "admin";
                    }
                    
                    session.setAttribute("role", role);
                    
                    // 统一跳转到首页
                    response.sendRedirect("index.jsp");
                    
                } else {
                    request.setAttribute("error", "密码错误");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
                
            } else {
                request.setAttribute("error", "用户不存在");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            // 打印详细的错误信息
            System.err.println("登录时数据库错误: " + e.getMessage());
            System.err.println("错误SQL状态: " + e.getSQLState());
            System.err.println("错误代码: " + e.getErrorCode());
            e.printStackTrace();
            
            request.setAttribute("error", "系统错误: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void register(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // 基本验证
        if(username == null || username.trim().isEmpty() || 
           password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 1. 检查用户名是否存在
            String checkSql = "SELECT id FROM users WHERE username = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            rs = checkStmt.executeQuery();
            
            if(rs.next()) {
                request.setAttribute("error", "用户名已存在");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            rs.close();
            checkStmt.close();
            
            // 2. 插入新用户
            // 假设你的users表有这些字段：id, username, password, email, phone, user_type
            String insertSql = "INSERT INTO users (username, password, email, phone, user_type) VALUES (?, ?, ?, ?, 0)";
            insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            insertStmt.setString(1, username);
            insertStmt.setString(2, password);
            insertStmt.setString(3, email != null ? email : "");
            insertStmt.setString(4, phone != null ? phone : "");
            
            int result = insertStmt.executeUpdate();
            
            if(result > 0) {
                // 获取生成的ID
                ResultSet generatedKeys = insertStmt.getGeneratedKeys();
                String userId = null;
                if (generatedKeys.next()) {
                    userId = generatedKeys.getString(1);
                }
                generatedKeys.close();
                
                // 注册成功后自动登录
                HttpSession session = request.getSession();
                session.setAttribute("user", username);
                session.setAttribute("userId", userId);
                session.setAttribute("role", "user"); // 新注册用户默认是普通用户
                
                response.sendRedirect("index.jsp");
            } else {
                request.setAttribute("error", "注册失败");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            // 打印详细的错误信息
            System.err.println("注册时数据库错误: " + e.getMessage());
            System.err.println("错误SQL状态: " + e.getSQLState());
            System.err.println("错误代码: " + e.getErrorCode());
            System.err.println("可能是表结构不匹配或字段名错误");
            e.printStackTrace();
            
            // 更详细的错误信息
            String errorMsg = "系统错误: ";
            if (e.getMessage().contains("role")) {
                errorMsg += "数据库表字段不匹配，请检查users表结构";
            } else {
                errorMsg += e.getMessage();
            }
            
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (checkStmt != null) checkStmt.close(); } catch (SQLException e) {}
            try { if (insertStmt != null) insertStmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    private void logout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if(session != null) {
            session.invalidate();
        }
        response.sendRedirect("login.jsp");
    }
    
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try { if(rs != null) rs.close(); } catch(SQLException e) {}
        try { if(stmt != null) stmt.close(); } catch(SQLException e) {}
        try { if(conn != null) conn.close(); } catch(SQLException e) {}
    }
}