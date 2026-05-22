<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "公告管理");
  User loginUser = (User) session.getAttribute("loginUser");
  AnnouncementDao dao = new AnnouncementDao();
  List<Announcement> list = dao.findAll();
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
        <div class="title"><% if (a.getIsTop()==1) { %><span class="badge bg-danger me-1">置顶</span><% } %><%= a.getTitle() %></div>
        <div>
          <button class="btn btn-sm btn-outline-primary" onclick="editAnn(<%= a.getId() %>,'<%= a.getTitle().replace("'","\\'") %>','<%= a.getContent().replace("'","\\'").replace("\n","\\n").replace("\r","") %>',<%= a.getIsTop() %>)">编辑</button>
          <form id="delAnn<%= a.getId() %>" action="../admin/announcement.action" method="post" style="display:inline">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= a.getId() %>">
            <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delAnn<%= a.getId() %>','确定删除该公告吗？')">删除</button>
          </form>
        </div>
      </div>
      <div class="meta"><%= a.getPublisherName() %> · <%= sdf.format(a.getCreatedAt()) %></div>
      <div class="content"><%= a.getContent().replace("\n","<br>") %></div>
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
        <div class="form-check"><input type="checkbox" name="isTop" value="1" class="form-check-input" id="editIsTop"><label class="form-check-label" for="editIsTop">置顶</label></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function editAnn(id,title,content,isTop) {
  document.getElementById('editId').value = id;
  document.getElementById('editTitle').value = title;
  document.getElementById('editContent').value = content;
  document.getElementById('editIsTop').checked = isTop === 1;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
