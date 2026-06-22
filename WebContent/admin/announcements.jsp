<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.CollegeUtil" %>
<%
  request.setAttribute("pageTitle", "公告管理");
  User loginUser = (User) session.getAttribute("loginUser");
  AnnouncementDao dao = new AnnouncementDao();
  List<Announcement> list = dao.findAll();
  Map<String, String> collegeOptions = CollegeUtil.getColleges();
  Map<String, Map<String, String>> majorGroups = CollegeUtil.getMajorGroups();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-end mb-3">
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 发布公告</button>
</div>

<div class="content-card">
  <% if (list.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128227;</div><p>暂无公告，点击上方按钮发布</p></div>
  <% } else { for (Announcement a : list) { %>
    <div class="announce-item">
      <div class="d-flex justify-content-between">
        <div class="title"><% if (a.getIsTop()==1) { %><span class="badge bg-danger me-1">置顶</span><% } %><%= EscapeUtil.html(a.getTitle()) %></div>
        <div>
          <button class="btn btn-sm btn-outline-primary" onclick="editAnn(<%= a.getId() %>,'<%= EscapeUtil.js(a.getTitle()) %>','<%= EscapeUtil.js(a.getContent()) %>',<%= a.getIsTop() %>,'<%= EscapeUtil.js(a.getScopeType()) %>','<%= EscapeUtil.js(a.getCollege()) %>','<%= EscapeUtil.js(a.getMajor()) %>')">编辑</button>
          <form id="delAnn<%= a.getId() %>" action="../admin/announcement.action" method="post" style="display:inline">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= a.getId() %>">
            <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delAnn<%= a.getId() %>','确定删除该公告吗？')">删除</button>
          </form>
        </div>
      </div>
      <div class="meta"><%= EscapeUtil.html(a.getPublisherName()) %> · <%= EscapeUtil.html(scopeText(a)) %> · <%= sdf.format(a.getCreatedAt()) %></div>
      <div class="content"><%= EscapeUtil.html(a.getContent()).replace("\n","<br>") %></div>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/announcement.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">发布公告</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">标题</label><input name="title" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">内容</label><textarea name="content" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2 mb-2">
          <div class="col-md-4"><label class="form-label">发布范围</label><select name="scopeType" id="addScopeType" class="form-select form-select-sm" onchange="toggleScopeFields('add')">
            <option value="global">全校</option>
            <option value="college">学院/学部</option>
            <option value="major">专业</option>
          </select></div>
          <div class="col-md-4"><label class="form-label">学院/学部</label><select name="college" id="addCollege" class="form-select form-select-sm" onchange="updateScopeMajors('add')">
            <option value="">请选择</option>
            <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
            <option value="<%= e.getKey() %>"><%= EscapeUtil.html(e.getValue()) %></option>
            <% } %>
          </select></div>
          <div class="col-md-4"><label class="form-label">专业</label><select name="major" id="addMajor" class="form-select form-select-sm"><option value="">请选择</option></select></div>
        </div>
        <div class="form-check"><input type="checkbox" name="isTop" value="1" class="form-check-input" id="isTop"><label class="form-check-label" for="isTop">置顶</label></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">发布</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/announcement.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑公告</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">标题</label><input name="title" id="editTitle" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">内容</label><textarea name="content" id="editContent" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2 mb-2">
          <div class="col-md-4"><label class="form-label">发布范围</label><select name="scopeType" id="editScopeType" class="form-select form-select-sm" onchange="toggleScopeFields('edit')">
            <option value="global">全校</option>
            <option value="college">学院/学部</option>
            <option value="major">专业</option>
          </select></div>
          <div class="col-md-4"><label class="form-label">学院/学部</label><select name="college" id="editCollege" class="form-select form-select-sm" onchange="updateScopeMajors('edit')">
            <option value="">请选择</option>
            <% for (Map.Entry<String, String> e : collegeOptions.entrySet()) { %>
            <option value="<%= e.getKey() %>"><%= EscapeUtil.html(e.getValue()) %></option>
            <% } %>
          </select></div>
          <div class="col-md-4"><label class="form-label">专业</label><select name="major" id="editMajor" class="form-select form-select-sm"><option value="">请选择</option></select></div>
        </div>
        <div class="form-check"><input type="checkbox" name="isTop" value="1" class="form-check-input" id="editIsTop"><label class="form-check-label" for="editIsTop">置顶</label></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
var majorsData = {
  <% int cidx = 0; for (Map.Entry<String, Map<String, String>> group : majorGroups.entrySet()) { %>
  <%= cidx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(group.getKey()) %>": {
    <% int midx = 0; for (Map.Entry<String, String> e : group.getValue().entrySet()) { %>
    <%= midx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(e.getKey()) %>": "<%= EscapeUtil.js(e.getValue()) %>"
    <% } %>
  }
  <% } %>
};

function updateScopeMajors(prefix, selectedMajor) {
  var college = document.getElementById(prefix + 'College').value;
  var majorSelect = document.getElementById(prefix + 'Major');
  majorSelect.innerHTML = '<option value="">请选择</option>';
  if (college && majorsData[college]) {
    for (var key in majorsData[college]) {
      var option = document.createElement('option');
      option.value = key;
      option.textContent = majorsData[college][key];
      if (key === selectedMajor) option.selected = true;
      majorSelect.appendChild(option);
    }
  }
}

function toggleScopeFields(prefix) {
  var type = document.getElementById(prefix + 'ScopeType').value;
  document.getElementById(prefix + 'College').disabled = type === 'global';
  document.getElementById(prefix + 'Major').disabled = type !== 'major';
}

function editAnn(id,title,content,isTop,scopeType,college,major) {
  document.getElementById('editId').value = id;
  document.getElementById('editTitle').value = title;
  document.getElementById('editContent').value = content;
  document.getElementById('editIsTop').checked = isTop === 1;
  document.getElementById('editScopeType').value = scopeType || 'global';
  document.getElementById('editCollege').value = college || '';
  updateScopeMajors('edit', major || '');
  toggleScopeFields('edit');
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
toggleScopeFields('add');
toggleScopeFields('edit');
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>

<%!
  private String scopeText(Announcement a) {
    if ("major".equals(a.getScopeType())) {
      return "专业：" + safe(a.getCollegeName()) + " / " + safe(a.getMajorName());
    }
    if ("college".equals(a.getScopeType())) {
      return "学院：" + safe(a.getCollegeName());
    }
    return "全校";
  }
  private String safe(String value) {
    return value == null ? "" : value;
  }
%>
