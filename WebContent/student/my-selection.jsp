<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "我的选题");
  User loginUser = (User) session.getAttribute("loginUser");
  TopicAssignment assignment = (TopicAssignment) request.getAttribute("assignment");
  List<SelectionChoice> choices = (List<SelectionChoice>) request.getAttribute("choices");
  List<TopicSelection> list = (List<TopicSelection>) request.getAttribute("selections");
  if (list == null || choices == null) {
    response.sendRedirect(request.getContextPath() + "/student/my-selection.action");
    return;
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (assignment != null) { %>
    <h5 class="mb-3">最终确认结果</h5>
    <table class="table-modern">
      <tr><th>课题</th><th>指导教师</th><th>来源</th><th>确认人</th><th>确认时间</th><th>确认意见</th></tr>
      <tr>
        <td><%= EscapeUtil.html(assignment.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(assignment.getTeacherName()) %></td>
        <td><%= EscapeUtil.html(assignment.getSource()) %></td>
        <td><%= EscapeUtil.html(assignment.getConfirmerName()) %></td>
        <td><%= assignment.getConfirmTime()==null?"—":sdf.format(assignment.getConfirmTime()) %></td>
        <td><%= assignment.getConfirmComment()==null?"—":EscapeUtil.html(assignment.getConfirmComment()) %></td>
      </tr>
    </table>
  <% } else if (!choices.isEmpty()) { %>
    <h5 class="mb-3">三志愿填报记录</h5>
    <table class="table-modern">
      <tr><th>轮次</th><th>志愿顺序</th><th>课题</th><th>指导教师</th><th>提交时间</th><th>状态</th></tr>
      <% for (SelectionChoice c : choices) { %>
      <tr>
        <td>第 <%= c.getRound() %> 轮</td>
        <td>第 <%= c.getChoiceRank() %> 志愿</td>
        <td><%= EscapeUtil.html(c.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(c.getTeacherName()) %></td>
        <td><%= c.getCreatedAt()==null?"—":sdf.format(c.getCreatedAt()) %></td>
        <td><%= EscapeUtil.html(c.getStatus()) %></td>
      </tr>
      <% } %>
    </table>
    <div class="text-muted small mt-2">当前志愿需要对应课题指导教师接收后，才会成为最终毕业设计题目。</div>
  <% } else if (list.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">&#128221;</div>
      <p>您还没有提交选题志愿</p>
      <a href="topic.action" class="btn btn-primary btn-sm">去浏览课题并填报志愿</a>
    </div>
  <% } else { %>
    <h5 class="mb-3">旧选题申请记录</h5>
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
