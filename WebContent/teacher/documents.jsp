<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat" %>
<%
  request.setAttribute("pageTitle", "文档审核");
  User loginUser = (User) session.getAttribute("loginUser");
  String docType = request.getParameter("type");
  if (docType == null) docType = "proposal";
  String statusFilter = request.getParameter("status");
  if (statusFilter == null) statusFilter = "submitted";
  DocumentDao dao = new DocumentDao();
  List<Document> list = dao.findByTeacher(loginUser.getId(), docType, "all".equals(statusFilter) ? null : statusFilter);
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  java.util.Map<String,String> typeNames = new java.util.LinkedHashMap<String,String>();
  typeNames.put("proposal", "开题报告");
  typeNames.put("midterm", "中期检查");
  typeNames.put("final", "终稿");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<ul class="nav nav-tabs nav-tabs-modern">
  <% for (java.util.Map.Entry<String,String> e : typeNames.entrySet()) { %>
    <li class="nav-item"><a class="nav-link <%= docType.equals(e.getKey())?"active":"" %>" href="?type=<%= e.getKey() %>&status=<%= statusFilter %>"><%= e.getValue() %></a></li>
  <% } %>
</ul>

<div class="mb-3">
  <a href="?type=<%= docType %>&status=submitted" class="btn btn-sm <%= "submitted".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">待审核</a>
  <a href="?type=<%= docType %>&status=reviewed" class="btn btn-sm <%= "reviewed".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">已审核</a>
  <a href="?type=<%= docType %>&status=all" class="btn btn-sm <%= "all".equals(statusFilter)?"btn-primary":"btn-outline-primary" %>">全部</a>
</div>

<div class="content-card">
  <% if (list.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>暂无待审文档</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr><th>学生</th><th>课题</th><th>标题</th><th>提交时间</th><th>状态</th><th>分数</th><th>操作</th></tr>
      <% for (Document d : list) { %>
      <tr>
        <td><%= d.getStudentName() %></td>
        <td><%= d.getTopicTitle() %></td>
        <td><%= d.getTitle() %></td>
        <td><%= d.getSubmitTime()!=null?sdf.format(d.getSubmitTime()):"—" %></td>
        <td><span class="badge-status badge-<%= d.getStatus() %>"><%= d.getStatus() %></span></td>
        <td><%= d.getScore()!=null?d.getScore():"—" %></td>
        <td>
          <button class="btn btn-sm btn-outline-primary" onclick="viewDoc(<%= d.getId() %>,'<%= d.getStudentName() %>','<%= d.getTitle().replace("'","\\'") %>','<%= d.getContent()==null?"":d.getContent().replace("'","\\'").replace("\n","\\n").replace("\r","") %>','<%= d.getFilePath()==null?"":d.getFilePath() %>','<%= d.getStatus() %>','<%= d.getScore()!=null?d.getScore():"" %>','<%= d.getFeedback()==null?"":d.getFeedback().replace("'","\\'").replace("\n","\\n").replace("\r","") %>')">查看/审核</button>
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
          <div class="col-4"><label class="form-label">分数 (0-100)</label><input name="score" id="docScore" type="number" min="0" max="100" step="0.5" class="form-control form-control-sm" oninput="validateScore(this)"></div>
          <div class="col-8"><label class="form-label">反馈意见</label><textarea name="feedback" id="docFeedback" class="form-control form-control-sm" rows="2"></textarea></div>
        </div>
      </div>
      <div class="modal-footer" id="docActions">
        <button type="submit" name="action" value="review" class="btn btn-success btn-sm">通过并评分</button>
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
  new bootstrap.Modal(document.getElementById('docModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
