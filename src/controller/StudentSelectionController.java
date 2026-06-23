package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.SelectionDao;

@WebServlet("/student/my-selection.action")
public class StudentSelectionController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        request.setAttribute("pageTitle", "我的选题");
        request.setAttribute("selections", new SelectionDao().findByStudent(user.getId()));
        request.getRequestDispatcher("/student/my-selection.jsp").forward(request, response);
    }
}
