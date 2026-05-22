<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "选题审批");
  User loginUser = (User) session.getAttribute("loginUser");
  String statusFilter = request.getParameter("status");
  if (statusFilter == null) statusFilter = "pending";
  SelectionDao dao = new SelectionDao();
  List<TopicSelection> list = dao.findByTeacher(loginUser.getId(), "all".equals(statusFilter) ? null : statusFilter);
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="mb-3">
  <a href="?status=pending" class="btn btn-sm <%= "pending".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">待审批</a>
  <a href="?status=approved" class="btn btn-sm <%= "approved".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">已通过</a>
  <a href="?status=rejected" class="btn btn-sm <%= "rejected".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">已驳回</a>
  <a href="?status=all" class="btn btn-sm <%= "all".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">全部</a>
</div>

<div class="content-card">
  <% if (list.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128203;</div><p>暂无选题申请</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>学生</th><th>学号</th><th>课题</th><th>申请理由</th><th>申请时间</th><th>状态</th><th>操作</th></tr>
      <% for (TopicSelection s : list) { %>
      <tr>
        <td><%= s.getStudentName() %></td>
        <td><%= s.getStudentNo() %></td>
        <td><%= s.getTopicTitle() %></td>
        <td><%= s.getApplyReason() %></td>
        <td><%= sdf.format(s.getApplyTime()) %></td>
        <td><span class="badge-status badge-<%= s.getStatus() %>"><%= s.getStatus() %></span></td>
        <td>
          <% if ("pending".equals(s.getStatus())) { %>
            <button class="btn btn-sm btn-success" onclick="reviewSel(<%= s.getId() %>,'approve','<%= s.getStudentName() %>')">批准</button>
            <button class="btn btn-sm btn-danger" onclick="reviewSel(<%= s.getId() %>,'reject','<%= s.getStudentName() %>')">驳回</button>
          <% } else { %>
            <%= s.getReviewComment()==null?"—":s.getReviewComment() %>
          <% } %>
        </td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<div class="modal fade" id="reviewModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form id="reviewForm" action="../teacher/selection.action" method="post">
      <input type="hidden" name="action" id="reviewAction">
      <input type="hidden" name="id" id="reviewId">
      <div class="modal-header"><h6 class="modal-title" id="reviewTitle">审批选题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">审批意见</label>
        <textarea name="reviewComment" class="form-control form-control-sm" rows="3" placeholder="请输入审批意见"></textarea>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">确认</button></div>
    </form>
  </div></div>
</div>

<script>
function reviewSel(id, action, name) {
  document.getElementById('reviewId').value = id;
  document.getElementById('reviewAction').value = action;
  document.getElementById('reviewTitle').textContent = (action === 'approve' ? '批准' : '驳回') + ' - ' + name;
  new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
