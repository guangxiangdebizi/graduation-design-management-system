<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,bean.User,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "本专业资料进度");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Object[]> rows = (List<Object[]>) request.getAttribute("progressRows");
  String directorScopeText = (String) request.getAttribute("directorScopeText");
  if (rows == null) {
    response.sendRedirect(request.getContextPath() + "/director/document-progress.action");
    return;
  }
  if (directorScopeText == null) directorScopeText = "";
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="alert alert-info py-2">
  当前范围：<%= EscapeUtil.html(directorScopeText) %>。本页用于查看本专业学生开题、中期、终稿/结题材料进度；具体文档审核仍由指导教师完成。
</div>

<div class="content-card">
  <% if (rows.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>本专业暂无已最终确认题目的学生</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr>
        <th>学生</th><th>学号</th><th>班级</th><th>课题</th><th>指导教师</th>
        <th>开题报告</th><th>中期检查</th><th>终稿/结题</th><th>最终成绩</th>
      </tr>
      <% for (Object[] r : rows) { %>
        <tr>
          <td><%= EscapeUtil.html((String) r[1]) %></td>
          <td><%= EscapeUtil.html((String) r[0]) %></td>
          <td><%= r[2]==null?"—":EscapeUtil.html(String.valueOf(r[2])) %></td>
          <td><%= EscapeUtil.html((String) r[3]) %></td>
          <td><%= EscapeUtil.html((String) r[4]) %></td>
          <td><%= stageCell(r[5], r[6], r[7], sdf) %></td>
          <td><%= stageCell(r[8], r[9], r[10], sdf) %></td>
          <td><%= stageCell(r[11], r[13], r[14], sdf) %></td>
          <td><%= r[12]==null?"—":EscapeUtil.html(String.valueOf(r[12])) + " 分" %></td>
        </tr>
      <% } %>
    </table>
  <% } %>
</div>

<%!
  private String stageCell(Object statusObj, Object submitObj, Object reviewObj, SimpleDateFormat sdf) {
    if (statusObj == null) {
      return "<span class=\"text-muted\">未提交</span>";
    }
    String status = String.valueOf(statusObj);
    StringBuilder sb = new StringBuilder();
    sb.append(EscapeUtil.html(StatusUtil.label(status)));
    if (submitObj != null) {
      sb.append("<div class=\"text-muted small\">提交：").append(sdf.format(submitObj)).append("</div>");
    }
    if (reviewObj != null) {
      sb.append("<div class=\"text-muted small\">审核：").append(sdf.format(reviewObj)).append("</div>");
    }
    return sb.toString();
  }
%>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
