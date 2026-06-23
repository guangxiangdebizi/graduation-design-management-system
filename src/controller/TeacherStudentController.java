package controller;

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
import bean.Document;
import bean.StudentProgress;
import bean.TopicSelection;
import bean.User;
import dao.DocumentDao;
import dao.SelectionDao;
import util.DictionaryUtil;

@WebServlet("/teacher/students.action")
public class TeacherStudentController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        DocumentDao documentDao = new DocumentDao();
        List<StudentProgress> progressList = new ArrayList<StudentProgress>();
        for (TopicSelection selection : new SelectionDao().findByTeacher(user.getId(), "approved")) {
            Map<String, Document> docMap = new HashMap<String, Document>();
            for (Document doc : documentDao.findByStudent(selection.getStudentId())) {
                docMap.put(doc.getDocType(), doc);
            }
            progressList.add(new StudentProgress(selection, docMap));
        }

        request.setAttribute("pageTitle", "学生进度");
        request.setAttribute("progressList", progressList);
        request.setAttribute("typeNames", DictionaryUtil.items("document_type"));
        request.getRequestDispatcher("/teacher/students.jsp").forward(request, response);
    }
}
