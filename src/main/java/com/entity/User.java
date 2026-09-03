package com.entity;

import java.util.Date;

public class User {
    private int id;
    private String username;
    private String password;
    private String email;
    private String phone;
    private int userType; // 0:普通用户 1:管理员
    private Date createTime;
    private int status;   // 0:禁用 1:正常
    
    // 构造方法
    public User() {}
    
    public User(String username, String password, String email, String phone, int userType) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.phone = phone;
        this.userType = userType;
        this.createTime = new Date();
        this.status = 1;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public int getUserType() { return userType; }
    public void setUserType(int userType) { this.userType = userType; }
    
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}