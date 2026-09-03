<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>系统错误</title>
</head>
<body>
    <div style="text-align: center; margin-top: 100px;">
        <h1 style="color: #dc3545;">⚠️ 系统错误</h1>
        <p>抱歉，系统发生了一个错误。</p>
        
        <%
            String errorMsg = (String) request.getAttribute("error");
            Throwable ex = (Throwable) request.getAttribute("exception");
            
            if(errorMsg != null) {
                out.println("<p><strong>错误信息：</strong>" + errorMsg + "</p>");
            }
            if(ex != null) {
                out.println("<p><strong>异常信息：</strong>" + ex.getMessage() + "</p>");
            }
        %>
        
        <div style="margin-top: 30px;">
            <a href="javascript:history.back()" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">返回上一页</a>
            <a href="index.jsp" style="margin-left: 10px; padding: 10px 20px; background: #6c757d; color: white; text-decoration: none; border-radius: 5px;">返回首页</a>
        </div>
    </div>
</body>
</html>