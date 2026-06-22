USE graduation_design;

ALTER TABLE users
    MODIFY role ENUM('admin','director','teacher','student') NOT NULL;

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'director', '系主任', 15, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director01', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '人工智能学部系主任', NULL, 'ai', 'ai', NULL, '人工智能学部',
       'director@school.edu', '13800000009', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director01');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_cs', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '计算机科学与技术系主任', NULL, 'ai', 'cs', NULL, '人工智能学部',
       'director_ai_cs@school.edu', '13800000011', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_cs');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_se', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '软件工程系主任', NULL, 'ai', 'se', NULL, '人工智能学部',
       'director_ai_se@school.edu', '13800000012', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_se');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_ds', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '数据科学与大数据技术系主任', NULL, 'ai', 'ds', NULL, '人工智能学部',
       'director_ai_ds@school.edu', '13800000013', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_ds');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_ai', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '人工智能系主任', NULL, 'ai', 'ai', NULL, '人工智能学部',
       'director_ai_ai@school.edu', '13800000014', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_ai');
