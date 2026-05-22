<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*" %>
<%
  request.setAttribute("pageTitle", "学生进度");
  User loginUser = (User) session.getAttribute("loginUser");
  SelectionDao selDao = new SelectionDao();
  DocumentDao docDao = new DocumentDao();
  List<TopicSelection> approved = selDao.findByTeacher(loginUser.getId(), "approved");
  java.util.Map<String,String> typeNames = new java.util.LinkedHashMap<String,String>();
  typeNames.put("proposal", "开题");
  typeNames.put("midterm", "中期");
  typeNames.put("final", "终稿");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (approved.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#127891;</div><p>暂无已选题学生</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>学生</th><th>学号</th><th>课题</th><th>开题报告</th><th>中期检查</th><th>终稿</th></tr>
      <% for (TopicSelection s : approved) {
           List<Document> docs = docDao.findByStudent(s.getStudentId());
           java.util.Map<String,Document> docMap = new java.util.HashMap<String,Document>();
           for (Document d : docs) { docMap.put(d.getDocType(), d); }
      %>
      <tr>
        <td><%= s.getStudentName() %></td>
        <td><%= s.getStudentNo() %></td>
        <td><%= s.getTopicTitle() %></td>
        <% for (String type : typeNames.keySet()) {
             Document d = docMap.get(type);
             if (d == null) { %>
          <td><span class="text-muted">未提交</span></td>
        <% } else { %>
          <td><span class="badge-status badge-<%= d.getStatus() %>"><%= d.getStatus() %></span>
            <% if (d.getScore()!=null) { %>(<%= d.getScore() %>分)<% } %>
          </td>
        <% }} %>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
