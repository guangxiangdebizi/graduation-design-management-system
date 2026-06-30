<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "志愿审批");
  User loginUser = (User) session.getAttribute("loginUser");
  List<TopicChoiceGroup> choiceGroups = (List<TopicChoiceGroup>) request.getAttribute("choiceGroups");
  Integer currentRoundAttr = (Integer) request.getAttribute("currentRound");
  Boolean round1OpenAttr = (Boolean) request.getAttribute("round1Open");
  Boolean round2OpenAttr = (Boolean) request.getAttribute("round2Open");
  Boolean manualAssignOpenAttr = (Boolean) request.getAttribute("manualAssignOpen");
  if (choiceGroups == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/choice-review.action");
    return;
  }
  int currentRound = currentRoundAttr == null ? 1 : currentRoundAttr.intValue();
  boolean round1Open = round1OpenAttr != null && round1OpenAttr.booleanValue();
  boolean round2Open = round2OpenAttr != null && round2OpenAttr.booleanValue();
  boolean manualAssignOpen = manualAssignOpenAttr != null && manualAssignOpenAttr.booleanValue();
  boolean reviewOpen = !manualAssignOpen && (currentRound == 2 ? round2Open : round1Open);
  String msg = request.getParameter("msg");
  String msgTitle = "";
  String msgContent = "";
  String msgClass = "info";
  if ("accept_ok".equals(msg)) { msgTitle="成功"; msgContent="已接收该学生志愿，并生成最终选题分配"; msgClass="success"; }
  else if ("reject_ok".equals(msg)) { msgTitle="成功"; msgContent="已将该志愿标记为未接收"; msgClass="success"; }
  else if ("forbidden".equals(msg)) { msgTitle="错误"; msgContent="该志愿不属于您的课题，不能审批"; msgClass="danger"; }
  else if ("student_has_topic".equals(msg)) { msgTitle="提示"; msgContent="该学生已经匹配其他课题"; msgClass="warning"; }
  else if ("topic_assigned".equals(msg)) { msgTitle="提示"; msgContent="该课题已经匹配其他学生"; msgClass="warning"; }
  else if ("choice_invalid".equals(msg)) { msgTitle="提示"; msgContent="该志愿当前状态不可审批"; msgClass="warning"; }
  else if ("review_closed".equals(msg)) { msgTitle="提示"; msgContent="当前轮次未开放教师志愿审批"; msgClass="warning"; }
  else if ("error".equals(msg)) { msgTitle="错误"; msgContent="操作失败，请稍后重试"; msgClass="danger"; }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (!msgContent.isEmpty()) { %>
  <div class="alert alert-<%= msgClass %> py-2">
    <strong><%= msgTitle %>：</strong><%= msgContent %>
  </div>
<% } %>

<div class="alert alert-info py-2">
  第一轮、第二轮志愿由对应课题指导教师审批；您只能审批自己课题收到的学生志愿。接收后系统会直接生成最终选题分配。
</div>

<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h5 class="mb-1">第 <%= currentRound %> 轮志愿审批</h5>
      <div class="text-muted small">
        当前轮次审批状态：
        <% if (reviewOpen) { %>
          <span class="badge bg-success">可审批</span>
        <% } else { %>
          <span class="badge bg-secondary">未开放</span>
        <% } %>
      </div>
    </div>
    <div>
      <a href="choice-review.action?round=1" class="btn btn-sm <%= currentRound==1?"btn-primary":"btn-outline-primary" %>">第一轮</a>
      <a href="choice-review.action?round=2" class="btn btn-sm <%= currentRound==2?"btn-primary":"btn-outline-primary" %>">第二轮</a>
    </div>
  </div>

  <% if (choiceGroups.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128221;</div><p>第<%= currentRound %>轮暂无需要您审批的志愿</p></div>
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
        <tr><th>志愿</th><th>学生</th><th>学号</th><th>提交时间</th><th>当前题目意向数</th><th>审批操作</th></tr>
        <% for (SelectionChoice c : group.getChoices()) { %>
          <tr>
            <td>
              <span class="badge <%= c.getChoiceRank()==1?"bg-primary":(c.getChoiceRank()==2?"bg-info":"bg-secondary") %>">
                第<%= c.getChoiceRank() %>志愿
              </span>
            </td>
            <td><%= EscapeUtil.html(c.getStudentName()) %></td>
            <td><%= EscapeUtil.html(c.getStudentNo()) %></td>
            <td><%= c.getCreatedAt()==null?"—":sdf.format(c.getCreatedAt()) %></td>
            <td><%= c.getCurrentIntentCount() %></td>
            <td>
              <form action="choice-review.action" method="post" class="d-inline"
                    onsubmit="return confirm('确认接收 <%= EscapeUtil.js(c.getStudentName()) %> 选择《<%= EscapeUtil.js(group.getTopicTitle()) %>》？');">
                <input type="hidden" name="action" value="acceptChoice">
                <input type="hidden" name="choiceId" value="<%= c.getId() %>">
                <input type="hidden" name="round" value="<%= currentRound %>">
                <button type="submit" class="btn btn-success btn-sm" <%= reviewOpen ? "" : "disabled" %>>接收</button>
              </form>
              <button type="button" class="btn btn-outline-danger btn-sm" <%= reviewOpen ? "" : "disabled" %>
                      onclick="rejectChoice(<%= c.getId() %>, <%= currentRound %>, '<%= EscapeUtil.js(c.getStudentName()) %>')">不接收</button>
            </td>
          </tr>
        <% } %>
      </table>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="rejectModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="choice-review.action" method="post">
      <input type="hidden" name="action" value="rejectChoice">
      <input type="hidden" name="choiceId" id="rejectChoiceId">
      <input type="hidden" name="round" id="rejectRound">
      <div class="modal-header">
        <h6 class="modal-title" id="rejectTitle">不接收志愿</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <label class="form-label">说明，可空</label>
        <textarea name="reviewComment" class="form-control form-control-sm" rows="3" placeholder="例如：名额有限，建议选择其他课题"></textarea>
      </div>
      <div class="modal-footer">
        <button type="submit" class="btn btn-outline-danger btn-sm">确认不接收</button>
      </div>
    </form>
  </div></div>
</div>

<script>
function rejectChoice(choiceId, round, studentName) {
  document.getElementById('rejectChoiceId').value = choiceId;
  document.getElementById('rejectRound').value = round;
  document.getElementById('rejectTitle').textContent = '不接收志愿 - ' + studentName;
  new bootstrap.Modal(document.getElementById('rejectModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>

