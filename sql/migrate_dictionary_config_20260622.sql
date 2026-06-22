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
('cs', '计算机学院', 10, 1),
('sw', '软件学院', 20, 1),
('ee', '电气学院', 30, 1),
('ai', '人工智能学部', 40, 1),
('ba', '经管学院', 50, 1),
('arts', '文科学部', 60, 1),
('science', '理学部', 70, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO majors(college_code, major_code, major_name, sort_order, status) VALUES
('cs', 'cs', '计算机科学与技术', 10, 1),
('cs', 'cy', '软件工程', 20, 1),
('cs', 'is', '信息安全', 30, 1),
('cs', 'ai', '人工智能', 40, 1),
('sw', 'sw', '软件工程', 10, 1),
('sw', 'bigdata', '数据科学与大数据技术', 20, 1),
('ee', 'ee', '电气工程及其自动化', 10, 1),
('ee', 'auto', '自动化', 20, 1),
('ee', 'eie', '电子信息工程', 30, 1),
('ai', 'ai', '人工智能', 10, 1),
('ai', 'robot', '机器人工程', 20, 1),
('ba', 'ba', '工商管理', 10, 1),
('ba', 'acc', '会计学', 20, 1),
('ba', 'ec', '电子商务', 30, 1),
('arts', 'chinese', '汉语言文学', 10, 1),
('arts', 'eng', '英语', 20, 1),
('arts', 'law', '法学', 30, 1),
('science', 'math', '数学与应用数学', 10, 1),
('science', 'phys', '物理学', 20, 1)
ON DUPLICATE KEY UPDATE major_name=VALUES(major_name), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'admin', '管理员', 10, 1),
('role', 'teacher', '教师', 20, 1),
('role', 'student', '学生', 30, 1),
('user_status', '1', '正常', 10, 1),
('user_status', '0', '禁用', 20, 1),
('topic_status', 'open', '开放选题', 10, 1),
('topic_status', 'closed', '关闭选题', 20, 1),
('document_type', 'proposal', '开题报告', 10, 1),
('document_type', 'midterm', '中期检查', 20, 1),
('document_type', 'final', '终稿', 30, 1),
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
    WHEN '计算机学院' THEN 'cs'
    WHEN '软件学院' THEN 'sw'
    WHEN '电气学院' THEN 'ee'
    WHEN '人工智能学部' THEN 'ai'
    WHEN '经管学院' THEN 'ba'
    WHEN '文科学部' THEN 'arts'
    WHEN '理学部' THEN 'science'
    ELSE college
END
WHERE college IS NULL OR college = '';

UPDATE users
SET major = CASE college
    WHEN 'cs' THEN 'cs'
    WHEN 'sw' THEN 'sw'
    WHEN 'ee' THEN 'ee'
    WHEN 'ai' THEN 'ai'
    WHEN 'ba' THEN 'ba'
    WHEN 'arts' THEN 'chinese'
    WHEN 'science' THEN 'math'
    ELSE major
END
WHERE role IN ('teacher', 'student') AND (major IS NULL OR major = '');

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
WHERE t.college IS NULL OR t.college = '';
