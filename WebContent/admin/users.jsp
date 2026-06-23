<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "用户管理");
  User loginUser = (User) session.getAttribute("loginUser");

  String roleFilter = (String) request.getAttribute("roleFilter");
  String collegeFilter = (String) request.getAttribute("collegeFilter");
  String majorFilter = (String) request.getAttribute("majorFilter");
  String classNameFilter = (String) request.getAttribute("classNameFilter");
  String studentNoFilter = (String) request.getAttribute("studentNoFilter");
  String realNameFilter = (String) request.getAttribute("realNameFilter");
  String filterQuery = (String) request.getAttribute("filterQuery");
  if (roleFilter == null) roleFilter = request.getParameter("role");
  if (collegeFilter == null) collegeFilter = request.getParameter("college");
  if (majorFilter == null) majorFilter = request.getParameter("major");
  if (classNameFilter == null) classNameFilter = request.getParameter("className");
  if (studentNoFilter == null) studentNoFilter = request.getParameter("studentNo");
  if (realNameFilter == null) realNameFilter = request.getParameter("realName");
  if (filterQuery == null) filterQuery = "";

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
  List<String> importErrors = (List<String>) session.getAttribute("userImportErrors");
  if (importErrors != null) session.removeAttribute("userImportErrors");
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

  String pagUrl = "user.action?" + filterQuery;

  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("add_ok".equals(msg)) { msgTitle="成功"; msgContent="用户添加成功"; msgClass="success"; }
  else if ("edit_ok".equals(msg)) { msgTitle="成功"; msgContent="用户更新成功"; msgClass="success"; }
  else if ("delete_ok".equals(msg)) { msgTitle="成功"; msgContent="用户删除成功"; msgClass="success"; }
  else if ("import_ok".equals(msg)) { msgTitle="成功"; msgContent="导入完成：成功 " + request.getParameter("success") + " 条，跳过 " + request.getParameter("skipped") + " 条"; msgClass="success"; }
  else if ("reset_ok".equals(msg)) { msgTitle="成功"; msgContent="学生密码重置完成，共处理 " + request.getParameter("count") + " 个账号"; msgClass="success"; }
  else if ("delete_failed".equals(msg)) { msgTitle="失败"; msgContent="删除用户失败"; msgClass="danger"; }
  else if ("delete_self".equals(msg)) { msgTitle="失败"; msgContent="不能删除当前登录用户"; msgClass="danger"; }
  else if ("username_exists".equals(msg)) { msgTitle="错误"; msgContent="用户名已存在"; msgClass="danger"; }
  else if ("import_empty".equals(msg)) { msgTitle="错误"; msgContent="请选择要导入的 Excel 文件"; msgClass="danger"; }
  else if ("import_error".equals(msg)) { msgTitle="错误"; msgContent="导入失败，请检查文件格式"; msgClass="danger"; }
  else if ("import_role_invalid".equals(msg)) { msgTitle="错误"; msgContent="只能导入教师或学生账号"; msgClass="danger"; }
  else if ("reset_password_invalid".equals(msg)) { msgTitle="错误"; msgContent="新密码长度不符合要求"; msgClass="danger"; }
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
<% if (importErrors != null && !importErrors.isEmpty()) { %>
<div class="alert alert-warning alert-dismissible fade show" role="alert">
  <strong>导入跳过明细：</strong>
  <% int maxErrors = Math.min(importErrors.size(), 8); %>
  <% for (int i = 0; i < maxErrors; i++) { %>
  <div class="small"><%= EscapeUtil.html(importErrors.get(i)) %></div>
  <% } %>
  <% if (importErrors.size() > maxErrors) { %>
  <div class="small">其余 <%= importErrors.size() - maxErrors %> 条已省略。</div>
  <% } %>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="content-card mb-3">
  <form action="user.action" method="get" class="row g-2 align-items-end">
    <div class="col-md-2">
      <label class="form-label">角色</label>
      <select name="role" class="form-select form-select-sm">
        <option value="">全部角色</option>
        <% for (Map.Entry<String, String> e : roleOptions.entrySet()) { %>
        <option value="<%= e.getKey() %>" <%= e.getKey().equals(roleFilter) ? "selected" : "" %>><%= e.getValue() %></option>
        <% } %>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label">学院</label>
      <select name="college" id="filterCollege" class="form-select form-select-sm" onchange="updateFilterMajors()">
        <option value="">全部学院</option>
        <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
        <option value="<%= e.getKey() %>" <%= e.getKey().equals(collegeFilter) ? "selected" : "" %>><%= e.getValue() %></option>
        <% } %>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label">专业</label>
      <select name="major" id="filterMajor" class="form-select form-select-sm">
        <option value="">全部专业</option>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label">班级</label>
      <input name="className" class="form-control form-control-sm" value="<%= EscapeUtil.attr(classNameFilter) %>" placeholder="支持模糊">
    </div>
    <div class="col-md-2">
      <label class="form-label">学号</label>
      <input name="studentNo" class="form-control form-control-sm" value="<%= EscapeUtil.attr(studentNoFilter) %>" placeholder="支持模糊">
    </div>
    <div class="col-md-2">
      <label class="form-label">姓名</label>
      <input name="realName" class="form-control form-control-sm" value="<%= EscapeUtil.attr(realNameFilter) %>" placeholder="支持模糊">
    </div>
    <div class="col-12 d-flex gap-2 flex-wrap">
      <button type="submit" class="btn btn-primary btn-sm">查询</button>
      <a href="user.action" class="btn btn-outline-secondary btn-sm">清空</a>
      <button type="button" class="btn btn-outline-success btn-sm" data-bs-toggle="modal" data-bs-target="#importModal">Excel 导入教师/学生</button>
      <button type="button" class="btn btn-outline-warning btn-sm" data-bs-toggle="modal" data-bs-target="#resetFilteredModal">按当前筛选重置学生密码</button>
      <button type="button" class="btn btn-primary btn-sm ms-auto" data-bs-toggle="modal" data-bs-target="#addModal">+ 新增用户</button>
    </div>
  </form>
</div>

<form id="selectedResetForm" action="user.action" method="post" style="display:none">
  <input type="hidden" name="action" value="resetSelected">
</form>
<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="text-muted small">勾选学生后可批量重置密码；教师/管理员不会被勾选重置。</div>
    <div class="d-flex gap-2 align-items-center">
      <input type="password" name="newPassword" form="selectedResetForm" class="form-control form-control-sm" style="width:160px" minlength="<%= passwordMinLength %>" placeholder="新密码" required>
      <button type="submit" form="selectedResetForm" class="btn btn-warning btn-sm" onclick="return confirmSelectedReset()">重置勾选学生</button>
    </div>
  </div>
  <table class="table-modern">
    <tr><th><input type="checkbox" id="checkAllStudents" onclick="toggleStudentChecks(this)"></th><th>姓名</th><th>ID</th><th>用户名</th><th>学院</th><th>专业</th><th>身份/职称</th><th>权限角色</th><th>班级</th><th>学号</th><th>状态</th><th>操作</th></tr>
    <% for (User u : users) { %>
    <tr>
      <td>
        <% if ("student".equals(u.getRole())) { %>
        <input type="checkbox" name="selectedIds" value="<%= u.getId() %>" class="student-check" form="selectedResetForm">
        <% } %>
      </td>
      <td><%= EscapeUtil.html(u.getRealName()) %></td>
      <td><%= u.getId() %></td>
      <td><%= EscapeUtil.html(u.getUsername()) %></td>
      <td><%= u.getCollegeName() != null ? u.getCollegeName() : "—" %></td>
      <td><%= u.getMajorName() != null ? u.getMajorName() : "—" %></td>
      <td><%= EscapeUtil.html(u.getDisplayTitle()) %></td>
      <td><span class="badge bg-<%= "admin".equals(u.getRole())?"danger":("director".equals(u.getRole())?"info":("teacher".equals(u.getRole())?"warning":"primary")) %>"><%= roleOptions.get(u.getRole()) %></span></td>
      <td><%= u.getClassName() != null ? u.getClassName() : "—" %></td>
      <td><%= u.getStudentNo() != null ? u.getStudentNo() : "—" %></td>
      <td><span class="badge bg-<%= u.getStatus()==1?"success":"secondary" %>"><%= userStatusOptions.get(String.valueOf(u.getStatus())) %></span></td>
      <td>
        <button class="btn btn-sm btn-outline-primary" onclick="editUser('<%= u.getId() %>','<%= EscapeUtil.js(u.getUsername()) %>','<%= EscapeUtil.js(u.getRealName()) %>','<%= EscapeUtil.js(u.getTitle() != null ? u.getTitle() : "") %>','<%= u.getRole() %>','<%= EscapeUtil.js(u.getCollege() != null ? u.getCollege() : "") %>','<%= EscapeUtil.js(u.getMajor() != null ? u.getMajor() : "") %>','<%= EscapeUtil.js(u.getClassName() != null ? u.getClassName() : "") %>','<%= EscapeUtil.js(u.getStudentNo() != null ? u.getStudentNo() : "") %>','<%= EscapeUtil.js(u.getEmail() != null ? u.getEmail() : "") %>','<%= EscapeUtil.js(u.getPhone() != null ? u.getPhone() : "") %>',<%= u.getStatus() %>)">编辑</button>
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
    <tr><td colspan="12" class="text-center text-muted py-4">暂无数据</td></tr>
    <% } %>
  </table>
  <% request.setAttribute("baseUrl", pagUrl);
     request.setAttribute("page", currentPage);
     request.setAttribute("pageSize", pageSize);
     request.setAttribute("total", total); %>
  <%@ include file="/WEB-INF/includes/pagination.jsp" %>
</div>

<!-- Import Modal -->
<div class="modal fade" id="importModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/user-import.action" method="post" enctype="multipart/form-data">
      <div class="modal-header"><h6 class="modal-title">Excel 批量导入教师/学生</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="alert alert-info small py-2">
          首行为表头；列顺序：用户名、姓名、学号、学院代码、专业代码、班级、部门/院系、邮箱、电话、初始密码、身份/职称。学生用户名可留空，系统用学号作为用户名；密码留空默认 123456；身份/职称留空时按角色自动填充。
        </div>
        <div class="mb-2">
          <label class="form-label">导入类型</label>
          <select name="importRole" class="form-select form-select-sm" required>
            <option value="student">学生</option>
            <option value="teacher">教师</option>
          </select>
        </div>
        <div>
          <label class="form-label">Excel 文件</label>
          <input type="file" name="file" class="form-control form-control-sm" accept=".xlsx,.xls" required>
        </div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-success btn-sm">开始导入</button></div>
    </form>
  </div></div>
</div>

<!-- Reset Filtered Modal -->
<div class="modal fade" id="resetFilteredModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="user.action" method="post" onsubmit="return confirm('确定按当前筛选条件重置所有匹配学生的密码吗？教师和管理员不会被重置。')">
      <input type="hidden" name="action" value="resetFiltered">
      <input type="hidden" name="role" value="<%= EscapeUtil.attr(roleFilter) %>">
      <input type="hidden" name="college" value="<%= EscapeUtil.attr(collegeFilter) %>">
      <input type="hidden" name="major" value="<%= EscapeUtil.attr(majorFilter) %>">
      <input type="hidden" name="className" value="<%= EscapeUtil.attr(classNameFilter) %>">
      <input type="hidden" name="studentNo" value="<%= EscapeUtil.attr(studentNoFilter) %>">
      <input type="hidden" name="realName" value="<%= EscapeUtil.attr(realNameFilter) %>">
      <div class="modal-header"><h6 class="modal-title">按筛选结果重置学生密码</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <p class="small text-muted">当前筛选命中总数：<%= total %>。实际只会重置其中角色为“学生”的账号。</p>
        <label class="form-label">新密码</label>
        <input type="password" name="newPassword" class="form-control form-control-sm" minlength="<%= passwordMinLength %>" required>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-warning btn-sm">确认重置</button></div>
    </form>
  </div></div>
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
          <div class="col-6"><label class="form-label">身份/职称</label><input name="title" class="form-control form-control-sm" placeholder="如：教授、副教授、系主任、学生"></div>
          <div class="col-6"><label class="form-label">权限角色 *</label>
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
          <div class="col-6"><label class="form-label">身份/职称</label><input name="title" id="editTitle" class="form-control form-control-sm" placeholder="如：教授、副教授、系主任、学生"></div>
          <div class="col-6"><label class="form-label">权限角色 *</label>
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

function updateFilterMajors() {
  var college = document.getElementById('filterCollege').value;
  var majorSelect = document.getElementById('filterMajor');
  var selected = '<%= EscapeUtil.js(majorFilter != null ? majorFilter : "") %>';
  majorSelect.innerHTML = '<option value="">全部专业</option>';
  if (college && majorsData[college]) {
    for (var key in majorsData[college]) {
      var option = document.createElement('option');
      option.value = key;
      option.textContent = majorsData[college][key];
      if (key === selected) option.selected = true;
      majorSelect.appendChild(option);
    }
  }
}

function toggleStudentChecks(source) {
  document.querySelectorAll('.student-check').forEach(function(cb) {
    cb.checked = source.checked;
  });
}

function confirmSelectedReset() {
  var checked = document.querySelectorAll('.student-check:checked').length;
  if (checked === 0) {
    alert('请先勾选要重置密码的学生。');
    return false;
  }
  return confirm('确定重置已勾选的 ' + checked + ' 个学生账号密码吗？');
}

function editUser(id, username, realName, title, role, college, major, className, studentNo, email, phone, status) {
  document.getElementById('editId').value = id;
  document.getElementById('editUsername').value = username;
  document.getElementById('editRealName').value = realName;
  document.getElementById('editTitle').value = title;
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

updateFilterMajors();
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
