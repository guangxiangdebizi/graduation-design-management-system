<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "我的成绩");
  User loginUser = (User) session.getAttribute("loginUser");
  DocumentDao docDao = new DocumentDao();
  List<Document> docs = docDao.findByStudent(loginUser.getId());
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  java.util.Map<String,String> typeNames = new java.util.LinkedHashMap<String,String>();
  typeNames.put("proposal", "开题报告");
  typeNames.put("midterm", "中期检查");
  typeNames.put("final", "终稿");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (docs.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128200;</div><p>暂无成绩记录，请先提交文档</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>阶段</th><th>标题</th><th>提交时间</th><th>状态</th><th>分数</th><th>教师反馈</th></tr>
      <% for (Document d : docs) { %>
      <tr>
        <td><%= typeNames.get(d.getDocType()) %></td>
        <td><%= d.getTitle() %></td>
        <td><%= d.getSubmitTime()!=null?sdf.format(d.getSubmitTime()):"—" %></td>
        <td><span class="badge-status badge-<%= d.getStatus() %>"><%= d.getStatus() %></span></td>
        <td><% if (d.getScore()!=null) { %><%= d.getScore() %> 分<% } else { %><span class="text-muted">待评分</span><% } %></td>
        <td><%= d.getFeedback()==null?"—":d.getFeedback() %></td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
