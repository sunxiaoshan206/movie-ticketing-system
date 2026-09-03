<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // 获取电影列表
    List<Map<String, Object>> movieList = (List<Map<String, Object>>) request.getAttribute("movieList");
    if (movieList == null) {
        movieList = new ArrayList<>();
    }
    
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>添加电影排期</title>
    <style>
        /* 保持原来的样式不变 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            width: 100%;
            max-width: 600px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            backdrop-filter: blur(10px);
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 14px;
        }
        
        .form-container {
            padding: 40px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 16px;
            transition: all 0.3s ease;
            background: white;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .btn {
            display: inline-block;
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            text-decoration: none;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 7px 14px rgba(102, 126, 234, 0.2);
        }
        
        .btn-back {
            background: #6c757d;
            margin-top: 15px;
        }
        
        .btn-back:hover {
            background: #5a6268;
            box-shadow: 0 7px 14px rgba(108, 117, 125, 0.2);
        }
        
        .error-message {
            background: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }
        
        .success-message {
            background: #efe;
            color: #2a7;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #2a7;
        }
        
        .select-wrapper {
            position: relative;
        }
        
        .select-wrapper:after {
            content: "▼";
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            color: #667eea;
        }
        
        .datetime-input {
            position: relative;
        }
        
        .datetime-input:before {
            content: "📅";
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            color: #667eea;
        }
        
        .datetime-input input {
            padding-left: 45px;
        }
        
        .price-input:before {
            content: "¥";
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
            color: #667eea;
            font-weight: bold;
        }
        
        .price-input input {
            padding-left: 35px;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .form-col {
            flex: 1;
        }
        
        @media (max-width: 768px) {
            .form-row {
                flex-direction: column;
                gap: 25px;
            }
            
            .container {
                margin: 20px;
            }
        }
        
        .movie-option {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        
        .movie-title {
            font-weight: 500;
            color: #333;
        }
        
        .movie-info {
            font-size: 12px;
            color: #666;
        }
    </style>
    <script>
        function validateForm() {
            var movieId = document.getElementById("movie_id").value;
            var showTime = document.getElementById("show_time").value;
            var hall = document.getElementById("hall").value;
            var price = document.getElementById("price").value;
            
            if (!movieId) {
                alert("请选择电影");
                return false;
            }
            
            if (!showTime) {
                alert("请选择放映时间");
                return false;
            }
            
            if (!hall || hall.trim() === "") {
                alert("请输入放映厅");
                return false;
            }
            
            if (!price || isNaN(price) || price <= 0) {
                alert("请输入有效的价格（大于0的数字）");
                return false;
            }
            
            // 确保时间不是过去的时间
            var selectedTime = new Date(showTime);
            var now = new Date();
            if (selectedTime < now) {
                alert("放映时间不能是过去的时间");
                return false;
            }
            
            return true;
        }
        
        function setMinDateTime() {
            var now = new Date();
            // 设置为当前时间的下一分钟
            now.setMinutes(now.getMinutes() + 1);
            
            var minDateTime = now.toISOString().slice(0, 16);
            document.getElementById("show_time").min = minDateTime;
            document.getElementById("show_time").value = minDateTime;
        }
        
        // 页面加载时设置最小时间
        window.onload = setMinDateTime;
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎬 添加电影排期</h1>
            <p>为观众安排精彩的电影放映</p>
        </div>
        
        <div class="form-container">
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
            
            <form action="ScheduleServlet?action=add" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="movie_id">选择电影</label>
                    <div class="select-wrapper">
                        <select class="form-control" id="movie_id" name="movie_id" required>
                            <option value="">-- 请选择电影 --</option>
                            <% 
                                for (Map<String, Object> movie : movieList) {
                                    Integer movieId = (Integer) movie.get("id");
                                    String movieTitle = (String) movie.get("title");
                            %>
                                <option value="<%= movieId %>">
                                    <%= movieTitle %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="show_time">放映时间</label>
                    <div class="datetime-input">
                        <input type="datetime-local" 
                               class="form-control" 
                               id="show_time" 
                               name="show_time" 
                               required>
                    </div>
                    <small style="color: #666; font-size: 12px; margin-top: 5px; display: block;">
                        ⏰ 请选择未来的时间
                    </small>
                </div>
                
                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label for="hall">放映厅</label>
                            <input type="text" 
                                   class="form-control" 
                                   id="hall" 
                                   name="hall" 
                                   placeholder="例如: 1号厅、IMAX厅" 
                                   maxlength="20"
                                   required>
                        </div>
                    </div>
                    
                    <div class="form-col">
                        <div class="form-group">
                            <label for="price">价格（元）</label>
                            <div class="price-input">
                                <input type="number" 
                                       class="form-control" 
                                       id="price" 
                                       name="price" 
                                       placeholder="0.00" 
                                       min="0" 
                                       step="0.01"
                                       required>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn">
                        <span style="font-size: 18px; margin-right: 8px;">➕</span>
                        添加排期
                    </button>
                    <a href="ScheduleServlet?action=list" class="btn btn-back">
                        <span style="font-size: 18px; margin-right: 8px;">←</span>
                        返回排期列表
                    </a>
                </div>
            </form>
            
            <% if (!movieList.isEmpty()) { %>
                <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    <h3 style="color: #333; margin-bottom: 15px; font-size: 16px;">📋 可选电影列表</h3>
                    <div style="background: #f8f9fa; border-radius: 10px; padding: 15px; max-height: 200px; overflow-y: auto;">
                        <% 
                            for (Map<String, Object> movie : movieList) {
                                Integer movieId = (Integer) movie.get("id");
                                String movieTitle = (String) movie.get("title");
                        %>
                            <div class="movie-option">
                                <span class="movie-title"><%= movieTitle %></span>
                                <span class="movie-info">ID: <%= movieId %></span>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>