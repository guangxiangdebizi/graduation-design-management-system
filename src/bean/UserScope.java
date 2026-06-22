package bean;

public class UserScope {
    private final boolean global;
    private final String college;
    private final String major;

    public UserScope(boolean global, String college, String major) {
        this.global = global;
        this.college = college;
        this.major = major;
    }

    public boolean isGlobal() {
        return global;
    }

    public String getCollege() {
        return college;
    }

    public String getMajor() {
        return major;
    }

    public boolean isMajorScope() {
        return !global && college != null && major != null;
    }
}
