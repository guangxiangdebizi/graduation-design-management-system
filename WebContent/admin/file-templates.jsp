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
  request.setAttribute("pageTitle", "文件模板管理");
  User loginUser = (User) session.getAttribute("loginUser");
  List<FileTemplate> templates = (List<FileTemplate>) request.getAttribute("templates");
  Map<String, String> typeNames = (Map<String, String>) request.getAttribute("typeNames");
  Integer totalAttr = (Integer) request.getAttribute("total");
  Integer pageAttr = (Integer) request.getAttribute("currentPage");
  Integer pageSizeAttr = (Integer) request.getAttribute("pageSize");
  String typeFilter = (String) request.getAttribute("typeFilter");
  if (templates == null || typeNames == null) {
    response.sendRedirect(request.getContextPath() + "/admin/file-template.action");
    return;
  }
  int currentPage = pageAttr != null ? pageAttr : 1;
  int pageSize = pageSizeAttr != null ? pageSizeAttr : 10;
  int total = totalAttr != null ? totalAttr : 0;
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  String pagUrl = "file-template.action" + (typeFilter != null ? "?type=" + typeFilter : "");
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("upload_ok".equals(msg)) { msgTitle="成功"; msgContent="模板上传成功"; msgClass="success"; }
  else if ("delete_ok".equals(msg)) { msgTitle="成功"; msgContent="模板删除成功"; msgClass="success"; }
  else if ("template_name_empty".equals(msg)) { msgTitle="错误"; msgContent="模板名称不能为空"; msgClass="danger"; }
  else if ("template_file_empty".equals(msg)) { msgTitle="错误"; msgContent="请选择要上传的模板文件"; msgClass="danger"; }
  else if ("upload_invalid".equals(msg)) { msgTitle="错误"; msgContent="文件类型或大小不符合上传配置"; msgClass="danger"; }
  else if ("delete_failed".equals(msg)) { msgTitle="失败"; msgContent="模板删除失败"; msgClass="danger"; }
  else if ("error".equals(msg)) { msgTitle="失败"; msgContent="操作失败，请重试"; msgClass="danger"; }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (!msgTitle.isEmpty()) { %>
<div class="alert alert-<%= msgClass %> alert-dismissible fade show" role="alert">
  <strong><%= msgTitle %>：</strong><%= msgContent %>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="d-flex justify-content-between align-items-center mb-3">
  <div class="d-flex gap-2 flex-wrap">
    <a href="file-template.action" class="btn btn-sm <%= typeFilter==null?"btn-primary":"btn-outline-primary" %>">全部模板</a>
    <% for (Map.Entry<String, String> e : typeNames.entrySet()) { %>
      <a href="file-template.action?type=<%= e.getKey() %>" class="btn btn-sm <%= e.getKey().equals(typeFilter)?"btn-primary":"btn-outline-primary" %>"><%= EscapeUtil.html(e.getValue()) %></a>
    <% } %>
  </div>
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#uploadModal">+ 上传模板</button>
</div>

<div class="content-card">
  <% if (templates.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>暂无文件模板</p></div>
  <% } else { %>
  <table class="table-modern">
    <tr><th>模板名称</th><th>类型</th><th>原文件名</th><th>大小</th><th>上传人</th><th>上传时间</th><th>说明</th><th>操作</th></tr>
    <% for (FileTemplate t : templates) { %>
    <tr>
      <td><%= EscapeUtil.html(t.getTemplateName()) %></td>
      <td><span class="badge bg-info"><%= t.getDocType()==null ? "通用" : EscapeUtil.html(DictionaryUtil.label("document_type", t.getDocType())) %></span></td>
      <td><%= EscapeUtil.html(t.getOriginalFilename()) %></td>
      <td><%= fmtSize(t.getFileSize()) %></td>
      <td><%= EscapeUtil.html(t.getUploaderName()) %></td>
      <td><%= t.getCreatedAt()!=null?sdf.format(t.getCreatedAt()):"—" %></td>
      <td><%= t.getDescription()==null || t.getDescription().isEmpty() ? "—" : EscapeUtil.html(t.getDescription()) %></td>
      <td>
        <a class="btn btn-sm btn-outline-success" href="../file-template-download.action?id=<%= t.getId() %>">下载</a>
        <form id="delTpl<%= t.getId() %>" action="../admin/file-template.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= t.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delTpl<%= t.getId() %>','确定删除模板 <%= EscapeUtil.js(t.getTemplateName()) %> 吗？')">删除</button>
        </form>
      </td>
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

<div class="modal fade" id="uploadModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/file-template.action" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="upload">
      <div class="modal-header"><h6 class="modal-title">上传文件模板</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">模板名称 *</label><input name="templateName" class="form-control form-control-sm" required maxlength="100"></div>
        <div class="mb-2"><label class="form-label">文档类型</label>
          <select name="docType" class="form-select form-select-sm">
            <option value="">通用模板</option>
            <% for (Map.Entry<String, String> e : typeNames.entrySet()) { %>
              <option value="<%= e.getKey() %>"><%= EscapeUtil.html(e.getValue()) %></option>
            <% } %>
          </select>
        </div>
        <div class="mb-2"><label class="form-label">模板文件 *</label><input type="file" name="file" class="form-control form-control-sm" accept=".pdf,.doc,.docx,.zip,.rar" required></div>
        <div class="mb-2"><label class="form-label">说明</label><textarea name="description" class="form-control form-control-sm" rows="3" maxlength="500"></textarea></div>
        <div class="text-muted small">支持 pdf/doc/docx/zip/rar，大小限制沿用系统上传配置。</div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">上传</button></div>
    </form>
  </div></div>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
