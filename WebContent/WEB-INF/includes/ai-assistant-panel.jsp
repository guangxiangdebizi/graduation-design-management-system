<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="bean.User,util.EscapeUtil,util.EnvUtil" %>
<%
  User aiUser = (User) session.getAttribute("loginUser");
  String aiRole = (String) request.getAttribute("aiRole");
  String aiRoleName = (String) request.getAttribute("aiRoleName");
  String aiAction = (String) request.getAttribute("aiAction");
  String[] aiPrompts = (String[]) request.getAttribute("aiPrompts");
  String aiModel = EnvUtil.get("DEEPSEEK_MODEL", "deepseek-v4-pro");
%>
<div class="row g-3">
  <div class="col-lg-8">
    <div class="content-card ai-chat-card">
      <div class="ai-chat-header">
        <div>
          <h5 class="mb-1"><%= EscapeUtil.html(aiRoleName) %>端 AI 助手</h5>
          <div class="text-muted small">
            当前用户：<%= EscapeUtil.html(aiUser.getRealName()) %>
            / <%= EscapeUtil.html(aiUser.getUsername()) %>
            / ID <%= aiUser.getId() %>
          </div>
        </div>
        <span class="badge bg-primary"><%= EscapeUtil.html(aiModel) %></span>
      </div>
      <div id="aiChatBox" class="ai-chat-box">
        <div class="ai-msg ai-msg-assistant">
          <div class="ai-msg-role">AI</div>
          <div class="ai-msg-body">
            我是<%= EscapeUtil.html(aiRoleName) %>端专属 AI 助手。本会话只绑定当前登录账号，不会与其他角色或同级其他用户共享上下文。
          </div>
        </div>
      </div>
      <form id="aiForm" class="ai-input-area" data-action="<%= aiAction %>">
        <textarea id="aiMessage" class="form-control" rows="3" maxlength="2000"
          placeholder="请输入你的问题，例如：帮我检查当前流程有什么风险、生成一段公告、优化选题申请理由..."></textarea>
        <div class="d-flex justify-content-between align-items-center mt-2">
          <div class="text-muted small">权限隔离：<%= EscapeUtil.html(aiRole) %> / userId=<%= aiUser.getId() %></div>
          <div>
            <button type="button" id="aiClearBtn" class="btn btn-outline-secondary btn-sm">清空会话</button>
            <button type="submit" id="aiSendBtn" class="btn btn-primary btn-sm">发送</button>
          </div>
        </div>
      </form>
    </div>
  </div>
  <div class="col-lg-4">
    <div class="content-card">
      <h5>推荐问题</h5>
      <div class="d-grid gap-2">
        <% if (aiPrompts != null) { for (int i = 0; i < aiPrompts.length; i++) { %>
          <button type="button" class="btn btn-outline-primary btn-sm text-start ai-prompt"
            data-prompt="<%= EscapeUtil.attr(aiPrompts[i]) %>"><%= EscapeUtil.html(aiPrompts[i]) %></button>
        <% }} %>
      </div>
    </div>
    <div class="content-card">
      <h5>隔离规则</h5>
      <ul class="small text-muted mb-0">
        <li>管理员、教师、学生分别访问各自路径和后端接口；系主任按教师角色继承教师端能力。</li>
        <li>AI 上下文按 <code>role + userId</code> 存放在当前 Session。</li>
        <li>同级用户之间不共享 AI 历史，例如学生 A 和学生 B 完全分开。</li>
        <li>接口层再次校验当前账号角色，越权请求会被拒绝。</li>
      </ul>
    </div>
  </div>
</div>

<script>
window.GDMS_AI_CONFIG = {
  action: '<%= EscapeUtil.js(aiAction) %>'
};
</script>
