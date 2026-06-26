# 12 - Windows 平台部署说明

本文档介绍如何在 **Windows 11** 上安装依赖、构建并运行本项目。整体思路与 WSL/Ubuntu 版本保持一致：

- 使用项目内便携工具（`tools/` 目录），不污染系统环境。
- 使用 Windows 批处理脚本（`.bat`）替代 Linux Shell 脚本。
- 使用 Windows 专用 Nginx 配置文件。

> 已在 Windows 11（Build 26200）+ Git Bash + PowerShell 5.1 环境验证通过。

---

## 目录

- [环境要求](#环境要求)
- [安装依赖](#安装依赖)
- [构建项目](#构建项目)
- [启动生产/本地演示模式](#启动生产本地演示模式)
- [开发模式](#开发模式)
- [运行测试](#运行测试)
- [停止服务](#停止服务)
- [重新加载 Nginx 配置](#重新加载-nginx-配置)
- [与 Linux/WSL 版本的差异](#与-linuxwsl-版本的差异)
- [目录结构变化](#目录结构变化)
- [常见问题排查](#常见问题排查)

---

## 环境要求

- Windows 11（64 位）
- PowerShell 5.1 或更高版本（用于运行 `setup-windows.ps1`）
- 已安装 Node.js 18+ 与 pnpm（前端构建需要；若未安装，请先安装 [Node.js](https://nodejs.org/) 并启用 pnpm）
- 端口未被占用：
  - `8080`：Tomcat
  - `8090`：Nginx
  - `8005`：Tomcat shutdown
  - `8081`：开发模式后端（仅开发模式使用）
  - `8000`：开发模式前端（仅开发模式使用）

> 提示：Windows 版本默认使用 `8090` 作为 Nginx 入口端口（而非 Linux/WSL 版本的 `8088`），这是因为在部分 Windows 系统上 `8088` 可能被保留或占用。如需修改，请编辑 `nginx/conf.d/default-win.conf.template`，将 `listen 8090;` 改为其他端口，然后运行 `scripts\reload-nginx.bat`。
>
> 提示：本文档假设项目已克隆到 `E:\Code\demo\nginxdemo`。如果你的路径不同，批处理脚本会自动检测项目根目录，无需手动修改。

---

## 安装依赖

项目提供了 `scripts/setup-windows.bat`，会自动下载并解压以下便携软件到 `tools/` 目录：

- Eclipse Temurin JDK 17 → `tools/jdk`
- Apache Maven 3.9.x → `tools/maven`
- Nginx for Windows 1.26.x → `tools/nginx`

在项目根目录打开 **CMD**、**PowerShell** 或 **Git Bash**，执行：

```bat
scripts\setup-windows.bat
```

首次执行需要联网下载约 300 MB 文件，耗时取决于网络。安装成功后你会看到：

```text
Windows dependencies ready!
  JDK:   E:\Code\demo\nginxdemo\tools\jdk
  Maven: E:\Code\demo\nginxdemo\tools\maven
  Nginx: E:\Code\demo\nginxdemo\tools\nginx
```

如需强制重新安装所有工具，执行：

```bat
scripts\setup-windows.bat -Force
```

---

## 构建项目

执行：

```bat
scripts\build.bat
```

该脚本会：

1. 使用 Maven 将后端打包为 `backend/target/backend.war`，并复制到 `tomcat/webapps/backend.war`。
2. 使用 pnpm 安装前端依赖并执行 `umi build`，产物输出到 `frontend/dist/`。

如需跳过单元测试以加快构建速度，执行：

```bat
SET SKIP_TESTS=true
scripts\build.bat
```

构建成功后会显示：

```text
[3/3] Build complete!
  - Backend WAR: E:\Code\demo\nginxdemo\tomcat\webapps\backend.war
  - Frontend dist: E:\Code\demo\nginxdemo\frontend\dist
```

---

## 启动生产/本地演示模式

构建完成后，执行：

```bat
scripts\start-local.bat
```

该脚本会：

1. 检查 `backend.war` 和 `frontend/dist` 是否存在。
2. 使用 `nginx/nginx-win.conf` 启动 Nginx，监听 `8090` 端口。
3. 使用项目内置 Tomcat 启动后端，监听 `8080` 端口。

启动成功后访问：

| 地址 | 说明 |
|------|------|
| <http://127.0.0.1:8090> | 前端页面 |
| <http://127.0.0.1:8090/api/users> | 经 Nginx 代理的用户列表 API |
| <http://127.0.0.1:8080/backend/api/users> | 后端直连（不经过 Nginx） |

---

## 开发模式

开发调试时可同时启动前后端，执行：

```bat
scripts\run-dev.bat
```

该脚本会：

1. 在后台启动 Spring Boot 后端（`mvn spring-boot:run`），监听 `8081` 端口。
2. 等待健康检查接口 `http://127.0.0.1:8081/backend/api/users/health` 就绪。
3. 在前台启动 UmiJS 开发服务器，监听 `8000` 端口。

开发模式访问地址：

| 地址 | 说明 |
|------|------|
| <http://127.0.0.1:8000> | 前端页面 |
| <http://127.0.0.1:8000/api/users> | 经 Umi 代理的用户列表 API |
| <http://127.0.0.1:8081/backend/api/users> | 后端直连 |

按 `Ctrl+C` 可停止前端 dev server，脚本会自动停止后台后端进程。

---

## 运行测试

执行：

```bat
scripts\test.bat
```

该脚本会依次运行：

1. 后端 Maven 测试（`mvn test`）。
2. 前端 Vitest 测试（`pnpm run test:run`）。

最后输出汇总结果：

```text
============================================================
Test Summary
  [PASS] Backend tests
  [PASS] Frontend tests
============================================================
All tests passed!
```

---

## 停止服务

执行：

```bat
scripts\stop-local.bat
```

该脚本会优雅地停止 Nginx 和 Tomcat。如果优雅停止失败，会自动使用 `taskkill` 强制结束进程。

---

## 重新加载 Nginx 配置

如果你修改了 `nginx/nginx-win.conf.template` 或 `nginx/conf.d/default-win.conf.template`，执行：

```bat
scripts\reload-nginx.bat
```

该脚本会先测试配置语法，然后重新加载 Nginx，不会中断现有连接。

> 注意：请直接编辑 `.template` 文件，实际生成的 `.conf` 文件会在运行脚本时自动覆盖。

---

## 与 Linux/WSL 版本的差异

| 项目 | Linux / WSL | Windows 11 |
|------|-------------|------------|
| JDK/Maven/Nginx 安装方式 | `apt` 系统安装 | 便携包放到 `tools/` |
| 脚本语言 | `.sh`（Shell） | `.bat`（批处理）+ `.ps1`（PowerShell） |
| Nginx 配置 | `/etc/nginx/sites-available/nginxdemo` | `nginx/nginx-win.conf` + `nginx/conf.d/default-win.conf` |
| Nginx 启动方式 | `sudo systemctl start nginx` | `start nginx.exe -c nginx-win.conf` |
| Tomcat 启动方式 | `startup.sh` | `catalina.bat start` |
| Nginx 事件模型 | `epoll` | Windows 默认 `select`（已移除 `use epoll`） |

---

## 目录结构变化

新增/变化的文件如下：

```text
nginxdemo/
├── tools/                          # 新增：便携工具目录（不提交到 Git）
│   ├── jdk/                        # Eclipse Temurin JDK 17
│   ├── maven/                      # Apache Maven 3.9.x
│   └── nginx/                      # Nginx for Windows
├── nginx/
│   ├── nginx-win.conf.template     # 新增：Windows 主配置模板
│   ├── nginx-win.conf              # 新增：自动生成的 Windows 主配置
│   └── conf.d/
│       ├── default-win.conf.template  # 新增：Windows 站点配置模板
│       └── default-win.conf           # 新增：自动生成的 Windows 站点配置
├── scripts/
│   ├── setup-windows.bat           # 新增：安装依赖
│   ├── setup-windows.ps1           # 新增：安装依赖（PowerShell）
│   ├── init-windows-env.bat        # 新增：初始化环境变量与 Nginx 配置
│   ├── build.bat                   # 新增：构建
│   ├── start-local.bat             # 新增：启动 Nginx + Tomcat
│   ├── stop-local.bat              # 新增：停止 Nginx + Tomcat
│   ├── run-dev.bat                 # 新增：开发模式
│   ├── run-dev.ps1                 # 新增：开发模式（PowerShell）
│   ├── test.bat                    # 新增：运行测试
│   └── reload-nginx.bat            # 新增：重载 Nginx 配置
└── docs/
    └── 12-Windows平台部署说明.md    # 新增：本文档
```

---

## 常见问题排查

### 1. 执行 `.bat` 脚本时中文乱码

所有 `.bat` 脚本均采用 ASCII/英文输出，不会出现中文乱码。文档说明以中文 Markdown 为准。

### 2. `setup-windows.bat` 下载失败

如果某个下载源临时不可用，可以：

1. 手动下载对应版本的 JDK / Maven / Nginx zip 包。
2. 解压到 `tools/jdk`、`tools/maven`、`tools/nginx`。
3. 重新运行 `scripts\setup-windows.bat`，已存在的目录会被跳过。

### 3. Nginx 启动失败，提示 `bind() to 0.0.0.0:8090 failed`

说明 `8090` 端口已被占用。检查并释放端口：

```bat
netstat -ano | findstr :8090
:: 记下最后一列 PID，然后执行：
taskkill /PID <PID> /F
```

### 4. Tomcat 启动失败，提示 `Address already in use: bind 8080`

同上，检查并释放 `8080` 端口：

```bat
netstat -ano | findstr :8080
```

### 5. Maven 提示 `JAVA_HOME not defined`

请确认已通过 `scripts\init-windows-env.bat` 初始化环境。单独运行 `mvn.cmd` 时需要手动设置：

```bat
set JAVA_HOME=E:\Code\demo\nginxdemo\tools\jdk
set PATH=%JAVA_HOME%\bin;%PATH%
```

### 6. 前端 dev server 无法代理到后端

确认后端已启动并监听 `8081`：

```bat
curl http://127.0.0.1:8081/backend/api/users/health
```

如果后端未启动，检查 `backend/backend-dev.log` 中的错误信息。

### 7. 修改 Nginx 配置后未生效

Windows 版本的 Nginx 配置由模板自动生成，请编辑 `.template` 文件后运行：

```bat
scripts\reload-nginx.bat
```

不要直接修改 `nginx/nginx-win.conf` 或 `nginx/conf.d/default-win.conf`，它们会被 `init-windows-env.bat` 覆盖。

---

完成以上步骤后，你就可以在 Windows 11 上完整运行本项目的 Nginx + Tomcat + Spring Boot + UmiJS 演示了。
