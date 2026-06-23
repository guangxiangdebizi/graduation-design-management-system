<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil,util.ScopeUtil" %>
<%
  request.setAttribute("pageTitle", "仪表盘");
  User loginUser = (User) session.getAttribute("loginUser");
  String role = loginUser.getRole();
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if ("admin".equals(role) || "director".equals(role)) {
    boolean director = "director".equals(role);
    UserScope directorScope = director ? ScopeUtil.directorScope(loginUser) : null;
    if (director && directorScope == null) {
      response.sendError(403, "director scope missing");
      return;
    }
    UserDao userDao = new UserDao();
    TopicDao topicDao = new TopicDao();
    SelectionDao selDao = new SelectionDao();
    AnnouncementDao annDao = new AnnouncementDao();
    int teacherCount;
    int studentCount;
    int topicCount;
    int selectedCount;
    if (director) {
      UserSearchCriteria teacherCriteria = new UserSearchCriteria();
      teacherCriteria.setRole("teacher");
      teacherCriteria.setCollege(directorScope.getCollege());
      teacherCriteria.setMajor(directorScope.getMajor());
      UserSearchCriteria studentCriteria = new UserSearchCriteria();
      studentCriteria.setRole("student");
      studentCriteria.setCollege(directorScope.getCollege());
      studentCriteria.setMajor(directorScope.getMajor());
      teacherCount = userDao.countAll(teacherCriteria);
      studentCount = userDao.countAll(studentCriteria);
      topicCount = topicDao.countByMajor(directorScope.getCollege(), directorScope.getMajor());
      selectedCount = selDao.countApprovedStudents(directorScope.getCollege(), directorScope.getMajor());
    } else {
      teacherCount = userDao.countByRole("teacher");
      studentCount = userDao.countByRole("student");
      topicCount = topicDao.countAll();
      selectedCount = selDao.countApprovedStudents();
    }
    List<Announcement> announcements = director
      ? annDao.findVisible(directorScope.getCollege(), directorScope.getMajor())
      : annDao.findAll();
    int myTopics = 0;
    int pendingSel = 0;
    int pendingDirectorSel = 0;
    int pendingDoc = 0;
    List<TopicSelection> pendingList = new ArrayList<TopicSelection>();
    if (director) {
      myTopics = topicDao.findByTeacher(loginUser.getId()).size();
      pendingSel = selDao.countPendingByTeacher(loginUser.getId());
      pendingDirectorSel = selDao.countPendingByDirector(directorScope.getCollege(), directorScope.getMajor());
      pendingDoc = new DocumentDao().countPendingByTeacher(loginUser.getId());
      pendingList = selDao.findByTeacher(loginUser.getId(), "pending");
    }
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
      <div class="text-muted small">系主任继承教师权限，这里只统计本人作为指导教师负责的课题、选题和文档。</div>
    </div>
    <div class="d-flex flex-wrap gap-2">
      <a href="teacher/topic.action" class="btn btn-outline-primary btn-sm">我的课题</a>
      <a href="teacher/selection.action" class="btn btn-outline-primary btn-sm">选题建议</a>
      <a href="teacher/document.action" class="btn btn-outline-primary btn-sm">文档审核</a>
      <a href="teacher/students.jsp" class="btn btn-outline-primary btn-sm">学生进度</a>
    </div>
  </div>
  <div class="stat-cards">
    <div class="stat-card"><span class="icon">&#128221;</span><div class="label">我的课题</div><div class="value"><%= myTopics %></div></div>
    <div class="stat-card"><span class="icon">&#128203;</span><div class="label">待给建议选题</div><div class="value"><%= pendingSel %></div></div>
    <div class="stat-card"><span class="icon">&#128196;</span><div class="label">待审文档</div><div class="value"><%= pendingDoc %></div></div>
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
    <a href="director/statistics.jsp" class="btn btn-outline-primary btn-sm">本专业项目统计</a>
    <% } else { %>
    <a href="admin/statistics.jsp" class="btn btn-outline-primary btn-sm">ECharts 统计</a>
    <a href="admin/announcements.jsp" class="btn btn-outline-primary btn-sm">公告管理</a>
    <a href="admin/defenses.jsp" class="btn btn-outline-primary btn-sm">答辩安排</a>
    <a href="admin/messages.jsp" class="btn btn-outline-primary btn-sm">站内消息</a>
    <a href="admin/logs.jsp" class="btn btn-outline-primary btn-sm">操作日志</a>
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
    TopicDao topicDao = new TopicDao();
    SelectionDao selDao = new SelectionDao();
    DocumentDao docDao = new DocumentDao();
    AnnouncementDao annDao = new AnnouncementDao();
    int myTopics = topicDao.findByTeacher(loginUser.getId()).size();
    int pendingSel = selDao.countPendingByTeacher(loginUser.getId());
    int pendingDoc = docDao.countPendingByTeacher(loginUser.getId());
    List<TopicSelection> pendingList = selDao.findByTeacher(loginUser.getId(), "pending");
    List<Announcement> announcements = annDao.findVisible(loginUser.getCollege(), loginUser.getMajor());
%>
<div class="stat-cards">
  <div class="stat-card"><span class="icon">&#128221;</span><div class="label">我的课题</div><div class="value"><%= myTopics %></div></div>
  <div class="stat-card"><span class="icon">&#128203;</span><div class="label">待给建议选题</div><div class="value"><%= pendingSel %></div></div>
  <div class="stat-card"><span class="icon">&#128196;</span><div class="label">待审文档</div><div class="value"><%= pendingDoc %></div></div>
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
    SelectionDao selDao = new SelectionDao();
    DocumentDao docDao = new DocumentDao();
    AnnouncementDao annDao = new AnnouncementDao();
    DefenseScheduleDao defDao = new DefenseScheduleDao();
    TopicSelection approved = selDao.findApprovedByStudent(loginUser.getId());
    List<TopicSelection> mySelections = selDao.findByStudent(loginUser.getId());
    List<Document> myDocs = docDao.findByStudent(loginUser.getId());
    List<Announcement> announcements = annDao.findVisible(loginUser.getCollege(), loginUser.getMajor());
    DefenseSchedule defense = defDao.findByStudent(loginUser.getId());
    String selectionStatusText = "未选题";
    if (approved != null) {
      selectionStatusText = "已通过";
    } else if (!mySelections.isEmpty()) {
      String latestStatus = mySelections.get(0).getStatus();
      if ("pending".equals(latestStatus)) {
        selectionStatusText = "待审核";
      } else if ("rejected".equals(latestStatus)) {
        selectionStatusText = "已驳回";
      }
    }
    SimpleDateFormat defSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
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
