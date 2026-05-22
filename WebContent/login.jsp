<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>登录 - 毕业设计管理系统</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="css/app.css" rel="stylesheet">
</head>
<body>
<div class="login-page">
  <div class="login-card">
    <h1>毕业设计管理系统</h1>
    <p class="subtitle">Graduation Design Management System</p>
    <form action="login.action" method="post">
      <div class="mb-3">
        <label class="form-label">用户名</label>
        <input type="text" name="username" class="form-control" placeholder="请输入用户名" required autofocus>
      </div>
      <div class="mb-3">
        <label class="form-label">密码</label>
        <div class="input-group">
          <input type="password" name="password" id="password" class="form-control" placeholder="请输入密码" required>
          <button type="button" class="btn btn-outline-secondary btn-sm" onclick="togglePassword('password', this)">显示</button>
        </div>
      </div>
      <button type="submit" class="btn btn-login">登 录</button>
    </form>
    <div class="demo-accounts">
      <strong>演示账号：</strong><br>
      管理员 admin / admin123<br>
      教师 teacher01 / 123456<br>
      学生 student01 / 123456
    </div>
  </div>
</div>
<div id="toastContainer" class="toast-container"></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/app.js"></script>
</body>
</html>
