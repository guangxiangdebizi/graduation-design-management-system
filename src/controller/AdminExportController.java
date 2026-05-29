package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import bean.User;
import dbutil.SQLHelper;
import util.OperationLogUtil;
import util.WebUtil;

@WebServlet("/admin/export.action")
public class AdminExportController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");
        if (user == null || !"admin".equals(user.getRole())) {
            WebUtil.redirect(request, response, "/login.jsp");
            return;
        }

        List<Object[]> rows = SQLHelper.queryList(
            "SELECT u.student_no,u.real_name,u.department,t.title,ut.real_name,"
            + "(SELECT score FROM documents WHERE student_id=u.id AND doc_type='proposal' LIMIT 1),"
            + "(SELECT score FROM documents WHERE student_id=u.id AND doc_type='midterm' LIMIT 1),"
            + "(SELECT score FROM documents WHERE student_id=u.id AND doc_type='final' LIMIT 1),"
            + "ds.score,ds.defense_time,ds.room "
            + "FROM users u "
            + "JOIN topic_selections s ON s.student_id=u.id AND s.status='approved' "
            + "JOIN topics t ON s.topic_id=t.id "
            + "JOIN users ut ON t.teacher_id=ut.id "
            + "LEFT JOIN defense_schedules ds ON ds.student_id=u.id "
            + "WHERE u.role='student' ORDER BY u.student_no");

        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("成绩汇总");
        Row header = sheet.createRow(0);
        String[] titles = {"学号", "姓名", "院系", "课题", "指导教师",
            "开题分数", "中期分数", "终稿分数", "答辩分数", "答辩时间", "答辩教室"};
        for (int i = 0; i < titles.length; i++) {
            header.createCell(i).setCellValue(titles[i]);
        }

        for (int i = 0; i < rows.size(); i++) {
            Object[] row = rows.get(i);
            Row r = sheet.createRow(i + 1);
            r.createCell(0).setCellValue(row[0] == null ? "" : String.valueOf(row[0]));
            r.createCell(1).setCellValue(row[1] == null ? "" : String.valueOf(row[1]));
            r.createCell(2).setCellValue(row[2] == null ? "" : String.valueOf(row[2]));
            r.createCell(3).setCellValue(row[3] == null ? "" : String.valueOf(row[3]));
            r.createCell(4).setCellValue(row[4] == null ? "" : String.valueOf(row[4]));
            setScoreCell(r, 5, row[5]);
            setScoreCell(r, 6, row[6]);
            setScoreCell(r, 7, row[7]);
            setScoreCell(r, 8, row[8]);
            r.createCell(9).setCellValue(row[9] == null ? "" : String.valueOf(row[9]));
            r.createCell(10).setCellValue(row[10] == null ? "" : String.valueOf(row[10]));
        }
        for (int i = 0; i < titles.length; i++) {
            sheet.autoSizeColumn(i);
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=grades_export.xlsx");
        wb.write(response.getOutputStream());
        wb.close();
        OperationLogUtil.log(user.getId(), "EXPORT", "grades", "导出成绩 Excel");
    }

    private void setScoreCell(Row r, int col, Object val) {
        if (val == null) {
            r.createCell(col).setCellValue("");
        } else {
            r.createCell(col).setCellValue(new BigDecimal(val.toString()).doubleValue());
        }
    }
}
