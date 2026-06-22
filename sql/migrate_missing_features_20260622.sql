USE graduation_design;

ALTER TABLE topics
    MODIFY status ENUM('pending','open','closed','rejected') DEFAULT 'pending',
    ADD COLUMN review_comment TEXT DEFAULT NULL AFTER status,
    ADD COLUMN reviewer_id INT DEFAULT NULL AFTER review_comment,
    ADD COLUMN review_time DATETIME DEFAULT NULL AFTER reviewer_id;

UPDATE topics SET status='open' WHERE status IS NULL OR status='';

INSERT INTO dictionary_items(dict_type, item_code, item_label, sort_order, status) VALUES
('topic_status', 'pending', '待审核', 5, 1),
('topic_status', 'rejected', '已驳回', 30, 1),
('status', 'pending', '待审核', 10, 1),
('status', 'rejected', '已驳回', 30, 1)
ON DUPLICATE KEY UPDATE item_label=VALUES(item_label), sort_order=VALUES(sort_order), status=VALUES(status);

INSERT INTO system_configs(config_key, config_value, description) VALUES
('switch.topic_submit', '1', '教师出题开关'),
('switch.selection', '1', '学生选题开关'),
('switch.selection_round1', '1', '第一轮选题开关'),
('switch.selection_round2', '0', '第二轮选题开关'),
('switch.upload_proposal', '1', '开题报告上传开关'),
('switch.upload_midterm', '1', '中期报告上传开关'),
('switch.upload_final', '1', '终稿上传开关')
ON DUPLICATE KEY UPDATE config_value=VALUES(config_value), description=VALUES(description);

CREATE TABLE IF NOT EXISTS file_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(200) NOT NULL,
    doc_type VARCHAR(50) DEFAULT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    original_filename VARCHAR(255) DEFAULT NULL,
    file_size BIGINT DEFAULT 0,
    uploader_id INT NOT NULL,
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
