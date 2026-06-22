package controller;

import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import bean.User;
import util.OperationLogUtil;
import util.SystemSwitchUtil;
import util.WebUtil;

@WebServlet({"/admin/system-switch.action", "/admin/switch.action"})
public class AdminSystemSwitchController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("switchDefinitions", SystemSwitchUtil.definitions());
        request.setAttribute("switchStates", SystemSwitchUtil.currentStates());
        request.setAttribute("systemSwitches", SystemSwitchUtil.currentRawStates());
        request.getRequestDispatcher("/admin/system-switches.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("loginUser");
        Map<String, String> definitions = SystemSwitchUtil.definitions();
        int changed = 0;
        for (String key : definitions.keySet()) {
            boolean enabled = "1".equals(request.getParameter(key)) || "on".equals(request.getParameter(key));
            changed += SystemSwitchUtil.update(key, enabled);
        }
        OperationLogUtil.log(user.getId(), "UPDATE", "system_switch",
            "管理员更新全局系统开放状态 " + changed + " 项");
        WebUtil.redirect(request, response, "/admin/system-switch.action?msg=switch_ok");
    }
}
