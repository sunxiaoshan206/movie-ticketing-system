package com.entity;

public class CinemaHall {
    private int id;
    private String hallName;
    private int totalSeats;
    private int rows;
    private int cols;
    private String hallType; // IMAX, 3D, 普通
    private int status;      // 0:关闭 1:正常
    
    // 构造方法
    public CinemaHall() {}
    
    public CinemaHall(String hallName, int rows, int cols, String hallType) {
        this.hallName = hallName;
        this.rows = rows;
        this.cols = cols;
        this.totalSeats = rows * cols;
        this.hallType = hallType;
        this.status = 1;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getHallName() { return hallName; }
    public void setHallName(String hallName) { this.hallName = hallName; }
    
    public int getTotalSeats() { return totalSeats; }
    public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }
    
    public int getRows() { return rows; }
    public void setRows(int rows) { this.rows = rows; }
    
    public int getCols() { return cols; }
    public void setCols(int cols) { this.cols = cols; }
    
    public String getHallType() { return hallType; }
    public void setHallType(String hallType) { this.hallType = hallType; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}