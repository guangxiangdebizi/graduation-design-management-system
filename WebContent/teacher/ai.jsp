<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User" %>
<%
  request.setAttribute("pageTitle", "教师 AI 助手");
  request.setAttribute("aiRole", "teacher");
  request.setAttribute("aiRoleName", "教师");
  request.setAttribute("aiAction", "ai.action");
  request.setAttribute("aiPrompts", new String[] {
    "帮我优化一个毕业设计课题名称和描述",
    "帮我写一段选题审批意见",
    "学生开题报告内容偏空，我该如何给修改建议",
    "答辩前教师端应该重点检查哪些学生进度"
  });
  User loginUser = (User) session.getAttribute("loginUser");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>
<%@ include file="/WEB-INF/includes/ai-assistant-panel.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
