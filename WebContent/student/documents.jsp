<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*" %>
<%
  request.setAttribute("pageTitle", "文档提交");
  User loginUser = (User) session.getAttribute("loginUser");
  SelectionDao selDao = new SelectionDao();
  DocumentDao docDao = new DocumentDao();
  TopicSelection approved = selDao.findApprovedByStudent(loginUser.getId());
  String activeType = request.getParameter("type");
  if (activeType == null) activeType = "proposal";
  java.util.Map<String,String> typeNames = new java.util.LinkedHashMap<String,String>();
  typeNames.put("proposal", "开题报告");
  typeNames.put("midterm", "中期检查");
  typeNames.put("final", "终稿");
  Document currentDoc = approved != null ? docDao.findByStudentAndType(loginUser.getId(), activeType) : null;
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (approved == null) { %>
  <div class="content-card">
    <div class="empty-state">
      <div class="icon">&#9888;</div>
      <p>您还没有通过选题审批，无法提交文档</p>
      <a href="topics.jsp" class="btn btn-primary btn-sm">去申请选题</a>
    </div>
  </div>
<% } else { %>

<ul class="nav nav-tabs nav-tabs-modern">
  <% for (java.util.Map.Entry<String,String> e : typeNames.entrySet()) { %>
    <li class="nav-item"><a class="nav-link <%= activeType.equals(e.getKey())?"active":"" %>" href="?type=<%= e.getKey() %>"><%= e.getValue() %></a></li>
  <% } %>
</ul>

<div class="content-card">
  <p class="text-muted small mb-3">当前课题: <strong><%= approved.getTopicTitle() %></strong> | 指导教师: <%= approved.getTeacherName() %></p>
  <% if (currentDoc != null && !"draft".equals(currentDoc.getStatus())) { %>
    <div class="alert alert-info py-2">
      已提交 — 状态: <span class="badge-status badge-<%= currentDoc.getStatus() %>"><%= currentDoc.getStatus() %></span>
      <% if (currentDoc.getScore()!=null) { %> | 分数: <%= currentDoc.getScore() %><% } %>
      <% if (currentDoc.getFeedback()!=null) { %> | 反馈: <%= currentDoc.getFeedback() %><% } %>
    </div>
  <% } %>
  <form action="../student/document.action" method="post">
    <input type="hidden" name="docType" value="<%= activeType %>">
    <div class="mb-2">
      <label class="form-label">文档标题</label>
      <input name="title" class="form-control form-control-sm" value="<%= currentDoc!=null?currentDoc.getTitle():"" %>" placeholder="请输入<%= typeNames.get(activeType) %>标题" required>
    </div>
    <div class="mb-2">
      <label class="form-label">文档内容</label>
      <textarea name="content" class="form-control" rows="8" placeholder="请输入文档正文内容..." required><%= currentDoc!=null && currentDoc.getContent()!=null?currentDoc.getContent():"" %></textarea>
    </div>
    <div class="mb-3">
      <label class="form-label">附件路径（标准版填写文件路径，完整版支持上传）</label>
      <input name="filePath" class="form-control form-control-sm" value="<%= currentDoc!=null && currentDoc.getFilePath()!=null?currentDoc.getFilePath():"" %>" placeholder="如 /uploads/student01/proposal.pdf">
    </div>
    <button type="submit" class="btn btn-primary btn-sm">提交文档</button>
  </form>
</div>

<% } %>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
