// src/main/java/com/entity/Movie.java
package com.entity;

import java.util.Date;

public class Movie {
    private int id;
    private String movieName;
    private String type;
    private int duration;
    private String director;
    private String actor;
    private Date releaseDate;
    private int status; // 0:未上映 1:热映 2:下架
    private String description;
    
    // 构造方法
    public Movie() {}
    
    public Movie(String movieName, String type, int duration, String director, 
                 String actor, Date releaseDate, int status, String description) {
        this.movieName = movieName;
        this.type = type;
        this.duration = duration;
        this.director = director;
        this.actor = actor;
        this.releaseDate = releaseDate;
        this.status = status;
        this.description = description;
    }
    
    // Getter和Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getMovieName() { return movieName; }
    public void setMovieName(String movieName) { this.movieName = movieName; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }
    
    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }
    
    public String getActor() { return actor; }
    public void setActor(String actor) { this.actor = actor; }
    
    public Date getReleaseDate() { return releaseDate; }
    public void setReleaseDate(Date releaseDate) { this.releaseDate = releaseDate; }
    
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}