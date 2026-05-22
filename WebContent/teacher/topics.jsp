<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "我的课题");
  User loginUser = (User) session.getAttribute("loginUser");
  TopicDao dao = new TopicDao();
  List<Topic> topics = dao.findByTeacher(loginUser.getId());
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-end mb-3">
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 发布课题</button>
</div>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128221;</div><p>还没有发布课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= t.getTitle() %></h6>
      <p><%= t.getDescription().length()>100 ? t.getDescription().substring(0,100)+"..." : t.getDescription() %></p>
      <div class="meta">
        名额: <%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>
        &nbsp;|&nbsp;
        <span class="badge-status badge-<%= t.getStatus() %>"><%= "open".equals(t.getStatus())?"开放":"关闭" %></span>
        &nbsp;|&nbsp; <%= sdf.format(t.getCreatedAt()) %>
      </div>
      <div class="mt-2">
        <button class="btn btn-sm btn-outline-primary" onclick="editTopic(<%= t.getId() %>,'<%= t.getTitle().replace("'","\\'") %>','<%= t.getDescription().replace("'","\\'").replace("\n","\\n").replace("\r","") %>',<%= t.getMaxStudents() %>,'<%= t.getStatus() %>')">编辑</button>
        <form id="delTopic<%= t.getId() %>" action="../teacher/topic.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= t.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delTopic<%= t.getId() %>','确定删除该课题吗？')">删除</button>
        </form>
      </div>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../teacher/topic.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">发布课题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称</label><input name="title" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述</label><textarea name="description" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="mb-2"><label class="form-label">最大人数</label><input name="maxStudents" type="number" value="1" min="1" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">状态</label><select name="status" class="form-select form-select-sm"><option value="open">开放选题</option><option value="closed">关闭选题</option></select></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">发布</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../teacher/topic.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑课题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称</label><input name="title" id="editTitle" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述</label><textarea name="description" id="editDesc" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="mb-2"><label class="form-label">最大人数</label><input name="maxStudents" id="editMax" type="number" min="1" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">状态</label><select name="status" id="editStatus" class="form-select form-select-sm"><option value="open">开放选题</option><option value="closed">关闭选题</option></select></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function editTopic(id,title,desc,max,status) {
  document.getElementById('editId').value = id;
  document.getElementById('editTitle').value = title;
  document.getElementById('editDesc').value = desc;
  document.getElementById('editMax').value = max;
  document.getElementById('editStatus').value = status;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
