<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%@ page import="bean.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil" %>

<%

  if (request.getAttribute("pageTitle") == null) {
    request.setAttribute("pageTitle", "操作日志");
  }

  User loginUser = (User) session.getAttribute("loginUser");

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  Integer filterUserId = (Integer) request.getAttribute("filterUserId");

  String filterAction = (String) request.getAttribute("filterAction");

  String dateFrom = (String) request.getAttribute("dateFrom");

  String dateTo = (String) request.getAttribute("dateTo");

  List<OperationLog> logs = (List<OperationLog>) request.getAttribute("logs");

  Integer totalObj = (Integer) request.getAttribute("total");

  int total = totalObj == null ? 0 : totalObj.intValue();

  if (logs == null) {
    response.sendRedirect(request.getContextPath() + "/admin/logs.action");
    return;
  }

%>

<%@ include file="/WEB-INF/includes/header.jsp" %>

<div class="app-layout">

<%@ include file="/WEB-INF/includes/sidebar.jsp" %>



<div class="content-card mb-3">

  <form action="<%= request.getContextPath() %>/admin/logs.action" method="get" class="row g-2 align-items-end">

    <div class="col-md-2">

      <label class="form-label">用户 ID</label>

      <input name="userId" class="form-control form-control-sm" value="<%= filterUserId==null?"":filterUserId %>" placeholder="可选">

    </div>

    <div class="col-md-2">

      <label class="form-label">操作类型</label>

      <input name="action" class="form-control form-control-sm" value="<%= filterAction==null?"":EscapeUtil.attr(filterAction) %>" placeholder="如 LOGIN">

    </div>

    <div class="col-md-2">

      <label class="form-label">开始日期</label>

      <input type="date" name="dateFrom" class="form-control form-control-sm" value="<%= dateFrom==null?"":dateFrom %>">

    </div>

    <div class="col-md-2">

      <label class="form-label">结束日期</label>

      <input type="date" name="dateTo" class="form-control form-control-sm" value="<%= dateTo==null?"":dateTo %>">

    </div>

    <div class="col-md-2">

      <button type="submit" class="btn btn-primary btn-sm">筛选</button>

      <a href="<%= request.getContextPath() %>/admin/logs.action" class="btn btn-outline-secondary btn-sm">重置</a>

    </div>

  </form>

</div>



<div class="content-card">

  <div class="d-flex justify-content-between align-items-center mb-3">

    <h5 class="mb-0">操作日志</h5>

    <span class="text-muted small">共 <%= total %> 条记录</span>

  </div>

  <table class="table-modern">

    <tr><th>时间</th><th>用户</th><th>操作</th><th>对象</th><th>详情</th></tr>

    <% if (logs.isEmpty()) { %>

      <tr><td colspan="5" class="text-center text-muted py-4">暂无操作日志</td></tr>

    <% } else { for (OperationLog log : logs) { %>

    <tr>

      <td><%= sdf.format(log.getCreatedAt()) %></td>

      <td><%= EscapeUtil.html(log.getRealName()==null?(log.getUsername()==null?"系统":log.getUsername()):log.getRealName()) %></td>

      <td><span class="badge bg-secondary"><%= EscapeUtil.html(log.getAction()) %></span></td>

      <td><%= log.getTarget()==null?"—":EscapeUtil.html(log.getTarget()) %></td>

      <td><%= log.getDetail()==null?"—":EscapeUtil.html(log.getDetail()) %></td>

    </tr>

    <% }} %>

  </table>

  <%@ include file="/WEB-INF/includes/pagination.jsp" %>

</div>



<%@ include file="/WEB-INF/includes/footer.jsp" %>

