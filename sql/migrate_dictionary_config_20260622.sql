USE graduation_design;

CREATE TABLE IF NOT EXISTS colleges (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS majors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    college_code VARCHAR(50) NOT NULL,
    major_code VARCHAR(50) NOT NULL,
    major_name VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    UNIQUE KEY uk_major_college_code (college_code, major_code),
    FOREIGN KEY (college_code) REFERENCES colleges(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS dictionary_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dict_type VARCHAR(50) NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    item_label VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    UNIQUE KEY uk_dict_type_code (dict_type, item_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS system_configs (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value VARCHAR(500) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'admin', '管理员', 10, 1),
('role', 'director', '系主任', 15, 1),
('role', 'teacher', '教师', 20, 1),
('role', 'student', '学生', 30, 1),
('college_alias', 'cs', 'ai', 10, 1),
('college_alias', 'sw', 'ai', 20, 1),
('major_alias', 'cy', 'se', 10, 1),
('major_alias', 'sw', 'se', 20, 1),
('major_alias', 'bigdata', 'ds', 30, 1),
('user_status', '1', '正常', 10, 1),
('user_status', '0', '禁用', 20, 1),
('topic_status', 'open', '开放选题', 10, 1),
('topic_status', 'closed', '关闭选题', 20, 1),
('document_type', 'proposal', '开题报告', 10, 1),
('document_type', 'midterm', '中期检查', 20, 1),
('document_type', 'final', '终稿/结题材料', 30, 1),
('status', 'pending', '待审核', 10, 1),
('status', 'approved', '已通过', 20, 1),
('status', 'rejected', '已拒绝', 30, 1),
('status', 'cancelled', '已取消', 40, 1),
('status', 'draft', '草稿', 50, 1),
('status', 'submitted', '已提交', 60, 1),
('status', 'reviewed', '已审核', 70, 1),
('status', 'open', '开放', 80, 1),
('status', 'closed', '已关闭', 90, 1),
('status', 'arranged', '已安排', 100, 1),
('status', 'unsubmitted', '未提交', 110, 1),
('status', 'unselected', '未选题', 120, 1),
('status', 'selected', '已选题', 130, 1),
('status', 'unread', '未读', 140, 1),
('status', 'read', '已读', 150, 1),
('status', 'sent', '已发送', 160, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO system_configs(config_key, config_value, description) VALUES
('page.default_size', '10', '默认分页大小'),
('upload.max_size_bytes', '10485760', '上传文件大小上限，单位字节'),
('upload.allowed_extensions', 'pdf,doc,docx,zip,rar', '允许上传的文件扩展名'),
('upload.blocked_extensions', 'exe,jsp,jspx,bat,cmd,sh', '禁止上传的文件扩展名'),
('login.max_attempts', '5', '登录失败锁定前最大尝试次数'),
('login.lock_minutes', '15', '登录失败锁定分钟数'),
('validation.username_regex', '^[a-zA-Z0-9_]{3,20}$', '用户名校验正则'),
('validation.password_min_length', '6', '密码最小长度'),
('validation.student_no_regex', '^[0-9]{5,20}$', '学号校验正则'),
('validation.phone_regex', '^1[3-9]\\d{9}$', '手机号校验正则'),
('validation.email_regex', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$', '邮箱校验正则')
ON DUPLICATE KEY UPDATE config_value=VALUES(config_value), description=VALUES(description);

UPDATE users
SET college = CASE department
    WHEN '计算机学院' THEN 'ai'
    WHEN '软件学院' THEN 'ai'
    WHEN '电气学院' THEN 'ee'
    WHEN '电气工程学部' THEN 'ee'
    WHEN '人工智能学部' THEN 'ai'
    WHEN '经管学院' THEN 'ba'
    WHEN '文科学部' THEN 'arts'
    WHEN '能源与机械动力学院' THEN 'mech_energy'
    WHEN '环境与化学工程学院' THEN 'env_chem'
    ELSE college
END
WHERE college IS NULL OR college = '';

UPDATE users
SET college = 'ai'
WHERE college IN ('cs', 'sw') OR department IN ('计算机学院', '软件学院');

UPDATE users
SET major = CASE college
    WHEN 'ai' THEN CASE
        WHEN major IN ('cy', 'sw', 'se') THEN 'se'
        WHEN major IN ('bigdata', 'ds') THEN 'ds'
        WHEN major = 'ai' THEN 'ai'
        ELSE 'cs'
    END
    WHEN 'ee' THEN 'ee'
    WHEN 'ba' THEN 'ba'
    WHEN 'arts' THEN 'chinese'
    WHEN 'mech_energy' THEN 'mech'
    WHEN 'env_chem' THEN 'env'
    ELSE major
END
WHERE role IN ('teacher', 'student') AND (major IS NULL OR major = '');

UPDATE users
SET major = CASE
    WHEN major IN ('cy', 'sw', 'se') THEN 'se'
    WHEN major IN ('bigdata', 'ds') THEN 'ds'
    WHEN major = 'ai' THEN 'ai'
    ELSE 'cs'
END
WHERE college = 'ai' AND major NOT IN ('cs', 'se', 'ds', 'ai');

UPDATE users u
JOIN colleges c ON c.code = u.college
SET u.department = c.name
WHERE u.department IS NULL OR u.department = '';

UPDATE users u
JOIN majors m ON m.college_code = u.college AND m.major_code = u.major
SET u.class_name = CONCAT(m.major_name, '2022级1班')
WHERE u.role = 'student' AND (u.class_name IS NULL OR u.class_name = '');

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
SET t.college = u.college
WHERE t.college IS NULL OR t.college = '' OR t.college IN ('cs', 'sw');

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

UPDATE topics t
JOIN users u ON t.teacher_id = u.id
SET t.major = u.major
WHERE t.major IS NULL OR t.major = '';

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
