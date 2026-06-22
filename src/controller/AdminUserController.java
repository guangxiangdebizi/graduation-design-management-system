package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.User;
import dao.UserDao;
import util.CollegeUtil;
import util.DictionaryUtil;
import util.OperationLogUtil;
import util.PageUtil;
import util.SystemConfigUtil;
import util.WebUtil;
import java.util.List;

@WebServlet("/admin/user.action")
public class AdminUserController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String college = request.getParameter("college");
        int page = PageUtil.getPage(request);
        int pageSize = PageUtil.getPageSize(request);

        UserDao dao = new UserDao();
        List<User> users = dao.findAllPaged(role, college, page, pageSize);
        int total = dao.countAll(role, college);

        request.setAttribute("users", users);
        request.setAttribute("total", total);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("roleFilter", role);
        request.setAttribute("collegeFilter", college);
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
}
