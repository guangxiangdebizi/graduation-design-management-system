<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "我的选题");
  User loginUser = (User) session.getAttribute("loginUser");
  SelectionDao dao = new SelectionDao();
  List<TopicSelection> list = dao.findByStudent(loginUser.getId());
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (list.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">&#128221;</div>
      <p>您还没有申请任何课题</p>
      <a href="topics.jsp" class="btn btn-primary btn-sm">去浏览课题</a>
    </div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>课题</th><th>指导教师</th><th>申请理由</th><th>申请时间</th><th>状态</th><th>审批意见</th></tr>
      <% for (TopicSelection s : list) { %>
      <tr>
        <td><%= s.getTopicTitle() %></td>
        <td><%= s.getTeacherName() %></td>
        <td><%= s.getApplyReason() %></td>
        <td><%= sdf.format(s.getApplyTime()) %></td>
        <td><span class="badge-status badge-<%= s.getStatus() %>"><%= s.getStatus() %></span></td>
        <td><%= s.getReviewComment()==null?"—":s.getReviewComment() %></td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
