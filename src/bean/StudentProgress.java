package bean;

import java.util.Map;

public class StudentProgress {
    private TopicSelection selection;
    private Map<String, Document> documents;

    public StudentProgress(TopicSelection selection, Map<String, Document> documents) {
        this.selection = selection;
        this.documents = documents;
    }

    public TopicSelection getSelection() { return selection; }
    public Map<String, Document> getDocuments() { return documents; }
}
