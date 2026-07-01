package util;

import java.util.ArrayList;
import java.util.List;
import bean.User;
import bean.UserSearchCriteria;
import dao.UserDao;
import util.SQLHelper;

public class MessageContactUtil {
    public static List<User> contactsFor(User sender) {
        List<User> contacts = new ArrayList<User>();
        if (sender == null) {
            return contacts;
        }
        List<User> users = new UserDao().findAll((UserSearchCriteria) null);
        for (User user : users) {
            if (isAllowed(sender, user)) {
                contacts.add(user);
            }
        }
        return contacts;
    }

    public static boolean canSendTo(User sender, int receiverId) {
        if (sender == null) {
            return false;
        }
        User receiver = new UserDao().findById(receiverId);
        return isAllowed(sender, receiver);
    }

    private static boolean isAllowed(User sender, User receiver) {
        if (sender == null || receiver == null || receiver.getStatus() != 1
                || sender.getId() == receiver.getId()) {
            return false;
        }
        if ("admin".equals(sender.getRole())) {
            return true;
        }
        if ("admin".equals(receiver.getRole())) {
            return true;
        }
        if ("director".equals(sender.getRole())) {
            return sameMajor(sender, receiver)
                && ("teacher".equals(receiver.getRole()) || "student".equals(receiver.getRole()));
        }
        if ("teacher".equals(sender.getRole())) {
            return "student".equals(receiver.getRole())
                && hasTeacherStudentRelation(sender.getId(), receiver.getId());
        }
        if ("student".equals(sender.getRole())) {
            return receiver.getId() == approvedTeacherId(sender.getId());
        }
        return false;
    }

    private static boolean sameMajor(User a, User b) {
        String aCollege = clean(a.getCollege());
        String aMajor = clean(a.getMajor());
        String bCollege = clean(b.getCollege());
        String bMajor = clean(b.getMajor());
        return aCollege != null && aMajor != null
            && aCollege.equals(bCollege) && aMajor.equals(bMajor);
    }

    private static boolean hasTeacherStudentRelation(int teacherId, int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT 1 FROM topic_selections s "
            + "JOIN topics t ON s.topic_id=t.id "
            + "WHERE t.teacher_id=? AND s.student_id=? LIMIT 1",
            teacherId, studentId);
        return val != null;
    }

    private static int approvedTeacherId(int studentId) {
        Object val = SQLHelper.queryScalar(
            "SELECT t.teacher_id FROM topic_selections s "
            + "JOIN topics t ON s.topic_id=t.id "
            + "WHERE s.student_id=? AND s.status='approved' "
            + "ORDER BY s.review_time DESC, s.apply_time DESC LIMIT 1",
            studentId);
        return val == null ? -1 : ((Number) val).intValue();
    }

    private static String clean(String value) {
        if (value == null) {
            return null;
        }
        String text = value.trim();
        return text.isEmpty() ? null : text;
    }
}
