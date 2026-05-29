<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.PageUtil" %>
<%
  request.setAttribute("pageTitle", "我的成绩");
  User loginUser = (User) session.getAttribute("loginUser");
  DocumentDao docDao = new DocumentDao();
  DefenseScheduleDao defDao = new DefenseScheduleDao();
  List<Document> docs = docDao.findByStudent(loginUser.getId());
  DefenseSchedule defense = defDao.findByStudent(loginUser.getId());
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  java.util.Map<String,String> typeNames = new java.util.LinkedHashMap<String,String>();
  typeNames.put("proposal", "开题报告");
  typeNames.put("midterm", "中期检查");
  typeNames.put("final", "终稿");
  java.util.Map<String, Document> docMap = new java.util.HashMap<String, Document>();
  for (Document d : docs) { docMap.put(d.getDocType(), d); }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="stat-cards mb-3">
  <% for (java.util.Map.Entry<String,String> e : typeNames.entrySet()) {
       Document d = docMap.get(e.getKey()); %>
  <div class="stat-card">
    <span class="icon">&#128196;</span>
    <div class="label"><%= e.getValue() %></div>
    <div class="value" style="font-size:1.1rem;"><%= d!=null && d.getScore()!=null ? d.getScore()+" 分" : "—" %></div>
  </div>
  <% } %>
  <div class="stat-card">
    <span class="icon">&#127891;</span>
    <div class="label">答辩成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= defense!=null && defense.getScore()!=null ? defense.getScore()+" 分" : "—" %></div>
  </div>
</div>

<div class="content-card">
  <% if (docs.isEmpty() && defense == null) { %>
    <div class="empty-state"><div class="icon">&#128200;</div><p>暂无成绩记录，请先提交文档</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>阶段</th><th>标题</th><th>提交时间</th><th>状态</th><th>分数</th><th>教师反馈</th></tr>
      <% for (Document d : docs) { %>
      <tr>
        <td><%= typeNames.get(d.getDocType()) %></td>
        <td><%= EscapeUtil.html(d.getTitle()) %></td>
        <td><%= d.getSubmitTime()!=null?sdf.format(d.getSubmitTime()):"—" %></td>
        <td><% request.setAttribute("status", d.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
        <td><% if (d.getScore()!=null) { %><%= d.getScore() %> 分<% } else { %><span class="text-muted">待评分</span><% } %></td>
        <td><%= d.getFeedback()==null?"—":EscapeUtil.html(d.getFeedback()) %></td>
      </tr>
      <% } %>
      <% if (defense != null) { %>
      <tr>
        <td>答辩</td>
        <td><%= defense.getTopicTitle()==null?"—":EscapeUtil.html(defense.getTopicTitle()) %></td>
        <td><%= defense.getDefenseTime()!=null?sdf.format(defense.getDefenseTime()):"—" %></td>
        <td><span class="badge-status badge-reviewed">已安排</span></td>
        <td><% if (defense.getScore()!=null) { %><%= defense.getScore() %> 分<% } else { %><span class="text-muted">待评定</span><% } %></td>
        <td><%= defense.getComment()==null?"—":EscapeUtil.html(defense.getComment()) %></td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
