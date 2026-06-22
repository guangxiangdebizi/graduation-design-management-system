<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.StatusUtil" %>
<%
  request.setAttribute("pageTitle", "我的课题");
  User loginUser = (User) session.getAttribute("loginUser");

  List<Topic> topics = (List<Topic>) request.getAttribute("topics");
  if (topics == null) {
    response.sendRedirect(request.getContextPath() + "/teacher/topic.action");
    return;
  }
  Map<String, String> majorOptions = (Map<String, String>) request.getAttribute("majorOptions");
  String teacherCollege = (String) request.getAttribute("teacherCollege");
  String teacherCollegeName = (String) request.getAttribute("teacherCollegeName");
  String teacherMajor = (String) request.getAttribute("teacherMajor");
  Boolean topicSubmitOpenAttr = (Boolean) request.getAttribute("topicSubmitOpen");
  boolean topicSubmitOpen = topicSubmitOpenAttr == null || topicSubmitOpenAttr.booleanValue();
  if (majorOptions == null) majorOptions = new LinkedHashMap<String, String>();
  if (teacherCollege == null) teacherCollege = loginUser.getCollege() != null ? loginUser.getCollege() : "";
  if (teacherCollegeName == null || teacherCollegeName.length() == 0) teacherCollegeName = loginUser.getCollegeName() != null ? loginUser.getCollegeName() : "未设置学院";
  if (teacherMajor == null) teacherMajor = loginUser.getMajor() != null ? loginUser.getMajor() : "";

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

  // 消息提示
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("add_ok".equals(msg)) { msgTitle="成功"; msgContent="课题已提交审核"; msgClass="success"; }
  else if ("edit_ok".equals(msg)) { msgTitle="成功"; msgContent="课题已修改并重新进入待审核"; msgClass="success"; }
  else if ("delete_ok".equals(msg)) { msgTitle="成功"; msgContent="课题删除成功"; msgClass="success"; }
  else if ("delete_failed".equals(msg)) { msgTitle="失败"; msgContent="删除课题失败"; msgClass="danger"; }
  else if ("topic_submit_closed".equals(msg)) { msgTitle="提示"; msgContent="管理员已关闭教师出题入口"; msgClass="warning"; }
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

<% if (!topicSubmitOpen) { %>
<div class="alert alert-warning py-2">教师出题入口当前关闭，只能查看已提交课题。</div>
<% } %>

<div class="d-flex justify-content-end mb-3">
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal" <%= topicSubmitOpen ? "" : "disabled" %>>+ 提交课题审核</button>
</div>

<div class="topic-grid">
  <% if (topics.isEmpty()) { %>
    <div class="empty-state" style="grid-column:1/-1"><div class="icon">&#128221;</div><p>还没有发布课题</p></div>
  <% } else { for (Topic t : topics) { %>
    <div class="topic-card">
      <h6><%= EscapeUtil.html(t.getTitle()) %></h6>
      <p><%= EscapeUtil.html(t.getDescription() != null && t.getDescription().length() > 100 ? t.getDescription().substring(0, 100) + "..." : (t.getDescription() != null ? t.getDescription() : "")) %></p>
      <div class="meta">
        <span class="badge bg-info"><%= t.getCollegeName() != null ? t.getCollegeName() : "未分类" %></span>
        <span class="badge bg-secondary"><%= t.getMajorName() != null ? t.getMajorName() : "未分专业" %></span>
        <br>
        名额: <%= t.getSelectedCount() %>/<%= t.getMaxStudents() %>
        &nbsp;|&nbsp;
        <span class="badge-status badge-<%= t.getStatus() %>"><%= StatusUtil.label(t.getStatus()) %></span>
        &nbsp;|&nbsp; <%= t.getCreatedAt() != null ? sdf.format(t.getCreatedAt()) : "" %>
        <% if (t.getReviewComment() != null && t.getReviewComment().trim().length() > 0) { %>
          <br>审核意见: <%= EscapeUtil.html(t.getReviewComment()) %>
        <% } %>
      </div>
      <div class="mt-2">
        <button class="btn btn-sm btn-outline-primary" onclick="editTopic(<%= t.getId() %>,'<%= EscapeUtil.js(t.getTitle()) %>','<%= EscapeUtil.js(t.getDescription() != null ? t.getDescription() : "") %>','<%= t.getMajor() != null ? t.getMajor() : "" %>',<%= t.getMaxStudents() %>)" <%= topicSubmitOpen ? "" : "disabled" %>>编辑并重提</button>
        <form id="delTopic<%= t.getId() %>" action="topic.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= t.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="if(confirm('确定删除该课题吗？'))document.getElementById('delTopic<%= t.getId() %>').submit()">删除</button>
        </form>
      </div>
    </div>
  <% }} %>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">提交课题审核</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称 *</label><input name="title" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述 *</label><textarea name="description" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2">
          <div class="col-6"><label class="form-label">所属学院</label>
            <input class="form-control form-control-sm" value="<%= EscapeUtil.attr(teacherCollegeName) %>" readonly>
            <input type="hidden" name="college" value="<%= EscapeUtil.attr(teacherCollege) %>">
          </div>
          <div class="col-6"><label class="form-label">最大人数 *</label><input name="maxStudents" type="number" value="1" min="1" max="5" class="form-control form-control-sm" required></div>
        </div>
        <div class="mb-2"><label class="form-label">所属专业 *</label>
          <select name="major" class="form-select form-select-sm" required>
            <option value="">请选择专业</option>
            <% for (Map.Entry<String, String> e : majorOptions.entrySet()) { %>
            <option value="<%= e.getKey() %>" <%= e.getKey().equals(teacherMajor) ? "selected" : "" %>><%= EscapeUtil.html(e.getValue()) %></option>
            <% } %>
          </select>
        </div>
        <div class="alert alert-info py-2 mb-0">提交后默认进入“待审核”，审核通过后学生才能看到。</div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">提交审核</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="topic.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑并重新提交审核</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">课题名称 *</label><input name="title" id="editTitle" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">课题描述 *</label><textarea name="description" id="editDesc" class="form-control form-control-sm" rows="4" required></textarea></div>
        <div class="row g-2">
          <div class="col-6"><label class="form-label">所属学院</label>
            <input class="form-control form-control-sm" value="<%= EscapeUtil.attr(teacherCollegeName) %>" readonly>
            <input type="hidden" name="college" value="<%= EscapeUtil.attr(teacherCollege) %>">
          </div>
          <div class="col-6"><label class="form-label">最大人数 *</label><input name="maxStudents" id="editMax" type="number" min="1" max="5" class="form-control form-control-sm" required></div>
        </div>
        <div class="mb-2"><label class="form-label">所属专业 *</label>
          <select name="major" id="editMajor" class="form-select form-select-sm" required>
            <option value="">请选择专业</option>
            <% for (Map.Entry<String, String> e : majorOptions.entrySet()) { %>
            <option value="<%= e.getKey() %>"><%= EscapeUtil.html(e.getValue()) %></option>
            <% } %>
          </select>
        </div>
        <div class="alert alert-info py-2 mb-0">保存后会重新进入“待审核”，原审核意见将清空。</div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存并提交审核</button></div>
    </form>
  </div></div>
</div>

<script>
function editTopic(id, title, desc, major, max) {
  document.getElementById('editId').value = id;
  document.getElementById('editTitle').value = title;
  document.getElementById('editDesc').value = desc;
  document.getElementById('editMajor').value = major;
  document.getElementById('editMax').value = max;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
