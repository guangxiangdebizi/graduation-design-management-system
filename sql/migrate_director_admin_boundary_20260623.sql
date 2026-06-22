USE graduation_design;

SET NAMES utf8mb4;

-- 用户确认：公告和系统开关属于管理员权限，系主任不再拥有发布公告或调整开关的权限。
-- 如上一次重构已创建专业级开关覆盖表，本次删除该表，系统开关恢复为管理员维护的全局配置。
DROP TABLE IF EXISTS system_switch_scopes;

-- 保留公告 scope 字段，供管理员面向全校/学院/专业发布；非管理员历史发布的公告回收为全局管理员公告。
UPDATE announcements a
JOIN users u ON a.publisher_id = u.id
SET a.publisher_id = (SELECT id FROM users WHERE role='admin' ORDER BY id LIMIT 1),
    a.scope_type = 'global',
    a.college = NULL,
    a.major = NULL
WHERE u.role <> 'admin';

SELECT
    (SELECT COUNT(*) FROM information_schema.TABLES
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME='system_switch_scopes') AS scoped_switch_table_exists,
    (SELECT COUNT(*) FROM announcements a JOIN users u ON a.publisher_id=u.id
     WHERE u.role <> 'admin') AS non_admin_announcements;
