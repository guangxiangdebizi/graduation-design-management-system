# 毕业设计管理系统

这是一个课程设计大作业项目，主题为“毕业设计管理系统”。项目使用 JSP、Servlet、MySQL 和 Maven 实现，覆盖管理员、教师、学生三类角色的毕业设计选题、公告、文档提交与审核等基础流程。

## 技术栈

- Java 8
- JSP / Servlet
- MySQL 8
- Maven
- Tomcat Maven Plugin
- Bootstrap 5

## 功能模块

- 登录与角色权限控制
- 管理员用户管理、公告管理
- 教师课题管理、选题审批、文档审核、学生进度查看
- 学生浏览课题、申请选题、查看选题状态、提交文档、查看成绩
- 仪表盘统计与系统公告展示

## 运行方式

1. 创建并初始化数据库：

```powershell
& "D:\MySQL\MySQL Server 8.0\bin\mysql.exe" --default-character-set=utf8mb4 -uroot -p12345 -e "source sql/init.sql"
```

如果 MySQL 安装路径或密码不同，请按本机环境修改命令，并同步调整 `src/dbutil/SQLHelper.java` 中的数据库连接配置。

2. 编译并启动项目：

```powershell
mvn package
mvn tomcat7:run-war
```

3. 浏览器访问：

```text
http://localhost:8086/graduation-design/
```

## 演示账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 教师 | teacher01 | 123456 |
| 学生 | student01 | 123456 |

## 说明

该项目为课程设计大作业演示版本，重点展示基于 JSP/Servlet 的 Web 管理系统基本开发流程和三角色业务闭环。
