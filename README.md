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
│   └── 10-测试说明.md       # 前后端单元测试与开发联调
├── frontend/                # UmiJS 4 React 前端
├── backend/                 # Spring Boot 3 + Java 17 后端
├── nginx/                   # Nginx 配置参考（系统 Nginx 使用 /etc/nginx 下的配置）
├── tomcat/                  # Tomcat 配置与本地二进制
│   └── apache-tomcat-10.1.56/
├── scripts/                 # 一键脚本
│   ├── build.sh             # 构建前后端（默认运行测试）
│   ├── test.sh              # 运行前后端单元测试
│   ├── run-dev.sh           # 前后端同时启动（开发模式）
│   ├── start-local.sh       # 启动 Nginx + Tomcat
│   └── stop-local.sh        # 停止 Nginx + Tomcat
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
