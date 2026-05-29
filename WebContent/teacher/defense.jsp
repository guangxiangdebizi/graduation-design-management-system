<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "答辩安排");
  User loginUser = (User) session.getAttribute("loginUser");
  DefenseScheduleDao dao = new DefenseScheduleDao();
  List<DefenseSchedule> schedules = dao.findByTeacher(loginUser.getId());
  SimpleDateFormat display = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <h5>所带学生答辩安排</h5>
  <table class="table-modern mt-3">
    <tr><th>学号</th><th>姓名</th><th>课题</th><th>答辩时间</th><th>教室</th><th>分组</th><th>答辩分</th><th>备注</th></tr>
    <% if (schedules.isEmpty()) { %>
      <tr><td colspan="8" class="text-center text-muted py-4">暂无答辩安排</td></tr>
    <% } else { for (DefenseSchedule d : schedules) { %>
    <tr>
      <td><%= d.getStudentNo()==null?"—":d.getStudentNo() %></td>
      <td><%= EscapeUtil.html(d.getStudentName()) %></td>
      <td><%= d.getTopicTitle()==null?"—":EscapeUtil.html(d.getTopicTitle()) %></td>
      <td><%= d.getDefenseTime()==null?"待定":display.format(d.getDefenseTime()) %></td>
      <td><%= d.getRoom()==null?"—":EscapeUtil.html(d.getRoom()) %></td>
      <td><%= d.getGroupName()==null?"—":EscapeUtil.html(d.getGroupName()) %></td>
      <td><%= d.getScore()==null?"—":d.getScore() %></td>
      <td><%= d.getComment()==null?"—":EscapeUtil.html(d.getComment()) %></td>
    </tr>
    <% }} %>
  </table>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
