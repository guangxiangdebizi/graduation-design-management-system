<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "本专业论文评阅安排");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Document> documents = (List<Document>) request.getAttribute("documents");
  List<User> reviewerCandidates = (List<User>) request.getAttribute("reviewerCandidates");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  if (documents == null || reviewerCandidates == null) {
    response.sendRedirect(request.getContextPath() + "/director/paper-review.action");
    return;
  }
  if (directorScopeText == null) directorScopeText = "";
  String msg = request.getParameter("msg");
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前范围：<%= EscapeUtil.html(directorScopeText) %>。终稿通过后，由系主任指定一名非指导教师作为论文评阅教师；评阅教师评分占最终成绩 20%。
</div>
<% if ("reviewer_ok".equals(msg)) { %>
  <div class="alert alert-success py-2">评阅教师已保存。</div>
<% } else if ("reviewer_invalid".equals(msg)) { %>
  <div class="alert alert-warning py-2">评阅教师无效，不能选择指导教师本人，且必须是本专业教师或系主任。</div>
<% } %>

<div class="content-card">
  <% if (documents.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>暂无终稿已通过的学生</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr>
        <th>学号</th><th>学生</th><th>课题</th><th>指导教师</th>
        <th>指导教师评分</th><th>评阅教师</th><th>评阅评分</th><th>操作</th>
      </tr>
      <% for (Document d : documents) { %>
      <tr>
        <td><%= EscapeUtil.html(d.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(d.getStudentName()) %></td>
        <td><%= EscapeUtil.html(d.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(d.getTeacherName()) %></td>
        <td><%= d.getAdvisorScore()==null?"—":d.getAdvisorScore() + " 分" %></td>
        <td>
          <% if (d.getPaperReviewerName() == null) { %>
            <span class="text-muted">未安排</span>
          <% } else { %>
            <%= EscapeUtil.html(d.getPaperReviewerName()) %>
          <% } %>
        </td>
        <td>
          <% if (d.getReviewerScore() == null) { %>
            <span class="text-muted">待评阅</span>
          <% } else { %>
            <%= d.getReviewerScore() %> 分
            <% if (d.getReviewerReviewTime()!=null) { %>
              <div class="text-muted small"><%= sdf.format(d.getReviewerReviewTime()) %></div>
            <% } %>
          <% } %>
        </td>
        <td>
          <button class="btn btn-sm btn-outline-primary"
              onclick="openArrange(<%= d.getId() %>, '<%= EscapeUtil.js(d.getStudentName()) %>', <%= d.getTeacherId()==null?0:d.getTeacherId() %>, <%= d.getPaperReviewerId()==null?0:d.getPaperReviewerId() %>)">
            安排评阅教师
          </button>
        </td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<div class="modal fade" id="arrangeModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="paper-review.action" method="post">
      <input type="hidden" name="documentId" id="documentId">
      <div class="modal-header">
        <h6 class="modal-title" id="arrangeTitle">安排评阅教师</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <label class="form-label">评阅教师</label>
        <select name="reviewerId" id="reviewerId" class="form-select form-select-sm" required>
          <option value="">请选择</option>
          <% for (User t : reviewerCandidates) { %>
            <option value="<%= t.getId() %>" data-teacher-id="<%= t.getId() %>">
              <%= EscapeUtil.html(t.getRealName()) %>（<%= EscapeUtil.html(t.getRole()) %>）
            </option>
          <% } %>
        </select>
        <div class="text-muted small mt-2">系统会拒绝选择指导教师本人。</div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary btn-sm" type="submit">保存</button>
      </div>
    </form>
  </div></div>
</div>

<script>
function openArrange(documentId, studentName, supervisorId, currentReviewerId) {
  document.getElementById('documentId').value = documentId;
  document.getElementById('arrangeTitle').textContent = '安排评阅教师 - ' + studentName;
  var select = document.getElementById('reviewerId');
  Array.prototype.forEach.call(select.options, function(opt) {
    var teacherId = parseInt(opt.getAttribute('data-teacher-id') || '0', 10);
    opt.disabled = teacherId > 0 && teacherId === supervisorId;
  });
  select.value = currentReviewerId ? String(currentReviewerId) : '';
  new bootstrap.Modal(document.getElementById('arrangeModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
