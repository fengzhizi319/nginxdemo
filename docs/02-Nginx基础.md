# 02 - Nginx 基础

## 1. Nginx 是什么？

**Nginx**（发音 "engine-x"）是一个高性能的 HTTP 服务器和反向代理服务器，同时也可以做邮件代理、负载均衡、缓存等。

在本项目中，Nginx 主要承担三个角色：

1. **静态资源服务器**：直接返回前端构建出来的 HTML/JS/CSS/图片。
2. **反向代理**：把 `/api/*` 请求转发给 Tomcat 上的后端服务。
3. **负载均衡器**：把请求分发到多个后端实例（见文档 08）。

## 2. 正向代理 vs 反向代理

### 正向代理

代理的是**客户端**。例如你通过 VPN 访问 Google，VPN 代理了你的请求。

```
你（客户端） → 正向代理 → 目标服务器
```

### 反向代理

代理的是**服务器**。客户端不知道自己访问的是哪台真实服务器，只知道反向代理的地址。

```
你（浏览器） → Nginx（反向代理） → Tomcat/Spring Boot
```

**本项目使用的就是反向代理。**

## 3. Nginx 核心概念

### 3.1 server 块

一个 `server` 块代表一个虚拟主机。你可以在一台 Nginx 上配置多个 `server`，监听不同端口或域名。

```nginx
server {
    listen 8088;
    server_name localhost;
    root /path/to/frontend/dist;
}
```

### 3.2 location 块

`location` 用来匹配请求的 URL 路径，并决定如何处理。

```nginx
location / {
    # 处理所有以 / 开头的请求
}

location /api/ {
    # 处理所有以 /api/ 开头的请求
}
```

匹配规则：

- `location = /`：精确匹配 `/`。
- `location /`：前缀匹配，优先级最低，兜底。
- `location ~* \.(js|css)$`：正则匹配（不区分大小写）。

### 3.3 proxy_pass

把请求转发到另一个服务器。

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8080/backend/api/;
}
```

注意末尾的 `/`：

- `proxy_pass http://a/b/`：会把 `/api/users` 变成 `/b/users`。
- `proxy_pass http://a/b`：会把 `/api/users` 变成 `/b/api/users`。

### 3.4 upstream

定义一组后端服务器，供 `proxy_pass` 使用。

```nginx
upstream backend_servers {
    server 127.0.0.1:8080;
    server 127.0.0.1:8082;
}

location /api/ {
    proxy_pass http://backend_servers/api/;
}
```

## 4. 常用命令

Nginx 已安装为系统服务，使用 `systemctl` 管理：

```bash
# 启动 Nginx
sudo systemctl start nginx

# 停止 Nginx
sudo systemctl stop nginx

# 重新加载配置（不中断现有连接）
sudo systemctl reload nginx

# 查看运行状态
sudo systemctl status nginx

# 测试配置文件语法
sudo nginx -t
```

本项目还提供了一个便捷脚本：

```bash
# 修改 /etc/nginx/sites-available/nginxdemo 后，重载配置
./scripts/reload-nginx.sh
```

## 5. 本项目的 Nginx 工作流程

1. 浏览器访问 `http://127.0.0.1:8088/`。
2. Nginx 监听 8088 端口，匹配 `/`，返回 `frontend/dist/index.html`。
3. 浏览器加载 JS/CSS，Nginx 直接返回静态文件。
4. 前端调用 `/api/users`，Nginx 匹配 `/api/`，转发到 Tomcat。
5. Tomcat 执行 Spring Boot 后端代码，返回 JSON。
6. Nginx 把 JSON 返回给浏览器。

下一篇文档将详细解释本项目中的 `nginx.conf` 和 `default.conf`。
