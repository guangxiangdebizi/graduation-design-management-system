package dao;

import java.util.ArrayList;
import java.util.List;
import bean.User;
import dbutil.SQLHelper;
import util.PasswordUtil;
import util.DateUtil;

public class UserDao {
    public User findByUsername(String username) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT id,username,password,role,real_name,student_no,department,email,phone,status,created_at FROM users WHERE username=?",
            username);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public User findById(int id) {
        List<Object[]> rows = SQLHelper.queryList(
            "SELECT id,username,password,role,real_name,student_no,department,email,phone,status,created_at FROM users WHERE id=?",
            id);
        if (rows.isEmpty()) {
            return null;
        }
        return mapRow(rows.get(0));
    }

    public List<User> findAll(String role) {
        String sql = "SELECT id,username,password,role,real_name,student_no,department,email,phone,status,created_at FROM users";
        List<Object[]> rows;
        if (role != null && role.length() > 0) {
            sql += " WHERE role=? ORDER BY id";
            rows = SQLHelper.queryList(sql, role);
        } else {
            sql += " ORDER BY id";
            rows = SQLHelper.queryList(sql);
        }
        List<User> list = new ArrayList<User>();
        for (Object[] row : rows) {
            list.add(mapRow(row));
        }
        return list;
    }

    public int insert(User user) {
        return SQLHelper.executeInsert(
            "INSERT INTO users(username,password,role,real_name,student_no,department,email,phone,status) VALUES(?,?,?,?,?,?,?,?,?)",
            user.getUsername(), PasswordUtil.md5(user.getPassword()), user.getRole(),
            user.getRealName(), user.getStudentNo(), user.getDepartment(),
            user.getEmail(), user.getPhone(), user.getStatus());
    }

    public int update(User user) {
        if (user.getPassword() != null && user.getPassword().length() > 0) {
            return SQLHelper.executeUpdate(
                "UPDATE users SET username=?,password=?,role=?,real_name=?,student_no=?,department=?,email=?,phone=?,status=? WHERE id=?",
                user.getUsername(), PasswordUtil.md5(user.getPassword()), user.getRole(),
                user.getRealName(), user.getStudentNo(), user.getDepartment(),
                user.getEmail(), user.getPhone(), user.getStatus(), user.getId());
        }
        return SQLHelper.executeUpdate(
            "UPDATE users SET username=?,role=?,real_name=?,student_no=?,department=?,email=?,phone=?,status=? WHERE id=?",
            user.getUsername(), user.getRole(), user.getRealName(), user.getStudentNo(),
            user.getDepartment(), user.getEmail(), user.getPhone(), user.getStatus(), user.getId());
    }

    public int delete(int id) {
        return SQLHelper.executeUpdate("DELETE FROM users WHERE id=?", id);
    }

    public boolean validate(String username, String password) {
        User user = findByUsername(username);
        if (user == null || user.getStatus() != 1) {
            return false;
        }
        return PasswordUtil.md5(password).equals(user.getPassword());
    }

    public int countByRole(String role) {
        Object val = SQLHelper.queryScalar("SELECT COUNT(*) FROM users WHERE role=?", role);
        return val == null ? 0 : ((Number) val).intValue();
    }

    private User mapRow(Object[] row) {
        User u = new User();
        u.setId(((Number) row[0]).intValue());
        u.setUsername((String) row[1]);
        u.setPassword((String) row[2]);
        u.setRole((String) row[3]);
        u.setRealName((String) row[4]);
        u.setStudentNo((String) row[5]);
        u.setDepartment((String) row[6]);
        u.setEmail((String) row[7]);
        u.setPhone((String) row[8]);
        u.setStatus(((Number) row[9]).intValue());
        u.setCreatedAt(DateUtil.toDate(row[10]));
        return u;
    }
}
