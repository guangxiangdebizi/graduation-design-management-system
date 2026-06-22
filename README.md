# 毕业设计管理系统

基于 JSP + Servlet + MySQL 的毕业设计全流程管理系统，支持管理员、系主任、教师、学生角色。

## 技术栈

- Java 8 / JSP / Servlet 4.0
- MySQL 8 / JDBC（PreparedStatement）
- Maven WAR + Tomcat Maven Plugin
- Bootstrap 5 + ECharts 5 + Apache POI

## 功能模块

### 标准版（Phase 1）
- 登录与 Session 权限控制（AuthFilter 按角色路由，系主任继承教师权限）
- 管理员：用户管理、公告管理
- 系主任：继承教师全部功能，并额外管理本人绑定专业的课题审核、统计与导出
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
- 教师/学生 Excel 批量导入、多条件用户查询、学生密码批量重置
- 系统开放状态开关、课题审核、文件模板管理、个人中心

### AI 助手模块
- DeepSeek API 接入，配置从本地 `.env` 读取
- 管理员端 AI：协助用户管理、公告、答辩安排、统计、日志等问答
- 教师端 AI：协助课题维护、选题审批、文档评阅、学生进度等问答
- 系主任可使用教师端 AI，并保留独立账号会话上下文
- 学生端 AI：协助选题申请、阶段文档、进度规划、答辩准备等问答
- 权限隔离：后端按角色路径校验，`director` 允许访问教师端路径但不允许访问管理员端路径；AI 会话按 `role + userId` 绑定，同级用户之间不共享上下文

## 快速启动

详见 [DEPLOYMENT.md](DEPLOYMENT.md)

```powershell
# 1. 初始化数据库
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 -e "source sql/init.sql"

# 可选：追加完整演示数据
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 graduation_design -e "source sql/seed_demo_data_20260622.sql"

# 可选：追加展示增强数据，让系主任/统计/审核页面截图更丰富
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 graduation_design -e "source sql/seed_showcase_data_20260623.sql"

# 2. 编译启动
mvn package
mvn tomcat7:run-war
```

AI 配置在本地 `.env` 中维护，示例见 `.env.example`。`.env` 已加入 `.gitignore`，不要提交真实 API Key。

访问：http://localhost:8086/graduation-design/

## 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 系主任 | director_ai_cs | 123456 |
| 教师 | teacher01 | 123456 |
| 学生 | student01 | 123456 |

## Servlet 路由

| URL | 功能 |
|-----|------|
| `/login.action` | 登录 |
| `/logout.action` | 登出 |
| `/admin/user.action` | 用户 CRUD |
| `/admin/user-import.action` | 教师/学生 Excel 导入 |
| `/admin/topic-review.action` | 课题审核 |
| `/admin/system-switch.action` | 系统开放状态 |
| `/admin/file-template.action` | 文件模板管理 |
| `/admin/announcement.action` | 公告 CRUD |
| `/admin/defense.action` | 答辩安排 CRUD |
| `/admin/defense-import.action` | 答辩 Excel 批量导入 |
| `/admin/export.action` | 成绩 Excel 导出 |
| `/admin/stats.action` | 统计 JSON API |
| `/director/topic-review.action` | 本专业课题审核 |
| `/director/statistics.jsp` | 本专业项目统计 |
| `/director/stats.action` | 本专业统计 JSON API |
| `/director/export.action` | 本专业成绩 Excel 导出 |
| `/teacher/topic.action` | 课题 CRUD |
| `/teacher/selection.action` | 选题审批 |
| `/teacher/document.action` | 文档评阅 |
| `/student/topic.action` | 选题申请 |
| `/student/document.action` | 文档提交（multipart） |
| `/teacher/file-template.action` | 教师模板下载 |
| `/student/file-template.action` | 学生模板下载 |
| `/profile.action` | 个人中心与修改密码 |
| `/message.action` | 站内消息 |
| `/download.action` | 附件下载 |
| `/file-template-download.action` | 模板下载 |

## 文档

- [DEPLOYMENT.md](DEPLOYMENT.md) — 部署指南
- [业务逻辑与数据流文档.md](业务逻辑与数据流文档.md) — 架构与流程
- [答辩材料目录](docs/答辩材料/README.md) — 模块化前后端、数据库、架构、数据流和答辩文档
- [页面运行截图.md](页面运行截图.md) — 页面清单与验收流程
