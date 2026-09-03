<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 用户登录检查
    String user = (String) session.getAttribute("user");
    String userId = (String) session.getAttribute("userId");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取电影ID
    String movieId = request.getParameter("movieId");
    if (movieId == null || movieId.trim().isEmpty()) {
        // 重定向到正确的电影列表页面
        response.sendRedirect("movie-list.jsp");
        return;
    }
    
    // 电影信息变量
    String movieName = "未知电影";
    String director = "未知导演";
    int duration = 120;
    double price = 45.0;
    String showtime = "";
    String hall = "1号厅";
    int scheduleId = 0;
    
    // 从数据库查询电影信息
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/movie_ticket_system", 
            "root", 
            "123456");
        
        // 1. 查询电影信息
        String sql = "SELECT movie_name, director, duration, price FROM movies WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(movieId));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            movieName = rs.getString("movie_name");
            director = rs.getString("director");
            duration = rs.getInt("duration");
            price = rs.getDouble("price");
        }
        rs.close();
        pstmt.close();
        
        // 2. 查询场次信息 - 简化版，只获取show_time
        sql = "SELECT id, show_time FROM schedules WHERE movie_id = ? ORDER BY show_time LIMIT 1";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(movieId));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            scheduleId = rs.getInt("id");
            showtime = rs.getString("show_time");
        } else {
            // 如果没有场次，创建一个默认场次
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String defaultShowtime = sdf.format(new java.util.Date());
            showtime = defaultShowtime;
            scheduleId = 100 + Integer.parseInt(movieId);
        }
        rs.close();
        pstmt.close();
        
        // 将电影信息存入session，用于订单提交
        session.setAttribute("selectedMovieId", movieId);
        session.setAttribute("selectedMovieName", movieName);
        session.setAttribute("selectedMoviePrice", price);
        session.setAttribute("selectedShowtime", showtime);
        session.setAttribute("selectedHall", hall);
        session.setAttribute("selectedScheduleId", scheduleId);
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('数据库错误: " + e.getMessage() + "');</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>选座购票 - <%= movieName %></title>
    <meta charset="UTF-8">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body { 
            font-family: 'Microsoft YaHei', Arial, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            margin: 0; 
            padding: 0;
            min-height: 100vh;
            color: #333;
        }
        
        .header { 
            background: linear-gradient(90deg, #1a237e, #283593);
            color: white; 
            padding: 20px 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .header-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 28px;
            margin: 0;
            font-weight: bold;
        }
        
        .user-info {
            font-size: 16px;
        }
        
        .container { 
            max-width: 1200px; 
            margin: 30px auto; 
            padding: 0 20px; 
        }
        
        .movie-info { 
            background: white; 
            padding: 25px; 
            border-radius: 12px; 
            margin-bottom: 25px; 
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            border-left: 6px solid #2196F3;
        }
        
        .movie-info h2 {
            color: #1a237e;
            margin-bottom: 20px;
            font-size: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        
        .info-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #42a5f5;
        }
        
        .info-item strong {
            color: #555;
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .info-item span {
            font-size: 18px;
            color: #1a237e;
            font-weight: 600;
        }
        
        .price-highlight {
            color: #e53935 !important;
            font-size: 22px !important;
        }
        
        .seat-map-container { 
            background: white; 
            padding: 25px; 
            border-radius: 12px; 
            margin-bottom: 25px; 
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .screen { 
            text-align: center; 
            font-size: 24px; 
            font-weight: bold;
            color: #1a237e; 
            margin: 30px 0 40px; 
            padding: 20px;
            background: linear-gradient(90deg, #e3f2fd, #bbdefb);
            border-radius: 10px;
            letter-spacing: 3px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.1);
            position: relative;
        }
        
        .screen:before {
            content: "";
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            width: 80%;
            height: 20px;
            background: linear-gradient(to bottom, rgba(0,0,0,0.1), transparent);
            border-radius: 50%;
        }
        
        .seats-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            margin: 20px 0;
        }
        
        .seat-row { 
            display: flex; 
            gap: 10px; 
            margin: 10px 0; 
        }
        
        .seat { 
            width: 45px; 
            height: 45px; 
            background: white;
            border: 2px solid #42a5f5;
            border-radius: 8px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            cursor: pointer; 
            font-size: 14px;
            font-weight: bold;
            color: #1a237e;
            box-shadow: 0 2px 5px rgba(66, 165, 245, 0.2);
            transition: all 0.2s ease;
            user-select: none;
        }
        
        .seat:hover { 
            background: #e3f2fd; 
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(66, 165, 245, 0.3);
        }
        
        .seat.selected { 
            background: #4caf50; 
            color: white; 
            border-color: #388e3c;
            box-shadow: 0 2px 5px rgba(76, 175, 80, 0.3);
        }
        
        .seat.booked { 
            background: #e53935; 
            color: white;
            border-color: #c62828;
            cursor: not-allowed;
            opacity: 0.7;
        }
        
        .legend { 
            display: flex; 
            justify-content: center;
            gap: 30px; 
            margin: 25px 0; 
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .legend-item { 
            display: flex; 
            align-items: center; 
            gap: 10px;
            font-weight: 600;
            color: #555;
        }
        
        .order-summary { 
            background: white; 
            padding: 25px; 
            border-radius: 12px; 
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            border-top: 6px solid #4caf50;
        }
        
        .order-summary h3 {
            color: #1a237e;
            margin-bottom: 20px;
            font-size: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .summary-item {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border: 1px solid #e0e0e0;
        }
        
        .summary-label {
            color: #666;
            font-size: 14px;
            margin-bottom: 8px;
            display: block;
        }
        
        .summary-value {
            font-size: 24px;
            font-weight: bold;
            color: #1a237e;
        }
        
        .total-price {
            color: #e53935 !important;
            font-size: 28px !important;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        
        .btn { 
            padding: 14px 35px; 
            background: linear-gradient(90deg, #2196F3, #1976D2);
            color: white; 
            border: none; 
            border-radius: 8px; 
            font-size: 16px; 
            font-weight: 600;
            cursor: pointer; 
            transition: all 0.3s ease;
            box-shadow: 0 4px 8px rgba(33, 150, 243, 0.3);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-success { 
            background: linear-gradient(90deg, #4caf50, #388e3c);
            box-shadow: 0 4px 8px rgba(76, 175, 80, 0.3);
        }
        
        .btn:hover { 
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(33, 150, 243, 0.4);
        }
        
        .btn-success:hover {
            box-shadow: 0 6px 12px rgba(76, 175, 80, 0.4);
        }
        
        .btn-back {
            background: #f5f5f5;
            color: #666;
            text-decoration: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .btn-back:hover {
            background: #e0e0e0;
            color: #333;
        }
        
        @media (max-width: 768px) {
            .header-container {
                flex-direction: column;
                text-align: center;
                gap: 10px;
            }
            
            .seat {
                width: 35px;
                height: 35px;
                font-size: 12px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn, .btn-back {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-container">
            <h1>🎬 在线选座购票</h1>
            <div class="user-info">
                欢迎您，<strong><%= user %></strong> | 用户ID: <%= userId %>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- 电影信息 -->
        <div class="movie-info">
            <h2>🎞️ <%= movieName %></h2>
            <div class="info-grid">
                <div class="info-item">
                    <strong>导演</strong>
                    <span><%= director %></span>
                </div>
                <div class="info-item">
                    <strong>时长</strong>
                    <span><%= duration %> 分钟</span>
                </div>
                <div class="info-item">
                    <strong>场次时间</strong>
                    <span><%= showtime %></span>
                </div>
                <div class="info-item">
                    <strong>影厅</strong>
                    <span><%= hall %></span>
                </div>
                <div class="info-item">
                    <strong>单张票价</strong>
                    <span class="price-highlight">¥ <%= String.format("%.2f", price) %></span>
                </div>
            </div>
        </div>
        
        <!-- 座位图 -->
        <div class="seat-map-container">
            <div class="screen">🎬 🎬 🎬 银 幕 🎬 🎬 🎬</div>
            
            <div class="seats-section" id="seatSection">
        
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'A1')">A1</div>
                    <div class="seat" onclick="selectSeat(this, 'A2')">A2</div>
                    <div class="seat" onclick="selectSeat(this, 'A3')">A3</div>
                    <div class="seat booked">A4</div>
                    <div class="seat" onclick="selectSeat(this, 'A5')">A5</div>
                    <div class="seat" onclick="selectSeat(this, 'A6')">A6</div>
                    <div class="seat" onclick="selectSeat(this, 'A7')">A7</div>
                    <div class="seat booked">A8</div>
                </div>
                
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'B1')">B1</div>
                    <div class="seat" onclick="selectSeat(this, 'B2')">B2</div>
                    <div class="seat booked">B3</div>
                    <div class="seat" onclick="selectSeat(this, 'B4')">B4</div>
                    <div class="seat" onclick="selectSeat(this, 'B5')">B5</div>
                    <div class="seat" onclick="selectSeat(this, 'B6')">B6</div>
                    <div class="seat booked">B7</div>
                    <div class="seat" onclick="selectSeat(this, 'B8')">B8</div>
                </div>
                
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'C1')">C1</div>
                    <div class="seat" onclick="selectSeat(this, 'C2')">C2</div>
                    <div class="seat" onclick="selectSeat(this, 'C3')">C3</div>
                    <div class="seat" onclick="selectSeat(this, 'C4')">C4</div>
                    <div class="seat" onclick="selectSeat(this, 'C5')">C5</div>
                    <div class="seat" onclick="selectSeat(this, 'C6')">C6</div>
                    <div class="seat" onclick="selectSeat(this, 'C7')">C7</div>
                    <div class="seat" onclick="selectSeat(this, 'C8')">C8</div>
                </div>
                
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'D1')">D1</div>
                    <div class="seat" onclick="selectSeat(this, 'D2')">D2</div>
                    <div class="seat booked">D3</div>
                    <div class="seat" onclick="selectSeat(this, 'D4')">D4</div>
                    <div class="seat" onclick="selectSeat(this, 'D5')">D5</div>
                    <div class="seat booked">D6</div>
                    <div class="seat" onclick="selectSeat(this, 'D7')">D7</div>
                    <div class="seat" onclick="selectSeat(this, 'D8')">D8</div>
                </div>
                
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'E1')">E1</div>
                    <div class="seat" onclick="selectSeat(this, 'E2')">E2</div>
                    <div class="seat" onclick="selectSeat(this, 'E3')">E3</div>
                    <div class="seat" onclick="selectSeat(this, 'E4')">E4</div>
                    <div class="seat" onclick="selectSeat(this, 'E5')">E5</div>
                    <div class="seat" onclick="selectSeat(this, 'E6')">E6</div>
                    <div class="seat" onclick="selectSeat(this, 'E7')">E7</div>
                    <div class="seat" onclick="selectSeat(this, 'E8')">E8</div>
                </div>
                
                <div class="seat-row">
                    <div class="seat" onclick="selectSeat(this, 'F1')">F1</div>
                    <div class="seat" onclick="selectSeat(this, 'F2')">F2</div>
                    <div class="seat" onclick="selectSeat(this, 'F3')">F3</div>
                    <div class="seat booked">F4</div>
                    <div class="seat" onclick="selectSeat(this, 'F5')">F5</div>
                    <div class="seat booked">F6</div>
                    <div class="seat" onclick="selectSeat(this, 'F7')">F7</div>
                    <div class="seat" onclick="selectSeat(this, 'F8')">F8</div>
                </div>
            </div>
            
            <div class="legend">
                <div class="legend-item">
                    <div class="seat" style="background:white; border-color:#42a5f5;"></div>
                    <span>可选座位</span>
                </div>
                <div class="legend-item">
                    <div class="seat" style="background:#4caf50; border-color:#388e3c;"></div>
                    <span>已选座位</span>
                </div>
                <div class="legend-item">
                    <div class="seat" style="background:#e53935; border-color:#c62828;"></div>
                    <span>已售座位</span>
                </div>
            </div>
        </div>
        
        <!-- 订单摘要 -->
        <div class="order-summary">
            <h3>📋 订单信息</h3>
            <div class="summary-grid">
                <div class="summary-item">
                    <span class="summary-label">已选座位</span>
                    <span class="summary-value" id="selectedSeats">无</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">票数</span>
                    <span class="summary-value" id="ticketCount">0</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label">总价</span>
                    <span class="summary-value total-price" id="totalPrice">¥ 0.00</span>
                </div>
            </div>
            
            <div class="action-buttons">
                <button class="btn btn-success" onclick="confirmOrder()">
                    <span>✅</span> 确认购票
                </button>
                <a href="movie-list.jsp" class="btn-back">
                    <span>←</span> 返回电影列表
                </a>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        // 存储选中的座位
        let selectedSeats = [];
        const price = <%= price %>;
        const movieId = '<%= movieId %>';
        const movieName = '<%= movieName %>';
        const scheduleId = <%= scheduleId %>;
        const userId = '<%= userId %>';
        
        // 预定义已售座位（硬编码）
        const bookedSeats = new Set(['A4', 'A8', 'B3', 'B7', 'D3', 'D6', 'F4', 'F6']);
        
        // 选座函数
        function selectSeat(element, seatId) {
            // 如果座位已售出，不处理
            if (bookedSeats.has(seatId)) {
                alert('⚠️ 这个座位已售出，请选择其他座位');
                return;
            }
            
            // 切换选中状态
            if (element.classList.contains('selected')) {
                // 取消选中
                element.classList.remove('selected');
                // 从数组中移除
                const index = selectedSeats.indexOf(seatId);
                if (index > -1) {
                    selectedSeats.splice(index, 1);
                }
            } else {
                // 选中
                element.classList.add('selected');
                selectedSeats.push(seatId);
            }
            
            // 更新订单信息
            updateOrderSummary();
        }
        
        // 更新订单信息
        function updateOrderSummary() {
            const total = selectedSeats.length * price;
            
            // 更新显示
            document.getElementById('selectedSeats').textContent = 
                selectedSeats.length > 0 ? selectedSeats.join(', ') : '无';
            document.getElementById('ticketCount').textContent = selectedSeats.length;
            document.getElementById('totalPrice').textContent = '¥ ' + total.toFixed(2);
        }
        
        // 确认订单
        function confirmOrder() {
            if (selectedSeats.length === 0) {
                alert('⚠️ 请先选择座位！');
                return;
            }
            
            const totalPrice = selectedSeats.length * price;
            const confirmMsg = `请确认购票信息：\n\n` +
                              `🎬 电影：${movieName}\n` +
                              `🎫 票数：${selectedSeats.length} 张\n` +
                              `💺 座位：${selectedSeats.join(', ')}\n` +
                              `💰 总价：¥${totalPrice.toFixed(2)}\n\n` +
                              `确定要购买吗？`;
            
            if (confirm(confirmMsg)) {
                submitOrder();
            }
        }
        
        // 提交订单到OrderServlet
        function submitOrder() {
            // 显示加载中
            const btn = document.querySelector('.btn-success');
            const originalText = btn.innerHTML;
            btn.innerHTML = '<span>⏳</span> 处理中...';
            btn.disabled = true;
            
            // 创建表单
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'OrderServlet';
            form.style.display = 'none';
            
            // 添加隐藏字段
            function addInput(name, value) {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = name;
                input.value = value;
                form.appendChild(input);
            }
            
            addInput('action', 'create');
            addInput('userId', userId);
            addInput('movieId', movieId);
            addInput('scheduleId', scheduleId);
            addInput('seats', selectedSeats.join(','));
            addInput('ticketCount', selectedSeats.length.toString());
            addInput('totalPrice', (selectedSeats.length * price).toFixed(2));
            addInput('paymentMethod', 'alipay');
            addInput('phone', '');
            addInput('remark', '');
            
            // 提交表单
            document.body.appendChild(form);
            form.submit();
        }
        
        // 初始更新
        updateOrderSummary();
        
        // 添加键盘快捷键支持
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                // ESC键清空选择
                selectedSeats = [];
                document.querySelectorAll('.seat.selected').forEach(seat => {
                    seat.classList.remove('selected');
                });
                updateOrderSummary();
            } else if (event.key === 'Enter' && selectedSeats.length > 0) {
                // Enter键确认订单
                confirmOrder();
            }
        });
    </script>
</body>
</html>