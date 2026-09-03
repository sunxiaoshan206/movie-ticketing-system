package com.entity;

import java.util.Date;

public class Ticket {
    private Integer id;
    private Integer movieId;
    private String movieName;
    private Integer userId;
    private String username;
    private String seats;
    private Integer quantity;
    private Double totalPrice;
    private String showTime;
    private String hall;
    private Integer status; // 0-已取消，1-已支付，2-已完成
    private Date createTime;
    private Date updateTime;
    
    // 无参构造
    public Ticket() {
    }
    
    // 全参构造
    public Ticket(Integer id, Integer movieId, String movieName, Integer userId, String username, 
                  String seats, Integer quantity, Double totalPrice, String showTime, 
                  String hall, Integer status, Date createTime, Date updateTime) {
        this.id = id;
        this.movieId = movieId;
        this.movieName = movieName;
        this.userId = userId;
        this.username = username;
        this.seats = seats;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.showTime = showTime;
        this.hall = hall;
        this.status = status;
        this.createTime = createTime;
        this.updateTime = updateTime;
    }
    
    // Getter和Setter方法
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public Integer getMovieId() {
        return movieId;
    }
    
    public void setMovieId(Integer movieId) {
        this.movieId = movieId;
    }
    
    public String getMovieName() {
        return movieName;
    }
    
    public void setMovieName(String movieName) {
        this.movieName = movieName;
    }
    
    public Integer getUserId() {
        return userId;
    }
    
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getSeats() {
        return seats;
    }
    
    public void setSeats(String seats) {
        this.seats = seats;
    }
    
    public Integer getQuantity() {
        return quantity;
    }
    
    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }
    
    public Double getTotalPrice() {
        return totalPrice;
    }
    
    public void setTotalPrice(Double totalPrice) {
        this.totalPrice = totalPrice;
    }
    
    public String getShowTime() {
        return showTime;
    }
    
    public void setShowTime(String showTime) {
        this.showTime = showTime;
    }
    
    public String getHall() {
        return hall;
    }
    
    public void setHall(String hall) {
        this.hall = hall;
    }
    
    public Integer getStatus() {
        return status;
    }
    
    public void setStatus(Integer status) {
        this.status = status;
    }
    
    public Date getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
    
    public Date getUpdateTime() {
        return updateTime;
    }
    
    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
    
    @Override
    public String toString() {
        return "Ticket{" +
                "id=" + id +
                ", movieId=" + movieId +
                ", movieName='" + movieName + '\'' +
                ", userId=" + userId +
                ", username='" + username + '\'' +
                ", seats='" + seats + '\'' +
                ", quantity=" + quantity +
                ", totalPrice=" + totalPrice +
                ", showTime='" + showTime + '\'' +
                ", hall='" + hall + '\'' +
                ", status=" + status +
                ", createTime=" + createTime +
                ", updateTime=" + updateTime +
                '}';
    }
}