<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "本专业课题审核");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  String keyword = (String) request.getAttribute("keyword");
  String statusFilter = (String) request.getAttribute("statusFilter");
  Map<String,String> topicStatusOptions = (Map<String,String>) request.getAttribute("topicStatusOptions");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  if (topics == null) {
    response.sendRedirect(request.getContextPath() + "/director/topic-review.action");
    return;
  }
  if (keyword == null) keyword = "";
  if (statusFilter == null) statusFilter = "";
  if (topicStatusOptions == null) topicStatusOptions = new LinkedHashMap<String,String>();
  if (directorScopeText == null) directorScopeText = "";
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前系主任权限范围：<%= EscapeUtil.html(directorScopeText) %>。只能查看和审核本专业课题。
</div>

<form class="content-card mb-3" method="get" action="topic-review.action">
  <div class="row g-2 align-items-end">
    <div class="col-md-4"><label class="form-label">关键词</label><input name="keyword" class="form-control form-control-sm" value="<%= EscapeUtil.attr(keyword) %>"></div>
    <div class="col-md-4"><label class="form-label">状态</label><select name="status" class="form-select form-select-sm">
      <option value="">全部状态</option>
      <% for (Map.Entry<String,String> e : topicStatusOptions.entrySet()) { %>
      <option value="<%= e.getKey() %>" <%= e.getKey().equals(statusFilter)?"selected":"" %>><%= EscapeUtil.html(e.getValue()) %></option>
      <% } %>
    </select></div>
    <div class="col-md-auto"><button class="btn btn-primary btn-sm">查询</button> <a href="topic-review.action" class="btn btn-outline-secondary btn-sm">重置</a></div>
  </div>
</form>

<div class="content-card">
  <table class="table-modern">
    <tr><th>课题</th><th>教师</th><th>学院/专业</th><th>名额</th><th>状态</th><th>审核信息</th><th>操作</th></tr>
    <% if (topics.isEmpty()) { %>
      <tr><td colspan="7" class="text-center text-muted py-4">暂无本专业课题</td></tr>
    <% } else { for (Topic t : topics) { %>
      <tr>
        <td><strong><%= EscapeUtil.html(t.getTitle()) %></strong><br><span class="text-muted small"><%= EscapeUtil.html(t.getDescription()) %></span></td>
        <td><%= EscapeUtil.html(t.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(t.getCollegeName()) %><br><span class="text-muted small"><%= EscapeUtil.html(t.getMajorName()) %></span></td>
        <td><%= t.getSelectedCount() %>/<%= t.getMaxStudents() %></td>
        <td><span class="badge-status badge-<%= t.getStatus() %>"><%= StatusUtil.label(t.getStatus()) %></span></td>
        <td>
          <% if (t.getReviewTime() != null) { %>
            <%= sdf.format(t.getReviewTime()) %> / <%= EscapeUtil.html(t.getReviewerName()) %><br>
            <span class="small text-muted"><%= t.getReviewComment()==null?"":EscapeUtil.html(t.getReviewComment()) %></span>
          <% } else { %>—<% } %>
        </td>
        <td>
          <button class="btn btn-sm btn-success" onclick="reviewTopic(<%= t.getId() %>,'approve','<%= EscapeUtil.js(t.getTitle()) %>')">通过</button>
          <button class="btn btn-sm btn-outline-danger" onclick="reviewTopic(<%= t.getId() %>,'reject','<%= EscapeUtil.js(t.getTitle()) %>')">驳回</button>
        </td>
      </tr>
    <% }} %>
  </table>
</div>

<div class="modal fade" id="reviewModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic-review.action" method="post">
      <input type="hidden" name="action" id="reviewAction">
      <input type="hidden" name="id" id="reviewId">
      <div class="modal-header"><h6 class="modal-title" id="reviewTitle">课题审核</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">审核意见</label>
        <textarea name="reviewComment" class="form-control form-control-sm" rows="4"></textarea>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">提交审核</button></div>
    </form>
  </div></div>
</div>

<script>
function reviewTopic(id, action, title) {
  document.getElementById('reviewId').value = id;
  document.getElementById('reviewAction').value = action;
  document.getElementById('reviewTitle').textContent = (action === 'approve' ? '通过' : '驳回') + ' - ' + title;
  new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
