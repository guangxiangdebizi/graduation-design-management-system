<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "我的选题");
  User loginUser = (User) session.getAttribute("loginUser");
  List<TopicSelection> list = (List<TopicSelection>) request.getAttribute("selections");
  if (list == null) {
    response.sendRedirect(request.getContextPath() + "/student/my-selection.action");
    return;
  }
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
      <a href="topic.action" class="btn btn-primary btn-sm">去浏览课题</a>
    </div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>课题</th><th>指导教师</th><th>申请理由</th><th>申请时间</th><th>状态</th><th>审批意见</th></tr>
      <% for (TopicSelection s : list) { %>
      <tr>
        <td><%= EscapeUtil.html(s.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(s.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(s.getApplyReason()) %></td>
        <td><%= sdf.format(s.getApplyTime()) %></td>
        <td><% request.setAttribute("status", s.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
        <td><%= s.getReviewComment()==null?"—":EscapeUtil.html(s.getReviewComment()) %></td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
