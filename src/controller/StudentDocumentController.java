package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import bean.Document;
import bean.TopicSelection;
import bean.User;
import dao.DocumentDao;
import dao.SelectionDao;

@WebServlet("/student/document.action")
public class StudentDocumentController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        SelectionDao selDao = new SelectionDao();
        TopicSelection approved = selDao.findApprovedByStudent(user.getId());
        if (approved == null) {
            redirect(response, "documents.jsp?msg=no_topic");
            return;
        }

        Document doc = new Document();
        doc.setStudentId(user.getId());
        doc.setTopicId(approved.getTopicId());
        doc.setDocType(request.getParameter("docType"));
        doc.setTitle(request.getParameter("title"));
        doc.setContent(request.getParameter("content"));
        doc.setFilePath(request.getParameter("filePath"));

        DocumentDao docDao = new DocumentDao();
        docDao.submit(doc);
        redirect(response, "documents.jsp?msg=submit_ok&type=" + doc.getDocType());
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }
}
