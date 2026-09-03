<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("role");
    if(!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>添加电影</title>
    <style>
        body { font-family: Arial; background: #f0f2f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        h2 { color: #2c3e50; margin-bottom: 30px; text-align: center; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; color: #555; font-weight: 500; }
        input, textarea, select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 16px; }
        input:focus, textarea:focus { border-color: #3498db; outline: none; box-shadow: 0 0 0 2px rgba(52,152,219,0.2); }
        .btn { padding: 12px 25px; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; }
        .btn-primary { background: #3498db; color: white; }
        .btn-secondary { background: #95a5a6; color: white; margin-left: 10px; }
        .btn:hover { opacity: 0.9; }
        .error { background: #ffeaea; color: #e74c3c; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>添加新电影</h2>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        
        <form action="MovieServlet" method="post">
            <input type="hidden" name="action" value="add">
            
            <div class="form-group">
                <label>电影名称 *</label>
                <input type="text" name="title" required>
            </div>
            
            <div class="form-group">
                <label>导演 *</label>
                <input type="text" name="director" required>
            </div>
            
            <div class="form-group">
                <label>主演 *</label>
                <input type="text" name="actors" required>
            </div>
            
            <div class="form-group">
                <label>时长（分钟） *</label>
                <input type="number" name="duration" required>
            </div>
            
            <div class="form-group">
                <label>票价（元） *</label>
                <input type="number" step="0.01" name="price" required>
            </div>
            
            <div class="form-group">
                <label>电影简介</label>
                <textarea name="description" rows="4"></textarea>
            </div>
            
            <div style="text-align: center;">
                <button type="submit" class="btn btn-primary">添加电影</button>
                <button type="button" class="btn btn-secondary" onclick="history.back()">取消</button>
            </div>
        </form>
    </div>
</body>
</html>