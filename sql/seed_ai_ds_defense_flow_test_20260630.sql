-- 人工智能学部 / 数据科学与大数据技术专业流程测试数据
-- 覆盖：
-- 1) 第一轮三志愿全部被拒绝/未匹配
-- 2) 第一轮顺利填报并匹配课题
-- 3) 终稿已通过，等待系主任安排答辩
-- 4) 已安排答辩但三教师均分低于 60，答辩未通过
-- 5) 已安排答辩且三教师均分达到 60 及以上，答辩通过
--
-- 所有测试账号密码均为 123456。脚本可重复执行，只清理 dsflow_ 用户相关流程数据和
-- “DS流程测试-”前缀课题，不影响其它专业或非测试数据。

USE graduation_design;
SET NAMES utf8mb4;

START TRANSACTION;

SET @pwd := 'e10adc3949ba59abbe56e057f20f883e';
SET @college := 'ai';
SET @major := 'ds';
SET @topic_prefix := 'DS流程测试-%';

SET @u_rejected := 'dsflow_rejected';
SET @u_selected := 'dsflow_selected';
SET @u_final_ready := 'dsflow_final_ready';
SET @u_defense_fail := 'dsflow_defense_fail';
SET @u_defense_pass := 'dsflow_defense_pass';

SET @director := (SELECT id FROM users WHERE username='director_ai_ds' AND role='director' LIMIT 1);
SET @teacher_main := (SELECT id FROM users WHERE username='teacher_ds' AND role='teacher' LIMIT 1);
SET @teacher_second := (SELECT id FROM users WHERE username='test1' AND role='teacher' LIMIT 1);
SET @teacher_third := (SELECT id FROM users WHERE username='director_ds' AND role='director' LIMIT 1);

-- 清理本脚本自己的流程数据，确保重复执行后状态一致。
DELETE FROM defense_scores
WHERE schedule_id IN (
  SELECT id FROM defense_schedules
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
  )
);

DELETE FROM defense_committee_members
WHERE schedule_id IN (
  SELECT id FROM defense_schedules
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
  )
);

DELETE FROM defense_schedules
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
);

DELETE FROM document_versions
WHERE document_id IN (
  SELECT id FROM documents
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
  )
);

DELETE FROM documents
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
);

DELETE FROM topic_assignments
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM topic_selections
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM selection_choices
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM selection_applications
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
);

DELETE FROM topics WHERE title LIKE @topic_prefix;

-- 创建/刷新五个学生账号。
INSERT INTO users(username,password,role,real_name,title,student_no,college,major,class_name,department,email,phone,status)
VALUES
(@u_rejected,@pwd,'student','流程测试-一志愿全拒','学生','2026063001',@college,@major,'数据科学与大数据技术1班','人工智能学部','dsflow_rejected@example.test','18800063001',1),
(@u_selected,@pwd,'student','流程测试-顺利选题','学生','2026063002',@college,@major,'数据科学与大数据技术1班','人工智能学部','dsflow_selected@example.test','18800063002',1),
(@u_final_ready,@pwd,'student','流程测试-待安排答辩','学生','2026063003',@college,@major,'数据科学与大数据技术1班','人工智能学部','dsflow_final_ready@example.test','18800063003',1),
(@u_defense_fail,@pwd,'student','流程测试-答辩未过','学生','2026063004',@college,@major,'数据科学与大数据技术1班','人工智能学部','dsflow_defense_fail@example.test','18800063004',1),
(@u_defense_pass,@pwd,'student','流程测试-答辩已过','学生','2026063005',@college,@major,'数据科学与大数据技术1班','人工智能学部','dsflow_defense_pass@example.test','18800063005',1)
ON DUPLICATE KEY UPDATE
  password=VALUES(password),
  role=VALUES(role),
  real_name=VALUES(real_name),
  title=VALUES(title),
  student_no=VALUES(student_no),
  college=VALUES(college),
  major=VALUES(major),
  class_name=VALUES(class_name),
  department=VALUES(department),
  email=VALUES(email),
  phone=VALUES(phone),
  status=VALUES(status);

SET @s_rejected := (SELECT id FROM users WHERE username=@u_rejected LIMIT 1);
SET @s_selected := (SELECT id FROM users WHERE username=@u_selected LIMIT 1);
SET @s_final_ready := (SELECT id FROM users WHERE username=@u_final_ready LIMIT 1);
SET @s_defense_fail := (SELECT id FROM users WHERE username=@u_defense_fail LIMIT 1);
SET @s_defense_pass := (SELECT id FROM users WHERE username=@u_defense_pass LIMIT 1);

-- 创建流程测试课题。三个“备选课题”用于模拟志愿被老师拒绝/未接收。
INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-第一志愿被拒绝课题A','用于测试学生第一轮三志愿全部未匹配：志愿1未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_rej_1 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-第二志愿被拒绝课题B','用于测试学生第一轮三志愿全部未匹配：志愿2未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_rej_2 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-第三志愿被拒绝课题C','用于测试学生第一轮三志愿全部未匹配：志愿3未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_rej_3 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-顺利匹配课题','用于测试第一轮第一志愿被指导教师接收并生成最终课题。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_selected := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-终稿通过待答辩课题','用于测试学生终稿已通过，进入系主任待安排答辩列表。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_final_ready := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-答辩未通过课题','用于测试已安排三名教师且均分低于60的答辩未通过状态。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_fail := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES
('DS流程测试-答辩已通过课题','用于测试已安排三名教师且均分达到60的答辩通过状态。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核开放',@director,NOW(),NOW());
SET @topic_pass := LAST_INSERT_ID();

-- 场景1：第一轮三志愿全部未被接收，学生无最终课题。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s_rejected,1,'expired',DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY));
SET @app_rejected := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_rejected,@s_rejected,@topic_rej_1,1,1,'not_selected',DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY)),
(@app_rejected,@s_rejected,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY)),
(@app_rejected,@s_rejected,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY));

-- 场景2：第一轮第一志愿顺利匹配。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s_selected,1,'confirmed',DATE_SUB(NOW(),INTERVAL 18 DAY),DATE_SUB(NOW(),INTERVAL 17 DAY));
SET @app_selected := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_selected,@s_selected,@topic_selected,1,1,'selected',DATE_SUB(NOW(),INTERVAL 18 DAY),DATE_SUB(NOW(),INTERVAL 17 DAY)),
(@app_selected,@s_selected,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 18 DAY),DATE_SUB(NOW(),INTERVAL 17 DAY)),
(@app_selected,@s_selected,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 18 DAY),DATE_SUB(NOW(),INTERVAL 17 DAY));
SET @choice_selected := (SELECT id FROM selection_choices WHERE application_id=@app_selected AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s_selected,@topic_selected,@choice_selected,1,'round1',@teacher_main,'测试数据：第一轮第一志愿由指导教师接收。',DATE_SUB(NOW(),INTERVAL 17 DAY));

-- 场景3：已匹配课题，开题/中期/终稿均通过，等待系主任安排三名答辩教师。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s_final_ready,1,'confirmed',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY));
SET @app_final_ready := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_final_ready,@s_final_ready,@topic_final_ready,1,1,'selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY)),
(@app_final_ready,@s_final_ready,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY)),
(@app_final_ready,@s_final_ready,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY));
SET @choice_final_ready := (SELECT id FROM selection_choices WHERE application_id=@app_final_ready AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s_final_ready,@topic_final_ready,@choice_final_ready,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，已进入终稿通过待答辩。',DATE_SUB(NOW(),INTERVAL 29 DAY));

INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s_final_ready,@topic_final_ready,'proposal','DS流程测试-待安排答辩-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 25 DAY),DATE_SUB(NOW(),INTERVAL 24 DAY),@teacher_main),
(@s_final_ready,@topic_final_ready,'midterm','DS流程测试-待安排答辩-中期检查','中期检查测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 15 DAY),DATE_SUB(NOW(),INTERVAL 14 DAY),@teacher_main),
(@s_final_ready,@topic_final_ready,'final','DS流程测试-待安排答辩-终稿/结题材料','终稿测试内容，已由指导教师审核通过。','reviewed',86.00,'指导教师评价：终稿通过，可进入评阅和答辩安排。','指导教师评价：终稿通过，可进入评阅和答辩安排。',86.00,'指导教师评价：终稿通过，可进入评阅和答辩安排。',@teacher_second,84.00,'评阅教师意见：论文结构完整，数据处理过程较清楚。','评阅教师意见：论文结构完整，数据处理过程较清楚。',DATE_SUB(NOW(),INTERVAL 3 DAY),DATE_SUB(NOW(),INTERVAL 5 DAY),DATE_SUB(NOW(),INTERVAL 4 DAY),@teacher_main);

-- 场景4：已安排答辩，三名教师评分均分低于 60，未通过。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s_defense_fail,1,'confirmed',DATE_SUB(NOW(),INTERVAL 34 DAY),DATE_SUB(NOW(),INTERVAL 33 DAY));
SET @app_fail := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_fail,@s_defense_fail,@topic_fail,1,1,'selected',DATE_SUB(NOW(),INTERVAL 34 DAY),DATE_SUB(NOW(),INTERVAL 33 DAY)),
(@app_fail,@s_defense_fail,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 34 DAY),DATE_SUB(NOW(),INTERVAL 33 DAY)),
(@app_fail,@s_defense_fail,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 34 DAY),DATE_SUB(NOW(),INTERVAL 33 DAY));
SET @choice_fail := (SELECT id FROM selection_choices WHERE application_id=@app_fail AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s_defense_fail,@topic_fail,@choice_fail,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，后续答辩未通过。',DATE_SUB(NOW(),INTERVAL 33 DAY));

INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s_defense_fail,@topic_fail,'proposal','DS流程测试-答辩未过-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 28 DAY),DATE_SUB(NOW(),INTERVAL 27 DAY),@teacher_main),
(@s_defense_fail,@topic_fail,'midterm','DS流程测试-答辩未过-中期检查','中期检查测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 18 DAY),DATE_SUB(NOW(),INTERVAL 17 DAY),@teacher_main),
(@s_defense_fail,@topic_fail,'final','DS流程测试-答辩未过-终稿/结题材料','终稿测试内容，已由指导教师审核通过。','reviewed',72.00,'指导教师评价：终稿基本通过，但系统完成度仍需提升。','指导教师评价：终稿基本通过，但系统完成度仍需提升。',72.00,'指导教师评价：终稿基本通过，但系统完成度仍需提升。',@teacher_second,68.00,'评阅教师意见：论文结构基本完整，但实验和分析偏弱。','评阅教师意见：论文结构基本完整，但实验和分析偏弱。',DATE_SUB(NOW(),INTERVAL 6 DAY),DATE_SUB(NOW(),INTERVAL 8 DAY),DATE_SUB(NOW(),INTERVAL 7 DAY),@teacher_main);

INSERT INTO defense_schedules(student_id,score,comment,created_at)
VALUES(@s_defense_fail,57.33,'测试数据：三名教师均分低于60，答辩未通过。',DATE_SUB(NOW(),INTERVAL 3 DAY));
SET @schedule_fail := LAST_INSERT_ID();
INSERT INTO defense_committee_members(schedule_id,teacher_id,member_order)
VALUES
(@schedule_fail,@teacher_main,1),
(@schedule_fail,@teacher_second,2),
(@schedule_fail,@teacher_third,3);
INSERT INTO defense_scores(schedule_id,teacher_id,score,comment,score_time)
VALUES
(@schedule_fail,@teacher_main,55.00,'陈述结构不完整，核心实现解释不足。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_fail,@teacher_second,58.00,'数据分析过程较弱，答问不充分。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_fail,@teacher_third,59.00,'系统完成度不足，未达到通过要求。',DATE_SUB(NOW(),INTERVAL 2 DAY));
UPDATE defense_schedules
SET score=(SELECT AVG(score) FROM defense_scores WHERE schedule_id=@schedule_fail)
WHERE id=@schedule_fail;

-- 场景5：已安排答辩，三名教师评分均分达到 60 及以上，通过。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s_defense_pass,1,'confirmed',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY));
SET @app_pass := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_pass,@s_defense_pass,@topic_pass,1,1,'selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY)),
(@app_pass,@s_defense_pass,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY)),
(@app_pass,@s_defense_pass,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY));
SET @choice_pass := (SELECT id FROM selection_choices WHERE application_id=@app_pass AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s_defense_pass,@topic_pass,@choice_pass,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，后续答辩通过。',DATE_SUB(NOW(),INTERVAL 35 DAY));

INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s_defense_pass,@topic_pass,'proposal','DS流程测试-答辩已过-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY),@teacher_main),
(@s_defense_pass,@topic_pass,'midterm','DS流程测试-答辩已过-中期检查','中期检查测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY),@teacher_main),
(@s_defense_pass,@topic_pass,'final','DS流程测试-答辩已过-终稿/结题材料','终稿测试内容，已由指导教师审核通过。','reviewed',91.00,'指导教师评价：终稿质量较好，系统实现完整。','指导教师评价：终稿质量较好，系统实现完整。',91.00,'指导教师评价：终稿质量较好，系统实现完整。',@teacher_second,89.00,'评阅教师意见：论文规范，工作量充足，技术路线合理。','评阅教师意见：论文规范，工作量充足，技术路线合理。',DATE_SUB(NOW(),INTERVAL 7 DAY),DATE_SUB(NOW(),INTERVAL 9 DAY),DATE_SUB(NOW(),INTERVAL 8 DAY),@teacher_main);

INSERT INTO defense_schedules(student_id,score,comment,created_at)
VALUES(@s_defense_pass,90.00,'测试数据：三名教师均分达到60及以上，答辩通过。',DATE_SUB(NOW(),INTERVAL 3 DAY));
SET @schedule_pass := LAST_INSERT_ID();
INSERT INTO defense_committee_members(schedule_id,teacher_id,member_order)
VALUES
(@schedule_pass,@teacher_main,1),
(@schedule_pass,@teacher_second,2),
(@schedule_pass,@teacher_third,3);
INSERT INTO defense_scores(schedule_id,teacher_id,score,comment,score_time)
VALUES
(@schedule_pass,@teacher_main,88.00,'系统实现完整，答辩表达清楚。',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(@schedule_pass,@teacher_second,90.00,'数据处理链路清晰，演示效果良好。',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(@schedule_pass,@teacher_third,92.00,'创新性和完成度较好，通过答辩。',DATE_SUB(NOW(),INTERVAL 1 DAY));
UPDATE defense_schedules
SET score=(SELECT AVG(score) FROM defense_scores WHERE schedule_id=@schedule_pass)
WHERE id=@schedule_pass;

COMMIT;

SELECT 'seed_ai_ds_defense_flow_test_20260630 applied' AS result;
SELECT username,real_name,student_no,college,major,status
FROM users
WHERE username IN (@u_rejected,@u_selected,@u_final_ready,@u_defense_fail,@u_defense_pass)
ORDER BY student_no;
