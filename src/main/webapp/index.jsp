<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>首页 - 电影票务系统</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: #f5f7fa;
            margin: 0;
            color: #333;
        }
        .header {
            background: #1a237e;
            color: white;
            padding: 20px;
        }
        .nav {
            background: #3949ab;
            padding: 15px 20px;
        }
        .nav a {
            color: white;
            text-decoration: none;
            margin-right: 20px;
            padding: 8px 12px;
            border-radius: 4px;
        }
        .nav a:hover {
            background: rgba(255,255,255,0.1);
        }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .welcome {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        .welcome h1 {
            margin: 0 0 10px 0;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin: 40px 0;
        }
        .feature-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            text-align: center;
        }
        .feature-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #2196f3;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 10px;
        }
        .btn:hover {
            opacity: 0.9;
        }
        .movies {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        .movie-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .movie-card h3 {
            margin: 0 0 10px 0;
            color: #1a237e;
        }
        .movie-info {
            color: #666;
            font-size: 14px;
            margin: 5px 0;
        }
        .footer {
            background: #333;
            color: white;
            text-align: center;
            padding: 20px;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎬 电影票务系统</h1>
        <p>欢迎，<%= user %>！</p>
    </div>
    
    <div class="nav">
        <a href="index.jsp">🏠 首页</a>
        <a href="MovieServlet?action=list">🎥 电影列表</a>
        <a href="buy-ticket.jsp">🎟️ 购票</a>
        <a href="order.jsp">📋 我的订单</a>
        <% if("admin".equals(role)) { %>
            <a href="admin.jsp" style="background:#4CAF50;">👑 管理面板</a>
        <% } %>
        <a href="UserServlet?action=logout" style="float:right; background:#f44336;">退出</a>
    </div>
    
    <div class="container">
        <div class="welcome">
            <h1>欢迎来到电影票务系统！</h1>
            <p>发现精彩电影，享受观影时光</p>
        </div>
        
        <div class="features">
            <div class="feature-card">
                <div class="feature-icon">🎥</div>
                <h3>浏览电影</h3>
                <p>查看最新上映电影和排期</p>
                <a href="MovieServlet?action=list" class="btn">立即查看</a>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">🎟️</div>
                <h3>在线购票</h3>
                <p>选择心仪座位，轻松购票</p>
                <a href="buy-ticket.jsp" class="btn">立即购票</a>
            </div>
            
            <div class="feature-card">
                <div class="feature-icon">📋</div>
                <h3>订单管理</h3>
                <p>查看历史订单记录</p>
                <a href="order.jsp" class="btn">我的订单</a>
            </div>
        </div>
        
        <h2>🔥 热映电影</h2>
        <div class="movies">
            <div class="movie-card">
                <h3>流浪地球2</h3>
                <p class="movie-info">导演：郭帆</p>
                <p class="movie-info">主演：吴京, 刘德华</p>
                <p class="movie-info">时长：173分钟</p>
                <p class="movie-info">评分：⭐ 9.2</p>
                <p style="color:#e91e63; font-size: 20px; font-weight: bold;">¥45.00</p>
                <a href="buy-ticket.jsp" class="btn" style="background:#4CAF50;">立即购票</a>
            </div>
            
            <div class="movie-card">
                <h3>满江红</h3>
                <p class="movie-info">导演：张艺谋</p>
                <p class="movie-info">主演：沈腾, 易烊千玺</p>
                <p class="movie-info">时长：159分钟</p>
                <p class="movie-info">评分：⭐ 8.5</p>
                <p style="color:#e91e63; font-size: 20px; font-weight: bold;">¥42.00</p>
                <a href="buy-ticket.jsp" class="btn" style="background:#4CAF50;">立即购票</a>
            </div>
            
            <div class="movie-card">
                <h3>深海</h3>
                <p class="movie-info">导演：田晓鹏</p>
                <p class="movie-info">主演：苏鑫, 王亭文</p>
                <p class="movie-info">时长：112分钟</p>
                <p class="movie-info">评分：⭐ 9.0</p>
                <p style="color:#e91e63; font-size: 20px; font-weight: bold;">¥38.00</p>
                <a href="buy-ticket.jsp" class="btn" style="background:#4CAF50;">立即购票</a>
            </div>
        </div>
    </div>
    
    <div class="footer">
        <p>© 2025 电影票务系统 | 客服电话：400-123-4567</p>
        <p>登录时间：<%= new java.util.Date() %></p>
    </div>
</body>
</html>