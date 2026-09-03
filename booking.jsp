<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 检查登录
    String user = (String) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    
    // 修复：安全获取userId，避免类型转换异常
    Object userIdObj = session.getAttribute("userId");
    Integer userId = null;
    
    if (userIdObj instanceof Integer) {
        userId = (Integer) userIdObj;
    } else if (userIdObj instanceof String) {
        try {
            userId = Integer.parseInt(((String) userIdObj).trim());
        } catch (NumberFormatException e) {
            System.out.println("⚠️ session中用户ID格式无效: " + userIdObj);
        }
    }
    
    if(userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取电影ID参数
    String movieId = request.getParameter("movieId");
    String movieTitle = "";
    
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    List<Map<String, Object>> movieList = new ArrayList<>();
    List<Map<String, Object>> scheduleList = new ArrayList<>();
    
    try {
        // 加载MySQL驱动
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/movie_ticket_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", 
            "root", 
            "123456");
        
        System.out.println("✅ booking.jsp: 数据库连接成功");
        
        // 1. 查询所有正在上映的电影
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id, movie_id, movie_name, price, duration, director, poster_url " +
                              "FROM movies WHERE status = 1 ORDER BY id DESC");
        
        while (rs.next()) {
            Map<String, Object> movie = new HashMap<>();
            movie.put("id", rs.getInt("id"));
            movie.put("movie_id", rs.getInt("movie_id"));
            movie.put("movie_name", rs.getString("movie_name"));
            movie.put("price", rs.getDouble("price"));
            movie.put("duration", rs.getInt("duration"));
            movie.put("director", rs.getString("director"));
            movie.put("poster_url", rs.getString("poster_url"));
            movieList.add(movie);
        }
        
        System.out.println("✅ booking.jsp: 查询到 " + movieList.size() + " 部电影");
        
        // 如果movieList为空，直接输出错误信息
        if (movieList.isEmpty()) {
            System.out.println("❌ booking.jsp: 电影列表为空！");
        }
        
        // 2. 如果指定了电影ID，获取该电影信息
        if (movieId != null && !movieId.trim().isEmpty()) {
            rs.close();
            stmt.close();
            
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT movie_name FROM movies WHERE id=" + movieId + " OR movie_id=" + movieId);
            
            if (rs.next()) {
                movieTitle = rs.getString("movie_name");
            }
            
            // 3. 获取该电影的排期信息
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            
            stmt = conn.createStatement();
            String scheduleSql = "SELECT s.*, m.movie_name " +
                                "FROM schedules s " +
                                "LEFT JOIN movies m ON s.movie_id = m.id " +
                                "WHERE s.movie_id = " + movieId + " " +
                                "AND s.show_time > NOW() " +
                                "ORDER BY s.show_time";
            rs = stmt.executeQuery(scheduleSql);
            
            while (rs.next()) {
                Map<String, Object> schedule = new HashMap<>();
                schedule.put("id", rs.getInt("id"));
                schedule.put("show_time", rs.getTimestamp("show_time"));
                schedule.put("hall", rs.getString("hall"));
                schedule.put("price", rs.getDouble("price"));
                schedule.put("available_seats", rs.getInt("available_seats"));
                schedule.put("movie_name", rs.getString("movie_name"));
                scheduleList.add(schedule);
            }
            
            System.out.println("✅ booking.jsp: 查询到 " + scheduleList.size() + " 个排期");
            
        } else if (!movieList.isEmpty()) {
            // 如果没有指定电影ID，获取第一个电影的排期
            Integer firstMovieId = (Integer) movieList.get(0).get("id");
            movieTitle = (String) movieList.get(0).get("movie_name");
            movieId = firstMovieId.toString();
            
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            
            // 获取排期信息
            stmt = conn.createStatement();
            String scheduleSql = "SELECT s.*, m.movie_name " +
                                "FROM schedules s " +
                                "LEFT JOIN movies m ON s.movie_id = m.id " +
                                "WHERE s.movie_id = " + firstMovieId + " " +
                                "AND s.show_time > NOW() " +
                                "ORDER BY s.show_time";
            rs = stmt.executeQuery(scheduleSql);
            
            while (rs.next()) {
                Map<String, Object> schedule = new HashMap<>();
                schedule.put("id", rs.getInt("id"));
                schedule.put("show_time", rs.getTimestamp("show_time"));
                schedule.put("hall", rs.getString("hall"));
                schedule.put("price", rs.getDouble("price"));
                schedule.put("available_seats", rs.getInt("available_seats"));
                schedule.put("movie_name", rs.getString("movie_name"));
                scheduleList.add(schedule);
            }
            
            System.out.println("✅ booking.jsp: 查询到第一个电影的 " + scheduleList.size() + " 个排期");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        System.out.println("❌ booking.jsp 数据库错误: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>电影订票</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            min-height: 100vh; 
            padding: 20px; 
        }
        
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: rgba(255, 255, 255, 0.95); 
            padding: 30px; 
            border-radius: 15px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.2); 
        }
        
        h1 { 
            color: #2c3e50; 
            border-bottom: 2px solid #3498db; 
            padding-bottom: 10px; 
            margin-bottom: 20px;
            text-align: center;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        .user-info {
            font-size: 16px;
            color: #333;
        }
        
        .user-info a {
            color: #3498db;
            text-decoration: none;
            margin-left: 15px;
        }
        
        .user-info a:hover {
            text-decoration: underline;
        }
        
        .content {
            display: flex;
            gap: 30px;
        }
        
        .movie-selection {
            width: 300px;
        }
        
        .booking-form {
            flex: 1;
        }
        
        .movie-list {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            max-height: 500px;
            overflow-y: auto;
        }
        
        .movie-item {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
            background: white;
        }
        
        .movie-item:hover {
            background: #e9ecef;
            border-color: #3498db;
        }
        
        .movie-item.active {
            background: #3498db;
            color: white;
            border-color: #2980b9;
        }
        
        .movie-name {
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 8px;
        }
        
        .movie-details {
            font-size: 13px;
            color: #666;
            line-height: 1.4;
        }
        
        .movie-item.active .movie-details {
            color: rgba(255, 255, 255, 0.8);
        }
        
        .form-group { 
            margin-bottom: 20px; 
        }
        
        label { 
            display: block; 
            margin-bottom: 8px; 
            font-weight: bold; 
            color: #34495e; 
        }
        
        input, select, textarea { 
            width: 100%; 
            padding: 12px; 
            border: 1px solid #ddd; 
            border-radius: 8px; 
            font-size: 14px; 
            transition: border 0.3s;
        }
        
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        
        .required { 
            color: red; 
        }
        
        .btn { 
            padding: 14px 30px; 
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); 
            color: white; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            font-size: 16px; 
            font-weight: 500;
            transition: all 0.3s ease;
            width: 100%;
        }
        
        .btn:hover { 
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3);
        }
        
        .error { 
            color: red; 
            background: #ffe6e6; 
            padding: 12px; 
            border-radius: 8px; 
            margin-bottom: 20px; 
            border-left: 4px solid red;
        }
        
        .movie-info { 
            background: #e8f4fc; 
            padding: 20px; 
            border-radius: 10px; 
            margin-bottom: 25px; 
            text-align: center;
        }
        
        .schedule-list {
            margin-bottom: 20px;
        }
        
        .schedule-item {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .schedule-item:hover {
            border-color: #3498db;
            transform: translateY(-2px);
        }
        
        .schedule-item.selected {
            border-color: #3498db;
            background: #f0f8ff;
        }
        
        .schedule-time {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .schedule-hall {
            color: #3498db;
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        .schedule-price {
            color: #27ae60;
            font-weight: 600;
            font-size: 16px;
        }
        
        .schedule-seats {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 5px;
        }
        
        .empty-message {
            text-align: center;
            padding: 40px;
            color: #666;
            background: #f8f9fa;
            border-radius: 10px;
            margin: 20px 0;
        }
        
        .loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        
        @media (max-width: 768px) {
            .content {
                flex-direction: column;
            }
            
            .movie-selection {
                width: 100%;
            }
            
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎬 在线订票</h1>
            <div class="user-info">
                欢迎，<%= username != null ? username : user %> 
                <a href="OrderServlet?action=list">我的订单</a> 
                <a href="movie-list.jsp">电影列表</a>
                <a href="index.jsp">返回首页</a>
            </div>
        </div>
        
        <div class="movie-info">
            <h2 id="currentMovie"><%= movieTitle.isEmpty() ? "请选择电影" : movieTitle %></h2>
            <% if (!movieTitle.isEmpty()) { %>
                <p>已选电影：<strong><%= movieTitle %></strong></p>
            <% } %>
        </div>
        
        <div class="content">
            <!-- 左侧电影列表 -->
            <div class="movie-selection">
                <h3 style="margin-bottom: 15px; color: #333;">🎥 正在热映</h3>
                <div class="movie-list">
                    <% 
                        if (movieList.isEmpty()) {
                    %>
                        <div class="empty-message">
                            <p>暂无电影信息</p>
                            <p>请检查数据库连接或电影数据</p>
                        </div>
                    <% 
                        } else {
                            for (int i = 0; i < movieList.size(); i++) {
                                Map<String, Object> movie = movieList.get(i);
                                Integer id = (Integer) movie.get("id");
                                String name = (String) movie.get("movie_name");
                                Double price = (Double) movie.get("price");
                                Integer duration = (Integer) movie.get("duration");
                                String director = (String) movie.get("director");
                                
                                // 检查是否当前选中
                                boolean isActive = false;
                                if (movieId != null && !movieId.isEmpty()) {
                                    isActive = movieId.equals(id.toString());
                                } else {
                                    isActive = (i == 0); // 默认选中第一个
                                }
                    %>
                        <div class="movie-item <%= isActive ? "active" : "" %>" 
                             onclick="selectMovie(<%= id %>, '<%= name.replace("'", "\\'") %>')">
                            <div class="movie-name"><%= name %></div>
                            <div class="movie-details">
                                导演：<%= director %><br>
                                时长：<%= duration %>分钟<br>
                                票价：¥<%= String.format("%.2f", price) %>
                            </div>
                        </div>
                    <% 
                            }
                        }
                    %>
                </div>
            </div>
            
            <!-- 右侧订票表单 -->
            <div class="booking-form">
                <h3 style="margin-bottom: 15px; color: #333;">⏰ 场次选择</h3>
                
                <% if (scheduleList.isEmpty()) { %>
                    <div class="empty-message">
                        <p>该电影暂无排期信息</p>
                        <p>请选择其他电影或稍后再来查看</p>
                    </div>
                <% } else { %>
                    <div class="schedule-list" id="scheduleList">
                        <% 
                            for (Map<String, Object> schedule : scheduleList) {
                                Integer scheduleId = (Integer) schedule.get("id");
                                java.sql.Timestamp showTime = (java.sql.Timestamp) schedule.get("show_time");
                                String hall = (String) schedule.get("hall");
                                Double price = (Double) schedule.get("price");
                                Integer availableSeats = (Integer) schedule.get("available_seats");
                                String schedMovieName = (String) schedule.get("movie_name");
                                
                                // 格式化时间
                                java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm");
                                String showDate = dateFormat.format(showTime);
                                String showTimeStr = timeFormat.format(showTime);
                        %>
                            <div class="schedule-item" onclick="selectSchedule(<%= scheduleId %>, <%= price %>, '<%= hall %>')">
                                <div class="schedule-time"><%= showTimeStr %></div>
                                <div style="font-size: 12px; color: #666; margin-bottom: 5px;"><%= showDate %></div>
                                <div class="schedule-hall"><%= hall %></div>
                                <div class="schedule-price">¥<%= String.format("%.2f", price) %></div>
                                <div class="schedule-seats">剩余座位：<%= availableSeats %>个</div>
                            </div>
                        <% 
                            }
                        %>
                    </div>
                <% } %>
                
                <form action="OrderServlet" method="post" onsubmit="return validateForm()">
                    <!-- 隐藏字段 -->
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="userId" id="userId" value="<%= userId %>">
                    <input type="hidden" name="movieId" id="movieId" value="<%= movieId %>">
                    <input type="hidden" name="showtimeId" id="showtimeId" value="">
                    <input type="hidden" name="scheduleId" id="scheduleId" value="">
                    
                    <div class="form-group">
                        <label>座位选择 <span class="required">*</span></label>
                        <input type="text" name="seats" id="seats" placeholder="例如：A1,A2,B3" required
                               oninput="calculateTotal()">
                        <small>多个座位用逗号分隔</small>
                    </div>
                    
                    <div class="form-group">
                        <label>票数 <span class="required">*</span></label>
                        <input type="number" name="ticketCount" id="ticketCount" min="1" max="10" value="1" required
                               oninput="calculateTotal()">
                    </div>
                    
                    <div class="form-group">
                        <label>单价 (元)</label>
                        <input type="number" name="unitPrice" id="unitPrice" step="0.01" value="45.00" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>总价 (元)</label>
                        <input type="number" name="totalPrice" id="totalPrice" step="0.01" value="45.00" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>支付方式 <span class="required">*</span></label>
                        <select name="paymentMethod" id="paymentMethod" required>
                            <option value="">请选择支付方式</option>
                            <option value="wechat">微信支付</option>
                            <option value="alipay" selected>支付宝</option>
                            <option value="card">银行卡</option>
                            <option value="cash">现金</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>联系电话 <span class="required">*</span></label>
                        <input type="tel" name="phone" id="phone" placeholder="请输入联系电话" required>
                    </div>
                    
                    <div class="form-group">
                        <label>备注</label>
                        <textarea name="remark" id="remark" rows="3" placeholder="如有特殊需求请备注"></textarea>
                    </div>
                    
                    <button type="submit" class="btn">🎫 提交订单</button>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // 全局变量
        let selectedScheduleId = null;
        let selectedPrice = 45.00;
        let selectedHall = '';
        
        // 选择电影
        function selectMovie(movieId, movieName) {
            // 显示加载提示
            document.getElementById('currentMovie').innerHTML = '加载中...';
            
            // 跳转到当前页面并传入电影ID
            window.location.href = 'booking.jsp?movieId=' + movieId;
        }
        
        // 选择场次
        function selectSchedule(scheduleId, price, hall) {
            selectedScheduleId = scheduleId;
            selectedPrice = price;
            selectedHall = hall;
            
            // 移除所有场次的选中状态
            document.querySelectorAll('.schedule-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            // 为选中的场次添加选中状态
            event.currentTarget.classList.add('selected');
            
            // 更新表单字段
            document.getElementById('showtimeId').value = scheduleId;
            document.getElementById('scheduleId').value = scheduleId;
            document.getElementById('unitPrice').value = price.toFixed(2);
            
            // 计算总价
            calculateTotal();
            
            // 提示用户
            alert('已选择场次：' + hall + '，价格：¥' + price.toFixed(2));
        }
        
        // 计算总价
        function calculateTotal() {
            const ticketCount = parseInt(document.getElementById('ticketCount').value) || 1;
            const unitPrice = parseFloat(document.getElementById('unitPrice').value) || selectedPrice;
            const total = ticketCount * unitPrice;
            document.getElementById('totalPrice').value = total.toFixed(2);
            
            // 自动生成座位（示例）
            const seatInput = document.getElementById('seats');
            if (!seatInput.value && selectedScheduleId) {
                const seats = [];
                const rows = ['A', 'B', 'C', 'D', 'E'];
                for (let i = 1; i <= ticketCount && i <= 10; i++) {
                    seats.push(rows[Math.min(i-1, 4)] + i);
                }
                seatInput.value = seats.join(',');
            }
        }
        
        // 表单验证
        function validateForm() {
            const scheduleId = document.getElementById('scheduleId').value;
            const seats = document.getElementById('seats').value;
            const phone = document.getElementById('phone').value;
            const paymentMethod = document.getElementById('paymentMethod').value;
            
            if (!scheduleId) {
                alert('请选择场次！');
                return false;
            }
            
            if (!seats.trim()) {
                alert('请填写座位！');
                return false;
            }
            
            if (!phone.trim()) {
                alert('请输入联系电话！');
                return false;
            }
            
            if (!paymentMethod) {
                alert('请选择支付方式！');
                return false;
            }
            
            // 验证电话格式
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(phone.trim())) {
                alert('请输入有效的11位手机号码！');
                return false;
            }
            
            // 确认订单信息
            const confirmMsg = `请确认订单信息：\n\n` +
                              `场次ID: ${scheduleId}\n` +
                              `座位: ${seats}\n` +
                              `票数: ${document.getElementById('ticketCount').value}\n` +
                              `总价: ¥${document.getElementById('totalPrice').value}\n` +
                              `支付方式: ${getPaymentMethodName(paymentMethod)}\n` +
                              `电话: ${phone}`;
            
            return confirm(confirmMsg);
        }
        
        // 获取支付方式名称
        function getPaymentMethodName(method) {
            switch(method) {
                case 'wechat': return '微信支付';
                case 'alipay': return '支付宝';
                case 'card': return '银行卡';
                case 'cash': return '现金';
                default: return '未知';
            }
        }
        
        // 页面加载时初始化
        window.onload = function() {
            calculateTotal();
            
            // 如果URL中有movieId参数，滚动到对应电影
            const urlParams = new URLSearchParams(window.location.search);
            const movieId = urlParams.get('movieId');
            if (movieId) {
                const movieItem = document.querySelector(`.movie-item[onclick*="selectMovie(${movieId}"]`);
                if (movieItem) {
                    movieItem.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
            
            // 如果只有一个场次，自动选择
            const scheduleItems = document.querySelectorAll('.schedule-item');
            if (scheduleItems.length === 1) {
                scheduleItems[0].click();
            }
        };
    </script>
</body>
</html>