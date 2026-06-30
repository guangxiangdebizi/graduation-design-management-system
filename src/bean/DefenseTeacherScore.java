package bean;

import java.math.BigDecimal;
import java.util.Date;

public class DefenseTeacherScore {
    private int scheduleId;
    private int studentId;
    private String studentName;
    private String studentNo;
    private String topicTitle;
    private String supervisorName;
    private BigDecimal myScore;
    private String myComment;
    private Date scoreTime;
    private BigDecimal averageScore;
    private int scoreCount;

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String supervisorName) { this.supervisorName = supervisorName; }
    public BigDecimal getMyScore() { return myScore; }
    public void setMyScore(BigDecimal myScore) { this.myScore = myScore; }
    public String getMyComment() { return myComment; }
    public void setMyComment(String myComment) { this.myComment = myComment; }
    public Date getScoreTime() { return scoreTime; }
    public void setScoreTime(Date scoreTime) { this.scoreTime = scoreTime; }
    public BigDecimal getAverageScore() { return averageScore; }
    public void setAverageScore(BigDecimal averageScore) { this.averageScore = averageScore; }
    public int getScoreCount() { return scoreCount; }
    public void setScoreCount(int scoreCount) { this.scoreCount = scoreCount; }
}
