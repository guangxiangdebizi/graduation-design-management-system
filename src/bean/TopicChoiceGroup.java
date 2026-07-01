package bean;

import java.util.ArrayList;
import java.util.List;

public class TopicChoiceGroup {
    private int topicId;
    private String topicTitle;
    private String teacherName;
    private int round;
    private List<SelectionChoice> choices = new ArrayList<SelectionChoice>();

    public int getTopicId() { return topicId; }
    public void setTopicId(int topicId) { this.topicId = topicId; }
    public String getTopicTitle() { return topicTitle; }
    public void setTopicTitle(String topicTitle) { this.topicTitle = topicTitle; }
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
    public int getRound() { return round; }
    public void setRound(int round) { this.round = round; }
    public List<SelectionChoice> getChoices() { return choices; }
    public void setChoices(List<SelectionChoice> choices) { this.choices = choices; }
    public int getCandidateCount() { return choices == null ? 0 : choices.size(); }
}
