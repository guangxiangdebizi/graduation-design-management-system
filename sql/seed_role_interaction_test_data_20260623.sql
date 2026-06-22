-- 毕业设计管理系统 角色交互测试数据
-- 目标：为管理员、系主任、教师、学生四类用户准备可重复执行的前端交互测试账号和关联数据。
-- 重点覆盖：有数据、无数据、待审核、已通过、已驳回、已提交文档、已安排答辩等状态。
USE graduation_design;
SET NAMES utf8mb4;

-- 1. 管理员和空范围系主任账号。
INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('admin_audit', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '审计管理员', NULL, NULL, NULL, NULL, '教务处', 'admin_audit@school.edu', '13800000101', 1),
('admin_ops', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '运维管理员', NULL, NULL, NULL, NULL, '教务处', 'admin_ops@school.edu', '13800000102', 1),
('director_ee_power', 'e10adc3949ba59abbe56e057f20f883e', 'director', '电力系统方向系主任', NULL, 'ee', 'power', NULL, '电气工程学部', 'director_ee_power@school.edu', '13800000103', 1),
('director_arts_history', 'e10adc3949ba59abbe56e057f20f883e', 'director', '历史学方向系主任', NULL, 'arts', 'history', NULL, '文科学部', 'director_arts_history@school.edu', '13800000104', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

-- 2. 教师账号：一个有完整流程数据，一个有待审核数据，一个完全空数据。
INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('teacher_test_cs', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '测试计算机教师', NULL, 'ai', 'cs', NULL, '人工智能学部', 'teacher_test_cs@school.edu', '13800000111', 1),
('teacher_test_ai', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '测试人工智能教师', NULL, 'ai', 'ai', NULL, '人工智能学部', 'teacher_test_ai@school.edu', '13800000112', 1),
('teacher_empty_cs', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '空数据教师', NULL, 'ai', 'cs', NULL, '人工智能学部', 'teacher_empty_cs@school.edu', '13800000113', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

-- 3. 学生账号：完整流程、待审核、无选题、驳回后空状态、跨专业空范围测试。
INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('student81', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试完整流程学生', '2022001081', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student81@stu.edu', '13900001081', 1),
('student82', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试待审选题学生', '2022001082', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student82@stu.edu', '13900001082', 1),
('student83', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试未选题学生', '2022001083', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student83@stu.edu', '13900001083', 1),
('student84', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试驳回选题学生', '2022001084', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student84@stu.edu', '13900001084', 1),
('student85', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试人工智能完整流程学生', '2022001085', 'ai', 'ai', '人工智能2022级交互测试班', '人工智能学部', 'student85@stu.edu', '13900001085', 1),
('student86', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试电力无课题学生', '2022001086', 'ee', 'power', '电力系统2022级交互测试班', '电气工程学部', 'student86@stu.edu', '13900001086', 1),
('student87', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试历史无课题学生', '2022001087', 'arts', 'history', '历史学2022级交互测试班', '文科学部', 'student87@stu.edu', '13900001087', 1),
('student88', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试教师审批动作学生', '2022001088', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student88@stu.edu', '13900001088', 1),
('student89', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试文档审核动作学生', '2022001089', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student89@stu.edu', '13900001089', 1),
('student90', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试消息联动学生', '2022001090', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student90@stu.edu', '13900001090', 1),
('student91', 'e10adc3949ba59abbe56e057f20f883e', 'student', '测试学生申请动作学生', '2022001091', 'ai', 'cs', '计算机科学与技术2022级交互测试班', '人工智能学部', 'student91@stu.edu', '13900001091', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

-- 4. 测试课题。
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：计算机专业完整流程课题',
       '用于验证学生选题、文档提交、教师审核、系主任统计和导出之间的一致性。',
       u.id, 'ai', 'cs', 3, 0, 'open', '测试课题，准予开放。', d.id, '2026-03-18 09:00:00'
FROM users u JOIN users d ON d.username='director_ai_cs'
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：计算机专业完整流程课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：计算机专业待审选题课题',
       '用于验证教师端待审选题列表、学生端待审状态和系主任统计。',
       u.id, 'ai', 'cs', 2, 0, 'open', '测试课题，准予开放。', d.id, '2026-03-18 09:10:00'
FROM users u JOIN users d ON d.username='director_ai_cs'
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：计算机专业待审选题课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '交互测试：教师新提交待系主任审核课题',
       '用于验证系主任本专业课题审核列表是否只显示本专业待审课题。',
       u.id, 'ai', 'cs', 2, 0, 'pending'
FROM users u
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：教师新提交待系主任审核课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：人工智能专业完整流程课题',
       '用于验证人工智能专业系主任统计不会混入计算机专业数据。',
       u.id, 'ai', 'ai', 3, 0, 'open', '测试课题，准予开放。', d.id, '2026-03-18 09:20:00'
FROM users u JOIN users d ON d.username='director_ai_ai'
WHERE u.username='teacher_test_ai'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：人工智能专业完整流程课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：教师审批动作课题',
       '专门用于真实前端动作测试：教师批准待审选题，不影响基础样例账号状态。',
       u.id, 'ai', 'cs', 3, 0, 'open', '动作测试课题，准予开放。', d.id, '2026-03-18 09:30:00'
FROM users u JOIN users d ON d.username='director_ai_cs'
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：教师审批动作课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：文档审核动作课题',
       '专门用于真实前端动作测试：教师审核学生提交文档，不影响基础样例账号状态。',
       u.id, 'ai', 'cs', 3, 0, 'open', '动作测试课题，准予开放。', d.id, '2026-03-18 09:40:00'
FROM users u JOIN users d ON d.username='director_ai_cs'
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：文档审核动作课题' AND t.teacher_id=u.id);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT '交互测试：消息联动课题',
       '专门用于真实前端动作测试：学生与指导教师互发站内消息。',
       u.id, 'ai', 'cs', 3, 0, 'open', '动作测试课题，准予开放。', d.id, '2026-03-18 09:50:00'
FROM users u JOIN users d ON d.username='director_ai_cs'
WHERE u.username='teacher_test_cs'
  AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='交互测试：消息联动课题' AND t.teacher_id=u.id);

-- 5. 选题申请。
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '用于完整流程测试，已通过选题。', '同意选题，进入文档阶段。', '2026-03-20 09:00:00', '2026-03-20 15:00:00'
FROM users s JOIN topics t ON t.title='交互测试：计算机专业完整流程课题'
WHERE s.username='student81'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '用于学生端和教师端待审核选题测试。', NULL, '2026-05-26 09:00:00', NULL
FROM users s JOIN topics t ON t.title='交互测试：计算机专业待审选题课题'
WHERE s.username='student82'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'rejected', '用于学生端驳回状态测试。', '测试驳回，不形成活跃选题。', '2026-03-22 09:00:00', '2026-03-22 15:00:00'
FROM users s JOIN topics t ON t.title='交互测试：计算机专业完整流程课题'
WHERE s.username='student84'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.topic_id=t.id);

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '用于人工智能专业完整流程测试。', '同意选题。', '2026-03-23 09:00:00', '2026-03-23 15:00:00'
FROM users s JOIN topics t ON t.title='交互测试：人工智能专业完整流程课题'
WHERE s.username='student85'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '动作测试：等待教师在前端批准该选题。', NULL, '2026-03-24 09:00:00', NULL
FROM users s JOIN topics t ON t.title='交互测试：教师审批动作课题'
WHERE s.username='student88'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '动作测试：已通过选题，用于文档审核。', '同意选题，进入文档审核动作测试。', '2026-03-24 09:10:00', '2026-03-24 15:00:00'
FROM users s JOIN topics t ON t.title='交互测试：文档审核动作课题'
WHERE s.username='student89'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '动作测试：已通过选题，用于学生和教师互发消息。', '同意选题，进入消息动作测试。', '2026-03-24 09:20:00', '2026-03-24 15:10:00'
FROM users s JOIN topics t ON t.title='交互测试：消息联动课题'
WHERE s.username='student90'
  AND NOT EXISTS (SELECT 1 FROM topic_selections old WHERE old.student_id=s.id AND old.status IN ('pending','approved'));

-- 6. 文档、版本和答辩。
INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, t.id, 'proposal', '交互测试计算机完整流程开题报告', '验证开题报告已评阅状态。', CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 87.00, '开题通过。', '2026-03-28 09:00:00', '2026-03-29 09:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student81'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, t.id, 'midterm', '交互测试计算机完整流程中期检查', '验证中期报告待教师审核状态。', CONCAT('uploads/', s.id, '/midterm.pdf'), 'submitted', NULL, NULL, '2026-05-26 10:00:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student81'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, t.id, 'proposal', '交互测试人工智能完整流程开题报告', '验证人工智能专业数据隔离。', CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 93.00, '开题质量较好。', '2026-03-28 10:00:00', '2026-03-29 10:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student85'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, t.id, 'proposal', '交互测试文档审核动作开题报告', '动作测试：等待教师在前端通过并评分。', CONCAT('uploads/', s.id, '/proposal.pdf'), 'submitted', NULL, NULL, '2026-03-28 11:00:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username='student89'
  AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 1, d.title, d.content, REPLACE(d.file_path, '.pdf', '_v1.pdf'), DATE_SUB(d.submit_time, INTERVAL 1 DAY)
FROM documents d JOIN users s ON s.id=d.student_id
WHERE s.username IN ('student81','student85','student89')
  AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=1);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-29 09:00:00', '信息楼T101', '交互测试计算机组', NULL, '用于学生端答辩安排显示测试'
FROM users s WHERE s.username='student81'
  AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-29 10:00:00', '信息楼T102', '交互测试人工智能组', 92.00, '用于人工智能专业答辩成绩统计测试'
FROM users s WHERE s.username='student85'
  AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

-- 7. 公告、消息、日志。
INSERT INTO announcements(title, content, publisher_id, is_top, scope_type, college, major)
SELECT '交互测试：计算机专业定向公告', '用于验证计算机专业学生、教师、系主任是否能看到本专业公告。', u.id, 0, 'major', 'ai', 'cs'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='交互测试：计算机专业定向公告');

INSERT INTO announcements(title, content, publisher_id, is_top, scope_type, college, major)
SELECT '交互测试：人工智能专业定向公告', '用于验证人工智能专业公告不会显示到计算机专业。', u.id, 0, 'major', 'ai', 'ai'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='交互测试：人工智能专业定向公告');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT t.id, s.id, '交互测试文档反馈', '你的中期报告已收到，请等待教师审核。', 0
FROM users t JOIN users s ON t.username='teacher_test_cs' AND s.username='student81'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=t.id AND m.receiver_id=s.id AND m.title='交互测试文档反馈');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT s.id, t.id, '交互测试选题咨询', '老师您好，我的选题还在待审核状态，请问是否需要补充材料？', 0
FROM users s JOIN users t ON s.username='student82' AND t.username='teacher_test_cs'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=s.id AND m.receiver_id=t.id AND m.title='交互测试选题咨询');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT t.id, s.id, '交互测试消息动作待读', '用于验证学生打开消息详情后已读状态变化。', 0
FROM users t JOIN users s ON t.username='teacher_test_cs' AND s.username='student90'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=t.id AND m.receiver_id=s.id AND m.title='交互测试消息动作待读');

-- 8. 动作测试账号恢复到可重复交互的基准状态。
UPDATE topic_selections s JOIN users u ON u.id=s.student_id
SET s.status='pending', s.review_comment=NULL, s.review_time=NULL
WHERE u.username='student88';

UPDATE documents d JOIN users u ON u.id=d.student_id
SET d.status='submitted', d.score=NULL, d.feedback=NULL, d.review_time=NULL, d.reviewer_id=NULL
WHERE u.username='student89' AND d.doc_type='proposal';

UPDATE messages m JOIN users r ON r.id=m.receiver_id
SET m.is_read=0
WHERE r.username='student90' AND m.title='交互测试消息动作待读';

DELETE m FROM messages m
LEFT JOIN users s ON s.id=m.sender_id
LEFT JOIN users r ON r.id=m.receiver_id
WHERE m.title LIKE 'action-test-%'
   OR (m.title IN ('选题审批结果','文档审核结果')
       AND r.username IN ('student88','student89'));

DELETE sel FROM topic_selections sel
JOIN users u ON u.id=sel.student_id
WHERE u.username='student91';

INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'SEED_ROLE_INTERACTION', 'demo_data', '补充四类角色前端交互测试数据'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (
    SELECT 1 FROM operation_logs l
    WHERE l.action='SEED_ROLE_INTERACTION' AND l.detail='补充四类角色前端交互测试数据'
  );

UPDATE topics t
SET selected_count = (
    SELECT COUNT(*) FROM topic_selections s
    WHERE s.topic_id = t.id AND s.status = 'approved'
);

UPDATE topics
SET status = CASE
    WHEN status = 'pending' THEN 'pending'
    WHEN status = 'rejected' THEN 'rejected'
    WHEN selected_count >= max_students THEN 'closed'
    ELSE 'open'
END;

SELECT
  (SELECT COUNT(*) FROM users WHERE username IN ('admin_audit','admin_ops','director_ee_power','director_arts_history','teacher_test_cs','teacher_test_ai','teacher_empty_cs','student81','student82','student83','student84','student85','student86','student87','student88','student89','student90','student91')) AS test_users,
  (SELECT COUNT(*) FROM topics WHERE title LIKE '交互测试：%') AS test_topics,
  (SELECT COUNT(*) FROM topic_selections s JOIN users u ON s.student_id=u.id WHERE u.username BETWEEN 'student81' AND 'student90') AS test_selections,
  (SELECT COUNT(*) FROM documents d JOIN users u ON d.student_id=u.id WHERE u.username IN ('student81','student85','student89')) AS test_documents,
  (SELECT COUNT(*) FROM defense_schedules d JOIN users u ON d.student_id=u.id WHERE u.username IN ('student81','student85')) AS test_defenses;
