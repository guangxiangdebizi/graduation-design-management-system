<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "答辩评分");
  User loginUser = (User) session.getAttribute("loginUser");
  List<DefenseTeacherScore> tasks = (List<DefenseTeacherScore>) request.getAttribute("tasks");
  if (tasks == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/defense.action");
    return;
  }
  String msg = request.getParameter("msg");
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if ("score_ok".equals(msg)) { %>
  <div class="alert alert-success py-2">答辩评分已保存。</div>
<% } else if ("invalid_score".equals(msg)) { %>
  <div class="alert alert-warning py-2">分数必须是 0 到 100 之间的数字。</div>
<% } else if ("defense_not_member".equals(msg)) { %>
  <div class="alert alert-warning py-2">您不是该学生的答辩教师，不能评分。</div>
<% } else if ("error".equals(msg)) { %>
  <div class="alert alert-danger py-2">操作失败，请稍后重试。</div>
<% } %>

<div class="content-card">
  <h5>我的答辩评分任务</h5>
  <div class="alert alert-info py-2 mt-3">
    系主任指定三名本专业教师参与答辩评分。每位教师独立录入分数，系统自动计算三名教师平均分作为学生答辩成绩；三人均分 60 分及以上视为通过，并按 40% 计入最终成绩。
  </div>
  <table class="table-modern">
    <tr><th>学号</th><th>学生</th><th>课题</th><th>指导教师</th><th>我的评分</th><th>评分进度</th><th>当前均分</th><th>答辩结果</th><th>操作</th></tr>
    <% if (tasks.isEmpty()) { %>
      <tr><td colspan="9" class="text-center text-muted py-4">暂无需要您评分的答辩任务</td></tr>
    <% } else { for (DefenseTeacherScore t : tasks) { %>
      <tr>
        <td><%= t.getStudentNo()==null?"—":EscapeUtil.html(t.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(t.getStudentName()) %></td>
        <td><%= t.getTopicTitle()==null?"—":EscapeUtil.html(t.getTopicTitle()) %></td>
        <td><%= t.getSupervisorName()==null?"—":EscapeUtil.html(t.getSupervisorName()) %></td>
        <td>
          <% if (t.getMyScore() == null) { %>
            <span class="text-muted">未评分</span>
          <% } else { %>
            <%= t.getMyScore() %> 分
            <% if (t.getScoreTime()!=null) { %><div class="text-muted small"><%= sdf.format(t.getScoreTime()) %></div><% } %>
          <% } %>
        </td>
        <td><%= t.getScoreCount() %>/3</td>
        <td><%= t.getAverageScore()==null?"—":t.getAverageScore() + " 分" %></td>
        <td><%= defenseResultBadge(t.getScoreCount(), t.getAverageScore()) %></td>
        <td>
          <button class="btn btn-sm btn-primary"
            data-comment="<%= t.getMyComment()==null?"":EscapeUtil.attr(t.getMyComment()) %>"
            onclick="openScore(<%= t.getScheduleId() %>,'<%= EscapeUtil.js(t.getStudentName()) %>','<%= t.getMyScore()==null?"":t.getMyScore() %>',this.getAttribute('data-comment'))">
            <%= t.getMyScore()==null ? "评分" : "修改评分" %>
          </button>
        </td>
      </tr>
    <% }} %>
  </table>
</div>

<div class="modal fade" id="scoreModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="defense.action" method="post">
      <input type="hidden" name="scheduleId" id="scheduleId">
      <div class="modal-header">
        <h6 class="modal-title" id="scoreTitle">答辩评分</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-2">
          <label class="form-label">答辩分数</label>
          <input name="score" id="scoreInput" type="number" min="0" max="100" step="0.01" class="form-control form-control-sm" required>
        </div>
        <div class="mb-2">
          <label class="form-label">评分意见</label>
          <textarea name="comment" id="commentInput" class="form-control form-control-sm" rows="3" placeholder="请输入答辩评价或修改建议"></textarea>
        </div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存评分</button></div>
    </form>
  </div></div>
</div>

<script>
function openScore(scheduleId, studentName, score, comment) {
  document.getElementById('scheduleId').value = scheduleId;
  document.getElementById('scoreTitle').textContent = '答辩评分 - ' + studentName;
  document.getElementById('scoreInput').value = score || '';
  document.getElementById('commentInput').value = comment || '';
  new bootstrap.Modal(document.getElementById('scoreModal')).show();
}
</script>

<%!
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
