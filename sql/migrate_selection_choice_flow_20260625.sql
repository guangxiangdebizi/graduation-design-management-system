-- =============================================================
-- 迁移脚本：三志愿选题 + 最终一题一人分配
-- 日期：2026-06-25
-- 说明：
--   1. selection_applications：学生每轮提交的一组选题志愿
--   2. selection_choices：第一/第二/第三志愿明细
--   3. topic_assignments：专业负责人最终确认后的一人一题结果
--   4. 保留旧 topic_selections，新增流程先兼容旧数据
-- =============================================================
USE graduation_design;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS selection_applications (
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

CREATE TABLE IF NOT EXISTS selection_choices (
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

CREATE TABLE IF NOT EXISTS topic_assignments (
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
    KEY idx_topic_assignment_topic (topic_id),
    CHECK (round IN (1, 2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO system_configs(config_key, config_value, description) VALUES
('selection.intent_limit', '3', '每个题目每轮最多志愿意向人数'),
('selection.choice_limit', '3', '每个学生每轮最多志愿数'),
('switch.manual_assign', '0', '强制分配阶段开关，管理员只控制开放状态，具体分配由系主任执行')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('status', 'confirmed', CONVERT(0xE5B7B2E7A1AEE8AEA4 USING utf8mb4), 65, 1),
('status', 'not_selected', CONVERT(0xE69CAAE4B8ADE98089 USING utf8mb4), 135, 1),
('status', 'invalid', CONVERT(0xE5B7B2E5A4B1E69588 USING utf8mb4), 136, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);
