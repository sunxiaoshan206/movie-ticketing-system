package com.servlet;

import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;  
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456";
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ OrderServlet: MySQL驱动加载成功");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ OrderServlet: MySQL驱动加载失败: " + e.getMessage());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        System.out.println("📋 OrderServlet action: " + action);
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Integer userId = getUserIdFromSession(session);
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        switch (action) {
            case "list":
                listUserOrders(request, response, userId);
                break;
            case "view":
                viewUserOrder(request, response, userId);
                break;
            case "cancel":
                cancelOrder(request, response, userId);
                break;
            default:
                listUserOrders(request, response, userId);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("📨 OrderServlet POST action: " + action);
        
        if (action == null) action = "";
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Integer userId = getUserIdFromSession(session);
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        switch (action) {
            case "create":
                createOrder(request, response, userId);
                break;
            default:
                doGet(request, response);
        }
    }
    
    // ==================== 核心订单管理功能 ====================
    
    /**
     * 用户查看自己的订单
     */
    private void listUserOrders(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT o.*, m.movie_name, m.poster_url, " +
                        "       s.show_time, s.hall_id, " +
                        "       ch.hall_name " +
                        "FROM orders o " +
                        "LEFT JOIN movies m ON o.movie_id = m.id " +
                        "LEFT JOIN schedules s ON o.schedule_id = s.id " +
                        "LEFT JOIN cinema_halls ch ON s.hall_id = ch.id " +
                        "WHERE o.user_id = ? " +
                        "ORDER BY o.order_time DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> orderList = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("order_id", rs.getString("order_id"));
                order.put("order_number", rs.getString("order_number"));
                order.put("movie_name", rs.getString("movie_name"));
                order.put("poster_url", rs.getString("poster_url"));
                order.put("show_time", rs.getTimestamp("show_time"));
                
                // 获取厅名
                String hall = rs.getString("hall_name");
                if (hall == null || hall.trim().isEmpty()) {
                    hall = "厅" + rs.getString("hall_id");
                }
                order.put("hall", hall != null ? hall : "默认厅");
                
                order.put("seats", rs.getString("seats"));
                order.put("ticket_count", rs.getInt("ticket_count"));
                order.put("total_price", rs.getDouble("total_price"));
                order.put("payment_status", rs.getInt("payment_status"));
                order.put("order_status", rs.getInt("order_status"));
                order.put("order_time", rs.getTimestamp("order_time"));
                
                orderList.add(order);
            }
            
            System.out.println("✅ 查询到用户 " + userId + " 的 " + orderList.size() + " 条订单");
            
            request.setAttribute("orderList", orderList);
            request.getRequestDispatcher("user/order.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "加载订单失败: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    /**
     * 用户查看单个订单详情
     */
    private void viewUserOrder(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws ServletException, IOException {
        
        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            request.setAttribute("error", "订单ID不能为空");
            listUserOrders(request, response, userId);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT o.*, m.movie_name, m.poster_url, m.duration, " +
                        "       s.show_time, s.hall_id, s.price as schedule_price, " +
                        "       ch.hall_name, ch.hall_type " +
                        "FROM orders o " +
                        "LEFT JOIN movies m ON o.movie_id = m.id " +
                        "LEFT JOIN schedules s ON o.schedule_id = s.id " +
                        "LEFT JOIN cinema_halls ch ON s.hall_id = ch.id " +
                        "WHERE o.order_id = ? AND o.user_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, orderId.trim());
            pstmt.setInt(2, userId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("order_id", rs.getString("order_id"));
                order.put("order_number", rs.getString("order_number"));
                order.put("movie_name", rs.getString("movie_name"));
                order.put("poster_url", rs.getString("poster_url"));
                order.put("duration", rs.getInt("duration"));
                order.put("show_time", rs.getTimestamp("show_time"));
                
                // 获取厅名
                String hall = rs.getString("hall_name");
                if (hall == null || hall.trim().isEmpty()) {
                    hall = "厅" + rs.getString("hall_id");
                }
                order.put("hall", hall != null ? hall : "默认厅");
                order.put("hall_type", rs.getString("hall_type"));
                
                order.put("schedule_price", rs.getDouble("schedule_price"));
                order.put("seats", rs.getString("seats"));
                order.put("ticket_count", rs.getInt("ticket_count"));
                order.put("total_price", rs.getDouble("total_price"));
                order.put("payment_method", rs.getString("payment_method"));
                order.put("payment_status", rs.getInt("payment_status"));
                order.put("order_status", rs.getInt("order_status"));
                order.put("order_time", rs.getTimestamp("order_time"));
                order.put("phone", rs.getString("phone"));
                order.put("remark", rs.getString("remark"));
                
                request.setAttribute("order", order);
                request.getRequestDispatcher("user/order.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "订单不存在或无权访问");
                listUserOrders(request, response, userId);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "加载订单详情失败: " + e.getMessage());
            listUserOrders(request, response, userId);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    /**
     * 用户取消订单
     */
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws ServletException, IOException {
        
        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.trim().isEmpty()) {
            request.setAttribute("error", "订单ID不能为空");
            listUserOrders(request, response, userId);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 检查订单是否属于该用户
            String checkSql = "SELECT order_status FROM orders WHERE order_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, orderId.trim());
            pstmt.setInt(2, userId);
            
            rs = pstmt.executeQuery();
            if (!rs.next()) {
                request.setAttribute("error", "订单不存在或无权操作");
                listUserOrders(request, response, userId);
                return;
            }
            
            int orderStatus = rs.getInt("order_status");
            if (orderStatus == -1) {
                request.setAttribute("error", "订单已取消");
                listUserOrders(request, response, userId);
                return;
            }
            
            // 更新订单状态为取消（-1）
            String updateSql = "UPDATE orders SET order_status = -1 WHERE order_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, orderId.trim());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                request.setAttribute("success", "订单取消成功");
            } else {
                request.setAttribute("error", "订单取消失败");
            }
            
            listUserOrders(request, response, userId);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "操作失败: " + e.getMessage());
            listUserOrders(request, response, userId);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    /**
     * 创建订单
     */
    private void createOrder(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // 获取表单参数
        String movieIdStr = request.getParameter("movieId");
        String scheduleIdStr = request.getParameter("scheduleId");
        String seats = request.getParameter("seats");
        String ticketCountStr = request.getParameter("ticketCount");
        String totalPriceStr = request.getParameter("totalPrice");
        String paymentMethod = request.getParameter("paymentMethod");
        String phone = request.getParameter("phone");
        String remark = request.getParameter("remark");
        
        // 参数验证
        if (movieIdStr == null || movieIdStr.trim().isEmpty() ||
            scheduleIdStr == null || scheduleIdStr.trim().isEmpty() ||
            seats == null || seats.trim().isEmpty()) {
            
            showErrorPage(out, "缺少必要参数", "电影ID、场次ID、座位信息不能为空");
            return;
        }
        
        try {
            int movieId = Integer.parseInt(movieIdStr.trim());
            int scheduleId = Integer.parseInt(scheduleIdStr.trim());
            int ticketCount = (ticketCountStr != null && !ticketCountStr.trim().isEmpty()) 
                                ? Integer.parseInt(ticketCountStr.trim()) : 1;
            double totalPrice = (totalPriceStr != null && !totalPriceStr.trim().isEmpty()) 
                                ? Double.parseDouble(totalPriceStr.trim()) : 0;
            
            // 生成订单号
            String orderId = generateOrderId();
            
            // 创建订单
            boolean success = saveOrderToDB(orderId, userId, movieId, scheduleId, 
                                          seats.trim(), ticketCount, totalPrice, 
                                          paymentMethod, phone, remark);
            
            if (success) {
                // 重定向到支付页面或显示成功页面
                request.setAttribute("orderId", orderId);
                request.setAttribute("totalPrice", totalPrice);
                request.getRequestDispatcher("pay.jsp").forward(request, response);
            } else {
                showErrorPage(out, "订单创建失败", "请稍后重试或联系客服");
            }
            
        } catch (NumberFormatException e) {
            showErrorPage(out, "参数格式错误", "请检查输入参数是否正确");
        } catch (Exception e) {
            e.printStackTrace();
            showErrorPage(out, "系统错误", e.getMessage());
        }
    }
    
    /**
     * 保存订单到数据库
     */
    private boolean saveOrderToDB(String orderId, int userId, int movieId, 
            int scheduleId, String seats, int ticketCount,
            double totalPrice, String paymentMethod, 
            String phone, String remark) {

Connection conn = null;
PreparedStatement pstmt = null;

try {
conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);


String sql = "INSERT INTO orders (order_id, order_number, user_id, schedule_id, movie_id, " +
   "total_price, ticket_count, seat_position, seats, " +
   "payment_method, phone, remark, order_status, create_time) " +
   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

System.out.println("📝 执行SQL: " + sql);
System.out.println("📦 订单ID: " + orderId);
System.out.println("👤 用户ID: " + userId);
System.out.println("🎬 电影ID: " + movieId);
System.out.println("⏰ 场次ID: " + scheduleId);
System.out.println("💺 座位: " + seats);

pstmt = conn.prepareStatement(sql);

// 生成订单编号
String orderNumber = "NO" + new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date());

// 重要：按顺序设置参数，一定要和SQL中的字段顺序一致！
pstmt.setString(1, orderId);                // 1. order_id
pstmt.setString(2, orderNumber);            // 2. order_number
pstmt.setInt(3, userId);                    // 3. user_id  ← 这里必须是整数！
pstmt.setInt(4, scheduleId);                // 4. schedule_id
pstmt.setInt(5, movieId);                   // 5. movie_id
pstmt.setDouble(6, totalPrice);             // 6. total_price
pstmt.setInt(7, ticketCount);               // 7. ticket_count
pstmt.setString(8, seats);                  // 8. seat_position
pstmt.setString(9, seats);                  // 9. seats
pstmt.setString(10, paymentMethod);         // 10. payment_method
pstmt.setString(11, phone != null ? phone.trim() : ""); // 11. phone
pstmt.setString(12, remark != null ? remark.trim() : ""); // 12. remark
pstmt.setInt(13, 1);                        // 13. order_status (1=有效)
pstmt.setTimestamp(14, new Timestamp(System.currentTimeMillis())); // 14. create_time

// 调试：打印所有参数值
System.out.println("✅ 参数设置完成");
System.out.println("1. order_id = " + orderId);
System.out.println("2. order_number = " + orderNumber);
System.out.println("3. user_id = " + userId + " (整数)");
System.out.println("4. schedule_id = " + scheduleId);
System.out.println("5. movie_id = " + movieId);
System.out.println("6. total_price = " + totalPrice);
System.out.println("7. ticket_count = " + ticketCount);
System.out.println("8. seat_position = " + seats);
System.out.println("9. seats = " + seats);
System.out.println("10. payment_method = " + paymentMethod);

int result = pstmt.executeUpdate();
System.out.println(result > 0 ? "✅ 订单保存成功" : "❌ 订单保存失败");
return result > 0;

} catch (Exception e) {
System.err.println("❌ 保存订单失败: " + e.getMessage());
e.printStackTrace();
return false;
} finally {
closeResources(conn, pstmt, null);
}
}
    // ==================== 工具方法 ====================
    
    /**
     * 从session获取用户ID
     */
    private Integer getUserIdFromSession(HttpSession session) {
        Object userIdObj = session.getAttribute("userId");
        
        if (userIdObj instanceof Integer) {
            return (Integer) userIdObj;
        } else if (userIdObj instanceof String) {
            try {
                return Integer.parseInt(((String) userIdObj).trim());
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
    
    /**
     * 生成订单ID
     */
    private String generateOrderId() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        // 明确使用java.util.Date
        String timeStr = sdf.format(new java.util.Date());  
        int random = (int)(Math.random() * 1000);
        return "ORD" + timeStr + String.format("%03d", random);
    }
    
    /**
     * 显示错误页面
     */
    private void showErrorPage(PrintWriter out, String title, String message) {
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>错误</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; background: #f5f7fa; padding: 20px; }");
        out.println(".container { max-width: 600px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
        out.println("h1 { color: #d32f2f; }");
        out.println(".btn { display: inline-block; padding: 10px 20px; background: #2196f3; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>" + title + "</h1>");
        out.println("<p>" + message + "</p>");
        out.println("<a href='javascript:history.back()' class='btn'>返回上一页</a>");
        out.println("<a href='index.jsp' class='btn' style='margin-left: 10px;'>返回首页</a>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    
    /**
     * 关闭数据库资源
     */
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (Exception e) { }
        try { if (stmt != null) stmt.close(); } catch (Exception e) { }
        try { if (conn != null) conn.close(); } catch (Exception e) { }
    }
}