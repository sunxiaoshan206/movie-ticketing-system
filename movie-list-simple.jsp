<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> movieList = (List<Map<String, Object>>) request.getAttribute("movieList");
    if (movieList == null) {
        movieList = new ArrayList<>();
    }
    
    String error = (String) request.getAttribute("error");
    Boolean isMockData = (Boolean) request.getAttribute("isMockData");
%>
<!DOCTYPE html>
<html>
<head>
    <title>电影列表</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            margin: 0; 
            padding: 0;
            min-height: 100vh;
        }
        .header { 
            background: linear-gradient(90deg, #2c3e50, #4a6491);
            color: white; 
            padding: 25px 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .container { 
            max-width: 1200px; 
            margin: 20px auto; 
            padding: 0 20px; 
        }
        .movie-card { 
            background: white; 
            padding: 25px; 
            border-radius: 15px; 
            margin-bottom: 25px; 
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            border-left: 5px solid #3498db;
        }
        .btn { 
            padding: 12px 30px; 
            background: linear-gradient(90deg, #3498db, #2980b9);
            color: white; 
            border: none; 
            border-radius: 8px; 
            font-size: 16px; 
            font-weight: bold;
            cursor: pointer; 
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            margin-right: 10px;
        }
        .btn-success { 
            background: linear-gradient(90deg, #27ae60, #219653);
        }
        .btn:hover { 
            opacity: 0.9; 
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(52, 152, 219, 0.4);
        }
        .warning-box {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .movie-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .info-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="container">
            <h1 style="margin:0;">🎬 电影列表</h1>
            <p style="margin:10px 0 0 0; font-size:18px;">
                共 <%= movieList.size() %> 部电影
                <% if (isMockData != null && isMockData) { %>
                    <span style="color:#ffc107;">(模拟数据)</span>
                <% } %>
            </p>
        </div>
    </div>
    
    <div class="container">
        <% if (error != null) { %>
            <div class="warning-box">
                ⚠️ <%= error %>
            </div>
        <% } %>
        
        <% if (movieList.isEmpty()) { %>
            <div style="text-align:center; padding:50px; background:white; border-radius:15px;">
                <h3>暂无电影</h3>
                <p>暂时没有可观看的电影</p>
            </div>
        <% } else { %>
            <% for (Map<String, Object> movie : movieList) { %>
                <div class="movie-card">
                    <h2 style="color:#2c3e50; margin-top:0;">
                        <%= movie.get("title") %>
                    </h2>
                    
                    <div class="movie-info-grid">
                        <div class="info-item">
                            <p><strong>导演：</strong><%= movie.get("director") %></p>
                            <p><strong>主演：</strong><%= movie.get("actor") != null ? movie.get("actor") : "暂无信息" %></p>
                        </div>
                        <div class="info-item">
                            <p><strong>时长：</strong><%= movie.get("duration") %>分钟</p>
                            <p><strong>票价：</strong>
                                <span style="color:#e74c3c; font-size:20px; font-weight:bold;">
                                    ¥<%= String.format("%.2f", movie.get("price")) %>
                                </span>
                            </p>
                        </div>
                    </div>
                    
                    <p style="margin-top:15px;"><strong>简介：</strong><%= movie.get("description") %></p>
                    
                    <div style="margin-top:20px;">
                        <a href="buy-ticket.jsp?movieId=<%= movie.get("id") %>" class="btn">
                            🎫 立即购票
                        </a>
                        <a href="MovieServlet?action=detail&id=<%= movie.get("id") %>" class="btn btn-success">
                            📖 查看详情
                        </a>
                    </div>
                </div>
            <% } %>
        <% } %>
        
        <div style="text-align:center; margin-top:30px;">
            <a href="index.jsp" class="btn" style="background:#6c757d;">🏠 返回首页</a>
        </div>
    </div>
</body>
</html>