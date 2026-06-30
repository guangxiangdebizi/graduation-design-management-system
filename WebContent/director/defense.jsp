<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.math.BigDecimal,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "本专业答辩教师安排");
  User loginUser = (User) session.getAttribute("loginUser");
  List<DefenseSchedule> schedules = (List<DefenseSchedule>) request.getAttribute("schedules");
  List<User> teachers = (List<User>) request.getAttribute("committeeTeachers");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  if (schedules == null || teachers == null) {
    response.sendRedirect(request.getContextPath() + "/director/defense.action");
    return;
  }
  if (directorScopeText == null) directorScopeText = "";
  String msg = request.getParameter("msg");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前范围：<%= EscapeUtil.html(directorScopeText) %>。终稿/结题材料通过后，由系主任为学生指定三名本专业答辩教师；三人评分完成后，答辩均分 60 分及以上视为通过；时间、地点、分组不在本模块维护。
</div>

<% if ("arrange_ok".equals(msg)) { %>
  <div class="alert alert-success py-2">答辩教师已保存。</div>
<% } else if ("defense_student_invalid".equals(msg)) { %>
  <div class="alert alert-warning py-2">该学生不在当前专业范围，或终稿/结题材料尚未通过。</div>
<% } else if ("defense_teacher_count".equals(msg)) { %>
  <div class="alert alert-warning py-2">必须选择三名答辩教师。</div>
<% } else if ("defense_teacher_duplicate".equals(msg)) { %>
  <div class="alert alert-warning py-2">三名答辩教师不能重复。</div>
<% } else if ("defense_teacher_scope".equals(msg)) { %>
  <div class="alert alert-warning py-2">只能选择当前专业的有效教师。</div>
<% } else if ("error".equals(msg)) { %>
  <div class="alert alert-danger py-2">操作失败，请稍后重试。</div>
<% } %>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">终稿通过学生答辩安排</h5>
    <span class="text-muted small">可选答辩教师：<%= teachers.size() %> 人</span>
  </div>
  <% if (teachers.size() < 3) { %>
    <div class="alert alert-warning py-2">当前专业可选教师不足 3 人，请先维护教师账号后再安排答辩。</div>
  <% } %>
  <table class="table-modern">
    <tr><th>学号</th><th>学生</th><th>课题</th><th>指导教师</th><th>答辩教师</th><th>评分进度</th><th>答辩均分</th><th>答辩结果</th><th>操作</th></tr>
    <% if (schedules.isEmpty()) { %>
      <tr><td colspan="9" class="text-center text-muted py-4">暂无终稿/结题材料已通过的学生</td></tr>
    <% } else { for (DefenseSchedule d : schedules) { %>
      <tr>
        <td><%= d.getStudentNo()==null?"—":EscapeUtil.html(d.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(d.getStudentName()) %></td>
        <td><%= d.getTopicTitle()==null?"—":EscapeUtil.html(d.getTopicTitle()) %></td>
        <td><%= d.getTeacherName()==null?"—":EscapeUtil.html(d.getTeacherName()) %></td>
        <td>
          <% if (d.getCommitteeMembers().isEmpty()) { %>
            <span class="text-muted">未安排</span>
          <% } else { for (User t : d.getCommitteeMembers()) { %>
            <span class="badge bg-secondary me-1"><%= EscapeUtil.html(t.getRealName()) %></span>
          <% }} %>
        </td>
        <td><%= d.getScoreCount() %>/3</td>
        <td><%= d.getAverageScore()==null?"—":d.getAverageScore() + " 分" %></td>
        <td><%= defenseResultBadge(d.getScoreCount(), d.getAverageScore()) %></td>
        <td>
          <button class="btn btn-sm btn-primary" <%= teachers.size() < 3 ? "disabled" : "" %>
            onclick="openArrange(<%= d.getStudentId() %>,'<%= EscapeUtil.js(d.getStudentName()) %>',<%= memberId(d,0) %>,<%= memberId(d,1) %>,<%= memberId(d,2) %>)">
            <%= d.getCommitteeMembers().isEmpty() ? "安排教师" : "调整教师" %>
          </button>
        </td>
      </tr>
    <% }} %>
  </table>
</div>

<div class="modal fade" id="arrangeModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="defense.action" method="post">
      <input type="hidden" name="studentId" id="studentId">
      <div class="modal-header">
        <h6 class="modal-title" id="arrangeTitle">安排答辩教师</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-2">
          <label class="form-label">答辩教师 1</label>
          <select name="teacherId1" id="teacherId1" class="form-select form-select-sm" required>
            <option value="">请选择</option>
            <% for (User t : teachers) { %>
              <option value="<%= t.getId() %>"><%= EscapeUtil.html(t.getRealName()) %>（<%= EscapeUtil.html(t.getDisplayTitle()) %>）</option>
            <% } %>
          </select>
        </div>
        <div class="mb-2">
          <label class="form-label">答辩教师 2</label>
          <select name="teacherId2" id="teacherId2" class="form-select form-select-sm" required>
            <option value="">请选择</option>
            <% for (User t : teachers) { %>
              <option value="<%= t.getId() %>"><%= EscapeUtil.html(t.getRealName()) %>（<%= EscapeUtil.html(t.getDisplayTitle()) %>）</option>
            <% } %>
          </select>
        </div>
        <div class="mb-2">
          <label class="form-label">答辩教师 3</label>
          <select name="teacherId3" id="teacherId3" class="form-select form-select-sm" required>
            <option value="">请选择</option>
            <% for (User t : teachers) { %>
              <option value="<%= t.getId() %>"><%= EscapeUtil.html(t.getRealName()) %>（<%= EscapeUtil.html(t.getDisplayTitle()) %>）</option>
            <% } %>
          </select>
        </div>
        <div class="text-muted small">保存后，三名教师将在教师端“答辩评分”页面看到该学生。</div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function openArrange(studentId, studentName, t1, t2, t3) {
  document.getElementById('studentId').value = studentId;
  document.getElementById('arrangeTitle').textContent = '安排答辩教师 - ' + studentName;
  document.getElementById('teacherId1').value = t1 > 0 ? String(t1) : '';
  document.getElementById('teacherId2').value = t2 > 0 ? String(t2) : '';
  document.getElementById('teacherId3').value = t3 > 0 ? String(t3) : '';
  new bootstrap.Modal(document.getElementById('arrangeModal')).show();
}
</script>

<%!
  private int memberId(DefenseSchedule d, int index) {
    if (d == null || d.getCommitteeMembers() == null || d.getCommitteeMembers().size() <= index) {
      return 0;
    }
    return d.getCommitteeMembers().get(index).getId();
  }

  private String defenseResultBadge(int scoreCount, BigDecimal averageScore) {
    if (scoreCount < 3 || averageScore == null) {
      return "<span class=\"text-muted\">未出结果</span>";
    }
    if (averageScore.compareTo(new BigDecimal("60")) >= 0) {
      return "<span class=\"badge-status badge-reviewed\">通过</span>";
    }
    return "<span class=\"badge-status badge-rejected\">未通过</span>";
  }
%>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
