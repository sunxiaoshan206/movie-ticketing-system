package com.dao;

import com.entity.Schedule;
import com.util.JDBCUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDAO {
    
    // 获取所有排期
    public List<Schedule> getAllSchedules() {
        List<Schedule> schedules = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = JDBCUtil.getConnection();
            String sql = "SELECT s.*, m.movie_name, h.hall_name " +
                         "FROM schedules s " +
                         "JOIN movies m ON s.movie_id = m.id " +
                         "JOIN cinema_halls h ON s.hall_id = h.id " +
                         "WHERE s.show_time > NOW() " +
                         "ORDER BY s.show_time";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Schedule schedule = new Schedule();
                schedule.setId(rs.getInt("id"));
                schedule.setMovieId(rs.getInt("movie_id"));
                schedule.setHallId(rs.getInt("hall_id"));
                schedule.setShowTime(rs.getTimestamp("show_time"));
                schedule.setPrice(rs.getDouble("price"));
                schedule.setAvailableSeats(rs.getInt("available_seats"));
                schedule.setStatus(rs.getInt("status"));
                
                schedules.add(schedule);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            JDBCUtil.close(conn, pstmt, rs);
        }
        return schedules;
    }
    
    // 根据电影ID获取排期
    public List<Schedule> getSchedulesByMovieId(int movieId) {
        List<Schedule> schedules = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = JDBCUtil.getConnection();
            String sql = "SELECT s.*, h.hall_name, h.hall_type " +
                         "FROM schedules s " +
                         "JOIN cinema_halls h ON s.hall_id = h.id " +
                         "WHERE s.movie_id = ? AND s.status = 1 AND s.show_time > NOW() " +
                         "ORDER BY s.show_time";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, movieId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Schedule schedule = new Schedule();
                schedule.setId(rs.getInt("id"));
                schedule.setMovieId(movieId);
                schedule.setHallId(rs.getInt("hall_id"));
                schedule.setShowTime(rs.getTimestamp("show_time"));
                schedule.setPrice(rs.getDouble("price"));
                schedule.setAvailableSeats(rs.getInt("available_seats"));
                schedule.setStatus(rs.getInt("status"));
                
                schedules.add(schedule);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            JDBCUtil.close(conn, pstmt, rs);
        }
        return schedules;
    }
    
    // 根据ID获取排期
    public Schedule getScheduleById(int id) {
        Schedule schedule = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = JDBCUtil.getConnection();
            String sql = "SELECT s.*, m.movie_name, h.hall_name " +
                         "FROM schedules s " +
                         "JOIN movies m ON s.movie_id = m.id " +
                         "JOIN cinema_halls h ON s.hall_id = h.id " +
                         "WHERE s.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                schedule = new Schedule();
                schedule.setId(rs.getInt("id"));
                schedule.setMovieId(rs.getInt("movie_id"));
                schedule.setHallId(rs.getInt("hall_id"));
                schedule.setShowTime(rs.getTimestamp("show_time"));
                schedule.setPrice(rs.getDouble("price"));
                schedule.setAvailableSeats(rs.getInt("available_seats"));
                schedule.setStatus(rs.getInt("status"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            JDBCUtil.close(conn, pstmt, rs);
        }
        return schedule;
    }
}