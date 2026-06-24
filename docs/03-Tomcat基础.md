# 03 - Tomcat 基础

## 1. Tomcat 是什么？

**Tomcat** 是一个开源的 **Servlet 容器**（也叫 Web 容器），由 Apache 软件基金会维护。它实现了 Java EE/Jakarta EE 中的 Servlet、JSP、WebSocket 等规范。

通俗地说：

- 你写的 Spring Boot 项目本质上是一堆 Servlet。
- Tomcat 负责接收 HTTP 请求、找到对应的 Servlet、调用它、再把结果返回给客户端。
- 所以 Tomcat 是连接“你的 Java 代码”和“浏览器/代理服务器”的桥梁。

## 2. Spring Boot 内嵌 Tomcat vs 外置 Tomcat

### 内嵌 Tomcat（默认方式）

```bash
java -jar myapp.jar
```

Spring Boot 默认把 Tomcat 打包进 JAR，直接运行即可。

优点：部署简单。  
缺点：一个应用一个 Tomcat，资源重复；不便于多应用共享。

### 外置 Tomcat（传统方式）

```bash
# 1. 把应用打成 WAR 包
mvn clean package

# 2. 把 WAR 放到 Tomcat 的 webapps 目录

# 3. 启动 Tomcat
./bin/startup.sh
```

优点：一个 Tomcat 可以运行多个 WAR；更符合传统 Java 企业级部署习惯。  
缺点：配置稍复杂，需要理解 WAR、Context、server.xml 等概念。

**本项目重点学习外置 Tomcat 部署。**

## 3. Tomcat 核心目录

以本项目的 `tomcat/apache-tomcat-10.1.56` 为例：

| 目录 | 作用 |
|------|------|
| `bin/` | 启动/关闭脚本：`startup.sh`、`shutdown.sh`、`catalina.sh` |
| `conf/` | 配置文件：`server.xml`、`context.xml`、`web.xml` |
| `lib/` | Tomcat 运行依赖的 jar 包 |
| `logs/` | 运行日志：`catalina.out`、访问日志等 |
| `webapps/` | 应用部署目录，WAR 包放在这里 |
| `work/` | 运行时生成的临时文件，例如 JSP 编译产物 |
| `temp/` | 临时目录 |

## 4. server.xml 核心组件

```xml
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" />
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
      </Host>
    </Engine>
  </Service>
</Server>
```

- **Server**：整个 Tomcat 实例。
- **Service**：一个或多个 Connector + 一个 Engine。
- **Connector**：监听端口，处理 HTTP/AJP 请求。
- **Engine**：请求处理引擎，决定交给哪个 Host。
- **Host**：虚拟主机，相当于一个站点。
- **Context**：一个 Web 应用，通常由 WAR 包自动创建。

## 5. WAR 包是什么？

**WAR** = Web Application Archive，是一个特殊的 JAR 包，目录结构固定：

```
myapp.war
├── META-INF/
├── WEB-INF/
│   ├── classes/        # 编译后的 Java 类
│   ├── lib/            # 依赖 jar
│   └── web.xml         # 部署描述符（可选，Spring Boot 可省略）
└── index.html          # 静态页面
```

Tomcat 会自动把 WAR 解压成同名的目录。

例如 `backend.war` 会被部署为 `/backend`，访问地址就是：

```
http://localhost:8080/backend/api/users
```

## 6. CATALINA_HOME 与 CATALINA_BASE

这是 Tomcat 中容易混淆的两个概念：

- **CATALINA_HOME**：Tomcat 的安装目录，包含 `bin/`、`lib/` 等二进制文件。
- **CATALINA_BASE**：Tomcat 的运行目录，包含 `conf/`、`webapps/`、`logs/` 等配置和数据。

默认情况下两者相同。但在本项目中：

```bash
CATALINA_HOME=/home/charles/code/nginxdemo/tomcat/apache-tomcat-10.1.56
CATALINA_BASE=/home/charles/code/nginxdemo/tomcat
```

这样可以把 Tomcat 程序和自己的配置/日志/应用分离开，是学习多实例部署的好基础。

下一篇将介绍前端项目结构和配置。
