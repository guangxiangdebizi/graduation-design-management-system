<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "我的答辩");
  User loginUser = (User) session.getAttribute("loginUser");
  DefenseSchedule schedule = (DefenseSchedule) request.getAttribute("schedule");
  if (!Boolean.TRUE.equals(request.getAttribute("scheduleLoaded"))) {
    response.sendRedirect(request.getContextPath() + "/student/defense.action");
    return;
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <% if (schedule == null) { %>
    <div class="empty-state">
      <div class="icon">&#128197;</div>
      <p>您的答辩教师尚未安排。终稿/结题材料通过后，由系主任指定三名答辩教师。</p>
    </div>
  <% } else { %>
    <h5>答辩信息</h5>
    <table class="table-modern mt-3" style="max-width:760px">
      <tr><th style="width:140px">课题</th><td><%= schedule.getTopicTitle()==null?"—":EscapeUtil.html(schedule.getTopicTitle()) %></td></tr>
      <tr><th>指导教师</th><td><%= schedule.getTeacherName()==null?"—":EscapeUtil.html(schedule.getTeacherName()) %></td></tr>
      <tr>
        <th>答辩教师</th>
        <td>
          <% if (schedule.getCommitteeMembers().isEmpty()) { %>
            <span class="text-muted">尚未指定</span>
          <% } else { for (User t : schedule.getCommitteeMembers()) { %>
            <span class="badge bg-secondary me-1"><%= EscapeUtil.html(t.getRealName()) %></span>
          <% }} %>
        </td>
      </tr>
      <tr><th>评分进度</th><td><%= schedule.getScoreCount() %>/3</td></tr>
      <tr><th>答辩成绩</th><td><%= schedule.getAverageScore()==null?"待评定":schedule.getAverageScore() + " 分" %></td></tr>
      <tr><th>答辩结果</th><td><%= defenseResultBadge(schedule.getScoreCount(), schedule.getAverageScore()) %></td></tr>
    </table>

    <div class="content-card mt-3 p-0">
      <table class="table-modern mb-0">
        <tr><th>评分教师</th><th>分数</th><th>评分时间</th><th>意见</th></tr>
        <% if (schedule.getScores().isEmpty()) { %>
          <tr><td colspan="4" class="text-center text-muted py-3">暂无教师评分</td></tr>
        <% } else { for (DefenseScore s : schedule.getScores()) { %>
          <tr>
            <td><%= EscapeUtil.html(s.getTeacherName()) %></td>
            <td><%= s.getScore()==null?"—":s.getScore() + " 分" %></td>
            <td><%= s.getScoreTime()==null?"—":sdf.format(s.getScoreTime()) %></td>
            <td><%= s.getComment()==null?"—":EscapeUtil.html(s.getComment()) %></td>
          </tr>
        <% }} %>
      </table>
    </div>
  <% } %>
</div>

<%!
  private String defenseResultBadge(int scoreCount, BigDecimal averageScore) {
    if (scoreCount < 3 || averageScore == null) {
      return "<span class=\"text-muted\">三名教师评分完成后出结果，60 分及以上通过</span>";
    }
    if (averageScore.compareTo(new BigDecimal("60")) >= 0) {
      return "<span class=\"badge-status badge-reviewed\">通过</span>";
    }
    return "<span class=\"badge-status badge-rejected\">未通过</span>";
  }
%>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
