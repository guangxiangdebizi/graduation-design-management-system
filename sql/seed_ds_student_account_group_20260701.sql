-- 数据科学与大数据技术专业学生测试账号组
-- 覆盖从“志愿审批前/未通过”到“材料提交、终稿评阅、答辩未过/已过”的完整链路。
-- 所有账号密码均为 123456。
--
-- 账号说明：
-- student_ds00：尚未填报任何志愿，无最终课题、无阶段材料
-- student_ds01：第一轮三志愿均未被教师接收，无最终课题
-- student_ds02：已通过选题，处于前中期材料阶段
-- student_ds03：已答辩，三名教师均分低于 60，答辩未通过
-- student_ds04：已答辩，三名教师均分达到 60 及以上，答辩通过
-- student_ds05：第一轮三志愿已提交，等待对应教师审批
-- student_ds06：已通过选题，开题/中期已过，终稿已提交待指导教师审核
-- student_ds07：终稿已通过并完成评阅，等待系主任安排答辩
-- student_ds08：两轮后由系主任兜底分配课题，尚未提交阶段材料
--
-- 脚本可重复执行：只清理 student_ds00~student_ds08 及 “DS账号组测试-” 前缀课题相关流程数据。

USE graduation_design;
SET NAMES utf8mb4;

START TRANSACTION;

SET @pwd := 'e10adc3949ba59abbe56e057f20f883e';
SET @college := 'ai';
SET @major := 'ds';
SET @class_name := '数据科学与大数据技术2022级测试班';
SET @department := '人工智能学部';
SET @topic_prefix := 'DS账号组测试-%';

SET @u00 := 'student_ds00';
SET @u01 := 'student_ds01';
SET @u02 := 'student_ds02';
SET @u03 := 'student_ds03';
SET @u04 := 'student_ds04';
SET @u05 := 'student_ds05';
SET @u06 := 'student_ds06';
SET @u07 := 'student_ds07';
SET @u08 := 'student_ds08';

SET @director := (SELECT id FROM users WHERE username='director_ds' AND role='director' LIMIT 1);
SET @teacher_main := (SELECT id FROM users WHERE username='teacher_ds' AND role='teacher' LIMIT 1);
SET @teacher_second := (SELECT id FROM users WHERE username='test1' AND role='teacher' LIMIT 1);
SET @teacher_third := (SELECT id FROM users WHERE username='director_ai_ds' AND role='director' LIMIT 1);

-- 清理本账号组旧流程数据，确保重复执行后状态一致。
DELETE FROM defense_scores
WHERE schedule_id IN (
  SELECT id FROM defense_schedules
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
  )
);

DELETE FROM defense_committee_members
WHERE schedule_id IN (
  SELECT id FROM defense_schedules
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
  )
);

DELETE FROM defense_schedules
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
);

DELETE FROM document_versions
WHERE document_id IN (
  SELECT id FROM documents
  WHERE student_id IN (
    SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
  )
);

DELETE FROM documents
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
);

DELETE FROM topic_assignments
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM topic_selections
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM selection_choices
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
)
OR topic_id IN (SELECT id FROM topics WHERE title LIKE @topic_prefix);

DELETE FROM selection_applications
WHERE student_id IN (
  SELECT id FROM users WHERE username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
);

DELETE FROM topics WHERE title LIKE @topic_prefix;

-- 创建/刷新学生账号。
INSERT INTO users(username,password,role,real_name,title,student_no,college,major,class_name,department,email,phone,status)
VALUES
(@u00,@pwd,'student','DS00-未填报志愿','学生','2026070100',@college,@major,@class_name,@department,'student_ds00@example.test','18807010100',1),
(@u01,@pwd,'student','DS01-志愿未通过','学生','2026070101',@college,@major,@class_name,@department,'student_ds01@example.test','18807010101',1),
(@u02,@pwd,'student','DS02-前中期材料','学生','2026070102',@college,@major,@class_name,@department,'student_ds02@example.test','18807010102',1),
(@u03,@pwd,'student','DS03-答辩未通过','学生','2026070103',@college,@major,@class_name,@department,'student_ds03@example.test','18807010103',1),
(@u04,@pwd,'student','DS04-答辩已通过','学生','2026070104',@college,@major,@class_name,@department,'student_ds04@example.test','18807010104',1),
(@u05,@pwd,'student','DS05-志愿待审批','学生','2026070105',@college,@major,@class_name,@department,'student_ds05@example.test','18807010105',1),
(@u06,@pwd,'student','DS06-终稿待审核','学生','2026070106',@college,@major,@class_name,@department,'student_ds06@example.test','18807010106',1),
(@u07,@pwd,'student','DS07-待安排答辩','学生','2026070107',@college,@major,@class_name,@department,'student_ds07@example.test','18807010107',1),
(@u08,@pwd,'student','DS08-主任兜底分配','学生','2026070108',@college,@major,@class_name,@department,'student_ds08@example.test','18807010108',1)
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

SET @s00 := (SELECT id FROM users WHERE username=@u00 LIMIT 1);
SET @s01 := (SELECT id FROM users WHERE username=@u01 LIMIT 1);
SET @s02 := (SELECT id FROM users WHERE username=@u02 LIMIT 1);
SET @s03 := (SELECT id FROM users WHERE username=@u03 LIMIT 1);
SET @s04 := (SELECT id FROM users WHERE username=@u04 LIMIT 1);
SET @s05 := (SELECT id FROM users WHERE username=@u05 LIMIT 1);
SET @s06 := (SELECT id FROM users WHERE username=@u06 LIMIT 1);
SET @s07 := (SELECT id FROM users WHERE username=@u07 LIMIT 1);
SET @s08 := (SELECT id FROM users WHERE username=@u08 LIMIT 1);

-- 公共候选课题：用于模拟三志愿全部未接收，以及已确认学生的第二/第三志愿落选。
INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-未接收候选课题A','用于 student_ds01 第一志愿未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_rej_1 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-未接收候选课题B','用于 student_ds01 第二志愿未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_rej_2 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-未接收候选课题C','用于 student_ds01 第三志愿未被接收。',@teacher_main,@college,@major,1,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_rej_3 := LAST_INSERT_ID();

-- student_ds05 的待审批三志愿课题，保持 pending choices，方便教师端直接看到待审批数据。
INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-待审批课题A','用于 student_ds05 第一志愿待教师审批。',@teacher_main,@college,@major,3,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_pending_1 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-待审批课题B','用于 student_ds05 第二志愿待教师审批。',@teacher_main,@college,@major,3,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_pending_2 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-待审批课题C','用于 student_ds05 第三志愿待教师审批。',@teacher_main,@college,@major,3,0,'open','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_pending_3 := LAST_INSERT_ID();

-- 已匹配/已分配学生的独立课题。
INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-前中期材料课题','用于 student_ds02：开题已通过，中期材料待审核。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds02 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-答辩未通过课题','用于 student_ds03：终稿评阅完成，答辩均分低于60。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds03 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-答辩已通过课题','用于 student_ds04：终稿评阅完成，答辩均分达到60以上。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds04 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-终稿待审核课题','用于 student_ds06：开题/中期通过，终稿已提交待指导教师审核。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds06 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-待安排答辩课题','用于 student_ds07：终稿通过并完成评阅，等待系主任安排答辩。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds07 := LAST_INSERT_ID();

INSERT INTO topics(title,description,teacher_id,college,major,max_students,selected_count,status,review_comment,reviewer_id,review_time,created_at)
VALUES('DS账号组测试-主任兜底分配课题','用于 student_ds08：两轮后由系主任手动兜底分配，尚未提交材料。',@teacher_main,@college,@major,1,1,'closed','测试数据：本专业审核通过。',@director,NOW(),NOW());
SET @topic_ds08 := LAST_INSERT_ID();

-- student_ds01：三志愿均未被教师接收，申请过期，无 topic_assignments。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s01,1,'expired',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY));
SET @app_ds01 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds01,@s01,@topic_rej_1,1,1,'not_selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY)),
(@app_ds01,@s01,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY)),
(@app_ds01,@s01,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY));

-- student_ds05：三志愿已提交，等待教师审批。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s05,1,'submitted',DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY));
SET @app_ds05 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds05,@s05,@topic_pending_1,1,1,'pending',DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY)),
(@app_ds05,@s05,@topic_pending_2,1,2,'pending',DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY)),
(@app_ds05,@s05,@topic_pending_3,1,3,'pending',DATE_SUB(NOW(),INTERVAL 1 DAY),DATE_SUB(NOW(),INTERVAL 1 DAY));

-- student_ds02：已确认课题，开题通过，中期材料已提交待审核。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s02,1,'confirmed',DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY));
SET @app_ds02 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds02,@s02,@topic_ds02,1,1,'selected',DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY)),
(@app_ds02,@s02,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY)),
(@app_ds02,@s02,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY));
SET @choice_ds02 := (SELECT id FROM selection_choices WHERE application_id=@app_ds02 AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s02,@topic_ds02,@choice_ds02,1,'round1',@teacher_main,'测试数据：第一轮第一志愿由指导教师接收。',DATE_SUB(NOW(),INTERVAL 25 DAY));
INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,submit_time,review_time,reviewer_id)
VALUES
(@s02,@topic_ds02,'proposal','DS02-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过，可以进入中期检查。',DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY),@teacher_main),
(@s02,@topic_ds02,'midterm','DS02-中期检查材料','中期材料测试内容。','submitted',NULL,NULL,DATE_SUB(NOW(),INTERVAL 3 DAY),NULL,NULL);

-- student_ds06：开题/中期已通过，终稿已提交待指导教师审核。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s06,1,'confirmed',DATE_SUB(NOW(),INTERVAL 32 DAY),DATE_SUB(NOW(),INTERVAL 31 DAY));
SET @app_ds06 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds06,@s06,@topic_ds06,1,1,'selected',DATE_SUB(NOW(),INTERVAL 32 DAY),DATE_SUB(NOW(),INTERVAL 31 DAY)),
(@app_ds06,@s06,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 32 DAY),DATE_SUB(NOW(),INTERVAL 31 DAY)),
(@app_ds06,@s06,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 32 DAY),DATE_SUB(NOW(),INTERVAL 31 DAY));
SET @choice_ds06 := (SELECT id FROM selection_choices WHERE application_id=@app_ds06 AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s06,@topic_ds06,@choice_ds06,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，终稿待审核。',DATE_SUB(NOW(),INTERVAL 31 DAY));
INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,submit_time,review_time,reviewer_id)
VALUES
(@s06,@topic_ds06,'proposal','DS06-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY),@teacher_main),
(@s06,@topic_ds06,'midterm','DS06-中期检查材料','中期材料测试内容。','reviewed',NULL,'中期通过。',DATE_SUB(NOW(),INTERVAL 16 DAY),DATE_SUB(NOW(),INTERVAL 15 DAY),@teacher_main),
(@s06,@topic_ds06,'final','DS06-终稿/结题材料','终稿测试内容，等待指导教师评分和评语。','submitted',NULL,NULL,DATE_SUB(NOW(),INTERVAL 2 DAY),NULL,NULL);

-- student_ds07：终稿已通过并完成评阅，等待系主任安排答辩。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s07,1,'confirmed',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY));
SET @app_ds07 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds07,@s07,@topic_ds07,1,1,'selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY)),
(@app_ds07,@s07,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY)),
(@app_ds07,@s07,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY));
SET @choice_ds07 := (SELECT id FROM selection_choices WHERE application_id=@app_ds07 AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s07,@topic_ds07,@choice_ds07,1,'round1',@teacher_main,'测试数据：终稿已通过并完成评阅，待系主任安排答辩。',DATE_SUB(NOW(),INTERVAL 35 DAY));
INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s07,@topic_ds07,'proposal','DS07-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 30 DAY),DATE_SUB(NOW(),INTERVAL 29 DAY),@teacher_main),
(@s07,@topic_ds07,'midterm','DS07-中期检查材料','中期材料测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 20 DAY),DATE_SUB(NOW(),INTERVAL 19 DAY),@teacher_main),
(@s07,@topic_ds07,'final','DS07-终稿/结题材料','终稿测试内容，已完成指导教师评分和论文评阅。','reviewed',86.00,'指导教师评价：终稿通过，可进入答辩安排。','指导教师评价：终稿通过，可进入答辩安排。',86.00,'指导教师评价：终稿通过，可进入答辩安排。',@teacher_second,84.00,'评阅教师意见：论文结构完整，系统实现较清楚。','评阅教师意见：论文结构完整，系统实现较清楚。',DATE_SUB(NOW(),INTERVAL 4 DAY),DATE_SUB(NOW(),INTERVAL 7 DAY),DATE_SUB(NOW(),INTERVAL 6 DAY),@teacher_main);

-- student_ds08：系主任兜底分配，尚未提交阶段材料。
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s08,@topic_ds08,NULL,2,'manual',@director,'测试数据：两轮后仍未匹配，由系主任兜底分配课题。',DATE_SUB(NOW(),INTERVAL 10 DAY));

-- student_ds03：答辩未通过。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s03,1,'confirmed',DATE_SUB(NOW(),INTERVAL 40 DAY),DATE_SUB(NOW(),INTERVAL 39 DAY));
SET @app_ds03 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds03,@s03,@topic_ds03,1,1,'selected',DATE_SUB(NOW(),INTERVAL 40 DAY),DATE_SUB(NOW(),INTERVAL 39 DAY)),
(@app_ds03,@s03,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 40 DAY),DATE_SUB(NOW(),INTERVAL 39 DAY)),
(@app_ds03,@s03,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 40 DAY),DATE_SUB(NOW(),INTERVAL 39 DAY));
SET @choice_ds03 := (SELECT id FROM selection_choices WHERE application_id=@app_ds03 AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s03,@topic_ds03,@choice_ds03,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，后续答辩未通过。',DATE_SUB(NOW(),INTERVAL 39 DAY));
INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s03,@topic_ds03,'proposal','DS03-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 34 DAY),DATE_SUB(NOW(),INTERVAL 33 DAY),@teacher_main),
(@s03,@topic_ds03,'midterm','DS03-中期检查材料','中期材料测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 24 DAY),DATE_SUB(NOW(),INTERVAL 23 DAY),@teacher_main),
(@s03,@topic_ds03,'final','DS03-终稿/结题材料','终稿测试内容，已通过指导教师审核并完成评阅。','reviewed',72.00,'指导教师评价：终稿基本通过，但系统完成度仍需提升。','指导教师评价：终稿基本通过，但系统完成度仍需提升。',72.00,'指导教师评价：终稿基本通过，但系统完成度仍需提升。',@teacher_second,68.00,'评阅教师意见：论文结构基本完整，但实验分析偏弱。','评阅教师意见：论文结构基本完整，但实验分析偏弱。',DATE_SUB(NOW(),INTERVAL 7 DAY),DATE_SUB(NOW(),INTERVAL 10 DAY),DATE_SUB(NOW(),INTERVAL 9 DAY),@teacher_main);
INSERT INTO defense_schedules(student_id,score,comment,created_at)
VALUES(@s03,57.33,'测试数据：三名教师均分低于60，答辩未通过。',DATE_SUB(NOW(),INTERVAL 3 DAY));
SET @schedule_ds03 := LAST_INSERT_ID();
INSERT INTO defense_committee_members(schedule_id,teacher_id,member_order)
VALUES
(@schedule_ds03,@teacher_main,1),
(@schedule_ds03,@teacher_second,2),
(@schedule_ds03,@teacher_third,3);
INSERT INTO defense_scores(schedule_id,teacher_id,score,comment,score_time)
VALUES
(@schedule_ds03,@teacher_main,55.00,'陈述结构不完整，核心实现解释不足。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_ds03,@teacher_second,58.00,'数据分析过程较弱，答问不充分。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_ds03,@teacher_third,59.00,'系统完成度不足，未达到通过要求。',DATE_SUB(NOW(),INTERVAL 2 DAY));
UPDATE defense_schedules
SET score=(SELECT AVG(score) FROM defense_scores WHERE schedule_id=@schedule_ds03)
WHERE id=@schedule_ds03;

-- student_ds04：答辩通过。
INSERT INTO selection_applications(student_id,round,status,submit_time,update_time)
VALUES(@s04,1,'confirmed',DATE_SUB(NOW(),INTERVAL 42 DAY),DATE_SUB(NOW(),INTERVAL 41 DAY));
SET @app_ds04 := LAST_INSERT_ID();
INSERT INTO selection_choices(application_id,student_id,topic_id,round,choice_rank,status,created_at,updated_at)
VALUES
(@app_ds04,@s04,@topic_ds04,1,1,'selected',DATE_SUB(NOW(),INTERVAL 42 DAY),DATE_SUB(NOW(),INTERVAL 41 DAY)),
(@app_ds04,@s04,@topic_rej_2,1,2,'not_selected',DATE_SUB(NOW(),INTERVAL 42 DAY),DATE_SUB(NOW(),INTERVAL 41 DAY)),
(@app_ds04,@s04,@topic_rej_3,1,3,'not_selected',DATE_SUB(NOW(),INTERVAL 42 DAY),DATE_SUB(NOW(),INTERVAL 41 DAY));
SET @choice_ds04 := (SELECT id FROM selection_choices WHERE application_id=@app_ds04 AND choice_rank=1 LIMIT 1);
INSERT INTO topic_assignments(student_id,topic_id,choice_id,round,source,confirmed_by,confirm_comment,confirm_time)
VALUES(@s04,@topic_ds04,@choice_ds04,1,'round1',@teacher_main,'测试数据：第一轮志愿匹配，后续答辩通过。',DATE_SUB(NOW(),INTERVAL 41 DAY));
INSERT INTO documents(student_id,topic_id,doc_type,title,content,status,score,feedback,self_review,advisor_score,advisor_comment,paper_reviewer_id,reviewer_score,reviewer_comment,peer_review,reviewer_review_time,submit_time,review_time,reviewer_id)
VALUES
(@s04,@topic_ds04,'proposal','DS04-开题报告','开题报告测试内容。','reviewed',NULL,'开题通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 36 DAY),DATE_SUB(NOW(),INTERVAL 35 DAY),@teacher_main),
(@s04,@topic_ds04,'midterm','DS04-中期检查材料','中期材料测试内容。','reviewed',NULL,'中期通过。',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATE_SUB(NOW(),INTERVAL 26 DAY),DATE_SUB(NOW(),INTERVAL 25 DAY),@teacher_main),
(@s04,@topic_ds04,'final','DS04-终稿/结题材料','终稿测试内容，已通过指导教师审核并完成评阅。','reviewed',91.00,'指导教师评价：终稿质量较好，系统实现完整。','指导教师评价：终稿质量较好，系统实现完整。',91.00,'指导教师评价：终稿质量较好，系统实现完整。',@teacher_second,89.00,'评阅教师意见：论文规范，工作量充足，技术路线合理。','评阅教师意见：论文规范，工作量充足，技术路线合理。',DATE_SUB(NOW(),INTERVAL 8 DAY),DATE_SUB(NOW(),INTERVAL 11 DAY),DATE_SUB(NOW(),INTERVAL 10 DAY),@teacher_main);
INSERT INTO defense_schedules(student_id,score,comment,created_at)
VALUES(@s04,90.00,'测试数据：三名教师均分达到60及以上，答辩通过。',DATE_SUB(NOW(),INTERVAL 3 DAY));
SET @schedule_ds04 := LAST_INSERT_ID();
INSERT INTO defense_committee_members(schedule_id,teacher_id,member_order)
VALUES
(@schedule_ds04,@teacher_main,1),
(@schedule_ds04,@teacher_second,2),
(@schedule_ds04,@teacher_third,3);
INSERT INTO defense_scores(schedule_id,teacher_id,score,comment,score_time)
VALUES
(@schedule_ds04,@teacher_main,88.00,'系统实现完整，答辩表达清楚。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_ds04,@teacher_second,90.00,'论文结构规范，答问较准确。',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(@schedule_ds04,@teacher_third,92.00,'创新性和完成度较好，通过答辩。',DATE_SUB(NOW(),INTERVAL 2 DAY));
UPDATE defense_schedules
SET score=(SELECT AVG(score) FROM defense_scores WHERE schedule_id=@schedule_ds04)
WHERE id=@schedule_ds04;

COMMIT;

-- 验收摘要。
SELECT
  u.username,
  u.real_name,
  u.student_no,
  COALESCE(t.title,'未确认课题') AS topic_title,
  COALESCE(a.source,'无') AS assignment_source,
  COALESCE(MAX(CASE WHEN d.doc_type='proposal' THEN d.status END),'无') AS proposal_status,
  COALESCE(MAX(CASE WHEN d.doc_type='midterm' THEN d.status END),'无') AS midterm_status,
  COALESCE(MAX(CASE WHEN d.doc_type='final' THEN d.status END),'无') AS final_status,
  MAX(CASE WHEN d.doc_type='final' THEN d.advisor_score END) AS advisor_score,
  MAX(CASE WHEN d.doc_type='final' THEN d.reviewer_score END) AS reviewer_score,
  ds.score AS defense_score,
  CASE
    WHEN ds.score IS NULL THEN '未答辩'
    WHEN ds.score >= 60 THEN '答辩通过'
    ELSE '答辩未通过'
  END AS defense_result
FROM users u
LEFT JOIN topic_assignments a ON a.student_id=u.id
LEFT JOIN topics t ON t.id=a.topic_id
LEFT JOIN documents d ON d.student_id=u.id
LEFT JOIN defense_schedules ds ON ds.student_id=u.id
WHERE u.username IN (@u00,@u01,@u02,@u03,@u04,@u05,@u06,@u07,@u08)
GROUP BY u.id,u.username,u.real_name,u.student_no,t.title,a.source,ds.score
ORDER BY u.username;
