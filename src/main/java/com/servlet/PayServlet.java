package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/PayServlet")
public class PayServlet extends HttpServlet {
    
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
            
            if ("pay".equals(action)) {
                processPayment(request, userId, jsonMap);
            } else if ("check".equals(action)) {
                checkPaymentStatus(request, userId, jsonMap);
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
     * 处理支付
     */
    private void processPayment(HttpServletRequest request, String userId, Map<String, Object> jsonMap) 
            throws SQLException {
        
        String orderId = request.getParameter("order_id");
        String paymentMethod = request.getParameter("payment_method");
        String amountStr = request.getParameter("amount");
        
        // 验证参数
        if (orderId == null || paymentMethod == null || amountStr == null) {
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
            conn.setAutoCommit(false); // 开始事务
            
            // 1. 检查订单状态
            String checkSql = "SELECT payment_status, total_price FROM orders " +
                             "WHERE order_id = ? AND user_id = ? FOR UPDATE";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, orderId);
            pstmt.setInt(2, Integer.parseInt(userId));
            ResultSet rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                jsonMap.put("success", false);
                jsonMap.put("message", "订单不存在");
                conn.rollback();
                return;
            }
            
            int paymentStatus = rs.getInt("payment_status");
            double totalPrice = rs.getDouble("total_price");
            rs.close();
            
            // 检查是否已支付
            if (paymentStatus == 1) {
                jsonMap.put("success", false);
                jsonMap.put("message", "订单已支付");
                conn.rollback();
                return;
            }
            
            // 2. 更新订单支付状态
            String updateSql = "UPDATE orders SET payment_status = 1, " +
                              "payment_method = ?, payment_time = NOW() " +
                              "WHERE order_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, paymentMethod);
            pstmt.setString(2, orderId);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // 3. 记录支付日志（可选）
                try {
                    String logSql = "INSERT INTO payment_logs (order_id, user_id, amount, " +
                                   "payment_method, status, create_time) " +
                                   "VALUES (?, ?, ?, ?, 1, NOW())";
                    pstmt = conn.prepareStatement(logSql);
                    pstmt.setString(1, orderId);
                    pstmt.setInt(2, Integer.parseInt(userId));
                    pstmt.setDouble(3, totalPrice);
                    pstmt.setString(4, paymentMethod);
                    pstmt.executeUpdate();
                } catch (SQLException e) {
                    // 日志表可能不存在，忽略这个错误
                    System.out.println("支付日志记录失败（表可能不存在）: " + e.getMessage());
                }
                
                // 提交事务
                conn.commit();
                
                jsonMap.put("success", true);
                jsonMap.put("message", "支付成功");
                jsonMap.put("order_id", orderId);
                jsonMap.put("payment_method", paymentMethod);
                jsonMap.put("amount", totalPrice);
                
            } else {
                conn.rollback();
                jsonMap.put("success", false);
                jsonMap.put("message", "支付失败，更新订单状态失败");
            }
            
        } catch (ClassNotFoundException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            jsonMap.put("success", false);
            jsonMap.put("message", "数据库驱动错误：" + e.getMessage());
        } catch (SQLException e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            jsonMap.put("success", false);
            jsonMap.put("message", "数据库错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 检查支付状态
     */
    private void checkPaymentStatus(HttpServletRequest request, String userId, Map<String, Object> jsonMap) 
            throws SQLException {
        
        String orderId = request.getParameter("order_id");
        
        if (orderId == null) {
            jsonMap.put("success", false);
            jsonMap.put("message", "参数不完整");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT o.*, m.movie_name, m.poster_url " +
                        "FROM orders o " +
                        "LEFT JOIN movies m ON o.movie_id = m.id " +
                        "WHERE o.order_id = ? AND o.user_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, orderId);
            pstmt.setInt(2, Integer.parseInt(userId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> orderInfo = new HashMap<>();
                orderInfo.put("order_id", rs.getString("order_id"));
                orderInfo.put("order_number", rs.getString("order_number"));
                orderInfo.put("movie_name", rs.getString("movie_name"));
                orderInfo.put("seat_info", rs.getString("seat_info"));
                orderInfo.put("total_price", rs.getDouble("total_price"));
                orderInfo.put("payment_status", rs.getInt("payment_status"));
                orderInfo.put("payment_method", rs.getString("payment_method"));
                orderInfo.put("payment_time", rs.getTimestamp("payment_time"));
                orderInfo.put("create_time", rs.getTimestamp("create_time"));
                orderInfo.put("poster_url", rs.getString("poster_url"));
                
                jsonMap.put("success", true);
                jsonMap.put("message", "获取支付状态成功");
                jsonMap.put("data", orderInfo);
            } else {
                jsonMap.put("success", false);
                jsonMap.put("message", "订单不存在");
            }
            
        } catch (Exception e) {
            jsonMap.put("success", false);
            jsonMap.put("message", "数据库错误：" + e.getMessage());
            e.printStackTrace();
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
        if (map == null) return "null";
        
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) {
                json.append(",");
            }
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            json.append(valueToJson(entry.getValue()));
        }
        
        json.append("}");
        return json.toString();
    }
    
    /**
     * 转换值为 JSON 格式
     */
    private String valueToJson(Object value) {
        if (value == null) return "null";
        if (value instanceof String) {
            return "\"" + escapeJson((String)value) + "\"";
        }
        if (value instanceof Boolean || value instanceof Number) {
            return value.toString();
        }
        if (value instanceof Map) {
            return mapToJson((Map<String, Object>)value);
        }
        if (value instanceof List) {
            return listToJson((List<?>)value);
        }
        return "\"" + escapeJson(value.toString()) + "\"";
    }
    
    /**
     * 将 List 转换为 JSON 数组字符串
     */
    private String listToJson(List<?> list) {
        if (list == null) return "null";
        
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        
        for (Object item : list) {
            if (!first) {
                json.append(",");
            }
            first = false;
            json.append(valueToJson(item));
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