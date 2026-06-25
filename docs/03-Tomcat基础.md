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
## 问题1，不同后端项目的区别

### 1. Tomcat 工作原理

Tomcat 的工作流程可以概括为：

```
浏览器/代理 → HTTP请求 → Connector(监听端口) → Engine(处理引擎) 
              → Host(虚拟主机) → Context(Web应用) → Servlet(你的代码)
              → 响应返回
```


**核心步骤：**
1. **Connector** 在指定端口（如 8080）监听 HTTP 请求
2. 收到请求后，交给 **Engine** 处理
3. Engine 根据域名找到对应的 **Host**
4. Host 根据 URL 路径找到对应的 **Context**（即你的 Web 应用）
5. Context 调用具体的 **Servlet**（Spring Boot 的 Controller）
6. 执行你的业务逻辑，返回结果

### 2. Tomcat 与后端项目的关系

你说得对，**Tomcat 本身是通用的**，它不关心你的具体业务逻辑。但它需要知道：

#### ✅ 必须配置的内容：

1. **端口**（Connector port）
    - 你的项目用 `8080`
    - 其他项目可以用 `8081`、`9090` 等

2. **应用部署位置**（appBase）
    - 你的项目在 `tomcat/webapps/backend.war`
    - Tomcat 会自动解压并映射为 `/backend` 路径

3. **上下文路径**（Context path）
    - 你的 WAR 包名决定了访问路径
    - `backend.war` → `http://localhost:8080/backend/api/users`

#### ❌ 不需要修改的内容：

- Tomcat 的核心代码（bin/、lib/）完全通用
- server.xml 的大部分配置可以保持不变
- 不同的 Spring Boot 项目只需要打不同的 WAR 包即可

### 3. 不同后端项目需要差异化配置吗？

#### 场景一：多个独立项目（常见）

```
项目A (电商) → backend-a.war → http://localhost:8080/backend-a/
项目B (博客) → backend-b.war → http://localhost:8080/backend-b/
```


**配置方式：**
- ✅ **无需修改 server.xml**（autoDeploy=true 时）
- ✅ 只需把不同的 WAR 包放到 `webapps/` 目录
- ✅ Tomcat 会自动根据 WAR 包名创建 Context

#### 场景二：多实例部署（高可用/隔离）

```
实例1 → CATALINA_BASE=/opt/tomcat-instance1 → 端口 8080
实例2 → CATALINA_BASE=/opt/tomcat-instance2 → 端口 8081
```


**配置方式：**
- ⚠️ 需要修改 `server.xml` 中的端口（避免冲突）
- ⚠️ 使用独立的 CATALINA_BASE 目录

#### 场景三：特殊需求（高级）

如果需要调整性能参数，可能需要修改：

```xml
<!-- 调整线程池大小 -->
<Connector port="8080" protocol="HTTP/1.1" 
           maxThreads="200"      <!-- 最大线程数 -->
           minSpareThreads="10"  <!-- 最小空闲线程 -->
           acceptCount="100" />  <!-- 等待队列长度 -->

<!-- 调整 JVM 内存（在 bin/setenv.sh 中） -->
export JAVA_OPTS="-Xms512m -Xmx2g"
```


### 4. 你的项目实际情况

在你的项目中：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **端口** | 8080 | `server.xml` 第 70 行 |
| **应用目录** | `tomcat/webapps/` | `server.xml` 第 107 行 |
| **WAR 包名** | `backend.war` | `pom.xml` 第 70 行 `<finalName>` |
| **访问路径** | `/backend` | WAR 包名自动决定 |
| **Nginx 代理** | `/api/` → `http://backend_servers/backend/api/` | `default.conf` 第 65 行 |

**关键点：**
- 如果你有另一个项目 `shop.war`，直接放到 `webapps/` 即可
- 访问路径会变成 `http://localhost:8080/shop/...`
- Nginx 需要新增一个 location 来代理它

### 总结

> 🎯 **Tomcat 是"容器"，你的项目是"内容"**
> - Tomcat 像一台服务器，WAR 包像网站程序
> - 换网站不需要换服务器，只需要上传新的 WAR 包
> - 大多数情况下，**只需要改端口和 WAR 包名**，其他都是通用的

这就是为什么外置 Tomcat 可以同时运行多个不同的 Java Web 应用，而内嵌 Tomcat（Spring Boot JAR）只能运行一个应用的原因。

让我用更直观的方式解释这句话的含义：

## 问题2， "Tomcat 会自动解压并映射为 /backend 路径"

### 1. 自动解压（unpackWARs）

当你把 `backend.war` 放到 `tomcat/webapps/` 目录后：
```
部署前：
webapps/
└── backend.war          ← 你刚放入的 WAR 包

部署后（Tomcat 启动后）：
webapps/
├── backend.war          ← 原始 WAR 包保留
└── backend/             ← Tomcat 自动解压出的目录 ✨
    ├── META-INF/
    ├── WEB-INF/
    │   ├── classes/
    │   │   └── com/example/demo/...
    │   └── lib/
    └── index.html
```


**关键配置**在 `server.xml` 第 108 行：
```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
```


- `unpackWARs="true"` → 自动解压 WAR 包
- `autoDeploy="true"` → 检测到新 WAR 包时自动部署

---

### 2️. **映射为 /backend 路径（Context Path）**

Tomcat 会根据**目录名/WAR 包名**决定访问路径：

```
WAR 包名              解压后的目录名        访问路径
backend.war    →     backend/      →     http://localhost:8080/backend/...
shop.war       →     shop/         →     http://localhost:8080/shop/...
myapp.war      →     myapp/        →     http://localhost:8080/myapp/...
```


**具体到你的项目：**

```
前端请求：
http://localhost:8088/api/users

Nginx 反向代理（default.conf 第 65 行）：
proxy_pass http://backend_servers/backend/api/;

实际转发到 Tomcat：
http://127.0.0.1:8080/backend/api/users
                ^^^^^^^^
                这个 /backend 就是 WAR 包名决定的！
```


---

### 3️. **完整流程示例**

假设你访问：`http://localhost:8088/api/users`

```
步骤1: 浏览器发送请求
       http://localhost:8088/api/users
       ↓

步骤2: Nginx 接收（监听 8088 端口）
       location /api/ {
           proxy_pass http://backend_servers/backend/api/;
       }
       ↓
       Nginx 把路径改写为：/backend/api/users
       ↓

步骤3: Nginx 转发到 Tomcat
       http://127.0.0.1:8080/backend/api/users
       ↓

步骤4: Tomcat 解析路径
       http://127.0.0.1:8080  ← Connector 监听的地址
       /backend               ← Context Path（对应 backend.war）
       /api/users             ← Servlet Path（对应你的 Controller）
       ↓

步骤5: Tomcat 找到对应的应用
       在 webapps/backend/WEB-INF/classes/ 中找到处理 /api/users 的 Controller
       ↓

步骤6: Spring Boot 执行你的代码
       @GetMapping("/api/users")
       public List<User> getUsers() { ... }
       ↓

步骤7: 返回结果
       JSON 数据沿原路返回给浏览器
```


---

### 4️. **如果换个 WAR 包名会怎样？**

假设你把 WAR 包改名为 `myapi.war`：

```bash
# 修改 pom.xml
<finalName>myapi</finalName>

# 重新打包
mvn clean package

# 部署
cp target/myapi.war tomcat/webapps/
```


**会发生什么：**

```
1. Tomcat 解压出 myapi/ 目录
2. 访问路径变成：http://localhost:8080/myapi/api/users
3. Nginx 配置需要改为：
   proxy_pass http://backend_servers/myapi/api/;
```


否则会出现 **404 错误**，因为 Tomcat 找不到 `/backend` 这个 Context。

---

### 5️. **可以自定义映射路径吗？**

可以！有两种方式：

#### 方式一：修改 WAR 包名（最简单）
```bash
backend.war → 映射为 /backend
```


#### 方式二：在 server.xml 中显式配置 Context
```xml
<Host name="localhost" appBase="webapps" ...>
    <!-- 把 myapp.war 映射到根路径 / -->
    <Context path="" docBase="myapp" reloadable="true" />
    
    <!-- 把 admin.war 映射到 /admin-panel -->
    <Context path="/admin-panel" docBase="admin" reloadable="true" />
</Host>
```


这样：
- `myapp.war` → `http://localhost:8080/` （根路径）
- `admin.war` → `http://localhost:8080/admin-panel` （自定义路径）

---

### 总结

> **"自动解压"** = Tomcat 把 `backend.war` 解压成 `backend/` 目录  
> **"映射为 /backend 路径"** = 你可以通过 `http://localhost:8080/backend/...` 访问这个应用

这就像：
- WAR 包是一个压缩包（类似 .zip）
- Tomcat 是个智能解压工具
- 解压后的文件夹名就是访问网址的一部分

这种设计让你只需**改变 WAR 包名**就能控制访问路径，无需额外配置！
## 发展趋势
### 1. Tomcat 现在还流行吗？
#### ✅ **依然非常流行，但使用方式在变化**

**市场地位：**
- 📊 Tomcat 仍然是 **全球最流行的 Java Web 容器**，市场占有率超过 60%
- 🏢 在传统企业、政府项目、金融系统中占据主导地位
- 🎓 是学习 Java Web 开发的标准教学工具
- 💼 大多数 Java 后端岗位的必备技能

**现状分析：**

| 领域 | Tomcat 使用情况 | 趋势 |
|------|----------------|------|
| 传统企业应用 | ⭐⭐⭐⭐⭐ 非常广泛 | 稳定 |
| 互联网大厂 | ⭐⭐⭐ 部分使用 | 逐渐减少 |
| 微服务架构 | ⭐⭐ 较少使用 | 下降 |
| 云原生/容器化 | ⭐⭐ 较少使用 | 下降 |
| Spring Boot 内嵌 | ⭐⭐⭐⭐⭐ 默认选择 | 增长 |

---

### 2. 最新的替代工具有哪些？

#### 🔥 **现代 Java Web 容器对比**

##### **(1) Spring Boot 内嵌 Tomcat（主流）**
```java
// 现在大多数项目这样用
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```
```bash
# 直接运行 JAR，无需外置 Tomcat
java -jar app.jar
```


**特点：**
- ✅ 开箱即用，零配置
- ✅ 一个应用一个进程，隔离性好
- ✅ 适合微服务、容器化部署
- ❌ 资源占用稍多（每个应用都有 Tomcat）

---

##### **(2) Undertow（高性能选择）**
Spring Boot 可以替换为 Undertow：

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-undertow</artifactId>
</dependency>
```


**特点：**
- ✅ Red Hat 开发，性能优于 Tomcat
- ✅ 完全异步非阻塞 I/O
- ✅ 更轻量，内存占用少
- ❌ 生态不如 Tomcat 成熟

---

##### **(3) Jetty（老牌替代品）**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```


**特点：**
- ✅ 轻量级，启动快
- ✅ 适合嵌入式场景
- ✅ Eclipse 基金会维护
- ❌ 市场份额逐渐减少

---

##### **(4) Quarkus（云原生新星）⭐**
```java
// Quarkus 应用示例
@QuarkusMain
public class Application {
    public static void main(String[] args) {
        Quarkus.run(args);
    }
}
```


**特点：**
- ✅ 专为 Kubernetes 和云原生设计
- ✅ 极速启动（毫秒级）
- ✅ 极低内存占用
- ✅ 支持 GraalVM 原生编译
- ❌ 学习曲线较陡，生态还在成长

---

##### **(5) Micronaut（微服务框架）**
```java
@MicronautTest
class MyTest {
    @Inject
    HttpClient client;
}
```


**特点：**
- ✅ 编译时依赖注入，无反射开销
- ✅ 启动快，适合 Serverless
- ✅ 内置响应式编程支持
- ❌ 社区相对较小

---

##### **(6) Helidon（Oracle 出品）**
```java
// Helidon MP (MicroProfile)
@ApplicationScoped
@Path("/hello")
public class HelloResource {
    @GET
    public String hello() {
        return "Hello World";
    }
}
```


**特点：**
- ✅ Oracle 官方支持
- ✅ 支持 MicroProfile 规范
- ✅ 响应式 Web 框架
- ❌ 采用率不高

---

### 3. 技术选型对比表

| 技术 | 启动速度 | 内存占用 | 适用场景 | 学习成本 | 流行度 |
|------|---------|---------|---------|---------|--------|
| **Tomcat（外置）** | 慢（秒级） | 高 | 传统企业部署 | 中 | ⭐⭐⭐ |
| **Tomcat（内嵌）** | 中（1-3秒） | 中 | Spring Boot 默认 | 低 | ⭐⭐⭐⭐⭐ |
| **Undertow** | 中（1-3秒） | 中 | 高性能需求 | 低 | ⭐⭐⭐ |
| **Jetty** | 快（<1秒） | 低 | 嵌入式场景 | 低 | ⭐⭐ |
| **Quarkus** | 极快（毫秒） | 极低 | 云原生/K8s | 高 | ⭐⭐⭐⭐ |
| **Micronaut** | 极快（毫秒） | 极低 | Serverless/微服务 | 高 | ⭐⭐⭐ |
| **Helidon** | 快（<1秒） | 低 | 云原生应用 | 高 | ⭐⭐ |

---

### 4. 行业趋势分析

#### 📈 **当前主流流做法（2024-2026）**

##### **场景一：传统单体应用**
```
技术栈：Spring Boot + 内嵌 Tomcat
部署：Docker 容器
比例：约 60%
```


##### **场景二：微服务架构**
```
技术栈：Spring Boot + 内嵌 Tomcat/Undertow
或
技术栈：Quarkus/Micronaut
部署：Kubernetes
比例：约 30%
```


##### **场景三：云原生/Serverless**
```
技术栈：Quarkus/Micronaut/Helidon
部署：Knative/FaaS
比例：约 10%（快速增长）
```


---

### 5. 你的项目应该用什么？

#### 🎯 **对于你这个学习项目：**

**继续使用外置 Tomcat 是正确的选择！**

**原因：**
1. ✅ **学习价值高**：理解 Web 容器工作原理
2. ✅ **符合教学目标**：掌握 Nginx + Tomcat 经典架构
3. ✅ **面试加分项**：很多公司仍在使用这种架构
4. ✅ **打好基础**：后续学内嵌 Tomcat 会更容易

#### 🚀 **实际工作推荐：**

```
新手入门 → Spring Boot + 内嵌 Tomcat（最简单）
进阶学习 → Spring Boot + Undertow（性能优化）
云原生方向 → Quarkus（未来趋势）
传统企业 → 外置 Tomcat（仍然大量使用）
```


---

### 6. 总结建议

> 💡 **Tomcat 并没有过时，只是使用方式变了**

**过去（2010-2018）：**
```
外置 Tomcat + WAR 包部署 = 标准做法
```


**现在（2019-2026）：**
```
Spring Boot + 内嵌 Tomcat + JAR 包 = 主流做法
```


**未来（2026+）：**
```
Quarkus/Micronaut + Kubernetes = 云原生趋势
```


**给你的建议：**
1. 📚 **先学好 Tomcat**：它是理解 Java Web 的基础
2. 🎯 **掌握内嵌 Tomcat**：工作中最常用的方式
3. 🔭 **关注 Quarkus**：未来的发展方向
4. 🏢 **了解外置部署**：传统企业仍在大量使用

**Tomcat 就像汽车的手动挡**：虽然自动挡（内嵌 Tomcat）和电动车（Quarkus）越来越流行，但学会手动挡能让你更好地理解汽车原理，而且在很多地方仍然需要它！🚗