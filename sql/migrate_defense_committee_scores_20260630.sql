-- =============================================================
-- 迁移脚本：三教师答辩评分
-- 日期：2026-06-30
-- 说明：
--   1. defense_schedules 继续作为学生答辩主记录
--   2. defense_committee_members 记录系主任指定的三名答辩教师
--   3. defense_scores 记录每名答辩教师独立评分
--   4. defense_schedules.score 保存三名教师已评分平均值，兼容原统计字段
-- 本脚本可重复执行。
-- =============================================================
USE graduation_design;

CREATE TABLE IF NOT EXISTS defense_committee_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    teacher_id INT NOT NULL,
    member_order TINYINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_defense_member_teacher (schedule_id, teacher_id),
    UNIQUE KEY uk_defense_member_order (schedule_id, member_order),
    CONSTRAINT fk_defense_member_schedule
        FOREIGN KEY (schedule_id) REFERENCES defense_schedules(id) ON DELETE CASCADE,
    CONSTRAINT fk_defense_member_teacher
        FOREIGN KEY (teacher_id) REFERENCES users(id),
    CHECK (member_order BETWEEN 1 AND 3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS defense_scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    teacher_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    comment TEXT,
    score_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_defense_score_teacher (schedule_id, teacher_id),
    CONSTRAINT fk_defense_score_schedule
        FOREIGN KEY (schedule_id) REFERENCES defense_schedules(id) ON DELETE CASCADE,
    CONSTRAINT fk_defense_score_teacher
        FOREIGN KEY (teacher_id) REFERENCES users(id),
    CHECK (score >= 0 AND score <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
