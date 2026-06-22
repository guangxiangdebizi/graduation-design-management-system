<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User,java.util.*" %>
<%
  request.setAttribute("pageTitle", "系统开放状态");
  User loginUser = (User) session.getAttribute("loginUser");
  Map<String,String> switches = (Map<String,String>) request.getAttribute("systemSwitches");
  if (switches == null) {
    response.sendRedirect(request.getContextPath() + "/admin/system-switch.action");
    return;
  }
%>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<div class="app-layout">
<%@ include file="/WEB-INF/includes/sidebar.jsp" %>

<div class="content-card">
  <h5 class="mb-3">系统开放状态</h5>
  <form action="system-switch.action" method="post">
    <table class="table-modern">
      <tr><th>功能</th><th>说明</th><th>当前状态</th></tr>
      <tr>
        <td>教师出题</td><td>关闭后教师不能新增或修改课题</td>
        <td><input class="form-check-input" type="checkbox" name="switch.topic_submit" <%= "1".equals(switches.get("switch.topic_submit"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>学生选题</td><td>关闭后学生不能提交选题申请；当前版本先作为统一选题开关</td>
        <td><input class="form-check-input" type="checkbox" name="switch.selection" <%= "1".equals(switches.get("switch.selection"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>开题报告上传</td><td>控制学生开题报告提交</td>
        <td><input class="form-check-input" type="checkbox" name="switch.upload_proposal" <%= "1".equals(switches.get("switch.upload_proposal"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>中期报告上传</td><td>控制学生中期检查提交</td>
        <td><input class="form-check-input" type="checkbox" name="switch.upload_midterm" <%= "1".equals(switches.get("switch.upload_midterm"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>终稿上传</td><td>控制学生毕业论文/终稿提交</td>
        <td><input class="form-check-input" type="checkbox" name="switch.upload_final" <%= "1".equals(switches.get("switch.upload_final"))?"checked":"" %>></td>
      </tr>
    </table>
    <div class="mt-3">
      <button type="submit" class="btn btn-primary btn-sm">保存开关</button>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jsp" %>
