<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>

<%

  request.setAttribute("pageTitle", "文档提交");

  User loginUser = (User) session.getAttribute("loginUser");

  java.util.Map<String,String> typeNames =
      (java.util.Map<String,String>) request.getAttribute("typeNames");
  TopicSelection approved = (TopicSelection) request.getAttribute("approvedSelection");
  String activeType = (String) request.getAttribute("activeType");
  Document currentDoc = (Document) request.getAttribute("currentDocument");
  List<DocumentVersion> versions =
      (List<DocumentVersion>) request.getAttribute("documentVersions");
  String uploadAccept = (String) request.getAttribute("uploadAccept");
  Boolean uploadOpenAttr = (Boolean) request.getAttribute("uploadOpen");
  boolean uploadOpen = uploadOpenAttr == null || uploadOpenAttr.booleanValue();
  if (uploadAccept == null) uploadAccept = ".pdf,.doc,.docx,.zip,.rar";
  if (typeNames == null || versions == null) {
    response.sendRedirect(request.getContextPath() + "/student/document.action");
    return;
  }

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

%>

<%@ include file="/WEB-INF/includes/header.jsp" %>

<div class="app-layout">

<%@ include file="/WEB-INF/includes/sidebar.jsp" %>



<% if (approved == null) { %>

  <div class="content-card">

    <div class="empty-state">

      <div class="icon">&#9888;</div>

      <p>您还没有最终确认的毕业设计题目，无法提交阶段资料</p>

      <a href="topic.action" class="btn btn-primary btn-sm">去申请选题</a>

    </div>

  </div>

<% } else { %>



<ul class="nav nav-tabs nav-tabs-modern">

  <% for (java.util.Map.Entry<String,String> e : typeNames.entrySet()) { %>

    <li class="nav-item"><a class="nav-link <%= activeType.equals(e.getKey())?"active":"" %>" href="document.action?type=<%= e.getKey() %>"><%= e.getValue() %></a></li>

  <% } %>

</ul>



<div class="content-card">

  <p class="text-muted small mb-3">当前课题: <strong><%= EscapeUtil.html(approved.getTopicTitle()) %></strong> | 指导教师: <%= EscapeUtil.html(approved.getTeacherName()) %></p>
  <div class="alert alert-info py-2">
    资料按阶段提交：开题报告通过后才能提交中期检查；中期检查通过后才能提交终稿/结题材料。开题和中期只做阶段审核；终稿通过后形成指导教师评分，系主任另行安排评阅教师评分，答辩成绩由三名答辩教师评分取平均。
  </div>

  <% if (!uploadOpen) { %>

    <div class="alert alert-warning py-2">当前阶段上传入口已关闭，暂不能提交或重交<%= typeNames.get(activeType) %>。</div>

  <% } %>

  <% if (currentDoc != null && !"draft".equals(currentDoc.getStatus())) { %>

    <div class="alert alert-info py-2">

      已提交 — 状态: <% request.setAttribute("status", currentDoc.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %>

      <% if (currentDoc.getAdvisorScore()!=null) { %> | 指导教师评分: <%= currentDoc.getAdvisorScore() %><% } %>

      <% if (currentDoc.getAdvisorComment()!=null) { %> | 指导教师评语: <%= EscapeUtil.html(currentDoc.getAdvisorComment()) %><% } else if (currentDoc.getFeedback()!=null) { %> | 反馈: <%= EscapeUtil.html(currentDoc.getFeedback()) %><% } %>

    </div>

  <% } %>

  <form action="../student/document.action" method="post" enctype="multipart/form-data">

    <input type="hidden" name="docType" value="<%= activeType %>">

    <div class="mb-2">

      <label class="form-label">文档标题</label>

      <input name="title" class="form-control form-control-sm" value="<%= currentDoc!=null?EscapeUtil.attr(currentDoc.getTitle()):"" %>" placeholder="请输入<%= typeNames.get(activeType) %>标题" required <%= uploadOpen ? "" : "disabled" %>>

    </div>

    <div class="mb-2">

      <label class="form-label">文档内容</label>

      <textarea name="content" class="form-control" rows="8" placeholder="请输入文档正文内容..." required <%= uploadOpen ? "" : "disabled" %>><% if (currentDoc!=null && currentDoc.getContent()!=null) { %><%= EscapeUtil.html(currentDoc.getContent()) %><% } %></textarea>

    </div>

    <div class="mb-3">

      <label class="form-label">上传附件</label>

      <input type="file" name="file" class="form-control form-control-sm" accept="<%= EscapeUtil.attr(uploadAccept) %>" <%= uploadOpen ? "" : "disabled" %>>

      <% if (currentDoc!=null && currentDoc.getFilePath()!=null && currentDoc.getFilePath().length()>0) { %>

        <div class="mt-1 small">当前附件: <a href="../download.action?path=<%= java.net.URLEncoder.encode(currentDoc.getFilePath().startsWith("/")?currentDoc.getFilePath().substring(1):currentDoc.getFilePath(),"UTF-8") %>"><%= EscapeUtil.html(currentDoc.getFilePath()) %></a>（重新上传将覆盖）</div>

      <% } %>

    </div>

    <button type="submit" class="btn btn-primary btn-sm" <%= uploadOpen ? "" : "disabled" %>>提交文档</button>

  </form>

</div>



<% if (!versions.isEmpty()) { %>

<div class="content-card mt-3">

  <h6>版本历史</h6>

  <table class="table-modern">

    <tr><th>版本</th><th>标题</th><th>提交时间</th><th>附件</th></tr>

    <% for (DocumentVersion v : versions) { %>

    <tr>

      <td>v<%= v.getVersionNo() %></td>

      <td><%= EscapeUtil.html(v.getTitle()) %></td>

      <td><%= v.getSubmitTime()!=null?sdf.format(v.getSubmitTime()):"—" %></td>

      <td><% if (v.getFilePath()!=null && v.getFilePath().length()>0) { %>

        <a href="../download.action?path=<%= java.net.URLEncoder.encode(v.getFilePath().startsWith("/")?v.getFilePath().substring(1):v.getFilePath(),"UTF-8") %>">下载</a>

      <% } else { %>—<% } %></td>

    </tr>

    <% } %>

  </table>

</div>

<% } %>



<% } %>



<%@ include file="/WEB-INF/includes/footer.jsp" %>

