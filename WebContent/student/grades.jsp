<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.math.RoundingMode,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "我的成绩");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Document> docs = (List<Document>) request.getAttribute("docs");
  DefenseSchedule defense = (DefenseSchedule) request.getAttribute("defense");
  java.util.Map<String,String> typeNames = (java.util.Map<String,String>) request.getAttribute("typeNames");
  java.util.Map<String, Document> docMap = (java.util.Map<String, Document>) request.getAttribute("docMap");
  if (docs == null || typeNames == null || docMap == null) {
    response.sendRedirect(request.getContextPath() + "/student/grades.action");
    return;
  }
  Document finalDoc = docMap.get("final");
  BigDecimal finalScore = finalDoc == null ? null : finalDoc.getScore();
  BigDecimal defenseScore = defense == null ? null :
      (defense.getAverageScore() != null ? defense.getAverageScore() : defense.getScore());
  BigDecimal compositeScore = null;
  if (finalScore != null && defenseScore != null) {
    compositeScore = finalScore.multiply(new BigDecimal("0.6"))
        .add(defenseScore.multiply(new BigDecimal("0.4")))
        .setScale(2, RoundingMode.HALF_UP);
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="stat-cards mb-3">
  <div class="stat-card">
    <span class="icon">&#127942;</span>
    <div class="label">综合参考分</div>
    <div class="value" style="font-size:1.1rem;"><%= compositeScore!=null ? compositeScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128196;</span>
    <div class="label">终稿成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= finalScore!=null ? finalScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128483;</span>
    <div class="label">答辩成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= defenseScore!=null ? defenseScore+" 分" : "待评定" %></div>
  </div>
</div>

<div class="content-card">
  <% if (docs.isEmpty() && defense == null) { %>
    <div class="empty-state"><div class="icon">&#128200;</div><p>暂无成绩记录，请先提交文档</p></div>
  <% } else { %>
    <div class="alert alert-info py-2">成绩规则：开题报告和中期检查只作为阶段审核；终稿成绩由指导教师审核终稿/结题材料时填写；答辩成绩取三名答辩教师评分平均值，三人均分 60 分及以上视为通过；综合参考分 = 终稿成绩 60% + 答辩成绩 40%。</div>
    <table class="table-modern">
      <tr><th>阶段</th><th>标题</th><th>提交时间</th><th>状态</th><th>成绩/说明</th><th>教师意见</th></tr>
      <% for (Document d : docs) { %>
      <tr>
        <td><%= typeNames.get(d.getDocType()) %></td>
        <td><%= EscapeUtil.html(d.getTitle()) %></td>
        <td><%= d.getSubmitTime()!=null?sdf.format(d.getSubmitTime()):"—" %></td>
        <td><% request.setAttribute("status", d.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
        <td>
          <% if ("final".equals(d.getDocType())) { %>
            <% if (d.getScore()!=null) { %><%= d.getScore() %> 分<% } else { %><span class="text-muted">待评定</span><% } %>
          <% } else { %>
            <span class="text-muted">阶段审核，不计最终成绩</span>
          <% } %>
        </td>
        <td><%= d.getFeedback()==null?"—":EscapeUtil.html(d.getFeedback()) %></td>
      </tr>
      <% } %>
      <% if (defense != null) { %>
      <tr>
        <td>答辩</td>
        <td><%= defense.getTopicTitle()==null?"—":EscapeUtil.html(defense.getTopicTitle()) %></td>
        <td>—</td>
        <td>
          <span class="badge-status badge-reviewed">评分 <%= defense.getScoreCount() %>/3</span>
          <div class="mt-1"><%= defenseResultBadge(defense.getScoreCount(), defenseScore) %></div>
        </td>
        <td><%= defenseScore==null?"待评定":defenseScore + " 分" %></td>
        <td>
          <% if (defense.getCommitteeMembers().isEmpty()) { %>
            <span class="text-muted">尚未指定答辩教师</span>
          <% } else { for (User t : defense.getCommitteeMembers()) { %>
            <span class="badge bg-secondary me-1"><%= EscapeUtil.html(t.getRealName()) %></span>
          <% }} %>
        </td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%!
  private String defenseResultBadge(int scoreCount, BigDecimal defenseScore) {
    if (scoreCount < 3 || defenseScore == null) {
      return "<span class=\"text-muted\">未出结果</span>";
    }
    if (defenseScore.compareTo(new BigDecimal("60")) >= 0) {
      return "<span class=\"badge-status badge-reviewed\">通过</span>";
    }
    return "<span class=\"badge-status badge-rejected\">未通过</span>";
  }
%>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
