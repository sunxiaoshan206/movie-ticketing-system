package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/MovieServlet")
public class MovieServlet extends HttpServlet {
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ [MovieServlet] MySQL驱动加载成功");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ [MovieServlet] MySQL驱动加载失败: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "123456"; // 改为你的实际密码
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if("list".equals(action) || action == null) {
            listMovies(request, response);
        } else if("detail".equals(action)) {
            getMovieDetail(request, response);
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("📨 收到POST请求，action: " + action);
        
        if ("add".equals(action)) {
            addMovie(request, response);
        } else if ("delete".equals(action)) {
            deleteMovie(request, response);
        } else if ("update".equals(action)) {
            updateMovie(request, response);
        } else {
            // 如果没有匹配的POST action，调用doGet
            System.out.println("⚠️ 未识别的POST action，转发给doGet");
            doGet(request, response);
        }
    }

    private void updateMovie(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("✏️ 开始更新电影信息...");
        
        // 检查管理员权限
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            System.out.println("❌ 权限不足，未登录或不是管理员");
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 获取表单数据
        String movieId = request.getParameter("id");
        String title = request.getParameter("title");
        String director = request.getParameter("director");
        String actors = request.getParameter("actors");
        String durationStr = request.getParameter("duration");
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");
        String type = request.getParameter("type");
        String status = request.getParameter("status");
        
        System.out.println("📋 接收到的更新数据：");
        System.out.println("  id: " + movieId);
        System.out.println("  title: " + title);
        System.out.println("  director: " + director);
        System.out.println("  actors: " + actors);
        System.out.println("  duration: " + durationStr);
        System.out.println("  price: " + priceStr);
        
        // 验证必填字段
        if (movieId == null || movieId.trim().isEmpty() || 
            title == null || title.trim().isEmpty()) {
            request.setAttribute("error", "电影ID和名称不能为空");
            request.getRequestDispatcher("edit-movie.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // 连接数据库
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ 数据库连接成功");
            
            // 构建动态SQL，只更新提供的字段
            StringBuilder sqlBuilder = new StringBuilder("UPDATE movies SET ");
            List<Object> params = new ArrayList<>();
            boolean hasUpdate = false;
            
            if (title != null && !title.trim().isEmpty()) {
                sqlBuilder.append("movie_name = ?, ");
                params.add(title.trim());
                hasUpdate = true;
            }
            
            if (director != null && !director.trim().isEmpty()) {
                sqlBuilder.append("director = ?, ");
                params.add(director.trim());
                hasUpdate = true;
            }
            
            if (actors != null && !actors.trim().isEmpty()) {
                sqlBuilder.append("actor = ?, ");
                params.add(actors.trim());
                hasUpdate = true;
            }
            
            if (durationStr != null && !durationStr.trim().isEmpty()) {
                try {
                    int duration = Integer.parseInt(durationStr.trim());
                    sqlBuilder.append("duration = ?, ");
                    params.add(duration);
                    hasUpdate = true;
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ 时长格式错误，跳过更新");
                }
            }
            
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                try {
                    double price = Double.parseDouble(priceStr.trim());
                    sqlBuilder.append("price = ?, ");
                    params.add(price);
                    hasUpdate = true;
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ 价格格式错误，跳过更新");
                }
            }
            
            if (description != null) {
                sqlBuilder.append("description = ?, ");
                params.add(description.trim());
                hasUpdate = true;
            }
            
            if (type != null && !type.trim().isEmpty()) {
                sqlBuilder.append("type = ?, ");
                params.add(type.trim());
                hasUpdate = true;
            }
            
            if (status != null && !status.trim().isEmpty()) {
                try {
                    int statusValue = Integer.parseInt(status.trim());
                    sqlBuilder.append("status = ?, ");
                    params.add(statusValue);
                    hasUpdate = true;
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ 状态格式错误，跳过更新");
                }
            }
            
            if (!hasUpdate) {
                request.setAttribute("error", "没有提供任何更新数据");
                request.getRequestDispatcher("edit-movie.jsp?id=" + movieId).forward(request, response);
                return;
            }
            
            // 移除最后一个逗号和空格
            sqlBuilder.setLength(sqlBuilder.length() - 2);
            sqlBuilder.append(" WHERE id = ?");
            params.add(Integer.parseInt(movieId.trim()));
            
            String sql = sqlBuilder.toString();
            System.out.println("📝 执行SQL: " + sql);
            
            pstmt = conn.prepareStatement(sql);
            
            // 设置参数
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    pstmt.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) param);
                } else if (param instanceof Double) {
                    pstmt.setDouble(i + 1, (Double) param);
                }
            }
            
            // 执行更新
            int result = pstmt.executeUpdate();
            System.out.println("✅ 数据库更新完成，影响行数: " + result);
            
            if (result > 0) {
                System.out.println("🎉 电影更新成功，ID: " + movieId);
                // 更新成功，重定向到电影详情或列表
                response.sendRedirect("MovieServlet?action=detail&id=" + movieId);
            } else {
                System.out.println("❌ 电影更新失败，可能ID不存在");
                request.setAttribute("error", "更新失败，电影可能不存在");
                request.getRequestDispatcher("edit-movie.jsp?id=" + movieId).forward(request, response);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 更新电影时数据库错误: " + e.getMessage());
            e.printStackTrace();
            
            request.setAttribute("error", "数据库错误: " + e.getMessage());
            request.getRequestDispatcher("edit-movie.jsp?id=" + movieId).forward(request, response);
            
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
            System.out.println("✏️ 更新电影流程结束");
        }
    }
	// 添加电影的方法
    private void addMovie(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("🎬 开始添加电影...");
        
        // 检查管理员权限
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            System.out.println("❌ 权限不足，未登录或不是管理员");
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 获取表单数据
        String title = request.getParameter("title");
        String director = request.getParameter("director");
        String actors = request.getParameter("actors");
        String durationStr = request.getParameter("duration");
        String priceStr = request.getParameter("price");
        String description = request.getParameter("description");
        
        System.out.println("📋 接收到的表单数据：");
        System.out.println("  title: " + title);
        System.out.println("  director: " + director);
        System.out.println("  actors: " + actors);
        System.out.println("  duration: " + durationStr);
        System.out.println("  price: " + priceStr);
        System.out.println("  description: " + description);
        
        // 验证必填字段
        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("error", "电影名称不能为空");
            request.getRequestDispatcher("add-movie.jsp").forward(request, response);
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // 连接数据库
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ 数据库连接成功");
            
            // 根据你的数据库表结构调整SQL
            // 注意：你的表中字段名是 movie_name，不是 title
            String sql = "INSERT INTO movies (movie_name, director, actor, duration, price, description) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            
            System.out.println("📝 执行SQL: " + sql);
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title.trim());            // movie_name
            pstmt.setString(2, director != null ? director.trim() : "");  // director
            pstmt.setString(3, actors != null ? actors.trim() : "");      // actor (注意：表中字段是单数actor)
            
            // 处理时长
            int duration = 120; // 默认值
            if (durationStr != null && !durationStr.trim().isEmpty()) {
                try {
                    duration = Integer.parseInt(durationStr.trim());
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ 时长格式错误，使用默认值120");
                }
            }
            pstmt.setInt(4, duration);
            
            // 处理价格
            double price = 45.0; // 默认值
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                try {
                    price = Double.parseDouble(priceStr.trim());
                } catch (NumberFormatException e) {
                    System.out.println("⚠️ 价格格式错误，使用默认值45.0");
                }
            }
            pstmt.setDouble(5, price);
            
            pstmt.setString(6, description != null ? description.trim() : "");  // description
            
            // 执行插入
            int result = pstmt.executeUpdate();
            System.out.println("✅ 数据库插入完成，影响行数: " + result);
            
            if (result > 0) {
                System.out.println("🎉 电影添加成功: " + title);
                // 添加成功，重定向到电影列表
                response.sendRedirect("MovieServlet?action=list");
            } else {
                System.out.println("❌ 电影添加失败");
                request.setAttribute("error", "添加电影失败");
                request.getRequestDispatcher("add-movie.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            System.err.println("❌ 添加电影时数据库错误: " + e.getMessage());
            e.printStackTrace();
            
            // 更详细的错误信息
            String errorMsg = "数据库错误";
            if (e.getMessage().contains("movie_name")) {
                errorMsg = "电影名称可能已存在";
            } else if (e.getMessage().contains("actor")) {
                errorMsg = "主演字段格式错误";
            }
            
            request.setAttribute("error", errorMsg + ": " + e.getMessage());
            request.getRequestDispatcher("add-movie.jsp").forward(request, response);
            
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
            System.out.println("🎬 添加电影流程结束");
        }
    }

    // 如果需要，添加删除电影的方法
    private void deleteMovie(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 删除电影的代码...
        System.out.println("删除电影功能待实现");
        response.sendRedirect("MovieServlet?action=list");
    }
    
    private void listMovies(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            System.out.println("🎬 [MovieServlet] 开始查询电影列表...");
            System.out.println("🔗 数据库URL: " + DB_URL);
            System.out.println("👤 用户名: " + DB_USER);
            
            // 测试数据库连接
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✅ 数据库连接成功！");
            
            // 先检查movies表是否存在
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "movies", null);
            
            if (tables.next()) {
                System.out.println("✅ movies表存在");
                
                // 检查表结构
                ResultSet columns = meta.getColumns(null, null, "movies", null);
                System.out.println("📋 movies表结构：");
                while (columns.next()) {
                    System.out.println("  - " + columns.getString("COLUMN_NAME") + 
                                     " (" + columns.getString("TYPE_NAME") + ")");
                }
                columns.close();
            } else {
                System.out.println("❌ movies表不存在！");
                tables.close();
                
                // 尝试查找可能的表名
                tables = meta.getTables(null, null, "%movie%", null);
                System.out.println("🔍 查找包含'movie'的表：");
                while (tables.next()) {
                    System.out.println("  - " + tables.getString("TABLE_NAME"));
                }
            }
            tables.close();
            
            // 执行查询
            String sql = "SELECT id, movie_name, price, duration, description, " +
                         "director, actor FROM movies WHERE status = 1 ORDER BY id DESC";
            
            System.out.println("📝 执行SQL: " + sql);
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            List<Map<String, Object>> movieList = new ArrayList<>();
            int count = 0;
            
            while(rs.next()) {
                count++;
                Map<String, Object> movie = new HashMap<>();
                
                movie.put("id", rs.getInt("id"));
                movie.put("title", rs.getString("movie_name"));
                movie.put("price", rs.getDouble("price"));
                movie.put("duration", rs.getInt("duration"));
                movie.put("description", rs.getString("description"));
                movie.put("director", rs.getString("director"));
                movie.put("actor", rs.getString("actor"));
                
                movieList.add(movie);
                System.out.println("📽️ 电影" + count + ": " + rs.getString("movie_name"));
            }
            
            System.out.println("✅ 查询完成，共找到 " + count + " 部电影");
            
            if (count == 0) {
                System.out.println("⚠️ 警告：查询到0条记录，可能是：");
                System.out.println("  1. movies表中没有数据");
                System.out.println("  2. status != 1 的电影不会被显示");
                System.out.println("  3. 表字段名不匹配");
                
                // 尝试查询所有电影（不限制status）
                pstmt.close();
                rs.close();
                
                String sqlAll = "SELECT * FROM movies";
                System.out.println("🔍 尝试查询所有电影: " + sqlAll);
                
                pstmt = conn.prepareStatement(sqlAll);
                rs = pstmt.executeQuery();
                
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                System.out.println("📊 movies表共有 " + columnCount + " 个字段：");
                for (int i = 1; i <= columnCount; i++) {
                    System.out.println("  " + i + ". " + rsmd.getColumnName(i) + 
                                     " (" + rsmd.getColumnTypeName(i) + ")");
                }
            }
            
            request.setAttribute("movieList", movieList);
            request.setAttribute("totalMovies", count);
            
            // 转发到你的现有JSP页面
            request.getRequestDispatcher("movie-list.jsp").forward(request, response);
            
        } catch (SQLException e) {
            System.err.println("❌ SQL错误详情：");
            System.err.println("  错误信息: " + e.getMessage());
            System.err.println("  SQL状态: " + e.getSQLState());
            System.err.println("  错误码: " + e.getErrorCode());
            e.printStackTrace();
            
            // 使用模拟数据
            List<Map<String, Object>> movieList = getMockMovies();
            request.setAttribute("movieList", movieList);
            request.setAttribute("error", "数据库错误: " + e.getMessage());
            request.getRequestDispatcher("movie-list.jsp").forward(request, response);
            
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private void getMovieDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String movieId = request.getParameter("id");
        if (movieId == null || movieId.trim().isEmpty()) {
            response.sendRedirect("MovieServlet?action=list");
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // ✅ 修复：使用正确的字段名 actor（不是actors）
            String sql = "SELECT id, movie_name, price, duration, description, " +
                         "director, actor FROM movies WHERE id = ? AND status = 1";
            
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
                movie.put("actor", rs.getString("actor")); // ✅ 使用 actor 字段
                
                request.setAttribute("movie", movie);
                request.getRequestDispatcher("movie-detail.jsp").forward(request, response);
                
            } else {
                request.setAttribute("error", "电影不存在或已下架");
                request.getRequestDispatcher("movie-list-simple.jsp").forward(request, response);
            }
            
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "加载电影详情失败: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    private List<Map<String, Object>> getMockMovies() {
        List<Map<String, Object>> movieList = new ArrayList<>();
        
        Map<String, Object> movie1 = new HashMap<>();
        movie1.put("id", 1);
        movie1.put("title", "流浪地球2");
        movie1.put("price", 45.0);
        movie1.put("duration", 173);
        movie1.put("description", "太阳即将毁灭，人类在地球表面建造出巨大的推进器，寻找新的家园。");
        movie1.put("director", "郭帆");
        movie1.put("actor", "吴京, 刘德华, 李雪健");
        movieList.add(movie1);
        
        Map<String, Object> movie2 = new HashMap<>();
        movie2.put("id", 2);
        movie2.put("title", "满江红");
        movie2.put("price", 40.0);
        movie2.put("duration", 159);
        movie2.put("description", "南宋绍兴年间，岳飞死后四年，秦桧率兵与金国会谈。");
        movie2.put("director", "张艺谋");
        movie2.put("actor", "沈腾, 易烊千玺, 张译");
        movieList.add(movie2);
        
        Map<String, Object> movie3 = new HashMap<>();
        movie3.put("id", 3);
        movie3.put("title", "深海");
        movie3.put("price", 38.0);
        movie3.put("duration", 112);
        movie3.put("description", "在大海的最深处，藏着所有秘密。");
        movie3.put("director", "田晓鹏");
        movie3.put("actor", "苏鑫, 王亭文");
        movieList.add(movie3);
        
        return movieList;
    }
    
    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try { if(rs != null) rs.close(); } catch(SQLException e) {}
        try { if(stmt != null) stmt.close(); } catch(SQLException e) {}
        try { if(conn != null) conn.close(); } catch(SQLException e) {}
    }
}