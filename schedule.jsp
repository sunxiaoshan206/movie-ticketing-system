<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 获取数据
    List<Map<String, Object>> scheduleList = (List<Map<String, Object>>) request.getAttribute("scheduleList");
    if (scheduleList == null) {
        scheduleList = new ArrayList<>();
    }
    
    List<Map<String, Object>> movieList = (List<Map<String, Object>>) request.getAttribute("movieList");
    if (movieList == null) {
        movieList = new ArrayList<>();
    }
    
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>电影排期管理</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            color: #333;
            font-size: 32px;
            font-weight: 600;
        }
        
        .header h1 span {
            color: #667eea;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 7px 14px rgba(102, 126, 234, 0.2);
        }
        
        .btn-add {
            background: linear-gradient(135deg, #00b09b 0%, #96c93d 100%);
        }
        
        .btn-back {
            background: #6c757d;
        }
        
        .content {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 18px 15px;
            text-align: left;
            font-weight: 500;
            font-size: 16px;
        }
        
        tbody tr {
            border-bottom: 1px solid #eee;
            transition: all 0.3s ease;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        td {
            padding: 15px;
            color: #333;
        }
        
        .movie-title {
            font-weight: 500;
            color: #333;
        }
        
        .show-time {
            font-weight: 500;
            color: #667eea;
        }
        
        .hall {
            background: #e3f2fd;
            color: #1976d2;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        
        .price {
            color: #2e7d32;
            font-weight: 600;
        }
        
        .seats {
            color: #666;
            font-size: 14px;
        }
        
        .actions {
            display: flex;
            gap: 10px;
        }
        
        .btn-action {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .btn-delete {
            background: #ff4444;
            color: white;
        }
        
        .btn-delete:hover {
            background: #cc0000;
            transform: translateY(-1px);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .error-message {
            background: #fee;
            color: #c33;
            padding: 15px;
            border-radius: 10px;
            margin: 20px;
            border-left: 4px solid #c33;
        }
        
        .success-message {
            background: #efe;
            color: #2a7;
            padding: 15px;
            border-radius: 10px;
            margin: 20px;
            border-left: 4px solid #2a7;
        }
        
        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        
        .status-available {
            background: #e8f5e9;
            color: #2e7d32;
        }
        
        .status-full {
            background: #ffebee;
            color: #c62828;
        }
        
        @media (max-width: 768px) {
            .header {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            .btn-group {
                width: 100%;
                justify-content: center;
            }
            
            th, td {
                padding: 12px 8px;
                font-size: 14px;
            }
            
            .actions {
                flex-direction: column;
                gap: 5px;
            }
            
            .btn-action {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎬 <span>电影排期管理</span></h1>
            <div class="btn-group">
                <a href="ScheduleServlet?action=toAdd" class="btn btn-add">
                    <span style="font-size: 18px; margin-right: 8px;">➕</span>
                    添加新排期
                </a>
                <a href="index.jsp" class="btn btn-back">
                    <span style="font-size: 18px; margin-right: 8px;">←</span>
                    返回首页
                </a>
            </div>
        </div>
        
        <div class="content">
            <% if (error != null && !error.isEmpty()) { %>
                <div class="error-message">
                    ❌ <%= error %>
                </div>
            <% } %>
            
            <% if (success != null && !success.isEmpty()) { %>
                <div class="success-message">
                    ✅ <%= success %>
                </div>
            <% } %>
            
            <% if (scheduleList.isEmpty()) { %>
                <div class="empty-state">
                    <div style="font-size: 48px; margin-bottom: 20px;">🎥</div>
                    <h3>暂无电影排期</h3>
                    <p>目前没有可用的电影排期，点击"添加新排期"按钮开始安排电影放映。</p>
                    <a href="ScheduleServlet?action=toAdd" class="btn btn-add">
                        <span style="font-size: 18px; margin-right: 8px;">➕</span>
                        添加第一个排期
                    </a>
                </div>
            <% } else { %>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>电影名称</th>
                                <th>放映时间</th>
                                <th>放映厅</th>
                                <th>价格</th>
                                <th>可用座位</th>
                                <th>状态</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                for (Map<String, Object> schedule : scheduleList) {
                                    String movieTitle = (String) schedule.get("movie_title");
                                    Date showTime = (Date) schedule.get("show_time");
                                    String hall = (String) schedule.get("hall");
                                    Double price = (Double) schedule.get("price");
                                    Integer availableSeats = (Integer) schedule.get("available_seats");
                                    Integer id = (Integer) schedule.get("id");
                            %>
                                <tr>
                                    <td>
                                        <div class="movie-title"><%= movieTitle %></div>
                                    </td>
                                    <td>
                                        <div class="show-time">
                                            <%= sdf.format(showTime) %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="hall"><%= hall %></span>
                                    </td>
                                    <td>
                                        <span class="price">
                                            ¥<%= String.format("%.2f", price) %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="seats">
                                            <%= availableSeats %> / 100
                                        </span>
                                    </td>
                                    <td>
                                        <% if (availableSeats > 0) { %>
                                            <span class="status-badge status-available">
                                                🔥 热映中
                                            </span>
                                        <% } else { %>
                                            <span class="status-badge status-full">
                                                🎫 已售罄
                                            </span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <a href="ScheduleServlet?action=delete&id=<%= id %>" 
                                               class="btn-action btn-delete"
                                               onclick="return confirm('确定要删除这个排期吗？')">
                                                删除
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>