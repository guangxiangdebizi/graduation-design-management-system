<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "文档审核");
  User loginUser = (User) session.getAttribute("loginUser");
  String docType = (String) request.getAttribute("docType");
  String statusFilter = (String) request.getAttribute("statusFilter");
  List<Document> list = (List<Document>) request.getAttribute("documents");
  java.util.Map<String,String> typeNames =
      (java.util.Map<String,String>) request.getAttribute("typeNames");
  if (list == null || typeNames == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/document.action");
    return;
  }
  String emptyText;
  if ("submitted".equals(statusFilter)) {
    emptyText = "暂无待审文档";
  } else if ("reviewed".equals(statusFilter)) {
    emptyText = "暂无已评阅文档";
  } else if ("rejected".equals(statusFilter)) {
    emptyText = "暂无已退回文档";
  } else {
    emptyText = "暂无文档记录";
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  boolean finalDocType = "final".equals(docType);
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<ul class="nav nav-tabs nav-tabs-modern">
  <% for (java.util.Map.Entry<String,String> e : typeNames.entrySet()) { %>
    <li class="nav-item"><a class="nav-link <%= docType.equals(e.getKey())?"active":"" %>" href="document.action?type=<%= e.getKey() %>&status=<%= statusFilter %>"><%= e.getValue() %></a></li>
  <% } %>
</ul>

<div class="mb-3">
  <a href="document.action?type=<%= docType %>&status=submitted" class="btn btn-sm <%= "submitted".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>"><%= StatusUtil.label("submitted") %></a>
  <a href="document.action?type=<%= docType %>&status=reviewed" class="btn btn-sm <%= "reviewed".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>"><%= StatusUtil.label("reviewed") %></a>
  <a href="document.action?type=<%= docType %>&status=rejected" class="btn btn-sm <%= "rejected".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>"><%= StatusUtil.label("rejected") %></a>
  <a href="document.action?type=<%= docType %>&status=all" class="btn btn-sm <%= "all".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">全部</a>
</div>

<div class="content-card">
  <% if (list.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p><%= EscapeUtil.html(emptyText) %></p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>学生</th><th>课题</th><th>标题</th><th>提交时间</th><th>状态</th><th><%= finalDocType ? "指导教师评分" : "阶段说明" %></th><th>操作</th></tr>
      <% for (Document d : list) { %>
      <tr>
        <td><%= EscapeUtil.html(d.getStudentName()) %></td>
        <td><%= EscapeUtil.html(d.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(d.getTitle()) %></td>
        <td><%= d.getSubmitTime()!=null?sdf.format(d.getSubmitTime()):"—" %></td>
        <td><% request.setAttribute("status", d.getStatus()); %><%@ include file="/WEB-INF/includes/status-badge.jsp" %></td>
        <td><%= finalDocType && d.getAdvisorScore()!=null ? d.getAdvisorScore() : "—" %></td>
        <td>
          <button class="btn btn-sm btn-outline-primary" onclick="viewDoc(<%= d.getId() %>,'<%= EscapeUtil.js(d.getStudentName()) %>','<%= EscapeUtil.js(d.getTitle()) %>','<%= EscapeUtil.js(d.getContent()==null?"":d.getContent()) %>','<%= EscapeUtil.js(d.getFilePath()==null?"":d.getFilePath()) %>','<%= d.getStatus() %>','<%= d.getAdvisorScore()!=null?d.getAdvisorScore():"" %>','<%= EscapeUtil.js(d.getAdvisorComment()==null?"":d.getAdvisorComment()) %>')">查看/审核</button>
        </td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<div class="modal fade" id="docModal" tabindex="-1">
  <div class="modal-dialog modal-lg"><div class="modal-content">
    <form id="docForm" action="../teacher/document.action" method="post">
      <input type="hidden" name="id" id="docId">
      <input type="hidden" name="docType" value="<%= docType %>">
      <div class="modal-header"><h6 class="modal-title" id="docTitle">文档审核</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><strong>内容：</strong><div id="docContent" class="border rounded p-2 bg-light" style="max-height:200px;overflow-y:auto;font-size:0.9rem"></div></div>
        <div class="mb-2"><strong>附件：</strong><span id="docFile"></span></div>
        <div class="row g-2">
          <div class="col-4 final-score-field"><label class="form-label">指导教师评分 (0-100)</label><input name="score" id="docScore" type="number" min="0" max="100" step="0.5" class="form-control form-control-sm" oninput="validateScore(this)"></div>
          <div class="<%= finalDocType ? "col-8" : "col-12" %>"><label class="form-label"><%= finalDocType ? "指导教师评语" : "审核意见" %></label><textarea name="feedback" id="docFeedback" class="form-control form-control-sm" rows="3"></textarea></div>
        </div>
        <% if (!finalDocType) { %>
          <div class="text-muted small mt-2">开题报告和中期检查只做阶段通过/退回；终稿通过后，指导教师评分、评阅教师评分、答辩平均分共同形成最终成绩。</div>
        <% } else { %>
          <div class="text-muted small mt-2">指导教师评分占最终成绩 40%；评阅教师评分由系主任另行安排非指导教师完成。</div>
        <% } %>
      </div>
      <div class="modal-footer" id="docActions">
        <button type="submit" name="action" value="review" class="btn btn-success btn-sm"><%= finalDocType ? "通过并填写指导教师评分" : "通过" %></button>
        <button type="submit" name="action" value="reject" class="btn btn-danger btn-sm">驳回</button>
      </div>
    </form>
  </div></div>
</div>

<script>
function viewDoc(id,student,title,content,file,status,score,feedback) {
  document.getElementById('docId').value = id;
  document.getElementById('docTitle').textContent = student + ' - ' + title;
  document.getElementById('docContent').textContent = content || '无内容';
  document.getElementById('docFile').textContent = file || '无附件';
  document.getElementById('docScore').value = score;
  document.getElementById('docFeedback').value = feedback;
  document.getElementById('docActions').style.display = (status === 'submitted') ? 'flex' : 'none';
  var isFinal = '<%= finalDocType ? "1" : "0" %>' === '1';
  document.querySelectorAll('.final-score-field').forEach(function(el) {
    el.style.display = isFinal ? '' : 'none';
  });
  document.getElementById('docScore').required = isFinal && status === 'submitted';
  new bootstrap.Modal(document.getElementById('docModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
