-- 任务切片 A：文件模板管理 + 个人中心
-- 个人中心复用 users.email/users.phone/password 字段，无需新增用户字段。

USE graduation_design;

CREATE TABLE IF NOT EXISTS file_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(200) NOT NULL,
    doc_type VARCHAR(50) DEFAULT NULL,
    description TEXT,
    file_path VARCHAR(500) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_size BIGINT DEFAULT 0,
    uploader_id INT NOT NULL,
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_file_templates_doc_type (doc_type),
    INDEX idx_file_templates_status (status),
    INDEX idx_file_templates_created_at (created_at),
    CONSTRAINT fk_file_templates_uploader
      FOREIGN KEY (uploader_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
