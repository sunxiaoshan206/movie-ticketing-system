<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 直接设置session测试
    session.setAttribute("testUser", "test");
    session.setAttribute("testRole", "admin");
%>
<html>
<body>
    <h2>Session测试页面</h2>
    <p>当前Session ID: <%= session.getId() %></p>
    <p>测试用户: <%= session.getAttribute("testUser") %></p>
    <p>测试角色: <%= session.getAttribute("testRole") %></p>
    
    <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="login">
        用户名：<input type="text" name="username"><br>
        密码：<input type="password" name="password"><br>
        <input type="submit" value="测试登录">
    </form>
</body>
</html>