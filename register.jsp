<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>注册 - 电影票务系统</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .register-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            width: 400px;
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
        }
        input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        input:focus {
            border-color: #6a11cb;
            outline: none;
            box-shadow: 0 0 0 2px rgba(106, 17, 203, 0.2);
        }
        .btn-register {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn-register:hover {
            opacity: 0.9;
        }
        .error {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .login-link a {
            color: #6a11cb;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="register-box">
        <h2>📝 用户注册</h2>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <form action="UserServlet" method="post">
            <input type="hidden" name="action" value="register">
            
            <div class="form-group">
                <label>用户名</label>
                <input type="text" name="username" required>
            </div>
            
            <div class="form-group">
                <label>密码</label>
                <input type="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label>邮箱（可选）</label>
                <input type="email" name="email">
            </div>
            
            <div class="form-group">
                <label>手机号（可选）</label>
                <input type="tel" name="phone">
            </div>
            
            <button type="submit" class="btn-register">注册</button>
        </form>
        
        <div class="login-link">
            已有账号？<a href="login.jsp">立即登录</a>
        </div>
    </div>
</body>
</html>