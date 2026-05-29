<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="util.PageUtil" %>
<%
  String baseUrl = (String) request.getAttribute("baseUrl");
  Integer pageObj = (Integer) request.getAttribute("page");
  Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
  Integer totalObj = (Integer) request.getAttribute("total");
  if (baseUrl == null) baseUrl = "";
  int currentPage = pageObj != null ? pageObj : 1;
  int pageSize = pageSizeObj != null ? pageSizeObj : PageUtil.DEFAULT_PAGE_SIZE;
  int total = totalObj != null ? totalObj : 0;
  int totalPages = PageUtil.totalPages(total, pageSize);
  String sep = baseUrl.contains("?") ? "&" : "?";
%>
<% if (totalPages > 1) { %>
<nav class="pagination-nav mt-3" aria-label="分页">
  <ul class="pagination pagination-sm mb-0">
    <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
      <a class="page-link" href="<%= baseUrl %><%= sep %>page=<%= currentPage - 1 %>&pageSize=<%= pageSize %>">上一页</a>
    </li>
    <% for (int i = 1; i <= totalPages; i++) {
         if (i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) { %>
    <li class="page-item <%= i == currentPage ? "active" : "" %>">
      <a class="page-link" href="<%= baseUrl %><%= sep %>page=<%= i %>&pageSize=<%= pageSize %>"><%= i %></a>
    </li>
    <%   } else if (i == currentPage - 3 || i == currentPage + 3) { %>
    <li class="page-item disabled"><span class="page-link">…</span></li>
    <%   }
       } %>
    <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
      <a class="page-link" href="<%= baseUrl %><%= sep %>page=<%= currentPage + 1 %>&pageSize=<%= pageSize %>">下一页</a>
    </li>
  </ul>
  <span class="text-muted small ms-2">共 <%= total %> 条，第 <%= currentPage %>/<%= totalPages %> 页</span>
</nav>
<% } %>
