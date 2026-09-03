<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    String user = (String) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 从MovieServlet获取数据
    List<Map<String, Object>> movies = (List<Map<String, Object>>) request.getAttribute("movieList");
    String error = (String) request.getAttribute("error");
    
    // 如果直接访问JSP（不是通过MovieServlet），重定向到MovieServlet
    if (movies == null) {
        response.sendRedirect("MovieServlet?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>电影列表</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f7fa; margin: 0; padding: 0; }
        .header { background: #2c3e50; color: white; padding: 20px; }
        .nav { background: #34495e; padding: 10px 20px; }
        .nav a { color: white; text-decoration: none; margin-right: 20px; padding: 5px 10px; border-radius: 4px; }
        .nav a:hover { background: rgba(255,255,255,0.1); }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .page-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .movie-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 25px; }
        .movie-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); position: relative; }
        .movie-title { font-size: 22px; color: #2c3e50; margin-bottom: 10px; }
        .movie-info { color: #7f8c8d; margin-bottom: 8px; font-size: 14px; }
        .movie-price { font-size: 24px; color: #e74c3c; font-weight: bold; margin: 15px 0; }
        .btn { display: inline-block; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: 500; }
        .btn-primary { background: #3498db; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-success { background: #2ecc71; color: white; }
        .actions { display: flex; gap: 10px; margin-top: 15px; }
        .status-badge { 
            position: absolute; 
            top: 15px; 
            right: 15px; 
            padding: 5px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: bold; 
            color: white; 
        }
        .type-tag { 
            display: inline-block; 
            background: #e8f4fc; 
            color: #3498db; 
            padding: 3px 10px; 
            border-radius: 12px; 
            font-size: 12px; 
            margin-right: 5px; 
            margin-bottom: 5px; 
        }
        .error { color: red; padding: 10px; background: #ffe6e6; border-radius: 5px; margin: 10px 0; }
        .success { color: green; padding: 10px; background: #e6ffe6; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>电影列表</h1>
        <p>欢迎，<%= user %>！</p>
    </div>
    
    <div class="nav">
        <a href="index.jsp">首页</a>
        <a href="MovieServlet?action=list">电影列表</a>  <!-- 修改这里 -->
        <a href="buy-ticket.jsp">购票</a>
        <a href="orders.jsp">我的订单</a>  <!-- 注意：你的订单页面是orders.jsp -->
        <% if ("admin".equals(role)) { %>
            <a href="add-movie.jsp" style="background:#27ae60;">添加电影</a>
            <a href="admin.jsp" style="background:#8e44ad;">管理面板</a>
        <% } %>
        <a href="UserServlet?action=logout" style="float:right; background:#e74c3c;">退出</a>
    </div>
    
    <div class="container">
        <div class="page-title">
            <h2>所有电影（共 <%= movies.size() %> 部）</h2>
            <% if ("admin".equals(role)) { %>
                <a href="add-movie.jsp" class="btn btn-success">添加新电影</a>
            <% } %>
        </div>
        
        <%-- 显示错误信息（如果有） --%>
        <% if (error != null) { %>
            <div class="error">
                <h3>注意：<%= error %></h3>
            </div>
        <% } %>
        
        <% if (movies.isEmpty()) { %>
            <div class="error">
                <h3>没有找到电影数据</h3>
                <p>数据库中暂时没有电影数据。</p>
                <% if ("admin".equals(role)) { %>
                    <p><a href="add-movie.jsp" class="btn btn-success">添加第一部电影</a></p>
                <% } %>
            </div>
        <% } else { %>
            <div class="movie-grid">
                <%
                    for (Map<String, Object> movie : movies) {
                        // 安全地获取值，避免NullPointerException
                        int id = movie.get("id") != null ? Integer.parseInt(movie.get("id").toString()) : 0;
                        String title = (String) movie.get("title");
                        if (title == null) title = (String) movie.get("movie_name");
                        if (title == null) title = "未知电影";
                        
                        String director = (String) movie.get("director");
                        if (director == null) director = "未知导演";
                        
                        String actors = (String) movie.get("actors");
                        if (actors == null) actors = (String) movie.get("actor");
                        if (actors == null) actors = "未知演员";
                        
                        int duration = 0;
                        if (movie.get("duration") != null) {
                            try {
                                duration = Integer.parseInt(movie.get("duration").toString());
                            } catch (NumberFormatException e) {
                                duration = 0;
                            }
                        }
                        
                        double price = 0.0;
                        if (movie.get("price") != null) {
                            try {
                                price = Double.parseDouble(movie.get("price").toString());
                            } catch (NumberFormatException e) {
                                price = 0.0;
                            }
                        }
                        
                        String description = (String) movie.get("description");
                        if (description == null) description = "";
                %>
                <div class="movie-card">
                    <%-- 状态徽章（可选） --%>
                    <% 
                        String status = (String) movie.get("status");
                        if (status != null && !status.isEmpty()) {
                            String statusColor = "#7f8c8d";
                            if ("正在热映".equals(status)) {
                                statusColor = "#e74c3c";
                            } else if ("即将上映".equals(status)) {
                                statusColor = "#3498db";
                            } else if ("已下映".equals(status)) {
                                statusColor = "#95a5a6";
                            }
                    %>
                    <div class="status-badge" style="background-color: <%= statusColor %>;">
                        <%= status %>
                    </div>
                    <% } %>
                    
                    <h3 class="movie-title"><%= title %></h3>
                    
                    <div class="movie-info">导演：<%= director %></div>
                    <div class="movie-info">主演：<%= actors %></div>
                    <div class="movie-info">时长：<%= duration %>分钟</div>
                    <div class="movie-price">¥<%= price %></div>
                    
                    <% if (description != null && !description.trim().isEmpty()) { %>
                    <div style="margin: 10px 0; padding: 10px; background: #f9f9f9; border-radius: 5px; font-size: 13px; color: #666; max-height: 80px; overflow: auto;">
                        <%= description.length() > 100 ? description.substring(0, 100) + "..." : description %>
                    </div>
                    <% } %>
                    
                    <div class="actions">
                        <a href="MovieServlet?action=detail&id=<%= id %>" class="btn">查看详情</a>
                        
                        <%-- 购票按钮 --%>
                        <% if (status == null || "正在热映".equals(status)) { %>
                            <a href="buy-ticket.jsp?movieId=<%= id %>" class="btn btn-primary">立即购票</a>
                        <% } else if ("即将上映".equals(status)) { %>
                            <a href="javascript:void(0)" class="btn" style="background:#f1c40f;color:#fff;">即将上映</a>
                        <% } else { %>
                            <a href="javascript:void(0)" class="btn" style="background:#95a5a6;color:#fff;">已下映</a>
                        <% } %>
                        
                        <% if ("admin".equals(role)) { %>
                            <a href="edit-movie.jsp?id=<%= id %>" class="btn">编辑</a>
                            <a href="MovieServlet?action=delete&id=<%= id %>" 
                               class="btn btn-danger"
                               onclick="return confirm('确定删除《<%= title %>》吗？')">删除</a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>