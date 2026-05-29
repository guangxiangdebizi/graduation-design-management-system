<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.PageUtil" %>

<%

  request.setAttribute("pageTitle", "站内消息");

  User loginUser = (User) session.getAttribute("loginUser");

  MessageDao msgDao = new MessageDao();

  UserDao userDao = new UserDao();

  String tab = request.getParameter("tab");

  if (tab == null) tab = "inbox";

  int viewId = 0;

  try { viewId = Integer.parseInt(request.getParameter("view")); } catch (Exception ignored) {}

  int currentPageNum = PageUtil.getPage(request);

  int pageSize = PageUtil.getPageSize(request);

  List<Message> list;

  int total;

  if ("sent".equals(tab)) {

    list = msgDao.findSent(loginUser.getId());

    total = list.size();

  } else {

    total = msgDao.countInbox(loginUser.getId());

    list = msgDao.findInboxPaged(loginUser.getId(), currentPageNum, pageSize);

  }

  Message viewing = viewId > 0 ? msgDao.findById(viewId) : null;

  if (viewing != null && viewing.getReceiverId() == loginUser.getId() && viewing.getIsRead() == 0) {

    msgDao.markRead(viewing.getId(), loginUser.getId());

    viewing.setIsRead(1);

  }

  List<User> contacts = userDao.findAll(null);

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

  String pagBase = "messages.jsp?tab=" + tab;

%>

<%@ include file="/WEB-INF/includes/header.jsp" %>

<div class="app-layout">

<%@ include file="/WEB-INF/includes/sidebar.jsp" %>



<div class="d-flex justify-content-end mb-3">

  <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#sendModal">+ 发送消息</button>

</div>



<ul class="nav nav-tabs nav-tabs-modern mb-3">

  <li class="nav-item"><a class="nav-link <%= "inbox".equals(tab)?"active":"" %>" href="?tab=inbox">收件箱 (<%= msgDao.countUnread(loginUser.getId()) %>)</a></li>

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

  <% if (!"sent".equals(tab)) {

       request.setAttribute("baseUrl", pagBase);

       request.setAttribute("page", page);

       request.setAttribute("pageSize", pageSize);

       request.setAttribute("total", total); %>

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

              <option value="<%= u.getId() %>"><%= EscapeUtil.html(u.getRealName()) %> (<%= u.getRole() %>)</option>

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



<%@ include file="/WEB-INF/includes/footer.j