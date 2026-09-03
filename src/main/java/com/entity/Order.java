package com.entity;

import java.util.Date;

public class Order {
    private int id;
    private String orderNumber;
    private int userId;
    private int scheduleId;
    private double totalPrice;
    private int ticketCount;
    private String seatPositions; // "A1,A2,B3"
    private int paymentStatus;    // 0:未支付 1:已支付 2:已退款
    private int orderStatus;      // 0:已取消 1:待支付 2:已完成
    private Date createTime;
    
    // 构造方法
    public Order() {
        this.createTime = new Date();
        this.orderNumber = "ORD" + System.currentTimeMillis();
    }
    
    public Order(int userId, int scheduleId, double totalPrice, int ticketCount, String seatPositions) {
        this.userId = userId;
        this.scheduleId = scheduleId;
        this.totalPrice = totalPrice;
        this.ticketCount = ticketCount;
        this.seatPositions = seatPositions;
        this.createTime = new Date();
        this.orderStatus = 1;
        this.paymentStatus = 0;
        this.orderNumber = "ORD" + System.currentTimeMillis();
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
    
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    
    public int getTicketCount() { return ticketCount; }
    public void setTicketCount(int ticketCount) { this.ticketCount = ticketCount; }
    
    public String getSeatPositions() { return seatPositions; }
    public void setSeatPositions(String seatPositions) { this.seatPositions = seatPositions; }
    
    public int getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(int paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public int getOrderStatus() { return orderStatus; }
    public void setOrderStatus(int orderStatus) { this.orderStatus = orderStatus; }
    
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}