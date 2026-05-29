# 毕业设计管理系统 — 部署指南

## 环境要求

- JDK 8+
- Maven 3.6+
- MySQL 8.x

## 1. 数据库初始化

```powershell
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 -e "source D:/Myproject/jspproject/毕业设计管理系统/sql/init.sql"
```

或使用 `sql/init-db.bat`。

## 2. 数据库配置（可选）

默认读取 `src/jdbc.properties`：

```properties
jdbc.url=jdbc:mysql://127.0.0.1:3306/graduation_design?...
jdbc.user=root
jdbc.password=12345
```

本地覆盖：复制为 `src/jdbc.local.properties` 并修改（已在 .gitignore 排除）。

## 3. 编译与启动

```powershell
cd D:\Myproject\jspproject\毕业设计管理系统
mvn package
mvn tomcat7:run-war
```

访问：http://localhost:8086/graduation-design/

## 4. WAR 部署

```powershell
mvn package
# 将 target/graduation-design.war 部署到 Tomcat webapps/
```

## 5. uploads 目录

学生上传文件保存在 Web 应用 `uploads/{studentId}/` 下。WAR 部署时建议：

- 将 uploads 目录配置为 Tomcat 外部可写路径，或
- 使用 `mvn tomcat7:run-war` 开发模式（自动可写）

## 6. 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 教师 | teacher01 | 123456 |
| 学生 | student01 | 123456 |

## 7. 验证清单

- [ ] 三角色登录
- [ ] 选题 → 审批 → 文档提交/上传 → 教师评阅
- [ ] 答辩安排 / Excel 导入 / 导出成绩
- [ ] 站内消息 / 操作日志 / ECharts 统计
