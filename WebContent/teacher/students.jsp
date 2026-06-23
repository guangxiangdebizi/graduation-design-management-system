<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "学生进度");
  User loginUser = (User) session.getAttribute("loginUser");
  List<StudentProgress> progressList = (List<StudentProgress>) request.getAttribute("progressList");
  java.util.Map<String,String> typeNames = (java.util.Map<String,String>) request.getAttribute("typeNames");
  if (progressList == null || typeNames == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/students.action");
    return;
  }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (progressList.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#127891;</div><p>暂无已选题学生</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>学生</th><th>学号</th><th>课题</th>
        <% for (String label : typeNames.values()) { %><th><%= label %></th><% } %>
      </tr>
      <% for (StudentProgress progress : progressList) {
           TopicSelection s = progress.getSelection();
           java.util.Map<String,Document> docMap = progress.getDocuments();
      %>
      <tr>
        <td><%= EscapeUtil.html(s.getStudentName()) %></td>
        <td><%= EscapeUtil.html(s.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
        <% for (String type : typeNames.keySet()) {
             Document d = docMap.get(type);
             if (d == null) { %>
          <td><span class="text-muted">未提交</span></td>
        <% } else { %>
          <td><% request.setAttribute("status", d.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %>
            <% if (d.getScore()!=null) { %>(<%= d.getScore() %>分)<% } %>
          </td>
        <% }} %>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
