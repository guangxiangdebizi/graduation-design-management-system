package bean;

import java.util.Date;

public class TopicAssignment {
    private int id;
    private int studentId;
    private String studentName;
    private String studentNo;
    private int topicId;
    private String topicTitle;
    private String teacherName;
    private Integer choiceId;
    private int round;
    private String source;
    private int confirmedBy;
    private String confirmerName;
    private String confirmComment;
    private Date confirmTime;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
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
    public Integer getChoiceId() { return choiceId; }
    public void setChoiceId(Integer choiceId) { this.choiceId = choiceId; }
    public int getRound() { return round; }
    public void setRound(int round) { this.round = round; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public int getConfirmedBy() { return confirmedBy; }
    public void setConfirmedBy(int confirmedBy) { this.confirmedBy = confirmedBy; }
    public String getConfirmerName() { return confirmerName; }
    public void setConfirmerName(String confirmerName) { this.confirmerName = confirmerName; }
    public String getConfirmComment() { return confirmComment; }
    public void setConfirmComment(String confirmComment) { this.confirmComment = confirmComment; }
    public Date getConfirmTime() { return confirmTime; }
    public void setConfirmTime(Date confirmTime) { this.confirmTime = confirmTime; }
}

