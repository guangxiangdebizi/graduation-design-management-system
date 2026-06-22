-- 毕业设计管理系统 演示数据扩充脚本
-- 可重复执行：用户、学院、专业采用 upsert；业务数据用 NOT EXISTS 防重复。
USE graduation_design;

SET NAMES utf8mb4;

-- 1. 学院扩充
INSERT INTO colleges(code, name, sort_order, status) VALUES
('ai', '人工智能学部', 10, 1),
('ba', '经管学院', 20, 1),
('arts', '文科学部', 30, 1),
('ee', '电气工程学部', 40, 1),
('mech_energy', '能源与机械动力学院', 50, 1),
('env_chem', '环境与化学工程学院', 60, 1),
('cs', '计算机学院', 900, 0),
('sw', '软件学院', 910, 0)
ON DUPLICATE KEY UPDATE name=VALUES(name), sort_order=VALUES(sort_order), status=VALUES(status);

-- 2. 专业扩充
INSERT INTO majors(college_code, major_code, major_name, sort_order, status) VALUES
('ai', 'cs', '计算机科学与技术', 10, 1),
('ai', 'se', '软件工程', 20, 1),
('ai', 'ds', '数据科学与大数据技术', 30, 1),
('ai', 'ai', '人工智能', 40, 1),
('ee', 'power', '电力系统及其自动化', 40, 1),
('ee', 'control', '控制科学与工程', 50, 1),
('ba', 'finance', '金融学', 40, 1),
('ba', 'marketing', '市场营销', 50, 1),
('ba', 'hr', '人力资源管理', 60, 1),
('arts', 'news', '新闻传播学', 40, 1),
('arts', 'history', '历史学', 50, 1),
('mech_energy', 'mech', '机械设计制造及其自动化', 10, 1),
('mech_energy', 'energy', '能源与动力工程', 20, 1),
('mech_energy', 'vehicle', '车辆工程', 30, 1),
('env_chem', 'env', '环境工程', 10, 1),
('env_chem', 'chem', '应用化学', 20, 1),
('env_chem', 'material', '材料科学与工程', 30, 1)
ON DUPLICATE KEY UPDATE major_name=VALUES(major_name), sort_order=VALUES(sort_order), status=VALUES(status);

UPDATE majors
SET status = CASE
    WHEN college_code = 'ai' AND major_code IN ('cs', 'se', 'ds', 'ai') THEN 1
    WHEN college_code = 'ba' AND major_code IN ('ba', 'acc', 'ec', 'finance', 'marketing', 'hr') THEN 1
    WHEN college_code = 'arts' AND major_code IN ('chinese', 'eng', 'law', 'news', 'history') THEN 1
    WHEN college_code = 'ee' AND major_code IN ('ee', 'auto', 'eie', 'power', 'control') THEN 1
    WHEN college_code = 'mech_energy' AND major_code IN ('energy', 'mech', 'vehicle') THEN 1
    WHEN college_code = 'env_chem' AND major_code IN ('env', 'chem', 'material') THEN 1
    ELSE 0
END;

-- 3. 用户扩充。密码均为 123456 的 MD5：e10adc3949ba59abbe56e057f20f883e
INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('admin02', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '教务管理员', NULL, NULL, NULL, NULL, '教务处', 'admin02@school.edu', '13800001002', 1),
('admin03', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '学院管理员', NULL, NULL, NULL, NULL, '教学质量办公室', 'admin03@school.edu', '13800001003', 1),
('director_ai_cs', 'e10adc3949ba59abbe56e057f20f883e', 'director', '计算机科学与技术系主任', NULL, 'ai', 'cs', NULL, '人工智能学部', 'director_ai_cs@school.edu', '13800000011', 1),
('director_ai_se', 'e10adc3949ba59abbe56e057f20f883e', 'director', '软件工程系主任', NULL, 'ai', 'se', NULL, '人工智能学部', 'director_ai_se@school.edu', '13800000012', 1),
('director_ai_ds', 'e10adc3949ba59abbe56e057f20f883e', 'director', '数据科学与大数据技术系主任', NULL, 'ai', 'ds', NULL, '人工智能学部', 'director_ai_ds@school.edu', '13800000013', 1),
('director_ai_ai', 'e10adc3949ba59abbe56e057f20f883e', 'director', '人工智能系主任', NULL, 'ai', 'ai', NULL, '人工智能学部', 'director_ai_ai@school.edu', '13800000014', 1),
('teacher03', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '王教授', NULL, 'ai', 'ai', NULL, '人工智能学部', 'wangprof@school.edu', '13800002003', 1),
('teacher04', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '陈老师', NULL, 'ba', 'finance', NULL, '经管学院', 'chentea@school.edu', '13800002004', 1),
('teacher05', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '刘副教授', NULL, 'arts', 'news', NULL, '文科学部', 'liutea@school.edu', '13800002005', 1),
('teacher06', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '赵老师', NULL, 'ba', 'finance', NULL, '经管学院', 'zhaotea@school.edu', '13800002006', 1),
('teacher07', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '孙教授', NULL, 'mech_energy', 'mech', NULL, '能源与机械动力学院', 'suntea@school.edu', '13800002007', 1),
('teacher08', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '周老师', NULL, 'mech_energy', 'mech', NULL, '能源与机械动力学院', 'zhoutea@school.edu', '13800002008', 1),
('teacher09', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '吴主任', NULL, 'env_chem', 'env', NULL, '环境与化学工程学院', 'wutea@school.edu', '13800002009', 1),
('teacher10', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '郑老师', NULL, 'arts', 'eng', NULL, '文科学部', 'zhengtea@school.edu', '13800002010', 1),
('teacher11', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '胡老师', NULL, 'arts', 'news', NULL, '文科学部', 'hutea@school.edu', '13800002011', 1),
('teacher12', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '高老师', NULL, 'arts', 'law', NULL, '文科学部', 'gaotea@school.edu', '13800002012', 1),
('teacher13', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '马老师', NULL, 'env_chem', 'material', NULL, '环境与化学工程学院', 'matea@school.edu', '13800002013', 1),
('teacher14', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '林老师', NULL, 'mech_energy', 'energy', NULL, '能源与机械动力学院', 'lintea@school.edu', '13800002014', 1),
('student09', 'e10adc3949ba59abbe56e057f20f883e', 'student', '何雨晴', '2022001009', 'ai', 'ai', '机器学习2022级1班', '人工智能学部', 'student09@stu.edu', '13900001009', 1),
('student10', 'e10adc3949ba59abbe56e057f20f883e', 'student', '郭子轩', '2022001010', 'ai', 'ai', '计算机视觉2022级1班', '人工智能学部', 'student10@stu.edu', '13900001010', 1),
('student11', 'e10adc3949ba59abbe56e057f20f883e', 'student', '罗思远', '2022001011', 'ai', 'ai', '自然语言处理2022级1班', '人工智能学部', 'student11@stu.edu', '13900001011', 1),
('student12', 'e10adc3949ba59abbe56e057f20f883e', 'student', '梁佳怡', '2022001012', 'ba', 'finance', '金融学2022级1班', '经管学院', 'student12@stu.edu', '13900001012', 1),
('student13', 'e10adc3949ba59abbe56e057f20f883e', 'student', '宋明哲', '2022001013', 'ba', 'marketing', '市场营销2022级1班', '经管学院', 'student13@stu.edu', '13900001013', 1),
('student14', 'e10adc3949ba59abbe56e057f20f883e', 'student', '唐诗涵', '2022001014', 'arts', 'news', '新闻传播学2022级1班', '文科学部', 'student14@stu.edu', '13900001014', 1),
('student15', 'e10adc3949ba59abbe56e057f20f883e', 'student', '许文博', '2022001015', 'ba', 'finance', '统计学2022级1班', '经管学院', 'student15@stu.edu', '13900001015', 1),
('student16', 'e10adc3949ba59abbe56e057f20f883e', 'student', '韩若曦', '2022001016', 'mech_energy', 'mech', '机器人工程2022级1班', '能源与机械动力学院', 'student16@stu.edu', '13900001016', 1),
('student17', 'e10adc3949ba59abbe56e057f20f883e', 'student', '邓嘉豪', '2022001017', 'mech_energy', 'vehicle', '车辆工程2022级1班', '能源与机械动力学院', 'student17@stu.edu', '13900001017', 1),
('student18', 'e10adc3949ba59abbe56e057f20f883e', 'student', '彭雅婷', '2022001018', 'mech_energy', 'mech', '建筑学2022级1班', '能源与机械动力学院', 'student18@stu.edu', '13900001018', 1),
('student19', 'e10adc3949ba59abbe56e057f20f883e', 'student', '蒋浩然', '2022001019', 'mech_energy', 'mech', '工程造价2022级1班', '能源与机械动力学院', 'student19@stu.edu', '13900001019', 1),
('student20', 'e10adc3949ba59abbe56e057f20f883e', 'student', '余欣怡', '2022001020', 'env_chem', 'env', '临床医学2022级1班', '环境与化学工程学院', 'student20@stu.edu', '13900001020', 1),
('student21', 'e10adc3949ba59abbe56e057f20f883e', 'student', '傅子墨', '2022001021', 'env_chem', 'chem', '药学2022级1班', '环境与化学工程学院', 'student21@stu.edu', '13900001021', 1),
('student22', 'e10adc3949ba59abbe56e057f20f883e', 'student', '程安琪', '2022001022', 'arts', 'eng', '翻译2022级1班', '文科学部', 'student22@stu.edu', '13900001022', 1),
('student23', 'e10adc3949ba59abbe56e057f20f883e', 'student', '邹凯文', '2022001023', 'arts', 'news', '数字媒体艺术2022级1班', '文科学部', 'student23@stu.edu', '13900001023', 1),
('student24', 'e10adc3949ba59abbe56e057f20f883e', 'student', '薛梦洁', '2022001024', 'arts', 'news', '产品设计2022级1班', '文科学部', 'student24@stu.edu', '13900001024', 1),
('student25', 'e10adc3949ba59abbe56e057f20f883e', 'student', '叶承宇', '2022001025', 'arts', 'law', '法学2022级1班', '文科学部', 'student25@stu.edu', '13900001025', 1),
('student26', 'e10adc3949ba59abbe56e057f20f883e', 'student', '孟雨桐', '2022001026', 'env_chem', 'material', '材料科学与工程2022级1班', '环境与化学工程学院', 'student26@stu.edu', '13900001026', 1),
('student27', 'e10adc3949ba59abbe56e057f20f883e', 'student', '乔宇航', '2022001027', 'mech_energy', 'energy', '新能源科学与工程2022级1班', '能源与机械动力学院', 'student27@stu.edu', '13900001027', 1),
('student28', 'e10adc3949ba59abbe56e057f20f883e', 'student', '任可欣', '2022001028', 'ai', 'cs', '物联网工程2022级1班', '人工智能学部', 'student28@stu.edu', '13900001028', 1),
('student29', 'e10adc3949ba59abbe56e057f20f883e', 'student', '田昊宇', '2022001029', 'ai', 'cs', '网络空间安全2022级1班', '人工智能学部', 'student29@stu.edu', '13900001029', 1),
('student30', 'e10adc3949ba59abbe56e057f20f883e', 'student', '白若琳', '2022001030', 'ai', 'se', '云计算技术2022级1班', '人工智能学部', 'student30@stu.edu', '13900001030', 1),
('student31', 'e10adc3949ba59abbe56e057f20f883e', 'student', '范俊杰', '2022001031', 'ee', 'power', '电力系统及其自动化2022级1班', '电气学院', 'student31@stu.edu', '13900001031', 1),
('student32', 'e10adc3949ba59abbe56e057f20f883e', 'student', '秦可乐', '2022001032', 'ee', 'control', '控制科学与工程2022级1班', '电气学院', 'student32@stu.edu', '13900001032', 1),
('student33', 'e10adc3949ba59abbe56e057f20f883e', 'student', '魏思成', '2022001033', 'ba', 'finance', '应用数学2022级1班', '经管学院', 'student33@stu.edu', '13900001033', 1),
('student34', 'e10adc3949ba59abbe56e057f20f883e', 'student', '龙雨菲', '2022001034', 'arts', 'eng', '日语2022级1班', '文科学部', 'student34@stu.edu', '13900001034', 1),
('student35', 'e10adc3949ba59abbe56e057f20f883e', 'student', '万景行', '2022001035', 'ba', 'hr', '人力资源管理2022级1班', '经管学院', 'student35@stu.edu', '13900001035', 1),
('student36', 'e10adc3949ba59abbe56e057f20f883e', 'student', '段清妍', '2022001036', 'arts', 'history', '历史学2022级1班', '文科学部', 'student36@stu.edu', '13900001036', 1),
('student37', 'e10adc3949ba59abbe56e057f20f883e', 'student', '谢启明', '2022001037', 'env_chem', 'env', '护理学2022级1班', '环境与化学工程学院', 'student37@stu.edu', '13900001037', 1),
('student38', 'e10adc3949ba59abbe56e057f20f883e', 'student', '姚星辰', '2022001038', 'mech_energy', 'mech', '土木工程2022级1班', '能源与机械动力学院', 'student38@stu.edu', '13900001038', 1),
('student39', 'e10adc3949ba59abbe56e057f20f883e', 'student', '顾南栀', '2022001039', 'arts', 'news', '动画2022级1班', '文科学部', 'student39@stu.edu', '13900001039', 1),
('student40', 'e10adc3949ba59abbe56e057f20f883e', 'student', '陆景然', '2022001040', 'arts', 'law', '公共事业管理2022级1班', '文科学部', 'student40@stu.edu', '13900001040', 1)
ON DUPLICATE KEY UPDATE
password=VALUES(password), role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), class_name=VALUES(class_name), department=VALUES(department),
email=VALUES(email), phone=VALUES(phone), status=VALUES(status);

-- 4. 课题扩充
SET @has_topics_major := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'topics' AND COLUMN_NAME = 'major'
);
SET @add_topics_major_sql := IF(
    @has_topics_major = 0,
    'ALTER TABLE topics ADD COLUMN major VARCHAR(50) DEFAULT NULL COMMENT ''课题所属专业'' AFTER college',
    'SELECT 1'
);
PREPARE add_topics_major_stmt FROM @add_topics_major_sql;
EXECUTE add_topics_major_stmt;
DEALLOCATE PREPARE add_topics_major_stmt;

INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '基于Transformer的校园问答系统', '面向教务、选课、毕业设计流程的智能问答系统，支持知识库检索与多轮对话。', u.id, 'ai', 'ai', 3, 0, 'open'
FROM users u WHERE u.username='teacher03' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='基于Transformer的校园问答系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '医学影像辅助诊断算法研究', '基于卷积神经网络和注意力机制实现医学影像病灶区域辅助识别。', u.id, 'ai', 'ai', 2, 0, 'open'
FROM users u WHERE u.username='teacher03' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='医学影像辅助诊断算法研究' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '企业经营数据可视化分析平台', '围绕销售、库存、利润和客户画像构建多维经营数据分析看板。', u.id, 'ba', 'finance', 3, 0, 'open'
FROM users u WHERE u.username='teacher04' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='企业经营数据可视化分析平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '供应链风险预警系统', '通过订单、库存和物流数据构建供应链风险指标与预警模型。', u.id, 'ba', 'finance', 2, 0, 'open'
FROM users u WHERE u.username='teacher04' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='供应链风险预警系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '校园新闻内容管理系统', '实现新闻采编、审核、发布、评论和访问统计等全流程管理。', u.id, 'arts', 'news', 2, 0, 'open'
FROM users u WHERE u.username='teacher05' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='校园新闻内容管理系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '短视频传播效果分析系统', '分析短视频标题、标签、播放量和互动数据，形成传播效果评价。', u.id, 'arts', 'news', 2, 0, 'open'
FROM users u WHERE u.username='teacher05' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='短视频传播效果分析系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '学生成绩预测与预警模型', '基于历史课程成绩、出勤和作业数据进行学习风险预测。', u.id, 'ba', 'finance', 3, 0, 'open'
FROM users u WHERE u.username='teacher06' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='学生成绩预测与预警模型' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '统计调查问卷分析平台', '支持问卷设计、样本采集、统计分析和可视化报告生成。', u.id, 'ba', 'finance', 2, 0, 'open'
FROM users u WHERE u.username='teacher06' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='统计调查问卷分析平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '移动机器人路径规划仿真系统', '实现A*、Dijkstra、RRT等路径规划算法的可视化仿真。', u.id, 'mech_energy', 'mech', 3, 0, 'open'
FROM users u WHERE u.username='teacher07' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='移动机器人路径规划仿真系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '新能源汽车电池管理系统', '围绕电池状态估计、充放电监控和安全告警实现管理原型。', u.id, 'mech_energy', 'vehicle', 2, 0, 'open'
FROM users u WHERE u.username='teacher07' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='新能源汽车电池管理系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '智慧工地安全监测平台', '基于传感器和视频数据实现工地人员、设备和环境风险监控。', u.id, 'mech_energy', 'mech', 3, 0, 'open'
FROM users u WHERE u.username='teacher08' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='智慧工地安全监测平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '建筑工程造价辅助核算系统', '实现工程量清单、材料价格、费用汇总和报表导出。', u.id, 'mech_energy', 'mech', 2, 0, 'open'
FROM users u WHERE u.username='teacher08' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='建筑工程造价辅助核算系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '慢病随访管理系统', '面向社区慢病患者，实现随访计划、指标记录、用药提醒和风险分层。', u.id, 'env_chem', 'env', 3, 0, 'open'
FROM users u WHERE u.username='teacher09' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='慢病随访管理系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '药品库存与处方审核系统', '实现药品库存预警、处方审核和用药记录查询。', u.id, 'env_chem', 'chem', 2, 0, 'open'
FROM users u WHERE u.username='teacher09' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='药品库存与处方审核系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '在线翻译辅助学习平台', '围绕术语库、译文对比和学习记录构建翻译辅助工具。', u.id, 'arts', 'eng', 2, 0, 'open'
FROM users u WHERE u.username='teacher10' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='在线翻译辅助学习平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '英语写作自动反馈系统', '分析学生作文中的词汇、语法、结构问题并给出修改建议。', u.id, 'arts', 'eng', 2, 0, 'open'
FROM users u WHERE u.username='teacher10' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='英语写作自动反馈系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '校园导览小程序交互设计', '完成校园空间信息架构、路径导航、界面设计和可用性测试。', u.id, 'arts', 'news', 3, 0, 'open'
FROM users u WHERE u.username='teacher11' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='校园导览小程序交互设计' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '数字展馆内容展示系统', '实现展品管理、三维展示、导览讲解和互动评价。', u.id, 'arts', 'news', 2, 0, 'open'
FROM users u WHERE u.username='teacher11' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='数字展馆内容展示系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '高校法务咨询预约系统', '实现法律咨询预约、案例分类、材料上传和处理进度跟踪。', u.id, 'arts', 'law', 2, 0, 'open'
FROM users u WHERE u.username='teacher12' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='高校法务咨询预约系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '社区治理网格化管理平台', '支持社区事件上报、网格员分派、进度跟踪和统计分析。', u.id, 'arts', 'law', 3, 0, 'open'
FROM users u WHERE u.username='teacher12' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='社区治理网格化管理平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '材料实验数据管理系统', '实现材料样品、实验参数、测试结果和报告归档管理。', u.id, 'env_chem', 'material', 2, 0, 'open'
FROM users u WHERE u.username='teacher13' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='材料实验数据管理系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '化学品安全库存管理系统', '实现试剂入库、领用审批、安全等级和库存预警。', u.id, 'env_chem', 'material', 2, 0, 'open'
FROM users u WHERE u.username='teacher13' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='化学品安全库存管理系统' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '校园碳排放统计与分析平台', '围绕用电、用水、交通和实验室耗材构建碳排放统计模型。', u.id, 'env_chem', 'env', 3, 0, 'open'
FROM users u WHERE u.username='teacher14' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='校园碳排放统计与分析平台' AND t.teacher_id=u.id);
INSERT INTO topics(title, description, teacher_id, college, major, max_students, selected_count, status)
SELECT '新能源设备运行监控系统', '对光伏、储能等新能源设备状态进行采集、展示和故障告警。', u.id, 'mech_energy', 'energy', 2, 0, 'open'
FROM users u WHERE u.username='teacher14' AND NOT EXISTS (SELECT 1 FROM topics t WHERE t.title='新能源设备运行监控系统' AND t.teacher_id=u.id);

-- 5. 选题数据。每个新学生至多一个 pending/approved 活跃选题。
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望结合人工智能方向完成一个完整系统，实现从需求分析到部署展示的闭环。', '选题方向明确，基础较好，同意。', '2026-03-05 09:10:00', '2026-03-06 10:30:00'
FROM users s JOIN topics t ON t.title='基于Transformer的校园问答系统' WHERE s.username='student09'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '对视觉识别和深度学习有兴趣，希望完成算法和系统结合的课题。', '同意，注意数据集来源和模型评估。', '2026-03-05 09:20:00', '2026-03-06 10:40:00'
FROM users s JOIN topics t ON t.title='医学影像辅助诊断算法研究' WHERE s.username='student10'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望研究校园场景下智能问答助手的知识库设计。', NULL, '2026-05-21 14:20:00', NULL
FROM users s JOIN topics t ON t.title='基于Transformer的校园问答系统' WHERE s.username='student11'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '熟悉Excel和可视化，希望做经营分析方向。', '同意，建议补充权限和导出功能。', '2026-03-07 08:30:00', '2026-03-08 09:10:00'
FROM users s JOIN topics t ON t.title='企业经营数据可视化分析平台' WHERE s.username='student12'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望结合管理课程知识做供应链风险评价。', NULL, '2026-05-22 11:00:00', NULL
FROM users s JOIN topics t ON t.title='供应链风险预警系统' WHERE s.username='student13'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望完成新闻采编和发布流程的信息化管理。', '批准，注意后台审核流程。', '2026-03-08 10:10:00', '2026-03-09 09:30:00'
FROM users s JOIN topics t ON t.title='校园新闻内容管理系统' WHERE s.username='student14'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '有统计学基础，希望做成绩风险预测模型。', '同意，重点说明特征选择。', '2026-03-09 09:40:00', '2026-03-10 15:00:00'
FROM users s JOIN topics t ON t.title='学生成绩预测与预警模型' WHERE s.username='student15'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望做机器人路径规划算法可视化。', '同意，建议加入多算法对比。', '2026-03-10 10:00:00', '2026-03-11 09:00:00'
FROM users s JOIN topics t ON t.title='移动机器人路径规划仿真系统' WHERE s.username='student16'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '对新能源汽车方向感兴趣，希望做电池管理相关系统。', NULL, '2026-05-22 15:10:00', NULL
FROM users s JOIN topics t ON t.title='新能源汽车电池管理系统' WHERE s.username='student17'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望做智慧工地安全监测和预警平台。', '同意，注意场景数据模拟。', '2026-03-11 10:30:00', '2026-03-12 10:00:00'
FROM users s JOIN topics t ON t.title='智慧工地安全监测平台' WHERE s.username='student18'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望围绕工程造价流程做信息系统。', '同意，注意报表和统计。', '2026-03-11 11:20:00', '2026-03-12 11:00:00'
FROM users s JOIN topics t ON t.title='建筑工程造价辅助核算系统' WHERE s.username='student19'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望把医学随访流程做成可管理的信息系统。', '批准，注意隐私保护设计。', '2026-03-12 09:10:00', '2026-03-13 09:20:00'
FROM users s JOIN topics t ON t.title='慢病随访管理系统' WHERE s.username='student20'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望做药品库存预警和处方审核。', NULL, '2026-05-23 09:00:00', NULL
FROM users s JOIN topics t ON t.title='药品库存与处方审核系统' WHERE s.username='student21'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望围绕术语库和译文对比实现翻译辅助学习平台。', '同意，建议加入学习记录。', '2026-03-13 13:00:00', '2026-03-14 10:00:00'
FROM users s JOIN topics t ON t.title='在线翻译辅助学习平台' WHERE s.username='student22'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望完成校园导览小程序的交互设计和原型验证。', '同意，注意可用性测试。', '2026-03-14 09:00:00', '2026-03-15 09:30:00'
FROM users s JOIN topics t ON t.title='校园导览小程序交互设计' WHERE s.username='student23'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望做数字展馆内容展示和交互设计。', NULL, '2026-05-23 16:00:00', NULL
FROM users s JOIN topics t ON t.title='数字展馆内容展示系统' WHERE s.username='student24'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望将高校法律咨询预约流程信息化。', '同意，注意材料上传和权限。', '2026-03-15 10:10:00', '2026-03-16 11:00:00'
FROM users s JOIN topics t ON t.title='高校法务咨询预约系统' WHERE s.username='student25'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望做材料实验数据采集和归档。', '同意，注意数据表设计。', '2026-03-16 08:50:00', '2026-03-17 09:20:00'
FROM users s JOIN topics t ON t.title='材料实验数据管理系统' WHERE s.username='student26'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'approved', '希望围绕校园双碳场景做统计分析平台。', '同意，注意指标来源说明。', '2026-03-17 09:00:00', '2026-03-18 09:10:00'
FROM users s JOIN topics t ON t.title='校园碳排放统计与分析平台' WHERE s.username='student27'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'pending', '希望做物联网设备数据采集和监控平台。', NULL, '2026-05-24 10:10:00', NULL
FROM users s JOIN topics t ON t.title='校园二手交易平台' WHERE s.username='student28'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.status IN ('pending','approved'));
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'rejected', '希望申请图像识别方向。', '该课题名额已满，建议选择网络安全相关课题。', '2026-03-18 09:00:00', '2026-03-19 09:00:00'
FROM users s JOIN topics t ON t.title='基于深度学习的图像识别系统' WHERE s.username='student29'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.topic_id=t.id);
INSERT INTO topic_selections(student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time)
SELECT s.id, t.id, 'cancelled', '曾申请在线考试系统，后调整方向。', '学生主动取消。', '2026-03-19 09:00:00', '2026-03-20 09:00:00'
FROM users s JOIN topics t ON t.title='在线考试系统的设计与实现' WHERE s.username='student30'
AND NOT EXISTS (SELECT 1 FROM topic_selections x WHERE x.student_id=s.id AND x.topic_id=t.id);

-- 6. 文档与版本数据
INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'proposal', CONCAT(t.title, '开题报告'), CONCAT('围绕“', t.title, '”完成需求分析、系统设计和实现计划。'), CONCAT('uploads/', s.id, '/proposal.pdf'), 'reviewed', 86.00, '开题报告完整，研究内容和技术路线较清晰。', '2026-03-22 10:00:00', '2026-03-24 09:30:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username IN ('student09','student10','student12','student14','student15','student16','student18','student19','student20','student22','student23','student25','student26','student27')
AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='proposal');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'midterm', CONCAT(t.title, '中期检查'), CONCAT('目前已完成“', t.title, '”的需求分析、数据库设计和核心页面开发。'), CONCAT('uploads/', s.id, '/midterm.pdf'), 'reviewed', 88.00, '中期进度正常，继续完善测试和文档。', '2026-05-08 15:00:00', '2026-05-10 10:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username IN ('student09','student10','student12','student14','student15','student16','student18','student19')
AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'midterm', CONCAT(t.title, '中期检查'), CONCAT('正在完善“', t.title, '”的核心模块，部分测试用例待补充。'), CONCAT('uploads/', s.id, '/midterm.pdf'), 'submitted', NULL, NULL, '2026-05-18 16:00:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username IN ('student20','student22','student23','student25','student26','student27')
AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='midterm');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'final', CONCAT(t.title, '终稿'), CONCAT('已完成“', t.title, '”系统设计、编码实现、测试和论文撰写。'), CONCAT('uploads/', s.id, '/final.pdf'), 'reviewed', 90.00, '终稿整体完成度较高，可以进入答辩。', '2026-06-10 12:00:00', '2026-06-12 14:00:00', t.teacher_id
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username IN ('student09','student10','student12','student14','student15','student16')
AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='final');

INSERT INTO documents(student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id)
SELECT s.id, sel.topic_id, 'final', CONCAT(t.title, '终稿'), CONCAT('已提交“', t.title, '”终稿，等待教师评阅。'), CONCAT('uploads/', s.id, '/final.pdf'), 'submitted', NULL, NULL, '2026-06-15 13:00:00', NULL, NULL
FROM users s JOIN topic_selections sel ON sel.student_id=s.id AND sel.status='approved' JOIN topics t ON t.id=sel.topic_id
WHERE s.username IN ('student18','student19')
AND NOT EXISTS (SELECT 1 FROM documents d WHERE d.student_id=s.id AND d.doc_type='final');

INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 1, d.title, d.content, REPLACE(d.file_path, '.pdf', '_v1.pdf'), DATE_SUB(d.submit_time, INTERVAL 3 DAY)
FROM documents d JOIN users s ON s.id=d.student_id
WHERE s.username IN ('student09','student10','student12','student14','student15','student16','student18','student19','student20','student22','student23','student25','student26','student27')
AND d.doc_type='proposal'
AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=1);

INSERT INTO document_versions(document_id, version_no, title, content, file_path, submit_time)
SELECT d.id, 2, d.title, d.content, d.file_path, d.submit_time
FROM documents d JOIN users s ON s.id=d.student_id
WHERE s.username IN ('student09','student10','student12','student14','student15','student16')
AND d.doc_type='proposal'
AND NOT EXISTS (SELECT 1 FROM document_versions v WHERE v.document_id=d.id AND v.version_no=2);

-- 7. 答辩安排、公告、消息、日志
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-24 09:00:00', '教学楼B201', '第三组', NULL, '请携带答辩PPT和系统演示材料'
FROM users s WHERE s.username='student09' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-24 10:00:00', '教学楼B201', '第三组', NULL, '请提前10分钟到场'
FROM users s WHERE s.username='student10' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-24 11:00:00', '教学楼B202', '第四组', NULL, '请准备项目源代码和论文'
FROM users s WHERE s.username='student12' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-24 14:00:00', '教学楼B202', '第四组', NULL, '请携带答辩记录表'
FROM users s WHERE s.username='student14' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-25 09:00:00', '教学楼C301', '第五组', NULL, '请提前完成终稿查重'
FROM users s WHERE s.username='student15' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);
INSERT INTO defense_schedules(student_id, defense_time, room, group_name, score, comment)
SELECT s.id, '2026-06-25 10:00:00', '教学楼C301', '第五组', NULL, '请准备系统演示账号'
FROM users s WHERE s.username='student16' AND NOT EXISTS (SELECT 1 FROM defense_schedules d WHERE d.student_id=s.id);

INSERT INTO announcements(title, content, publisher_id, is_top)
SELECT '毕业设计终稿提交与答辩材料准备提醒', '请已完成终稿评阅的同学提前准备答辩PPT、项目源码、论文终稿和演示账号。', u.id, 1
FROM users u WHERE u.username='admin' AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='毕业设计终稿提交与答辩材料准备提醒');
INSERT INTO announcements(title, content, publisher_id, is_top)
SELECT '各学院毕业设计答辩分组已陆续发布', '各学院答辩时间、地点和分组信息将通过系统持续更新，请学生和指导教师及时查看。', u.id, 0
FROM users u WHERE u.username='admin02' AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='各学院毕业设计答辩分组已陆续发布');
INSERT INTO announcements(title, content, publisher_id, is_top)
SELECT '关于加强毕业设计过程材料归档的通知', '请教师在系统中及时完成文档评阅和反馈填写，学生应保存各阶段版本材料。', u.id, 0
FROM users u WHERE u.username='admin03' AND NOT EXISTS (SELECT 1 FROM announcements a WHERE a.title='关于加强毕业设计过程材料归档的通知');

INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT t.id, s.id, '开题报告修改建议', '请在研究内容部分补充关键技术路线和可行性分析。', 0
FROM users t JOIN users s ON t.username='teacher03' AND s.username='student09'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=t.id AND m.receiver_id=s.id AND m.title='开题报告修改建议');
INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT t.id, s.id, '中期检查通过', '你的中期材料已审核通过，请继续推进终稿和测试说明。', 1
FROM users t JOIN users s ON t.username='teacher04' AND s.username='student12'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=t.id AND m.receiver_id=s.id AND m.title='中期检查通过');
INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT s.id, t.id, '关于答辩PPT页数', '老师您好，答辩PPT建议控制在多少页以内？', 0
FROM users s JOIN users t ON s.username='student16' AND t.username='teacher07'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=s.id AND m.receiver_id=t.id AND m.title='关于答辩PPT页数');
INSERT INTO messages(sender_id, receiver_id, title, content, is_read)
SELECT a.id, s.id, '答辩时间确认', '你的答辩安排已发布，请查看系统中的答辩时间和地点。', 0
FROM users a JOIN users s ON a.username='admin02' AND s.username='student15'
WHERE NOT EXISTS (SELECT 1 FROM messages m WHERE m.sender_id=a.id AND m.receiver_id=s.id AND m.title='答辩时间确认');

INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'SEED', 'demo_data', '扩充学院、专业、用户、课题和过程数据'
FROM users u WHERE u.username='admin'
AND NOT EXISTS (SELECT 1 FROM operation_logs l WHERE l.user_id=u.id AND l.action='SEED' AND l.detail='扩充学院、专业、用户、课题和过程数据');
INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'REVIEW', 'documents', '批量评阅学生阶段文档'
FROM users u WHERE u.username='teacher03'
AND NOT EXISTS (SELECT 1 FROM operation_logs l WHERE l.user_id=u.id AND l.action='REVIEW' AND l.detail='批量评阅学生阶段文档');
INSERT INTO operation_logs(user_id, action, target, detail)
SELECT u.id, 'EXPORT', 'grades', '导出演示成绩统计表'
FROM users u WHERE u.username='admin02'
AND NOT EXISTS (SELECT 1 FROM operation_logs l WHERE l.user_id=u.id AND l.action='EXPORT' AND l.detail='导出演示成绩统计表');

-- 8. 组织口径收敛：历史演示学院归并到当前 6 个学院/学部，并回填课题专业。
UPDATE users
SET college = CASE
        WHEN college IN ('cs', 'sw', 'ai', 'science') OR department IN ('计算机学院', '软件学院', '理学部', '人工智能学部') THEN 'ai'
        WHEN college = 'ee' OR department IN ('电气学院', '电气工程学部') THEN 'ee'
        WHEN college = 'ba' OR department = '经管学院' THEN 'ba'
        WHEN college IN ('arts', 'foreign', 'design', 'lawgov') OR department IN ('文科学部', '外国语学院', '数字媒体与设计学院', '法政学院') THEN 'arts'
        WHEN college IN ('mech', 'civil', 'mech_energy') OR department IN ('机械工程学院', '土木建筑学院', '能源与机械动力学院') THEN 'mech_energy'
        WHEN college IN ('env', 'chem', 'med', 'env_chem') OR department IN ('环境与能源学院', '化学与材料学院', '医学院', '环境与化学工程学院') THEN 'env_chem'
        ELSE college
    END
WHERE role IN ('director', 'teacher', 'student');

UPDATE users
SET major = CASE
    WHEN college = 'ai' THEN CASE
        WHEN major IN ('cy', 'sw', 'se', 'cloud', 'fintech') THEN 'se'
        WHEN major IN ('bigdata', 'ds', 'math', 'stat', 'applied_math') THEN 'ds'
        WHEN major IN ('ai', 'ml', 'cv', 'nlp', 'robot', 'robotics') THEN 'ai'
        ELSE 'cs'
    END
    WHEN college = 'ee' THEN CASE
        WHEN major IN ('power', 'control', 'auto', 'eie', 'ee') THEN major
        ELSE 'ee'
    END
    WHEN college = 'ba' THEN CASE
        WHEN major IN ('acc', 'ec', 'finance', 'marketing', 'hr', 'ba') THEN major
        ELSE 'ba'
    END
    WHEN college = 'arts' THEN CASE
        WHEN major IN ('eng', 'law', 'news', 'history', 'chinese') THEN major
        ELSE 'chinese'
    END
    WHEN college = 'mech_energy' THEN CASE
        WHEN major IN ('energy', 'vehicle') THEN major
        ELSE 'mech'
    END
    WHEN college = 'env_chem' THEN CASE
        WHEN major IN ('chem', 'material') THEN major
        ELSE 'env'
    END
    ELSE major
END
WHERE role IN ('director', 'teacher', 'student');

UPDATE users
SET department = CASE college
    WHEN 'ai' THEN '人工智能学部'
    WHEN 'ba' THEN '经管学院'
    WHEN 'arts' THEN '文科学部'
    WHEN 'ee' THEN '电气工程学部'
    WHEN 'mech_energy' THEN '能源与机械动力学院'
    WHEN 'env_chem' THEN '环境与化学工程学院'
    ELSE department
END
WHERE role IN ('director', 'teacher', 'student');

UPDATE topics
SET college = 'ai',
    major = CASE
        WHEN major IN ('cy', 'sw', 'se', 'cloud') THEN 'se'
        WHEN major IN ('bigdata', 'ds') THEN 'ds'
        WHEN major = 'ai' THEN 'ai'
        ELSE 'cs'
    END
WHERE college IN ('cs', 'sw');

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
SET t.college = u.college
WHERE t.college IS NULL OR t.college = '' OR t.college IN ('cs', 'sw')
   OR t.college NOT IN ('ai', 'ba', 'arts', 'ee', 'mech_energy', 'env_chem');

UPDATE topics
SET major = CASE
    WHEN college = 'ai' THEN CASE
        WHEN major IN ('se', 'cy', 'sw', 'cloud', 'fintech') THEN 'se'
        WHEN major IN ('ds', 'bigdata', 'math', 'stat', 'applied_math') THEN 'ds'
        WHEN major IN ('ai', 'ml', 'cv', 'nlp', 'robot', 'robotics') THEN 'ai'
        ELSE 'cs'
    END
    WHEN college = 'ee' THEN CASE
        WHEN major IN ('auto', 'eie', 'power', 'control') THEN major
        ELSE 'ee'
    END
    WHEN college = 'ba' THEN CASE
        WHEN major IN ('acc', 'ec', 'finance', 'marketing', 'hr') THEN major
        ELSE 'ba'
    END
    WHEN college = 'arts' THEN CASE
        WHEN major IN ('eng', 'law', 'news', 'history') THEN major
        ELSE 'chinese'
    END
    WHEN college = 'mech_energy' THEN CASE
        WHEN major IN ('energy', 'vehicle') THEN major
        ELSE 'mech'
    END
    WHEN college = 'env_chem' THEN CASE
        WHEN major IN ('chem', 'material') THEN major
        ELSE 'env'
    END
    ELSE major
END;

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
LEFT JOIN majors m ON m.college_code = t.college AND m.major_code = t.major AND m.status = 1
SET t.major = u.major
WHERE (t.major IS NULL OR t.major = '' OR m.id IS NULL)
  AND u.major IS NOT NULL AND u.major <> '';

UPDATE topics SET major='cs' WHERE college='ai' AND title='基于JSP的毕业设计管理系统';
UPDATE topics SET major='ai' WHERE college='ai' AND title IN ('基于深度学习的图像识别系统', '智能客服机器人设计与实现');
UPDATE topics SET major='se' WHERE college='ai' AND title='校园二手交易平台';

-- 9. 重新计算课题人数和开放状态，保证统计页数据一致。
UPDATE topics t
SET selected_count = (
    SELECT COUNT(*) FROM topic_selections s
    WHERE s.topic_id = t.id AND s.status = 'approved'
);

UPDATE topics
SET status = CASE WHEN selected_count >= max_students THEN 'closed' ELSE 'open' END;
