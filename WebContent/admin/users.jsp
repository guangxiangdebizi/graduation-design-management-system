<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "用户管理");
  User loginUser = (User) session.getAttribute("loginUser");

  String roleFilter = request.getParameter("role");
  String collegeFilter = request.getParameter("college");

  List<User> users = (List<User>) request.getAttribute("users");
  Integer totalAttr = (Integer) request.getAttribute("total");
  Integer pageAttr = (Integer) request.getAttribute("currentPage");
  Integer pageSizeAttr = (Integer) request.getAttribute("pageSize");
  Map<String, String> roleOptions = (Map<String, String>) request.getAttribute("roleOptions");
  Map<String, String> userStatusOptions = (Map<String, String>) request.getAttribute("userStatusOptions");
  Map<String, String> collegeOptions = (Map<String, String>) request.getAttribute("collegeOptions");
  Map<String, Map<String, String>> majorGroups =
      (Map<String, Map<String, String>>) request.getAttribute("majorGroups");
  String usernamePattern = (String) request.getAttribute("usernamePattern");
  Integer passwordMinLength = (Integer) request.getAttribute("passwordMinLength");
  if (roleOptions == null) roleOptions = new LinkedHashMap<String, String>();
  if (userStatusOptions == null) userStatusOptions = new LinkedHashMap<String, String>();
  if (collegeOptions == null) collegeOptions = new LinkedHashMap<String, String>();
  if (majorGroups == null) majorGroups = new LinkedHashMap<String, Map<String, String>>();
  if (usernamePattern == null) usernamePattern = "^[a-zA-Z0-9_]{3,20}$";
  if (passwordMinLength == null) passwordMinLength = 6;

  int currentPage, pageSize, total;
  if (users == null) {
    response.sendRedirect(request.getContextPath() + "/admin/user.action");
    return;
  } else {
    currentPage = pageAttr != null ? pageAttr : 1;
    pageSize = pageSizeAttr != null ? pageSizeAttr : 20;
    total = totalAttr != null ? totalAttr : 0;
  }

  StringBuilder pagBase = new StringBuilder("user.action?");
  if (roleFilter != null && !roleFilter.isEmpty()) pagBase.append("role=").append(roleFilter).append("&");
  if (collegeFilter != null && !collegeFilter.isEmpty()) pagBase.append("college=").append(collegeFilter).append("&");
  String pagUrl = pagBase.toString();

  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("add_ok".equals(msg)) { msgTitle="成功"; msgContent="用户添加成功"; msgClass="success"; }
  else if ("edit_ok".equals(msg)) { msgTitle="成功"; msgContent="用户更新成功"; msgClass="success"; }
  else if ("delete_ok".equals(msg)) { msgTitle="成功"; msgContent="用户删除成功"; msgClass="success"; }
  else if ("delete_failed".equals(msg)) { msgTitle="失败"; msgContent="删除用户失败"; msgClass="danger"; }
  else if ("delete_self".equals(msg)) { msgTitle="失败"; msgContent="不能删除当前登录用户"; msgClass="danger"; }
  else if ("username_exists".equals(msg)) { msgTitle="错误"; msgContent="用户名已存在"; msgClass="danger"; }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (!msgTitle.isEmpty()) { %>
<div class="alert alert-<%= msgClass %> alert-dismissible fade show" role="alert">
  <strong><%= msgTitle %>：</strong><%= msgContent %>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="d-flex justify-content-between align-items-center mb-3">
  <div class="d-flex gap-2 flex-wrap align-items-center">
    <a href="user.action" class="btn btn-sm <%= roleFilter==null?"btn-primary":"btn-outline-primary" %>">全部</a>
    <% for (Map.Entry<String, String> e : roleOptions.entrySet()) { %>
    <a href="user.action?role=<%= e.getKey() %>" class="btn btn-sm <%= e.getKey().equals(roleFilter)?"btn-primary":"btn-outline-primary" %>"><%= e.getValue() %></a>
    <% } %>
    <span class="vr"></span>
    <select id="collegeFilter" class="form-select form-select-sm" style="width:150px" onchange="location.href='user.action?role=<%= roleFilter != null ? roleFilter : "" %>&college='+this.value">
      <option value="">全部学院</option>
      <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
      <option value="<%= e.getKey() %>" <%= e.getKey().equals(collegeFilter) ? "selected" : "" %>><%= e.getValue() %></option>
      <% } %>
    </select>
  </div>
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 新增用户</button>
</div>

<div class="content-card">
  <table class="table-modern">
    <tr><th>ID</th><th>用户名</th><th>姓名</th><th>角色</th><th>学院</th><th>专业</th><th>班级</th><th>学号</th><th>状态</th><th>操作</th></tr>
    <% for (User u : users) { %>
    <tr>
      <td><%= u.getId() %></td>
      <td><%= EscapeUtil.html(u.getUsername()) %></td>
      <td><%= EscapeUtil.html(u.getRealName()) %></td>
      <td><span class="badge bg-<%= "admin".equals(u.getRole())?"danger":("teacher".equals(u.getRole())?"warning":"primary") %>"><%= roleOptions.get(u.getRole()) %></span></td>
      <td><%= u.getCollegeName() != null ? u.getCollegeName() : "—" %></td>
      <td><%= u.getMajorName() != null ? u.getMajorName() : "—" %></td>
      <td><%= u.getClassName() != null ? u.getClassName() : "—" %></td>
      <td><%= u.getStudentNo() != null ? u.getStudentNo() : "—" %></td>
      <td><span class="badge bg-<%= u.getStatus()==1?"success":"secondary" %>"><%= userStatusOptions.get(String.valueOf(u.getStatus())) %></span></td>
      <td>
        <button class="btn btn-sm btn-outline-primary" onclick="editUser('<%= u.getId() %>','<%= EscapeUtil.js(u.getUsername()) %>','<%= EscapeUtil.js(u.getRealName()) %>','<%= u.getRole() %>','<%= EscapeUtil.js(u.getCollege() != null ? u.getCollege() : "") %>','<%= EscapeUtil.js(u.getMajor() != null ? u.getMajor() : "") %>','<%= EscapeUtil.js(u.getClassName() != null ? u.getClassName() : "") %>','<%= EscapeUtil.js(u.getStudentNo() != null ? u.getStudentNo() : "") %>','<%= EscapeUtil.js(u.getEmail() != null ? u.getEmail() : "") %>','<%= EscapeUtil.js(u.getPhone() != null ? u.getPhone() : "") %>',<%= u.getStatus() %>)">编辑</button>
        <% if (u.getId() != 1) { %>
        <form action="user.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= u.getId() %>">
          <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('确定删除用户 <%= EscapeUtil.js(u.getUsername()) %> 吗？')">删除</button>
        </form>
        <% } %>
      </td>
    </tr>
    <% } %>
    <% if (users.isEmpty()) { %>
    <tr><td colspan="10" class="text-center text-muted py-4">暂无数据</td></tr>
    <% } %>
  </table>
  <% request.setAttribute("baseUrl", pagUrl);
     request.setAttribute("page", currentPage);
     request.setAttribute("pageSize", pageSize);
     request.setAttribute("total", total); %>
  <%@ include file="/WEB-INF/includes/pagination.jsp" %>
</div>

<!-- Add Modal -->
<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="user.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">新增用户</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-6"><label class="form-label">用户名 *</label><input name="username" class="form-control form-control-sm" required pattern="<%= EscapeUtil.attr(usernamePattern) %>"></div>
          <div class="col-6"><label class="form-label">密码 *</label><input name="password" type="password" class="form-control form-control-sm" required minlength="<%= passwordMinLength %>"></div>
          <div class="col-6"><label class="form-label">姓名 *</label><input name="realName" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">角色 *</label>
            <select name="role" class="form-select form-select-sm">
              <% for (Map.Entry<String, String> e : roleOptions.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-4"><label class="form-label">学院</label>
            <select name="college" id="addCollege" class="form-select form-select-sm" onchange="updateAddMajors()">
              <option value="">请选择学院</option>
              <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-4"><label class="form-label">专业</label>
            <select name="major" id="addMajor" class="form-select form-select-sm"><option value="">请先选择学院</option></select>
          </div>
          <div class="col-4"><label class="form-label">班级</label><input name="className" id="addClass" class="form-control form-control-sm" placeholder="如：计算机2022级1班"></div>
          <div class="col-6"><label class="form-label">学号</label><input name="studentNo" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">部门/院系</label><input name="department" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">邮箱</label><input name="email" type="email" class="form-control form-control-sm"></div>
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
    <form action="user.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑用户</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-6"><label class="form-label">用户名 *</label><input name="username" id="editUsername" class="form-control form-control-sm" required pattern="<%= EscapeUtil.attr(usernamePattern) %>"></div>
          <div class="col-6"><label class="form-label">新密码(留空不改)</label><input name="password" type="password" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">姓名 *</label><input name="realName" id="editRealName" class="form-control form-control-sm" required></div>
          <div class="col-6"><label class="form-label">角色 *</label>
            <select name="role" id="editRole" class="form-select form-select-sm">
              <% for (Map.Entry<String, String> e : roleOptions.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-4"><label class="form-label">学院</label>
            <select name="college" id="editCollege" class="form-select form-select-sm" onchange="updateEditMajors()">
              <option value="">请选择学院</option>
              <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-4"><label class="form-label">专业</label>
            <select name="major" id="editMajor" class="form-select form-select-sm"><option value="">请先选择学院</option></select>
          </div>
          <div class="col-4"><label class="form-label">班级</label><input name="className" id="editClass" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">学号</label><input name="studentNo" id="editStudentNo" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">部门/院系</label><input name="department" id="editDepartment" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">邮箱</label><input name="email" id="editEmail" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">电话</label><input name="phone" id="editPhone" class="form-control form-control-sm"></div>
          <div class="col-6"><label class="form-label">状态</label>
            <select name="status" id="editStatus" class="form-select form-select-sm">
              <% for (Map.Entry<String, String> e : userStatusOptions.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
        </div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
// 专业数据（后端从数据库加载）
var majorsData = {
  <% int cidx = 0; for (Map.Entry<String, Map<String, String>> group : majorGroups.entrySet()) { %>
  <%= cidx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(group.getKey()) %>": {
    <% int midx = 0; for (Map.Entry<String, String> e : group.getValue().entrySet()) { %>
    <%= midx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(e.getKey()) %>": "<%= EscapeUtil.js(e.getValue()) %>"
    <% } %>
  }
  <% } %>
};

function updateAddMajors() {
  var college = document.getElementById('addCollege').value;
  var majorSelect = document.getElementById('addMajor');
  majorSelect.innerHTML = '<option value="">请选择专业</option>';
  if (college && majorsData[college]) {
    for (var key in majorsData[college]) {
      majorSelect.innerHTML += '<option value="' + key + '">' + majorsData[college][key] + '</option>';
    }
  }
}

function updateEditMajors() {
  var college = document.getElementById('editCollege').value;
  var majorSelect = document.getElementById('editMajor');
  majorSelect.innerHTML = '<option value="">请选择专业</option>';
  if (college && majorsData[college]) {
    for (var key in majorsData[college]) {
      majorSelect.innerHTML += '<option value="' + key + '">' + majorsData[college][key] + '</option>';
    }
  }
}

function editUser(id, username, realName, role, college, major, className, studentNo, email, phone, status) {
  document.getElementById('editId').value = id;
  document.getElementById('editUsername').value = username;
  document.getElementById('editRealName').value = realName;
  document.getElementById('editRole').value = role;
  document.getElementById('editCollege').value = college;
  updateEditMajors();
  document.getElementById('editMajor').value = major;
  document.getElementById('editClass').value = className;
  document.getElementById('editStudentNo').value = studentNo;
  document.getElementById('editEmail').value = email;
  document.getElementById('editPhone').value = phone;
  document.getElementById('editStatus').value = status;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
