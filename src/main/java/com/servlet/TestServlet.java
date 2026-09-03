package com.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;


public class TestServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head><title>测试Servlet</title></head>");
        out.println("<body style='font-family: Arial; margin: 50px;'>");
        out.println("<h1 style='color: green;'>✅ TestServlet 工作正常！</h1>");
        out.println("<p>如果看到这个页面，说明Servlet配置正确</p>");
        out.println("<p>服务器时间：" + new java.util.Date() + "</p>");
        out.println("<p><a href='index.jsp'>返回首页</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}