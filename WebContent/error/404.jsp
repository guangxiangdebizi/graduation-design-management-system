<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>页面未找到 - 毕业设计管理系统</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="<%= request.getContextPath() %>/css/app.css" rel="stylesheet">
</head>
<body>
<div class="login-page">
  <div class="login-card text-center">
    <div style="font-size:4rem;line-height:1">404</div>
    <h1 class="h4 mt-2">页面未找到</h1>
    <p class="text-muted">您访问的页面不存在或已被移除</p>
    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-primary btn-sm">返回首页</a>
    <a href="javascript:history.back()" class="btn btn-outline-secondary btn-sm ms-2">返回上一页</a>
  </div>
</div>
</body>
</html>
