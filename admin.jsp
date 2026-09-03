<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("role");
    String user = (String) session.getAttribute("user");
    
    if(!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>管理员面板 - 电影票务系统</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: #f0f2f5;
            margin: 0;
            color: #333;
        }
        .admin-header {
            background: linear-gradient(135deg, #1a237e 0%, #3949ab 100%);
            color: white;
            padding: 30px 20px;
        }
        .admin-nav {
            background: #333;
            padding: 15px 20px;
        }
        .admin-nav a {
            color: white;
            text-decoration: none;
            margin-right: 15px;
            padding: 8px 15px;
            border-radius: 4px;
        }
        .admin-nav a:hover {
            background: rgba(255,255,255,0.1);
        }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 5px solid;
        }
        .stat-card:nth-child(1) { border-color: #667eea; }
        .stat-card:nth-child(2) { border-color: #4CAF50; }
        .stat-card:nth-child(3) { border-color: #ff9800; }
        .stat-card:nth-child(4) { border-color: #f44336; }
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin: 10px 0;
        }
        .modules {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin: 40px 0;
        }
        .module-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            text-align: center;
        }
        .module-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 5px;
        }
        .btn-primary { background: #2196f3; }
        .btn-success { background: #4CAF50; }
        .btn-warning { background: #ff9800; }
        .btn-danger { background: #f44336; }
        .table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin: 40px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            border-top: 1px solid #eee;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="admin-header">
        <h1>👑 管理员控制面板</h1>
        <p>欢迎，管理员 <%= user %>！</p>
    </div>
    
    <div class="admin-nav">
        <a href="admin.jsp">🏠 管理首页</a>
        <a href="MovieServlet?action=list">🎬 电影管理</a>
        <a href="add-movie.jsp" style="background:#4CAF50;">➕ 添加电影</a>
        <a href="ScheduleServlet?action=list">📅 排期管理</a>
        <a href="order.jsp?admin=1">📊 订单统计</a>
        <a href="index.jsp" style="background:#2196f3;">🏠 用户首页</a>
        <a href="UserServlet?action=logout" style="background:#f44336; float:right;">🚪 退出</a>
    </div>
    
    <div class="container">
        <div class="stats">
            <div class="stat-card">
                <div>今日订单</div>
                <div class="stat-number">156</div>
                <div>↑ 12% 较昨日</div>
            </div>
            <div class="stat-card">
                <div>在映电影</div>
                <div class="stat-number">23</div>
                <div>↑ 3 较上周</div>
            </div>
            <div class="stat-card">
                <div>总用户数</div>
                <div class="stat-number">1,234</div>
                <div>↑ 5% 较昨日</div>
            </div>
            <div class="stat-card">
                <div>今日营收</div>
                <div class="stat-number">¥45,678</div>
                <div>↑ 18% 较昨日</div>
            </div>
        </div>
        
        <h2>管理功能</h2>
        <div class="modules">
            <div class="module-card">
                <div class="module-icon">🎬</div>
                <h3>影片管理</h3>
                <p>管理所有电影信息</p>
                <a href="MovieServlet?action=list" class="btn btn-primary">管理电影</a>
                <a href="add-movie.jsp" class="btn btn-success">添加电影</a>
            </div>
            
            <div class="module-card">
                <div class="module-icon">📅</div>
                <h3>排期管理</h3>
                <p>设置电影放映时间</p>
                <a href="ScheduleServlet?action=list" class="btn btn-primary">排期列表</a>
                <a href="ScheduleServlet?action=toAdd" class="btn btn-success">添加排期</a>
            </div>
            
            <div class="module-card">
                <div class="module-icon">📊</div>
                <h3>订单统计</h3>
                <p>查看销售数据和报表</p>
                <a href="order.jsp?admin=1" class="btn btn-primary">查看统计</a>
                <a href="#" class="btn btn-warning">导出报表</a>
            </div>
        </div>
        
        <h2>最新订单</h2>
        <div class="table">
            <table>
                <thead>
                    <tr>
                        <th>订单号</th>
                        <th>用户</th>
                        <th>电影</th>
                        <th>金额</th>
                        <th>状态</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>20231215001</td>
                        <td>张三</td>
                        <td>流浪地球2</td>
                        <td>¥90.00</td>
                        <td><span style="color:#4CAF50;">已支付</span></td>
                    </tr>
                    <tr>
                        <td>20231215002</td>
                        <td>李四</td>
                        <td>满江红</td>
                        <td>¥42.00</td>
                        <td><span style="color:#4CAF50;">已支付</span></td>
                    </tr>
                    <tr>
                        <td>20231215003</td>
                        <td>王五</td>
                        <td>深海</td>
                        <td>¥38.00</td>
                        <td><span style="color:#ff9800;">待支付</span></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="footer">
        <p>© 2025 电影票务系统 - 管理员面板 | 登录时间：<%= new java.util.Date() %></p>
    </div>
</body>
</html>