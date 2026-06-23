<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "本专业选题确认");
  User loginUser = (User) session.getAttribute("loginUser");
  List<TopicSelection> selections = (List<TopicSelection>) request.getAttribute("selections");
  List<User> unselectedStudents = (List<User>) request.getAttribute("unselectedStudents");
  List<Topic> availableTopics = (List<Topic>) request.getAttribute("availableTopics");
  String statusFilter = (String) request.getAttribute("statusFilter");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  if (selections == null || unselectedStudents == null || availableTopics == null) {
    response.sendRedirect(request.getContextPath() + "/director/selection-confirm.action");
    return;
  }
  if (statusFilter == null) statusFilter = "pending";
  if (directorScopeText == null) directorScopeText = "";
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前系主任权限范围：<%= EscapeUtil.html(directorScopeText) %>。这里负责确认学生与题目的一一对应关系；教师端只提供指导教师意见。
</div>

<div class="mb-3">
  <a href="selection-confirm.action?status=pending" class="btn btn-sm <%= "pending".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">待确认</a>
  <a href="selection-confirm.action?status=approved" class="btn btn-sm <%= "approved".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">已确认</a>
  <a href="selection-confirm.action?status=rejected" class="btn btn-sm <%= "rejected".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">未确认</a>
  <a href="selection-confirm.action?status=all" class="btn btn-sm <%= "all".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">全部</a>
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">学生选题申请</h5>
    <span class="text-muted small">选题系统关闭后，系主任可在这里确认本轮匹配结果。</span>
  </div>
  <table class="table-modern">
    <tr><th>学生</th><th>学号</th><th>申请题目</th><th>指导教师</th><th>申请理由</th><th>状态/意见</th><th>操作</th></tr>
    <% if (selections.isEmpty()) { %>
      <tr><td colspan="7" class="text-center text-muted py-4">暂无本专业选题申请</td></tr>
    <% } else { for (TopicSelection s : selections) { %>
      <tr>
        <td><%= EscapeUtil.html(s.getStudentName()) %></td>
        <td><%= EscapeUtil.html(s.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(s.getTopicTitle()) %><br><span class="text-muted small"><%= s.getApplyTime()==null?"":sdf.format(s.getApplyTime()) %></span></td>
        <td><%= EscapeUtil.html(s.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(s.getApplyReason()) %></td>
        <td>
          <% request.setAttribute("status", s.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %>
          <% if (s.getReviewComment() != null && s.getReviewComment().trim().length() > 0) { %>
            <div class="small text-muted mt-1"><%= EscapeUtil.html(s.getReviewComment()).replace("\n","<br>") %></div>
          <% } %>
        </td>
        <td>
          <% if ("pending".equals(s.getStatus())) { %>
            <button class="btn btn-sm btn-success" onclick="reviewSelection(<%= s.getId() %>,'confirm','<%= EscapeUtil.js(s.getStudentName()) %>')">确认对应</button>
            <button class="btn btn-sm btn-outline-danger" onclick="reviewSelection(<%= s.getId() %>,'reject','<%= EscapeUtil.js(s.getStudentName()) %>')">不确认</button>
          <% } else { %>
            —
          <% } %>
        </td>
      </tr>
    <% }} %>
  </table>
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">未选题学生手动分配</h5>
    <span class="text-muted small">用于第二轮后仍未选题的学生，分配到未满额题目。</span>
  </div>
  <% if (unselectedStudents.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#9989;</div><p>本专业暂无未选题学生</p></div>
  <% } else if (availableTopics.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128221;</div><p>暂无可分配题目</p></div>
  <% } else { %>
    <form action="selection-confirm.action" method="post" class="row g-2 align-items-end">
      <input type="hidden" name="action" value="assign">
      <div class="col-md-3">
        <label class="form-label">未选题学生</label>
        <select name="studentId" class="form-select form-select-sm" required>
          <option value="">请选择学生</option>
          <% for (User u : unselectedStudents) { %>
            <option value="<%= u.getId() %>"><%= EscapeUtil.html(u.getRealName()) %>（<%= EscapeUtil.html(u.getStudentNo()) %>）</option>
          <% } %>
        </select>
      </div>
      <div class="col-md-4">
        <label class="form-label">可分配题目</label>
        <select name="topicId" class="form-select form-select-sm" required>
          <option value="">请选择题目</option>
          <% for (Topic t : availableTopics) { %>
            <option value="<%= t.getId() %>"><%= EscapeUtil.html(t.getTitle()) %>（<%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>，<%= EscapeUtil.html(t.getTeacherName()) %>）</option>
          <% } %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label">分配说明</label>
        <input name="reviewComment" class="form-control form-control-sm" placeholder="如：第二轮后手动分配">
      </div>
      <div class="col-md-auto">
        <button type="submit" class="btn btn-primary btn-sm">确认分配</button>
      </div>
    </form>
  <% } %>
</div>

<div class="modal fade" id="reviewModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="selection-confirm.action" method="post">
      <input type="hidden" name="action" id="reviewAction">
      <input type="hidden" name="id" id="reviewId">
      <div class="modal-header"><h6 class="modal-title" id="reviewTitle">选题确认</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">确认意见</label>
        <textarea name="reviewComment" class="form-control form-control-sm" rows="3" placeholder="请输入系主任确认意见"></textarea>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">提交</button></div>
    </form>
  </div></div>
</div>

<script>
function reviewSelection(id, action, name) {
  document.getElementById('reviewId').value = id;
  document.getElementById('reviewAction').value = action;
  document.getElementById('reviewTitle').textContent = (action === 'confirm' ? '确认对应 - ' : '不确认 - ') + name;
  new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
