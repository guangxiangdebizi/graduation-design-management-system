# 01. 登录 / 退出 / 全局鉴权 / CSRF / 公共资源 / 角色权限 / 个人中心入口网络数据流详解

本节只说明基础访问控制链路：登录、退出、`AuthFilter` 全局鉴权、CSRF token 生成与校验、公共静态资源放行、角色路径权限、个人中心入口与个人资料修改。AI 模块不纳入本节。

## 1. 涉及 URL、方法与参数

| 场景 | URL / 匹配规则 | HTTP 方法 | 典型 Content-Type | 请求参数 / Cookie | 后端入口 | 结果 |
|---|---|---:|---|---|---|---|
| 访问系统根入口 | `/`、`/index.jsp` | GET | 无请求体 | `JSESSIONID` 可选 | `AuthFilter` -> `index.jsp` | 已登录跳 `dashboard.jsp`；未登录跳 `login.jsp` |
| 打开登录页 | `/login.jsp` | GET | 无请求体 | `error` 查询参数可选：`1`、`locked`、`empty` | `AuthFilter.isPublic` -> `login.jsp` | 渲染登录表单和错误提示 |
| 提交登录表单 | `/login.action` | POST | `application/x-www-form-urlencoded` | 表单体：`username=...&password=...` | `AuthFilter.isPublic` -> `LoginController.doPost` | 成功建立 session 并 302 到 `dashboard.jsp`；失败 302 回 `login.jsp?...` |
| GET 访问登录动作 | `/login.action` | GET | 无请求体 | 可带任意 query | `AuthFilter.isPublic` -> `LoginController.doGet` | 302 到 `login.jsp` |
| 访问仪表盘 | `/dashboard.jsp` | GET | 无请求体 | `JSESSIONID`；无显式业务参数 | `AuthFilter` -> `dashboard.jsp` | 按 `session.loginUser.role` 渲染 admin / director / teacher / student 视图 |
| 管理员目录 | `/admin/*` | 任意 | 由页面或控制器决定 | `JSESSIONID`；非安全 `.action` 还要 `_csrf` | `AuthFilter` 角色判断 | 只有 `admin` 可进入；其他角色 302 到 `dashboard.jsp` |
| 系主任目录 | `/director/*` | 任意 | 由页面或控制器决定 | `JSESSIONID`；非安全 `.action` 还要 `_csrf` | `AuthFilter` 角色判断 | 只有 `director` 可进入；其他角色 302 到 `dashboard.jsp` |
| 教师目录 | `/teacher/*` | 任意 | 由页面或控制器决定 | `JSESSIONID`；非安全 `.action` 还要 `_csrf` | `AuthFilter` + `RoleUtil.hasRole(user,"teacher")` | `teacher` 可进入；`director` 也继承教师目录；其他角色 302 到 `dashboard.jsp` |
| 学生目录 | `/student/*` | 任意 | 由页面或控制器决定 | `JSESSIONID`；非安全 `.action` 还要 `_csrf` | `AuthFilter` 角色判断 | 只有 `student` 可进入；其他角色 302 到 `dashboard.jsp` |
| 个人中心入口 | `/profile.action` | GET | 无请求体 | `JSESSIONID` | `AuthFilter` -> `ProfileController.doGet` -> forward `/profile.jsp` | 登录用户重新查库后渲染个人中心 |
| 直接访问个人中心 JSP | `/profile.jsp` | GET | 无请求体 | `JSESSIONID` | `AuthFilter` -> `profile.jsp` | 如果没有 `profileUser` request 属性，JSP 302 到 `ctx + /profile.action` |
| 修改个人资料 | `/profile.action` | POST | `application/x-www-form-urlencoded` | `_csrf`、`action=profile`、`email`、`phone` | `AuthFilter` CSRF -> `ProfileController.doPost` | 校验邮箱 / 电话，更新 DB，刷新 session，302 回 `profile.action?msg=profile_ok` |
| 修改密码 | `/profile.action` | POST | `application/x-www-form-urlencoded` | `_csrf`、`action=password`、`oldPassword`、`newPassword`、`confirmPassword` | `AuthFilter` CSRF -> `ProfileController.doPost` | 校验旧密码和新密码，更新 DB，302 回 `profile.action?msg=password_ok` 或错误码 |
| 退出登录 | `/logout.action` | GET | 无请求体 | `JSESSIONID` | `AuthFilter` -> `LogoutController.doGet` | 记录退出日志、`session.invalidate()`、302 到 `login.jsp` |
| 受保护业务提交 | 任意受保护 `*.action`，排除 `/login.action` | POST / PUT / DELETE 等非安全方法 | 常见为 `application/x-www-form-urlencoded` 或 `multipart/form-data` | `_csrf` 表单参数 / 查询参数，或 `X-CSRF-Token` 请求头 | `AuthFilter` 先校验，再进入具体 Controller | token 正确才放行；错误则回来源页带 `msg=csrf_error` 或返回 403 |
| 公共静态资源 | `/css/*`、`/js/*`、`/error/*` | 任意 | 由资源决定 | 无需登录 | `AuthFilter.isPublic` 放行 | 登录前也能加载样式和公共 JS |
| 上传文件直链 | `/uploads/*` | 任意 | 任意 | 任意 | `AuthFilter` | 直接返回 404，不进入资源或业务处理 |

### 关键 URL 与特殊符号约定

- `.action`：本项目用它表示“Servlet 控制器动作”地址，例如 `login.action` 映射到 `LoginController`，`profile.action` 映射到 `ProfileController`。`AuthFilter` 只对非安全方法且 `path.endsWith(".action")` 的受保护提交做 CSRF 校验。
- `?`：URL 中查询字符串的开始，例如 `login.jsp?error=empty`。`error=empty` 不在请求体里，而是 query parameter。
- `&`：多个查询参数的分隔符。`AuthFilter.appendMsg` 会根据 URL 中是否已有 `?` 自动选择 `?msg=csrf_error` 或 `&msg=csrf_error`。
- `_csrf`：服务端约定的 CSRF 参数名。普通 POST 表单由前端自动追加隐藏字段 `<input name="_csrf" ...>`；multipart 表单还会把 `_csrf` 追加到 action URL 的查询参数中。
- `_csrf_token`：服务端 session 内部保存名，不直接等同于浏览器字段名。`CsrfUtil.TOKEN_ATTR` 用它保存随机 token。
- `X-CSRF-Token`：服务端支持的另一种提交方式，适合脚本请求把 token 放在请求头里。
- `ctx`：`request.getContextPath()`，即应用部署上下文。例如部署在 `/gdms` 时，`ctx=/gdms`。
- `path`：`AuthFilter` 用 `uri.substring(ctx.length())` 去掉部署上下文后的应用内路径。例如请求 URI `/gdms/director/topic-review.action` 会变成 `/director/topic-review.action`，这样权限判断不受部署名影响。
- `/`：应用内根路径，是 public path，会进入 `index.jsp` 再按 session 状态跳转。
- `/admin/`、`/director/`、`/teacher/`、`/student/`：角色目录前缀。注意它们只按路径前缀判断，不等同于页面侧菜单是否显示。
- `/profile.action`：没有角色目录前缀，因此不是 admin / teacher / student 的专属路径；任意已登录角色都能访问。
- `../`：浏览器解析相对 URL 时的“上一级目录”符号。后端权限判断最终看 Servlet 容器解析后的请求 URI / path，而不是页面源码里的相对写法；因此权限边界应以 `AuthFilter` 计算出的 `path` 为准。
- `302 redirect`：`response.sendRedirect(...)` 产生的客户端重定向。浏览器会收到 302，再发起第二次 GET 到新地址。
- `forward`：服务端内部转发。`ProfileController.doGet` 用 `request.getRequestDispatcher("/profile.jsp").forward(...)` 把同一个 request 交给 JSP，因此 `profile.jsp` 能读取 `request.getAttribute("profileUser")`。
- `403`：CSRF token 无效且不能安全回来源页时，服务端返回 Forbidden；系主任缺少管理范围时部分页面 / 控制器也会返回 403。
- `404`：`/uploads/*` 被过滤器主动隐藏为 Not Found，避免通过静态直链绕过业务下载控制。
- GET / HEAD / OPTIONS 安全方法：在本项目中被 `isSafeMethod` 视为“不直接改变业务状态”的方法，不做 CSRF 校验，但会生成 session token 供后续 POST 使用。

## 2. 总链路 flowchart

```mermaid
flowchart TD
  B["浏览器\nGET / 或 /index.jsp"] --> AF1["AuthFilter.java:24-50\nUTF-8 + 安全响应头; 计算 ctx/path; /uploads 404; public path 放行"]
  AF1 --> IDX["index.jsp:3-8\n检查 session.loginUser"]
  IDX -->|未登录| LP["login.jsp:13-21,32-45\n读取 error; 渲染 username/password 表单"]
  IDX -->|已登录| AF2["AuthFilter.java:52-68\n读取 session.loginUser; UserDao.findById 实时复查; 覆盖 session 当前用户"]
  LP -->|POST /login.action| AF_LOGIN["AuthFilter.java:107-113\n/login.jsp 与 /login.action 属于 public"]
  AF_LOGIN --> LC["LoginController.java:20-54\n读取 username/password; 登录失败计数; UserDao.validate; 成功写 session"]
  LC -->|302 /dashboard.jsp| AF2
  AF2 --> ROLE["AuthFilter.java:69-84\n/admin /director /teacher /student 目录角色判断"]
  ROLE --> DASH["dashboard.jsp:4-13,176-227\n按 admin/director/teacher/student 渲染不同首页"]
  DASH --> HDR["header.jsp:7-12\ninclude csrf-meta.jsp"]
  HDR --> META["csrf-meta.jsp:4-8\n登录用户输出 meta csrf-token"]
  META --> JS["app.js:51-72,415-417\nDOMContentLoaded 后给 POST 表单注入 _csrf"]
  DASH --> SIDE["sidebar.jsp:18-60,73-75\n仪表盘、角色菜单、个人中心、退出入口"]
  SIDE -->|GET /profile.action| PROFCTL["ProfileController.java:17-29\n重新查当前用户; forward /profile.jsp"]
  SIDE -->|GET /logout.action| LO["LogoutController.java:18-27\n记录日志; invalidate session; 302 login.jsp"]
  JS -->|POST /profile.action 或其他受保护 .action| AF_CSRF["AuthFilter.java:86-102\n安全方法生成 token; 非安全 .action 校验 _csrf / X-CSRF-Token"]
```

这条总链路里有三个核心状态：

1. **登录态**：服务端 session 中是否存在 `loginUser`。没有它，受保护 URL 会被 `AuthFilter` 302 到登录页。
2. **实时账号态**：即使 session 里有 `loginUser`，过滤器仍会用 `UserDao.findById` 重新查库，确认账号仍存在、启用且角色没有变化。
3. **CSRF 态**：session 中是否存在 `_csrf_token`，且本次非安全 `.action` 请求是否提交了相同值。没有或不一致，业务 Controller 不会执行。

## 3. 登录请求生命周期：从浏览器表单到 `request.getParameter`

### 3.1 登录页如何产生请求

`login.jsp` 中登录表单的关键点是：

- `request.getParameter("error")` 只读取 query 参数，目前显式映射 `1`、`locked`、`empty` 三种提示。
- `<form action="login.action" method="post">`：提交到当前应用上下文下的 `/login.action`。
- `<input type="text" name="username">`：用户名字段名是 `username`。
- `<input type="password" name="password">`：密码字段名是 `password`，`id="password"` 只给前端显示 / 隐藏密码按钮使用。
- 登录页没有 include `csrf-meta.jsp`，因为 `/login.action` 是 public path，并且 CSRF 规则也明确排除 `/login.action`。

用户点击“登录”后，浏览器默认编码为 `application/x-www-form-urlencoded`，请求体类似：

```text
username=admin&password=admin123
```

这里的 `&` 只是参数分隔符，不是密码的一部分；如果用户名或密码含特殊字符，浏览器会 URL encode 后再发送。后端调用 `request.getParameter("username")` 和 `request.getParameter("password")` 时，Servlet 容器会从 POST 表单体解析出对应参数。

### 3.2 登录 sequence

```mermaid
sequenceDiagram
  participant Browser as 浏览器
  participant Filter as AuthFilter.java:24-50,107-118
  participant LoginJsp as login.jsp:13-21,32-45
  participant LoginCtl as LoginController.java:20-54
  participant UserDao as UserDao.java:20-27,140-146
  participant SQL as SQLHelper.java:52-77
  participant Session as HttpSession

  Browser->>Filter: GET /login.jsp
  Filter->>LoginJsp: isPublic(/login.jsp) 放行
  LoginJsp-->>Browser: HTML 表单: username/password
  Browser->>Filter: POST /login.action<br/>Content-Type: application/x-www-form-urlencoded<br/>username=...&password=...
  Filter->>LoginCtl: isPublic(/login.action) 放行
  LoginCtl->>LoginCtl: setCharacterEncoding("UTF-8")<br/>getParameter("username"/"password")
  alt 用户名或密码为空
    LoginCtl-->>Browser: 302 ctx + /login.jsp?error=empty
  else session 内该用户名被锁
    LoginCtl-->>Browser: 302 ctx + /login.jsp?error=locked
  else 进入数据库校验
    LoginCtl->>UserDao: validate(username,password)
    UserDao->>SQL: SELECT users WHERE username=?
    SQL-->>UserDao: User 行数据
    UserDao-->>LoginCtl: status=1 且密码匹配
    LoginCtl->>Session: setAttribute("loginUser", user)<br/>setAttribute("loginTime", ...)
    LoginCtl-->>Browser: 302 ctx + /dashboard.jsp
  end
```

### 3.3 后端逐段解释

1. `LoginController` 的 Servlet 映射是 `/login.action`，所以登录页表单 POST 命中这个控制器。
2. 控制器先 `request.setCharacterEncoding("UTF-8")`，保证表单体中的中文用户名等内容按 UTF-8 解析。
3. `request.getParameter("username")` 和 `request.getParameter("password")` 读取的是登录页两个 input 的 `name` 字段，不是 label 文本，也不是 `id`。
4. 用户名或密码为空时，不进入数据库验证，直接 `WebUtil.redirect(request,response,"/login.jsp?error=empty")`。`WebUtil` 会给以 `/` 开头的 path 自动拼接 `ctx`。
5. 控制器在登录阶段调用 `request.getSession(true)`。这是合理的，因为失败次数、锁定状态、成功后的登录态都需要 session 承载。
6. `LoginAttemptUtil.isLocked(session, username)` 使用当前 session 判断该用户名是否被锁；锁定时 302 到 `login.jsp?error=locked`。
7. `UserDao.validate` 先按 username 查数据库用户，再要求 `status=1`，最后用密码工具匹配提交密码和库内密码摘要。
8. 认证成功后，控制器再次取完整 `User`，把 `password` 置空，然后放入 `session.setAttribute("loginUser", user)`。这样后续请求不必每次重新输入密码，只要浏览器带同一个 `JSESSIONID` Cookie，服务端就能从 session 找到登录用户。
9. 登录成功还写入 `loginTime`，清理失败计数，记录登录日志，然后 302 到 `/dashboard.jsp`。
10. 认证失败时记录失败次数，302 到 `/login.jsp?error=1`；登录页根据 query 参数显示“用户名或密码错误”。

### 3.4 为什么登录成功要放 session

HTTP 请求本身是无状态的。登录 POST 只发生一次；如果不把认证结果保存到 session，下一次访问 `dashboard.jsp` 时服务端无法知道这是刚登录过的浏览器。把去密码后的 `User` 放进 session 有三个作用：

- 后续鉴权统一读取 `session.loginUser`，不用每个 JSP / Controller 自己重新校验用户名密码。
- 页面可以从 `loginUser.role` 判断展示 admin、director、teacher、student 哪一套功能。
- 配合服务端 session 生命周期，退出时一次 `invalidate()` 就能清理登录态和 CSRF token。

## 4. 访问控制生命周期：`AuthFilter` 如何根据 path / role 放行或重定向

`AuthFilter` 标注 `@WebFilter("/*")`，说明它拦截应用内所有请求。它的处理顺序非常重要：

1. **统一编码和安全响应头**：先设置请求 / 响应 UTF-8，再给所有响应加安全头。
2. **计算路径**：取 `request.getRequestURI()` 和 `request.getContextPath()`，再截出应用内 `path`。
3. **隐藏上传直链**：如果 `path.startsWith("/uploads/")`，立即 404。
4. **公共路径放行**：根入口、登录页、登录动作、CSS、JS、错误页无需 session。
5. **登录态检查**：非 public path 必须有 `session.loginUser`；没有则 302 到 `ctx + "/login.jsp"`。
6. **账号实时复查**：根据 session 用户 id 重新查数据库。账号被删除、停用或角色变化时，清空 session 并 302 到 `login.jsp?error=account_changed`。当前 `login.jsp` 没有专门映射 `account_changed` 文案，所以跳转会发生，但页面不会像 `empty` / `locked` 那样显示定制提示。
7. **角色路径控制**：
   - `/admin/*` 只能 `admin` 访问。
   - `/director/*` 只能 `director` 访问。
   - `/teacher/*` 由 `RoleUtil.hasRole(user,"teacher")` 判断；`teacher` 本身可访问，`director` 也被视为拥有教师权限。
   - `/student/*` 只能 `student` 访问。
   - 角色不匹配不返回 403，而是 302 到 `dashboard.jsp`，让用户回到自己角色可访问的首页。
8. **公共登录后页面**：`/dashboard.jsp`、`/profile.action`、`/profile.jsp`、`/logout.action` 不属于 public，但也没有角色目录前缀；只要已登录且账号复查通过，各角色都能进入。
9. **安全方法生成 token**：GET / HEAD / OPTIONS 请求会确保 session 中已有 CSRF token。
10. **非安全 `.action` 校验 CSRF**：受保护 POST 等动作必须提交 token，验证通过才 `chain.doFilter` 进入后续 Servlet / JSP。

### 4.1 鉴权 / 角色 flowchart

```mermaid
flowchart TD
  R["请求进入\nAuthFilter.java:24-29"] --> H["AuthFilter.java:31-36\n写安全响应头"]
  H --> P["AuthFilter.java:38-40\nuri + ctx => path"]
  P --> U{"AuthFilter.java:42-45\npath startsWith /uploads/ ?"}
  U -->|是| N404["返回 404\nsendError(SC_NOT_FOUND)"]
  U -->|否| PUB{"AuthFilter.java:47-50,107-118\nisPublic(path) ?"}
  PUB -->|是| CHAIN1["chain.doFilter\n允许 / /index.jsp /login.jsp /login.action /css /js /error"]
  PUB -->|否| S{"AuthFilter.java:52-57\nsession.loginUser 存在 ?"}
  S -->|否| LOGIN302["302 redirect\nctx + /login.jsp"]
  S -->|是| DB{"AuthFilter.java:59-68\nUserDao.findById; status=1; role 未变化 ?"}
  DB -->|否| CHANGED["session.invalidate();\n302 ctx + /login.jsp?error=account_changed"]
  DB -->|是| ADMIN{"AuthFilter.java:69-72\n/admin/* 且非 admin ?"}
  ADMIN -->|是| DASH302["302 ctx + /dashboard.jsp"]
  ADMIN -->|否| DIRECTOR{"AuthFilter.java:73-76\n/director/* 且非 director ?"}
  DIRECTOR -->|是| DASH302
  DIRECTOR -->|否| TEACHER{"AuthFilter.java:77-80\n/teacher/* 且 RoleUtil 不认可 teacher ?"}
  TEACHER -->|是| DASH302
  TEACHER -->|否| STUDENT{"AuthFilter.java:81-84\n/student/* 且非 student ?"}
  STUDENT -->|是| DASH302
  STUDENT -->|否| SAFE{"AuthFilter.java:86-88\nGET/HEAD/OPTIONS ?"}
  SAFE -->|是| TOKEN["CsrfUtil.java:11-20\n生成或复用 session _csrf_token"]
  SAFE -->|否| CSRF{"AuthFilter.java:90-102\n非安全 .action 且 token 有效 ?"}
  TOKEN --> CHAIN2["chain.doFilter\n进入 JSP/Controller"]
  CSRF -->|是| CHAIN2
  CSRF -->|否| FAIL["redirect Referer + msg=csrf_error\n或 403 CSRF token invalid"]
```

### 4.2 为什么要用统一 `AuthFilter`

如果每个 JSP 或 Controller 自己写登录检查，容易漏掉某个 URL，形成未授权访问。统一过滤器的好处是：

- 所有请求先过同一个入口，鉴权策略集中。
- 公共资源、登录页、角色路径、CSRF 校验顺序固定，减少重复代码。
- 安全响应头可在所有响应上一致生效，包括登录页和静态资源。
- 账号状态变化能在下一次请求立即生效：管理员停用某个用户或修改角色后，该用户 session 会被过滤器复查并失效。
- `/profile.action` 这类跨角色公共登录功能不用在多个角色目录下复制一份。

### 4.3 public path 为什么要放行

登录页和登录动作必须允许未登录访问，否则用户永远无法提交登录。CSS / JS 也必须放行，否则登录页虽然能打开，但样式、密码显示按钮、全局消息等前端功能加载失败。当前 public path 包括：

```text
/
/index.jsp
/login.jsp
/login.action
/css/*
/js/*
/error/*
```

注意：`/uploads/*` 虽然可能是静态文件路径，但过滤器在 public 判断之前先返回 404，因此它不是公共资源。

### 4.4 `index.jsp`、`dashboard.jsp` 与角色首页分工

`index.jsp` 不是业务主页，它只做入口跳转：

- session 中已有 `loginUser`：302 到 `dashboard.jsp`。
- 没有 `loginUser`：302 到 `login.jsp`。

`dashboard.jsp` 是登录后的角色首页。它直接从 `session.getAttribute("loginUser")` 取用户并读取 `role`。这依赖 `AuthFilter` 已经保证未登录请求不能进入该 JSP；否则 `loginUser.getRole()` 会空指针。

当前首页分支是：

- `admin` 与 `director` 进入同一个大分支。`director` 会先计算 `ScopeUtil.directorScope(loginUser)`；如果没有学院 / 专业管理范围，直接 `sendError(403,"director scope missing")`。
- `director` 首页统计教师、学生、课题、已选题人数时会限定在本学院 / 本专业，并显示“教师身份工作台”和“本专业管理功能”。
- `admin` 首页显示全局统计和完整管理入口。
- `teacher` 首页显示本人课题、待给建议选题、待审文档和可见公告。
- 其余分支按学生逻辑渲染选题、文档、公告、答辩安排。数据库角色应由用户管理保证在系统角色集合内。

### 4.5 当前角色路径设计原因

`director` 同时出现在 `/director/*` 和 `/teacher/*` 两类路径中，这是当前代码的关键变化：

- `/director/*` 表示“系主任本专业管理”能力，只允许 `director`。
- `/teacher/*` 表示“指导教师工作”能力，`RoleUtil` 明确允许 `director` 在需要 `teacher` 时通过。这样系主任既能审核本专业课题 / 选题，也能保留自己作为指导教师的课题、选题建议、文档审核等功能。
- `/admin/*` 仍然只给 `admin`，没有让 `director` 继承全局管理员权限。
- `/profile.action` 和 `/dashboard.jsp` 不绑定具体角色，因为它们是所有登录用户的共同入口。

## 5. 个人中心入口与资料修改流程

个人中心入口由公共布局提供，不在某个角色目录里：

- 左侧菜单固定输出 `<a href="ctx/profile.action">个人中心</a>`。
- 顶部用户信息区域也输出 `<a href="ctx/profile.action">个人中心</a>`。
- `profile.jsp` 本身要求 request 中已经有 `profileUser`；如果用户直接 GET `/profile.jsp`，JSP 会 302 到 `/profile.action`，让控制器重新查库并 forward。

### 5.1 profile 流程图

```mermaid
flowchart TD
  A["任意已登录角色\n点击 sidebar/topbar 个人中心"] --> B["GET /profile.action"]
  B --> AF["AuthFilter.java:52-88\n必须已登录; 查库复查账号; GET 生成 CSRF token"]
  AF --> PCGET["ProfileController.java:17-29\nUserDao.findById(loginUser.id); password 置空; setAttribute(profileUser); forward /profile.jsp"]
  PCGET --> JSP["profile.jsp:4-22\n读取 profileUser 与 msg; include header"]
  JSP --> META["header.jsp:12 + csrf-meta.jsp:4-8\n输出 meta[name=csrf-token]"]
  META --> JS["app.js:51-72,415-417\n给两个 POST 表单追加 _csrf"]
  JSP --> FORM1["profile.jsp:54-67\nPOST action=profile email phone"]
  JSP --> FORM2["profile.jsp:72-89\nPOST action=password old/new/confirm"]
  FORM1 --> AFPOST["AuthFilter.java:90-102\n/profile.action 是受保护 .action; POST 必须校验 CSRF"]
  FORM2 --> AFPOST
  AFPOST --> PCPOST["ProfileController.java:31-43\n按 action 分派"]
  PCPOST --> UP1["ProfileController.java:45-70\n校验 email/phone; updateProfile; 刷新 session; 302 msg=profile_ok"]
  PCPOST --> UP2["ProfileController.java:72-96\n校验旧密码/新密码/确认密码; updatePassword; 302 msg=password_ok"]
```

### 5.2 `ProfileController` 逐段解释

1. `@WebServlet("/profile.action")` 把个人中心控制器挂在应用根路径下，各角色共享。
2. GET 请求读取 `session.loginUser`，再用 `UserDao.findById(loginUser.getId())` 重新查当前账号。这样页面展示的是数据库最新资料，而不是旧 session 快照。
3. 如果查不到用户，说明账号状态异常，控制器主动 `session.invalidate()` 并跳到 `login.jsp?error=account_changed`。
4. 查到用户后，`profileUser.setPassword(null)`，再通过 request attribute 传给 JSP。这里使用 forward，不是 redirect，因此 JSP 能直接读取 `profileUser`。
5. POST 请求先设置 UTF-8，再读取隐藏字段 `action`。`action=profile` 走资料修改；`action=password` 走密码修改；其他值返回 `/profile.action`。
6. 资料修改只允许改 `email` 和 `phone`，并用 `ValidationUtil` 做格式校验；成功后重新 `findById`，置空密码并刷新 `session.loginUser`。
7. 密码修改先用 `UserDao.validatePassword` 校验旧密码，再检查新密码规则和两次输入是否一致，最后 `UserDao.updatePassword` 写入密码摘要。
8. 成功和失败都用 redirect 回 `/profile.action?...`，避免刷新页面重复提交表单。

### 5.3 为什么 `profile.jsp` 不直接查库

`profile.jsp` 当前只负责展示和提交表单；真正的数据读取、账号异常处理、密码字段清理由 `ProfileController` 完成。这样设计有三个原因：

- 控制器能集中处理“账号被删除或异常”的分支。
- JSP 只消费 `profileUser`，减少页面内数据库访问逻辑。
- 使用 forward 时，`profile.jsp` 可以区分“来自控制器的正常渲染”和“用户直接访问 JSP”。直接访问时没有 `profileUser`，页面会重定向回 `/profile.action` 补齐控制器流程。

## 6. CSRF 生命周期：GET 生成 token，POST 校验 token

### 6.1 token 在哪里生成

CSRF token 保存在 session 属性 `_csrf_token` 中。`CsrfUtil.getToken(session)` 的逻辑是：

1. session 为空则返回 `null`。
2. session 中已有 `_csrf_token` 就复用。
3. 没有则用 `UUID.randomUUID().toString().replace("-", "")` 生成一个无横杠随机字符串。
4. 写回 session。

`AuthFilter` 在 GET / HEAD / OPTIONS 这类安全方法上调用 `CsrfUtil.getToken(session)`，目的是让用户打开页面时就准备好后续 POST 需要的 token。之后公共 header include 的 `csrf-meta.jsp` 也会在登录用户存在时输出：

```html
<meta name="csrf-token" content="...">
```

前端 `app.js` 在 `DOMContentLoaded` 后读取这个 meta，并给所有 POST 表单补一个隐藏字段：

```html
<input type="hidden" name="_csrf" value="...">
```

对于 `multipart/form-data` 文件上传表单，脚本还会把 `_csrf` 同步追加到 action URL 的查询参数里。这是为了让过滤器阶段的 `request.getParameter("_csrf")` 更稳定地拿到 token；某些 multipart 请求在进入业务上传解析前，不适合依赖普通表单字段完成安全校验。

### 6.2 token 在哪里校验

`AuthFilter` 的 CSRF 条件是：

```text
非 GET/HEAD/OPTIONS
并且 path 以 .action 结尾
并且 path 不是 /login.action
```

满足这些条件时，过滤器调用 `CsrfUtil.validate(request)`。校验顺序：

1. 取现有 session；没有 session，失败。
2. 从 session 取 `_csrf_token`；没有或为空，失败。
3. 先读请求参数 `_csrf`。
4. 参数没有时，再读请求头 `X-CSRF-Token`。
5. 提交值与 session 中的 expected 完全相等才通过。

### 6.3 CSRF flowchart

```mermaid
flowchart TD
  G["GET /dashboard.jsp 或 /profile.action\nAuthFilter.java:86-88"] --> T1["CsrfUtil.java:11-20\nsession._csrf_token 不存在则生成"]
  T1 --> H["header.jsp:12\ninclude csrf-meta.jsp"]
  H --> M["csrf-meta.jsp:4-8\n登录用户输出 meta[name=csrf-token]"]
  M --> J["app.js:51-72\n扫描 POST form; 追加 hidden _csrf; multipart action 追加 query _csrf"]
  J --> READY["app.js:415-417\nDOMContentLoaded 调用 injectCsrfToken"]
  READY --> P["浏览器 POST /profile.action 或 /xxx.action\n参数 _csrf=token 或请求头 X-CSRF-Token"]
  P --> F{"AuthFilter.java:90-91\n非安全方法 + .action + 非 /login.action ?"}
  F -->|否| PASS0["不做 CSRF 校验\n继续后续链路"]
  F -->|是| V["CsrfUtil.java:23-36\n取 session token; 对比 _csrf 或 X-CSRF-Token"]
  V -->|一致| PASS["AuthFilter.java:104\nchain.doFilter 放行业务 Controller"]
  V -->|不一致| REF{"AuthFilter.java:93-99\nReferer 是否同应用前缀 ?"}
  REF -->|是| R302["302 到 Referer + msg=csrf_error\napp.js:78-84,114 显示安全验证失败"]
  REF -->|否| R403["403 Forbidden\nCSRF token invalid"]
```

### 6.4 为什么 POST 要校验 CSRF

浏览器会自动携带同站点 session Cookie。如果用户已登录，攻击页面可能诱导浏览器向本系统发起 POST；没有 CSRF token 时，服务端只看到合法 Cookie，无法区分这是用户主动提交还是跨站伪造。把随机 token 存在 session，并要求页面表单或请求头提交同一个 token，可以证明请求来自本系统页面渲染出的上下文。

### 6.5 为什么 GET 生成 token 而不是 POST 时才生成

POST 到达过滤器时，业务操作已经准备执行，必须“校验已有 token”，不能临时生成一个再通过。GET 页面是用户正常进入表单的阶段，此时生成 token 并渲染到 meta，后续 POST 才有可提交的凭证。

### 6.6 当前退出接口的特殊点

`/logout.action` 使用 GET。按当前过滤器规则，GET 属于安全方法，不触发 CSRF 校验；但 `/logout.action` 不是 public path，所以仍要求已登录。请求到达 `LogoutController` 后：

1. `request.getSession(false)` 获取现有 session，不创建新 session。
2. 如果 session 里有 `loginUser`，记录退出日志。
3. `session.invalidate()` 清除登录态和 CSRF token。
4. 302 到 `/login.jsp`。

这解释了为什么退出后再访问 `dashboard.jsp` 会被过滤器重定向回登录页：原 session 已失效，新的请求找不到 `loginUser`。

## 7. 安全响应头、公共资源与数据库连接

`AuthFilter` 在判断 public path 之前就写安全响应头，因此登录页、CSS、JS、业务页、Controller 响应都会带这些头：

| Header | 当前值 / 作用 |
|---|---|
| `X-Content-Type-Options` | `nosniff`，要求浏览器不要把响应猜成其他 MIME 类型 |
| `X-Frame-Options` | `SAMEORIGIN`，限制页面只能被同源页面嵌入 frame |
| `X-XSS-Protection` | `1; mode=block`，兼容旧浏览器的 XSS 过滤开关 |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains`，声明 HTTPS 访问策略；只有 HTTPS 下浏览器才会实际采纳 |
| `Content-Security-Policy` | 限制默认资源同源，允许 jsdelivr CDN、内联脚本 / 样式、`unsafe-eval`、data 图片等项目当前需要的资源 |

登录页自己引用 `css/app.css` 和 `js/app.js`。这两个路径在 `/css/`、`/js/` public 规则内，所以未登录时也能加载。页面还引用 jsdelivr 的 Bootstrap CSS / JS，这类请求直接发往 CDN 域名，不经过本应用的 `AuthFilter`。

数据库访问链路集中在 `UserDao` 与 `SQLHelper`：

- `UserDao.findByUsername`、`findById`、`validate`、`validatePassword`、`updateProfile`、`updatePassword` 都通过 `SQLHelper` 执行参数化 SQL。
- `SQLHelper` 静态初始化时从 classpath 读取 `jdbc.properties`，用 Druid 创建连接池。
- `queryList`、`queryScalar`、`executeUpdate`、`executeInsert` 都先 `prepareStatement`，再 `bindParams`，最后关闭 `ResultSet` / `PreparedStatement` / `Connection`。
- `jdbc.properties` 当前连接本机 MySQL `graduation_design` 库，设置 UTF-8、Asia/Shanghai、Druid 初始连接数、最大连接数、校验 SQL 和 stat filter。

## 8. redirect / forward 目的地汇总

| 触发条件 | 代码行为 | 浏览器下一跳 / 服务端结果 |
|---|---|---|
| `index.jsp` 发现已登录 | `response.sendRedirect("dashboard.jsp")` | GET `/dashboard.jsp` |
| `index.jsp` 发现未登录 | `response.sendRedirect("login.jsp")` | GET `/login.jsp` |
| GET `/login.action` | `WebUtil.redirect(..., "/login.jsp")` | GET `ctx + /login.jsp` |
| 登录参数为空 | `WebUtil.redirect(..., "/login.jsp?error=empty")` | GET `ctx + /login.jsp?error=empty` |
| 登录账号被锁 | `WebUtil.redirect(..., "/login.jsp?error=locked")` | GET `ctx + /login.jsp?error=locked` |
| 登录成功 | `WebUtil.redirect(..., "/dashboard.jsp")` | GET `ctx + /dashboard.jsp` |
| 登录失败 | `WebUtil.redirect(..., "/login.jsp?error=1")` | GET `ctx + /login.jsp?error=1` |
| 未登录访问受保护路径 | `response.sendRedirect(ctx + "/login.jsp")` | GET `ctx + /login.jsp` |
| session 用户被删除 / 停用 / 角色变化 | `session.invalidate(); response.sendRedirect(ctx + "/login.jsp?error=account_changed")` | GET 登录页并带错误码；当前登录页无专门文案 |
| 角色访问错目录 | `response.sendRedirect(ctx + "/dashboard.jsp")` | 回自己的仪表盘 |
| 直接 GET `/profile.jsp` 且无 `profileUser` | `response.sendRedirect(request.getContextPath() + "/profile.action")` | GET `ctx + /profile.action` |
| GET `/profile.action` 查不到当前用户 | `session.invalidate(); WebUtil.redirect(..., "/login.jsp?error=account_changed")` | GET 登录页并带错误码 |
| GET `/profile.action` 查到当前用户 | `request.getRequestDispatcher("/profile.jsp").forward(...)` | 服务端内部 forward 到 `/profile.jsp` |
| 修改资料成功 | `WebUtil.redirect(..., "/profile.action?msg=profile_ok")` | GET `ctx + /profile.action?msg=profile_ok` |
| 修改密码成功 | `WebUtil.redirect(..., "/profile.action?msg=password_ok")` | GET `ctx + /profile.action?msg=password_ok` |
| 个人中心 POST 校验失败 | 多个 `WebUtil.redirect(..., "/profile.action?msg=...")` | GET `ctx + /profile.action?msg=email_invalid` 等 |
| CSRF 失败且 Referer 是本应用 | `response.sendRedirect(appendMsg(referer,"csrf_error"))` | 回来源页，query 增加 `msg=csrf_error` |
| CSRF 失败且 Referer 不可信 | `sendError(403,"CSRF token invalid")` | 停止请求，显示 403 |
| 访问 `/uploads/*` | `sendError(404)` | 停止请求，显示 404 |
| 退出登录 | `session.invalidate(); WebUtil.redirect(..., "/login.jsp")` | GET `ctx + /login.jsp` |

## 9. 关键代码逐段解释

### 9.1 `login.jsp`

- `request.getParameter("error")` 读取 URL query 中的错误码，决定显示哪条登录失败提示；当前只处理 `1`、`locked`、`empty`。
- `<form action="login.action" method="post">` 决定浏览器向 `/login.action` 发 POST。
- `name="username"` / `name="password"` 决定后端 `getParameter` 的参数名。`id="password"` 只服务于前端“显示 / 隐藏密码”按钮，不参与后端取值。
- 登录页没有 include `csrf-meta.jsp`；这是符合当前后端规则的，因为 `/login.action` 是 public 并被 CSRF 校验排除。
- 登录页仍加载 `js/app.js`，用于 `togglePassword`、toast 等公共交互；由于没有 `meta[name="csrf-token"]`，`injectCsrfToken()` 会直接 return。

### 9.2 `LoginController`

- `@WebServlet("/login.action")` 把 `.action` URL 绑定到这个 Servlet。
- `setCharacterEncoding` 必须在 `getParameter` 之前调用，否则 POST 体里的非 ASCII 字符可能已经按错误编码解析。
- 空值检查在数据库访问前完成，避免无效请求消耗数据库连接。
- `request.getSession(true)` 在登录流程中合理：即使之前没有 session，登录成功也需要创建一个来保存状态；失败次数 / 锁定状态也依赖 session。
- `LoginAttemptUtil.isLocked` 在数据库校验前执行；锁定时直接返回 `error=locked`。
- `user.setPassword(null)` 是重要的安全处理，避免把密码摘要或密码字段放进登录成功时的 session。
- `session.setAttribute("loginUser", user)` 是整个后续鉴权链路的依据。
- 所有结果都用 redirect，不用 forward。这样登录成功或失败后的地址栏会变成目标页，刷新页面不会重复提交登录表单。

### 9.3 `AuthFilter`

- 安全响应头放在最前面，保证即使后面 public 放行、redirect 或错误响应也尽量带上统一安全策略。
- `path` 是去掉 `ctx` 的路径，用它做权限判断可以兼容不同部署上下文。
- `/uploads/` 先于 public 判断返回 404，说明上传文件不允许被当成普通静态目录直接访问。
- `isPublic` 只放行登录必需资源和错误页，不包含 dashboard、profile、logout、admin、director、teacher、student。
- session 中有 `loginUser` 还不够，过滤器会再查一次数据库确认账号仍存在、启用且角色未变化。
- 角色目录判断使用路径前缀：`/admin/`、`/director/`、`/teacher/`、`/student/`。不匹配时重定向到 dashboard，而不是让用户留在无权限 URL。
- `/teacher/` 路径使用 `RoleUtil.hasRole(user,"teacher")`，因此 `director` 继承教师功能；这与 dashboard / sidebar 中给 director 同时显示 teacher 工作台和 director 管理入口一致。
- CSRF 校验只发生在受保护的非安全 `.action` 请求上；普通 GET 页面不会被拦截，但会生成 token。

### 9.4 `CsrfUtil`、`csrf-meta.jsp`、`app.js`

- `CsrfUtil.TOKEN_ATTR="_csrf_token"` 是 session 内部保存名；`PARAM_NAME="_csrf"` 是浏览器提交名。
- `getToken` 是懒生成：第一次 GET 页面时创建，之后同一 session 复用。
- `validate` 同时支持参数 `_csrf` 和请求头 `X-CSRF-Token`。参数适合普通表单；请求头适合脚本请求。
- `csrf-meta.jsp` 只在 `loginUser != null` 时输出 token，避免未登录页面暴露无意义 token。
- `header.jsp` 在业务页 `<body>` 开始处 include `csrf-meta.jsp`，所以 dashboard、profile 以及角色业务页都能拿到 meta。
- `app.js` 不要求每个表单手写隐藏字段，而是在 DOM 加载后统一扫描 POST 表单并注入 `_csrf`。
- 对 `multipart/form-data`，`app.js` 额外把 `_csrf` 放入 action URL 的 searchParams，提升过滤器读取 token 的稳定性。
- `initPageMessages` 将 `msg=csrf_error` 显示为“安全验证失败，请刷新页面后重试”。

### 9.5 `ProfileController` 与 `profile.jsp`

- `profile.action` 是所有登录角色共享的个人中心控制器，不在角色目录中。
- GET 流程重新从数据库查当前用户，避免直接展示旧 session 数据。
- `profile.jsp` 对 `profileUser == null` 做兜底 redirect，避免用户绕开控制器直接访问 JSP 时出现空对象展示。
- 资料表单和密码表单都是 `method="post"`，都会被 `app.js` 自动注入 `_csrf`，并被 `AuthFilter` 按受保护 `.action` 校验。
- 修改资料成功后会刷新 `session.loginUser`，所以顶部显示的邮箱 / 电话等用户对象相关信息能跟数据库保持一致。
- 修改密码不会立即退出当前 session；它更新数据库密码后返回 `password_ok`，下一次登录使用新密码。

### 9.6 `UserDao`、`SQLHelper`、`jdbc.properties`

- `UserDao.findByUsername` 使用 `WHERE username=?`，参数通过 `SQLHelper` 绑定进 `PreparedStatement`，不是字符串拼接。
- `UserDao.validate` 要求用户存在且 `status=1`，再做密码匹配。
- `UserDao.validatePassword` 用于个人中心修改密码时校验旧密码。
- `UserDao.updateProfile` 只更新 `email` 和 `phone`；`updatePassword` 只更新密码摘要。
- `AuthFilter` 的账号复查使用 `UserDao.findById`，不是完全信任 session 中旧对象。
- `SQLHelper` 启动时从 classpath 读取 `jdbc.properties`，创建 Druid 数据源；查询时获取连接、prepare SQL、绑定参数、执行查询、最后关闭资源。
- `jdbc.properties` 当前指定 MySQL 驱动、本机 `graduation_design` 库、UTF-8 编码、Asia/Shanghai 时区和 Druid 连接池参数。

## 10. 代码证据清单

- `WebContent/login.jsp:13-21`
- `WebContent/login.jsp:32-45`
- `WebContent/login.jsp:46-56`
- `WebContent/index.jsp:3-8`
- `WebContent/dashboard.jsp:4-13`
- `WebContent/dashboard.jsp:14-19`
- `WebContent/dashboard.jsp:28-40`
- `WebContent/dashboard.jsp:47-60`
- `WebContent/dashboard.jsp:86-130`
- `WebContent/dashboard.jsp:153-156`
- `WebContent/dashboard.jsp:176-185`
- `WebContent/dashboard.jsp:227-236`
- `WebContent/dashboard.jsp:308-308`
- `WebContent/profile.jsp:4-10`
- `WebContent/profile.jsp:11-20`
- `WebContent/profile.jsp:22-24`
- `WebContent/profile.jsp:54-67`
- `WebContent/profile.jsp:72-89`
- `WebContent/profile.jsp:94-94`
- `WebContent/WEB-INF/includes/header.jsp:7-12`
- `WebContent/WEB-INF/includes/sidebar.jsp:18-29`
- `WebContent/WEB-INF/includes/sidebar.jsp:30-40`
- `WebContent/WEB-INF/includes/sidebar.jsp:41-60`
- `WebContent/WEB-INF/includes/sidebar.jsp:69-75`
- `WebContent/WEB-INF/includes/footer.jsp:17-18`
- `WebContent/WEB-INF/includes/csrf-meta.jsp:4-8`
- `WebContent/js/app.js:51-72`
- `WebContent/js/app.js:74-84`
- `WebContent/js/app.js:114-115`
- `WebContent/js/app.js:415-417`
- `src/controller/LoginController.java:16-18`
- `src/controller/LoginController.java:20-29`
- `src/controller/LoginController.java:31-38`
- `src/controller/LoginController.java:40-54`
- `src/controller/LoginController.java:57-60`
- `src/controller/LogoutController.java:14-18`
- `src/controller/LogoutController.java:19-27`
- `src/controller/ProfileController.java:15-20`
- `src/controller/ProfileController.java:21-29`
- `src/controller/ProfileController.java:31-43`
- `src/controller/ProfileController.java:45-70`
- `src/controller/ProfileController.java:72-96`
- `src/filter/AuthFilter.java:19-29`
- `src/filter/AuthFilter.java:31-40`
- `src/filter/AuthFilter.java:42-50`
- `src/filter/AuthFilter.java:52-68`
- `src/filter/AuthFilter.java:69-84`
- `src/filter/AuthFilter.java:86-104`
- `src/filter/AuthFilter.java:107-118`
- `src/filter/AuthFilter.java:120-128`
- `src/util/RoleUtil.java:5-18`
- `src/util/CsrfUtil.java:8-20`
- `src/util/CsrfUtil.java:23-36`
- `src/util/WebUtil.java:8-27`
- `src/dao/UserDao.java:16-27`
- `src/dao/UserDao.java:38-45`
- `src/dao/UserDao.java:140-154`
- `src/dao/UserDao.java:156-166`
- `src/dao/UserDao.java:281-307`
- `src/dbutil/SQLHelper.java:19-27`
- `src/dbutil/SQLHelper.java:30-49`
- `src/dbutil/SQLHelper.java:52-77`
- `src/dbutil/SQLHelper.java:79-94`
- `src/dbutil/SQLHelper.java:96-115`
- `src/dbutil/SQLHelper.java:117-143`
- `src/dbutil/SQLHelper.java:145-155`
- `src/jdbc.properties:2-18`
