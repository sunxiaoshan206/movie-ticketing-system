package com.util;

import java.util.*;
import java.text.SimpleDateFormat;

public class JSONUtil {
    
    /**
     * 创建成功JSON
     */
    public static String createSuccess(String message) {
        return "{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}";
    }
    
    /**
     * 创建带数据的成功JSON
     */
    public static String createSuccess(String message, Map<String, Object> data) {
        StringBuilder json = new StringBuilder("{\"success\":true,\"message\":\"");
        json.append(escapeJson(message)).append("\",\"data\":");
        json.append(mapToJson(data));
        json.append("}");
        return json.toString();
    }
    
    /**
     * 创建失败JSON
     */
    public static String createError(String message) {
        return "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}";
    }
    
    /**
     * 将 Map 转换为 JSON 字符串
     */
    public static String mapToJson(Map<String, Object> map) {
        if (map == null) return "null";
        
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) json.append(",");
            first = false;
            
            json.append("\"").append(entry.getKey()).append("\":");
            json.append(valueToJson(entry.getValue()));
        }
        
        json.append("}");
        return json.toString();
    }
    
    private static String valueToJson(Object value) {
        if (value == null) return "null";
        if (value instanceof String) return "\"" + escapeJson((String)value) + "\"";
        if (value instanceof Number || value instanceof Boolean) return value.toString();
        if (value instanceof Map) return mapToJson((Map<String, Object>)value);
        if (value instanceof List) return listToJson((List<?>)value);
        if (value instanceof Date) return "\"" + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format((Date)value) + "\"";
        return "\"" + escapeJson(value.toString()) + "\"";
    }
    
    private static String listToJson(List<?> list) {
        if (list == null) return "null";
        
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        
        for (Object item : list) {
            if (!first) json.append(",");
            first = false;
            json.append(valueToJson(item));
        }
        
        json.append("]");
        return json.toString();
    }
    
    private static String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}