package controller;

import bean.AiChatMessage;
import bean.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import service.DeepSeekAiService;
import util.AiAccessUtil;
import util.EnvUtil;
import util.JsonUtil;
import util.OperationLogUtil;
import util.RoleUtil;

@WebServlet({"/admin/ai.action", "/teacher/ai.action", "/student/ai.action"})
public class AiAssistantController extends HttpServlet {
    private static final int MAX_INPUT_LENGTH = 2000;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            response.setContentType("application/json;charset=UTF-8");
            writeJson(response, false, "请先登录后再使用 AI 助手。", null);
            return;
        }

        String pathRole = AiAccessUtil.roleFromPath(request.getServletPath());
        if (!RoleUtil.hasRole(user, pathRole)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            writeJson(response, false, "当前账号无权访问该角色的 AI 助手。", null);
            return;
        }

        String action = trim(request.getParameter("action"));
        if ("clear".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            session.removeAttribute(AiAccessUtil.sessionKey(user));
            OperationLogUtil.log(user.getId(), "AI_CLEAR", user.getRole(),
                user.getUsername() + " 清空" + AiAccessUtil.roleName(pathRole) + "端 AI 会话");
            writeJson(response, true, "已清空当前用户的 AI 会话。", "");
            return;
        }

        String message = trim(request.getParameter("message"));
        if (message.length() == 0) {
            response.setContentType("application/json;charset=UTF-8");
            writeJson(response, false, "请输入要咨询的问题。", null);
            return;
        }
        if (message.length() > MAX_INPUT_LENGTH) {
            response.setContentType("application/json;charset=UTF-8");
            writeJson(response, false, "问题过长，请控制在 " + MAX_INPUT_LENGTH + " 字以内。", null);
            return;
        }

        List<AiChatMessage> history = getHistory(session, user);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/event-stream;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Connection", "keep-alive");
        response.setHeader("X-Accel-Buffering", "no");
        try {
            final HttpServletResponse streamResponse = response;
            String reply = new DeepSeekAiService().streamChat(user, pathRole, history, message,
                new DeepSeekAiService.ChunkConsumer() {
                    public void accept(String chunk) throws Exception {
                        writeEvent(streamResponse, "delta", chunk);
                    }
                });
            history.add(new AiChatMessage("user", message));
            history.add(new AiChatMessage("assistant", reply));
            trimHistory(history);
            session.setAttribute(AiAccessUtil.sessionKey(user), history);
            OperationLogUtil.log(user.getId(), "AI_CHAT", user.getRole(),
                user.getUsername() + " 使用" + AiAccessUtil.roleName(pathRole) + "端 AI 助手");
            writeEvent(response, "done", "");
        } catch (Exception ex) {
            writeEvent(response, "error", safeError(ex));
        }
    }

    @SuppressWarnings("unchecked")
    private List<AiChatMessage> getHistory(HttpSession session, User user) {
        Object value = session.getAttribute(AiAccessUtil.sessionKey(user));
        if (value instanceof List) {
            return (List<AiChatMessage>) value;
        }
        return new ArrayList<AiChatMessage>();
    }

    private void trimHistory(List<AiChatMessage> history) {
        int max = EnvUtil.getInt("DEEPSEEK_MAX_HISTORY_MESSAGES", 12);
        if (max < 2) {
            max = 2;
        }
        while (history.size() > max) {
            history.remove(0);
        }
    }

    private void writeJson(HttpServletResponse response, boolean ok, String message, String reply)
            throws IOException {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("ok", ok);
        data.put("message", message);
        if (reply != null) {
            data.put("reply", reply);
        }
        response.getWriter().print(JsonUtil.object(data));
    }

    private void writeEvent(HttpServletResponse response, String event, String data)
            throws IOException {
        Map<String, Object> payload = new HashMap<String, Object>();
        payload.put("event", event);
        payload.put("data", data == null ? "" : data);
        response.getWriter().write("data: " + JsonUtil.object(payload) + "\n\n");
        response.getWriter().flush();
    }

    private String safeError(Exception ex) {
        String msg = ex == null ? "" : ex.getMessage();
        if (msg == null || msg.trim().length() == 0) {
            return "AI 服务调用失败，请稍后重试。";
        }
        if (msg.contains("API Key")) {
            return "AI 服务未配置 API Key，请检查本地 .env。";
        }
        return "AI 服务调用失败：" + msg.replaceAll("sk-[A-Za-z0-9]+", "sk-***");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
