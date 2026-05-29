-- 毕业设计管理系统 数据库初始化脚本
CREATE DATABASE IF NOT EXISTS graduation_design DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE graduation_design;

DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS operation_logs;
DROP TABLE IF EXISTS document_versions;
DROP TABLE IF EXISTS defense_schedules;
DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS topic_selections;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    role ENUM('admin','teacher','student') NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    student_no VARCHAR(20) DEFAULT NULL,
    department VARCHAR(100) DEFAULT NULL,
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
    max_students INT DEFAULT 1,
    selected_count INT DEFAULT 0,
    status ENUM('open','closed') DEFAULT 'open',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE topic_selections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    topic_id INT NOT NULL,
    status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
    apply_reason TEXT,
    review_comment TEXT,
    apply_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    review_time DATETIME DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id)
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
    submit_time DATETIME DEFAULT NULL,
    review_time DATETIME DEFAULT NULL,
    reviewer_id INT DEFAULT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id),
    FOREIGN KEY (reviewer_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    publisher_id INT NOT NULL,
    is_top TINYINT DEFAULT 0,
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
    FOREIGN KEY (student_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE document_versions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    document_id INT NOT NULL,
    version_no INT NOT NULL,
    title VARCHAR(200) DEFAULT NULL,
    content TEXT,
    file_path VARCHAR(500) DEFAULT NULL,
    submit_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id)
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

-- 密码: admin123 / 123456 (MD5)
INSERT INTO users (username, password, role, real_name, student_no, department, email, phone) VALUES
('admin', '0192023a7bbd73250516f069df18b500', 'admin', '系统管理员', NULL, '教务处', 'admin@school.edu', '13800000001'),
('teacher01', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '张教授', NULL, '计算机学院', 'zhang@school.edu', '13800000002'),
('teacher02', 'e10adc3949ba59abbe56e057f20f883e', 'teacher', '李副教授', NULL, '软件学院', 'li@school.edu', '13800000003'),
('student01', 'e10adc3949ba59abbe56e057f20f883e', 'student', '王小明', '2022001001', '计算机学院', 'wang@stu.edu', '13900000001'),
('student02', 'e10adc3949ba59abbe56e057f20f883e', 'student', '刘小红', '2022001002', '计算机学院', 'liu@stu.edu', '13900000002'),
('student03', 'e10adc3949ba59abbe56e057f20f883e', 'student', '陈小刚', '2022001003', '软件学院', 'chen@stu.edu', '13900000003'),
('student04', 'e10adc3949ba59abbe56e057f20f883e', 'student', '赵小芳', '2022001004', '软件学院', 'zhao@stu.edu', '13900000004'),
('student05', 'e10adc3949ba59abbe56e057f20f883e', 'student', '孙小亮', '2022001005', '计算机学院', 'sun@stu.edu', '13900000005');

INSERT INTO topics (title, description, teacher_id, max_students, selected_count, status) VALUES
('基于JSP的毕业设计管理系统', '设计并实现一套完整的毕业设计全流程管理系统，包含选题、文档提交与审核等功能。', 2, 2, 1, 'open'),
('基于深度学习的图像识别系统', '使用卷积神经网络实现常见物体识别，并提供Web展示界面。', 2, 1, 1, 'open'),
('校园二手交易平台', '面向在校学生的C2C交易平台，支持商品发布、搜索与在线沟通。', 2, 2, 0, 'open'),
('智能图书推荐系统', '基于协同过滤算法为用户推荐图书，分析用户借阅行为。', 3, 2, 1, 'open'),
('在线考试系统的设计与实现', '支持题库管理、组卷、在线答题与自动阅卷。', 3, 1, 0, 'open');

INSERT INTO topic_selections (student_id, topic_id, status, apply_reason, review_comment, apply_time, review_time) VALUES
(4, 1, 'approved', '对Web开发有浓厚兴趣，希望完成一个完整的管理系统。', '基础扎实，同意选题。', '2026-03-01 10:00:00', '2026-03-02 09:00:00'),
(5, 2, 'approved', '有深度学习课程基础，想实践CNN项目。', '已修完机器学习，批准。', '2026-03-01 11:00:00', '2026-03-02 10:00:00'),
(6, 4, 'approved', '对推荐算法感兴趣。', '同意。', '2026-03-03 09:00:00', '2026-03-03 14:00:00'),
(7, 3, 'pending', '希望锻炼全栈开发能力。', NULL, '2026-05-20 15:00:00', NULL),
(8, 1, 'pending', '第二志愿申请该课题。', NULL, '2026-05-21 10:00:00', NULL);

UPDATE topics SET selected_count = 1 WHERE id IN (1, 2, 4);

INSERT INTO documents (student_id, topic_id, doc_type, title, content, file_path, status, score, feedback, submit_time, review_time, reviewer_id) VALUES
(4, 1, 'proposal', '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal.pdf', 'reviewed', 88.00, '开题报告结构清晰，研究目标明确。', '2026-03-15 10:00:00', '2026-03-18 14:00:00', 2),
(4, 1, 'midterm', '毕业设计管理系统中期检查', '目前已完成用户模块、选题模块的开发...', 'uploads/4/midterm.pdf', 'submitted', NULL, NULL, '2026-05-10 16:00:00', NULL, NULL),
(5, 2, 'proposal', '图像识别系统开题报告', '本课题基于ResNet模型实现图像分类...', 'uploads/5/proposal.pdf', 'reviewed', 92.00, '选题前沿，方案可行。', '2026-03-16 09:00:00', '2026-03-19 11:00:00', 2),
(6, 4, 'proposal', '图书推荐系统开题报告', '采用UserCF协同过滤算法...', 'uploads/6/proposal.pdf', 'submitted', NULL, NULL, '2026-05-18 11:00:00', NULL, NULL);

INSERT INTO document_versions (document_id, version_no, title, content, file_path, submit_time) VALUES
(1, 1, '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal_v1.pdf', '2026-03-10 09:00:00'),
(1, 2, '毕业设计管理系统开题报告', '本课题旨在设计一套基于JSP+Servlet+MySQL的毕业设计管理系统...', 'uploads/4/proposal.pdf', '2026-03-15 10:00:00'),
(3, 1, '图像识别系统开题报告', '本课题基于ResNet模型实现图像分类...', 'uploads/5/proposal.pdf', '2026-03-16 09:00:00');

INSERT INTO announcements (title, content, publisher_id, is_top) VALUES
('2026届毕业设计工作安排通知', '请各位同学于5月30日前完成选题，6月15日前提交开题报告。详细安排请查看教务处网站。', 1, 1),
('中期检查时间节点提醒', '中期检查时间为5月1日-5月20日，请各指导教师督促学生按时提交中期报告。', 1, 0),
('答辩安排（即将开放）', '答辩具体安排将在6月底发布，请同学们关注系统公告。', 1, 0);

INSERT INTO operation_logs (user_id, action, target, detail) VALUES
(1, 'LOGIN', 'admin', '管理员登录系统'),
(2, 'APPROVE', 'topic_selection', '批准 student01 选题申请');

INSERT INTO defense_schedules (student_id, defense_time, room, group_name, score, comment) VALUES
(4, '2026-06-20 09:00:00', '教学楼A301', '第一组', NULL, '请携带答辩PPT'),
(5, '2026-06-20 10:30:00', '教学楼A301', '第一组', NULL, '请携带答辩PPT'),
(6, '2026-06-20 14:00:00', '教学楼A302', '第二组', NULL, '请准时参加');

INSERT INTO messages (sender_id, receiver_id, title, content, is_read) VALUES
(1, 4, '答辩注意事项', '请各同学提前准备答辩PPT，答辩时间20分钟，提问10分钟。', 0),
(2, 4, '中期报告反馈', '你的中期报告已收到，整体进展良好，请继续完善文档模块。', 1),
(4, 2, '关于终稿格式', '老师您好，请问终稿是否需要按照学校模板排版？', 0);
