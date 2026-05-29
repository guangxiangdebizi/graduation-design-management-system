<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>服务器错误 - 毕业设计管理系统</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="<%= request.getContextPath() %>/css/app.css" rel="stylesheet">
</head>
<body>
<div class="login-page">
  <div class="login-card text-center">
    <div style="font-size:4rem;line-height:1">500</div>
    <h1 class="h4 mt-2">服务器内部错误</h1>
    <p class="text-muted">系统暂时无法处理您的请求，请稍后重试</p>
    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-primary btn-sm">返回首页</a>
    <a href="javascript:location.reload()" class="btn btn-outline-secondary btn-sm ms-2">重新加载</a>
  </div>
</div>
</body>
</html>
