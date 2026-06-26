USE graduation_design;

INSERT INTO system_configs(config_key, config_value, description) VALUES
('switch.manual_assign', '0', '强制分配阶段开关，管理员只控制开放状态，具体分配由系主任执行')
ON DUPLICATE KEY UPDATE description=VALUES(description);
