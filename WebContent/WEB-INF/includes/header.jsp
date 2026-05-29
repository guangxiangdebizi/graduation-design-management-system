<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "毕业设计管理系统" %></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="<%= request.getContextPath() %>/css/app.css" rel="stylesheet">
</head>
<body>
<%@ include file="/WEB-INF/includes/csrf-meta.jsp" %>
