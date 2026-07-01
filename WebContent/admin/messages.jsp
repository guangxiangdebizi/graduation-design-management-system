<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>
<%
  if (request.getAttribute("pageTitle") == null) request.setAttribute("pageTitle", "站内消息");
  User loginUser = (User) session.getAttribute("loginUser");
  String tab = (String) request.getAttribute("tab");
  List<Message> list = (List<Message>) request.getAttribute("messages");
  Message viewing = (Message) request.getAttribute("viewing");
  List<User> contacts = (List<User>) request.getAttribute("contacts");
  Integer messageUnreadObj = (Integer) request.getAttribute("unreadMsg");
  int messageUnread = messageUnreadObj == null ? 0 : messageUnreadObj.intValue();
  if (tab == null || list == null || contacts == null) {
    response.sendRedirect(request.getContextPath() + "/admin/messages.action");
    return;
  }
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="d-flex justify-content-end mb-3">
  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#sendModal">+ 发送消息</button>
</div>

<ul class="nav nav-tabs nav-tabs-modern mb-3">
  <li class="nav-item"><a class="nav-link <%= "inbox".equals(tab)?"active":"" %>" href="?tab=inbox">收件箱 (<%= messageUnread %>)</a></li>
  <li class="nav-item"><a class="nav-link <%= "sent".equals(tab)?"active":"" %>" href="?tab=sent">已发送</a></li>
</ul>

<% if (viewing != null) { %>
<div class="content-card mb-3">
  <h5><%= EscapeUtil.html(viewing.getTitle()) %></h5>
  <p class="text-muted small">发件人: <%= EscapeUtil.html(viewing.getSenderName()) %> · <%= sdf.format(viewing.getCreatedAt()) %></p>
  <div><%= EscapeUtil.html(viewing.getContent()).replace("\n","<br>") %></div>
  <form action="../message.action" method="post" class="mt-3">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" value="<%= viewing.getId() %>">
    <button type="submit" class="btn btn-sm btn-outline-danger">删除</button>
  </form>
</div>
<% } %>

<div class="content-card">
  <table class="table-modern">
    <tr><th>标题</th><th><%= "sent".equals(tab)?"收件人":"发件人" %></th><th>时间</th><th>状态</th><th></th></tr>
    <% if (list.isEmpty()) { %>
      <tr><td colspan="5" class="text-center text-muted py-4">暂无消息</td></tr>
    <% } else { for (Message m : list) { %>
    <tr>
      <td><%= EscapeUtil.html(m.getTitle()) %><% if (!"sent".equals(tab) && m.getIsRead()==0) { %> <span class="badge bg-danger">新</span><% } %></td>
      <td><%= EscapeUtil.html("sent".equals(tab) ? m.getReceiverName() : m.getSenderName()) %></td>
      <td><%= sdf.format(m.getCreatedAt()) %></td>
      <td><%= "sent".equals(tab) ? "已发送" : (m.getIsRead()==1?"已读":"未读") %></td>
      <td><a href="?tab=<%= tab %>&view=<%= m.getId() %>" class="btn btn-sm btn-outline-primary">查看</a></td>
    </tr>
    <% }} %>
  </table>
  <% if (!"sent".equals(tab)) { %>
  <%@ include file="/WEB-INF/includes/pagination.jsp" %>
  <% } %>
</div>

<div class="modal fade" id="sendModal" tabindex="-1">
  <div class="modal-dialog"><div class="modal-content">
    <form action="../message.action" method="post">
      <input type="hidden" name="action" value="send">
      <div class="modal-header"><h6 class="modal-title">发送消息</h6><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">收件人</label>
          <select name="receiverId" class="form-select form-select-sm" required>
            <% for (User u : contacts) { if (u.getId() != loginUser.getId()) { %>
              <option value="<%= u.getId() %>"><%= EscapeUtil.html(u.getRealName()) %>（<%= EscapeUtil.html(u.getDisplayTitle()) %>）</option>
            <% }} %>
          </select>
        </div>
        <div class="mb-2"><label class="form-label">标题</label><input name="title" class="form-control form-control-sm" required></div>
        <div class="mb-2"><label class="form-label">内容</label><textarea name="content" class="form-control form-control-sm" rows="4" required></textarea></div>
      </div>
      <div class="modal-footer"><button type="submit" class="btn btn-primary btn-sm">发送</button></div>
    </form>
  </div></div>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
