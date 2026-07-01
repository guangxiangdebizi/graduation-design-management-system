USE graduation_design;

SET NAMES utf8mb4;

SET @has_scope_type := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'announcements' AND COLUMN_NAME = 'scope_type'
);
SET @add_scope_type_sql := IF(
    @has_scope_type = 0,
    'ALTER TABLE announcements ADD COLUMN scope_type ENUM(''global'',''college'',''major'') DEFAULT ''global'' AFTER is_top',
    'SELECT 1'
);
PREPARE add_scope_type_stmt FROM @add_scope_type_sql;
EXECUTE add_scope_type_stmt;
DEALLOCATE PREPARE add_scope_type_stmt;

SET @has_announcement_college := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'announcements' AND COLUMN_NAME = 'college'
);
SET @add_announcement_college_sql := IF(
    @has_announcement_college = 0,
    'ALTER TABLE announcements ADD COLUMN college VARCHAR(50) DEFAULT NULL AFTER scope_type',
    'SELECT 1'
);
PREPARE add_announcement_college_stmt FROM @add_announcement_college_sql;
EXECUTE add_announcement_college_stmt;
DEALLOCATE PREPARE add_announcement_college_stmt;

SET @has_announcement_major := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'announcements' AND COLUMN_NAME = 'major'
);
SET @add_announcement_major_sql := IF(
    @has_announcement_major = 0,
    'ALTER TABLE announcements ADD COLUMN major VARCHAR(50) DEFAULT NULL AFTER college',
    'SELECT 1'
);
PREPARE add_announcement_major_stmt FROM @add_announcement_major_sql;
EXECUTE add_announcement_major_stmt;
DEALLOCATE PREPARE add_announcement_major_stmt;

UPDATE announcements
SET scope_type = 'global', college = NULL, major = NULL
WHERE scope_type IS NULL OR scope_type = '';

-- 历史跨专业选题不再保留为有效申请，避免系主任统计/导出混入其他专业数据。
UPDATE topic_selections s
JOIN users u ON s.student_id = u.id
JOIN topics t ON s.topic_id = t.id
SET s.status = 'rejected',
    s.review_comment = CONCAT(COALESCE(s.review_comment, ''), ' [系统清理：学生与课题专业不一致]'),
    s.review_time = COALESCE(s.review_time, NOW())
WHERE s.status IN ('pending','approved')
  AND (u.college <> t.college OR u.major <> t.major);

UPDATE topics t
SET selected_count = (
    SELECT COUNT(*)
    FROM topic_selections s
    WHERE s.topic_id = t.id AND s.status = 'approved'
);

UPDATE topics
SET status = CASE
    WHEN selected_count >= max_students THEN 'closed'
    WHEN status = 'closed' AND selected_count < max_students THEN 'open'
    ELSE status
END
WHERE status IN ('open','closed');

SELECT
    (SELECT COUNT(*) FROM users WHERE role='director' AND status=1
        AND (college IS NULL OR college='' OR major IS NULL OR major='')) AS director_without_scope,
    (SELECT COUNT(*) FROM topic_selections s
        JOIN users u ON s.student_id=u.id
        JOIN topics t ON s.topic_id=t.id
        WHERE s.status IN ('pending','approved')
          AND (u.college<>t.college OR u.major<>t.major)) AS active_cross_major_selection;
