package bean;

public class UserSearchCriteria {
    private String role;
    private String college;
    private String major;
    private String className;
    private String studentNo;
    private String realName;

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = trimToNull(role);
    }

    public String getCollege() {
        return college;
    }

    public void setCollege(String college) {
        this.college = trimToNull(college);
    }

    public String getMajor() {
        return major;
    }

    public void setMajor(String major) {
        this.major = trimToNull(major);
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = trimToNull(className);
    }

    public String getStudentNo() {
        return studentNo;
    }

    public void setStudentNo(String studentNo) {
        this.studentNo = trimToNull(studentNo);
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = trimToNull(realName);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String text = value.trim();
        return text.isEmpty() ? null : text;
    }
}
