package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import dao.DefenseScheduleDao;

@WebServlet("/student/defense.action")
public class StudentDefenseController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        request.setAttribute("pageTitle", "我的答辩");
        request.setAttribute("scheduleLoaded", Boolean.TRUE);
        request.setAttribute("schedule", new DefenseScheduleDao().findByStudent(user.getId()));
        request.getRequestDispatcher("/student/defense.jsp").forward(request, response);
    }
}
