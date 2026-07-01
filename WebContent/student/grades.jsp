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
  BigDecimal advisorScore = finalDoc == null ? null : finalDoc.getAdvisorScore();
  BigDecimal reviewerScore = finalDoc == null ? null : finalDoc.getReviewerScore();
  BigDecimal defenseScore = defense == null ? null :
      (defense.getAverageScore() != null ? defense.getAverageScore() : defense.getScore());
  BigDecimal finalScore = null;
  String finalResult = "待评定";
  if (advisorScore != null && reviewerScore != null && defenseScore != null) {
    finalScore = advisorScore.multiply(new BigDecimal("0.4"))
        .add(reviewerScore.multiply(new BigDecimal("0.2")))
        .add(defenseScore.multiply(new BigDecimal("0.4")))
        .setScale(2, RoundingMode.HALF_UP);
    boolean defensePassed = defense != null && defense.getScoreCount() >= 3
        && defenseScore.compareTo(new BigDecimal("60")) >= 0;
    finalResult = defensePassed && finalScore.compareTo(new BigDecimal("60")) >= 0
        ? "通过" : "未通过";
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="stat-cards mb-3">
  <div class="stat-card">
    <span class="icon">&#127942;</span>
    <div class="label">最终成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= finalScore!=null ? finalScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128196;</span>
    <div class="label">指导教师评分</div>
    <div class="value" style="font-size:1.1rem;"><%= advisorScore!=null ? advisorScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128214;</span>
    <div class="label">评阅教师评分</div>
    <div class="value" style="font-size:1.1rem;"><%= reviewerScore!=null ? reviewerScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128483;</span>
    <div class="label">答辩成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= defenseScore!=null ? defenseScore+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#9989;</span>
    <div class="label">结课结果</div>
    <div class="value" style="font-size:1.1rem;"><%= finalResult %></div>
  </div>
</div>

<div class="content-card">
  <% if (docs.isEmpty() && defense == null) { %>
    <div class="empty-state"><div class="icon">&#128200;</div><p>暂无成绩记录，请先提交文档</p></div>
  <% } else { %>
    <div class="alert alert-info py-2">成绩规则：开题报告和中期检查只作为阶段审核；最终成绩 = 指导教师评分 40% + 评阅教师评分 20% + 答辩平均分 40%。答辩三人均分 60 分及以上视为通过；最终成绩和答辩均通过后可结课。</div>
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
            <div>指导教师：<%= d.getAdvisorScore()!=null ? d.getAdvisorScore()+" 分" : "待评定" %></div>
            <div>评阅教师：<%= d.getReviewerScore()!=null ? d.getReviewerScore()+" 分" : "待评阅" %></div>
          <% } else { %>
            <span class="text-muted">阶段审核，不计最终成绩</span>
          <% } %>
        </td>
        <td>
          <% if ("final".equals(d.getDocType())) { %>
            <div><strong>指导教师：</strong><%= d.getAdvisorComment()==null?"—":EscapeUtil.html(d.getAdvisorComment()) %></div>
            <div><strong>评阅教师：</strong><%= d.getReviewerComment()==null?"—":EscapeUtil.html(d.getReviewerComment()) %></div>
          <% } else { %>
            <%= d.getFeedback()==null?"—":EscapeUtil.html(d.getFeedback()) %>
          <% } %>
        </td>
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
