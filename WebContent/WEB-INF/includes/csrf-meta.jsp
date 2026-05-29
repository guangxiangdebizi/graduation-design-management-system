<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="util.CsrfUtil,bean.User" %>
<%
  User csrfUser = (User) session.getAttribute("loginUser");
  if (csrfUser != null) {
    String csrfToken = CsrfUtil.getToken(session);
%>
<meta name="csrf-token" content="<%= csrfToken %>">
<% } %>
