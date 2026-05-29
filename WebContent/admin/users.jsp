<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,util.PageUtil,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "用户管理");
  User loginUser = (User) session.getAttribute("loginUser");
  UserDao dao = new UserDao();
  String roleFilter = request.getParameter("role");
  int currentPageNum = PageUtil.getPage(request);
  int pageSize = PageUtil.getPageSize(request);
  List<User> users = dao.findAllPaged(roleFilter, currentPageNum, pageSize);
  int total = dao.countAll(roleFilter);
  String pagBase = "users.jsp" + (roleFilter != null && roleFilter.length() > 0 ? "?role=" + roleFilter : "");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
  <div>
    <a href="?role=" class="btn btn-sm <%= roleFilter==null?"btn-primary":"btn-outline-primary" %>">全部</a>
    <a href="?role=admin" class="btn btn-sm <%= "admin".equals(roleFilter)?"btn-primary":"btn-outline-primary" %>">管理员</a>
    <a href="?role=teacher" class="btn btn-sm <%= "teacher".equals(roleFilter)?"btn-primary":"btn-outline-primary" %>">教师</a>
    <a href="?role=student" class="btn btn-sm <%= "student".equals(roleFilter)?"btn-primary":"btn-outline-primary" %>">学生</a>
  </div>
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 新增用户</button>
</div>

<div class="content-card">
  <table class="table-modern">
    <tr><th>ID</th><th>用户名</th><th>姓名</th><th>角色</th><th>学号</th><th>院系</th><th>状态</th><th>操作</th></tr>
    <% for (User u : users) { %>
    <tr>
      <td><%= u.getId() %></td>
      <td><%= u.getUsername() %></td>
      <td><%= u.getRealName() %></td>
      <td><%= u.getRole() %></td>
      <td><%= u.getStudentNo()==null?"—":u.getStudentNo() %></td>
      <td><%= u.getDepartment()==null?"—":u.getDepartment() %></td>
      <td><%= u.getStatus()==1?"正常":"禁用" %></td>
      <td>
        <button class="btn btn-sm btn-outline-primary" onclick="editUser(<%= u.getId() %>,'<%= u.getUsername() %>','<%= u.getRealName() %>','<%= u.getRole() %>','<%= u.getStudentNo()==null?"":u.getStudentNo() %>','<%= u.getDepartment()==null?"":u.getDepartment() %>','<%= u.getEmail()==null?"":u.getEmail() %>','<%= u.getPhone()==null?"":u.getPhone() %>',<%= u.getStatus() %>)">编辑</button>
        <% if (u.getId() != 1) { %>
        <form id="delForm<%= u.getId() %>" action="../admin/user.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= u.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delForm<%= u.getId() %>','确定删除用户 <%= u.getUsername() %> 吗？')">删除</button>
        </form>
        <% } %>
      </td>
    </tr>
    <% } %>
  </table>
  <% request.setAttribute("baseUrl", pagBase);
     request.setAttribute("page", currentPageNum);
     request.setAttribute("pageSize", pageSize);
     request.setAttribute("total", total); %>
  <%@ include file="/WEB-INF/includes/pagination.jsp" %>
</div>

<!-- Add Modal -->
<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/user.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">新增用户</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-6"><label class="form-label">用户名</label><input name="username" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">密码</label><input name="password" type="password" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">姓名</label><input name="realName" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">角色</label><select name="role" class="form-select form-select-sm"><option value="student">学生</option><option value="teacher">教师</option><option value="admin">管理员</option></select></div>
          <div class="col-6"><label class="form-label">学号</label><input name="studentNo" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">院系</label><input name="department" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">邮箱</label><input name="email" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">电话</label><input name="phone" class="form-control form-control-sm"></div>
        </div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/user.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑用户</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-6"><label class="form-label">用户名</label><input name="username" id="editUsername" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">新密码(留空不改)</label><input name="password" type="password" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">姓名</label><input name="realName" id="editRealName" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">角色</label><select name="role" id="editRole" class="form-select form-select-sm"><option value="student">学生</option><option value="teacher">教师</option><option value="admin">管理员</option></select></div>
          <div class="col-6"><label class="form-label">学号</label><input name="studentNo" id="editStudentNo" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">院系</label><input name="department" id="editDepartment" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">邮箱</label><input name="email" id="editEmail" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">电话</label><input name="phone" id="editPhone" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">状态</label><select name="status" id="editStatus" class="form-select form-select-sm"><option value="1">正常</option><option value="0">禁用</option></select></div>
        </div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function editUser(id,username,realName,role,studentNo,department,email,phone,status) {
  document.getElementById('editId').value = id;
  document.getElementById('editUsername').value = username;
  document.getElementById('editRealName').value = realName;
  document.getElementById('editRole').value = role;
  document.getElementById('editStudentNo').value = studentNo;
  document.getElementById('editDepartment').value = department;
  document.getElementById('editEmail').value = email;
  document.getElementById('editPhone').value = phone;
  document.getElementById('editStatus').value = status;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
