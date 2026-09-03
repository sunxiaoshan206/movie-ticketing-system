package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/TicketServlet")
public class TicketServlet extends HttpServlet {
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if("selectSeat".equals(action)) {
            selectSeat(request, response);
        }
    }
    
    private void selectSeat(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String movieId = request.getParameter("movieId");
        if (movieId == null || movieId.trim().isEmpty()) {
            response.sendRedirect("MovieServlet?action=list");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 查询电影详情
            String sql = "SELECT id, movie_name, price, duration, description, " +
                         "director, actors FROM movies WHERE id = ? AND status = 1";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(movieId));
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                Map<String, Object> movie = new HashMap<>();
                movie.put("id", rs.getInt("id"));
                movie.put("title", rs.getString("movie_name"));
                movie.put("price", rs.getDouble("price"));
                movie.put("duration", rs.getInt("duration"));
                movie.put("description", rs.getString("description"));
                movie.put("director", rs.getString("director"));
                movie.put("actors", rs.getString("actors"));
                
                // 将电影信息存入request
                request.setAttribute("movie", movie);
                
                // 转发到buy-ticket.jsp
                request.getRequestDispatcher("buy-ticket.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "电影不存在或已下架");
                request.getRequestDispatcher("movie-list.jsp").forward(request, response);
            }
            
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "加载电影信息失败: " + e.getMessage());
            request.getRequestDispatcher("movie-list.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try { if(rs != null) rs.close(); } catch(SQLException e) {}
        try { if(stmt != null) stmt.close(); } catch(SQLException e) {}
        try { if(conn != null) conn.close(); } catch(SQLException e) {}
    }
}