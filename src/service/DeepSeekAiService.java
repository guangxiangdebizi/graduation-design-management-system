package service;

import bean.AiChatMessage;
import bean.User;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import util.AiAccessUtil;
import util.EnvUtil;
import util.JsonUtil;

public class DeepSeekAiService {
    public interface ChunkConsumer {
        void accept(String chunk) throws Exception;
    }

    public String chat(User user, String role, List<AiChatMessage> history, String message)
            throws Exception {
        String apiKey = EnvUtil.get("DEEPSEEK_API_KEY");
        if (apiKey == null || apiKey.length() == 0) {
            throw new IllegalStateException("AI 服务未配置 API Key");
        }

        String apiUrl = normalizeUrl(EnvUtil.get("DEEPSEEK_API_URL",
            "https://api.deepseek.com/chat/completions"));
        String model = EnvUtil.get("DEEPSEEK_MODEL", "deepseek-v4-pro");
        int timeout = EnvUtil.getInt("DEEPSEEK_TIMEOUT_MS", 30000);

        String payload = buildPayload(user, role, history, message, false, model);

        HttpURLConnection conn = (HttpURLConnection) new URL(apiUrl).openConnection();
        conn.setConnectTimeout(timeout);
        conn.setReadTimeout(timeout);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);

        OutputStream out = conn.getOutputStream();
        out.write(payload.getBytes(StandardCharsets.UTF_8));
        out.flush();
        out.close();

        int status = conn.getResponseCode();
        String body = readAll(status >= 400 ? conn.getErrorStream() : conn.getInputStream());
        if (status >= 400) {
            throw new IllegalStateException("AI 接口返回 " + status + ": " + truncate(body, 300));
        }
        return parseReply(body);
    }

    public String streamChat(User user, String role, List<AiChatMessage> history, String message,
            ChunkConsumer consumer) throws Exception {
        String apiKey = EnvUtil.get("DEEPSEEK_API_KEY");
        if (apiKey == null || apiKey.length() == 0) {
            throw new IllegalStateException("AI 服务未配置 API Key");
        }

        String apiUrl = normalizeUrl(EnvUtil.get("DEEPSEEK_API_URL",
            "https://api.deepseek.com/chat/completions"));
        String model = EnvUtil.get("DEEPSEEK_MODEL", "deepseek-v4-pro");
        int timeout = EnvUtil.getInt("DEEPSEEK_TIMEOUT_MS", 30000);

        String payload = buildPayload(user, role, history, message, true, model);

        HttpURLConnection conn = (HttpURLConnection) new URL(apiUrl).openConnection();
        conn.setConnectTimeout(timeout);
        conn.setReadTimeout(timeout);
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Accept", "text/event-stream");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);

        OutputStream out = conn.getOutputStream();
        out.write(payload.getBytes(StandardCharsets.UTF_8));
        out.flush();
        out.close();

        int status = conn.getResponseCode();
        if (status >= 400) {
            String body = readAll(conn.getErrorStream());
            throw new IllegalStateException("AI 接口返回 " + status + ": " + truncate(body, 300));
        }

        StringBuilder full = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(
            conn.getInputStream(), StandardCharsets.UTF_8));
        try {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.startsWith("data:")) {
                    continue;
                }
                String data = line.substring(5).trim();
                if ("[DONE]".equals(data)) {
                    break;
                }
                String delta = parseStreamDelta(data);
                if (delta.length() > 0) {
                    full.append(delta);
                    consumer.accept(delta);
                }
            }
        } finally {
            reader.close();
        }
        return full.toString();
    }

    private String buildPayload(User user, String role, List<AiChatMessage> history,
            String message, boolean stream, String model) {
        StringBuilder sb = new StringBuilder();
        sb.append('{');
        sb.append("\"model\":").append(JsonUtil.quote(model)).append(',');
        sb.append("\"stream\":").append(stream).append(',');
        sb.append("\"temperature\":0.6,");
        sb.append("\"messages\":").append(buildMessages(user, role, history, message));
        sb.append('}');
        return sb.toString();
    }

    private String buildMessages(User user, String role, List<AiChatMessage> history, String message) {
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        appendMessage(sb, "system", systemPrompt(user, role), true);

        if (history != null) {
            for (AiChatMessage item : history) {
                if (item == null || item.getRole() == null || item.getContent() == null) {
                    continue;
                }
                appendMessage(sb, item.getRole(), item.getContent(), false);
            }
        }

        appendMessage(sb, "user", message, false);
        sb.append(']');
        return sb.toString();
    }

    private void appendMessage(StringBuilder sb, String role, String content, boolean first) {
        if (!first) {
            sb.append(',');
        }
        sb.append('{')
            .append("\"role\":").append(JsonUtil.quote(role)).append(',')
            .append("\"content\":").append(JsonUtil.quote(content))
            .append('}');
    }

    private String systemPrompt(User user, String role) {
        String roleName = AiAccessUtil.roleName(role);
        String username = user == null ? "" : user.getUsername();
        int userId = user == null ? 0 : user.getId();
        String base = "你是毕业设计管理系统中的" + roleName + "端 AI 助手。"
            + "当前会话只属于当前登录用户，用户ID=" + userId + "，用户名=" + username + "。"
            + "必须同时按角色和用户ID隔离上下文：不能泄露、推测或代替同级其他用户、其他角色用户的数据或操作。"
            + "不能输出 API Key、环境变量、服务器敏感配置。"
            + "回答使用中文，围绕毕业设计管理系统的实际业务，给出可执行、简洁的建议。";
        if ("admin".equals(role)) {
            return base + "你只能协助管理员进行用户管理、公告维护、答辩安排、数据统计、成绩导出、操作日志、系统管理问答。"
                + "涉及教师或学生个人数据时，只能从管理员合法管理视角给通用建议，不假设能读取未提供的数据。";
        }
        if ("teacher".equals(role)) {
            return base + "你只能协助当前教师进行课题发布、选题审批、文档评阅、学生进度跟踪、答辩安排查看和教学管理问答。"
                + "不得提供管理员后台操作，也不得处理其他教师的私有课题或学生数据。";
        }
        return base + "你只能协助当前学生进行课题选择、申请理由、开题/中期/终稿写作、进度规划、成绩与答辩准备问答。"
            + "不得提供教师审批、管理员后台、其他学生账号或越权操作建议。";
    }

    private String parseReply(String body) {
        String content = JsonUtil.extractString(body, "content");
        return content.length() == 0 ? "AI 接口没有返回消息内容。" : content;
    }

    private String parseStreamDelta(String data) {
        String content = JsonUtil.extractString(data, "content");
        return content.length() > 0 ? content : JsonUtil.extractString(data, "reasoning_content");
    }

    private String normalizeUrl(String value) {
        String url = value == null ? "" : value.trim();
        if (url.length() == 0) {
            return "https://api.deepseek.com/chat/completions";
        }
        if (url.endsWith("/chat/completions")) {
            return url;
        }
        if (url.endsWith("/")) {
            return url + "chat/completions";
        }
        return url + "/chat/completions";
    }

    private String readAll(InputStream in) throws Exception {
        if (in == null) {
            return "";
        }
        BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        return sb.toString();
    }

    private String truncate(String text, int max) {
        if (text == null) {
            return "";
        }
        return text.length() <= max ? text : text.substring(0, max) + "...";
    }
}
