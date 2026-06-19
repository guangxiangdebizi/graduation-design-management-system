<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.CollegeUtil" %>
<%
  request.setAttribute("pageTitle", "我的课题");
  User loginUser = (User) session.getAttribute("loginUser");

  // 获取课题列表
  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  if (topics == null) {
    TopicDao dao = new TopicDao();
    topics = dao.findByTeacher(loginUser.getId());
  }

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

  // 消息提示
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("add_ok".equals(msg)) { msgTitle="成功"; msgContent="课题发布成功"; msgClass="success"; }
  else if ("edit_ok".equals(msg)) { msgTitle="成功"; msgContent="课题更新成功"; msgClass="success"; }
  else if ("delete_ok".equals(msg)) { msgTitle="成功"; msgContent="课题删除成功"; msgClass="success"; }
  else if ("delete_failed".equals(msg)) { msgTitle="失败"; msgContent="删除课题失败"; msgClass="danger"; }
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

<div class="d-flex justify-content-end mb-3">
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 发布课题</button>
</div>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128221;</div><p>还没有发布课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= EscapeUtil.html(t.getTitle()) %></h6>
      <p><%= EscapeUtil.html(t.getDescription() != null && t.getDescription().length() > 100 ? t.getDescription().substring(0, 100) + "..." : (t.getDescription() != null ? t.getDescription() : "")) %></p>
      <div class="meta">
        <span class="badge bg-info"><%= t.getCollegeName() != null ? t.getCollegeName() : "未分类" %></span>
        <br>
        名额: <%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>
        &nbsp;|&nbsp;
        <span class="badge-status badge-<%= t.getStatus() %>"><%= "open".equals(t.getStatus())?"开放":"关闭" %></span>
        &nbsp;|&nbsp; <%= t.getCreatedAt() != null ? sdf.format(t.getCreatedAt()) : "" %>
      </div>
      <div class="mt-2">
        <button class="btn btn-sm btn-outline-primary" onclick="editTopic(<%= t.getId() %>,'<%= EscapeUtil.js(t.getTitle()) %>','<%= EscapeUtil.js(t.getDescription() != null ? t.getDescription() : "") %>','<%= t.getCollege() != null ? t.getCollege() : "" %>',<%= t.getMaxStudents() %>,'<%= t.getStatus() %>')">编辑</button>
        <form id="delTopic<%= t.getId() %>" action="topic.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= t.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="if(confirm('确定删除该课题吗？'))document.getElementById('delTopic<%= t.getId() %>').submit()">删除</button>
        </form>
      </div>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">发布课题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称 *</label><input name="title" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述 *</label><textarea name="description" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2">
          <div class="col-6"><label class="form-label">所属学院 *</label>
            <select name="college" id="addCollege" class="form-select form-select-sm" required>
              <option value="">请选择学院</option>
              <% for (Map.Entry<String, String> e : CollegeUtil.COLLEGES.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-6"><label class="form-label">最大人数 *</label><input name="maxStudents" type="number" value="1" min="1" max="5" class="form-control form-control-sm" required></div>
        </div>
        <div class="mb-2"><label class="form-label">状态</label><select name="status" class="form-select form-select-sm"><option value="open">开放选题</option><option value="closed">关闭选题</option></select></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">发布</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑课题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称 *</label><input name="title" id="editTitle" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述 *</label><textarea name="description" id="editDesc" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2">
          <div class="col-6"><label class="form-label">所属学院 *</label>
            <select name="college" id="editCollege" class="form-select form-select-sm" required>
              <option value="">请选择学院</option>
              <% for (Map.Entry<String, String> e : CollegeUtil.COLLEGES.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= e.getValue() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-6"><label class="form-label">最大人数 *</label><input name="maxStudents" id="editMax" type="number" min="1" max="5" class="form-control form-control-sm" required></div>
        </div>
        <div class="mb-2"><label class="form-label">状态</label><select name="status" id="editStatus" class="form-select form-select-sm"><option value="open">开放选题</option><option value="closed">关闭选题</option></select></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function editTopic(id, title, desc, college, max, status) {
  document.getElementById('editId').value = id;
  document.getElementById('editTitle').value = title;
  document.getElementById('editDesc').value = desc;
  document.getElementById('editCollege').value = college;
  document.getElementById('editMax').value = max;
  document.getElementById('editStatus').value = status;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>