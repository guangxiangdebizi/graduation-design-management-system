package bean;

import java.math.BigDecimal;
import java.util.Date;

public class DefenseScore {
    private int id;
    private int scheduleId;
    private int teacherId;
    private String teacherName;
    private BigDecimal score;
    private String comment;
    private Date scoreTime;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Date getScoreTime() { return scoreTime; }
    public void setScoreTime(Date scoreTime) { this.scoreTime = scoreTime; }
}
