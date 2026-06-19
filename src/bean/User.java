package bean;

import java.util.Date;

public class User {
    private int id;
    private String username;
    private String password;
    private String role;
    private String realName;
    private String studentNo;
    private String college;      // 学院代码
    private String collegeName;  // 学院名称（展示用）
    private String major;        // 专业代码
    private String majorName;    // 专业名称（展示用）
    private String className;    // 班级
    private String department;    // 兼容旧字段
    private String email;
    private String phone;
    private int status;
    private Date createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
    public String getCollege() { return college; }
    public void setCollege(String college) { this.college = college; }
    public String getCollegeName() { return collegeName; }
    public void setCollegeName(String collegeName) { this.collegeName = collegeName; }
    public String getMajor() { return major; }
    public void setMajor(String major) { this.major = major; }
    public String getMajorName() { return majorName; }
    public void setMajorName(String majorName) { this.majorName = majorName; }
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    // 获取完整归属信息（用于显示）
    public String getFullAffiliation() {
        if ("student".equals(role)) {
            StringBuilder sb = new StringBuilder();
            if (collegeName != null) sb.append(collegeName);
            if (majorName != null) sb.append(" / ").append(majorName);
            if (className != null) sb.append(" / ").append(className);
            return sb.length() > 0 ? sb.toString() : (department != null ? department : "");
        } else {
            return department != null ? department : (collegeName != null ? collegeName : "");
        }
    }
}