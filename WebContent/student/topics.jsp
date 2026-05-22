<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*" %>
<%
  request.setAttribute("pageTitle", "浏览课题");
  User loginUser = (User) session.getAttribute("loginUser");
  String keyword = request.getParameter("keyword");
  TopicDao topicDao = new TopicDao();
  SelectionDao selDao = new SelectionDao();
  List<Topic> topics = topicDao.findOpenTopics(keyword);
  boolean hasApplied = selDao.hasPendingOrApproved(loginUser.getId());
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<form class="mb-3 d-flex gap-2" method="get">
  <input name="keyword" class="form-control form-control-sm" style="max-width:300px" placeholder="搜索课题名称或描述..." value="<%= keyword==null?"":keyword %>">
  <button type="submit" class="btn btn-primary btn-sm">搜索</button>
</form>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128269;</div><p>没有找到匹配的课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= t.getTitle() %></h6>
      <p><%= t.getDescription() %></p>
      <div class="meta">
        指导教师: <%= t.getTeacherName() %><br>
        名额: <%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>
      </div>
      <% if (!hasApplied && t.getSelectedCount() < t.getMaxStudents()) { %>
        <button class="btn btn-primary btn-sm mt-2" onclick="applyTopic(<%= t.getId() %>,'<%= t.getTitle().replace("'","\\'") %>')">申请选题</button>
      <% } else if (hasApplied) { %>
        <span class="text-muted small mt-2 d-block">您已有选题申请</span>
      <% } else { %>
        <span class="badge-status badge-closed mt-2">名额已满</span>
      <% } %>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="applyModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../student/topic.action" method="post">
      <input type="hidden" name="action" value="apply">
      <input type="hidden" name="topicId" id="applyTopicId">
      <div class="modal-header"><h6 class="modal-title" id="applyTitle">申请选题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">申请理由</label>
        <textarea name="applyReason" class="form-control form-control-sm" rows="4" placeholder="请说明您选择该课题的原因和相关基础..." required></textarea>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">提交申请</button></div>
    </form>
  </div></div>
</div>

<script>
function applyTopic(id, title) {
  document.getElementById('applyTopicId').value = id;
  document.getElementById('applyTitle').textContent = '申请选题 - ' + title;
  new bootstrap.Modal(document.getElementById('applyModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
