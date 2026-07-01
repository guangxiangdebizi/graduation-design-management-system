package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.Message;
import bean.User;
import dao.MessageDao;
import util.MessageContactUtil;
import util.OperationLogUtil;
import util.PageUtil;
import util.RoleUtil;
import util.WebUtil;

@WebServlet({"/message.action", "/admin/messages.action", "/teacher/messages.action", "/student/messages.action"})
public class MessageController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        MessageDao dao = new MessageDao();
        String tab = request.getParameter("tab");
        if (!"sent".equals(tab)) {
            tab = "inbox";
        }
        int viewId = parseInt(request.getParameter("view"), 0);
        if (viewId > 0) {
            Message preView = dao.findByIdForUser(viewId, user.getId());
            if (preView != null && preView.getReceiverId() == user.getId()
                    && preView.getIsRead() == 0) {
                dao.markRead(preView.getId(), user.getId());
            }
        }

        int page = PageUtil.getPage(request);
        int pageSize = PageUtil.getPageSize(request);
        List<Message> messages;
        int total;
        if ("sent".equals(tab)) {
            messages = dao.findSent(user.getId());
            total = messages.size();
        } else {
            total = dao.countInbox(user.getId());
            messages = dao.findInboxPaged(user.getId(), page, pageSize);
        }

        String basePath = messagesPath(user);
        request.setAttribute("pageTitle", "站内消息");
        request.setAttribute("tab", tab);
        request.setAttribute("viewing", viewId > 0 ? dao.findByIdForUser(viewId, user.getId()) : null);
        request.setAttribute("messages", messages);
        request.setAttribute("total", Integer.valueOf(total));
        request.setAttribute("page", Integer.valueOf(page));
        request.setAttribute("pageSize", Integer.valueOf(pageSize));
        request.setAttribute("baseUrl", request.getContextPath() + basePath + "?tab=" + tab);
        request.setAttribute("contacts", MessageContactUtil.contactsFor(user));
        request.setAttribute("unreadMsg", Integer.valueOf(dao.countUnread(user.getId())));
        request.getRequestDispatcher(viewFor(user)).forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        String action = request.getParameter("action");
        MessageDao dao = new MessageDao();

        if ("send".equals(action)) {
            int receiverId = Integer.parseInt(request.getParameter("receiverId"));
            if (!MessageContactUtil.canSendTo(user, receiverId)) {
                WebUtil.redirect(request, response, messagesPath(user) + "?msg=forbidden");
                return;
            }

            Message msg = new Message();
            msg.setSenderId(user.getId());
            msg.setReceiverId(receiverId);
            msg.setTitle(request.getParameter("title"));
            msg.setContent(request.getParameter("content"));
            dao.insert(msg);

            OperationLogUtil.log(user.getId(), "SEND", "message",
                "发送消息给 userId=" + msg.getReceiverId());
            WebUtil.redirect(request, response, messagesPath(user) + "?msg=send_ok");
        } else if ("read".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.markRead(id, user.getId());
            WebUtil.redirect(request, response, messagesPath(user) + "?view=" + id);
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id, user.getId());
            OperationLogUtil.log(user.getId(), "DELETE", "message", "删除消息 id=" + id);
            WebUtil.redirect(request, response, messagesPath(user) + "?msg=delete_ok");
        } else {
            WebUtil.redirect(request, response, messagesPath(user));
        }
    }

    private String messagesPath(User user) {
        if ("admin".equals(user.getRole())) {
            return "/admin/messages.action";
        }
        if (RoleUtil.hasRole(user, "teacher")) {
            return "/teacher/messages.action";
        }
        return "/student/messages.action";
    }

    private String viewFor(User user) {
        if ("admin".equals(user.getRole())) {
            return "/admin/messages.jsp";
        }
        if (RoleUtil.hasRole(user, "teacher")) {
            return "/teacher/messages.jsp";
        }
        return "/student/messages.jsp";
    }

    private int parseInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
