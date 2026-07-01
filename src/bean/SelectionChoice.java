package bean;

import java.util.Date;

public class SelectionChoice {
    private int id;
    private int applicationId;
    private int studentId;
    private String studentName;
    private String studentNo;
    private int topicId;
    private String topicTitle;
    private String teacherName;
    private int round;
    private int choiceRank;
    private String status;
    private Date createdAt;
    private int currentIntentCount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }
    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
    public int getRound() { return round; }
    public void setRound(int round) { this.round = round; }
    public int getChoiceRank() { return choiceRank; }
    public void setChoiceRank(int choiceRank) { this.choiceRank = choiceRank; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public int getCurrentIntentCount() { return currentIntentCount; }
    public void setCurrentIntentCount(int currentIntentCount) { this.currentIntentCount = currentIntentCount; }
}

