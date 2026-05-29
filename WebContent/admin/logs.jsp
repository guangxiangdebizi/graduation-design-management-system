<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<%@ page import="bean.*,dao.*,java.util.*,java.text.SimpleDateFormat,util.EscapeUtil,util.PageUtil" %>

<%

  request.setAttribute("pageTitle", "操作日志");

  User loginUser = (User) session.getAttribute("loginUser");

  OperationLogDao dao = new OperationLogDao();

  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");



  int currentPageNum = PageUtil.getPage(request);
  int pageSize = PageUtil.getPageSize(request);

  Integer filterUserId = null;

  try {

    String uid = request.getParameter("userId");

    if (uid != null && uid.trim().length() > 0) filterUserId = Integer.parseInt(uid.trim());

  } catch (Exception ignored) {}

  String filterAction = request.getParameter("action");

  if (filterAction != null && filterAction.trim().isEmpty()) filterAction = null;

  String dateFrom = request.getParameter("dateFrom");

  if (dateFrom != null && dateFrom.trim().isEmpty()) dateFrom = null;

  String dateTo = request.getParameter("dateTo");

  if (dateTo != null && dateTo.trim().isEmpty()) dateTo = null;



  List<OperationLog> logs = dao.findFiltered(filterUserId, filterAction, dateFrom, dateTo, currentPageNum, pageSize);

  int total = dao.countFiltered(filterUserId, filterAction, dateFrom, dateTo);



  StringBuilder baseUrl = new StringBuilder("logs.jsp?");

  if (filterUserId != null) baseUrl.append("userId=").append(filterUserId).append("&");

  if (filterAction != null) baseUrl.append("action=").append(filterAction).append("&");

  if (dateFrom != null) baseUrl.append("dateFrom=").append(dateFrom).append("&");

  if (dateTo != null) baseUrl.append("dateTo=").append(dateTo).append("&");

  String pagBase = baseUrl.toString();

  if (pagBase.endsWith("?") || pagBase.endsWith("&")) pagBase = pagBase.substring(0, pagBase.length() - 1);

%>

<%@ include file="/WEB-INF/includes/header.jsp" %>

<div class="app-layout">

<%@ include file="/WEB-INF/includes/sidebar.jsp" %>



<div class="content-card mb-3">

  <form method="get" class="row g-2 align-items-end">

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

      <a href="logs.jsp" class="btn btn-outline-secondary btn-sm">重置</a>

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

  <% request.setAttribute("baseUrl", pagBase);

     request.setAttribute("page", currentPageNum);

     request.setAttribute("pageSize", pageSize);

     request.setAttribute("total", total); %>

  <%@ include file="/WEB-INF/includes/pagination.jsp" %>

</div>



<%@ include file="/WEB-INF/includes/footer.jsp" %>

