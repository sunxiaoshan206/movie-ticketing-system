<%-- src/main/webapp/add-movie.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>添加电影</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .container { max-width: 600px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input, select, textarea { width: 100%; padding: 8px; }
        .btn { padding: 10px 20px; border: none; cursor: pointer; }
        .submit-btn { background: #4CAF50; color: white; }
        .back-btn { background: #ccc; color: black; text-decoration: none; padding: 10px 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>添加新电影</h1>
        
        <c:if test="${not empty error}">
            <div style="color: red; margin-bottom: 15px;">${error}</div>
        </c:if>
        
        <form action="movie?action=add" method="post">
            <div class="form-group">
                <label>电影名称：</label>
                <input type="text" name="movieName" required>
            </div>
            
            <div class="form-group">
                <label>类型：</label>
                <input type="text" name="type" required>
            </div>
            
            <div class="form-group">
                <label>时长(分钟)：</label>
                <input type="number" name="duration" required>
            </div>
            
            <div class="form-group">
                <label>导演：</label>
                <input type="text" name="director" required>
            </div>
            
            <div class="form-group">
                <label>演员：</label>
                <input type="text" name="actor" required>
            </div>
            
            <div class="form-group">
                <label>上映日期：</label>
                <input type="date" name="releaseDate" required>
            </div>
            
            <div class="form-group">
                <label>状态：</label>
                <select name="status">
                    <option value="0">未上映</option>
                    <option value="1">热映</option>
                    <option value="2">下架</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>描述：</label>
                <textarea name="description" rows="4"></textarea>
            </div>
            
            <button type="submit" class="btn submit-btn">添加电影</button>
            <a href="movie?action=list" class="back-btn">返回列表</a>
        </form>
    </div>
</body>
</html>