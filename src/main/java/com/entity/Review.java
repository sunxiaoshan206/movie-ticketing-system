package com.entity;

import java.util.Date;

public class Review {
    private int id;
    private int userId;
    private int movieId;
    private int rating;      // 评分 1-5
    private String content;
    private Date createTime;
    private int status;      // 0:隐藏 1:显示
    
    // 构造方法
    public Review() {
        this.createTime = new Date();
        this.status = 1;
    }
    
    public Review(int userId, int movieId, int rating, String content) {
        this.userId = userId;
        this.movieId = movieId;
        this.rating = rating;
        this.content = content;
        this.createTime = new Date();
        this.status = 1;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getMovieId() { return movieId; }
    public void setMovieId(int movieId) { this.movieId = movieId; }
    
    public int getRating() { return rating; }
    public void setRating(int rating) { 
        if (rating < 1) rating = 1;
        if (rating > 5) rating = 5;
        this.rating = rating; 
    }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}