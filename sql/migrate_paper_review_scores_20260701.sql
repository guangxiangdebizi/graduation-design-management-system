-- =============================================================
-- 迁移脚本：毕业设计三段式最终成绩
-- 日期：2026-07-01
-- 说明：
--   1. documents 增加指导教师评分/评语
--   2. documents 增加论文评阅教师、评阅教师评分/意见
--   3. 兼容旧数据：把原 score/feedback 回填为 advisor_score/advisor_comment
--   4. 最终成绩由页面/导出动态计算：
--      advisor_score * 0.4 + reviewer_score * 0.2 + defense_avg * 0.4
-- 本脚本可重复执行。
-- =============================================================
USE graduation_design;
SET NAMES utf8mb4;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'advisor_score');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN advisor_score DECIMAL(5,2) DEFAULT NULL AFTER peer_review',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'advisor_comment');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN advisor_comment TEXT AFTER advisor_score',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'paper_reviewer_id');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN paper_reviewer_id INT DEFAULT NULL AFTER advisor_comment',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'reviewer_score');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN reviewer_score DECIMAL(5,2) DEFAULT NULL AFTER paper_reviewer_id',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'reviewer_comment');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN reviewer_comment TEXT AFTER reviewer_score',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND COLUMN_NAME = 'reviewer_review_time');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE documents ADD COLUMN reviewer_review_time DATETIME DEFAULT NULL AFTER reviewer_comment',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'documents'
      AND CONSTRAINT_NAME = 'fk_documents_paper_reviewer');
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE documents ADD CONSTRAINT fk_documents_paper_reviewer FOREIGN KEY (paper_reviewer_id) REFERENCES users(id)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE documents
SET advisor_score = score
WHERE doc_type='final' AND advisor_score IS NULL AND score IS NOT NULL;

UPDATE documents
SET advisor_comment = feedback
WHERE doc_type='final' AND advisor_comment IS NULL AND feedback IS NOT NULL;

UPDATE documents
SET score = advisor_score,
    feedback = advisor_comment,
    self_review = advisor_comment
WHERE doc_type='final' AND advisor_score IS NOT NULL;

SELECT 'migrate_paper_review_scores_20260701 applied' AS result;
