package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import bean.UserSearchCriteria;
import dao.UserDao;
import util.CollegeUtil;
import util.DictionaryUtil;
import util.OperationLogUtil;
import util.PageUtil;
import util.SystemConfigUtil;
import util.WebUtil;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/user.action")
public class AdminUserController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserSearchCriteria criteria = buildCriteria(request);
        int page = PageUtil.getPage(request);
        int pageSize = PageUtil.getPageSize(request);

        UserDao dao = new UserDao();
        List<User> users = dao.findAllPaged(criteria, page, pageSize);
        int total = dao.countAll(criteria);
        String filterQuery = buildFilterQuery(criteria);

        request.setAttribute("users", users);
        request.setAttribute("total", total);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("roleFilter", criteria.getRole());
        request.setAttribute("collegeFilter", criteria.getCollege());
        request.setAttribute("majorFilter", criteria.getMajor());
        request.setAttribute("classNameFilter", criteria.getClassName());
        request.setAttribute("studentNoFilter", criteria.getStudentNo());
        request.setAttribute("realNameFilter", criteria.getRealName());
        request.setAttribute("filterQuery", filterQuery);
        request.setAttribute("roleOptions", DictionaryUtil.items("role"));
        request.setAttribute("userStatusOptions", DictionaryUtil.items("user_status"));
        request.setAttribute("collegeOptions", CollegeUtil.getColleges());
        request.setAttribute("majorGroups", CollegeUtil.getMajorGroups());
        request.setAttribute("usernamePattern",
            SystemConfigUtil.getString("validation.username_regex", "^[a-zA-Z0-9_]{3,20}$"));
        request.setAttribute("passwordMinLength",
            SystemConfigUtil.getInt("validation.password_min_length", 6));
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        UserDao dao = new UserDao();
        if ("add".equals(action)) {
            String username = request.getParameter("username");
            if (dao.existsByUsername(username)) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=username_exists");
                return;
            }
            User u = buildUser(request);
            u.setStatus(1);
            dao.insert(u);
            OperationLogUtil.log(loginUser.getId(), "ADD", "user", "新增用户 " + u.getUsername());
            WebUtil.redirect(request, response, "/admin/user.action?msg=add_ok");
        } else if ("edit".equals(action)) {
            int editId = Integer.parseInt(request.getParameter("id"));
            String username = request.getParameter("username");
            if (dao.existsByUsernameExcludeId(username, editId)) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=username_exists");
                return;
            }
            User u = buildUser(request);
            u.setId(editId);
            u.setStatus(Integer.parseInt(request.getParameter("status")));
            User current = dao.findById(editId);
            if (current == null) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=error");
                return;
            }
            if (editId == loginUser.getId()
                    && (!"admin".equals(u.getRole()) || u.getStatus() != 1)) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=edit_self_role");
                return;
            }
            if ("admin".equals(current.getRole())
                    && (!"admin".equals(u.getRole()) || u.getStatus() != 1)
                    && dao.countActiveAdmins() <= 1) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=last_admin");
                return;
            }
            String pwd = request.getParameter("password");
            u.setPassword(pwd == null || pwd.trim().isEmpty() ? null : pwd);
            dao.update(u);
            OperationLogUtil.log(loginUser.getId(), "UPDATE", "user", "编辑用户 id=" + u.getId());
            WebUtil.redirect(request, response, "/admin/user.action?msg=edit_ok");
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (id == loginUser.getId()) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=delete_self");
                return;
            }
            int result = dao.delete(id);
            if (result <= 0) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=delete_failed");
                return;
            }
            OperationLogUtil.log(loginUser.getId(), "DELETE", "user", "删除用户 id=" + id);
            WebUtil.redirect(request, response, "/admin/user.action?msg=delete_ok");
        } else if ("resetSelected".equals(action)) {
            String[] values = request.getParameterValues("selectedIds");
            String newPassword = request.getParameter("newPassword");
            if (!validNewPassword(newPassword)) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=reset_password_invalid");
                return;
            }
            List<Integer> ids = parseIds(values);
            int count = dao.resetStudentPasswords(ids, newPassword);
            OperationLogUtil.log(loginUser.getId(), "RESET_PASSWORD", "user",
                "按勾选重置学生密码 " + count + " 个");
            WebUtil.redirect(request, response,
                "/admin/user.action?msg=reset_ok&count=" + count);
        } else if ("resetFiltered".equals(action)) {
            String newPassword = request.getParameter("newPassword");
            if (!validNewPassword(newPassword)) {
                WebUtil.redirect(request, response, "/admin/user.action?msg=reset_password_invalid");
                return;
            }
            UserSearchCriteria criteria = buildCriteria(request);
            List<Integer> ids = dao.findStudentIdsForReset(criteria);
            int count = dao.resetStudentPasswords(ids, newPassword);
            OperationLogUtil.log(loginUser.getId(), "RESET_PASSWORD", "user",
                "按筛选重置学生密码 " + count + " 个");
            String query = buildFilterQuery(criteria);
            WebUtil.redirect(request, response,
                "/admin/user.action?" + query + (query.isEmpty() ? "" : "&")
                    + "msg=reset_ok&count=" + count);
        } else {
            WebUtil.redirect(request, response, "/admin/user.action");
        }
    }

    private User buildUser(HttpServletRequest request) {
        User u = new User();
        u.setUsername(request.getParameter("username"));
        u.setPassword(request.getParameter("password"));
        u.setRole(request.getParameter("role"));
        u.setRealName(request.getParameter("realName"));
        u.setStudentNo(request.getParameter("studentNo"));
        u.setCollege(request.getParameter("college"));
        u.setMajor(request.getParameter("major"));
        u.setClassName(request.getParameter("className"));
        u.setDepartment(request.getParameter("department"));
        u.setEmail(request.getParameter("email"));
        u.setPhone(request.getParameter("phone"));
        return u;
    }

    private UserSearchCriteria buildCriteria(HttpServletRequest request) {
        UserSearchCriteria criteria = new UserSearchCriteria();
        criteria.setRole(request.getParameter("role"));
        criteria.setCollege(request.getParameter("college"));
        criteria.setMajor(request.getParameter("major"));
        criteria.setClassName(request.getParameter("className"));
        criteria.setStudentNo(request.getParameter("studentNo"));
        criteria.setRealName(request.getParameter("realName"));
        return criteria;
    }

    private List<Integer> parseIds(String[] values) {
        List<Integer> ids = new ArrayList<Integer>();
        if (values == null) {
            return ids;
        }
        for (String value : values) {
            if (value == null || value.trim().isEmpty()) {
                continue;
            }
            try {
                ids.add(Integer.parseInt(value.trim()));
            } catch (NumberFormatException ignored) {
            }
        }
        return ids;
    }

    private boolean validNewPassword(String password) {
        int minLength = SystemConfigUtil.getInt("validation.password_min_length", 6);
        return password != null && password.length() >= minLength;
    }

    private String buildFilterQuery(UserSearchCriteria criteria) {
        StringBuilder sb = new StringBuilder();
        appendQuery(sb, "role", criteria.getRole());
        appendQuery(sb, "college", criteria.getCollege());
        appendQuery(sb, "major", criteria.getMajor());
        appendQuery(sb, "className", criteria.getClassName());
        appendQuery(sb, "studentNo", criteria.getStudentNo());
        appendQuery(sb, "realName", criteria.getRealName());
        return sb.toString();
    }

    private void appendQuery(StringBuilder sb, String key, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }
        try {
            if (sb.length() > 0) {
                sb.append("&");
            }
            sb.append(URLEncoder.encode(key, "UTF-8"))
                .append("=")
                .append(URLEncoder.encode(value, "UTF-8"));
        } catch (Exception ignored) {
        }
    }
}
