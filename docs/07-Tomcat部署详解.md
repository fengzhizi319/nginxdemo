# 07 - Tomcat 部署详解

本项目使用**外置 Tomcat** 部署 Spring Boot 后端。下面讲解完整流程。

## 1. 部署流程

```bash
# 1. 打包
mvn clean package -DskipTests

# 2. 复制 WAR 到 Tomcat
mkdir -p tomcat/webapps
cp backend/target/backend.war tomcat/webapps/

# 3. 启动 Tomcat
./tomcat/apache-tomcat-10.1.56/bin/startup.sh

# 4. 验证
# http://127.0.0.1:8080/backend/api/users
```

`scripts/build.sh` 和 `scripts/start-local.sh` 已经把这些步骤自动化了。

## 2. 为什么 WAR 包名决定访问路径？

Tomcat 的 `Host` 配置：

```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
</Host>
```

- `appBase="webapps"`：应用部署根目录。
- `unpackWARs="true"：自动解压 WAR。
- `autoDeploy="true"`：自动部署新放入的 WAR。

当你放入 `backend.war`，Tomcat 会：

1. 解压为 `webapps/backend/`。
2. 创建一个 Context，路径为 `/backend`。
3. 访问地址就是 `http://localhost:8080/backend/...`。

如果你希望用根路径 `/`，可以把 WAR 重命名为 `ROOT.war`。

## 3. CATALINA_HOME 与 CATALINA_BASE 的使用

`scripts/start-local.sh` 中：

```bash
export CATALINA_HOME="$PROJECT_DIR/tomcat/apache-tomcat-10.1.56"
export CATALINA_BASE="$PROJECT_DIR/tomcat"
```

启动时 Tomcat 会：

- 从 `CATALINA_HOME/bin` 找启动脚本。
- 从 `CATALINA_BASE/conf` 读 `server.xml`。
- 从 `CATALINA_BASE/webapps` 部署应用。
- 把日志写到 `CATALINA_BASE/logs`。

这样程序和应用数据分离，是学习多实例 Tomcat 的基础。

## 4. server.xml 关键配置回顾

```xml
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" />
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps"
            unpackWARs="true" autoDeploy="true">
      </Host>
    </Engine>
  </Service>
</Server>
```

- `Server port="8005"`：关闭端口。
- `Connector port="8080"`：HTTP 监听端口，Nginx 会转发到这里。
- `Engine`：处理引擎。
- `Host`：虚拟主机。

## 5. 查看日志

Tomcat 日志在 `tomcat/logs/`：

| 文件 | 内容 |
|------|------|
| `catalina.out` | 标准输出/错误，包含 Spring Boot 启动日志 |
| `localhost_access_log.*.txt` | HTTP 访问日志 |
| `localhost.*.log` | 应用日志 |
| `manager.*.log` | 管理应用日志 |

查看实时日志：

```bash
tail -f tomcat/logs/catalina.out
```

## 6. 修改端口

如果 8080 被占用，修改 `tomcat/conf/server.xml`：

```xml
<Connector port="8080" ... />
```

改为其他端口，例如 8090，然后同步修改 Nginx 的 upstream：

```nginx
upstream backend_servers {
    server 127.0.0.1:8090 weight=1;
}
```

最后重启 Tomcat 和 Nginx。

## 7. 热部署

因为 `autoDeploy="true"`，你可以在 Tomcat 运行时替换 WAR 包：

```bash
mvn clean package -DskipTests
cp backend/target/backend.war tomcat/webapps/
```

Tomcat 会自动重新加载应用。不过生产环境建议先停止再替换，避免 ClassLoader 泄漏。

## 8. 常见问题

### 8.1 端口冲突

错误信息：

```
Address already in use: bind 8080
```

解决：修改 `server.xml` 中的 Connector 端口。

### 8.2 WAR 没有自动部署

检查 `server.xml` 中 `autoDeploy="true"` 和 `unpackWARs="true"` 是否设置。

### 8.3 Spring Boot 404

确认 `DemoApplication` 继承了 `SpringBootServletInitializer` 并重写了 `configure()`。

下一篇将演示 Nginx 负载均衡。
