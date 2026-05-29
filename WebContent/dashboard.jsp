<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "仪表盘");
  User loginUser = (User) session.getAttribute("loginUser");
  String role = loginUser.getRole();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if ("admin".equals(role)) {
    UserDao userDao = new UserDao();
    TopicDao topicDao = new TopicDao();
    SelectionDao selDao = new SelectionDao();
    AnnouncementDao annDao = new AnnouncementDao();
    int teacherCount = userDao.countByRole("teacher");
    int studentCount = userDao.countByRole("student");
    int topicCount = topicDao.countAll();
    int selectedCount = selDao.countApprovedStudents();
    List<Announcement> announcements = annDao.findAll();
%>
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
<div class="content-card">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">完整版功能</h5>
    <a href="admin/export.action" class="btn btn-success btn-sm">导出成绩 Excel</a>
  </div>
  <div class="d-flex flex-wrap gap-2">
    <a href="admin/defenses.jsp" class="btn btn-outline-primary btn-sm">答辩安排</a>
    <a href="admin/statistics.jsp" class="btn btn-outline-primary btn-sm">ECharts 统计</a>
    <a href="admin/messages.jsp" class="btn btn-outline-primary btn-sm">站内消息</a>
    <a href="admin/logs.jsp" class="btn btn-outline-primary btn-sm">操作日志</a>
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
    fetch('admin/stats.action').then(function(r) {
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
    TopicDao topicDao = new TopicDao();
    SelectionDao selDao = new SelectionDao();
    DocumentDao docDao = new DocumentDao();
    AnnouncementDao annDao = new AnnouncementDao();
    int myTopics = topicDao.findByTeacher(loginUser.getId()).size();
    int pendingSel = selDao.countPendingByTeacher(loginUser.getId());
    int pendingDoc = docDao.countPendingByTeacher(loginUser.getId());
    List<TopicSelection> pendingList = selDao.findByTeacher(loginUser.getId(), "pending");
    List<Announcement> announcements = annDao.findAll();
%>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">我的课题</div><div class="value"><%= myTopics %></div></div>
  <div class="stat-card"><span class="icon">&#128203;</span><div class="label">待审选题</div><div class="value"><%= pendingSel %></div></div>
  <div class="stat-card"><span class="icon">&#128196;</span><div class="label">待审文档</div><div class="value"><%= pendingDoc %></div></div>
</div>
<div class="row">
  <div class="col-md-6">
    <div class="content-card">
      <h5>待审选题</h5>
      <% if (pendingList.isEmpty()) { %>
        <div class="empty-state"><p>暂无待审选题申请</p></div>
      <% } else { %>
        <table class="table-modern">
          <tr><th>学生</th><th>课题</th><th>时间</th><th></th></tr>
          <% for (TopicSelection s : pendingList) { %>
          <tr>
            <td><%= EscapeUtil.html(s.getStudentName()) %></td>
            <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
            <td><%= sdf.format(s.getApplyTime()) %></td>
            <td><a href="teacher/selections.jsp" class="btn btn-sm btn-outline-primary">去审批</a></td>
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
    SelectionDao selDao = new SelectionDao();
    DocumentDao docDao = new DocumentDao();
    AnnouncementDao annDao = new AnnouncementDao();
    DefenseScheduleDao defDao = new DefenseScheduleDao();
    TopicSelection approved = selDao.findApprovedByStudent(loginUser.getId());
    List<TopicSelection> mySelections = selDao.findByStudent(loginUser.getId());
    List<Document> myDocs = docDao.findByStudent(loginUser.getId());
    List<Announcement> announcements = annDao.findAll();
    DefenseSchedule defense = defDao.findByStudent(loginUser.getId());
    SimpleDateFormat defSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">选题状态</div><div class="value" style="font-size:1.2rem;"><%= approved != null ? "已通过" : "未选题" %></div></div>
  <div class="stat-card"><span class="icon">&#128196;</span><div class="label">已提交文档</div><div class="value"><%= myDocs.size() %></div></div>
  <div class="stat-card"><span class="icon">&#128227;</span><div class="label">系统公告</div><div class="value"><%= announcements.size() %></div></div>
</div>
<div class="row">
  <div class="col-md-6">
    <div class="content-card">
      <h5>我的选题</h5>
      <% if (mySelections.isEmpty()) { %>
        <div class="empty-state"><p>您还没有申请选题</p><a href="student/topics.jsp" class="btn btn-primary btn-sm">去浏览课题</a></div>
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
      <h5>答辩安排</h5>
      <% if (defense == null) { %>
        <div class="empty-state"><p>答辩安排尚未发布</p></div>
      <% } else { %>
        <table class="table-modern">
          <tr><th>时间</th><td><%= defense.getDefenseTime()==null?"待定":defSdf.format(defense.getDefenseTime()) %></td></tr>
          <tr><th>教室</th><td><%= defense.getRoom()==null?"待定":EscapeUtil.html(defense.getRoom()) %></td></tr>
          <tr><th>分组</th><td><%= defense.getGroupName()==null?"—":EscapeUtil.html(defense.getGroupName()) %></td></tr>
          <tr><th>成绩</th><td><%= defense.getScore()==null?"待评定":defense.getScore() %></td></tr>
        </table>
        <a href="student/defense.jsp" class="btn btn-sm btn-outline-primary">查看详情</a>
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
