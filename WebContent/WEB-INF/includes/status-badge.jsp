<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="util.StatusUtil" %>
<%
  String status = (String) request.getAttribute("status");
  if (status == null) status = "";
%>
<span class="badge-status badge-<%= status %>"><%= StatusUtil.label(status) %></span>
