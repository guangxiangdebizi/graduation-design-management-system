-- 最小化选题流程修正：
-- 不新增轮次表，保留现有 topics/status 和 switch.selection。
-- switch.selection 作为第一轮、第二轮选题窗口的人工开关。

INSERT INTO system_configs(config_key, config_value, description) VALUES
('switch.selection', '1', '学生选题开关，第一轮和第二轮复用')
ON DUPLICATE KEY UPDATE description=VALUES(description);
