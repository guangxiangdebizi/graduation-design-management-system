# 毕业设计管理系统

基于 JSP + Servlet + MySQL 的毕业设计全流程管理系统，支持管理员、教师、学生三角色。

## 技术栈

- Java 8 / JSP / Servlet 4.0
- MySQL 8 / JDBC（PreparedStatement）
- Maven WAR + Tomcat Maven Plugin
- Bootstrap 5 + ECharts 5 + Apache POI

## 功能模块

### 标准版（Phase 1）
- 登录与 Session 权限控制（AuthFilter 三角色路由）
- 管理员：用户管理、公告管理
- 教师：课题 CRUD、选题审批、文档评阅、学生进度
- 学生：浏览/申请选题、文档提交、成绩查看
- 仪表盘统计

### 完整版（Phase 2）
- 答辩安排（管理员 CRUD，教师/学生查看）
- 站内消息（收发、已读/未读、角标）
- 操作日志审计
- ECharts 数据统计 + Excel 成绩导出
- 文件上传/下载

### 增强版（Phase 3）
- 选题名额校验、XSS 防护、CSRF Token
- BCrypt 密码（兼容 MD5 旧数据）
- 登录失败锁定、上传文件白名单校验
- JDBC 配置外置、404/500 错误页
- 答辩 Excel 批量导入、业务事件自动通知
- 文档版本历史、成绩四阶段汇总
- 列表分页、操作日志筛选、JUnit 测试

## 快速启动

详见 [DEPLOYMENT.md](DEPLOYMENT.md)

```powershell
# 1. 初始化数据库
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 -e "source sql/init.sql"

# 2. 编译启动
mvn package
mvn tomcat7:run-war
```

访问：http://localhost:8086/graduation-design/

## 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 教师 | teacher01 | 123456 |
| 学生 | student01 | 123456 |

## Servlet 路由（15 个）

| URL | 功能 |
|-----|------|
| `/login.action` | 登录 |
| `/logout.action` | 登出 |
| `/admin/user.action` | 用户 CRUD |
| `/admin/announcement.action` | 公告 CRUD |
| `/admin/defense.action` | 答辩安排 CRUD |
| `/admin/defense-import.action` | 答辩 Excel 批量导入 |
| `/admin/export.action` | 成绩 Excel 导出 |
| `/admin/stats.action` | 统计 JSON API |
| `/teacher/topic.action` | 课题 CRUD |
| `/teacher/selection.action` | 选题审批 |
| `/teacher/document.action` | 文档评阅 |
| `/student/topic.action` | 选题申请 |
| `/student/document.action` | 文档提交（multipart） |
| `/message.action` | 站内消息 |
| `/download.action` | 附件下载 |

## 文档

- [DEPLOYMENT.md](DEPLOYMENT.md) — 部署指南
- [业务逻辑与数据流文档.md](业务逻辑与数据流文档.md) — 架构与流程
- [页面运行截图.md](页面运行截图.md) — 页面清单与验收流程
