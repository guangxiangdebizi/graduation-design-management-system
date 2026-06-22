<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="util.DictionaryUtil" %>
<%
  String ctx = request.getContextPath();
  String sidebarCurrentPage = request.getRequestURI();
  String userRole = loginUser.getRole();
  int unreadMsg = 0;
  try {
    unreadMsg = new dao.MessageDao().countUnread(loginUser.getId());
  } catch (Exception ignored) {}
%>
<div class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    毕业设计管理系统
    <small>Graduation Design</small>
  </div>
  <nav class="sidebar-nav">
    <a href="<%= ctx %>/dashboard.jsp" class="<%= sidebarCurrentPage.endsWith("dashboard.jsp") ? "active" : "" %>">&#9632; 仪表盘</a>
    <% if ("admin".equals(userRole)) { %>
      <a href="<%= ctx %>/admin/user.action" class="<%= sidebarCurrentPage.contains("/admin/user") ? "active" : "" %>">&#9632; 用户管理</a>
      <a href="<%= ctx %>/admin/announcements.jsp" class="<%= sidebarCurrentPage.contains("/admin/announcements") ? "active" : "" %>">&#9632; 公告管理</a>
      <a href="<%= ctx %>/admin/defenses.jsp" class="<%= sidebarCurrentPage.contains("/admin/defenses") ? "active" : "" %>">&#9632; 答辩安排</a>
      <a href="<%= ctx %>/admin/statistics.jsp" class="<%= sidebarCurrentPage.contains("/admin/statistics") ? "active" : "" %>">&#9632; 数据统计</a>
      <a href="<%= ctx %>/admin/messages.jsp" class="<%= sidebarCurrentPage.contains("/messages") ? "active" : "" %>">&#9632; 站内消息<% if (unreadMsg > 0) { %> <span class="badge bg-danger"><%= unreadMsg %></span><% } %></a>
      <a href="<%= ctx %>/admin/logs.jsp" class="<%= sidebarCurrentPage.contains("/admin/logs") ? "active" : "" %>">&#9632; 操作日志</a>
    <% } else if ("teacher".equals(userRole)) { %>
      <a href="<%= ctx %>/teacher/topic.action" class="<%= sidebarCurrentPage.contains("/teacher/topic") ? "active" : "" %>">&#9632; 我的课题</a>
      <a href="<%= ctx %>/teacher/selection.action" class="<%= sidebarCurrentPage.contains("/teacher/selection") ? "active" : "" %>">&#9632; 选题审批</a>
      <a href="<%= ctx %>/teacher/document.action" class="<%= sidebarCurrentPage.contains("/teacher/document") ? "active" : "" %>">&#9632; 文档审核</a>
      <a href="<%= ctx %>/teacher/students.jsp" class="<%= sidebarCurrentPage.contains("/teacher/students") ? "active" : "" %>">&#9632; 学生进度</a>
      <a href="<%= ctx %>/teacher/defense.jsp" class="<%= sidebarCurrentPage.contains("/teacher/defense") ? "active" : "" %>">&#9632; 答辩安排</a>
      <a href="<%= ctx %>/teacher/messages.jsp" class="<%= sidebarCurrentPage.contains("/messages") ? "active" : "" %>">&#9632; 站内消息<% if (unreadMsg > 0) { %> <span class="badge bg-danger"><%= unreadMsg %></span><% } %></a>
    <% } else { %>
      <a href="<%= ctx %>/student/topic.action" class="<%= sidebarCurrentPage.contains("/student/topic") ? "active" : "" %>">&#9632; 浏览课题</a>
      <a href="<%= ctx %>/student/my-selection.jsp" class="<%= sidebarCurrentPage.contains("/student/my-selection") ? "active" : "" %>">&#9632; 我的选题</a>
      <a href="<%= ctx %>/student/document.action" class="<%= sidebarCurrentPage.contains("/student/document") ? "active" : "" %>">&#9632; 文档提交</a>
      <a href="<%= ctx %>/student/grades.jsp" class="<%= sidebarCurrentPage.contains("/student/grades") ? "active" : "" %>">&#9632; 我的成绩</a>
      <a href="<%= ctx %>/student/defense.jsp" class="<%= sidebarCurrentPage.contains("/student/defense") ? "active" : "" %>">&#9632; 我的答辩</a>
      <a href="<%= ctx %>/student/messages.jsp" class="<%= sidebarCurrentPage.contains("/messages") ? "active" : "" %>">&#9632; 站内消息<% if (unreadMsg > 0) { %> <span class="badge bg-danger"><%= unreadMsg %></span><% } %></a>
    <% } %>
  </nav>
</div>
<div class="main-content">
  <div class="topbar">
    <div>
      <button class="btn btn-sm btn-outline-secondary d-md-none" onclick="document.getElementById('sidebar').classList.toggle('show')">菜单</button>
      <span class="breadcrumb ms-2"><%= request.getAttribute("pageTitle") %></span>
    </div>
    <div class="user-info">
      <strong><%= loginUser.getRealName() %></strong>
      <span class="text-muted">(<%= DictionaryUtil.label("role", userRole) %>)</span>
      &nbsp;|&nbsp;
      <a href="<%= ctx %>/logout.action" class="text-decoration-none">退出</a>
    </div>
  </div>
  <div class="page-body">
