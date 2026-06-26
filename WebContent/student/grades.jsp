<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
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
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="stat-cards mb-3">
  <div class="stat-card">
    <span class="icon">&#127942;</span>
    <div class="label">最终成绩</div>
    <div class="value" style="font-size:1.1rem;"><%= finalDoc!=null && finalDoc.getScore()!=null ? finalDoc.getScore()+" 分" : "待评定" %></div>
  </div>
  <div class="stat-card">
    <span class="icon">&#128196;</span>
    <div class="label">终稿/结题状态</div>
    <div class="value" style="font-size:1.1rem;"><%= finalDoc==null ? "未提交" : util.StatusUtil.label(finalDoc.getStatus()) %></div>
  </div>
</div>

<div class="content-card">
  <% if (docs.isEmpty() && defense == null) { %>
    <div class="empty-state"><div class="icon">&#128200;</div><p>暂无成绩记录，请先提交文档</p></div>
  <% } else { %>
    <div class="alert alert-info py-2">简化版成绩规则：开题报告和中期检查只作为阶段审核；终稿/结题材料审核通过后的成绩作为最终成绩。</div>
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
        <td><%= defense.getDefenseTime()!=null?sdf.format(defense.getDefenseTime()):"—" %></td>
        <td><span class="badge-status badge-reviewed">已安排</span></td>
        <td><span class="text-muted">答辩记录，不参与当前简化版最终成绩</span></td>
        <td><%= defense.getComment()==null?"—":EscapeUtil.html(defense.getComment()) %></td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
