-- =============================================================
-- 迁移脚本：多轮选题 + 文档自评/互评意见
-- 日期：2026-06-23
-- 说明：
--   1. topic_selections 增加 round 字段，记录该选题申请发生在第几轮
--   2. documents 增加 self_review（自评意见）、peer_review（互评意见）
--   3. system_configs 增加 selection.current_round（当前选题轮次）
-- 本脚本使用动态 SQL 做幂等处理，可重复执行。
-- =============================================================
USE graduation_design;

-- 1. topic_selections.round --------------------------------------------------
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'topic_selections'
      AND COLUMN_NAME = 'round');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE topic_selections ADD COLUMN round TINYINT NOT NULL DEFAULT 1 AFTER status',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2. documents.self_review ---------------------------------------------------
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'self_review');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN self_review TEXT AFTER feedback',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. documents.peer_review ---------------------------------------------------
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'peer_review');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN peer_review TEXT AFTER self_review',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4. system_configs：当前选题轮次 + 第二轮开关描述 ---------------------------
INSERT INTO system_configs(config_key, config_value, description) VALUES
('selection.current_round', '1', '当前选题轮次，管理员推进第二轮时改为 2')
ON DUPLICATE KEY UPDATE description = VALUES(description);

UPDATE system_configs
   SET description = '第二轮学生选题开关，开启后学生端进入第二轮'
 WHERE config_key = 'switch.selection_round2';
