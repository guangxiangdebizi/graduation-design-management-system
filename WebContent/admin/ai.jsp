<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User" %>
<%
  request.setAttribute("pageTitle", "管理员 AI 助手");
  request.setAttribute("aiRole", "admin");
  request.setAttribute("aiRoleName", "管理员");
  request.setAttribute("aiAction", "ai.action");
  request.setAttribute("aiPrompts", new String[] {
    "帮我生成一条毕业设计答辩安排公告",
    "帮我检查系统管理员演示时应该重点展示哪些功能",
    "用户管理、公告、答辩安排、统计这些模块怎么向老师说明",
    "如果老师问系统权限和日志审计怎么回答"
  });
  User loginUser = (User) session.getAttribute("loginUser");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>
<%@ include file="/WEB-INF/includes/ai-assistant-panel.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
