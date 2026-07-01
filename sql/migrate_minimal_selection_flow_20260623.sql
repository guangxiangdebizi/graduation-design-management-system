-- 最小化选题流程修正：
-- 不新增轮次表，保留现有 topics/status。
-- switch.selection 作为第一轮选题窗口开关，switch.selection_round2 作为第二轮选题窗口开关。

INSERT INTO system_configs(config_key, config_value, description) VALUES
('switch.selection', '1', '第一轮学生选题开关')
ON DUPLICATE KEY UPDATE description=VALUES(description);
