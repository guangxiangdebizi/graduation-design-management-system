USE graduation_design;
SET NAMES utf8mb4;

SET @has_user_title := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'title'
);
SET @add_user_title_sql := IF(
    @has_user_title = 0,
    'ALTER TABLE users ADD COLUMN title VARCHAR(50) DEFAULT NULL COMMENT ''身份/职称，如教授、副教授、系主任、学生'' AFTER real_name',
    'SELECT 1'
);
PREPARE add_user_title_stmt FROM @add_user_title_sql;
EXECUTE add_user_title_stmt;
DEALLOCATE PREPARE add_user_title_stmt;

UPDATE users
SET title = CASE
        WHEN role='admin' THEN '管理员'
        WHEN role='director' THEN '系主任'
        WHEN role='student' THEN '学生'
        WHEN real_name LIKE '%副教授' THEN '副教授'
        WHEN real_name LIKE '%教授' THEN '教授'
        WHEN real_name LIKE '%讲师' THEN '讲师'
        WHEN real_name LIKE '%主任' THEN '主任'
        WHEN real_name LIKE '%老师' THEN '教师'
        WHEN role='teacher' THEN '教师'
        ELSE title
    END
WHERE title IS NULL OR title = '';

UPDATE users SET real_name='张建国', title='教授' WHERE username='teacher01';
UPDATE users SET real_name='李明华', title='副教授' WHERE username='teacher02';
UPDATE users SET real_name='王志远', title='教授' WHERE username='teacher03';
UPDATE users SET real_name='陈思明', title='讲师' WHERE username='teacher04';
UPDATE users SET real_name='刘雅文', title='副教授' WHERE username='teacher05';
UPDATE users SET real_name='赵启航', title='讲师' WHERE username='teacher06';
UPDATE users SET real_name='孙立新', title='教授' WHERE username='teacher07';
UPDATE users SET real_name='周若楠', title='讲师' WHERE username='teacher08';
UPDATE users SET real_name='吴文博', title='教师' WHERE username='teacher09';
UPDATE users SET real_name='郑雨薇', title='讲师' WHERE username='teacher10';
UPDATE users SET real_name='胡景明', title='讲师' WHERE username='teacher11';
UPDATE users SET real_name='高子轩', title='讲师' WHERE username='teacher12';
UPDATE users SET real_name='马清扬', title='讲师' WHERE username='teacher13';
UPDATE users SET real_name='林嘉宁', title='讲师' WHERE username='teacher14';

UPDATE users SET real_name='许明远', title='系主任' WHERE username='director01';
UPDATE users SET real_name='周启明', title='系主任' WHERE username='director_ai_cs';
UPDATE users SET real_name='宋嘉树', title='系主任' WHERE username='director_ai_se';
UPDATE users SET real_name='邵文澜', title='系主任' WHERE username='director_ai_ds';
UPDATE users SET real_name='韩知远', title='系主任' WHERE username='director_ai_ai';
UPDATE users SET real_name='陆景行', title='系主任' WHERE username='director_ee_power';
UPDATE users SET real_name='顾清宁', title='系主任' WHERE username='director_arts_history';

UPDATE users SET real_name='陈若松', title='教师' WHERE username='teacher_test_cs';
UPDATE users SET real_name='林知远', title='教师' WHERE username='teacher_test_ai';
UPDATE users SET real_name='王安和', title='教师' WHERE username='teacher_empty_cs';

UPDATE users SET real_name='沈明', title='管理员' WHERE username='admin';
UPDATE users SET real_name='秦文', title='教务管理员' WHERE username='admin02';
UPDATE users SET real_name='许宁', title='学院管理员' WHERE username='admin03';
UPDATE users SET real_name='程安', title='审计管理员' WHERE username='admin_audit';
UPDATE users SET real_name='叶舟', title='运维管理员' WHERE username='admin_ops';

UPDATE users
SET real_name = REGEXP_REPLACE(real_name, '副教授$', '')
WHERE real_name LIKE '%副教授';

UPDATE users
SET real_name = REGEXP_REPLACE(real_name, '教授$', '')
WHERE real_name LIKE '%教授';

UPDATE users
SET real_name = REGEXP_REPLACE(real_name, '老师$', '')
WHERE real_name LIKE '%老师';

UPDATE users
SET real_name = REGEXP_REPLACE(real_name, '主任$', '')
WHERE real_name LIKE '%主任' AND role='teacher';

UPDATE users
SET real_name = REGEXP_REPLACE(real_name, '系主任$', '')
WHERE real_name LIKE '%系主任' AND role='director';

UPDATE users
SET title='学生'
WHERE role='student' AND (title IS NULL OR title='');

SELECT id, username, role, real_name, title, student_no, college, major, class_name
FROM users
WHERE role IN ('admin','director','teacher')
ORDER BY role, id;
