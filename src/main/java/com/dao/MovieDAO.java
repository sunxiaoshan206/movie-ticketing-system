package com.dao;

import com.entity.Movie;
import com.util.JDBCUtil;
import java.sql.*;
import java.util.*;

public class MovieDAO {
    
    // 获取所有电影 - 修复完整版
    public List<Movie> getAllMovies() {
        List<Movie> movies = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = JDBCUtil.getConnection();
            
            if (conn == null) {
                System.out.println("错误：数据库连接为null");
                return movies;
            }
            
            String sql = "SELECT * FROM movies ORDER BY release_date DESC";
            ps = conn.prepareStatement(sql);  
            rs = ps.executeQuery();
            
            // 处理查询结果
            while (rs.next()) {
                Movie movie = new Movie();
                movie.setId(rs.getInt("id"));
                movie.setMovieName(rs.getString("movie_name"));
                movie.setType(rs.getString("type"));
                movie.setDuration(rs.getInt("duration"));
                movie.setDirector(rs.getString("director"));
                movie.setActor(rs.getString("actor"));
                movie.setReleaseDate(rs.getDate("release_date"));
                movie.setStatus(rs.getInt("status"));
                movie.setDescription(rs.getString("description"));
                
                movies.add(movie);
            }
            
            System.out.println("成功获取 " + movies.size() + " 条电影记录");
            
        } catch (SQLException e) {
            System.out.println("SQL查询错误：" + e.getMessage());
            e.printStackTrace();
        } finally {
            JDBCUtil.close(conn, ps, rs);
        }
        
        return movies;
    }
    
    // 根据ID获取电影
    public Movie getMovieById(int id) {
        Movie movie = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = JDBCUtil.getConnection();
            String sql = "SELECT * FROM movies WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                movie = new Movie();
                movie.setId(rs.getInt("id"));
                movie.setMovieName(rs.getString("movie_name"));
                movie.setType(rs.getString("type"));
                movie.setDuration(rs.getInt("duration"));
                movie.setDirector(rs.getString("director"));
                movie.setActor(rs.getString("actor"));
                movie.setReleaseDate(rs.getDate("release_date"));
                movie.setStatus(rs.getInt("status"));
                movie.setDescription(rs.getString("description"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            JDBCUtil.close(conn, pstmt, rs);
        }
        
        return movie;
    }
    
    // 添加电影
    public boolean addMovie(Movie movie) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = JDBCUtil.getConnection();
            String sql = "INSERT INTO movies(movie_name, type, duration, director, actor, release_date, status, description) " +
                         "VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, movie.getMovieName());
            pstmt.setString(2, movie.getType());
            pstmt.setInt(3, movie.getDuration());
            pstmt.setString(4, movie.getDirector());
            pstmt.setString(5, movie.getActor());
            pstmt.setDate(6, new java.sql.Date(movie.getReleaseDate().getTime()));
            pstmt.setInt(7, movie.getStatus());
            pstmt.setString(8, movie.getDescription());
            
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            JDBCUtil.close(conn, pstmt, null);
        }
    }
}