<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User" %>
<%
  request.setAttribute("pageTitle", "学生 AI 助手");
  request.setAttribute("aiRole", "student");
  request.setAttribute("aiRoleName", "学生");
  request.setAttribute("aiAction", "ai.action");
  request.setAttribute("aiPrompts", new String[] {
    "帮我写一段选题申请理由",
    "帮我把开题报告研究内容整理成三点",
    "中期检查需要准备哪些材料",
    "帮我准备毕业设计答辩自我陈述"
  });
  User loginUser = (User) session.getAttribute("loginUser");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>
<%@ include file="/WEB-INF/includes/ai-assistant-panel.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
