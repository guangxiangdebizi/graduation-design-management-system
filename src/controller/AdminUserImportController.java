package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import bean.User;
import dao.UserDao;
import util.CollegeUtil;
import util.DictionaryUtil;
import util.OperationLogUtil;
import util.SystemConfigUtil;
import util.WebUtil;

@WebServlet("/admin/user-import.action")
@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 20971520)
public class AdminUserImportController extends HttpServlet {
    private static final String DEFAULT_PASSWORD = "123456";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null || !"admin".equals(loginUser.getRole())) {
            WebUtil.redirect(request, response, "/login.jsp");
            return;
        }

        String importRole = normalize(request.getParameter("importRole"));
        if (!"teacher".equals(importRole) && !"student".equals(importRole)) {
            WebUtil.redirect(request, response, "/admin/user.action?msg=import_role_invalid");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            WebUtil.redirect(request, response, "/admin/user.action?msg=import_empty");
            return;
        }

        UserDao userDao = new UserDao();
        DataFormatter formatter = new DataFormatter();
        int success = 0;
        int skipped = 0;
        List<String> errors = new ArrayList<String>();

        try (Workbook wb = WorkbookFactory.create(filePart.getInputStream())) {
            Sheet sheet = wb.getSheetAt(0);
            Iterator<Row> it = sheet.iterator();
            if (it.hasNext()) {
                it.next();
            }
            while (it.hasNext()) {
                Row row = it.next();
                if (row == null || isEmptyRow(row, formatter)) {
                    continue;
                }
                String username = normalize(cellText(row.getCell(0), formatter));
                String realName = normalize(cellText(row.getCell(1), formatter));
                String studentNo = normalize(cellText(row.getCell(2), formatter));
                String college = normalize(cellText(row.getCell(3), formatter));
                String major = normalize(cellText(row.getCell(4), formatter));
                String className = normalize(cellText(row.getCell(5), formatter));
                String department = normalize(cellText(row.getCell(6), formatter));
                String email = normalize(cellText(row.getCell(7), formatter));
                String phone = normalize(cellText(row.getCell(8), formatter));
                String password = normalize(cellText(row.getCell(9), formatter));
                String title = normalize(cellText(row.getCell(10), formatter));

                if (username == null) {
                    username = "student".equals(importRole) ? studentNo : null;
                }
                if (password == null) {
                    password = DEFAULT_PASSWORD;
                }
                if (username == null || realName == null) {
                    skipped++;
                    errors.add("第 " + (row.getRowNum() + 1) + " 行缺少用户名或姓名");
                    continue;
                }
                if ("student".equals(importRole) && studentNo == null) {
                    skipped++;
                    errors.add("第 " + (row.getRowNum() + 1) + " 行缺少学号");
                    continue;
                }
                if (!validPassword(password)) {
                    skipped++;
                    errors.add("第 " + (row.getRowNum() + 1) + " 行密码长度不足");
                    continue;
                }
                if (userDao.existsByUsername(username)) {
                    skipped++;
                    errors.add("用户名已存在: " + username);
                    continue;
                }
                if ("student".equals(importRole) && studentNo != null
                        && userDao.existsByStudentNoExcludeId(studentNo, 0)) {
                    skipped++;
                    errors.add("学号已存在: " + studentNo);
                    continue;
                }

                User u = new User();
                u.setUsername(username);
                u.setPassword(password);
                u.setRole(importRole);
                u.setRealName(realName);
                u.setTitle(title != null ? title : defaultTitle(importRole));
                u.setStudentNo("student".equals(importRole) ? studentNo : null);
                u.setCollege(college);
                u.setMajor(major);
                u.setClassName("student".equals(importRole) ? className : null);
                u.setDepartment(department != null ? department : collegeName(college));
                u.setEmail(email);
                u.setPhone(phone);
                u.setStatus(1);
                int id = userDao.insert(u);
                if (id > 0) {
                    success++;
                } else {
                    skipped++;
                    errors.add("第 " + (row.getRowNum() + 1) + " 行写入失败");
                }
            }
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/admin/user.action?msg=import_error");
            return;
        }

        OperationLogUtil.log(loginUser.getId(), "IMPORT", "user",
            "批量导入" + DictionaryUtil.label("role", importRole)
                + ": 成功" + success + "条, 跳过" + skipped + "条");
        if (!errors.isEmpty()) {
            session.setAttribute("userImportErrors", errors);
        } else {
            session.removeAttribute("userImportErrors");
        }
        WebUtil.redirect(request, response,
            "/admin/user.action?msg=import_ok&success=" + success + "&skipped=" + skipped);
    }

    private boolean isEmptyRow(Row row, DataFormatter formatter) {
        for (int i = 0; i <= 10; i++) {
            if (normalize(cellText(row.getCell(i), formatter)) != null) {
                return false;
            }
        }
        return true;
    }

    private String cellText(Cell cell, DataFormatter formatter) {
        if (cell == null) {
            return null;
        }
        String val = formatter.formatCellValue(cell);
        return val == null ? null : val.trim();
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String text = value.trim();
        return text.isEmpty() ? null : text;
    }

    private boolean validPassword(String password) {
        int minLength = SystemConfigUtil.getInt("validation.password_min_length", 6);
        return password != null && password.length() >= minLength;
    }

    private String collegeName(String college) {
        if (college == null) {
            return null;
        }
        return CollegeUtil.getCollegeName(college);
    }

    private String defaultTitle(String role) {
        if ("student".equals(role)) {
            return "学生";
        }
        if ("teacher".equals(role)) {
            return "教师";
        }
        return null;
    }
}
