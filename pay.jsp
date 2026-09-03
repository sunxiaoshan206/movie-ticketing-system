<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    // 用户验证
    String user = (String) session.getAttribute("user");
    String userId = (String) session.getAttribute("userId");
    
    if (user == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取订单ID
    String orderId = request.getParameter("orderId");
    if (orderId == null || orderId.trim().isEmpty()) {
        response.sendRedirect("my-orders.jsp?error=订单不存在");
        return;
    }
    
    // 数据库配置
    String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    String DB_USER = "root";
    String DB_PASSWORD = "123456";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String orderNumber = "";
    String movieName = "";
    double totalPrice = 0;
    String seats = "";
    int ticketCount = 0;
    int currentStatus = 0;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        
        // 查询订单信息
        String sql = "SELECT o.order_number, m.movie_name, o.total_price, " +
                    "o.seat_position, o.ticket_count, o.payment_status " +
                    "FROM orders o " +
                    "LEFT JOIN movies m ON o.movie_id = m.movie_id " +
                    "WHERE o.order_id = ? AND o.user_id = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, orderId);
        pstmt.setInt(2, Integer.parseInt(userId));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            orderNumber = rs.getString("order_number");
            movieName = rs.getString("movie_name");
            totalPrice = rs.getDouble("total_price");
            seats = rs.getString("seat_position");
            ticketCount = rs.getInt("ticket_count");
            currentStatus = rs.getInt("payment_status");
            
            // 如果已支付，跳转到订单页面
            if (currentStatus == 1) {
                response.sendRedirect("order-detail.jsp?orderId=" + orderId);
                return;
            }
        } else {
            response.sendRedirect("my-orders.jsp?error=订单不存在");
            return;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("my-orders.jsp?error=" + e.getMessage());
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>支付订单</title>
    <meta charset="UTF-8">
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
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            max-width: 800px;
            width: 100%;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
            color: white;
            padding: 30px 40px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }
        
        .header p {
            font-size: 16px;
            opacity: 0.9;
        }
        
        .content {
            padding: 40px;
        }
        
        .order-info {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            border-left: 5px solid #00b894;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .info-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .info-label {
            width: 120px;
            font-weight: 600;
            color: #555;
        }
        
        .info-value {
            flex: 1;
            color: #333;
        }
        
        .info-value.highlight {
            color: #ff4d4f;
            font-size: 24px;
            font-weight: bold;
        }
        
        .payment-methods {
            margin-bottom: 40px;
        }
        
        .payment-methods h3 {
            margin-bottom: 20px;
            color: #333;
            font-size: 20px;
        }
        
        .methods-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .method-card {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }
        
        .method-card:hover {
            border-color: #00b894;
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 184, 148, 0.2);
        }
        
        .method-card.selected {
            border-color: #00b894;
            background: #e6f7f0;
        }
        
        .method-icon {
            font-size: 36px;
            margin-bottom: 10px;
        }
        
        .method-name {
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 5px;
            color: #333;
        }
        
        .method-desc {
            font-size: 14px;
            color: #666;
        }
        
        .action-buttons {
            display: flex;
            gap: 20px;
            margin-top: 40px;
        }
        
        .btn {
            flex: 1;
            padding: 16px 30px;
            border-radius: 12px;
            font-size: 16px;
            font-weight: bold;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            text-decoration: none;
        }
        
        .btn-pay {
            background: linear-gradient(135deg, #00b894 0%, #00a085 100%);
            color: white;
        }
        
        .btn-pay:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 184, 148, 0.4);
        }
        
        .btn-cancel {
            background: #f8f9fa;
            color: #666;
            border: 2px solid #e0e0e0;
        }
        
        .btn-cancel:hover {
            background: #e9ecef;
        }
        
        .qr-code {
            text-align: center;
            margin: 30px 0;
            display: none;
        }
        
        .qr-code.show {
            display: block;
            animation: fadeIn 0.5s ease;
        }
        
        .qr-image {
            width: 200px;
            height: 200px;
            background: #f0f0f0;
            border-radius: 10px;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            color: #333;
        }
        
        .qr-instruction {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }
        
        .success-message {
            text-align: center;
            padding: 40px;
            display: none;
        }
        
        .success-message.show {
            display: block;
            animation: fadeIn 0.5s ease;
        }
        
        .success-icon {
            font-size: 80px;
            color: #00b894;
            margin-bottom: 20px;
        }
        
        .success-message h2 {
            color: #00b894;
            margin-bottom: 15px;
        }
        
        .success-message p {
            color: #666;
            margin-bottom: 30px;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 40px;
        }
        
        .loading.show {
            display: block;
        }
        
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #00b894;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .error-message {
            background: #fff2f0;
            border: 1px solid #ffccc7;
            color: #d4380d;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
        }
        
        .error-message.show {
            display: block;
        }
        
        .timer {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 14px;
        }
        
        .timer-number {
            color: #ff4d4f;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💰 订单支付</h1>
            <p>请完成支付以确认订单</p>
        </div>
        
        <div class="content">
            <div class="order-info">
                <div class="info-row">
                    <div class="info-label">订单号：</div>
                    <div class="info-value"><strong><%= orderNumber %></strong></div>
                </div>
                <div class="info-row">
                    <div class="info-label">电影名称：</div>
                    <div class="info-value"><%= movieName %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">座位：</div>
                    <div class="info-value"><%= seats %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">票数：</div>
                    <div class="info-value"><%= ticketCount %>张</div>
                </div>
                <div class="info-row">
                    <div class="info-label">支付金额：</div>
                    <div class="info-value highlight">¥<%= String.format("%.2f", totalPrice) %></div>
                </div>
            </div>
            
            <div class="payment-methods">
                <h3>请选择支付方式</h3>
                <div class="methods-grid">
                    <div class="method-card" data-method="wechat" onclick="selectPaymentMethod('wechat')">
                        <div class="method-icon">💳</div>
                        <div class="method-name">微信支付</div>
                        <div class="method-desc">推荐使用微信扫码支付</div>
                    </div>
                    
                    <div class="method-card" data-method="alipay" onclick="selectPaymentMethod('alipay')">
                        <div class="method-icon">💰</div>
                        <div class="method-name">支付宝</div>
                        <div class="method-desc">支持支付宝扫码支付</div>
                    </div>
                    
                    <div class="method-card" data-method="card" onclick="selectPaymentMethod('card')">
                        <div class="method-icon">🏦</div>
                        <div class="method-name">银行卡</div>
                        <div class="method-desc">支持储蓄卡/信用卡</div>
                    </div>
                    
                    <div class="method-card" data-method="balance" onclick="selectPaymentMethod('balance')">
                        <div class="method-icon">⚡</div>
                        <div class="method-name">余额支付</div>
                        <div class="method-desc">使用账户余额支付</div>
                    </div>
                </div>
            </div>
            
            <div class="qr-code" id="qrCodeSection">
                <div class="qr-image" id="qrImage">
                    <!-- 这里显示二维码图片 -->
                    📱
                </div>
                <p>请使用<strong id="paymentApp">微信</strong>扫描二维码完成支付</p>
                <p class="qr-instruction">支付完成后，请不要关闭此页面，系统会自动跳转</p>
            </div>
            
            <div class="error-message" id="errorMessage">
                <h3>⚠️ 支付失败</h3>
                <p id="errorText"></p>
            </div>
            
            <div class="loading" id="loadingSection">
                <div class="spinner"></div>
                <p>正在处理支付，请稍候...</p>
            </div>
            
            <div class="success-message" id="successMessage">
                <div class="success-icon">✅</div>
                <h2>支付成功！</h2>
                <p>订单支付已完成，正在为您跳转到订单详情...</p>
            </div>
            
            <div class="action-buttons">
                <a href="my-orders.jsp" class="btn btn-cancel">取消支付</a>
                <button class="btn btn-pay" onclick="processPayment()" id="payButton">立即支付</button>
            </div>
            
            <div class="timer" id="timerSection">
                支付剩余时间：<span class="timer-number" id="timer">900</span>秒
            </div>
        </div>
    </div>
    
    <script>
        // 选中的支付方式
        let selectedMethod = 'wechat';
        let timerInterval;
        let secondsLeft = 900; // 15分钟
        
        // 选择支付方式
        function selectPaymentMethod(method) {
            selectedMethod = method;
            
            // 更新卡片选中状态
            document.querySelectorAll('.method-card').forEach(card => {
                card.classList.remove('selected');
            });
            document.querySelector(`.method-card[data-method="${method}"]`).classList.add('selected');
            
            // 更新二维码区域显示
            const qrSection = document.getElementById('qrCodeSection');
            const paymentApp = document.getElementById('paymentApp');
            
            switch(method) {
                case 'wechat':
                    paymentApp.textContent = '微信';
                    qrSection.querySelector('.qr-image').textContent = '💳';
                    break;
                case 'alipay':
                    paymentApp.textContent = '支付宝';
                    qrSection.querySelector('.qr-image').textContent = '💰';
                    break;
                case 'card':
                    paymentApp.textContent = '手机银行';
                    qrSection.querySelector('.qr-image').textContent = '🏦';
                    break;
                case 'balance':
                    paymentApp.textContent = '账户';
                    qrSection.querySelector('.qr-image').textContent = '⚡';
                    break;
            }
        }
        
        // 处理支付
        function processPayment() {
            // 显示加载中
            document.getElementById('loadingSection').classList.add('show');
            document.getElementById('payButton').disabled = true;
            
            // 模拟支付处理
            setTimeout(() => {
                // 隐藏加载中
                document.getElementById('loadingSection').classList.remove('show');
                
                // 显示二维码
                document.getElementById('qrCodeSection').classList.add('show');
                
                // 隐藏支付按钮，显示倒计时
                document.querySelector('.action-buttons').style.display = 'none';
                document.getElementById('timerSection').style.display = 'block';
                
                // 开始倒计时
                startTimer();
                
                // 5秒后模拟支付成功（实际应该通过轮询服务器检查支付状态）
                setTimeout(() => {
                    completePayment();
                }, 5000);
                
            }, 2000);
        }
        
        // 开始倒计时
        function startTimer() {
            timerInterval = setInterval(() => {
                secondsLeft--;
                document.getElementById('timer').textContent = secondsLeft;
                
                if (secondsLeft <= 0) {
                    clearInterval(timerInterval);
                    showError('支付超时，请重新支付');
                    resetPaymentUI();
                }
            }, 1000);
        }
        
        // 完成支付
        function completePayment() {
            // 停止倒计时
            clearInterval(timerInterval);
            
            // 发送支付请求到服务器
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'PayServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            // 显示成功消息
                            document.getElementById('qrCodeSection').classList.remove('show');
                            document.getElementById('successMessage').classList.add('show');
                            
                            // 3秒后跳转到订单详情
                            setTimeout(() => {
                                window.location.href = 'order-detail.jsp?orderId=<%= orderId %>';
                            }, 3000);
                        } else {
                            showError(response.message || '支付失败');
                            resetPaymentUI();
                        }
                    } catch (e) {
                        showError('支付结果解析失败');
                        resetPaymentUI();
                    }
                } else {
                    showError('支付请求失败，状态码：' + xhr.status);
                    resetPaymentUI();
                }
            };
            
            xhr.onerror = function() {
                showError('网络错误，请检查网络连接');
                resetPaymentUI();
            };
            
            const params = 'action=pay' +
                          '&order_id=<%= orderId %>' +
                          '&payment_method=' + encodeURIComponent(selectedMethod) +
                          '&amount=<%= totalPrice %>';
            
            xhr.send(params);
        }
        
        // 显示错误消息
        function showError(message) {
            document.getElementById('errorText').textContent = message;
            document.getElementById('errorMessage').classList.add('show');
            
            // 3秒后自动隐藏错误消息
            setTimeout(() => {
                document.getElementById('errorMessage').classList.remove('show');
            }, 3000);
        }
        
        // 重置支付UI
        function resetPaymentUI() {
            document.getElementById('qrCodeSection').classList.remove('show');
            document.querySelector('.action-buttons').style.display = 'flex';
            document.getElementById('timerSection').style.display = 'none';
            document.getElementById('payButton').disabled = false;
            secondsLeft = 900;
            document.getElementById('timer').textContent = secondsLeft;
        }
        
        // 页面加载时初始化
        document.addEventListener('DOMContentLoaded', function() {
            // 默认选择微信支付
            selectPaymentMethod('wechat');
            
            // 隐藏计时器
            document.getElementById('timerSection').style.display = 'none';
            
            // 如果订单已支付，显示提示并跳转
            if (<%= currentStatus %> == 1) {
                alert('订单已支付，正在跳转到订单详情...');
                window.location.href = 'order-detail.jsp?orderId=<%= orderId %>';
            }
        });
        
        // 页面卸载时清理计时器
        window.addEventListener('beforeunload', function() {
            if (timerInterval) {
                clearInterval(timerInterval);
            }
        });
    </script>
</body>
</html>