<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>系统错误</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 20px;
        }
        .error-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            text-align: center;
        }
        .error-code {
            font-size: 72px;
            color: #dc3545;
            margin-bottom: 20px;
        }
        .error-message {
            font-size: 18px;
            color: #6c757d;
            margin-bottom: 30px;
        }
        .btn {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            display: inline-block;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .details {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            text-align: left;
            font-family: monospace;
            font-size: 14px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">⚠️</div>
        <h1>系统错误</h1>
        <p class="error-message">
            抱歉，系统发生了一个错误。<br>
            请稍后再试或联系管理员。
        </p>
        
        <%
            // 显示错误信息
            String errorMsg = (String) request.getAttribute("error");
            String exceptionMsg = exception.getMessage(); 
            
            if(errorMsg != null || exception != null) {
        %>
            <div class="details">
                <strong>错误详情：</strong><br>
                <% if(errorMsg != null) { %>
                    <%= errorMsg %><br>
                <% } %>
                <% if(exception != null) { %>
                    异常类型：<%= exception.getClass().getName() %><br>
                    异常信息：<%= exception.getMessage() %>
                <% } %>
            </div>
        <% } %>
        
        <div style="margin-top: 30px;">
            <a href="javascript:history.back()" class="btn">返回上一页</a>
            <a href="index.jsp" class="btn" style="margin-left: 10px;">返回首页</a>
            <% 
                String user = (String) session.getAttribute("user");
                String role = (String) session.getAttribute("role");
                if("admin".equals(role)) {
            %>
                <a href="admin.jsp" class="btn" style="margin-left: 10px;">管理后台</a>
            <% } %>
        </div>
    </div>
</body>
</html>