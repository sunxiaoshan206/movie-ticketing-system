<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>MySQL驱动测试</title>
</head>
<body>
    <h1>MySQL JDBC驱动测试</h1>
    
    <%
        Connection conn = null;
        try {
            out.println("<h2>测试1：加载驱动类</h2>");
            
            // 尝试加载驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            out.println("<p style='color:green'>✅ com.mysql.cj.jdbc.Driver 加载成功</p>");
            
            // 如果没有异常，继续测试
            try {
                Class.forName("com.mysql.jdbc.Driver");
                out.println("<p style='color:green'>✅ com.mysql.jdbc.Driver 加载成功</p>");
            } catch (ClassNotFoundException e2) {
                out.println("<p style='color:orange'>⚠️ com.mysql.jdbc.Driver 未找到（MySQL 8.0+ 通常使用上面那个）</p>");
            }
            
            out.println("<h2>测试2：连接数据库</h2>");
            String url = "jdbc:mysql://localhost:3306/movie_ticket_system";
            String user = "root";
            String password = "123456"; // 改为你的密码
            
            conn = DriverManager.getConnection(url, user, password);
            out.println("<p style='color:green'>✅ 数据库连接成功</p>");
            
            out.println("<h2>测试3：查看 movies 表</h2>");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SHOW TABLES");
            
            out.println("<table border='1'><tr><th>表名</th></tr>");
            while(rs.next()) {
                out.println("<tr><td>" + rs.getString(1) + "</td></tr>");
            }
            out.println("</table>");
            
            rs.close();
            stmt.close();
            
        } catch (ClassNotFoundException e) {
            out.println("<h2 style='color:red'>❌ 驱动类未找到错误</h2>");
            out.println("<p>错误信息: " + e.getMessage() + "</p>");
            out.println("<p>请确保 mysql-connector-j-8.0.33.jar 在以下位置：</p>");
            out.println("<ul>");
            out.println("<li>WebContent/WEB-INF/lib/mysql-connector-j-8.0.33.jar</li>");
            out.println("<li>或者项目的构建路径中</li>");
            out.println("</ul>");
            
            // 显示类路径信息
            out.println("<h3>当前类路径:</h3>");
            String classpath = System.getProperty("java.class.path");
            String[] paths = classpath.split(System.getProperty("path.separator"));
            for (String path : paths) {
                if (path.contains("mysql")) {
                    out.println("<p style='color:green'>" + path + "</p>");
                } else {
                    out.println("<p>" + path + "</p>");
                }
            }
            
        } catch (SQLException e) {
            out.println("<h2 style='color:red'>❌ 数据库连接错误</h2>");
            out.println("<p>错误信息: " + e.getMessage() + "</p>");
            out.println("<p>错误代码: " + e.getErrorCode() + "</p>");
            out.println("<p>SQL状态: " + e.getSQLState() + "</p>");
        } finally {
            try { if(conn != null) conn.close(); } catch(SQLException e) {}
        }
    %>
    
    <h2>驱动文件检查</h2>
    <%
        // 检查驱动文件是否存在
        String[] driverClasses = {
            "com.mysql.cj.jdbc.Driver",
            "com.mysql.jdbc.Driver"
        };
        
        for (String driverClass : driverClasses) {
            try {
                Class.forName(driverClass);
                out.println("<p style='color:green'>✅ " + driverClass + " - 可用</p>");
            } catch (ClassNotFoundException e) {
                out.println("<p style='color:red'>❌ " + driverClass + " - 不可用</p>");
            }
        }
    %>
</body>
</html>