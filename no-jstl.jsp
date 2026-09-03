<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.entity.Movie" %>
<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movieList");
    if (movies == null) movies = new ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>电影列表（无JSTL）</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: #4CAF50; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .add-btn { background: #2196F3; color: white; padding: 10px 15px; 
                   text-decoration: none; border-radius: 5px; display: inline-block; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:hover { background-color: #f5f5f5; }
        .btn { padding: 5px 10px; text-decoration: none; border-radius: 3px; margin: 2px; }
        .view-btn { background: #4CAF50; color: white; }
        .edit-btn { background: #FF9800; color: white; }
        .delete-btn { background: #f44336; color: white; }
        .status-0 { color: orange; }
        .status-1 { color: green; }
        .status-2 { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>电影票管理系统</h1>
            <a href="movie?action=addForm" class="add-btn">添加新电影</a>
        </div>
        
        <% if (movies.isEmpty()) { %>
            <p>暂无电影数据</p>
        <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>电影名称</th>
                        <th>类型</th>
                        <th>时长(分钟)</th>
                        <th>导演</th>
                        <th>演员</th>
                        <th>上映日期</th>
                        <th>状态</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Movie movie : movies) { %>
                        <tr>
                            <td><%= movie.getId() %></td>
                            <td><%= movie.getMovieName() %></td>
                            <td><%= movie.getType() %></td>
                            <td><%= movie.getDuration() %></td>
                            <td><%= movie.getDirector() %></td>
                            <td><%= movie.getActor() %></td>
                            <td><%= movie.getReleaseDate() %></td>
                            <td class="status-<%= movie.getStatus() %>">
                                <% 
                                    switch(movie.getStatus()) {
                                        case 0: out.print("未上映"); break;
                                        case 1: out.print("热映"); break;
                                        case 2: out.print("下架"); break;
                                        default: out.print("未知");
                                    }
                                %>
                            </td>
                            <td>
                                <a href="movie?action=view&id=<%= movie.getId() %>" class="btn view-btn">查看</a>
                                <a href="movie?action=editForm&id=<%= movie.getId() %>" class="btn edit-btn">编辑</a>
                                <a href="movie?action=delete&id=<%= movie.getId() %>" 
                                   class="btn delete-btn" onclick="return confirm('确定删除这部电影吗？')">删除</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
</html>