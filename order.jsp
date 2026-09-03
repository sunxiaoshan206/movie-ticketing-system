<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 用户验证
    String user = (String) session.getAttribute("user");
    String userId = (String) session.getAttribute("userId");
    
    if (user == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 数据库配置
    String DB_URL = "jdbc:mysql://localhost:3306/movie_ticket_system";
    String DB_USER = "root";
    String DB_PASSWORD = "123456";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <title>我的订单</title>
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
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #4a6bff 0%, #6b4aff 100%);
            color: white;
            padding: 30px 40px;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 16px;
            opacity: 0.9;
        }
        
        .user-info {
            background: rgba(255,255,255,0.1);
            padding: 10px 20px;
            border-radius: 10px;
            display: inline-block;
            margin-top: 15px;
        }
        
        .content {
            padding: 40px;
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: #666;
        }
        
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }
        
        .empty-state p {
            font-size: 16px;
            margin-bottom: 30px;
            color: #777;
        }
        
        .btn {
            display: inline-block;
            padding: 14px 32px;
            background: linear-gradient(135deg, #4a6bff 0%, #6b4aff 100%);
            color: white;
            text-decoration: none;
            border-radius: 50px;
            font-weight: bold;
            font-size: 16px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(74, 107, 255, 0.4);
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            margin-left: 15px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        thead {
            background: linear-gradient(135deg, #4a6bff 0%, #6b4aff 100%);
            color: white;
        }
        
        th {
            padding: 18px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 15px;
        }
        
        td {
            padding: 18px 15px;
            border-bottom: 1px solid #eee;
        }
        
        tr:hover {
            background: #f8f9ff;
        }
        
        .status {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
        }
        
        .status-paid {
            background: #e6f7ee;
            color: #00a854;
        }
        
        .status-unpaid {
            background: #fff7e6;
            color: #fa8c16;
        }
        
        .status-reviewed {
            background: #e6f3ff;
            color: #1890ff;
        }
        
        .order-id {
            font-family: monospace;
            background: #f5f5f5;
            padding: 4px 8px;
            border-radius: 4px;
            color: #333;
        }
        
        .movie-name {
            font-weight: 600;
            color: #333;
        }
        
        .price {
            font-weight: bold;
            color: #ff4d4f;
        }
        
        .time {
            color: #666;
            font-size: 14px;
        }
        
        .actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .action-btn {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s;
            border: none;
            cursor: pointer;
            white-space: nowrap;
        }
        
        .action-btn.view {
            background: #f0f5ff;
            color: #4a6bff;
            border: 1px solid #d6e4ff;
        }
        
        .action-btn.pay {
            background: #fff2e8;
            color: #fa8c16;
            border: 1px solid #ffd8b8;
        }
        
        .action-btn.review {
            background: linear-gradient(135deg, #ff9f43 0%, #ff7f00 100%);
            color: white;
            border: 1px solid #ffa726;
        }
        
        .action-btn.review:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 159, 67, 0.4);
        }
        
        .action-btn.reviewed {
            background: #28a745;
            color: white;
            border: 1px solid #218838;
            opacity: 0.8;
            cursor: not-allowed;
        }
        
        .action-btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
        
        .summary {
            margin-top: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            text-align: right;
            font-size: 14px;
            color: #666;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #f0f0f0;
            text-align: center;
        }
        
        .error-box {
            background: #fff2f0;
            border: 1px solid #ffccc7;
            color: #d4380d;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        
        .error-box h3 {
            margin-bottom: 10px;
            color: #d4380d;
        }
        
        /* 评价模态框样式 */
        .review-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .review-content {
            background: white;
            padding: 40px;
            border-radius: 15px;
            width: 500px;
            max-width: 90%;
            animation: slideIn 0.3s ease;
        }
        
        .stars {
            display: flex;
            gap: 10px;
            margin: 20px 0;
            justify-content: center;
        }
        
        .star {
            font-size: 36px;
            color: #ddd;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .star:hover,
        .star.active {
            color: #ffc107;
            transform: scale(1.2);
        }
        
        .star.hover {
            color: #ffc107;
        }
        
        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            resize: vertical;
            min-height: 100px;
        }
        
        .rating-text {
            text-align: center;
            margin: 15px 0;
            font-size: 16px;
            color: #ffc107;
            font-weight: bold;
            min-height: 24px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 我的订单</h1>
            <p>管理您的所有电影票订单</p>
            <div class="user-info">
                👤 当前用户：<strong><%= user %></strong> | 🆔 用户ID：<strong><%= userId %></strong>
            </div>
        </div>
        
        <div class="content">
            <%
                try {
                    // 加载数据库驱动
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    
                    // 建立数据库连接
                    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    
                    // 查询订单，同时检查是否已评价
                    String sql = "SELECT " +
                                "o.order_id, " +
                                "o.order_number, " +
                                "m.movie_name, " +
                                "o.total_price, " +
                                "o.ticket_count, " +
                                "o.seat_position, " +
                                "o.payment_status, " +
                                "o.create_time, " +
                                "o.order_status, " +
                                "CASE WHEN r.id IS NOT NULL THEN 1 ELSE 0 END as has_reviewed " +  // 是否已评价
                                "FROM orders o " +
                                "LEFT JOIN movies m ON o.movie_id = m.movie_id " +
                                "LEFT JOIN reviews r ON o.order_id = r.order_id " +  // 左连接评价表
                                "WHERE o.user_id = ? " +
                                "ORDER BY o.create_time DESC";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(userId));
                    rs = pstmt.executeQuery();
                    
                    // 检查是否有数据
                    if (!rs.isBeforeFirst()) {
            %>
                        <div class="empty-state">
                            <div style="font-size: 80px; color: #ddd; margin-bottom: 20px;">📭</div>
                            <h3>暂无订单</h3>
                            <p>您还没有任何电影票订单记录</p>
                            <p style="margin-top: 30px;">
                                <a href="movie-list.jsp" class="btn">🎬 浏览电影</a>
                                <a href="index.jsp" class="btn btn-secondary">🏠 返回首页</a>
                            </p>
                        </div>
            <%
                    } else {
                        int orderCount = 0;
                        int paidCount = 0;
                        int reviewCount = 0;
            %>
                        <table>
                            <thead>
                                <tr>
                                    <th>订单号</th>
                                    <th>电影名称</th>
                                    <th>座位</th>
                                    <th>票数</th>
                                    <th>总价</th>
                                    <th>支付状态</th>
                                    <th>评价状态</th>
                                    <th>下单时间</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    while (rs.next()) {
                                        orderCount++;
                                        String orderId = rs.getString("order_id");
                                        String orderNumber = rs.getString("order_number");
                                        String movieName = rs.getString("movie_name");
                                        String seats = rs.getString("seat_position");
                                        int ticketCount = rs.getInt("ticket_count");
                                        double totalPrice = rs.getDouble("total_price");
                                        int paymentStatus = rs.getInt("payment_status");
                                        String createTime = rs.getString("create_time");
                                        int orderStatus = rs.getInt("order_status");
                                        int hasReviewed = rs.getInt("has_reviewed");  // 是否已评价
                                        
                                        if (paymentStatus == 1) paidCount++;
                                        if (hasReviewed == 1) reviewCount++;
                                        
                                        // 格式化时间
                                        String formattedTime = createTime;
                                        try {
                                            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                            SimpleDateFormat outputFormat = new SimpleDateFormat("MM月dd日 HH:mm");
                                            formattedTime = outputFormat.format(inputFormat.parse(createTime));
                                        } catch (Exception e) {
                                            // 如果格式化失败，使用原始时间
                                        }
                                        
                                        // 设置状态文本和样式
                                        String statusText = "待支付";
                                        String statusClass = "status-unpaid";
                                        if (paymentStatus == 1) {
                                            statusText = "已支付";
                                            statusClass = "status-paid";
                                        }
                                        
                                        // 评价状态
                                        String reviewStatusText = "未评价";
                                        String reviewStatusClass = "status-unpaid";
                                        if (hasReviewed == 1) {
                                            reviewStatusText = "已评价";
                                            reviewStatusClass = "status-reviewed";
                                        }
                                %>
                                <tr>
                                    <td><span class="order-id"><%= orderNumber %></span></td>
                                    <td><span class="movie-name"><%= movieName != null ? movieName : "未知电影" %></span></td>
                                    <td><%= seats %></td>
                                    <td><%= ticketCount %>张</td>
                                    <td><span class="price">¥<%= String.format("%.2f", totalPrice) %></span></td>
                                    <td>
                                        <span class="status <%= statusClass %>">
                                            <%= statusText %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status <%= reviewStatusClass %>">
                                            <%= reviewStatusText %>
                                        </span>
                                    </td>
                                    <td><span class="time"><%= formattedTime %></span></td>
                                    <td>
                                        <div class="actions">
                                            <a href="order-detail.jsp?orderId=<%= orderId %>" class="action-btn view">详情</a>
                                            <%
                                                if (paymentStatus == 0 && orderStatus == 1) {
                                            %>
                                                    <a href="pay.jsp?orderId=<%= orderId %>" class="action-btn pay">支付</a>
                                            <%
                                                } else if (paymentStatus == 1 && hasReviewed == 0) {
                                                    // 已支付且未评价，显示评价按钮
                                            %>
                                                    <button class="action-btn review" 
                                                            onclick="openReviewModal('<%= orderId %>', '<%= movieName %>')">
                                                        ⭐ 评价
                                                    </button>
                                            <%
                                                } else if (hasReviewed == 1) {
                                                    // 已评价
                                            %>
                                                    <button class="action-btn reviewed" disabled>
                                                        ✅ 已评
                                                    </button>
                                            <%
                                                }
                                            %>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                        
                        <div class="summary">
                            <div style="display: flex; justify-content: space-between;">
                                <div>
                                    <span>订单总数: <strong><%= orderCount %></strong></span> | 
                                    <span>已支付: <strong><%= paidCount %></strong></span> | 
                                    <span>已评价: <strong><%= reviewCount %></strong></span>
                                </div>
                                <div>
                                    共 <strong><%= orderCount %></strong> 条订单记录
                                </div>
                            </div>
                        </div>
            <%
                    }
                    
                } catch (SQLException e) {
            %>
                    <div class="error-box">
                        <h3>⚠️ 数据库查询错误</h3>
                        <p><strong>错误信息：</strong> <%= e.getMessage() %></p>
                        <%
                            // 检查是否需要创建评价表
                            if (e.getMessage() != null && e.getMessage().contains("reviews")) {
                        %>
                                <p><strong>可能的原因：</strong>评价表不存在</p>
                                <p><strong>解决方案：</strong>需要创建评价表</p>
                                <button onclick="createReviewTable()" class="btn" style="margin-top: 10px;">
                                    创建评价表
                                </button>
                        <%
                            }
                        %>
                        <p style="margin-top: 15px;">
                            <a href="javascript:location.reload()" class="btn" style="padding: 10px 20px;">🔄 重新加载</a>
                        </p>
                    </div>
            <%
                } catch (ClassNotFoundException e) {
            %>
                    <div class="error-box">
                        <h3>⚠️ 数据库驱动错误</h3>
                        <p>MySQL 驱动未找到，请检查项目依赖</p>
                    </div>
            <%
                } catch (Exception e) {
            %>
                    <div class="error-box">
                        <h3>⚠️ 系统错误</h3>
                        <p><%= e.getMessage() %></p>
                    </div>
            <%
                } finally {
                    // 关闭数据库连接
                    try { if (rs != null) rs.close(); } catch (Exception e) {}
                    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
                    try { if (conn != null) conn.close(); } catch (Exception e) {}
                }
            %>
            
            <div class="footer">
                <a href="movie-list.jsp" class="btn">➕ 继续订票</a>
                <a href="index.jsp" class="btn btn-secondary">🏠 返回首页</a>
            </div>
        </div>
    </div>
    
    <!-- 评价模态框 -->
    <div id="reviewModal" class="review-modal">
        <div class="review-content">
            <h2 id="reviewMovieTitle" style="text-align: center; margin-bottom: 20px; color: #1a237e;"></h2>
            
            <div style="text-align: center; margin-bottom: 10px;">
                <span style="color: #666;">请为这部电影评分</span>
            </div>
            
            <div class="stars" id="starsContainer">
                <span class="star" data-value="1">☆</span>
                <span class="star" data-value="2">☆</span>
                <span class="star" data-value="3">☆</span>
                <span class="star" data-value="4">☆</span>
                <span class="star" data-value="5">☆</span>
            </div>
            
            <div class="rating-text" id="ratingText">请选择评分</div>
            
            <div class="form-group">
                <label>评价内容</label>
                <textarea id="reviewContent" rows="4" 
                          placeholder="请写下您的观影感受，分享您的想法..."></textarea>
            </div>
            
            <input type="hidden" id="currentOrderId">
            <input type="hidden" id="currentRating" value="0">
            
            <div style="display: flex; gap: 15px; margin-top: 30px;">
                <button onclick="submitReview()" class="btn" style="flex: 1; background: #00b894;">提交评价</button>
                <button onclick="closeReviewModal()" class="btn" style="flex: 1; background: #f8f9fa; color: #666;">取消</button>
            </div>
        </div>
    </div>
    
    <script>
        // 当前选中的评价数据
        let currentOrderId = '';
        let currentMovieName = '';
        
        // 打开评价模态框
        function openReviewModal(orderId, movieName) {
            currentOrderId = orderId;
            currentMovieName = movieName;
            
            document.getElementById('reviewMovieTitle').textContent = '评价《' + movieName + '》';
            document.getElementById('currentOrderId').value = orderId;
            document.getElementById('ratingText').textContent = '请选择评分';
            document.getElementById('reviewContent').value = '';
            document.getElementById('currentRating').value = '0';
            
            // 重置星星
            document.querySelectorAll('.star').forEach(star => {
                star.textContent = '☆';
                star.classList.remove('active', 'hover');
            });
            
            document.getElementById('reviewModal').style.display = 'flex';
        }
        
        // 关闭评价模态框
        function closeReviewModal() {
            document.getElementById('reviewModal').style.display = 'none';
        }
        
        // 星星评分功能
        document.querySelectorAll('.star').forEach(star => {
            star.addEventListener('click', function() {
                const rating = parseInt(this.getAttribute('data-value'));
                document.getElementById('currentRating').value = rating;
                
                // 更新星星显示
                document.querySelectorAll('.star').forEach((s, index) => {
                    if (index < rating) {
                        s.textContent = '★';
                        s.classList.add('active');
                    } else {
                        s.textContent = '☆';
                        s.classList.remove('active');
                    }
                });
                
                // 更新评分文字
                const ratingTexts = ['请选择评分', '很差', '一般', '还行', '推荐', '力荐'];
                document.getElementById('ratingText').textContent = ratingTexts[rating];
            });
            
            // 鼠标悬停效果
            star.addEventListener('mouseenter', function() {
                const rating = parseInt(this.getAttribute('data-value'));
                document.querySelectorAll('.star').forEach((s, index) => {
                    if (index < rating) {
                        s.classList.add('hover');
                    }
                });
            });
            
            star.addEventListener('mouseleave', function() {
                document.querySelectorAll('.star').forEach(s => {
                    s.classList.remove('hover');
                });
            });
        });
        
        // 提交评价
        function submitReview() {
            const orderId = document.getElementById('currentOrderId').value;
            const rating = document.getElementById('currentRating').value;
            const content = document.getElementById('reviewContent').value.trim();
            
            if (rating === '0') {
                alert('请选择评分！');
                return;
            }
            
            if (!content) {
                alert('请填写评价内容！');
                return;
            }
            
            if (content.length < 10) {
                alert('评价内容至少需要10个字符！');
                return;
            }
            
            // 显示加载状态
            const submitBtn = document.querySelector('#reviewModal .btn');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = '提交中...';
            submitBtn.disabled = true;
            
            // 使用AJAX提交评价
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'ReviewServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            xhr.onload = function() {
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
                
                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.success) {
                            alert('🎉 评价提交成功！');
                            closeReviewModal();
                            // 刷新页面
                            location.reload();
                        } else {
                            alert('❌ 评价提交失败：' + response.message);
                        }
                    } catch (e) {
                        alert('❌ 响应解析失败：' + xhr.responseText);
                    }
                } else {
                    alert('❌ 提交失败，请稍后重试');
                }
            };
            
            xhr.onerror = function() {
                submitBtn.textContent = originalText;
                submitBtn.disabled = false;
                alert('❌ 网络错误，请检查网络连接');
            };
            
            const params = 'action=add' +
                          '&order_id=' + encodeURIComponent(orderId) +
                          '&rating=' + encodeURIComponent(rating) +
                          '&content=' + encodeURIComponent(content);
            
            xhr.send(params);
        }
        
        // 创建评价表（如果不存在）
        function createReviewTable() {
            if (!confirm('确定要创建评价表吗？')) {
                return;
            }
            
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'ReviewServlet', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            xhr.onload = function() {
                if (xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        alert('✅ 评价表创建成功！');
                        location.reload();
                    } else {
                        alert('❌ 创建失败：' + response.message);
                    }
                } else {
                    alert('❌ 创建失败');
                }
            };
            
            xhr.send('action=create_table');
        }
        
        // 点击模态框外部关闭
        window.onclick = function(event) {
            const modal = document.getElementById('reviewModal');
            if (event.target === modal) {
                closeReviewModal();
            }
        }
        
        // 页面加载时的交互效果
        document.addEventListener('DOMContentLoaded', function() {
            // 支付按钮确认
            var payButtons = document.querySelectorAll('.action-btn.pay');
            payButtons.forEach(function(btn) {
                btn.addEventListener('click', function(e) {
                    if (!confirm('确定要前往支付页面吗？')) {
                        e.preventDefault();
                    }
                });
            });
            
            // 行悬停效果
            var tableRows = document.querySelectorAll('tbody tr');
            tableRows.forEach(function(row) {
                row.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 5px 15px rgba(0,0,0,0.1)';
                });
                row.addEventListener('mouseleave', function() {
                    this.style.transform = '';
                    this.style.boxShadow = '';
                });
            });
        });
    </script>
</body>
</html>