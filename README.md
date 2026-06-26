# Nginx + Tomcat 学习示例

> 本项目是一个面向初学者的完整示例，演示如何用 **Nginx** 做反向代理和静态资源服务器，用 **Tomcat** 作为 Servlet 容器运行 Spring Boot 后端，前端则是一个 UmiJS 4 React 单页应用。

## 为什么要做这个示例？

很多新手在学习 Nginx 和 Tomcat 时会遇到这些问题：

- Nginx 到底转发请求给谁？怎么配置？
- Tomcat 是干什么用的？Spring Boot 不是自带 Tomcat 吗？为什么还要外置？
- 前端打包后怎么部署？刷新页面为什么会 404？
- 负载均衡在 Nginx 里怎么配？

本项目用最小的代码量、最详细的注释和文档，把这些知识点串起来，让你跑一遍就能理解整个链路。

## 项目结构

```
nginxdemo/
├── docs/                    # 详细学习文档（从这里开始看）
│   ├── 01-环境准备.md
│   ├── 02-Nginx基础.md
│   ├── 03-Tomcat基础.md
│   ├── 04-前端项目说明.md
│   ├── 05-后端项目说明.md
│   ├── 06-Nginx配置详解.md
│   ├── 07-Tomcat部署详解.md
│   ├── 08-负载均衡演示.md
│   ├── 09-常见问题排查.md
│   ├── 10-测试说明.md       # 前后端单元测试与开发联调
│   └── 12-Windows平台部署说明.md  # Windows 11 部署指南
├── frontend/                # UmiJS 4 React 前端
├── backend/                 # Spring Boot 3 + Java 17 后端
├── nginx/                   # Nginx 配置参考（系统 Nginx 使用 /etc/nginx 下的配置）
│   ├── nginx-win.conf.template      # Windows 主配置模板
│   └── conf.d/
│       └── default-win.conf.template # Windows 站点配置模板
├── tomcat/                  # Tomcat 配置与本地二进制
│   └── apache-tomcat-10.1.56/
├── scripts/                 # 一键脚本
│   ├── build.sh             # Linux/WSL：构建前后端
│   ├── test.sh              # Linux/WSL：运行前后端单元测试
│   ├── run-dev.sh           # Linux/WSL：前后端同时启动（开发模式）
│   ├── start-local.sh       # Linux/WSL：启动 Nginx + Tomcat
│   ├── stop-local.sh        # Linux/WSL：停止 Nginx + Tomcat
│   ├── setup-windows.bat    # Windows：安装便携 JDK/Maven/Nginx
│   ├── build.bat            # Windows：构建前后端
│   ├── start-local.bat      # Windows：启动 Nginx + Tomcat
│   ├── stop-local.bat       # Windows：停止 Nginx + Tomcat
│   ├── run-dev.bat          # Windows：前后端同时启动（开发模式）
│   ├── test.bat             # Windows：运行前后端单元测试
│   └── reload-nginx.bat     # Windows：重新加载 Nginx 配置
├── tools/                   # Windows 便携工具（不提交到 Git）
│   ├── jdk/                 # Eclipse Temurin JDK 17
│   ├── maven/               # Apache Maven
│   └── nginx/               # Nginx for Windows
└── README.md
```

## 快速开始

### 1. 环境要求

- JDK 17+
- Maven 3.8+
- Node.js 18+ / npm 9+
- Linux / WSL（已测试 Ubuntu）

> Nginx 已通过 `apt` 安装为系统服务，由 `systemctl` 管理。
> Tomcat 以项目内便携目录形式包含，无需安装到系统。

### 2. 构建

```bash
cd /home/charles/code/nginxdemo
./scripts/build.sh
```

这会：
- 用 Maven 把后端打包成 `backend.war`，放到 `tomcat/webapps/`。
- 用 npm 安装前端依赖并构建，产物放到 `frontend/dist/`。

### 3. 启动

```bash
./scripts/start-local.sh
```

> 系统 Nginx 由 `systemctl` 管理：`sudo systemctl start|stop|reload|status nginx`。
> 当前已为你配置好 `/etc/nginx/sites-available/nginxdemo`，监听 8088 端口。

### 4. 访问

- 前端页面：<http://127.0.0.1:8088>
- 用户列表 API（经 Nginx 代理）：<http://127.0.0.1:8088/api/users>
- 后端直连（不经过 Nginx）：<http://127.0.0.1:8080/backend/api/users>

### 5. 停止

```bash
./scripts/stop-local.sh
```

## Windows 平台快速开始

本项目也支持在 Windows 11 上直接运行，无需 WSL。Windows 版本使用项目内便携工具（`tools/` 目录）和批处理脚本（`.bat`）。

### 1. 环境要求

- Windows 11（64 位）
- PowerShell 5.1+
- Node.js 18+ / pnpm（前端构建需要）

### 2. 安装依赖

```bat
cd e:\Code\demo\nginxdemo
scripts\setup-windows.bat
```

这会下载并解压 JDK 17、Maven 3.9.x 和 Nginx for Windows 到 `tools/` 目录。

### 3. 构建

```bat
scripts\build.bat
```

### 4. 启动

```bat
scripts\start-local.bat
```

### 5. 访问

- 前端页面：<http://127.0.0.1:8090>
- 用户列表 API（经 Nginx 代理）：<http://127.0.0.1:8090/api/users>
- 后端直连（不经过 Nginx）：<http://127.0.0.1:8080/backend/api/users>

### 6. 停止

```bat
scripts\stop-local.bat
```

### 7. 开发模式

```bat
scripts\run-dev.bat
```

### 8. 测试

```bat
scripts\test.bat
```

更多细节请阅读 [docs/12-Windows平台部署说明.md](docs/12-Windows平台部署说明.md)。

## 测试

本项目为前后端都补充了详细的单元测试，并支持一键运行。

### 一键运行全部测试

```bash
./scripts/test.sh
```

脚本会先运行后端 Maven 测试，再运行前端 Vitest 测试，最后输出汇总结果。

### 分别运行

**后端测试：**

```bash
cd backend
mvn test
```

**前端测试：**

```bash
cd frontend
pnpm install
pnpm run test:run
```

更多细节请阅读 [docs/10-测试说明.md](docs/10-测试说明.md)。
**只前端运行：**

```bash
cd frontend && npm run dev
```
## 前后端同时运行（开发模式）

开发调试时可使用 `run-dev.sh` 同时启动前后端：

```bash
./scripts/run-dev.sh
```

启动后访问：

- 前端页面：<http://127.0.0.1:8000>
- 用户列表 API（经 Umi 代理）：<http://127.0.0.1:8000/api/users>
- 后端直连：<http://127.0.0.1:8081/backend/api/users>

按 `Ctrl+C` 可同时停止前端 dev server 和后端 Spring Boot。

更多手动分步运行方式请阅读 [docs/10-测试说明.md](docs/10-测试说明.md)。

## 生产环境部署

生产环境使用 **Nginx** 作为反向代理和静态资源服务器，**外置 Tomcat** 作为 Servlet 容器运行 Spring Boot 后端。与开发模式最大的区别是：前端已构建为静态文件，Nginx 直接处理 `/api/*` 反向代理，不再依赖 Umi 开发服务器的 proxy。

### 1. 构建生产产物

```bash
./scripts/build.sh
```

构建完成后会生成：

- 后端 WAR：`tomcat/webapps/backend.war`
- 前端静态资源：`frontend/dist/`

> 如需跳过测试加速构建，可执行：`SKIP_TESTS=true ./scripts/build.sh`

### 2. Nginx 生产配置

生产环境使用系统级 Nginx（由 `systemd` 管理），站点配置文件位于：

- `/etc/nginx/sites-available/nginxdemo`
- 通过软链接启用：`/etc/nginx/sites-enabled/nginxdemo`

关键配置说明（已默认配置好）：

| 配置项 | 说明 |
|--------|------|
| `listen 8088` | Nginx 监听端口 |
| `root /home/charles/code/nginxdemo/frontend/dist` | 前端静态资源根目录 |
| `location /` | SPA 回退：`try_files $uri $uri/ /index.html` |
| `location /api/` | 反向代理到 Tomcat：`proxy_pass http://backend_servers/backend/api/` |
| `upstream backend_servers` | 后端 Tomcat 实例池，默认 `127.0.0.1:8080` |

如果修改了 Nginx 配置，执行以下命令重载即可生效：

```bash
./scripts/reload-nginx.sh
```

或手动执行：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 3. 启动生产服务

```bash
./scripts/start-local.sh
```

脚本会完成：

1. 检查 WAR 包和前端 `dist` 是否存在。
2. 确保系统 Nginx 已启动并加载 `nginxdemo` 站点配置。
3. 启动项目内的外置 Tomcat，监听 `8080` 端口。

### 4. 访问生产环境

- 前端页面：<http://127.0.0.1:8088>
- 前端页面：http://localhost:8088/
- 用户列表 API（经 Nginx 代理）：<http://127.0.0.1:8088/api/users>
- 后端直连（不经过 Nginx）：<http://127.0.0.1:8080/backend/api/users>

### 5. 停止生产服务

```bash
./scripts/stop-local.sh
```

该脚本会停止 Tomcat；系统 Nginx 仍由 `systemd` 管理，如需停止可执行：

```bash
sudo systemctl stop nginx
```

### 6. 开发模式与生产模式对比

| 对比项 | 开发模式 (`run-dev.sh`) | 生产模式 (`start-local.sh`) |
|--------|------------------------|----------------------------|
| 前端 | Umi dev server（端口 8000） | Nginx 托管静态文件（端口 8088） |
| 后端 | 内嵌 Tomcat（端口 8081） | 外置 Tomcat（端口 8080） |
| API 代理 | Umi `proxy` 转发 `/api` | Nginx `location /api/` 反向代理 |
| 是否热更新 | 是 | 否，需重新构建 |
| 用途 | 开发调试 | 部署运行 |

## 推荐阅读顺序

| 顺序 | 文档 | 内容 |
|------|------|------|
| 1 | [01-环境准备.md](docs/01-环境准备.md) | 检查 JDK、Maven、Node、Nginx、Tomcat |
| 2 | [02-Nginx基础.md](docs/02-Nginx基础.md) | 正向/反向代理、location、upstream |
| 3 | [03-Tomcat基础.md](docs/03-Tomcat基础.md) | Servlet 容器、目录结构、server.xml |
| 4 | [04-前端项目说明.md](docs/04-前端项目说明.md) | UmiJS 4 路由、代理、构建 |
| 5 | [05-后端项目说明.md](docs/05-后端项目说明.md) | Spring Boot WAR 打包、外置 Tomcat |
| 6 | [06-Nginx配置详解.md](docs/06-Nginx配置详解.md) | 逐行解释 nginx.conf、default.conf |
| 7 | [07-Tomcat部署详解.md](docs/07-Tomcat部署详解.md) | WAR 部署、CATALINA_BASE |
| 8 | [08-负载均衡演示.md](docs/08-负载均衡演示.md) | 多实例、weight、轮询 |
| 9 | [09-常见问题排查.md](docs/09-常见问题排查.md) | 404/502、端口冲突、跨域 |
| 10 | [10-测试说明.md](docs/10-测试说明.md) | 前后端单元测试与开发联调 |

## 架构图

```
┌─────────────────┐
│     浏览器       │
└────────┬────────┘
         │ HTTP 请求
         ▼
┌───────────────────────────────────┐     /api/*      ┌─────────────────┐
│  Nginx（系统服务）                │ ───────────────▶│  Tomcat :8080   │
│  /etc/nginx/sites-available/nginxdemo │  反向代理      │  - backend.war  │
│  - 静态资源服务                    │                 │  - Spring Boot  │
│  - 反向代理                        │                 │                 │
│  - 负载均衡                        │                 │                 │
└───────────────────────────────────┘                 └─────────────────┘
```

## 许可证

本项目仅用于学习交流。
