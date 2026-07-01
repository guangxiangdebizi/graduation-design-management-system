-- =============================================================
-- 迁移脚本：课题容量按确认人数计算
-- 日期：2026-07-01
-- 说明：
--   1. 取消 topic_assignments.topic_id 的唯一约束，允许一个课题按 max_students 接收多名学生。
--   2. selected_count 表示已被教师/系主任确认的人数，不统计 pending 志愿。
--   3. 课题达到 max_students 后才关闭，未满时继续开放给其他学生填报志愿。
-- 本脚本可重复执行。
-- =============================================================
USE graduation_design;

SET @db := DATABASE();

SET @has_unique_topic := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA=@db
      AND TABLE_NAME='topic_assignments'
      AND INDEX_NAME='uk_topic_assignment_topic'
);

SET @drop_unique_sql := IF(
    @has_unique_topic > 0,
    'ALTER TABLE topic_assignments DROP INDEX uk_topic_assignment_topic',
    'SELECT 1'
);
PREPARE stmt FROM @drop_unique_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_topic_index := (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA=@db
      AND TABLE_NAME='topic_assignments'
      AND INDEX_NAME='idx_topic_assignment_topic'
);

SET @add_topic_index_sql := IF(
    @has_topic_index = 0,
    'ALTER TABLE topic_assignments ADD INDEX idx_topic_assignment_topic(topic_id)',
    'SELECT 1'
);
PREPARE stmt FROM @add_topic_index_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE topics t
SET selected_count = (
    SELECT COUNT(*) FROM topic_assignments a WHERE a.topic_id=t.id
);

UPDATE topics
SET status = CASE
    WHEN selected_count >= max_students THEN 'closed'
    WHEN status = 'closed' AND selected_count < max_students THEN 'open'
    ELSE status
END
WHERE status IN ('open','closed');
