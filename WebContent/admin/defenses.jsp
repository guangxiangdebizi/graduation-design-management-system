<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  request.setAttribute("pageTitle", "答辩安排");
  User loginUser = (User) session.getAttribute("loginUser");
  DefenseScheduleDao dao = new DefenseScheduleDao();
  UserDao userDao = new UserDao();
  SelectionDao selDao = new SelectionDao();
  List<DefenseSchedule> schedules = dao.findAll();
  List<User> approvedStudents = new ArrayList<User>();
  for (User u : userDao.findAll("student")) {
    if (selDao.findApprovedByStudent(u.getId()) != null) {
      approvedStudents.add(u);
    }
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
  SimpleDateFormat display = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-3">
  <div></div>
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ 安排答辩</button>
</div>

<div class="content-card mb-3">
  <h6 class="mb-2">批量导入答辩安排</h6>
  <p class="text-muted small mb-2">Excel 列：学号、答辩时间、教室、分组、备注（首行为表头）</p>
  <form action="../admin/defense-import.action" method="post" enctype="multipart/form-data" class="d-flex flex-wrap gap-2 align-items-end">
    <div>
      <label class="form-label">Excel 文件</label>
      <input type="file" name="file" class="form-control form-control-sm" accept=".xls,.xlsx" required>
    </div>
    <button type="submit" class="btn btn-success btn-sm">导入</button>
  </form>
  <%
    String importMsg = request.getParameter("msg");
    if ("import_ok".equals(importMsg)) {
      int importSuccess = 0, importSkipped = 0;
      try { importSuccess = Integer.parseInt(request.getParameter("success")); } catch (Exception ignored) {}
      try { importSkipped = Integer.parseInt(request.getParameter("skipped")); } catch (Exception ignored) {}
  %>
  <div class="alert alert-success py-2 mt-2 mb-0">导入完成：成功 <%= importSuccess %> 条，跳过 <%= importSkipped %> 条</div>
  <% } else if ("import_empty".equals(importMsg)) { %>
  <div class="alert alert-warning py-2 mt-2 mb-0">请选择要导入的 Excel 文件</div>
  <% } else if ("import_error".equals(importMsg)) { %>
  <div class="alert alert-danger py-2 mt-2 mb-0">导入失败，请检查文件格式后重试</div>
  <% } %>
</div>

<div class="content-card">
  <table class="table-modern">
    <tr><th>学号</th><th>姓名</th><th>课题</th><th>指导教师</th><th>答辩时间</th><th>教室</th><th>分组</th><th>答辩分</th><th>操作</th></tr>
    <% if (schedules.isEmpty()) { %>
      <tr><td colspan="9" class="text-center text-muted py-4">暂无答辩安排</td></tr>
    <% } else { for (DefenseSchedule d : schedules) { %>
    <tr>
      <td><%= d.getStudentNo()==null?"—":d.getStudentNo() %></td>
      <td><%= EscapeUtil.html(d.getStudentName()) %></td>
      <td><%= d.getTopicTitle()==null?"—":EscapeUtil.html(d.getTopicTitle()) %></td>
      <td><%= d.getTeacherName()==null?"—":EscapeUtil.html(d.getTeacherName()) %></td>
      <td><%= d.getDefenseTime()==null?"待定":display.format(d.getDefenseTime()) %></td>
      <td><%= d.getRoom()==null?"—":EscapeUtil.html(d.getRoom()) %></td>
      <td><%= d.getGroupName()==null?"—":EscapeUtil.html(d.getGroupName()) %></td>
      <td><%= d.getScore()==null?"—":d.getScore() %></td>
      <td>
        <button class="btn btn-sm btn-outline-primary" onclick="editDefense(<%= d.getId() %>,<%= d.getStudentId() %>,'<%= d.getDefenseTime()==null?"":sdf.format(d.getDefenseTime()) %>','<%= d.getRoom()==null?"":d.getRoom() %>','<%= d.getGroupName()==null?"":d.getGroupName() %>','<%= d.getScore()==null?"":d.getScore() %>','<%= d.getComment()==null?"":d.getComment().replace("'","\\'") %>')">编辑</button>
        <form id="delForm<%= d.getId() %>" action="../admin/defense.action" method="post" style="display:inline">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="id" value="<%= d.getId() %>">
          <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmAction('delForm<%= d.getId() %>','确定删除该答辩安排吗？')">删除</button>
        </form>
      </td>
    </tr>
    <% }} %>
  </table>
</div>

<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/defense.action" method="post">
      <input type="hidden" name="action" value="add">
      <div class="modal-header"><h6 class="modal-title">安排答辩</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body row g-2">
        <div class="col-12"><label class="form-label">学生</label>
          <select name="studentId" class="form-select form-select-sm" required>
            <% for (User u : approvedStudents) { %>
              <option value="<%= u.getId() %>"><%= u.getStudentNo() %> - <%= u.getRealName() %></option>
            <% } %>
          </select>
        </div>
        <div class="col-6"><label class="form-label">答辩时间</label><input type="datetime-local" name="defenseTime" class="form-control form-control-sm"></div>
        <div class="col-6"><label class="form-label">教室</label><input name="room" class="form-control form-control-sm" placeholder="如 A301"></div>
        <div class="col-6"><label class="form-label">分组</label><input name="groupName" class="form-control form-control-sm" placeholder="如 第一组"></div>
        <div class="col-6"><label class="form-label">答辩分数</label><input name="score" type="number" step="0.01" min="0" max="100" class="form-control form-control-sm"></div>
        <div class="col-12"><label class="form-label">备注</label><textarea name="comment" class="form-control form-control-sm" rows="2"></textarea></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../admin/defense.action" method="post">
      <input type="hidden" name="action" value="edit">
      <input type="hidden" name="id" id="editId">
      <div class="modal-header"><h6 class="modal-title">编辑答辩安排</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body row g-2">
        <div class="col-12"><label class="form-label">学生</label>
          <select name="studentId" id="editStudentId" class="form-select form-select-sm" required>
            <% for (User u : approvedStudents) { %>
              <option value="<%= u.getId() %>"><%= u.getStudentNo() %> - <%= u.getRealName() %></option>
            <% } %>
          </select>
        </div>
        <div class="col-6"><label class="form-label">答辩时间</label><input type="datetime-local" name="defenseTime" id="editDefenseTime" class="form-control form-control-sm"></div>
        <div class="col-6"><label class="form-label">教室</label><input name="room" id="editRoom" class="form-control form-control-sm"></div>
        <div class="col-6"><label class="form-label">分组</label><input name="groupName" id="editGroupName" class="form-control form-control-sm"></div>
        <div class="col-6"><label class="form-label">答辩分数</label><input name="score" id="editScore" type="number" step="0.01" min="0" max="100" class="form-control form-control-sm"></div>
        <div class="col-12"><label class="form-label">备注</label><textarea name="comment" id="editComment" class="form-control form-control-sm" rows="2"></textarea></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">保存</button></div>
    </form>
  </div></div>
</div>

<script>
function editDefense(id, studentId, time, room, group, score, comment) {
  document.getElementById('editId').value = id;
  document.getElementById('editStudentId').value = studentId;
  document.getElementById('editDefenseTime').value = time;
  document.getElementById('editRoom').value = room;
  document.getElementById('editGroupName').value = group;
  document.getElementById('editScore').value = score;
  document.getElementById('editComment').value = comment;
  new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
