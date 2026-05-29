package bean;

import java.math.BigDecimal;
import java.util.Date;

public class DefenseSchedule {
    private int id;
    private int studentId;
    private String studentName;
    private String studentNo;
    private String topicTitle;
    private String teacherName;
    private Date defenseTime;
    private String room;
    private String groupName;
    private BigDecimal score;
    private String comment;
    private Date createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
    public Date getDefenseTime() { return defenseTime; }
    public void setDefenseTime(Date defenseTime) { this.defenseTime = defenseTime; }
    public String getRoom() { return room; }
    public void setRoom(String room) { this.room = room; }
    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }
    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
