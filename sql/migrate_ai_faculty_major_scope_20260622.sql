USE graduation_design;

SET NAMES utf8mb4;

INSERT INTO colleges(code, name, sort_order, status) VALUES
('ai', '人工智能学部', 10, 1),
('ba', '经管学院', 20, 1),
('arts', '文科学部', 30, 1),
('ee', '电气工程学部', 40, 1),
('mech_energy', '能源与机械动力学院', 50, 1),
('env_chem', '环境与化学工程学院', 60, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), sort_order=VALUES(sort_order), status=VALUES(status);

UPDATE colleges
SET status = 0
WHERE code IN ('cs', 'sw');

INSERT INTO majors(college_code, major_code, major_name, sort_order, status) VALUES
('ai', 'cs', '计算机科学与技术', 10, 1),
('ai', 'se', '软件工程', 20, 1),
('ai', 'ds', '数据科学与大数据技术', 30, 1),
('ai', 'ai', '人工智能', 40, 1),
('ee', 'ee', '电气工程及其自动化', 10, 1),
('ee', 'auto', '自动化', 20, 1),
('ee', 'eie', '电子信息工程', 30, 1),
('ba', 'ba', '工商管理', 10, 1),
('ba', 'acc', '会计学', 20, 1),
('ba', 'ec', '电子商务', 30, 1),
('arts', 'chinese', '汉语言文学', 10, 1),
('arts', 'eng', '英语', 20, 1),
('arts', 'law', '法学', 30, 1),
('mech_energy', 'energy', '能源与动力工程', 10, 1),
('mech_energy', 'mech', '机械设计制造及其自动化', 20, 1),
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

UPDATE users
SET college = 'ai',
    department = '人工智能学部',
    major = CASE
        WHEN major IN ('cy', 'sw', 'se') THEN 'se'
        WHEN major IN ('bigdata', 'ds') THEN 'ds'
        WHEN major = 'ai' THEN 'ai'
        ELSE 'cs'
    END
WHERE college IN ('cs', 'sw') OR department IN ('计算机学院', '软件学院');

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
WHERE college IN ('ai', 'ba', 'arts', 'ee', 'mech_energy', 'env_chem');

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

UPDATE topics
SET college = 'ai',
    major = CASE
        WHEN major IN ('cy', 'sw', 'se') THEN 'se'
        WHEN major IN ('bigdata', 'ds') THEN 'ds'
        WHEN major = 'ai' THEN 'ai'
        ELSE 'cs'
    END
WHERE college IN ('cs', 'sw');

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
SET t.college = u.college,
    t.major = u.major
WHERE t.college IS NULL OR t.college = '' OR t.major IS NULL OR t.major = '';

-- 最终口径收敛：前端只展示数据库里 status=1 的学院/学部。
UPDATE colleges
SET status = CASE
    WHEN code IN ('ai', 'ba', 'arts', 'ee', 'mech_energy', 'env_chem') THEN 1
    ELSE 0
END;

INSERT INTO majors(college_code, major_code, major_name, sort_order, status) VALUES
('ai', 'cs', '计算机科学与技术', 10, 1),
('ai', 'se', '软件工程', 20, 1),
('ai', 'ds', '数据科学与大数据技术', 30, 1),
('ai', 'ai', '人工智能', 40, 1),
('ee', 'ee', '电气工程及其自动化', 10, 1),
('ee', 'auto', '自动化', 20, 1),
('ee', 'eie', '电子信息工程', 30, 1),
('ee', 'power', '电力系统及其自动化', 40, 1),
('ee', 'control', '控制科学与工程', 50, 1),
('ba', 'ba', '工商管理', 10, 1),
('ba', 'acc', '会计学', 20, 1),
('ba', 'ec', '电子商务', 30, 1),
('ba', 'finance', '金融学', 40, 1),
('ba', 'marketing', '市场营销', 50, 1),
('ba', 'hr', '人力资源管理', 60, 1),
('arts', 'chinese', '汉语言文学', 10, 1),
('arts', 'eng', '英语', 20, 1),
('arts', 'law', '法学', 30, 1),
('arts', 'news', '新闻传播学', 40, 1),
('arts', 'history', '历史学', 50, 1),
('mech_energy', 'energy', '能源与动力工程', 10, 1),
('mech_energy', 'mech', '机械设计制造及其自动化', 20, 1),
('mech_energy', 'vehicle', '车辆工程', 30, 1),
('env_chem', 'env', '环境工程', 10, 1),
('env_chem', 'chem', '应用化学', 20, 1),
('env_chem', 'material', '材料科学与工程', 30, 1)
ON DUPLICATE KEY UPDATE major_name=VALUES(major_name), sort_order=VALUES(sort_order), status=VALUES(status);

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

-- 保留初始化演示课题的专业归属，不让历史迁移把“题目所属专业”覆盖成教师个人专业。
UPDATE topics SET major='cs' WHERE college='ai' AND title='基于JSP的毕业设计管理系统';
UPDATE topics SET major='ai' WHERE college='ai' AND title IN ('基于深度学习的图像识别系统', '智能客服机器人设计与实现');
UPDATE topics SET major='se' WHERE college='ai' AND title='校园二手交易平台';

ALTER TABLE users
    MODIFY role ENUM('admin','director','teacher','student') NOT NULL;

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'director', '系主任', 15, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status) VALUES
('director_ai_cs', 'e10adc3949ba59abbe56e057f20f883e', 'director', '计算机科学与技术系主任', NULL, 'ai', 'cs', NULL, '人工智能学部', 'director_ai_cs@school.edu', '13800000011', 1),
('director_ai_se', 'e10adc3949ba59abbe56e057f20f883e', 'director', '软件工程系主任', NULL, 'ai', 'se', NULL, '人工智能学部', 'director_ai_se@school.edu', '13800000012', 1),
('director_ai_ds', 'e10adc3949ba59abbe56e057f20f883e', 'director', '数据科学与大数据技术系主任', NULL, 'ai', 'ds', NULL, '人工智能学部', 'director_ai_ds@school.edu', '13800000013', 1),
('director_ai_ai', 'e10adc3949ba59abbe56e057f20f883e', 'director', '人工智能系主任', NULL, 'ai', 'ai', NULL, '人工智能学部', 'director_ai_ai@school.edu', '13800000014', 1)
ON DUPLICATE KEY UPDATE role=VALUES(role), real_name=VALUES(real_name), college=VALUES(college),
major=VALUES(major), department=VALUES(department), email=VALUES(email), phone=VALUES(phone), status=VALUES(status);
