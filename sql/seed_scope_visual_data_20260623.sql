-- 毕业设计管理系统 分专业可视化增强数据
-- 目标：让系主任统计页能清楚展示不同专业之间的数据差异，同时验证数据按 topics.college + topics.major 隔离。
-- 可重复执行。
USE graduation_design;
SET NAMES utf8mb4;

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('student49', 'e10adc3949ba59abbe56e057f20f883e', 'student', '秦知远', '2022001049', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student49@stu.edu', '13900001049', 1),
('student50', 'e10adc3949ba59abbe56e057f20f883e', 'student', '孟雨桐', '2022001050', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student50@stu.edu', '13900001050', 1),
('student51', 'e10adc3949ba59abbe56e057f20f883e', 'student', '许景然', '2022001051', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student51@stu.edu', '13900001051', 1),
('student52', 'e10adc3949ba59abbe56e057f20f883e', 'student', '韩若宁', '2022001052', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student52@stu.edu', '13900001052', 1),
('student53', 'e10adc3949ba59abbe56e057f20f883e', 'student', '邵明轩', '2022001053', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student53@stu.edu', '13900001053', 1),
('student54', 'e10adc3949ba59abbe56e057f20f883e', 'student', '汪可欣', '2022001054', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student54@stu.edu', '13900001054', 1),
('student55', 'e10adc3949ba59abbe56e057f20f883e', 'student', '毛子涵', '2022001055', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student55@stu.edu', '13900001055', 1),
('student56', 'e10adc3949ba59abbe56e057f20f883e', 'student', '潘思睿', '2022001056', 'ai', 'ai', '人工智能2022级2班', '人工智能学部', 'student56@stu.edu', '13900001056', 1),
('student57', 'e10adc3949ba59abbe56e057f20f883e', 'student', '宋一诺', '2022001057', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student57@stu.edu', '13900001057', 1),
('student58', 'e10adc3949ba59abbe56e057f20f883e', 'student', '姜亦辰', '2022001058', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student58@stu.edu', '13900001058', 1),
('student59', 'e10adc3949ba59abbe56e057f20f883e', 'student', '田语汐', '2022001059', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student59@stu.edu', '13900001059', 1),
('student60', 'e10adc3949ba59abbe56e057f20f883e', 'student', '方皓宇', '2022001060', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student60@stu.edu', '13900001060', 1),
('student61', 'e10adc3949ba59abbe56e057f20f883e', 'student', '任洛笙', '2022001061', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student61@stu.edu', '13900001061', 1),
('student62', 'e10adc3949ba59abbe56e057f20f883e', 'student', '戴清越', '2022001062', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student62@stu.edu', '13900001062', 1),
('student63', 'e10adc3949ba59abbe56e057f20f883e', 'student', '邱云舟', '2022001063', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student63@stu.edu', '13900001063', 1),
('student64', 'e10adc3949ba59abbe56e057f20f883e', 'student', '薛安琪', '2022001064', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'student64@stu.edu', '13900001064', 1),
('student65', 'e10adc3949ba59abbe56e057f20f883e', 'student', '贺星野', '2022001065', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student65@stu.edu', '13900001065', 1),
('student66', 'e10adc3949ba59abbe56e057f20f883e', 'student', '梁知微', '2022001066', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student66@stu.edu', '13900001066', 1),
('student67', 'e10adc3949ba59abbe56e057f20f883e', 'student', '钟景澄', '2022001067', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student67@stu.edu', '13900001067', 1),
('student68', 'e10adc3949ba59abbe56e057f20f883e', 'student', '傅南栀', '2022001068', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student68@stu.edu', '13900001068', 1),
('student69', 'e10adc3949ba59abbe56e057f20f883e', 'student', '尹嘉木', '2022001069', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student69@stu.edu', '13900001069', 1),
('student70', 'e10adc3949ba59abbe56e057f20f883e', 'student', '卢清禾', '2022001070', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student70@stu.edu', '13900001070', 1),
('student71', 'e10adc3949ba59abbe56e057f20f883e', 'student', '程亦白', '2022001071', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student71@stu.edu', '13900001071', 1),
('student72', 'e10adc3949ba59abbe56e057f20f883e', 'student', '石若菲', '2022001072', 'ai', 'ds', '数据科学与大数据技术2022级1班', '人工智能学部', 'student72@stu.edu', '13900001072', 1),
('student73', 'e10adc3949ba59abbe56e057f20f883e', 'student', '叶景行', '2022001073', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student73@stu.edu', '13900001073', 1),
('student74', 'e10adc3949ba59abbe56e057f20f883e', 'student', '顾清欢', '2022001074', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student74@stu.edu', '13900001074', 1),
('student75', 'e10adc3949ba59abbe56e057f20f883e', 'student', '陆闻舟', '2022001075', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student75@stu.edu', '13900001075', 1),
('student76', 'e10adc3949ba59abbe56e057f20f883e', 'student', '沈星眠', '2022001076', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student76@stu.edu', '13900001076', 1),
('student77', 'e10adc3949ba59abbe56e057f20f883e', 'student', '苏明澈', '2022001077', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student77@stu.edu', '13900001077', 1),
('student78', 'e10adc3949ba59abbe56e057f20f883e', 'student', '林知夏', '2022001078', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student78@stu.edu', '13900001078', 1),
('student79', 'e10adc3949ba59abbe56e057f20f883e', 'student', '夏予安', '2022001079', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student79@stu.edu', '13900001079', 1),
('student80', 'e10adc3949ba59abbe56e057f20f883e', 'student', '许长风', '2022001080', 'ai', 'cs', '计算机科学与技术2022级3班', '人工智能学部', 'student80@stu.edu', '13900001080', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status, review_comment, reviewer_id, review_time)
SELECT x.title, x.description, u.id, x.college, x.major, x.max_students, 0, x.status, x.review_comment, u.id, x.review_time
FROM (
  SELECT '多模态校园问答智能体' title, '融合文本、图片和校园知识库，构建面向学生服务的多模态问答智能体。' description, 'director_ai_ai' teacher_username, 'ai' college, 'ai' major, 4 max_students, 'open' status, '人工智能专业方向明确，准予开放选题。' review_comment, '2026-03-02 09:00:00' review_time
  UNION ALL SELECT 'AI模型推理服务监控平台', '对模型调用延迟、错误率、Token消耗和服务健康状态进行监控。', 'director_ai_ai', 'ai', 'ai', 3, 'open', '工程落地性强，适合作为毕业设计。', '2026-03-03 09:00:00'
  UNION ALL SELECT '计算机视觉缺陷检测系统', '基于目标检测和图像分类算法实现工业缺陷自动识别。', 'director_ai_ai', 'ai', 'ai', 3, 'open', '算法与应用场景结合较好。', '2026-03-04 09:00:00'
  UNION ALL SELECT '软件工程需求追踪与变更管理平台', '实现需求、任务、代码提交和测试用例之间的追踪关系。', 'director_ai_se', 'ai', 'se', 4, 'open', '符合软件工程专业培养目标。', '2026-03-05 09:00:00'
  UNION ALL SELECT 'DevOps持续集成质量看板', '聚合构建、测试、部署和缺陷数据，展示研发质量趋势。', 'director_ai_se', 'ai', 'se', 3, 'open', '项目过程数据完整，准予开放。', '2026-03-06 09:00:00'
  UNION ALL SELECT '微服务缺陷定位与回归测试系统', '围绕微服务调用链、日志和测试结果实现缺陷定位辅助。', 'director_ai_se', 'ai', 'se', 3, 'pending', NULL, NULL
  UNION ALL SELECT '数据科学就业画像分析系统', '基于招聘数据和学生能力标签分析就业岗位画像。', 'director_ai_ds', 'ai', 'ds', 4, 'open', '数据分析目标清晰，准予开放。', '2026-03-07 09:00:00'
  UNION ALL SELECT '大数据实时指标预警平台', '基于流式数据模拟业务指标监控、阈值预警和趋势分析。', 'director_ai_ds', 'ai', 'ds', 3, 'open', '体现大数据技术链路。', '2026-03-08 09:00:00'
  UNION ALL SELECT '教学质量数据仓库与可视化系统', '建设课程、作业、成绩、评教数据仓库并形成可视化分析。', 'director_ai_ds', 'ai', 'ds', 3, 'pending', NULL, NULL
  UNION ALL SELECT '操作系统实验自动评测平台', '实现实验提交、自动编译、测试用例运行和成绩反馈。', 'director_ai_cs', 'ai', 'cs', 4, 'open', '系统性强，适合计算机专业。', '2026-03-09 09:00:00'
  UNION ALL SELECT '分布式缓存一致性演示系统', '通过可视化方式演示缓存穿透、击穿、雪崩和一致性策略。', 'director_ai_cs', 'ai', 'cs', 3, 'open', '主题有工程价值，准予开放。', '2026-03-10 09:00:00'
  UNION ALL SELECT '代码架构与网络流可视化平台', '自动整理项目代码结构、请求链路和数据库访问链路。', 'director_ai_cs', 'ai', 'cs', 3, 'open', '与课程设计展示场景高度相关。', '2026-03-11 09:00:00'
) x
JOIN users u ON u.username=x.teacher_username
WHERE NOT EXISTS (
  SELECT 1 FROM topics t WHERE t.title=x.title AND t.teacher_id=u.id
);

INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, x.status, x.apply_reason, x.review_comment, x.apply_time, x.review_time
FROM (
  SELECT 'student49' username, '多模态校园问答智能体' title, 'approved' status, '希望完成知识库问答和多模态交互。' apply_reason, '同意选题，注意评测指标。' review_comment, '2026-03-12 09:00:00' apply_time, '2026-03-12 15:00:00' review_time
  UNION ALL SELECT 'student50', '多模态校园问答智能体', 'approved', '对大模型应用开发感兴趣。', '同意，重点补充提示词和检索链路。', '2026-03-12 09:20:00', '2026-03-12 15:10:00'
  UNION ALL SELECT 'student51', 'AI模型推理服务监控平台', 'approved', '希望做模型服务监控和指标展示。', '同意，注意数据采样设计。', '2026-03-12 10:00:00', '2026-03-12 16:00:00'
  UNION ALL SELECT 'student52', '计算机视觉缺陷检测系统', 'approved', '希望完成图像检测算法和Web演示。', '同意，注意训练数据说明。', '2026-03-13 09:00:00', '2026-03-13 14:30:00'
  UNION ALL SELECT 'student53', '计算机视觉缺陷检测系统', 'pending', '希望参与视觉检测系统开发。', NULL, '2026-05-20 09:00:00', NULL
  UNION ALL SELECT 'student54', 'AI模型推理服务监控平台', 'rejected', '希望申请模型监控方向。', '基础准备不足，建议先补充后端接口设计。', '2026-03-14 09:00:00', '2026-03-14 15:30:00'
  UNION ALL SELECT 'student57', '软件工程需求追踪与变更管理平台', 'approved', '希望研究需求和测试用例追踪。', '同意，注意需求状态机。', '2026-03-15 09:00:00', '2026-03-15 15:00:00'
  UNION ALL SELECT 'student58', 'DevOps持续集成质量看板', 'approved', '希望完成CI指标看板。', '同意，注意构建状态数据模型。', '2026-03-15 09:30:00', '2026-03-15 15:20:00'
  UNION ALL SELECT 'student59', '软件工程需求追踪与变更管理平台', 'approved', '希望参与研发过程管理系统。', '同意，补充权限边界说明。', '2026-03-15 10:00:00', '2026-03-15 15:40:00'
  UNION ALL SELECT 'student60', '微服务缺陷定位与回归测试系统', 'pending', '希望做微服务测试链路。', NULL, '2026-05-21 09:00:00', NULL
  UNION ALL SELECT 'student61', 'DevOps持续集成质量看板', 'pending', '希望做测试质量趋势分析。', NULL, '2026-05-21 09:30:00', NULL
  UNION ALL SELECT 'student62', '微服务缺陷定位与回归测试系统', 'rejected', '希望申请微服务缺陷定位方向。', '课题尚未通过审核，暂不批准选题。', '2026-03-16 09:00:00', '2026-03-16 14:30:00'
  UNION ALL SELECT 'student65', '数据科学就业画像分析系统', 'approved', '希望做招聘数据分析和画像建模。', '同意，注意数据清洗。', '2026-03-17 09:00:00', '2026-03-17 15:00:00'
  UNION ALL SELECT 'student66', '大数据实时指标预警平台', 'approved', '希望做实时指标和告警策略。', '同意，补充流式处理说明。', '2026-03-17 09:30:00', '2026-03-17 15:20:00'
  UNION ALL SELECT 'student67', '教学质量数据仓库与可视化系统', 'pending', '希望做教学质量数据仓库。', NULL, '2026-05-22 09:00:00', NULL
  UNION ALL SELECT 'student68', '数据科学就业画像分析系统', 'approved', '希望做就业画像可视化。', '同意，注意图表指标定义。', '2026-03-18 09:00:00', '2026-03-18 15:00:00'
  UNION ALL SELECT 'student69', '教学质量数据仓库与可视化系统', 'rejected', '希望申请教学数据仓库方向。', '课题暂未通过审核，暂不批准。', '2026-03-18 10:00:00', '2026-03-18 16:00:00'
  UNION ALL SELECT 'student73', '操作系统实验自动评测平台', 'approved', '希望做自动评测和测试用例设计。', '同意，注意沙箱边界。', '2026-03-19 09:00:00', '2026-03-19 15:00:00'
  UNION ALL SELECT 'student74', '分布式缓存一致性演示系统', 'approved', '希望做分布式缓存演示。', '同意，注意并发场景。', '2026-03-19 09:30:00', '2026-03-19 15:20:00'
  UNION ALL SELECT 'student75', '代码架构与网络流可视化平台', 'approved', '希望做代码结构和网络流展示。', '同意，注意图结构设计。', '2026-03-19 10:00:00', '2026-03-19 15:40:00'
  UNION ALL SELECT 'student76', '操作系统实验自动评测平台', 'approved', '希望参与自动评测平台后端。', '同意，注意安全隔离。', '2026-03-20 09:00:00', '2026-03-20 14:30:00'
  UNION ALL SELECT 'student77', '分布式缓存一致性演示系统', 'pending', '希望做缓存一致性可视化。', NULL, '2026-05-23 09:00:00', NULL
  UNION ALL SELECT 'student78', '代码架构与网络流可视化平台', 'pending', '希望做网络请求链路图谱。', NULL, '2026-05-23 09:20:00', NULL
  UNION ALL SELECT 'student79', '操作系统实验自动评测平台', 'rejected', '希望申请自动评测平台。', '本课题人数接近上限，建议选择其他方向。', '2026-03-21 09:00:00', '2026-03-21 15:00:00'
) x
JOIN users s ON s.username=x.username
JOIN topics t ON t.title=x.title
WHERE NOT EXISTS (
  SELECT 1 FROM topic_selections old
  WHERE old.student_id=s.id AND old.topic_id=t.id
);

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, t.id, x.doc_type, x.doc_title, x.content, CONCAT('uploads/', s.id, '/', x.doc_type, '.pdf'),
       x.doc_status, x.score, x.feedback, x.submit_time, x.review_time, t.teacher_id
FROM (
  SELECT 'student49' username, '多模态校园问答智能体' topic_title, 'proposal' doc_type, '多模态校园问答智能体开题报告' doc_title, '完成需求分析、知识库方案和多模态交互设计。' content, 'reviewed' doc_status, 94.00 score, '方案完整，创新性较强。' feedback, '2026-03-25 09:00:00' submit_time, '2026-03-26 09:00:00' review_time
  UNION ALL SELECT 'student49', '多模态校园问答智能体', 'midterm', '多模态校园问答智能体中期检查', '已完成检索增强链路和问答接口。', 'reviewed', 91.00, '进度良好，继续补充评测。', '2026-05-10 09:00:00', '2026-05-11 09:00:00'
  UNION ALL SELECT 'student49', '多模态校园问答智能体', 'final', '多模态校园问答智能体终稿', '完成系统实现、截图和性能测试。', 'reviewed', 93.00, '完成质量高。', '2026-06-10 09:00:00', '2026-06-12 09:00:00'
  UNION ALL SELECT 'student50', '多模态校园问答智能体', 'proposal', '大模型问答应用开题报告', '设计提示词、检索和会话管理模块。', 'reviewed', 86.00, '方案可行。', '2026-03-26 09:00:00', '2026-03-27 09:00:00'
  UNION ALL SELECT 'student50', '多模态校园问答智能体', 'midterm', '大模型问答应用中期检查', '完成基础问答和知识库接入。', 'submitted', NULL, NULL, '2026-05-12 09:00:00', NULL
  UNION ALL SELECT 'student51', 'AI模型推理服务监控平台', 'proposal', '模型推理监控平台开题报告', '定义延迟、错误率和Token消耗指标。', 'reviewed', 78.00, '指标较完整，补充异常处理。', '2026-03-27 09:00:00', '2026-03-28 09:00:00'
  UNION ALL SELECT 'student51', 'AI模型推理服务监控平台', 'midterm', '模型推理监控平台中期检查', '完成监控面板和接口统计。', 'reviewed', 82.00, '进度正常。', '2026-05-13 09:00:00', '2026-05-14 09:00:00'
  UNION ALL SELECT 'student52', '计算机视觉缺陷检测系统', 'proposal', '视觉缺陷检测系统开题报告', '完成数据集、模型和演示页面设计。', 'reviewed', 66.00, '基础方案可行，算法部分需加强。', '2026-03-28 09:00:00', '2026-03-29 09:00:00'
  UNION ALL SELECT 'student57', '软件工程需求追踪与变更管理平台', 'proposal', '需求追踪平台开题报告', '设计需求、任务、测试用例追踪模型。', 'reviewed', 88.00, '结构清晰。', '2026-03-29 09:00:00', '2026-03-30 09:00:00'
  UNION ALL SELECT 'student57', '软件工程需求追踪与变更管理平台', 'midterm', '需求追踪平台中期检查', '完成需求状态机和权限控制。', 'reviewed', 84.00, '继续补充变更历史。', '2026-05-14 09:00:00', '2026-05-15 09:00:00'
  UNION ALL SELECT 'student58', 'DevOps持续集成质量看板', 'proposal', 'DevOps质量看板开题报告', '设计构建、测试和部署指标采集。', 'reviewed', 76.00, '指标口径要继续细化。', '2026-03-30 09:00:00', '2026-03-31 09:00:00'
  UNION ALL SELECT 'student59', '软件工程需求追踪与变更管理平台', 'proposal', '研发过程管理开题报告', '设计项目流程和缺陷跟踪模块。', 'reviewed', 92.00, '完成度高。', '2026-03-31 09:00:00', '2026-04-01 09:00:00'
  UNION ALL SELECT 'student59', '软件工程需求追踪与变更管理平台', 'midterm', '研发过程管理中期检查', '完成核心流程和报表。', 'reviewed', 90.00, '进度优秀。', '2026-05-15 09:00:00', '2026-05-16 09:00:00'
  UNION ALL SELECT 'student59', '软件工程需求追踪与变更管理平台', 'final', '研发过程管理终稿', '完成部署和测试报告。', 'submitted', NULL, NULL, '2026-06-14 09:00:00', NULL
  UNION ALL SELECT 'student65', '数据科学就业画像分析系统', 'proposal', '就业画像分析系统开题报告', '设计招聘数据采集、清洗和画像标签。', 'reviewed', 83.00, '数据来源说明较完整。', '2026-04-01 09:00:00', '2026-04-02 09:00:00'
  UNION ALL SELECT 'student65', '数据科学就业画像分析系统', 'midterm', '就业画像分析系统中期检查', '完成数据清洗和基础图表。', 'reviewed', 81.00, '继续补充模型解释。', '2026-05-16 09:00:00', '2026-05-17 09:00:00'
  UNION ALL SELECT 'student66', '大数据实时指标预警平台', 'proposal', '实时指标预警平台开题报告', '设计实时指标、阈值和告警流程。', 'reviewed', 71.00, '技术链路基本合理。', '2026-04-02 09:00:00', '2026-04-03 09:00:00'
  UNION ALL SELECT 'student68', '数据科学就业画像分析系统', 'proposal', '就业画像可视化开题报告', '完成岗位画像指标和可视化原型。', 'reviewed', 95.00, '展示效果好。', '2026-04-03 09:00:00', '2026-04-04 09:00:00'
  UNION ALL SELECT 'student68', '数据科学就业画像分析系统', 'midterm', '就业画像可视化中期检查', '完成数据仓库和多维分析图表。', 'reviewed', 92.00, '继续完善交互筛选。', '2026-05-17 09:00:00', '2026-05-18 09:00:00'
  UNION ALL SELECT 'student68', '数据科学就业画像分析系统', 'final', '就业画像可视化终稿', '完成系统实现和分析报告。', 'reviewed', 94.00, '最终效果优秀。', '2026-06-15 09:00:00', '2026-06-16 09:00:00'
  UNION ALL SELECT 'student73', '操作系统实验自动评测平台', 'proposal', '操作系统实验自动评测平台开题报告', '设计提交、编译、测试和反馈流程。', 'reviewed', 89.00, '方案完整。', '2026-04-04 09:00:00', '2026-04-05 09:00:00'
  UNION ALL SELECT 'student73', '操作系统实验自动评测平台', 'midterm', '操作系统实验自动评测平台中期检查', '完成评测沙箱和测试用例。', 'reviewed', 87.00, '注意安全隔离。', '2026-05-18 09:00:00', '2026-05-19 09:00:00'
  UNION ALL SELECT 'student74', '分布式缓存一致性演示系统', 'proposal', '分布式缓存一致性演示系统开题报告', '设计缓存异常场景和可视化演示。', 'reviewed', 80.00, '场景设计较完整。', '2026-04-05 09:00:00', '2026-04-06 09:00:00'
  UNION ALL SELECT 'student75', '代码架构与网络流可视化平台', 'proposal', '代码架构与网络流可视化平台开题报告', '设计代码结构、请求链路和数据库访问图谱。', 'reviewed', 96.00, '与项目展示结合很好。', '2026-04-06 09:00:00', '2026-04-07 09:00:00'
  UNION ALL SELECT 'student75', '代码架构与网络流可视化平台', 'midterm', '代码架构与网络流可视化平台中期检查', '完成路由扫描和接口链路可视化。', 'reviewed', 94.00, '继续完善数据库表关系图。', '2026-05-19 09:00:00', '2026-05-20 09:00:00'
  UNION ALL SELECT 'student75', '代码架构与网络流可视化平台', 'final', '代码架构与网络流可视化平台终稿', '完成全链路展示、截图和报告。', 'reviewed', 97.00, '展示效果优秀。', '2026-06-16 09:00:00', '2026-06-17 09:00:00'
  UNION ALL SELECT 'student76', '操作系统实验自动评测平台', 'proposal', '自动评测平台后端开题报告', '设计后端队列、评测任务和成绩反馈。', 'reviewed', 73.00, '需要补充并发控制。', '2026-04-07 09:00:00', '2026-04-08 09:00:00'
) x
JOIN users s ON s.username=x.username
JOIN topics t ON t.title=x.topic_title
WHERE NOT EXISTS (
  SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type=x.doc_type
);

INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 1, d.title, d.content, REPLACE(d.file_path, '.pdf', '_v1.pdf'), DATE_SUB(d.submit_time, INTERVAL 2 DAY)
FROM documents d
JOIN users s ON s.id=d.student_id
WHERE s.student_no BETWEEN '2022001049' AND '2022001080'
  AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=1);

INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, x.defense_time, x.room, x.group_name, x.score, x.comment
FROM (
  SELECT 'student49' username, '2026-06-27 09:00:00' defense_time, '信息楼B201' room, '人工智能第一组' group_name, 93.00 score, '重点展示多模态问答链路' comment
  UNION ALL SELECT 'student50', '2026-06-27 09:40:00', '信息楼B201', '人工智能第一组', 86.00, '说明检索增强和提示词设计'
  UNION ALL SELECT 'student51', '2026-06-27 10:20:00', '信息楼B201', '人工智能第一组', 82.00, '展示监控指标口径'
  UNION ALL SELECT 'student52', '2026-06-27 11:00:00', '信息楼B201', '人工智能第一组', NULL, '补充算法实验截图'
  UNION ALL SELECT 'student57', '2026-06-27 14:00:00', '信息楼B301', '软件工程第一组', 85.00, '展示需求追踪矩阵'
  UNION ALL SELECT 'student58', '2026-06-27 14:40:00', '信息楼B301', '软件工程第一组', NULL, '准备CI指标截图'
  UNION ALL SELECT 'student59', '2026-06-27 15:20:00', '信息楼B301', '软件工程第一组', 91.00, '说明研发流程闭环'
  UNION ALL SELECT 'student65', '2026-06-28 09:00:00', '信息楼C201', '数据科学第一组', 82.00, '展示就业画像分析'
  UNION ALL SELECT 'student66', '2026-06-28 09:40:00', '信息楼C201', '数据科学第一组', NULL, '说明实时预警流程'
  UNION ALL SELECT 'student68', '2026-06-28 10:20:00', '信息楼C201', '数据科学第一组', 94.00, '展示多维可视化'
  UNION ALL SELECT 'student73', '2026-06-28 14:00:00', '信息楼A402', '计算机科学与技术第二组', 88.00, '展示自动评测流程'
  UNION ALL SELECT 'student74', '2026-06-28 14:40:00', '信息楼A402', '计算机科学与技术第二组', 81.00, '说明缓存一致性场景'
  UNION ALL SELECT 'student75', '2026-06-28 15:20:00', '信息楼A402', '计算机科学与技术第二组', 96.00, '展示架构图和网络流'
  UNION ALL SELECT 'student76', '2026-06-28 16:00:00', '信息楼A402', '计算机科学与技术第二组', NULL, '补充沙箱安全边界'
) x
JOIN users s ON s.username=x.username
WHERE NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO announcements(title, content, publisher_id, is_top, scope_type, college, major)
SELECT x.title, x.content, u.id, x.is_top, 'major', x.college, x.major
FROM (
  SELECT '人工智能专业模型演示材料提交提醒' title, '请人工智能专业学生答辩前补齐模型结构图、推理截图和评测指标。' content, 1 is_top, 'ai' college, 'ai' major
  UNION ALL SELECT '软件工程专业过程文档检查提醒', '请软件工程专业学生提交需求规格、测试用例和迭代记录。', 0, 'ai', 'se'
  UNION ALL SELECT '数据科学专业数据来源说明提醒', '请数据科学专业学生在终稿中说明数据来源、清洗过程和指标口径。', 0, 'ai', 'ds'
  UNION ALL SELECT '计算机科学与技术专业系统演示检查提醒', '请计算机科学与技术专业学生准备系统部署、接口测试和截图材料。', 1, 'ai', 'cs'
) x
JOIN users u ON u.username='admin'
WHERE NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title=x.title AND a.college=x.college AND a.major=x.major);

INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'SEED_SCOPE_VISUAL', 'demo_data', '补充分专业可视化增强数据，验证系主任统计隔离'
FROM users u WHERE u.username='admin'
  AND NOT EXISTS (
    SELECT 1 FROM operation_logs l
    WHERE l.action='SEED_SCOPE_VISUAL' AND l.detail='补充分专业可视化增强数据，验证系主任统计隔离'
  );

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
  (SELECT COUNT(*) FROM users WHERE student_no BETWEEN '2022001049' AND '2022001080') AS visual_students,
  (SELECT COUNT(*) FROM topics WHERE college='ai' AND major IN ('ai','cs','se','ds')) AS ai_college_topics,
  (SELECT COUNT(*) FROM topic_selections s JOIN topics t ON s.topic_id=t.id WHERE t.college='ai' AND t.major IN ('ai','cs','se','ds') AND s.status IN ('approved','pending')) AS ai_college_active_selections,
  (SELECT COUNT(*) FROM documents d JOIN topics t ON d.topic_id=t.id WHERE t.college='ai' AND t.major IN ('ai','cs','se','ds')) AS ai_college_documents,
  (SELECT COUNT(*) FROM defense_schedules d JOIN users u ON d.student_id=u.id WHERE u.student_no BETWEEN '2022001049' AND '2022001080') AS visual_defenses;
