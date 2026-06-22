-- 毕业设计管理系统 展示增强增量数据
-- 可重复执行：围绕 director=teacher+director-extra 的新权限模型补充更适合截图的过程数据。
USE graduation_design;
SET NAMES utf8mb4;

-- 1. 给计算机科学与技术专业补充学生，便于展示系主任的本专业统计和教师身份工作台。
INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('student41', 'e10adc3949ba59abbe56e057f20f883e', 'student', '高一鸣', '2022001041', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student41@stu.edu', '13900001041', 1),
('student42', 'e10adc3949ba59abbe56e057f20f883e', 'student', '林若溪', '2022001042', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student42@stu.edu', '13900001042', 1),
('student43', 'e10adc3949ba59abbe56e057f20f883e', 'student', '杜承泽', '2022001043', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student43@stu.edu', '13900001043', 1),
('student44', 'e10adc3949ba59abbe56e057f20f883e', 'student', '沈知夏', '2022001044', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student44@stu.edu', '13900001044', 1),
('student45', 'e10adc3949ba59abbe56e057f20f883e', 'student', '陆星河', '2022001045', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student45@stu.edu', '13900001045', 1),
('student46', 'e10adc3949ba59abbe56e057f20f883e', 'student', '唐嘉宁', '2022001046', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student46@stu.edu', '13900001046', 1),
('student47', 'e10adc3949ba59abbe56e057f20f883e', 'student', '叶思远', '2022001047', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student47@stu.edu', '13900001047', 1),
('student48', 'e10adc3949ba59abbe56e057f20f883e', 'student', '程安然', '2022001048', 'ai', 'cs', '计算机科学与技术2022级2班', '人工智能学部', 'student48@stu.edu', '13900001048', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

-- 2. 系主任本人作为教师提交课题，展示“系主任继承教师权限”的真实数据。
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '基于RBAC角色继承的毕业设计权限隔离系统',
       '围绕管理员、系主任、教师、学生四类角色，设计RBAC角色层级与本专业数据隔离机制。',
       u.id, 'ai', 'cs', 4, 0, 'open', '课题范围清晰，适合计算机科学与技术专业学生完成。', u.id, '2026-03-04 09:30:00'
FROM users u
WHERE u.username='director_ai_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='基于RBAC角色继承的毕业设计权限隔离系统' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '毕业设计全过程网络数据流追踪平台',
       '对登录、选题、文档上传、审核、统计导出等请求链路进行可视化追踪和安全审计。',
       u.id, 'ai', 'cs', 3, 0, 'open', '选题结合系统实际业务，建议重点说明请求生命周期。', u.id, '2026-03-05 10:00:00'
FROM users u
WHERE u.username='director_ai_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='毕业设计全过程网络数据流追踪平台' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '基于JSP与Servlet的课程设计自动归档系统',
       '实现课程设计报告、截图、源码、测试记录的一体化归档和下载。',
       u.id, 'ai', 'cs', 2, 0, 'pending'
FROM users u
WHERE u.username='director_ai_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='基于JSP与Servlet的课程设计自动归档系统' AND t.teacher_id=u.id);

-- 3. 围绕上述课题补充不同状态的选题申请。
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望研究RBAC角色层级和权限隔离的完整实现。', '同意选题，注意区分教师继承权限和管理员权限。', '2026-03-06 09:00:00', '2026-03-06 15:00:00'
FROM users s JOIN topics t ON t.title='基于RBAC角色继承的毕业设计权限隔离系统'
WHERE s.username='student41'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '对权限模型和数据隔离测试感兴趣，希望参与该方向。', '同意，后续重点补充测试用例。', '2026-03-06 09:20:00', '2026-03-06 15:10:00'
FROM users s JOIN topics t ON t.title='基于RBAC角色继承的毕业设计权限隔离系统'
WHERE s.username='student42'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望完成请求链路追踪和网络数据流分析模块。', '同意，注意保留关键网络请求证据。', '2026-03-07 10:00:00', '2026-03-07 16:00:00'
FROM users s JOIN topics t ON t.title='毕业设计全过程网络数据流追踪平台'
WHERE s.username='student43'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望做课程设计自动归档与报告管理方向。', NULL, '2026-05-25 09:30:00', NULL
FROM users s JOIN topics t ON t.title='基于JSP与Servlet的课程设计自动归档系统'
WHERE s.username='student44'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望参与归档系统的数据表和报告生成模块。', NULL, '2026-05-25 10:10:00', NULL
FROM users s JOIN topics t ON t.title='基于JSP与Servlet的课程设计自动归档系统'
WHERE s.username='student45'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'rejected', '希望申请权限隔离系统方向。', '该方向已有足够学生，建议选择网络数据流追踪方向。', '2026-03-08 09:00:00', '2026-03-08 14:00:00'
FROM users s JOIN topics t ON t.title='基于RBAC角色继承的毕业设计权限隔离系统'
WHERE s.username='student46'
  AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.topic_id=t.id);

-- 4. 补充阶段文档，展示教师端文档审核和学生端成绩页面。
INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'proposal', 'RBAC角色继承权限隔离系统开题报告',
       '本文从管理员、系主任、教师、学生四类角色出发，分析角色继承、菜单边界和后端鉴权策略。',
       CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 91.00, '需求分析完整，权限边界清晰。', '2026-03-20 10:00:00', '2026-03-22 09:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student41'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'midterm', 'RBAC角色继承权限隔离系统中期检查',
       '已完成RoleUtil、AuthFilter、教师端继承、系主任本专业作用域等核心实现。',
       CONCAT('uploads/', s.id, '/midterm.pdf'), 'reviewed', 89.00, '实现进度正常，建议补充越权测试。', '2026-05-12 14:30:00', '2026-05-13 09:30:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student41'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'final', 'RBAC角色继承权限隔离系统终稿',
       '系统已完成实现、数据隔离验证、截图采集和课程设计报告撰写。',
       CONCAT('uploads/', s.id, '/final.pdf'), 'submitted', NULL, NULL, '2026-06-16 11:30:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student41'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='final');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'proposal', '权限隔离测试用例设计开题报告',
       '围绕管理员、系主任、教师、学生构造正向访问和越权访问测试矩阵。',
       CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 88.00, '测试矩阵设计合理。', '2026-03-21 09:30:00', '2026-03-22 10:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student42'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'midterm', '权限隔离测试用例设计中期检查',
       '已完成权限矩阵、HTTP状态码验证和前端菜单可见性验证。',
       CONCAT('uploads/', s.id, '/midterm.pdf'), 'submitted', NULL, NULL, '2026-05-18 16:00:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student42'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'proposal', '网络数据流追踪平台开题报告',
       '从浏览器请求、Servlet路由、DAO访问、数据库事务和响应渲染角度梳理系统网络流。',
       CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 90.00, '网络流分析方向明确。', '2026-03-23 10:20:00', '2026-03-24 10:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student43'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'midterm', '网络数据流追踪平台中期检查',
       '已完成登录、选题、文档上传、统计接口的网络请求链路梳理。',
       CONCAT('uploads/', s.id, '/midterm.pdf'), 'reviewed', 87.00, '继续补充导出和消息模块链路。', '2026-05-14 15:40:00', '2026-05-15 09:20:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student43'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

-- 5. 版本、答辩、公告、消息、日志。
INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 1, d.title, d.content, REPLACE(d.file_path, '.pdf', '_v1.pdf'), DATE_SUB(d.submit_time, INTERVAL 3 DAY)
FROM documents d JOIN users s ON s.id=d.student_id
WHERE s.username IN ('student41','student42','student43')
  AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=1);

INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 2, d.title, d.content, d.file_path, d.submit_time
FROM documents d JOIN users s ON s.id=d.student_id
WHERE s.username IN ('student41','student42','student43') AND d.status IN ('reviewed','submitted')
  AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=2);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-26 09:00:00', '信息楼A401', '计算机科学与技术第一组', NULL, '请展示RBAC权限验证过程'
FROM users s WHERE s.username='student41'
  AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-26 10:00:00', '信息楼A401', '计算机科学与技术第一组', NULL, '请准备权限矩阵截图'
FROM users s WHERE s.username='student42'
  AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-26 11:00:00', '信息楼A401', '计算机科学与技术第一组', NULL, '请说明网络流和数据流关系'
FROM users s WHERE s.username='student43'
  AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO announcements(title, content, publisher_id, is_top, scope_type, college, major)
SELECT '计算机科学与技术专业答辩材料提交提醒',
       '请本专业学生在答辩前完成终稿、源代码、系统截图和测试记录提交。该公告由管理员按专业定向发布。',
       u.id, 1, 'major', 'ai', 'cs'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='计算机科学与技术专业答辩材料提交提醒');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT d.id, s.id, '终稿待完善提醒', '你的终稿已提交，下一步请补充测试截图和部署说明。', 0
FROM users d JOIN users s ON d.username='director_ai_cs' AND s.username='student41'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=d.id AND m.receiver_id=s.id AND m.title='终稿待完善提醒');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT s.id, d.id, '关于权限继承测试', '老师您好，系主任继承教师权限的测试用例是否需要覆盖消息和下载模块？', 0
FROM users s JOIN users d ON s.username='student42' AND d.username='director_ai_cs'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=s.id AND m.receiver_id=d.id AND m.title='关于权限继承测试');

INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'SEED_SHOWCASE', 'demo_data', '补充系主任教师身份与本专业管理展示数据'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM operation_logs l WHERE l.action='SEED_SHOWCASE' AND l.detail='补充系主任教师身份与本专业管理展示数据');

INSERT INTO file_templates(template_name, doc_type, description, file_path, original_filename, file_size, uploader_id, status)
SELECT '开题报告模板', 'proposal', '用于规范开题报告的研究背景、目标、技术路线和进度安排。',
       'uploads/templates/demo-proposal-template.docx', '开题报告模板.docx', 2048, u.id, 1
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM file_templates f WHERE f.file_path='uploads/templates/demo-proposal-template.docx');

INSERT INTO file_templates(template_name, doc_type, description, file_path, original_filename, file_size, uploader_id, status)
SELECT '中期检查模板', 'midterm', '用于提交阶段进度、已完成模块、存在问题和后续计划。',
       'uploads/templates/demo-midterm-template.docx', '中期检查模板.docx', 2048, u.id, 1
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM file_templates f WHERE f.file_path='uploads/templates/demo-midterm-template.docx');

INSERT INTO file_templates(template_name, doc_type, description, file_path, original_filename, file_size, uploader_id, status)
SELECT '毕业设计终稿模板', 'final', '用于规范论文终稿结构、摘要、目录、正文、参考文献和附录。',
       'uploads/templates/demo-final-template.docx', '毕业设计终稿模板.docx', 2048, u.id, 1
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM file_templates f WHERE f.file_path='uploads/templates/demo-final-template.docx');

-- 6. 重新计算课题已选人数，保持统计和列表一致。
UPDATE topics t
SET selected_count = (
    SELECT COUNT(*) FROM topic_selections s
    WHERE s.topic_id = t.id AND s.status = 'approved'
);

UPDATE topics
SET status = CASE
    WHEN status = 'pending' THEN 'pending'
    WHEN selected_count >= max_students THEN 'closed'
    ELSE 'open'
END;

SELECT
  (SELECT COUNT(*) FROM users WHERE username BETWEEN 'student41' AND 'student48') AS showcase_students,
  (SELECT COUNT(*) FROM topics t JOIN users u ON t.teacher_id=u.id WHERE u.username='director_ai_cs') AS director_teacher_topics,
  (SELECT COUNT(*) FROM topic_selections s JOIN topics t ON s.topic_id=t.id JOIN users u ON t.teacher_id=u.id WHERE u.username='director_ai_cs') AS director_teacher_selections,
  (SELECT COUNT(*) FROM announcements WHERE scope_type='major' AND college='ai' AND major='cs') AS cs_major_announcements,
  (SELECT COUNT(*) FROM file_templates WHERE status=1) AS active_file_templates;
