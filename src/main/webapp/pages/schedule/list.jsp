<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>电影排片列表</title>
    <!-- 极简样式，仅保证布局清晰 -->
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f0f0f0; }
        .btn { padding: 5px 10px; background: #007bff; color: white; border: none; cursor: pointer; }
        .tip { color: red; margin-bottom: 10px; }
    </style>
</head>
<body>
    <h2>电影排片列表</h2>

    <%-- 登录状态提示 & 退出/登录入口 --%>
    <% 
        String loginUser = (String) session.getAttribute("loginUser");
        if (loginUser != null) { 
    %>
        <div class="tip">当前登录：<%= loginUser %> | <a href="<%= request.getContextPath() %>/UserServlet?action=logout">退出</a></div>
    <% } else { %>
        <div class="tip">未登录！<a href="<%= request.getContextPath() %>/UserServlet?action=toLogin">立即登录</a></div>
    <% } %>

    <%-- 核心排片表格（功能全覆盖，数据模拟） --%>
    <table>
        <tr>
            <th>电影名</th>
            <th>日期</th>
            <th>时间</th>
            <th>影厅</th>
            <th>票价</th>
            <th>操作</th>
        </tr>
        <tr>
            <td>流浪地球3</td>
            <td>2025-12-20</td>
            <td>09:30</td>
            <td>IMAX厅</td>
            <td>88元</td>
            <td><button class="btn" onclick="buyTicket(this)">购票</button></td>
        </tr>
        <tr>
            <td>哪吒之魔童闹海</td>
            <td>2025-12-20</td>
            <td>10:00</td>
            <td>3D厅</td>
            <td>68元</td>
            <td><button class="btn" onclick="buyTicket(this)">购票</button></td>
        </tr>
        <tr>
            <td>满江红2</td>
            <td>2025-12-20</td>
            <td>14:00</td>
            <td>2D厅</td>
            <td>58元</td>
            <td><button class="btn" onclick="buyTicket(this)">购票</button></td>
        </tr>
    </table>

    <script>
        // 核心购票功能（含登录校验）
        function buyTicket(btn) {
            <% if (loginUser == null) { %>
                alert("请先登录再购票！");
                window.location.href = "<%= request.getContextPath() %>/UserServlet?action=toLogin";
                return;
            <% } %>

            // 获取选中的排片信息
            const tr = btn.parentElement.parentElement;
            const movie = tr.cells[0].innerText;
            const time = tr.cells[2].innerText;
            alert(`已选择《${movie}》${time}场次，即将进入购票流程！`);
            // 实际项目可跳转至选座/下单页：
            // window.location.href = "<%= request.getContextPath() %>/pages/order/create.jsp?movie=" + movie;
        }
    </script>
</body>
</html>