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
  <div class="alert alert-info py-2">
    管理员只控制流程开关：关闭第一轮、开启第二轮后学生端进入第 2 轮选题；第二轮结束后关闭第二轮并开启强制分配，具体分配由系主任/专业负责人在本专业确认页执行。
  </div>
  <form action="system-switch.action" method="post">
    <table class="table-modern">
      <tr><th>功能</th><th>说明</th><th>当前状态</th></tr>
      <tr>
        <td>教师出题</td><td>关闭后教师不能新增或修改课题</td>
        <td><input class="form-check-input" type="checkbox" name="switch.topic_submit" <%= "1".equals(switches.get("switch.topic_submit"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>第一轮选题</td><td>开启后学生端进入第一轮志愿填报；第一轮结束后关闭该开关</td>
        <td><input class="form-check-input" type="checkbox" name="switch.selection" <%= "1".equals(switches.get("switch.selection"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>第二轮选题</td><td>第一轮确认完成后开启；未最终确认题目的学生可在学生端提交第 2 轮志愿</td>
        <td><input class="form-check-input" type="checkbox" name="switch.selection_round2" <%= "1".equals(switches.get("switch.selection_round2"))?"checked":"" %>></td>
      </tr>
      <tr>
        <td>强制分配</td><td>第二轮确认结束后由管理员开启阶段；开启后由系主任/专业负责人把剩余学生分配到剩余题目</td>
        <td><input class="form-check-input" type="checkbox" name="switch.manual_assign" <%= "1".equals(switches.get("switch.manual_assign"))?"checked":"" %>></td>
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
