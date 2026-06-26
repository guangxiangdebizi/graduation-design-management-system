<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "本专业选题确认");
  User loginUser = (User) session.getAttribute("loginUser");
  List<TopicChoiceGroup> choiceGroups = (List<TopicChoiceGroup>) request.getAttribute("choiceGroups");
  List<TopicAssignment> assignments = (List<TopicAssignment>) request.getAttribute("assignments");
  List<TopicSelection> selections = (List<TopicSelection>) request.getAttribute("selections");
  List<User> unselectedStudents = (List<User>) request.getAttribute("unselectedStudents");
  List<Topic> availableTopics = (List<Topic>) request.getAttribute("availableTopics");
  String statusFilter = (String) request.getAttribute("statusFilter");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  Boolean manualAssignOpenAttr = (Boolean) request.getAttribute("manualAssignOpen");
  Integer currentRoundAttr = (Integer) request.getAttribute("currentRound");
  int currentRound = currentRoundAttr == null ? 1 : currentRoundAttr.intValue();
  if (choiceGroups == null || assignments == null || selections == null
      || unselectedStudents == null || availableTopics == null) {
    response.sendRedirect(request.getContextPath() + "/director/selection-confirm.action");
    return;
  }
  if (statusFilter == null) statusFilter = "pending";
  if (directorScopeText == null) directorScopeText = "";
  boolean manualAssignOpen = manualAssignOpenAttr != null && manualAssignOpenAttr.booleanValue();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前专业负责人权限范围：<%= EscapeUtil.html(directorScopeText) %>。
  本页按“一个题目最终只能确认给一个学生、一个学生最终只能确认一个题目”的规则生成最终分配。
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h5 class="mb-1">学生三志愿确认</h5>
      <div class="text-muted small">按题目聚合显示本轮候选人，优先查看第一志愿；确认后写入最终分配表。</div>
    </div>
    <div>
      <a href="selection-confirm.action?round=1&status=<%= EscapeUtil.attr(statusFilter) %>" class="btn btn-sm <%= currentRound==1?"btn-primary":"btn-outline-primary" %>">第一轮</a>
      <a href="selection-confirm.action?round=2&status=<%= EscapeUtil.attr(statusFilter) %>" class="btn btn-sm <%= currentRound==2?"btn-primary":"btn-outline-primary" %>">第二轮</a>
    </div>
  </div>

  <% if (choiceGroups.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128221;</div><p>第<%= currentRound %>轮暂无待确认志愿候选</p></div>
  <% } else { for (TopicChoiceGroup group : choiceGroups) { %>
    <div class="border rounded p-3 mb-3">
      <div class="d-flex justify-content-between align-items-start mb-2">
        <div>
          <strong><%= EscapeUtil.html(group.getTopicTitle()) %></strong>
          <span class="text-muted small ms-2">指导教师：<%= EscapeUtil.html(group.getTeacherName()) %></span>
        </div>
        <span class="badge bg-secondary">候选 <%= group.getCandidateCount() %> 人</span>
      </div>
      <table class="table-modern">
        <tr><th>志愿</th><th>学生</th><th>学号</th><th>提交时间</th><th>当前题目意向数</th><th>确认操作</th></tr>
        <% for (SelectionChoice c : group.getChoices()) { %>
          <tr>
            <td><span class="badge <%= c.getChoiceRank()==1?"bg-primary":(c.getChoiceRank()==2?"bg-info":"bg-secondary") %>">第<%= c.getChoiceRank() %>志愿</span></td>
            <td><%= EscapeUtil.html(c.getStudentName()) %></td>
            <td><%= EscapeUtil.html(c.getStudentNo()) %></td>
            <td><%= c.getCreatedAt()==null?"—":sdf.format(c.getCreatedAt()) %></td>
            <td><%= c.getCurrentIntentCount() %></td>
            <td>
              <form action="selection-confirm.action" method="post" class="d-flex gap-2 align-items-center"
                    onsubmit="return confirm('确认将《<%= EscapeUtil.js(group.getTopicTitle()) %>》分配给 <%= EscapeUtil.js(c.getStudentName()) %>？');">
                <input type="hidden" name="action" value="confirmChoice">
                <input type="hidden" name="choiceId" value="<%= c.getId() %>">
                <input name="reviewComment" class="form-control form-control-sm" placeholder="确认说明，可空" style="min-width:180px;">
                <button type="submit" class="btn btn-success btn-sm">确认给该学生</button>
              </form>
            </td>
          </tr>
        <% } %>
      </table>
    </div>
  <% }} %>
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">已确认最终分配</h5>
    <span class="text-muted small">来自第一轮、第二轮或强制分配。</span>
  </div>
  <table class="table-modern">
    <tr><th>学生</th><th>学号</th><th>课题</th><th>指导教师</th><th>来源</th><th>确认时间</th><th>说明</th></tr>
    <% if (assignments.isEmpty()) { %>
      <tr><td colspan="7" class="text-center text-muted py-4">暂无最终分配</td></tr>
    <% } else { for (TopicAssignment a : assignments) { %>
      <tr>
        <td><%= EscapeUtil.html(a.getStudentName()) %></td>
        <td><%= EscapeUtil.html(a.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(a.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(a.getTeacherName()) %></td>
        <td>
          <% if ("round1".equals(a.getSource())) { %>第一轮<% }
             else if ("round2".equals(a.getSource())) { %>第二轮<% }
             else { %>强制分配<% } %>
        </td>
        <td><%= a.getConfirmTime()==null?"—":sdf.format(a.getConfirmTime()) %></td>
        <td><%= a.getConfirmComment()==null?"—":EscapeUtil.html(a.getConfirmComment()) %></td>
      </tr>
    <% }} %>
  </table>
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">第二轮后强制分配</h5>
    <span class="text-muted small">管理员只开放流程阶段；剩余学生和剩余题目的具体分配由系主任/专业负责人执行。</span>
  </div>
  <% if (!manualAssignOpen) { %>
    <div class="alert alert-warning py-2 mb-0">
      管理员尚未开启强制分配阶段。请先完成第二轮确认，由管理员关闭第二轮选题并开启“强制分配”后再操作。
    </div>
  <% } else if (unselectedStudents.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#9989;</div><p>本专业暂无未确认题目的学生</p></div>
  <% } else if (availableTopics.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128221;</div><p>暂无可分配题目</p></div>
  <% } else { %>
    <form action="selection-confirm.action" method="post" class="row g-2 align-items-end">
      <input type="hidden" name="action" value="assign">
      <div class="col-md-3">
        <label class="form-label">未确认题目的学生</label>
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
            <option value="<%= t.getId() %>"><%= EscapeUtil.html(t.getTitle()) %>（<%= EscapeUtil.html(t.getTeacherName()) %>）</option>
          <% } %>
        </select>
      </div>
      <div class="col-md-3">
        <label class="form-label">分配说明</label>
        <input name="reviewComment" class="form-control form-control-sm" placeholder="如：第二轮后强制分配">
      </div>
      <div class="col-md-auto">
        <button type="submit" class="btn btn-primary btn-sm">确认分配</button>
      </div>
    </form>
  <% } %>
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">旧版单题申请兼容</h5>
    <span class="text-muted small">保留旧数据和旧入口，主流程建议使用上方三志愿确认。</span>
  </div>
  <div class="mb-3">
    <a href="selection-confirm.action?round=<%= currentRound %>&status=pending" class="btn btn-sm <%= "pending".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">待确认</a>
    <a href="selection-confirm.action?round=<%= currentRound %>&status=approved" class="btn btn-sm <%= "approved".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">已确认</a>
    <a href="selection-confirm.action?round=<%= currentRound %>&status=rejected" class="btn btn-sm <%= "rejected".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">未确认</a>
    <a href="selection-confirm.action?round=<%= currentRound %>&status=all" class="btn btn-sm <%= "all".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">全部</a>
  </div>
  <table class="table-modern">
    <tr><th>学生</th><th>学号</th><th>轮次</th><th>申请题目</th><th>指导教师</th><th>申请理由</th><th>状态/意见</th><th>操作</th></tr>
    <% if (selections.isEmpty()) { %>
      <tr><td colspan="8" class="text-center text-muted py-4">暂无旧版单题申请</td></tr>
    <% } else { for (TopicSelection s : selections) { %>
      <tr>
        <td><%= EscapeUtil.html(s.getStudentName()) %></td>
        <td><%= EscapeUtil.html(s.getStudentNo()) %></td>
        <td><span class="badge bg-secondary">第<%= s.getRound() %>轮</span></td>
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

<div class="modal fade" id="reviewModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="selection-confirm.action" method="post">
      <input type="hidden" name="action" id="reviewAction">
      <input type="hidden" name="id" id="reviewId">
      <div class="modal-header"><h6 class="modal-title" id="reviewTitle">选题确认</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">确认意见</label>
        <textarea name="reviewComment" class="form-control form-control-sm" rows="3" placeholder="请输入专业负责人确认意见"></textarea>
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
