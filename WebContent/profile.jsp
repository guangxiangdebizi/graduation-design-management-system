<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User,util.EscapeUtil,util.DictionaryUtil" %>
<%
  request.setAttribute("pageTitle", "个人中心");
  User loginUser = (User) session.getAttribute("loginUser");
  User profileUser = (User) request.getAttribute("profileUser");
  if (profileUser == null) {
    response.sendRedirect(request.getContextPath() + "/profile.action");
    return;
  }
  String msg = request.getParameter("msg");
  String msgTitle = "", msgContent = "", msgClass = "";
  if ("profile_ok".equals(msg)) { msgTitle="成功"; msgContent="个人资料已更新"; msgClass="success"; }
  else if ("password_ok".equals(msg)) { msgTitle="成功"; msgContent="密码已修改，下次登录请使用新密码"; msgClass="success"; }
  else if ("email_invalid".equals(msg)) { msgTitle="错误"; msgContent="邮箱格式不正确"; msgClass="danger"; }
  else if ("phone_invalid".equals(msg)) { msgTitle="错误"; msgContent="电话格式不正确"; msgClass="danger"; }
  else if ("old_password_wrong".equals(msg)) { msgTitle="错误"; msgContent="旧密码校验失败"; msgClass="danger"; }
  else if ("password_invalid".equals(msg)) { msgTitle="错误"; msgContent="新密码不符合长度要求"; msgClass="danger"; }
  else if ("password_mismatch".equals(msg)) { msgTitle="错误"; msgContent="两次输入的新密码不一致"; msgClass="danger"; }
  else if ("error".equals(msg)) { msgTitle="失败"; msgContent="操作失败，请重试"; msgClass="danger"; }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<% if (!msgTitle.isEmpty()) { %>
<div class="alert alert-<%= msgClass %> alert-dismissible fade show" role="alert">
  <strong><%= msgTitle %>：</strong><%= msgContent %>
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="row g-3">
  <div class="col-lg-5">
    <div class="content-card">
      <h6 class="mb-3">账号信息</h6>
      <table class="table table-sm">
        <tr><th style="width:110px">用户名</th><td><%= EscapeUtil.html(profileUser.getUsername()) %></td></tr>
        <tr><th>姓名</th><td><%= EscapeUtil.html(profileUser.getRealName()) %></td></tr>
        <tr><th>角色</th><td><%= EscapeUtil.html(DictionaryUtil.label("role", profileUser.getRole())) %></td></tr>
        <% if ("student".equals(profileUser.getRole())) { %>
        <tr><th>学号</th><td><%= EscapeUtil.html(profileUser.getStudentNo()) %></td></tr>
        <tr><th>班级</th><td><%= EscapeUtil.html(profileUser.getClassName()) %></td></tr>
        <% } %>
        <tr><th>所属</th><td><%= EscapeUtil.html(profileUser.getFullAffiliation()) %></td></tr>
      </table>
    </div>
  </div>

  <div class="col-lg-7">
    <div class="content-card mb-3">
      <h6 class="mb-3">基本资料</h6>
      <form action="profile.action" method="post">
        <input type="hidden" name="action" value="profile">
        <div class="row g-2">
          <div class="col-md-6">
            <label class="form-label">邮箱</label>
            <input name="email" type="email" class="form-control form-control-sm" value="<%= EscapeUtil.attr(profileUser.getEmail()) %>">
          </div>
          <div class="col-md-6">
            <label class="form-label">电话</label>
            <input name="phone" class="form-control form-control-sm" value="<%= EscapeUtil.attr(profileUser.getPhone()) %>">
          </div>
        </div>
        <div class="mt-3"><button type="submit" class="btn btn-primary btn-sm">保存资料</button></div>
      </form>
    </div>

    <div class="content-card">
      <h6 class="mb-3">修改密码</h6>
      <form action="profile.action" method="post">
        <input type="hidden" name="action" value="password">
        <div class="row g-2">
          <div class="col-md-4">
            <label class="form-label">旧密码 *</label>
            <input name="oldPassword" type="password" class="form-control form-control-sm" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">新密码 *</label>
            <input name="newPassword" type="password" class="form-control form-control-sm" minlength="6" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">确认新密码 *</label>
            <input name="confirmPassword" type="password" class="form-control form-control-sm" minlength="6" required>
          </div>
        </div>
        <div class="mt-3"><button type="submit" class="btn btn-warning btn-sm">修改密码</button></div>
      </form>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
