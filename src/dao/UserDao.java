package dao;

import java.util.ArrayList;
import java.util.List;
import bean.User;
import dbutil.SQLHelper;
import util.PasswordUtil;
import util.DateUtil;
import util.PageUtil;
import util.CollegeUtil;

public class UserDao {
    private static final String SELECT_COLS =
        "id,username,password,role,real_name,student_no,college,major,class_name,department,email,phone,status,created_at";

    public User findByUsername(String username) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + " FROM users WHERE username=?", username);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public User findByStudentNo(String studentNo) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + " FROM users WHERE student_no=?", studentNo);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public User findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT " + SELECT_COLS + " FROM users WHERE id=?", id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public List<User> findAll(String role, String college) {
        StringBuilder sql = new StringBuilder("SELECT " + SELECT_COLS + " FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role=?");
            params.add(role);
        }
        if (college != null && !college.isEmpty()) {
            sql.append(" AND college=?");
            params.add(college);
        }
        sql.append(" ORDER BY id");
        List<Object[]> rows = params.isEmpty() ?
            SQLHelper.queryList(sql.toString()) :
            SQLHelper.queryList(sql.toString(), params.toArray());
        List<User> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    public List<User> findAll(String role) {
        return findAll(role, null);
    }

    public List<User> findAllPaged(String role, String college, int page, int pageSize) {
        StringBuilder sql = new StringBuilder("SELECT " + SELECT_COLS + " FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role=?");
            params.add(role);
        }
        if (college != null && !college.isEmpty()) {
            sql.append(" AND college=?");
            params.add(college);
        }
        sql.append(" ORDER BY id LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(PageUtil.offset(page, pageSize));
        List<Object[]> rows = SQLHelper.queryList(sql.toString(), params.toArray());
        List<User> list = new ArrayList<>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    public int countAll(String role, String college) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role=?");
            params.add(role);
        }
        if (college != null && !college.isEmpty()) {
            sql.append(" AND college=?");
            params.add(college);
        }
        Object val = params.isEmpty() ?
            SQLHelper.queryScalar(sql.toString()) :
            SQLHelper.queryScalar(sql.toString(), params.toArray());
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int insert(User user) {
        return SQLHelper.executeInsert(
            "INSERT INTO users(username,password,role,real_name,student_no,college,major,class_name,department,email,phone,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)",
            user.getUsername(), PasswordUtil.hash(user.getPassword()), user.getRole(),
            user.getRealName(), user.getStudentNo(), user.getCollege(), user.getMajor(),
            user.getClassName(), user.getDepartment(), user.getEmail(), user.getPhone(), user.getStatus());
    }

    public int update(User user) {
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            return SQLHelper.executeUpdate(
                "UPDATE users SET username=?,password=?,role=?,real_name=?,student_no=?,college=?,major=?,class_name=?,department=?,email=?,phone=?,status=? WHERE id=?",
                user.getUsername(), PasswordUtil.hash(user.getPassword()), user.getRole(),
                user.getRealName(), user.getStudentNo(), user.getCollege(), user.getMajor(),
                user.getClassName(), user.getDepartment(), user.getEmail(), user.getPhone(),
                user.getStatus(), user.getId());
        }
        return SQLHelper.executeUpdate(
            "UPDATE users SET username=?,role=?,real_name=?,student_no=?,college=?,major=?,class_name=?,department=?,email=?,phone=?,status=? WHERE id=?",
            user.getUsername(), user.getRole(), user.getRealName(), user.getStudentNo(),
            user.getCollege(), user.getMajor(), user.getClassName(), user.getDepartment(),
            user.getEmail(), user.getPhone(), user.getStatus(), user.getId());
    }

    public int delete(int id) {
        return SQLHelper.executeUpdate("DELETE FROM users WHERE id=?", id);
    }

    public boolean validate(String username, String password) {
        User user = findByUsername(username);
        if (user == null || user.getStatus() != 1) {
            return false;
        }
        return PasswordUtil.matches(password, user.getPassword());
    }

    public int countByRole(String role) {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM users WHERE role=?", role);
        return val == null ? 0 : ((Number) val).intValue();
    }

    public int countActiveAdmins() {
        Object val = SQLHelper.queryScalar(
            "SELECT COUNT(*) FROM users WHERE role='admin' AND status=1");
        return val == null ? 0 : ((Number) val).intValue();
    }

    public boolean existsByUsername(String username) {
        Object val = SQLHelper.queryScalar("SELECT 1 FROM users WHERE username=?", username);
        return val != null;
    }

    public boolean existsByUsernameExcludeId(String username, int excludeId) {
        Object val = SQLHelper.queryScalar(
            "SELECT 1 FROM users WHERE username=? AND id<>?", username, excludeId);
        return val != null;
    }

    private User mapRow(Object[] row) {
        User u = new User();
        u.setId(((Number) row[0]).intValue());
        u.setUsername((String) row[1]);
        u.setPassword((String) row[2]);
        u.setRole((String) row[3]);
        u.setRealName((String) row[4]);
        u.setStudentNo((String) row[5]);
        u.setCollege((String) row[6]);
        u.setMajor((String) row[7]);
        u.setClassName((String) row[8]);
        u.setDepartment((String) row[9]);
        u.setEmail((String) row[10]);
        u.setPhone((String) row[11]);
        u.setStatus(((Number) row[12]).intValue());
        u.setCreatedAt(DateUtil.toDate(row[13]));

        // 翻译学院和专业名称
        if (u.getCollege() != null) {
            u.setCollegeName(CollegeUtil.getCollegeName(u.getCollege()));
        }
        if (u.getCollege() != null && u.getMajor() != null) {
            u.setMajorName(CollegeUtil.getMajorName(u.getCollege(), u.getMajor()));
        }
        return u;
    }
}
