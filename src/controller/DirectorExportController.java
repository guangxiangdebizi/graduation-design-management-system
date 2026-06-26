package controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import bean.User;
import bean.UserScope;
import util.SQLHelper;
import util.OperationLogUtil;
import util.ScopeUtil;

@WebServlet("/director/export.action")
public class DirectorExportController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("loginUser");
        UserScope scope = ScopeUtil.directorScope(user);
        if (scope == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "director scope missing");
            return;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT u.student_no,u.real_name,u.department,t.title,ut.real_name,"
            + "(SELECT status FROM documents WHERE student_id=u.id AND doc_type='proposal' LIMIT 1),"
            + "(SELECT status FROM documents WHERE student_id=u.id AND doc_type='midterm' LIMIT 1),"
            + "(SELECT status FROM documents WHERE student_id=u.id AND doc_type='final' LIMIT 1),"
            + "(SELECT score FROM documents WHERE student_id=u.id AND doc_type='final' LIMIT 1),"
            + "(SELECT feedback FROM documents WHERE student_id=u.id AND doc_type='final' LIMIT 1),"
            + "ds.defense_time,ds.room "
            + "FROM users u "
            + "JOIN ("
            + "  SELECT student_id,topic_id FROM topic_assignments "
            + "  UNION SELECT student_id,topic_id FROM topic_selections WHERE status='approved'"
            + ") sel ON sel.student_id=u.id "
            + "JOIN topics t ON sel.topic_id=t.id "
            + "JOIN users ut ON t.teacher_id=ut.id "
            + "LEFT JOIN defense_schedules ds ON ds.student_id=u.id "
            + "WHERE u.role='student' "
            + "AND t.college=? AND t.major=? AND u.college=? AND u.major=? "
            + "ORDER BY u.student_no");
        List<Object> params = new ArrayList<Object>();
        params.add(scope.getCollege());
        params.add(scope.getMajor());
        params.add(scope.getCollege());
        params.add(scope.getMajor());
        List<Object[]> rows = SQLHelper.queryList(sql.toString(), params.toArray());

        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("本专业成绩汇总");
        Row header = sheet.createRow(0);
        String[] titles = {"学号", "姓名", "院系", "课题", "指导教师",
            "开题状态", "中期状态", "终稿/结题状态", "最终成绩", "导师评语", "答辩时间", "答辩教室"};
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
            r.createCell(5).setCellValue(statusText(row[5]));
            r.createCell(6).setCellValue(statusText(row[6]));
            r.createCell(7).setCellValue(statusText(row[7]));
            setScoreCell(r, 8, row[8]);
            r.createCell(9).setCellValue(row[9] == null ? "" : String.valueOf(row[9]));
            r.createCell(10).setCellValue(row[10] == null ? "" : String.valueOf(row[10]));
            r.createCell(11).setCellValue(row[11] == null ? "" : String.valueOf(row[11]));
        }
        for (int i = 0; i < titles.length; i++) {
            sheet.autoSizeColumn(i);
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=director_grades_export.xlsx");
        wb.write(response.getOutputStream());
        wb.close();
        OperationLogUtil.log(user.getId(), "EXPORT", "grades",
            "系主任导出本专业成绩 Excel: " + ScopeUtil.scopeText(scope));
    }

    private void setScoreCell(Row r, int col, Object val) {
        if (val == null) {
            r.createCell(col).setCellValue("");
        } else {
            r.createCell(col).setCellValue(new BigDecimal(val.toString()).doubleValue());
        }
    }

    private String statusText(Object val) {
        if (val == null) return "未提交";
        String status = String.valueOf(val);
        if ("submitted".equals(status)) return "待审核";
        if ("reviewed".equals(status)) return "已通过";
        if ("rejected".equals(status)) return "已退回";
        return status;
    }
}
