package controller;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
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
import bean.DefenseSchedule;
import bean.User;
import dao.DefenseScheduleDao;
import dao.UserDao;
import util.MessageNotifyUtil;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/defense-import.action")
@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 20971520)
public class AdminDefenseImportController extends HttpServlet {
    private final SimpleDateFormat[] formats = {
        new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"),
        new SimpleDateFormat("yyyy-MM-dd HH:mm"),
        new SimpleDateFormat("yyyy/MM/dd HH:mm")
    };

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        if (user == null || !"admin".equals(user.getRole())) {
            WebUtil.redirect(request, response, "/login.jsp");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=import_empty");
            return;
        }

        UserDao userDao = new UserDao();
        DefenseScheduleDao defenseDao = new DefenseScheduleDao();
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
                String studentNo = cellText(row.getCell(0), formatter);
                if (studentNo == null || studentNo.trim().isEmpty()) {
                    continue;
                }
                User student = userDao.findByStudentNo(studentNo.trim());
                if (student == null || !"student".equals(student.getRole())) {
                    errors.add("学号不存在: " + studentNo);
                    skipped++;
                    continue;
                }
                if (defenseDao.existsByStudent(student.getId())) {
                    errors.add("已有答辩安排: " + studentNo);
                    skipped++;
                    continue;
                }
                DefenseSchedule ds = new DefenseSchedule();
                ds.setStudentId(student.getId());
                ds.setDefenseTime(parseDate(cellText(row.getCell(1), formatter)));
                ds.setRoom(cellText(row.getCell(2), formatter));
                ds.setGroupName(cellText(row.getCell(3), formatter));
                ds.setComment(cellText(row.getCell(4), formatter));
                defenseDao.insert(ds);
                MessageNotifyUtil.send(student.getId(), "答辩安排通知",
                    "您的答辩已安排，时间: " + ds.getDefenseTime() + "，地点: " + ds.getRoom());
                success++;
            }
        } catch (Exception ex) {
            WebUtil.redirect(request, response, "/admin/defenses.jsp?msg=import_error");
            return;
        }

        OperationLogUtil.log(user.getId(), "IMPORT", "defense_schedule",
            "批量导入答辩: 成功" + success + "条, 跳过" + skipped + "条");
        WebUtil.redirect(request, response,
            "/admin/defenses.jsp?msg=import_ok&success=" + success + "&skipped=" + skipped);
    }

    private String cellText(Cell cell, DataFormatter formatter) {
        if (cell == null) {
            return null;
        }
        String val = formatter.formatCellValue(cell);
        return val == null ? null : val.trim();
    }

    private java.util.Date parseDate(String text) {
        if (text == null || text.isEmpty()) {
            return null;
        }
        for (SimpleDateFormat sdf : formats) {
            try {
                return sdf.parse(text);
            } catch (ParseException ignored) {
            }
        }
        return null;
    }
}
