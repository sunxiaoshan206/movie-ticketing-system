package com.entity;

public class Seat {
    private int id;
    private int hallId;
    private int rowNum;
    private int colNum;
    private int seatType; // 0:普通 1:情侣座 2:VIP
    private int status;   // 0:损坏 1:正常
    
    // 构造方法
    public Seat() {}
    
    public Seat(int hallId, int rowNum, int colNum, int seatType) {
        this.hallId = hallId;
        this.rowNum = rowNum;
        this.colNum = colNum;
        this.seatType = seatType;
        this.status = 1;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getHallId() { return hallId; }
    public void setHallId(int hallId) { this.hallId = hallId; }
    
    public int getRowNum() { return rowNum; }
    public void setRowNum(int rowNum) { this.rowNum = rowNum; }
    
    public int getColNum() { return colNum; }
    public void setColNum(int colNum) { this.colNum = colNum; }
    
    public int getSeatType() { return seatType; }
    public void setSeatType(int seatType) { this.seatType = seatType; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}