<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "浏览课题");
  User loginUser = (User) session.getAttribute("loginUser");

  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  TopicAssignment assignment = (TopicAssignment) request.getAttribute("assignment");
  TopicSelection legacySelection = (TopicSelection) request.getAttribute("legacySelection");
  SelectionApplication activeApplication = (SelectionApplication) request.getAttribute("activeApplication");
  List<SelectionChoice> activeChoices = (List<SelectionChoice>) request.getAttribute("activeChoices");
  Map<Integer, Integer> intentCounts = (Map<Integer, Integer>) request.getAttribute("intentCounts");
  String keyword = (String) request.getAttribute("keyword");
  String collegeFilter = (String) request.getAttribute("collegeFilter");
  String majorFilter = (String) request.getAttribute("majorFilter");
  Boolean hasAppliedAttr = (Boolean) request.getAttribute("hasApplied");
  Boolean selectionOpenAttr = (Boolean) request.getAttribute("selectionOpen");
  Boolean manualAssignOpenAttr = (Boolean) request.getAttribute("manualAssignOpen");
  Integer roundObj = (Integer) request.getAttribute("round");
  Integer intentLimitObj = (Integer) request.getAttribute("intentLimit");
  if (topics == null || hasAppliedAttr == null || activeChoices == null || intentCounts == null) {
    response.sendRedirect(request.getContextPath() + "/student/topic.action");
    return;
  }
  if (keyword == null) keyword = "";
  if (collegeFilter == null) collegeFilter = "";
  if (majorFilter == null) majorFilter = "";
  boolean hasApplied = hasAppliedAttr.booleanValue();
  boolean selectionOpen = selectionOpenAttr == null || selectionOpenAttr.booleanValue();
  boolean manualAssignOpen = manualAssignOpenAttr != null && manualAssignOpenAttr.booleanValue();
  int round = roundObj == null ? 1 : roundObj.intValue();
  int intentLimit = intentLimitObj == null ? 3 : intentLimitObj.intValue();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

  // 消息提示
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("already_applied".equals(msg)) { msgTitle="提示"; msgContent="您已有选题申请，请等待系主任确认"; msgClass="warning"; }
  else if ("choice_ok".equals(msg)) { msgTitle="成功"; msgContent="志愿已提交，请等待专业负责人确认"; msgClass="success"; }
  else if ("has_assignment".equals(msg)) { msgTitle="提示"; msgContent="您已经有最终确认题目，不能重复填报"; msgClass="warning"; }
  else if ("already_submitted".equals(msg)) { msgTitle="提示"; msgContent="您本轮已经提交过志愿，请等待确认"; msgClass="warning"; }
  else if ("choice_count_invalid".equals(msg)) { msgTitle="提示"; msgContent="每轮至少选择 1 个志愿，最多选择 3 个志愿"; msgClass="warning"; }
  else if ("duplicate_choice".equals(msg)) { msgTitle="提示"; msgContent="三个志愿不能选择同一个题目"; msgClass="warning"; }
  else if ("topic_invalid".equals(msg)) { msgTitle="提示"; msgContent="只能选择本专业、未分配、已审核通过的题目"; msgClass="warning"; }
  else if ("intent_full".equals(msg)) { msgTitle="提示"; msgContent="某个题目的本轮意向人数已满，请重新选择"; msgClass="warning"; }
  else if ("quota_full".equals(msg)) { msgTitle="提示"; msgContent="该课题名额已满"; msgClass="warning"; }
  else if ("selection_closed".equals(msg)) { msgTitle="提示"; msgContent="选题系统当前未开启，只能浏览已公布题目"; msgClass="warning"; }
  else if ("major_mismatch".equals(msg)) { msgTitle="提示"; msgContent="只能申请本学院本专业范围内的课题"; msgClass="warning"; }
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

<form class="mb-3" method="get" action="topic.action">
  <div class="row g-2">
    <div class="col-md-4">
      <input name="keyword" class="form-control form-control-sm" placeholder="搜索课题名称或描述..." value="<%= EscapeUtil.attr(keyword) %>">
    </div>
    <div class="col-md-5">
      <div class="form-control form-control-sm bg-light">
        仅显示本人专业：<%= EscapeUtil.html(loginUser.getCollegeName()) %> / <%= EscapeUtil.html(loginUser.getMajorName()) %>
      </div>
    </div>
    <div class="col-md-auto">
      <button type="submit" class="btn btn-primary btn-sm">搜索</button>
      <a href="topic.action" class="btn btn-outline-secondary btn-sm">重置</a>
    </div>
  </div>
</form>

<% if (!selectionOpen && manualAssignOpen) { %>
  <div class="alert alert-warning py-2">第二轮选题已结束，当前进入强制分配阶段。请等待系主任/专业负责人确认或分配最终题目。</div>
<% } else if (!selectionOpen) { %>
  <div class="alert alert-warning py-2">选题系统当前关闭：可以浏览系主任已公布题目，但不能提交选题申请。</div>
<% } %>

<% if (assignment != null) { %>
  <div class="content-card mb-3">
    <h5 class="mb-3">最终确认结果</h5>
    <table class="table-modern">
      <tr><th>题目</th><th>指导教师</th><th>来源</th><th>确认人</th><th>确认时间</th></tr>
      <tr>
        <td><%= EscapeUtil.html(assignment.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(assignment.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(assignment.getSource()) %></td>
        <td><%= EscapeUtil.html(assignment.getConfirmerName()) %></td>
        <td><%= assignment.getConfirmTime()==null?"—":sdf.format(assignment.getConfirmTime()) %></td>
      </tr>
    </table>
  </div>
<% } else if (legacySelection != null) { %>
  <div class="content-card mb-3">
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
  </div>
<% } else if (activeApplication != null) { %>
  <div class="content-card mb-3">
    <h5 class="mb-3">本轮已提交志愿</h5>
    <table class="table-modern">
      <tr><th>轮次</th><th>志愿顺序</th><th>题目</th><th>指导教师</th><th>状态</th></tr>
      <% for (SelectionChoice c : activeChoices) { %>
      <tr>
        <td>第 <%= c.getRound() %> 轮</td>
        <td>第 <%= c.getChoiceRank() %> 志愿</td>
        <td><%= EscapeUtil.html(c.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(c.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(c.getStatus()) %></td>
      </tr>
      <% } %>
    </table>
    <div class="text-muted small mt-2">提交后需等待专业负责人确认，本轮不能重复提交。</div>
  </div>
<% } else { %>
  <div class="content-card mb-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h5 class="mb-0">第 <%= round %> 轮志愿填报</h5>
      <span class="text-muted small">至少 1 个，最多 3 个；每题本轮最多 <%= intentLimit %> 个意向</span>
    </div>
    <% if (topics.isEmpty()) { %>
      <div class="empty-state"><div class="icon">&#128269;</div><p>当前没有可填报的本专业题目</p></div>
    <% } else { %>
    <form action="topic.action" method="post" onsubmit="return validateChoices()">
      <input type="hidden" name="action" value="submitChoices">
      <div class="row g-2">
        <div class="col-md-4">
          <label class="form-label">第一志愿 *</label>
          <select name="topic1" id="topic1" class="form-select form-select-sm choice-select" required <%= selectionOpen ? "" : "disabled" %>>
            <option value="">请选择题目</option>
            <% for (Topic t : topics) {
                Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
                int count = cntObj == null ? 0 : cntObj.intValue();
                boolean full = count >= intentLimit;
            %>
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>）<%= full ? " - 意向已满" : "" %></option>
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
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>）<%= full ? " - 意向已满" : "" %></option>
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
              <option value="<%= t.getId() %>" <%= full ? "disabled" : "" %>><%= EscapeUtil.html(t.getTitle()) %>（<%= count %>/<%= intentLimit %>）<%= full ? " - 意向已满" : "" %></option>
            <% } %>
          </select>
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary btn-sm" <%= selectionOpen ? "" : "disabled" %>>提交志愿</button>
      </div>
    </form>
    <% } %>
  </div>
<% } %>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128269;</div><p>没有找到匹配的已公布课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= EscapeUtil.html(t.getTitle()) %></h6>
      <p><%= EscapeUtil.html(t.getDescription()) %></p>
      <div class="meta">
        <span class="badge bg-secondary"><%= t.getCollegeName() != null ? t.getCollegeName() : "未分类" %></span>
        <span class="badge bg-info"><%= t.getMajorName() != null ? t.getMajorName() : "未分专业" %></span>
        <br>
        指导教师: <%= EscapeUtil.html(t.getTeacherName()) %>
        <br>
        <% Integer cntObj = intentCounts.get(Integer.valueOf(t.getId()));
           int intentCount = cntObj == null ? 0 : cntObj.intValue(); %>
        本轮意向: <%= intentCount %>/<%= intentLimit %>
      </div>
      <% if (!selectionOpen) { %>
        <span class="text-muted small mt-2 d-block">当前只能浏览，选题系统开启后才能申请</span>
      <% } else if (!hasApplied && intentCount < intentLimit) { %>
        <div class="btn-group btn-group-sm mt-2" role="group">
          <button type="button" class="btn btn-outline-primary" onclick="setChoice('topic1','<%= t.getId() %>')">设为第一志愿</button>
          <button type="button" class="btn btn-outline-secondary" onclick="setChoice('topic2','<%= t.getId() %>')">第二</button>
          <button type="button" class="btn btn-outline-secondary" onclick="setChoice('topic3','<%= t.getId() %>')">第三</button>
        </div>
      <% } else if (hasApplied) { %>
        <span class="text-muted small mt-2 d-block">您已有选题或志愿记录</span>
      <% } else { %>
        <span class="badge-status badge-closed mt-2">本轮意向已满</span>
      <% } %>
    </div>
  <% }} %>
</div>

<script>
function setChoice(selectId, topicId) {
  var select = document.getElementById(selectId);
  if (!select) return;
  select.value = topicId;
}
function validateChoices() {
  var values = [];
  ['topic1', 'topic2', 'topic3'].forEach(function(id) {
    var el = document.getElementById(id);
    var val = el ? el.value : '';
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
