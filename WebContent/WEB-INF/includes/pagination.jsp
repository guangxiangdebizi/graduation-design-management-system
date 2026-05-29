<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="util.PageUtil" %>
<%
  String pgBaseUrl = (String) request.getAttribute("baseUrl");
  Integer pgPageObj = (Integer) request.getAttribute("page");
  Integer pgSizeObj = (Integer) request.getAttribute("pageSize");
  Integer pgTotalObj = (Integer) request.getAttribute("total");
  if (pgBaseUrl == null) pgBaseUrl = "";
  int pgCurrent = pgPageObj != null ? pgPageObj : 1;
  int pgSize = pgSizeObj != null ? pgSizeObj : PageUtil.DEFAULT_PAGE_SIZE;
  int pgTotal = pgTotalObj != null ? pgTotalObj : 0;
  int pgTotalPages = PageUtil.totalPages(pgTotal, pgSize);
  String pgSep = pgBaseUrl.contains("?") ? "&" : "?";
%>
<% if (pgTotalPages > 1) { %>
<nav class="pagination-nav mt-3" aria-label="分页">
  <ul class="pagination pagination-sm mb-0">
    <li class="page-item <%= pgCurrent <= 1 ? "disabled" : "" %>">
      <a class="page-link" href="<%= pgBaseUrl %><%= pgSep %>page=<%= pgCurrent - 1 %>&pageSize=<%= pgSize %>">上一页</a>
    </li>
    <% for (int i = 1; i <= pgTotalPages; i++) {
         if (i == 1 || i == pgTotalPages || (i >= pgCurrent - 2 && i <= pgCurrent + 2)) { %>
    <li class="page-item <%= i == pgCurrent ? "active" : "" %>">
      <a class="page-link" href="<%= pgBaseUrl %><%= pgSep %>page=<%= i %>&pageSize=<%= pgSize %>"><%= i %></a>
    </li>
    <%   } else if (i == pgCurrent - 3 || i == pgCurrent + 3) { %>
    <li class="page-item disabled"><span class="page-link">…</span></li>
    <%   }
       } %>
    <li class="page-item <%= pgCurrent >= pgTotalPages ? "disabled" : "" %>">
      <a class="page-link" href="<%= pgBaseUrl %><%= pgSep %>page=<%= pgCurrent + 1 %>&pageSize=<%= pgSize %>">下一页</a>
    </li>
  </ul>
  <span class="text-muted small ms-2">共 <%= pgTotal %> 条，第 <%= pgCurrent %>/<%= pgTotalPages %> 页</span>
</nav>
<% } %>
