<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.DictionaryUtil" %>
<%!
  private String fmtSize(long size) {
    if (size >= 1024L * 1024L) return String.format("%.2f MB", size / 1024.0 / 1024.0);
    if (size >= 1024L) return String.format("%.1f KB", size / 1024.0);
    return size + " B";
  }
%>
<%
  request.setAttribute("pageTitle", "模板下载");
  User loginUser = (User) session.getAttribute("loginUser");
  List<FileTemplate> templates = (List<FileTemplate>) request.getAttribute("templates");
  Map<String, String> typeNames = (Map<String, String>) request.getAttribute("typeNames");
  Integer totalAttr = (Integer) request.getAttribute("total");
  Integer pageAttr = (Integer) request.getAttribute("currentPage");
  Integer pageSizeAttr = (Integer) request.getAttribute("pageSize");
  String typeFilter = (String) request.getAttribute("typeFilter");
  if (templates == null || typeNames == null) {
    response.sendRedirect(request.getContextPath() + "/student/file-template.action");
    return;
  }
  int currentPage = pageAttr != null ? pageAttr : 1;
  int pageSize = pageSizeAttr != null ? pageSizeAttr : 10;
  int total = totalAttr != null ? totalAttr : 0;
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  String pagUrl = "file-template.action" + (typeFilter != null ? "?type=" + typeFilter : "");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex gap-2 flex-wrap mb-3">
  <a href="file-template.action" class="btn btn-sm <%= typeFilter==null?"btn-primary":"btn-outline-primary" %>">全部模板</a>
  <% for (Map.Entry<String, String> e : typeNames.entrySet()) { %>
    <a href="file-template.action?type=<%= e.getKey() %>" class="btn btn-sm <%= e.getKey().equals(typeFilter)?"btn-primary":"btn-outline-primary" %>"><%= EscapeUtil.html(e.getValue()) %></a>
  <% } %>
</div>

<div class="content-card">
  <% if (templates.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>暂无可下载模板</p></div>
  <% } else { %>
  <table class="table-modern">
    <tr><th>模板名称</th><th>类型</th><th>文件名</th><th>大小</th><th>上传人</th><th>上传时间</th><th>说明</th><th>操作</th></tr>
    <% for (FileTemplate t : templates) { %>
    <tr>
      <td><%= EscapeUtil.html(t.getTemplateName()) %></td>
      <td><span class="badge bg-info"><%= t.getDocType()==null ? "通用" : EscapeUtil.html(DictionaryUtil.label("document_type", t.getDocType())) %></span></td>
      <td><%= EscapeUtil.html(t.getOriginalFilename()) %></td>
      <td><%= fmtSize(t.getFileSize()) %></td>
      <td><%= EscapeUtil.html(t.getUploaderName()) %></td>
      <td><%= t.getCreatedAt()!=null?sdf.format(t.getCreatedAt()):"—" %></td>
      <td><%= t.getDescription()==null || t.getDescription().isEmpty() ? "—" : EscapeUtil.html(t.getDescription()) %></td>
      <td><a class="btn btn-sm btn-outline-success" href="../file-template-download.action?id=<%= t.getId() %>">下载</a></td>
    </tr>
    <% } %>
  </table>
  <% } %>
  <% request.setAttribute("baseUrl", pagUrl);
     request.setAttribute("page", currentPage);
     request.setAttribute("pageSize", pageSize);
     request.setAttribute("total", total); %>
  <%@ include file="/WEB-INF/includes/pagination.jsp" %>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
