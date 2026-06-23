USE graduation_design;

ALTER TABLE users
    MODIFY role ENUM('admin','director','teacher','student') NOT NULL;

SET @has_user_title_director_role := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'title'
);
SET @add_user_title_director_role_sql := IF(
    @has_user_title_director_role = 0,
    'ALTER TABLE users ADD COLUMN title VARCHAR(50) DEFAULT NULL COMMENT ''身份/职称，如教授、副教授、系主任、学生'' AFTER real_name',
    'SELECT 1'
);
PREPARE add_user_title_director_role_stmt FROM @add_user_title_director_role_sql;
EXECUTE add_user_title_director_role_stmt;
DEALLOCATE PREPARE add_user_title_director_role_stmt;

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('role', 'director', '系主任', 15, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director01', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '许明远', NULL, 'ai', 'ai', NULL, '人工智能学部',
       'director@school.edu', '13800000009', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director01');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_cs', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '周启明', NULL, 'ai', 'cs', NULL, '人工智能学部',
       'director_ai_cs@school.edu', '13800000011', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_cs');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_se', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '宋嘉树', NULL, 'ai', 'se', NULL, '人工智能学部',
       'director_ai_se@school.edu', '13800000012', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_se');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_ds', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '邵文澜', NULL, 'ai', 'ds', NULL, '人工智能学部',
       'director_ai_ds@school.edu', '13800000013', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_ds');

INSERT INTO users(username, password, role, real_name, student_no, college, major, class_name, department, email, phone, status)
SELECT 'director_ai_ai', 'e10adc3949ba59abbe56e057f20f883e',
       'director', '韩知远', NULL, 'ai', 'ai', NULL, '人工智能学部',
       'director_ai_ai@school.edu', '13800000014', 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username='director_ai_ai');

UPDATE users
SET title='系主任'
WHERE role='director' AND (title IS NULL OR title='');
