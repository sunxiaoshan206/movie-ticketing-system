package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;

@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        
        PrintWriter out = response.getWriter();
        Map<String, Object> jsonMap = new HashMap<>();
        
        try {
            String action = request.getParameter("action");
            HttpSession session = request.getSession(false);
            
            if (session == null) {
                jsonMap.put("success", false);
                jsonMap.put("message", "用户未登录");
                out.print(mapToJson(jsonMap));
                return;
            }
            
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                jsonMap.put("success", false);
                jsonMap.put("message", "用户未登录");
                out.print(mapToJson(jsonMap));
                return;
            }
            
            if ("add".equals(action)) {
                addReview(request, userId, jsonMap);
            } else if ("create_table".equals(action)) {
                createReviewTable(jsonMap);
            } else if ("list".equals(action)) {
                listReviews(request, userId, jsonMap);
            } else {
                jsonMap.put("success", false);
                jsonMap.put("message", "未知操作");
            }
            
        } catch (Exception e) {
            jsonMap.put("success", false);
            jsonMap.put("message", "系统错误：" + e.getMessage());
            e.printStackTrace();
        }
        
        out.print(mapToJson(jsonMap));
        out.close();
    }
    
    /**
     * 添加评价
     */
    private void addReview(HttpServletRequest request, String userId, Map<String, Object> jsonMap) 
            throws SQLException {
        
        String orderId = request.getParameter("order_id");
        String rating = request.getParameter("rating");
        String content = request.getParameter("content");
        
        // 验证参数
        if (orderId == null || rating == null || content == null) {
            jsonMap.put("success", false);
            jsonMap.put("message", "参数不完整");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // 加载驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 1. 检查订单是否属于该用户且已支付
            String checkSql = "SELECT o.movie_id FROM orders o " +
                             "WHERE o.order_id = ? AND o.user_id = ? AND o.payment_status = 1";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, orderId);
            pstmt.setInt(2, Integer.parseInt(userId));
            ResultSet rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                jsonMap.put("success", false);
                jsonMap.put("message", "订单不存在或未支付");
                rs.close();
                return;
            }
            
            int movieId = rs.getInt("movie_id");
            rs.close();
            
            // 2. 检查是否已评价过
            String checkReviewSql = "SELECT id FROM reviews WHERE order_id = ?";
            pstmt = conn.prepareStatement(checkReviewSql);
            pstmt.setString(1, orderId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                jsonMap.put("success", false);
                jsonMap.put("message", "该订单已评价过");
                rs.close();
                return;
            }
            rs.close();
            
            // 3. 插入评价
         // 在 addReview 方法中，修改插入语句：
            String insertSql = "INSERT INTO reviews (order_id, user_id, movie_id, rating, content) " +
                              "VALUES (?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, orderId);      // order_id
            pstmt.setInt(2, Integer.parseInt(userId));      // user_id
            pstmt.setInt(3, movieId);         // movie_id
            pstmt.setInt(4, Integer.parseInt(rating));      // rating
            pstmt.setString(5, content);      // content
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                jsonMap.put("success", true);
                jsonMap.put("message", "评价提交成功");
                jsonMap.put("order_id", orderId);
                jsonMap.put("rating", rating);
            } else {
                jsonMap.put("success", false);
                jsonMap.put("message", "评价提交失败");
            }
            
        } catch (ClassNotFoundException e) {
            jsonMap.put("success", false);
            jsonMap.put("message", "数据库驱动错误：" + e.getMessage());
        } catch (SQLException e) {
            // 如果表不存在，尝试创建表
            if (e.getMessage().contains("reviews")) {
                try {
                    createReviewTable(jsonMap);
                    // 重新尝试插入
                    if ((Boolean)jsonMap.getOrDefault("success", false)) {
                        addReview(request, userId, jsonMap);
                    }
                } catch (Exception ex) {
                    jsonMap.put("success", false);
                    jsonMap.put("message", "创建评价表失败：" + ex.getMessage());
                }
            } else {
                jsonMap.put("success", false);
                jsonMap.put("message", "数据库错误：" + e.getMessage());
            }
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 创建评价表
     */
    private void createReviewTable(Map<String, Object> jsonMap) {
        Connection conn = null;
        Statement stmt = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            stmt = conn.createStatement();
            
            // 创建评价表
            String sql = "CREATE TABLE IF NOT EXISTS reviews (" +
                        "id INT PRIMARY KEY AUTO_INCREMENT, " +
                        "order_id VARCHAR(50) NOT NULL, " +
                        "user_id INT NOT NULL, " +
                        "movie_id INT NOT NULL, " +
                        "rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5), " +
                        "content TEXT, " +
                        "create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                        "status TINYINT DEFAULT 1, " +
                        "INDEX idx_order_id (order_id), " +
                        "INDEX idx_user_id (user_id), " +
                        "INDEX idx_movie_id (movie_id), " +
                        "UNIQUE KEY unique_order_review (order_id)" +
                        ")";
            
            stmt.executeUpdate(sql);
            
            // 添加测试数据（可选）
            String testSql = "INSERT IGNORE INTO reviews (order_id, user_id, movie_id, rating, content) " +
                           "SELECT o.order_id, o.user_id, o.movie_id, 5, '默认好评' " +
                           "FROM orders o WHERE o.payment_status = 1 LIMIT 3";
            stmt.executeUpdate(testSql);
            
            jsonMap.put("success", true);
            jsonMap.put("message", "评价表创建成功");
            
        } catch (Exception e) {
            jsonMap.put("success", false);
            jsonMap.put("message", "创建评价表失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 获取评价列表
     */
    private void listReviews(HttpServletRequest request, String userId, Map<String, Object> jsonMap) 
            throws SQLException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT r.*, m.movie_name, o.order_number " +
                        "FROM reviews r " +
                        "JOIN movies m ON r.movie_id = m.movie_id " +
                        "JOIN orders o ON r.order_id = o.order_id " +
                        "WHERE r.user_id = ? " +
                        "ORDER BY r.create_time DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(userId));
            rs = pstmt.executeQuery();
            
            // 构建评价列表
            List<Map<String, Object>> reviewList = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            
            while (rs.next()) {
                Map<String, Object> review = new HashMap<>();
                review.put("id", rs.getInt("id"));
                review.put("order_id", rs.getString("order_id"));
                review.put("order_number", rs.getString("order_number"));
                review.put("movie_id", rs.getInt("movie_id"));
                review.put("movie_name", rs.getString("movie_name"));
                review.put("rating", rs.getInt("rating"));
                review.put("content", rs.getString("content"));
                review.put("create_time", sdf.format(rs.getTimestamp("create_time")));
                review.put("status", rs.getInt("status"));
                reviewList.add(review);
            }
            
            jsonMap.put("success", true);
            jsonMap.put("message", "获取评价列表成功");
            jsonMap.put("data", reviewList);
            jsonMap.put("count", reviewList.size());
            
        } catch (Exception e) {
            jsonMap.put("success", false);
            jsonMap.put("message", "获取评价列表失败：" + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 将 Map 转换为 JSON 字符串
     */
    private String mapToJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            
            Object value = entry.getValue();
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(escapeJson((String)value)).append("\"");
            } else if (value instanceof Boolean || value instanceof Number) {
                json.append(value);
            } else if (value instanceof List) {
                json.append(listToJson((List<?>)value));
            } else if (value instanceof Map) {
                json.append(mapToJson((Map<String, Object>)value));
            } else {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            }
        }
        
        json.append("}");
        return json.toString();
    }
    
    /**
     * 将 List 转换为 JSON 数组字符串
     */
    private String listToJson(List<?> list) {
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        
        for (Object item : list) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            if (item == null) {
                json.append("null");
            } else if (item instanceof String) {
                json.append("\"").append(escapeJson((String)item)).append("\"");
            } else if (item instanceof Boolean || item instanceof Number) {
                json.append(item);
            } else if (item instanceof Map) {
                json.append(mapToJson((Map<String, Object>)item));
            } else if (item instanceof List) {
                json.append(listToJson((List<?>)item));
            } else {
                json.append("\"").append(escapeJson(item.toString())).append("\"");
            }
        }
        
        json.append("]");
        return json.toString();
    }
    
    /**
     * 转义 JSON 字符串中的特殊字符
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}