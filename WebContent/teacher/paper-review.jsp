<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "论文评阅评分");
  User loginUser = (User) session.getAttribute("loginUser");
  List<Document> documents = (List<Document>) request.getAttribute("documents");
  if (documents == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/paper-review.action");
    return;
  }
  String msg = request.getParameter("msg");
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if ("score_ok".equals(msg)) { %>
  <div class="alert alert-success py-2">论文评阅评分已保存。</div>
<% } else if ("invalid_score".equals(msg)) { %>
  <div class="alert alert-warning py-2">分数必须在 0-100 之间，且只能评阅分配给您的终稿。</div>
<% } %>

<div class="content-card">
  <h5>我的论文评阅任务</h5>
  <div class="alert alert-info py-2">
    评阅教师评分占最终成绩 20%。该评分由非指导教师独立评阅终稿/结题材料后给出，不评价学生平时指导过程。
  </div>
  <% if (documents.isEmpty()) { %>
    <div class="empty-state"><div class="icon">&#128196;</div><p>暂无论文评阅任务</p></div>
  <% } else { %>
    <table class="table-modern">
      <tr>
        <th>学号</th><th>学生</th><th>课题</th><th>指导教师</th>
        <th>终稿提交</th><th>我的评分</th><th>操作</th>
      </tr>
      <% for (Document d : documents) { %>
      <tr>
        <td><%= EscapeUtil.html(d.getStudentNo()) %></td>
        <td><%= EscapeUtil.html(d.getStudentName()) %></td>
        <td><%= EscapeUtil.html(d.getTopicTitle()) %></td>
        <td><%= EscapeUtil.html(d.getTeacherName()) %></td>
        <td><%= d.getSubmitTime()==null?"—":sdf.format(d.getSubmitTime()) %></td>
        <td>
          <% if (d.getReviewerScore()==null) { %>
            <span class="text-muted">待评阅</span>
          <% } else { %>
            <%= d.getReviewerScore() %> 分
            <% if (d.getReviewerReviewTime()!=null) { %>
              <div class="text-muted small"><%= sdf.format(d.getReviewerReviewTime()) %></div>
            <% } %>
          <% } %>
        </td>
        <td>
          <button class="btn btn-sm btn-outline-primary"
              onclick="openReview(<%= d.getId() %>, '<%= EscapeUtil.js(d.getStudentName()) %>', '<%= EscapeUtil.js(d.getTitle()) %>', '<%= EscapeUtil.js(d.getContent()==null?"":d.getContent()) %>', '<%= EscapeUtil.js(d.getFilePath()==null?"":d.getFilePath()) %>', '<%= d.getReviewerScore()==null?"":d.getReviewerScore() %>', '<%= EscapeUtil.js(d.getReviewerComment()==null?"":d.getReviewerComment()) %>')">
            查看/评分
          </button>
        </td>
      </tr>
      <% } %>
    </table>
  <% } %>
</div>

<div class="modal fade" id="reviewModal" tabindex="-1">
  <div class="modal-dialog modal-lg"><div class="modal-content">
    <form action="paper-review.action" method="post">
      <input type="hidden" name="documentId" id="documentId">
      <div class="modal-header">
        <h6 class="modal-title" id="reviewTitle">论文评阅</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-2"><strong>终稿标题：</strong><span id="docTitleText"></span></div>
        <div class="mb-2"><strong>内容：</strong><div id="docContent" class="border rounded p-2 bg-light" style="max-height:220px;overflow-y:auto;font-size:0.9rem"></div></div>
        <div class="mb-2"><strong>附件：</strong><span id="docFile"></span></div>
        <div class="row g-2">
          <div class="col-4">
            <label class="form-label">评阅教师评分 (0-100)</label>
            <input name="score" id="scoreInput" type="number" min="0" max="100" step="0.5" class="form-control form-control-sm" required>
          </div>
          <div class="col-8">
            <label class="form-label">评阅教师意见</label>
            <textarea name="comment" id="commentInput" class="form-control form-control-sm" rows="3"></textarea>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary btn-sm" type="submit">保存评分</button>
      </div>
    </form>
  </div></div>
</div>

<script>
function openReview(documentId, studentName, title, content, file, score, comment) {
  document.getElementById('documentId').value = documentId;
  document.getElementById('reviewTitle').textContent = '论文评阅 - ' + studentName;
  document.getElementById('docTitleText').textContent = title || '';
  document.getElementById('docContent').textContent = content || '无内容';
  document.getElementById('docFile').textContent = file || '无附件';
  document.getElementById('scoreInput').value = score || '';
  document.getElementById('commentInput').value = comment || '';
  new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
