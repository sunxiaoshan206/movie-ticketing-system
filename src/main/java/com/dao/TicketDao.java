package com.dao;

import com.entity.Ticket;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TicketDao {
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL驱动加载失败", e);
        }
        
        String url = "jdbc:mysql://localhost:3306/movie_ticket_system?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8";
        String user = "root";
        String password = "123456"; 
        
        return DriverManager.getConnection(url, user, password);
    }
    
    /**
     * 创建票务订单
     */
    public boolean createTicket(Ticket ticket) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            String sql = "INSERT INTO tickets (movie_id, movie_name, user_id, username, " +
                         "seats, quantity, total_price, show_time, hall, status, create_time) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ticket.getMovieId());
            pstmt.setString(2, ticket.getMovieName());
            pstmt.setInt(3, ticket.getUserId());
            pstmt.setString(4, ticket.getUsername());
            pstmt.setString(5, ticket.getSeats());
            pstmt.setInt(6, ticket.getQuantity());
            pstmt.setDouble(7, ticket.getTotalPrice());
            pstmt.setString(8, ticket.getShowTime());
            pstmt.setString(9, ticket.getHall());
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    
    /**
     * 根据用户ID查询订单
     */
    public List<Ticket> getTicketsByUserId(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Ticket> tickets = new ArrayList<>();
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM tickets WHERE user_id = ? ORDER BY create_time DESC";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Ticket ticket = extractTicketFromResultSet(rs);
                tickets.add(ticket);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return tickets;
    }
    
    /**
     * 根据订单ID查询
     */
    public Ticket getTicketById(int ticketId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Ticket ticket = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM tickets WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ticketId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                ticket = extractTicketFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return ticket;
    }
    
    /**
     * 取消订单
     */
    public boolean cancelTicket(int ticketId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE tickets SET status = 0, update_time = NOW() " +
                         "WHERE id = ? AND user_id = ? AND status = 1";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, ticketId);
            pstmt.setInt(2, userId);
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
    
    /**
     * 获取用户订单数量
     */
    public int getTicketCountByUserId(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) as count FROM tickets WHERE user_id = ? AND status = 1";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt("count");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }
    
    /**
     * 查询所有订单（管理员用）
     */
    public List<Ticket> getAllTickets() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Ticket> tickets = new ArrayList<>();
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM tickets ORDER BY create_time DESC";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Ticket ticket = extractTicketFromResultSet(rs);
                tickets.add(ticket);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return tickets;
    }
    
    /**
     * 检查座位是否已被预订
     */
    public boolean isSeatsBooked(int movieId, String showTime, String seats) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) as count FROM tickets " +
                         "WHERE movie_id = ? AND show_time = ? " +
                         "AND seats LIKE ? AND status = 1";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, movieId);
            pstmt.setString(2, showTime);
            pstmt.setString(3, "%" + seats + "%");
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return false;
    }
    
    /**
     * 从ResultSet提取Ticket对象
     */
    private Ticket extractTicketFromResultSet(ResultSet rs) throws SQLException {
        Ticket ticket = new Ticket();
        ticket.setId(rs.getInt("id"));
        ticket.setMovieId(rs.getInt("movie_id"));
        ticket.setMovieName(rs.getString("movie_name"));
        ticket.setUserId(rs.getInt("user_id"));
        ticket.setUsername(rs.getString("username"));
        ticket.setSeats(rs.getString("seats"));
        ticket.setQuantity(rs.getInt("quantity"));
        ticket.setTotalPrice(rs.getDouble("total_price"));
        ticket.setShowTime(rs.getString("show_time"));
        ticket.setHall(rs.getString("hall"));
        ticket.setStatus(rs.getInt("status"));
        ticket.setCreateTime(rs.getTimestamp("create_time"));
        ticket.setUpdateTime(rs.getTimestamp("update_time"));
        return ticket;
    }
    
    /**
     * 关闭数据库资源
     */
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        try {
            if (stmt != null) stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}