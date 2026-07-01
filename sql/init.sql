-- 毕业设计管理系统 数据库初始化脚本
CREATE DATABASE IF NOT EXISTS graduation_design DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE graduation_design;

DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS operation_logs;
DROP TABLE IF EXISTS document_versions;
DROP TABLE IF EXISTS defense_scores;
DROP TABLE IF EXISTS defense_committee_members;
DROP TABLE IF EXISTS defense_schedules;
DROP TABLE IF EXISTS file_templates;
DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS topic_assignments;
DROP TABLE IF EXISTS selection_choices;
DROP TABLE IF EXISTS selection_applications;
DROP TABLE IF EXISTS topic_selections;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS majors;
DROP TABLE IF EXISTS colleges;
DROP TABLE IF EXISTS dictionary_items;
DROP TABLE IF EXISTS system_configs;

CREATE TABLE colleges (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE majors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    college_code VARCHAR(50) NOT NULL,
    major_code VARCHAR(50) NOT NULL,
    major_name VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    UNIQUE KEY uk_major_college_code (college_code, major_code),
    FOREIGN KEY (college_code) REFERENCES colleges(code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dictionary_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dict_type VARCHAR(50) NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    item_label VARCHAR(100) NOT NULL,
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    UNIQUE KEY uk_dict_type_code (dict_type, item_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE system_configs (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value VARCHAR(500) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    role ENUM('admin','director','teacher','student') NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    title VARCHAR(50) DEFAULT NULL COMMENT '身份/职称，如教授、副教授、系主任、学生',
    student_no VARCHAR(20) DEFAULT NULL UNIQUE,
    college VARCHAR(50) DEFAULT NULL COMMENT '学院/学部代码',
    major VARCHAR(50) DEFAULT NULL COMMENT '专业代码',
    class_name VARCHAR(50) DEFAULT NULL COMMENT '班级',
    department VARCHAR(100) DEFAULT NULL COMMENT '保留字段，兼容旧数据',
    email VARCHAR(100) DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    teacher_id INT NOT NULL,
    college VARCHAR(50) DEFAULT NULL COMMENT '课题所属学院',
    major VARCHAR(50) DEFAULT NULL COMMENT '课题所属专业',
    max_students INT DEFAULT 1,
    selected_count INT DEFAULT 0,
    status ENUM('pending','open','closed','rejected') DEFAULT 'pending',
    review_comment TEXT DEFAULT NULL,
    reviewer_id INT DEFAULT NULL,
    review_time DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE topic_selections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
    round TINYINT NOT NULL DEFAULT 1,
    apply_reason TEXT,
    review_comment TEXT,
    apply_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    review_time DATETIME DEFAULT NULL,
    active_guard TINYINT GENERATED ALWAYS AS (
        CASE WHEN status IN ('pending','approved') THEN 1 ELSE NULL END
    ) STORED,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id),
    UNIQUE KEY uk_student_active_selection (student_id, active_guard)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE selection_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    round TINYINT NOT NULL,
    status ENUM('submitted','confirmed','expired','cancelled') NOT NULL DEFAULT 'submitted',
    submit_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active_guard TINYINT GENERATED ALWAYS AS (
        CASE WHEN status='submitted' THEN 1 ELSE NULL END
    ) STORED,
    FOREIGN KEY (student_id) REFERENCES users(id),
    UNIQUE KEY uk_selection_app_student_round_active (student_id, round, active_guard),
    CHECK (round IN (1, 2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE selection_choices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    round TINYINT NOT NULL,
    choice_rank TINYINT NOT NULL,
    status ENUM('pending','selected','not_selected','invalid') NOT NULL DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES selection_applications(id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id),
    UNIQUE KEY uk_selection_choice_application_rank (application_id, choice_rank),
    UNIQUE KEY uk_selection_choice_application_topic (application_id, topic_id),
    KEY idx_selection_choice_topic_round_status (topic_id, round, status),
    KEY idx_selection_choice_student_round (student_id, round),
    CHECK (choice_rank BETWEEN 1 AND 3),
    CHECK (round IN (1, 2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE topic_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    choice_id INT DEFAULT NULL,
    round TINYINT NOT NULL DEFAULT 1,
    source ENUM('round1','round2','manual') NOT NULL,
    confirmed_by INT NOT NULL,
    confirm_comment TEXT,
    confirm_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id),
    FOREIGN KEY (choice_id) REFERENCES selection_choices(id),
    FOREIGN KEY (confirmed_by) REFERENCES users(id),
    UNIQUE KEY uk_topic_assignment_student (student_id),
    UNIQUE KEY uk_topic_assignment_topic (topic_id),
    CHECK (round IN (1, 2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    doc_type ENUM('proposal','midterm','final') NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    file_path VARCHAR(500) DEFAULT NULL,
    status ENUM('draft','submitted','reviewed','rejected') DEFAULT 'draft',
    score DECIMAL(5,2) DEFAULT NULL,
    feedback TEXT,
    self_review TEXT,
    peer_review TEXT,
    advisor_score DECIMAL(5,2) DEFAULT NULL,
    advisor_comment TEXT,
    paper_reviewer_id INT DEFAULT NULL,
    reviewer_score DECIMAL(5,2) DEFAULT NULL,
    reviewer_comment TEXT,
    reviewer_review_time DATETIME DEFAULT NULL,
    submit_time DATETIME DEFAULT NULL,
    review_time DATETIME DEFAULT NULL,
    reviewer_id INT DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id),
    FOREIGN KEY (paper_reviewer_id) REFERENCES users(id),
    UNIQUE KEY uk_student_doc_type (student_id, doc_type),
    CHECK (score IS NULL OR (score >= 0 AND score <= 100)),
    CHECK (advisor_score IS NULL OR (advisor_score >= 0 AND advisor_score <= 100)),
    CHECK (reviewer_score IS NULL OR (reviewer_score >= 0 AND reviewer_score <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    publisher_id INT NOT NULL,
    is_top TINYINT DEFAULT 0,
    scope_type ENUM('global','college','major') DEFAULT 'global',
    college VARCHAR(50) DEFAULT NULL,
    major VARCHAR(50) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE defense_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    defense_time DATETIME DEFAULT NULL,
    room VARCHAR(50) DEFAULT NULL,
    group_name VARCHAR(50) DEFAULT NULL,
    score DECIMAL(5,2) DEFAULT NULL,
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_defense_student (student_id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    CHECK (score IS NULL OR (score >= 0 AND score <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE defense_committee_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    teacher_id INT NOT NULL,
    member_order TINYINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (schedule_id) REFERENCES defense_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    UNIQUE KEY uk_defense_member_teacher (schedule_id, teacher_id),
    UNIQUE KEY uk_defense_member_order (schedule_id, member_order),
    CHECK (member_order BETWEEN 1 AND 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE defense_scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    teacher_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    comment TEXT,
    score_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (schedule_id) REFERENCES defense_schedules(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    UNIQUE KEY uk_defense_score_teacher (schedule_id, teacher_id),
    CHECK (score >= 0 AND score <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE document_versions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    document_id INT NOT NULL,
    version_no INT NOT NULL,
    title VARCHAR(200) DEFAULT NULL,
    content TEXT,
    file_path VARCHAR(500) DEFAULT NULL,
    submit_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id),
    UNIQUE KEY uk_document_version (document_id, version_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE operation_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    action VARCHAR(50) NOT NULL,
    target VARCHAR(100) DEFAULT NULL,
    detail TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_read TINYINT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE file_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(200) NOT NULL,
    doc_type VARCHAR(50) DEFAULT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    original_filename VARCHAR(255) DEFAULT NULL,
    file_size BIGINT DEFAULT 0,
    uploader_id INT NOT NULL,
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO colleges(code, name, sort_order, status) VALUES
('ai', '人工智能学部', 10, 1),
('ba', '经管学院', 20, 1),
('arts', '文科学部', 30, 1),
('ee', '电气工程学部', 40, 1),
('mech_energy', '能源与机械动力学院', 50, 1),
('env_chem', '环境与化学工程学院', 60, 1);

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
('env_chem', 'material', '材料科学与工程', 30, 1);

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'admin', '管理员', 10, 1),
('role', 'director', '系主任', 15, 1),
('role', 'teacher', '教师', 20, 1),
('role', 'student', '学生', 30, 1),
('user_status', '1', '正常', 10, 1),
('user_status', '0', '禁用', 20, 1),
('topic_status', 'pending', '待审核', 5, 1),
('topic_status', 'open', '开放选题', 10, 1),
('topic_status', 'closed', '关闭选题', 20, 1),
('topic_status', 'rejected', '已驳回', 30, 1),
('document_type', 'proposal', '开题报告', 10, 1),
('document_type', 'midterm', '中期检查', 20, 1),
('document_type', 'final', '终稿/结题材料', 30, 1),
('status', 'pending', '待审核', 10, 1),
('status', 'approved', '已通过', 20, 1),
('status', 'rejected', '已拒绝', 30, 1),
('status', 'cancelled', '已取消', 40, 1),
('status', 'draft', '草稿', 50, 1),
('status', 'submitted', '已提交', 60, 1),
('status', 'confirmed', '已确认', 65, 1),
('status', 'reviewed', '已审核', 70, 1),
('status', 'open', '开放', 80, 1),
('status', 'closed', '已关闭', 90, 1),
('status', 'arranged', '已安排', 100, 1),
('status', 'unsubmitted', '未提交', 110, 1),
('status', 'unselected', '未选题', 120, 1),
('status', 'selected', '已选题', 130, 1),
('status', 'not_selected', '未中选', 135, 1),
('status', 'invalid', '已失效', 136, 1),
('status', 'unread', '未读', 140, 1),
('status', 'read', '已读', 150, 1),
('status', 'sent', '已发送', 160, 1);

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
('validation.email_regex', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$', '邮箱校验正则'),
('switch.topic_submit', '1', '教师出题开关'),
('switch.selection', '1', '第一轮学生选题开关'),
('switch.selection_round1', '1', '第一轮学生选题开关，兼容旧配置'),
('switch.selection_round2', '0', '第二轮学生选题开关，开启后学生端进入第二轮'),
('switch.manual_assign', '0', '强制分配阶段开关，管理员只控制开放状态，具体分配由系主任执行'),
('selection.current_round', '1', '当前选题轮次，管理员推进第二轮时改为 2'),
('selection.intent_limit', '3', '每个题目每轮最多志愿意向人数'),
('selection.choice_limit', '3', '每个学生每轮最多志愿数'),
('switch.upload_proposal', '1', '开题报告上传开关'),
('switch.upload_midterm', '1', '中期报告上传开关'),
('switch.upload_final', '1', '终稿/结题材料上传开关');

-- 密码: admin123 / 123456 (MD5)
INSERT INTO users (username, password, role, real_name, title, student_no, college, major, class_name, department, email, phone) VALUES
('admin', '0192023a7bbd73250516f069df18b500', 'admin', '沈明', '管理员', NULL, NULL, NULL, NULL, '教务处', 'admin@school.edu', '13800000001'),
('teacher01', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '张建国', '教授', NULL, 'ai', 'cs', NULL, '人工智能学部', 'zhang@school.edu', '13800000002'),
('teacher02', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '李明华', '副教授', NULL, 'ee', 'ee', NULL, '电气工程学部', 'li@school.edu', '13800000003'),
('student01', 'e10adc3949ba59abbe56e057f20f883e', 'student', '王小明', '学生', '2022001001', 'ai', 'cs', '计算机科学与技术2022级1班', '人工智能学部', 'wang@stu.edu', '13900000001'),
('student02', 'e10adc3949ba59abbe56e057f20f883e', 'student', '刘小红', '学生', '2022001002', 'ai', 'se', '软件工程2022级1班', '人工智能学部', 'liu@stu.edu', '13900000002'),
('student03', 'e10adc3949ba59abbe56e057f20f883e', 'student', '陈小刚', '学生', '2022001003', 'ai', 'se', '软件工程2022级2班', '人工智能学部', 'chen@stu.edu', '13900000003'),
('student04', 'e10adc3949ba59abbe56e057f20f883e', 'student', '赵小芳', '学生', '2022001004', 'ee', 'ee', '电气工程及其自动化2022级1班', '电气工程学部', 'zhao@stu.edu', '13900000004'),
('student05', 'e10adc3949ba59abbe56e057f20f883e', 'student', '孙小亮', '学生', '2022001005', 'ai', 'ai', '人工智能2022级1班', '人工智能学部', 'sun@stu.edu', '13900000005'),
('student06', 'e10adc3949ba59abbe56e057f20f883e', 'student', '周小丽', '学生', '2022001006', 'ba', 'ba', '工商管理2022级1班', '经管学院', 'zhou@stu.edu', '13900000006'),
('student07', 'e10adc3949ba59abbe56e057f20f883e', 'student', '吴小强', '学生', '2022001007', 'arts', 'chinese', '汉语言文学2022级1班', '文科学部', 'wu@stu.edu', '13900000007'),
('student08', 'e10adc3949ba59abbe56e057f20f883e', 'student', '郑小华', '学生', '2022001008', 'mech_energy', 'mech', '机械设计制造及其自动化2022级1班', '能源与机械动力学院', 'zheng@stu.edu', '13900000008'),
('director_ai_cs', 'e10adc3949ba59abbe56e057f20f883e', 'director', '周启明', '系主任', NULL, 'ai', 'cs', NULL, '人工智能学部', 'director_ai_cs@school.edu', '13800000011'),
('director_ai_se', 'e10adc3949ba59abbe56e057f20f883e', 'director', '宋嘉树', '系主任', NULL, 'ai', 'se', NULL, '人工智能学部', 'director_ai_se@school.edu', '13800000012'),
('director_ai_ds', 'e10adc3949ba59abbe56e057f20f883e', 'director', '邵文澜', '系主任', NULL, 'ai', 'ds', NULL, '人工智能学部', 'director_ai_ds@school.edu', '13800000013'),
('director_ai_ai', 'e10adc3949ba59abbe56e057f20f883e', 'director', '韩知远', '系主任', NULL, 'ai', 'ai', NULL, '人工智能学部', 'director_ai_ai@school.edu', '13800000014'),
('director01', 'e10adc3949ba59abbe56e057f20f883e', 'director', '许明远', '系主任', NULL, 'ai', 'ai', NULL, '人工智能学部', 'director@school.edu', '13800000009');

INSERT INTO topics (title, description, teacher_id, college, major, max_students, selected_count, status) VALUES
('基于JSP的毕业设计管理系统', '设计并实现一套完整的毕业设计全流程管理系统，包含选题、文档提交与审核等功能。', 2, 'ai', 'cs', 3, 1, 'open'),
('基于深度学习的图像识别系统', '使用卷积神经网络实现常见物体识别，并提供Web展示界面。', 2, 'ai', 'ai', 2, 1, 'open'),
('校园二手交易平台', '面向在校学生的C2C交易平台，支持商品发布、搜索与在线沟通。', 2, 'ai', 'se', 2, 0, 'open'),
('智能图书推荐系统', '基于协同过滤算法为用户推荐图书，分析用户借阅行为。', 3, 'ee', 'ee', 2, 1, 'open'),
('电气设备远程监控系统', '设计并实现基于物联网的电气设备远程监控与故障诊断系统。', 3, 'ee', 'auto', 2, 0, 'open'),
('智能客服机器人设计与实现', '基于自然语言处理技术实现智能客服对话系统。', 2, 'ai', 'ai', 2, 0, 'open'),
('企业财务管理系统', '面向中小企业的财务收支管理与报表分析系统。', 3, 'ba', 'ba', 2, 0, 'open');

INSERT INTO topic_selections (student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time) VALUES
(4, 1, 'approved', '对Web开发有浓厚兴趣，希望完成一个完整的管理系统。', '基础扎实，同意选题。', '2026-03-01 10:00:00', '2026-03-02 09:00:00'),
(5, 2, 'approved', '有深度学习课程基础，想实践CNN项目。', '已修完机器学习，批准。', '2026-03-01 11:00:00', '2026-03-02 10:00:00'),
(6, 1, 'pending', '希望锻炼全栈开发能力。', NULL, '2026-05-20 15:00:00', NULL),
(7, 4, 'approved', '对电气控制感兴趣。', '同意选题。', '2026-03-03 09:00:00', '2026-03-03 14:00:00'),
(8, 3, 'pending', '想做一个实用的电商项目。', NULL, '2026-05-21 10:00:00', NULL);

UPDATE topics SET selected_count = 1 WHERE id IN (1, 2, 4);

INSERT INTO documents (student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id) VALUES
(4, 1, 'proposal', '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal.pdf', 'reviewed', 88.00, '开题报告结构清晰，研究目标明确。', '2026-03-15 10:00:00', '2026-03-18 14:00:00', 2),
(4, 1, 'midterm', '毕业设计管理系统中期检查', '目前已完成用户模块、选题模块的开发...', 'uploads/4/midterm.pdf', 'submitted', NULL, NULL, '2026-05-10 16:00:00', NULL, NULL),
(5, 2, 'proposal', '图像识别系统开题报告', '本课题基于ResNet模型实现图像分类...', 'uploads/5/proposal.pdf', 'reviewed', 92.00, '选题前沿，方案可行。', '2026-03-16 09:00:00', '2026-03-19 11:00:00', 2),
(7, 4, 'proposal', '图书推荐系统开题报告', '采用UserCF协同过滤算法...', 'uploads/7/proposal.pdf', 'submitted', NULL, NULL, '2026-05-18 11:00:00', NULL, NULL);

INSERT INTO document_versions (document_id, version_no, title, content, file_path, submit_time) VALUES
(1, 1, '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal_v1.pdf', '2026-03-10 09:00:00'),
(1, 2, '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal.pdf', '2026-03-15 10:00:00'),
(3, 1, '图像识别系统开题报告', '本课题基于ResNet模型实现图像分类...', 'uploads/5/proposal.pdf', '2026-03-16 09:00:00');

INSERT INTO announcements (title, content, publisher_id, is_top, scope_type, college, major) VALUES
('2026届毕业设计工作安排通知', '请各位同学于5月30日前完成选题，6月15日前提交开题报告。详细安排请查看教务处网站。', 1, 1, 'global', NULL, NULL),
('中期检查时间节点提醒', '中期检查时间为5月1日-5月20日，请各指导教师督促学生按时提交中期报告。', 1, 0, 'global', NULL, NULL),
('答辩安排（即将开放）', '答辩具体安排将在6月底发布，请同学们关注系统公告。', 1, 0, 'global', NULL, NULL);

INSERT INTO operation_logs (user_id, action, target, detail) VALUES
(1, 'LOGIN', 'admin', '管理员登录系统'),
(2, 'APPROVE', 'topic_selection', '批准 student01 选题申请');

INSERT INTO defense_schedules (student_id, defense_time, room, group_name, score, comment) VALUES
(4, '2026-06-20 09:00:00', '教学楼A301', '第一组', NULL, '请携带答辩PPT'),
(5, '2026-06-20 10:30:00', '教学楼A301', '第一组', NULL, '请携带答辩PPT'),
(7, '2026-06-20 14:00:00', '教学楼A302', '第二组', NULL, '请准时参加');

INSERT INTO messages (sender_id, receiver_id, title, content, is_read) VALUES
(1, 4, '答辩注意事项', '请各同学提前准备答辩PPT，答辩时间20分钟，提问10分钟。', 0),
(2, 4, '中期报告反馈', '你的中期报告已收到，整体进展良好，请继续完善文档模块。', 1),
(4, 2, '关于终稿格式', '老师您好，请问终稿是否需要按照学校模板排版？', 0);
