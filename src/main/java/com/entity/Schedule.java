package com.entity;

import java.util.Date;

public class Schedule {
    private int id;
    private int movieId;
    private int hallId;
    private Date showTime;
    private double price;
    private int availableSeats;
    private int status; // 0:已取消 1:正常
    
    // 构造方法
    public Schedule() {}
    
    public Schedule(int movieId, int hallId, Date showTime, double price, int availableSeats) {
        this.movieId = movieId;
        this.hallId = hallId;
        this.showTime = showTime;
        this.price = price;
        this.availableSeats = availableSeats;
        this.status = 1;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getMovieId() { return movieId; }
    public void setMovieId(int movieId) { this.movieId = movieId; }
    
    public int getHallId() { return hallId; }
    public void setHallId(int hallId) { this.hallId = hallId; }
    
    public Date getShowTime() { return showTime; }
    public void setShowTime(Date showTime) { this.showTime = showTime; }
    
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    
    public int getAvailableSeats() { return availableSeats; }
    public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}