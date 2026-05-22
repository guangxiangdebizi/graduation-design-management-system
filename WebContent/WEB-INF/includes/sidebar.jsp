<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
  String ctx = request.getContextPath();
  String currentPage = request.getRequestURI();
  String userRole = loginUser.getRole();
%>
<div class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    毕业设计管理系统
    <small>Graduation Design</small>
  </div>
  <nav class="sidebar-nav">
    <a href="<%= ctx %>/dashboard.jsp" class="<%= currentPage.endsWith("dashboard.jsp") ? "active" : "" %>">&#9632; 仪表盘</a>
    <% if ("admin".equals(userRole)) { %>
      <a href="<%= ctx %>/admin/users.jsp" class="<%= currentPage.contains("/admin/users") ? "active" : "" %>">&#9632; 用户管理</a>
      <a href="<%= ctx %>/admin/announcements.jsp" class="<%= currentPage.contains("/admin/announcements") ? "active" : "" %>">&#9632; 公告管理</a>
    <% } else if ("teacher".equals(userRole)) { %>
      <a href="<%= ctx %>/teacher/topics.jsp" class="<%= currentPage.contains("/teacher/topics") ? "active" : "" %>">&#9632; 我的课题</a>
      <a href="<%= ctx %>/teacher/selections.jsp" class="<%= currentPage.contains("/teacher/selections") ? "active" : "" %>">&#9632; 选题审批</a>
      <a href="<%= ctx %>/teacher/documents.jsp" class="<%= currentPage.contains("/teacher/documents") ? "active" : "" %>">&#9632; 文档审核</a>
      <a href="<%= ctx %>/teacher/students.jsp" class="<%= currentPage.contains("/teacher/students") ? "active" : "" %>">&#9632; 学生进度</a>
    <% } else { %>
      <a href="<%= ctx %>/student/topics.jsp" class="<%= currentPage.contains("/student/topics") ? "active" : "" %>">&#9632; 浏览课题</a>
      <a href="<%= ctx %>/student/my-selection.jsp" class="<%= currentPage.contains("/student/my-selection") ? "active" : "" %>">&#9632; 我的选题</a>
      <a href="<%= ctx %>/student/documents.jsp" class="<%= currentPage.contains("/student/documents") ? "active" : "" %>">&#9632; 文档提交</a>
      <a href="<%= ctx %>/student/grades.jsp" class="<%= currentPage.contains("/student/grades") ? "active" : "" %>">&#9632; 我的成绩</a>
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
      <span class="text-muted">(<%= "admin".equals(userRole)?"管理员":("teacher".equals(userRole)?"教师":"学生") %>)</span>
      &nbsp;|&nbsp;
      <a href="<%= ctx %>/logout.action" class="text-decoration-none">退出</a>
    </div>
  </div>
  <div class="page-body">
