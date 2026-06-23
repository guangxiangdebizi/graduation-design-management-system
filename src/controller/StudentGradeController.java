package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.DefenseSchedule;
import bean.Document;
import bean.User;
import dao.DefenseScheduleDao;
import dao.DocumentDao;
import util.DictionaryUtil;

@WebServlet("/student/grades.action")
public class StudentGradeController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        List<Document> docs = new DocumentDao().findByStudent(user.getId());
        DefenseSchedule defense = new DefenseScheduleDao().findByStudent(user.getId());
        Map<String, Document> docMap = new HashMap<String, Document>();
        for (Document doc : docs) {
            docMap.put(doc.getDocType(), doc);
        }

        request.setAttribute("pageTitle", "我的成绩");
        request.setAttribute("docs", docs);
        request.setAttribute("defense", defense);
        request.setAttribute("docMap", docMap);
        request.setAttribute("typeNames", DictionaryUtil.items("document_type"));
        request.getRequestDispatcher("/student/grades.jsp").forward(request, response);
    }
}
