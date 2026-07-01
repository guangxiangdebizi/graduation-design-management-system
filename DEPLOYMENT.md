# 毕业设计管理系统 — 部署指南

## 环境要求

- JDK 8+
- Maven 3.6+
- MySQL 8.x

## 1. 数据库初始化

```powershell
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 -e "source D:/Myproject/jspproject/毕业设计管理系统/sql/init.sql"
```

如果需要更完整的演示数据，继续执行：

```powershell
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 graduation_design -e "source D:/Myproject/jspproject/毕业设计管理系统/sql/seed_demo_data_20260622.sql"
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 graduation_design -e "source D:/Myproject/jspproject/毕业设计管理系统/sql/seed_showcase_data_20260623.sql"
```

或直接使用 `sql/init-db.bat`，它会先初始化基础库，再自动追加完整演示数据和展示增强数据。

## 2. 数据库配置（可选）

默认读取 `src/jdbc.properties`：

```properties
jdbc.url=jdbc:mysql://127.0.0.1:3306/graduation_design?...
jdbc.user=root
jdbc.password=12345
```

本地覆盖：复制为 `src/jdbc.local.properties` 并修改（已在 .gitignore 排除）。

## 3. AI 配置

项目根目录创建 `.env`：

```properties
DEEPSEEK_API_KEY=你的 DeepSeek API Key
DEEPSEEK_API_URL=https://api.deepseek.com/chat/completions
DEEPSEEK_MODEL=deepseek-v4-pro
DEEPSEEK_TIMEOUT_MS=30000
DEEPSEEK_MAX_HISTORY_MESSAGES=12
```

说明：

- `.env` 已加入 `.gitignore`，真实 API Key 不提交。
- `DEEPSEEK_API_URL` 可以写完整接口地址，也可以写 `https://api.deepseek.com`，程序会补 `/chat/completions`。
- AI 后端接口分别为 `/admin/ai.action`、`/teacher/ai.action`、`/student/ai.action`。
- 权限隔离采用两层校验：`AuthFilter` 按角色路径拦截，`AiAssistantController` 再校验当前 Session 用户角色；系主任继承教师端 AI 访问能力，但会话历史仍按真实 `role + userId` 存在当前 Session 中。

## 4. 编译与启动

```powershell
cd D:\Myproject\jspproject\毕业设计管理系统
mvn package
mvn tomcat7:run-war
```

访问：http://localhost:8086/graduation-design/

## 5. WAR 部署

```powershell
mvn package
# 将 target/graduation-design.war 部署到 Tomcat webapps/
```

## 6. uploads 目录

学生上传文件保存在 Web 应用 `uploads/{studentId}/` 下。WAR 部署时建议：

- 将 uploads 目录配置为 Tomcat 外部可写路径，或
- 使用 `mvn tomcat7:run-war` 开发模式（自动可写）

## 7. 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 系主任 | director_ai_cs | 123456 |
| 教师 | teacher01 | 123456 |
| 学生 | student01 | 123456 |

## 8. 验证清单

- [ ] 管理员、系主任、教师、学生登录
- [ ] 选题 → 审批 → 文档提交/上传 → 教师评阅
- [ ] 答辩安排 / Excel 导入 / 导出成绩
- [ ] 站内消息 / 操作日志 / ECharts 统计
- [ ] AI 助手入口可见；系主任可访问教师 AI，但不能访问管理员/学生 AI；教师不能访问管理员/学生/系主任管理路径
- [ ] 系主任可访问 `/teacher/*` 教师功能和 `/director/*` 本专业管理功能，但不能访问 `/admin/*` 公告、系统开关、用户管理等管理员功能
