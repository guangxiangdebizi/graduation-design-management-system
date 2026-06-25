<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "志愿填报");
  User loginUser = (User) session.getAttribute("loginUser");
  Integer roundObj = (Integer) request.getAttribute("round");
  Integer intentLimitObj = (Integer) request.getAttribute("intentLimit");
  Boolean selectionOpenObj = (Boolean) request.getAttribute("selectionOpen");
  TopicAssignment assignment = (TopicAssignment) request.getAttribute("assignment");
  TopicSelection legacySelection = (TopicSelection) request.getAttribute("legacySelection");
  SelectionApplication activeApplication = (SelectionApplication) request.getAttribute("activeApplication");
  List<SelectionChoice> activeChoices = (List<SelectionChoice>) request.getAttribute("activeChoices");
  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  Map<Integer, Integer> intentCounts = (Map<Integer, Integer>) request.getAttribute("intentCounts");
  if (roundObj == null || activeChoices == null || topics == null || intentCounts == null) {
    response.sendRedirect(request.getContextPath() + "/student/choice.action");
    return;
  }
  int round = roundObj.intValue();
  int intentLimit = intentLimitObj == null ? 3 : intentLimitObj.intValue();
  boolean selectionOpen = selectionOpenObj == null || selectionOpenObj.booleanValue();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("choice_ok".equals(msg)) { msgTitle="成功"; msgContent="志愿已提交，请等待专业负责人确认"; msgClass="success"; }
  else if ("has_assignment".equals(msg)) { msgTitle="提示"; msgContent="您已经有最终确认题目，不能重复填报"; msgClass="warning"; }
  else if ("already_submitted".equals(msg)) { msgTitle="提示"; msgContent="您本轮已经提交过志愿，请等待确认"; msgClass="warning"; }
  else if ("choice_count_invalid".equals(msg)) { msgTitle="提示"; msgContent="每轮至少选择 1 个志愿，最多选择 3 个志愿"; msgClass="warning"; }
  else if ("duplicate_choice".equals(msg)) { msgTitle="提示"; msgContent="三个志愿不能选择同一个题目"; msgClass="warning"; }
  else if ("topic_invalid".equals(msg)) { msgTitle="提示"; msgContent="只能选择本专业、未分配、已审核通过的题目"; msgClass="warning"; }
  else if ("intent_full".equals(msg)) { msgTitle="提示"; msgContent="某个题目的本轮意向人数已满，请重新选择"; msgClass="warning"; }
  else if ("selection_closed".equals(msg)) { msgTitle="提示"; msgContent="当前不在本轮选题开放阶段"; msgClass="warning"; }
  else if ("error".equals(msg)) { msgTitle="失败"; msgContent="志愿提交失败，请稍后重试"; msgClass="danger"; }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (!msgTitle.isEmpty()) { %>
<div class="alert alert-<%= msgClass %> alert-dismissible fade show" role="alert">
  <strong><%= msgTitle %>：</strong><%= msgContent %>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="alert alert-info py-2">
  当前为第 <strong><%= round %></strong> 轮志愿填报。每名学生本轮至少填 1 个志愿，最多填 3 个志愿；
  每个题目本轮最多允许 <strong><%= intentLimit %></strong> 名学生填为志愿。
</div>

<% if (assignment != null) { %>
<div class="content-card">
  <h5 class="mb-3">最终确认结果</h5>
  <table class="table-modern">
    <tr><th>题目</th><th>指导教师</th><th>来源</th><th>确认人</th><th>确认时间</th><th>确认意见</th></tr>
    <tr>
      <td><%= EscapeUtil.html(assignment.getTopicTitle()) %></td>
      <td><%= EscapeUtil.html(assignment.getTeacherName()) %></td>
      <td><%= EscapeUtil.html(assignment.getSource()) %></td>
      <td><%= EscapeUtil.html(assignment.getConfirmerName()) %></td>
      <td><%= assignment.getConfirmTime()==null?"—":sdf.format(assignment.getConfirmTime()) %></td>
      <td><%= assignment.getConfirmComment()==null?"—":EscapeUtil.html(assignment.getConfirmComment()) %></td>
    </tr>
  </table>
  <div class="text-muted small mt-2">您已经确定毕业设计题目，不能再参加后续选题。</div>
</div>
<% } else if (legacySelection != null) { %>
<div class="content-card">
  <h5 class="mb-3">已确认选题</h5>
  <table class="table-modern">
    <tr><th>题目</th><th>指导教师</th><th>状态</th><th>确认意见</th></tr>
    <tr>
      <td><%= EscapeUtil.html(legacySelection.getTopicTitle()) %></td>
      <td><%= EscapeUtil.html(legacySelection.getTeacherName()) %></td>
      <td><% request.setAttribute("status", legacySelection.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
      <td><%= legacySelection.getReviewComment()==null?"—":EscapeUtil.html(legacySelection.getReviewComment()) %></td>
    </tr>
  </table>
  <div class="text-muted small mt-2">这是旧选题流程中的已确认结果，系统已阻止重复填报志愿。</div>
</div>
<% } else if (activeApplication != null) { %>
<div class="content-card">
  <h5 class="mb-3">本轮已提交志愿</h5>
  <table class="table-modern">
    <tr><th>志愿顺序</th><th>题目</th><th>指导教师</th><th>当前题目意向人数</th><th>状态</th></tr>
    <% for (SelectionChoice c : activeChoices) { %>
    <tr>
      <td>第 <%= c.getChoiceRank() %> 志愿</td>
      <td><%= EscapeUtil.html(c.getTopicTitle()) %></td>
      <td><%= EscapeUtil.html(c.getTeacherName()) %></td>
      <td><%= c.getCurrentIntentCount() %>/<%= intentLimit %></td>
      <td><%= EscapeUtil.html(c.getStatus()) %></td>
    </tr>
    <% } %>
  </table>
  <div class="text-muted small mt-2">
    提交时间：<%= activeApplication.getSubmitTime()==null?"—":sdf.format(activeApplication.getSubmitTime()) %>。
    当前志愿等待专业负责人确认，本轮不能重复提交。
  </div>
</div>
<% } else { %>
  <% if (!selectionOpen) { %>
  <div class="alert alert-warning py-2">当前选题入口关闭，只能查看题目，不能提交志愿。</div>
  <% } %>

  <div class="content-card mb-3">
    <h5 class="mb-3">提交本轮志愿</h5>
    <% if (topics.isEmpty()) { %>
      <div class="empty-state">
        <div class="icon">&#128269;</div>
        <p>当前没有可填报的本专业未分配题目</p>
      </div>
    <% } else { %>
    <form action="choice.action" method="post" onsubmit="return validateChoices()">
      <input type="hidden" name="action" value="submit">
      <div class="row g-3">
        <div class="col-md-4">
          <label class="form-label">第一志愿 *</label>
          <select name="topic1" id="topic1" class="form-select form-select-sm choice-select" required <%= selectionOpen ? "" : "disabled" %>>
            <option value="">请选择题目</option>
            <% for (Topic t : topics) {
                Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
                int count = cntObj == null ? 0 : cntObj.intValue();
                boolean full = count >= intentLimit;
            %>
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>，<%= EscapeUtil.html(t.getTeacherName()) %>）<%= full ? " - 意向已满" : "" %></option>
            <% } %>
          </select>
        </div>
        <div class="col-md-4">
          <label class="form-label">第二志愿</label>
          <select name="topic2" id="topic2" class="form-select form-select-sm choice-select" <%= selectionOpen ? "" : "disabled" %>>
            <option value="">不填</option>
            <% for (Topic t : topics) {
                Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
                int count = cntObj == null ? 0 : cntObj.intValue();
                boolean full = count >= intentLimit;
            %>
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>，<%= EscapeUtil.html(t.getTeacherName()) %>）<%= full ? " - 意向已满" : "" %></option>
            <% } %>
          </select>
        </div>
        <div class="col-md-4">
          <label class="form-label">第三志愿</label>
          <select name="topic3" id="topic3" class="form-select form-select-sm choice-select" <%= selectionOpen ? "" : "disabled" %>>
            <option value="">不填</option>
            <% for (Topic t : topics) {
                Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
                int count = cntObj == null ? 0 : cntObj.intValue();
                boolean full = count >= intentLimit;
            %>
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>，<%= EscapeUtil.html(t.getTeacherName()) %>）<%= full ? " - 意向已满" : "" %></option>
            <% } %>
          </select>
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary btn-sm" <%= selectionOpen ? "" : "disabled" %>>提交志愿</button>
        <a href="topic.action" class="btn btn-outline-secondary btn-sm">返回浏览题目</a>
      </div>
    </form>
    <% } %>
  </div>

  <div class="content-card">
    <h5 class="mb-3">可填报题目</h5>
    <% if (topics.isEmpty()) { %>
      <div class="text-muted">暂无可选题目。</div>
    <% } else { %>
    <table class="table-modern">
      <tr><th>题目</th><th>指导教师</th><th>专业</th><th>本轮意向人数</th><th>说明</th></tr>
      <% for (Topic t : topics) {
          Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
          int count = cntObj == null ? 0 : cntObj.intValue();
      %>
      <tr>
        <td><%= EscapeUtil.html(t.getTitle()) %></td>
        <td><%= EscapeUtil.html(t.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(t.getMajorName()) %></td>
        <td><%= count %>/<%= intentLimit %></td>
        <td><%= EscapeUtil.html(t.getDescription()) %></td>
      </tr>
      <% } %>
    </table>
    <% } %>
  </div>
<% } %>

<script>
function validateChoices() {
  var values = [];
  ['topic1', 'topic2', 'topic3'].forEach(function(id) {
    var val = document.getElementById(id).value;
    if (val) values.push(val);
  });
  if (values.length < 1) {
    alert('至少需要选择一个志愿');
    return false;
  }
  var seen = {};
  for (var i = 0; i < values.length; i++) {
    if (seen[values[i]]) {
      alert('三个志愿不能选择同一个题目');
      return false;
    }
    seen[values[i]] = true;
  }
  return true;
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>

