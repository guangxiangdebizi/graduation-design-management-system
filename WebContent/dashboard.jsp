<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "仪表盘");
  User loginUser = (User) session.getAttribute("loginUser");
  String role = loginUser.getRole();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  if (request.getAttribute("announcements") == null && request.getAttribute("mySelections") == null) {
    response.sendRedirect(request.getContextPath() + "/dashboard.action");
    return;
  }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if ("admin".equals(role) || "director".equals(role)) {
    boolean director = "director".equals(role);
    int teacherCount = ((Integer) request.getAttribute("teacherCount")).intValue();
    int studentCount = ((Integer) request.getAttribute("studentCount")).intValue();
    int topicCount = ((Integer) request.getAttribute("topicCount")).intValue();
    int selectedCount = ((Integer) request.getAttribute("selectedCount")).intValue();
    List<Announcement> announcements = (List<Announcement>) request.getAttribute("announcements");
    int myTopics = ((Integer) request.getAttribute("myTopics")).intValue();
    int pendingSel = ((Integer) request.getAttribute("pendingSel")).intValue();
    int pendingDirectorSel = ((Integer) request.getAttribute("pendingDirectorSel")).intValue();
    int pendingDoc = ((Integer) request.getAttribute("pendingDoc")).intValue();
    int pendingPaperReview = ((Integer) request.getAttribute("pendingPaperReview")).intValue();
    List<TopicSelection> pendingList = (List<TopicSelection>) request.getAttribute("pendingList");
%>
<% if (director) { %>
<div class="alert alert-info py-2">
  当前系主任管理范围：<%= EscapeUtil.html(loginUser.getCollegeName()) %> / <%= EscapeUtil.html(loginUser.getMajorName()) %>
</div>
<% } %>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128101;</span><div class="label">教师人数</div><div class="value"><%= teacherCount %></div></div>
  <div class="stat-card"><span class="icon">&#127891;</span><div class="label">学生人数</div><div class="value"><%= studentCount %></div></div>
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">课题总数</div><div class="value"><%= topicCount %></div></div>
  <div class="stat-card"><span class="icon">&#9989;</span><div class="label">已选题学生</div><div class="value"><%= selectedCount %></div></div>
</div>
<div class="content-card">
  <h5>系统公告</h5>
  <% if (announcements.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128227;</div><p>暂无公告</p></div>
  <% } else { for (Announcement a : announcements) { %>
    <div class="announce-item">
      <div class="title"><% if (a.getIsTop()==1) { %><span class="badge bg-danger me-1">置顶</span><% } %><%= EscapeUtil.html(a.getTitle()) %></div>
      <div class="meta"><%= EscapeUtil.html(a.getPublisherName()) %> · <%= sdf.format(a.getCreatedAt()) %></div>
      <div class="content"><%= EscapeUtil.html(a.getContent()).replace("\n","<br>") %></div>
    </div>
  <% }} %>
</div>
<% if (director) { %>
<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h5 class="mb-1">教师身份工作台</h5>
      <div class="text-muted small">系主任继承教师权限，这里统计本人作为指导教师负责的课题/文档，以及被分配的论文评阅任务。</div>
    </div>
    <div class="d-flex flex-wrap gap-2">
      <a href="teacher/topic.action" class="btn btn-outline-primary btn-sm">我的课题</a>
      <a href="teacher/selection.action" class="btn btn-outline-primary btn-sm">选题建议</a>
      <a href="teacher/document.action" class="btn btn-outline-primary btn-sm">文档审核</a>
      <a href="teacher/paper-review.action" class="btn btn-outline-primary btn-sm">论文评阅</a>
      <a href="teacher/students.action" class="btn btn-outline-primary btn-sm">学生进度</a>
    </div>
  </div>
  <div class="stat-cards">
    <div class="stat-card"><span class="icon">&#128221;</span><div class="label">我的课题</div><div class="value"><%= myTopics %></div></div>
    <div class="stat-card"><span class="icon">&#128203;</span><div class="label">待给建议选题</div><div class="value"><%= pendingSel %></div></div>
    <div class="stat-card"><span class="icon">&#128196;</span><div class="label">待审文档</div><div class="value"><%= pendingDoc %></div></div>
    <div class="stat-card"><span class="icon">&#128214;</span><div class="label">待评阅论文</div><div class="value"><%= pendingPaperReview %></div></div>
    <div class="stat-card"><span class="icon">&#9989;</span><div class="label">本专业待确认选题</div><div class="value"><%= pendingDirectorSel %></div></div>
  </div>
  <% if (!pendingList.isEmpty()) { %>
  <table class="table-modern mt-3">
    <tr><th>学生</th><th>课题</th><th>时间</th><th></th></tr>
    <% for (TopicSelection s : pendingList) { %>
    <tr>
      <td><%= EscapeUtil.html(s.getStudentName()) %></td>
      <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
      <td><%= sdf.format(s.getApplyTime()) %></td>
      <td><a href="teacher/selection.action" class="btn btn-sm btn-outline-primary">给建议</a></td>
    </tr>
    <% } %>
  </table>
  <% } %>
</div>
<% } %>
<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0"><%= director ? "本专业管理功能" : "完整版功能" %></h5>
    <a href="<%= director ? "director" : "admin" %>/export.action" class="btn btn-success btn-sm">导出成绩 Excel</a>
  </div>
  <div class="d-flex flex-wrap gap-2">
    <% if (director) { %>
    <a href="director/topic-review.action" class="btn btn-outline-primary btn-sm">本专业课题审核</a>
    <a href="director/selection-confirm.action" class="btn btn-outline-primary btn-sm">本专业选题确认</a>
    <a href="director/paper-review.action" class="btn btn-outline-primary btn-sm">本专业论文评阅</a>
    <a href="director/defense.action" class="btn btn-outline-primary btn-sm">本专业答辩安排</a>
    <a href="director/statistics.jsp" class="btn btn-outline-primary btn-sm">本专业项目统计</a>
    <% } else { %>
    <a href="admin/statistics.jsp" class="btn btn-outline-primary btn-sm">ECharts 统计</a>
    <a href="admin/announcement.action" class="btn btn-outline-primary btn-sm">公告管理</a>
    <a href="admin/messages.action" class="btn btn-outline-primary btn-sm">站内消息</a>
    <a href="admin/logs.action" class="btn btn-outline-primary btn-sm">操作日志</a>
    <% } %>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
<div class="content-card">
  <h6>选题概况</h6>
  <div id="adminMiniChart" style="height:220px;position:relative">
    <div id="adminMiniChartLoading" class="text-center py-5 text-muted">加载中...</div>
    <div id="adminMiniChartError" class="text-center py-5 text-danger d-none">图表加载失败，请稍后刷新页面重试</div>
  </div>
</div>
<script>
(function() {
  var loadingEl = document.getElementById('adminMiniChartLoading');
  var errorEl = document.getElementById('adminMiniChartError');
  try {
    fetch('<%= director ? "director" : "admin" %>/stats.action').then(function(r) {
      if (!r.ok) throw new Error('fetch failed');
      return r.json();
    }).then(function(data) {
      if (typeof echarts === 'undefined') throw new Error('echarts missing');
      loadingEl.style.display = 'none';
      var selData = [];
      for (var k in data.selection) { selData.push({ name: k, value: data.selection[k] }); }
      echarts.init(document.getElementById('adminMiniChart')).setOption({
        tooltip: { trigger: 'item' },
        series: [{ type: 'pie', radius: '60%', data: selData }]
      });
    }).catch(function() {
      loadingEl.style.display = 'none';
      errorEl.classList.remove('d-none');
    });
  } catch (e) {
    loadingEl.style.display = 'none';
    errorEl.classList.remove('d-none');
  }
})();
</script>

<% } else if ("teacher".equals(role)) {
    int myTopics = ((Integer) request.getAttribute("myTopics")).intValue();
    int pendingSel = ((Integer) request.getAttribute("pendingSel")).intValue();
    int pendingDoc = ((Integer) request.getAttribute("pendingDoc")).intValue();
    int pendingPaperReview = ((Integer) request.getAttribute("pendingPaperReview")).intValue();
    List<TopicSelection> pendingList = (List<TopicSelection>) request.getAttribute("pendingList");
    List<Announcement> announcements = (List<Announcement>) request.getAttribute("announcements");
%>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">我的课题</div><div class="value"><%= myTopics %></div></div>
  <div class="stat-card"><span class="icon">&#128203;</span><div class="label">待给建议选题</div><div class="value"><%= pendingSel %></div></div>
  <div class="stat-card"><span class="icon">&#128196;</span><div class="label">待审文档</div><div class="value"><%= pendingDoc %></div></div>
  <div class="stat-card"><span class="icon">&#128214;</span><div class="label">待评阅论文</div><div class="value"><%= pendingPaperReview %></div></div>
</div>
<div class="row">
  <div class="col-md-6">
    <div class="content-card">
      <h5>待给建议选题</h5>
      <% if (pendingList.isEmpty()) { %>
        <div class="empty-state"><p>暂无待给建议选题申请</p></div>
      <% } else { %>
        <table class="table-modern">
          <tr><th>学生</th><th>课题</th><th>时间</th><th></th></tr>
          <% for (TopicSelection s : pendingList) { %>
          <tr>
            <td><%= EscapeUtil.html(s.getStudentName()) %></td>
            <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
            <td><%= sdf.format(s.getApplyTime()) %></td>
            <td><a href="teacher/selection.action" class="btn btn-sm btn-outline-primary">给建议</a></td>
          </tr>
          <% } %>
        </table>
      <% } %>
    </div>
  </div>
  <div class="col-md-6">
    <div class="content-card">
      <h5>最新公告</h5>
      <% for (int i=0; i<Math.min(3, announcements.size()); i++) {
           Announcement a = announcements.get(i); %>
        <div class="announce-item">
          <div class="title"><%= EscapeUtil.html(a.getTitle()) %></div>
          <div class="meta"><%= sdf.format(a.getCreatedAt()) %></div>
        </div>
      <% } %>
    </div>
  </div>
</div>

<% } else {
    List<TopicSelection> mySelections = (List<TopicSelection>) request.getAttribute("mySelections");
    List<Document> myDocs = (List<Document>) request.getAttribute("myDocs");
    List<Announcement> announcements = (List<Announcement>) request.getAttribute("announcements");
    DefenseSchedule defense = (DefenseSchedule) request.getAttribute("defense");
    String selectionStatusText = (String) request.getAttribute("selectionStatusText");
%>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">选题状态</div><div class="value" style="font-size:1.2rem;"><%= selectionStatusText %></div></div>
  <div class="stat-card"><span class="icon">&#128196;</span><div class="label">已提交文档</div><div class="value"><%= myDocs.size() %></div></div>
  <div class="stat-card"><span class="icon">&#128227;</span><div class="label">系统公告</div><div class="value"><%= announcements.size() %></div></div>
</div>
<div class="row">
  <div class="col-md-6">
    <div class="content-card">
      <h5>我的选题</h5>
      <% if (mySelections.isEmpty()) { %>
        <div class="empty-state"><p>您还没有申请选题</p><a href="student/topic.action" class="btn btn-primary btn-sm">去浏览课题</a></div>
      <% } else { %>
        <table class="table-modern">
          <tr><th>课题</th><th>指导教师</th><th>状态</th></tr>
          <% for (TopicSelection s : mySelections) { %>
          <tr>
            <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
            <td><%= EscapeUtil.html(s.getTeacherName()) %></td>
            <td><% request.setAttribute("status", s.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
          </tr>
          <% } %>
        </table>
      <% } %>
    </div>
  </div>
  <div class="col-md-6">
    <div class="content-card">
      <h5>答辩信息</h5>
      <% if (defense == null) { %>
        <div class="empty-state"><p>答辩教师尚未安排</p></div>
      <% } else { %>
        <table class="table-modern">
          <tr><th>答辩教师</th><td><%= defense.getCommitteeMembers()==null || defense.getCommitteeMembers().isEmpty() ? "尚未指定" : defense.getCommitteeMembers().size() + " 人" %></td></tr>
          <tr><th>评分进度</th><td><%= defense.getScoreCount() %>/3</td></tr>
          <tr><th>答辩成绩</th><td><%= defense.getAverageScore()==null?"待评定":defense.getAverageScore() + " 分" %></td></tr>
        </table>
        <a href="student/defense.action" class="btn btn-sm btn-outline-primary">查看详情</a>
      <% } %>
    </div>
  </div>
</div>
<div class="row mt-0">
  <div class="col-md-12">
    <div class="content-card">
      <h5>最新公告</h5>
      <% for (int i=0; i<Math.min(3, announcements.size()); i++) {
           Announcement a = announcements.get(i); %>
        <div class="announce-item">
          <div class="title"><%= EscapeUtil.html(a.getTitle()) %></div>
          <div class="content"><%= EscapeUtil.html(a.getContent().length()>80 ? a.getContent().substring(0,80)+"..." : a.getContent()) %></div>
        </div>
      <% } %>
    </div>
  </div>
</div>
<% } %>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
