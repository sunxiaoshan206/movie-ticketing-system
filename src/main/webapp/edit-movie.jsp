<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if(!"admin".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String movieId = request.getParameter("id");
    Map<String, Object> movie = null;
    
    if (movieId != null && !movieId.trim().isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // 加载驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // 建立连接
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/movie_ticket_system", 
                "root", 
                "123456");
            
            String sql = "SELECT * FROM movies WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(movieId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                movie = new HashMap<>();  
                movie.put("id", rs.getInt("id"));
                movie.put("movie_name", rs.getString("movie_name"));
                movie.put("director", rs.getString("director"));
                movie.put("actor", rs.getString("actor"));
                movie.put("duration", rs.getInt("duration"));
                movie.put("price", rs.getDouble("price"));
                movie.put("description", rs.getString("description"));
                movie.put("type", rs.getString("type"));
                movie.put("status", rs.getInt("status"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red'>数据库错误: " + e.getMessage() + "</p>");
        } finally {
            // 确保资源被关闭
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
    
    if (movie == null) {
        response.sendRedirect("MovieServlet?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>编辑电影</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container { 
            max-width: 800px; 
            margin: 40px auto; 
            background: white; 
            padding: 40px; 
            border-radius: 15px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h2 { 
            color: #333; 
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #667eea;
        }
        .form-group { 
            margin-bottom: 25px; 
        }
        label { 
            display: block; 
            margin-bottom: 10px; 
            font-weight: bold; 
            color: #555;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        input, textarea, select { 
            width: 100%; 
            padding: 12px 15px; 
            border: 2px solid #e0e0e0; 
            border-radius: 8px; 
            font-size: 16px;
            transition: all 0.3s;
            box-sizing: border-box;
        }
        input:focus, textarea:focus, select:focus {
            border-color: #667eea;
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn { 
            padding: 14px 30px; 
            border: none; 
            border-radius: 8px; 
            cursor: pointer; 
            font-size: 16px;
            font-weight: bold;
            transition: all 0.3s;
        }
        .btn-primary { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white; 
            margin-right: 15px;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary { 
            background: #f8f9fa; 
            color: #666;
            border: 2px solid #e0e0e0;
        }
        .btn-secondary:hover {
            background: #e9ecef;
        }
        .error { 
            background: #ffe6e6; 
            color: #d63031; 
            padding: 15px; 
            border-radius: 8px; 
            margin-bottom: 25px; 
            border-left: 4px solid #d63031;
        }
        .success { 
            background: #d4edda; 
            color: #155724; 
            padding: 15px; 
            border-radius: 8px; 
            margin-bottom: 25px; 
            border-left: 4px solid #28a745;
        }
        .form-actions {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #f0f0f0;
        }
        .movie-header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        .movie-header h3 {
            margin: 0;
            font-size: 24px;
        }
        .required::after {
            content: " *";
            color: #e74c3c;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="movie-header">
            <h3>🎬 编辑电影信息</h3>
            <p>ID: <%= movie.get("id") %> | 当前名称: <%= movie.get("movie_name") %></p>
        </div>
        
        <% if(request.getAttribute("error") != null) { %>
            <div class="error">
                <strong>错误：</strong><%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if(request.getAttribute("success") != null) { %>
            <div class="success">
                <strong>成功：</strong><%= request.getAttribute("success") %>
            </div>
        <% } %>
        
        <form action="MovieServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= movie.get("id") %>">
            
            <div class="form-group">
                <label class="required">电影名称</label>
                <input type="text" name="title" 
                       value="<%= movie.get("movie_name") != null ? movie.get("movie_name") : "" %>" 
                       required
                       placeholder="请输入电影名称">
            </div>
            
            <div class="form-group">
                <label>导演</label>
                <input type="text" name="director" 
                       value="<%= movie.get("director") != null ? movie.get("director") : "" %>"
                       placeholder="请输入导演姓名">
            </div>
            
            <div class="form-group">
                <label>主演</label>
                <input type="text" name="actors" 
                       value="<%= movie.get("actor") != null ? movie.get("actor") : "" %>"
                       placeholder="请输入主演姓名，多个用逗号分隔">
            </div>
            
            <div class="form-group">
                <label>时长（分钟）</label>
                <input type="number" name="duration" 
                       value="<%= movie.get("duration") != null ? movie.get("duration") : "120" %>"
                       min="60" max="300"
                       placeholder="请输入电影时长">
            </div>
            
            <div class="form-group">
                <label>票价（元）</label>
                <input type="number" step="0.01" name="price" 
                       value="<%= movie.get("price") != null ? movie.get("price") : "45.00" %>"
                       min="20" max="200"
                       placeholder="请输入票价">
            </div>
            
            <div class="form-group">
                <label>电影简介</label>
                <textarea name="description" rows="5" 
                          placeholder="请输入电影简介"><%= movie.get("description") != null ? movie.get("description") : "" %></textarea>
            </div>
            
            <div class="form-group">
                <label>电影类型</label>
                <select name="type">
                    <option value="">请选择类型</option>
                    <option value="动作" <%= "动作".equals(movie.get("type")) ? "selected" : "" %>>动作</option>
                    <option value="喜剧" <%= "喜剧".equals(movie.get("type")) ? "selected" : "" %>>喜剧</option>
                    <option value="爱情" <%= "爱情".equals(movie.get("type")) ? "selected" : "" %>>爱情</option>
                    <option value="科幻" <%= "科幻".equals(movie.get("type")) ? "selected" : "" %>>科幻</option>
                    <option value="恐怖" <%= "恐怖".equals(movie.get("type")) ? "selected" : "" %>>恐怖</option>
                    <option value="动画" <%= "动画".equals(movie.get("type")) ? "selected" : "" %>>动画</option>
                    <option value="剧情" <%= "剧情".equals(movie.get("type")) ? "selected" : "" %>>剧情</option>
                    <option value="其他" <%= "其他".equals(movie.get("type")) ? "selected" : "" %>>其他</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>状态</label>
                <select name="status">
                    <%
                        String statusValue = movie.get("status") != null ? movie.get("status").toString() : "1";
                    %>
                    <option value="1" <%= "1".equals(statusValue) ? "selected" : "" %>>上架</option>
                    <option value="0" <%= "0".equals(statusValue) ? "selected" : "" %>>下架</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">💾 保存修改</button>
                <button type="button" class="btn btn-secondary" onclick="history.back()">取消</button>
                <a href="MovieServlet?action=list" style="margin-left: 20px; color: #667eea; text-decoration: none;">返回电影列表</a>
            </div>
        </form>
    </div>
    
    <script>
        // 表单验证
        document.querySelector('form').addEventListener('submit', function(e) {
            var title = document.querySelector('input[name="title"]').value.trim();
            var price = document.querySelector('input[name="price"]').value;
            
            if (!title) {
                alert('电影名称不能为空！');
                e.preventDefault();
                return;
            }
            
            if (price && (parseFloat(price) < 20 || parseFloat(price) > 200)) {
                alert('票价应在20-200元之间！');
                e.preventDefault();
                return;
            }
            
            if (!confirm('确定要保存修改吗？')) {
                e.preventDefault();
            }
        });
        
        // 输入框效果
        var inputs = document.querySelectorAll('input, textarea, select');
        inputs.forEach(function(input) {
            input.addEventListener('focus', function() {
                this.style.backgroundColor = '#f8f9ff';
            });
            input.addEventListener('blur', function() {
                this.style.backgroundColor = '';
            });
        });
    </script>
</body>
</html>