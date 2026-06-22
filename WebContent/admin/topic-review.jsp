<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "课题审核");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  String keyword = (String) request.getAttribute("keyword");
  String collegeFilter = (String) request.getAttribute("collegeFilter");
  String majorFilter = (String) request.getAttribute("majorFilter");
  String statusFilter = (String) request.getAttribute("statusFilter");
  Map<String,String> collegeOptions = (Map<String,String>) request.getAttribute("collegeOptions");
  Map<String, Map<String, String>> majorGroups =
      (Map<String, Map<String, String>>) request.getAttribute("majorGroups");
  Map<String,String> topicStatusOptions = (Map<String,String>) request.getAttribute("topicStatusOptions");
  if (topics == null) {
    response.sendRedirect(request.getContextPath() + "/admin/topic-review.action");
    return;
  }
  if (keyword == null) keyword = "";
  if (collegeFilter == null) collegeFilter = "";
  if (majorFilter == null) majorFilter = "";
  if (statusFilter == null) statusFilter = "";
  if (collegeOptions == null) collegeOptions = new LinkedHashMap<String,String>();
  if (majorGroups == null) majorGroups = new LinkedHashMap<String, Map<String, String>>();
  if (topicStatusOptions == null) topicStatusOptions = new LinkedHashMap<String,String>();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<form class="content-card mb-3" method="get" action="topic-review.action">
  <div class="row g-2 align-items-end">
    <div class="col-md-3"><label class="form-label">关键词</label><input name="keyword" class="form-control form-control-sm" value="<%= EscapeUtil.attr(keyword) %>"></div>
    <div class="col-md-2"><label class="form-label">学院</label><select name="college" id="filterCollege" class="form-select form-select-sm" onchange="updateFilterMajors()">
      <option value="">全部学院</option>
      <% for (Map.Entry<String,String> e : collegeOptions.entrySet()) { %>
      <option value="<%= e.getKey() %>" <%= e.getKey().equals(collegeFilter)?"selected":"" %>><%= EscapeUtil.html(e.getValue()) %></option>
      <% } %>
    </select></div>
    <div class="col-md-2"><label class="form-label">专业</label><select name="major" id="filterMajor" class="form-select form-select-sm">
      <option value="">全部专业</option>
    </select></div>
    <div class="col-md-3"><label class="form-label">状态</label><select name="status" class="form-select form-select-sm">
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
      <tr><td colspan="7" class="text-center text-muted py-4">暂无课题</td></tr>
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
var majorsData = {
  <% int cidx = 0; for (Map.Entry<String, Map<String, String>> group : majorGroups.entrySet()) { %>
  <%= cidx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(group.getKey()) %>": {
    <% int midx = 0; for (Map.Entry<String, String> e : group.getValue().entrySet()) { %>
    <%= midx++ > 0 ? "," : "" %>"<%= EscapeUtil.js(e.getKey()) %>": "<%= EscapeUtil.js(e.getValue()) %>"
    <% } %>
  }
  <% } %>
};

function updateFilterMajors() {
  var collegeEl = document.getElementById('filterCollege');
  var majorSelect = document.getElementById('filterMajor');
  if (!collegeEl || !majorSelect) return;
  var college = collegeEl.value;
  var selected = '<%= EscapeUtil.js(majorFilter) %>';
  majorSelect.innerHTML = '<option value="">全部专业</option>';
  if (college && majorsData[college]) {
    for (var key in majorsData[college]) {
      var option = document.createElement('option');
      option.value = key;
      option.textContent = majorsData[college][key];
      if (key === selected) option.selected = true;
      majorSelect.appendChild(option);
    }
  }
}

function reviewTopic(id, action, title) {
  document.getElementById('reviewId').value = id;
  document.getElementById('reviewAction').value = action;
  document.getElementById('reviewTitle').textContent = (action === 'approve' ? '通过' : '驳回') + ' - ' + title;
  new bootstrap.Modal(document.getElementById('reviewModal')).show();
}

updateFilterMajors();
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
