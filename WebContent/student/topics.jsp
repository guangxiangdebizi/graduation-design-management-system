<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*" %>
<%@ page import="util.EscapeUtil,util.CollegeUtil" %>
<%
  request.setAttribute("pageTitle", "浏览课题");
  User loginUser = (User) session.getAttribute("loginUser");

  // 获取筛选参数和课题列表（如果是从Controller传入的）
  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  String keyword = (String) request.getAttribute("keyword");
  String collegeFilter = (String) request.getAttribute("collegeFilter");

  if (topics == null) {
    // 首次加载
    keyword = request.getParameter("keyword");
    collegeFilter = request.getParameter("college");
    TopicDao topicDao = new TopicDao();
    topics = topicDao.findOpenTopics(keyword, collegeFilter);
  }
  if (keyword == null) keyword = "";
  if (collegeFilter == null) collegeFilter = "";

  SelectionDao selDao = new SelectionDao();
  boolean hasApplied = selDao.hasPendingOrApproved(loginUser.getId());

  // 消息提示
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("already_applied".equals(msg)) { msgTitle="提示"; msgContent="您已有选题申请，请等待教师审核"; msgClass="warning"; }
  else if ("quota_full".equals(msg)) { msgTitle="提示"; msgContent="该课题名额已满"; msgClass="warning"; }
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
      <input name="keyword" class="form-control form-control-sm" placeholder="搜索课题名称或描述..." value="<%= keyword %>">
    </div>
    <div class="col-md-3">
      <select name="college" class="form-select form-select-sm">
        <option value="">全部学院</option>
        <% for (Map.Entry<String, String> e : CollegeUtil.COLLEGES.entrySet()) { %>
        <option value="<%= e.getKey() %>" <%= e.getKey().equals(collegeFilter) ? "selected" : "" %>><%= e.getValue() %></option>
        <% } %>
      </select>
    </div>
    <div class="col-md-auto">
      <button type="submit" class="btn btn-primary btn-sm">搜索</button>
      <a href="topic.action" class="btn btn-outline-secondary btn-sm">重置</a>
    </div>
  </div>
</form>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128269;</div><p>没有找到匹配的课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= EscapeUtil.html(t.getTitle()) %></h6>
      <p><%= EscapeUtil.html(t.getDescription()) %></p>
      <div class="meta">
        <span class="badge bg-secondary"><%= t.getCollegeName() != null ? t.getCollegeName() : "未分类" %></span>
        <br>
        指导教师: <%= EscapeUtil.html(t.getTeacherName()) %>
        <br>
        名额: <%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>
      </div>
      <% if (!hasApplied && t.getSelectedCount() < t.getMaxStudents()) { %>
        <button class="btn btn-primary btn-sm mt-2" onclick="applyTopic(<%= t.getId() %>,'<%= EscapeUtil.js(t.getTitle()) %>')">申请选题</button>
      <% } else if (hasApplied) { %>
        <span class="text-muted small mt-2 d-block">您已有选题申请</span>
      <% } else { %>
        <span class="badge-status badge-closed mt-2">名额已满</span>
      <% } %>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="applyModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic.action" method="post">
      <input type="hidden" name="action" value="apply">
      <input type="hidden" name="topicId" id="applyTopicId">
      <div class="modal-header"><h6 class="modal-title" id="applyTitle">申请选题</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <label class="form-label">申请理由</label>
        <textarea name="applyReason" class="form-control form-control-sm" rows="4" placeholder="请说明您选择该课题的原因和相关基础..." required></textarea>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">提交申请</button></div>
    </form>
  </div></div>
</div>

<script>
function applyTopic(id, title) {
  document.getElementById('applyTopicId').value = id;
  document.getElementById('applyTitle').textContent = '申请选题 - ' + title;
  new bootstrap.Modal(document.getElementById('applyModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>