package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.DefenseScheduleDao;

@WebServlet("/teacher/defense.action")
public class TeacherDefenseController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        request.setAttribute("pageTitle", "答辩安排");
        request.setAttribute("schedules", new DefenseScheduleDao().findByTeacher(user.getId()));
        request.getRequestDispatcher("/teacher/defense.jsp").forward(request, response);
    }
}
