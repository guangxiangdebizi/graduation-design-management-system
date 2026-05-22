<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
  if (session.getAttribute("loginUser") != null) {
    response.sendRedirect("dashboard.jsp");
    return;
  }
  response.sendRedirect("login.jsp");
%>
