# 06 - Nginx 配置详解

本项目的 Nginx 配置位于系统目录：

- `/etc/nginx/nginx.conf`：全局主配置（使用系统默认）。
- `/etc/nginx/sites-available/nginxdemo`：站点/业务配置（我们自定义的）。

项目目录下的 `nginx/nginx.conf` 和 `nginx/conf.d/default.conf` 仅作为学习参考，
展示了如果不用系统 Nginx、改用便携版时的写法。

下面逐段解释 `/etc/nginx/sites-available/nginxdemo`。

## 1. 系统 Nginx 主配置 /etc/nginx/nginx.conf

系统 Nginx 已经有一个默认且合理的 `nginx.conf`，通常不需要修改。
它主要负责：

- 指定运行用户（默认 `www-data`）。
- 设置 worker 进程数、连接数、日志格式等全局参数。
- 引入 `sites-enabled/*` 下的站点配置。

你可以用 `cat /etc/nginx/nginx.conf` 查看默认配置，
主要关注 `include /etc/nginx/sites-enabled/*;` 这一行，
它说明系统会加载 `sites-enabled` 目录下所有站点配置。

## 2. 站点配置 /etc/nginx/sites-available/nginxdemo 详解

### 2.1 upstream 块

```nginx
upstream backend_servers {
    server 127.0.0.1:8080 weight=1;
}
```

定义后端服务器组。当前只有一台 Tomcat，权重为 1。

后续学习负载均衡时，可以添加更多 `server`，并设置 `weight`、`backup`、`max_fails` 等。

### 2.2 server 块

```nginx
server {
    listen 8088;
    server_name localhost;
    root /home/charles/code/nginxdemo/frontend/dist;
    index index.html;
```

- `listen 8088`：Nginx 监听 8088 端口。
- `server_name localhost`：虚拟主机名。
- `root`：静态资源根目录。

### 2.3 SPA 回退配置

```nginx
    location / {
        try_files $uri $uri/ /index.html;
    }
```

这是单页应用部署的核心：

1. 先找请求的文件或目录。
2. 找不到就返回 `index.html`，让前端路由处理。

### 2.4 反向代理配置

```nginx
    location /api/ {
        proxy_pass http://backend_servers/backend/api/;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_connect_timeout 30;
        proxy_send_timeout 30;
        proxy_read_timeout 30;
    }
```

- `proxy_pass`：转发目标。`backend_servers` 解析为 `127.0.0.1:8080`。
- `proxy_set_header`：把客户端信息传递给后端。
- `proxy_*_timeout`：代理超时时间。

### 2.5 静态资源缓存

```nginx
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|otf)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
```

对静态资源设置 30 天缓存，减少重复请求。

### 2.6 错误页面

```nginx
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
```

当后端不可用时，返回系统默认的错误页面。

## 3. 启用站点配置

```bash
# 创建软链接，启用站点
sudo ln -sf /etc/nginx/sites-available/nginxdemo /etc/nginx/sites-enabled/nginxdemo

# 测试配置语法
sudo nginx -t

# 重载配置
sudo systemctl reload nginx
```

## 4. 请求流转总结

```
浏览器 http://127.0.0.1:8088/api/users
       │
       ▼
   Nginx :8088
   location /api/ 匹配
       │
       ▼
   proxy_pass http://backend_servers/backend/api/users
       │
       ▼
   Tomcat :8080 /backend/api/users
       │
       ▼
   Spring Boot UserController
```

## 5. 调试技巧

```bash
# 查看 Nginx 访问日志
tail -f /var/log/nginx/nginxdemo-access.log

# 查看 Nginx 错误日志
tail -f /var/log/nginx/nginxdemo-error.log

# 测试配置是否正确
sudo nginx -t

# 查看 Nginx 运行状态
sudo systemctl status nginx
```

下一篇将解释 Tomcat 的部署和配置。
