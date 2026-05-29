package controller;



import java.io.IOException;

import javax.servlet.ServletException;

import javax.servlet.annotation.WebServlet;

import javax.servlet.http.HttpServlet;

import javax.servlet.http.HttpServletRequest;

import javax.servlet.http.HttpServletResponse;

import javax.servlet.http.HttpSession;

import bean.Message;

import bean.TopicSelection;

import bean.User;

import dao.MessageDao;

import dao.SelectionDao;

import dao.TopicDao;

import dao.UserDao;

import util.OperationLogUtil;

import util.WebUtil;



@WebServlet("/message.action")

public class MessageController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)

            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("loginUser");

        String action = request.getParameter("action");

        MessageDao dao = new MessageDao();



        if ("send".equals(action)) {

            int receiverId = Integer.parseInt(request.getParameter("receiverId"));

            if (!canSendTo(user, receiverId)) {

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



    private boolean canSendTo(User sender, int receiverId) {

        UserDao userDao = new UserDao();

        User receiver = userDao.findById(receiverId);

        if (receiver == null) {

            return false;

        }

        if ("admin".equals(sender.getRole())) {

            return true;

        }

        if ("teacher".equals(sender.getRole())) {

            return "student".equals(receiver.getRole()) || "admin".equals(receiver.getRole());

        }

        if ("student".equals(sender.getRole())) {

            if ("admin".equals(receiver.getRole())) {

                return true;

            }

            SelectionDao selDao = new SelectionDao();

            TopicSelection approved = selDao.findApprovedByStudent(sender.getId());

            if (approved == null) {

                return false;

            }

            bean.Topic topic = new TopicDao().findById(approved.getTopicId());

            return topic != null && receiver.getId() == topic.getTeacherId();

        }

        return false;

    }



    private String messagesPath(User user) {

        if ("admin".equals(user.getRole())) {

            return "/admin/messages.jsp";

        }

        if ("teacher".equals(user.getRole())) {

            return "/teacher/messages.jsp";

        }

        return "/student/messages.jsp";

    }

}

