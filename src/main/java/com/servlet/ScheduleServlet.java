package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/ScheduleServlet")
public class ScheduleServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        if(action == null) action = "list";
        
        switch(action) {
            case "list":
                listSchedules(request, response);
                break;
            case "toAdd":
                toAddSchedule(request, response);
                break;
            case "add":
                addSchedule(request, response);
                break;
            case "delete":
                deleteSchedule(request, response);
                break;
            default:
                listSchedules(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    private void listSchedules(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 检查表结构
            boolean hasHallField = checkTableHasColumn(conn, "schedules", "hall");
            
            // 构建SQL查询
            String sql;
            if (hasHallField) {
                // 有hall字段
                sql = "SELECT s.*, m.movie_name as movie_title FROM schedules s " +
                      "LEFT JOIN movies m ON s.movie_id = m.id " +
                      "WHERE s.show_time > NOW() ORDER BY s.show_time";
            } else {
                // 没有hall字段，使用hall_id并转换为可读名称
                sql = "SELECT s.*, m.movie_name as movie_title, s.hall_id as hall_raw " +
                      "FROM schedules s " +
                      "LEFT JOIN movies m ON s.movie_id = m.id " +
                      "WHERE s.show_time > NOW() ORDER BY s.show_time";
            }
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> scheduleList = new ArrayList<>();
            
            while(rs.next()) {
                Map<String, Object> schedule = new HashMap<>();
                schedule.put("id", rs.getInt("id"));
                schedule.put("movie_id", rs.getInt("movie_id"));
                schedule.put("movie_title", rs.getString("movie_title"));
                schedule.put("show_time", rs.getTimestamp("show_time"));
                schedule.put("price", rs.getDouble("price"));
                schedule.put("available_seats", rs.getInt("available_seats"));
                
                // 处理hall字段
                if (hasHallField) {
                    schedule.put("hall", rs.getString("hall"));
                } else {
                    String hallRaw = rs.getString("hall_raw");
                    schedule.put("hall", convertHallIdToName(hallRaw));
                }
                
                scheduleList.add(schedule);
            }
            
            // 获取所有电影用于下拉框
            closeResources(null, pstmt, rs);
            
            sql = "SELECT id, movie_name FROM movies WHERE status = 1 ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> movieList = new ArrayList<>();
            while(rs.next()) {
                Map<String, Object> movie = new HashMap<>();
                movie.put("id", rs.getInt("id"));
                movie.put("title", rs.getString("movie_name"));
                movieList.add(movie);
            }
            
            request.setAttribute("scheduleList", scheduleList);
            request.setAttribute("movieList", movieList);
            request.getRequestDispatcher("schedule.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "加载排期失败: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void toAddSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT id, movie_name FROM movies WHERE status = 1 ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> movieList = new ArrayList<>();
            while(rs.next()) {
                Map<String, Object> movie = new HashMap<>();
                movie.put("id", rs.getInt("id"));
                movie.put("title", rs.getString("movie_name"));
                movieList.add(movie);
            }
            
            request.setAttribute("movieList", movieList);
            request.getRequestDispatcher("add-schedule.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "加载电影列表失败: " + e.getMessage());
            request.getRequestDispatcher("schedule.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void addSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String movieId = request.getParameter("movie_id");
        String showTime = request.getParameter("show_time");
        String hall = request.getParameter("hall");
        String price = request.getParameter("price");
        
        // 参数验证
        if(movieId == null || movieId.trim().isEmpty() ||
           showTime == null || showTime.trim().isEmpty() ||
           hall == null || hall.trim().isEmpty() ||
           price == null || price.trim().isEmpty()) {
            request.setAttribute("error", "所有字段都必须填写");
            request.getRequestDispatcher("add-schedule.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 检查表结构
            boolean hasHallField = checkTableHasColumn(conn, "schedules", "hall");
            boolean hasHallIdField = checkTableHasColumn(conn, "schedules", "hall_id");
            
            String sql;
            if (hasHallField) {
                // 有hall字段
                sql = "INSERT INTO schedules(movie_id, show_time, hall, price, available_seats) VALUES (?, ?, ?, ?, 100)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(movieId));
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                java.util.Date date = sdf.parse(showTime);
                pstmt.setTimestamp(2, new Timestamp(date.getTime()));
                
                pstmt.setString(3, hall);
                pstmt.setDouble(4, Double.parseDouble(price));
                
            } else if (hasHallIdField) {
                // 只有hall_id字段
                String hallId = convertHallNameToId(hall);
                sql = "INSERT INTO schedules(movie_id, show_time, hall_id, price, available_seats) VALUES (?, ?, ?, ?, 100)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(movieId));
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                java.util.Date date = sdf.parse(showTime);
                pstmt.setTimestamp(2, new Timestamp(date.getTime()));
                
                pstmt.setString(3, hallId);
                pstmt.setDouble(4, Double.parseDouble(price));
                
            } else {
                // 两个字段都没有，添加hall字段
                sql = "ALTER TABLE schedules ADD COLUMN hall VARCHAR(50) DEFAULT '1号厅'";
                Statement stmt = conn.createStatement();
                stmt.executeUpdate(sql);
                stmt.close();
                
                // 重新插入
                sql = "INSERT INTO schedules(movie_id, show_time, hall, price, available_seats) VALUES (?, ?, ?, ?, 100)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(movieId));
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                java.util.Date date = sdf.parse(showTime);
                pstmt.setTimestamp(2, new Timestamp(date.getTime()));
                
                pstmt.setString(3, hall);
                pstmt.setDouble(4, Double.parseDouble(price));
            }
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                response.sendRedirect("ScheduleServlet?action=list");
            } else {
                request.setAttribute("error", "添加排期失败");
                request.getRequestDispatcher("add-schedule.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "价格必须是数字");
            request.getRequestDispatcher("add-schedule.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "添加失败: " + e.getMessage());
            request.getRequestDispatcher("add-schedule.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    
    private void deleteSchedule(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String id = request.getParameter("id");
        if(id == null || id.trim().isEmpty()) {
            response.sendRedirect("ScheduleServlet?action=list");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            String sql = "DELETE FROM schedules WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(id));
            pstmt.executeUpdate();
            
            response.sendRedirect("ScheduleServlet?action=list");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("ScheduleServlet?action=list");
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    
    // ========== 辅助方法 ==========
    
    // 检查表是否有某字段
    private boolean checkTableHasColumn(Connection conn, String tableName, String columnName) {
        ResultSet rs = null;
        try {
            DatabaseMetaData meta = conn.getMetaData();
            rs = meta.getColumns(null, null, tableName, columnName);
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
        }
    }
    
    // 将hall_id转换为放映厅名称
    private String convertHallIdToName(String hallId) {
        if (hallId == null || hallId.trim().isEmpty()) return "1号厅";
        
        hallId = hallId.trim().toLowerCase();
        
        switch(hallId) {
            case "1":
            case "hall1": return "1号厅";
            case "2":
            case "hall2": return "2号厅";
            case "3":
            case "hall3": return "3号厅";
            case "imax":
            case "hall_imax": return "IMAX厅";
            case "dolby":
            case "hall_dolby": return "杜比厅";
            case "vip":
            case "hall_vip": return "VIP厅";
            default: 
                if (hallId.matches("\\d+")) {
                    return hallId + "号厅";
                } else if (hallId.startsWith("hall")) {
                    return hallId.replace("hall", "") + "号厅";
                } else {
                    return hallId;
                }
        }
    }
    
    // 将放映厅名称转换为hall_id
    private String convertHallNameToId(String hallName) {
        if (hallName == null || hallName.trim().isEmpty()) return "1";
        
        hallName = hallName.trim();
        
        // 如果是数字号厅
        if (hallName.matches("\\d+号厅")) {
            return hallName.replace("号厅", "");
        }
        
        // 特殊放映厅
        switch(hallName) {
            case "IMAX厅": return "imax";
            case "杜比厅": return "dolby";
            case "VIP厅": return "vip";
            case "巨幕厅": return "large";
            case "普通厅": return "1";
            default: 
                // 尝试提取数字
                String numbers = hallName.replaceAll("[^0-9]", "");
                if (!numbers.isEmpty()) {
                    return numbers;
                } else {
                    return "1";
                }
        }
    }
    
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try { if(rs != null) rs.close(); } catch(SQLException e) { e.printStackTrace(); }
        try { if(stmt != null) stmt.close(); } catch(SQLException e) { e.printStackTrace(); }
        try { if(conn != null) conn.close(); } catch(SQLException e) { e.printStackTrace(); }
    }
}