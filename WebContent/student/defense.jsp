<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "我的答辩");
  User loginUser = (User) session.getAttribute("loginUser");
  DefenseScheduleDao dao = new DefenseScheduleDao();
  DefenseSchedule schedule = dao.findByStudent(loginUser.getId());
  SimpleDateFormat display = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (schedule == null) { %>
    <div class="empty-state">
      <div class="icon">&#128197;</div>
      <p>您的答辩安排尚未发布，请关注系统公告</p>
    </div>
  <% } else { %>
    <h5>答辩安排详情</h5>
    <table class="table-modern mt-3" style="max-width:600px">
      <tr><th style="width:120px">课题</th><td><%= schedule.getTopicTitle()==null?"—":EscapeUtil.html(schedule.getTopicTitle()) %></td></tr>
      <tr><th>指导教师</th><td><%= schedule.getTeacherName()==null?"—":EscapeUtil.html(schedule.getTeacherName()) %></td></tr>
      <tr><th>答辩时间</th><td><%= schedule.getDefenseTime()==null?"待定":display.format(schedule.getDefenseTime()) %></td></tr>
      <tr><th>答辩教室</th><td><%= schedule.getRoom()==null?"待定":EscapeUtil.html(schedule.getRoom()) %></td></tr>
      <tr><th>答辩分组</th><td><%= schedule.getGroupName()==null?"—":EscapeUtil.html(schedule.getGroupName()) %></td></tr>
      <tr><th>答辩成绩</th><td><%= schedule.getScore()==null?"待评定":schedule.getScore() %></td></tr>
      <tr><th>备注</th><td><%= schedule.getComment()==null?"—":EscapeUtil.html(schedule.getComment()) %></td></tr>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
