# 前端项目架构说明

## 📋 目录

- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [文件详解](#文件详解)
- [开发流程](#开发流程)
- [构建与部署](#构建与部署)
- [与 Nginx 的协作](#与-nginx-的协作)

---

## 技术栈

本项目使用现代化的前端技术栈，旨在演示单页应用（SPA）如何与 Nginx + Tomcat 后端协同工作。

| 技术 | 版本 | 用途 |
|------|------|------|
| **UmiJS** | 4.4.6+ | React 企业级框架，提供路由、构建、配置等一站式解决方案 |
| **React** | 18.x | UI 组件库 |
| **TypeScript** | 5.7.3+ | 类型安全的 JavaScript 超集 |
| **Fetch API** | 原生 | HTTP 请求封装（无需 axios） |

### 为什么选择 UmiJS？

1. **约定式路由**：`src/pages/` 下的文件自动映射为路由，无需手动配置
2. **内置代理**：开发时通过 `proxy` 配置解决跨域问题
3. **开箱即用**：零配置启动，适合快速原型开发
4. **生产优化**：自动代码分割、Tree Shaking、压缩等

---

## 项目结构

```
frontend/
├── src/                      # 源代码目录
│   ├── pages/                # 页面组件（约定式路由）
│   │   ├── index.tsx         # 首页 → 映射到 /
│   │   └── user.tsx          # 用户页 → 映射到 /user
│   ├── services/             # API 服务层
│   │   └── api.ts            # HTTP 请求封装
│   ├── app.ts                # Umi 运行时配置
│   └── .umi-production/      # Umi 构建产物（自动生成）
├── dist/                     # 构建输出目录（部署到 Nginx）
├── node_modules/             # 依赖包
├── .umirc.ts                 # Umi 配置文件
├── package.json              # 项目元信息与脚本
├── pnpm-lock.yaml            # 依赖锁定文件
└── tsconfig.json             # TypeScript 配置
```

---

## 文件详解

### 1️⃣ `.umirc.ts` - Umi 配置文件

**作用**：定义应用的构建配置、路由行为、开发代理等。

**核心配置项**：

```typescript
export default defineConfig({
  title: 'Nginx + Tomcat 学习示例',  // 页面标题
  base: '/',                          // 路由基础路径
  publicPath: '/',                    // 静态资源公共路径
  history: { type: 'browser' },       // HTML5 History 模式（无 # 号）
  proxy: {                            // 开发时代理配置
    '/api': {
      target: 'http://127.0.0.1:8080/backend',
      changeOrigin: true,
    },
  },
  outputPath: 'dist',                 // 构建产物输出目录
});
```

**学习要点**：
- `history: { type: 'browser' }` 使 URL 更美观（如 `/user` 而非 `/#/user`），但需要 Nginx 配置 `try_files $uri $uri/ /index.html;` 否则刷新会 404
- `proxy` 仅在开发环境生效，生产环境由 Nginx 处理反向代理

---

### 2️⃣ `src/app.ts` - Umi 运行时配置

**作用**：Umi 4 约定式的运行时配置入口，可配置全局初始化、路由守卫等。

**当前实现**：
```typescript
export const onInitialStateChange = () => {
  // 示例：可以在这里打印日志或做权限校验
};
```

**扩展场景**：
- 添加全局请求拦截器
- 实现用户登录状态管理
- 配置错误边界（Error Boundary）

---

### 3️⃣ `src/services/api.ts` - API 服务层

**作用**：封装 HTTP 请求，统一处理响应和错误。

**核心函数**：

| 函数 | 方法 | 用途 |
|------|------|------|
| `get<T>(path)` | GET | 获取数据 |
| `post<T>(path, body)` | POST | 提交数据 |

**关键设计**：
```typescript
const BASE_URL = '/api';  // 相对路径，生产环境由 Nginx 代理

export async function get<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`);
  if (!response.ok) {
    throw new Error(`请求失败：${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}
```

**学习要点**：
- 使用浏览器原生 `fetch` API，无需安装 axios
- 请求地址为相对路径 `/api/xxx`，生产环境由 Nginx 转发到 Tomcat
- 统一的错误处理逻辑

---

### 4️⃣ `src/pages/index.tsx` - 首页组件

**作用**：应用入口页面，展示项目介绍和导航。

**路由映射**：`src/pages/index.tsx` → `/`

**核心功能**：
- 项目架构说明
- 技术栈展示
- 导航到用户管理页面

**关键代码**：
```typescript
import { Link } from 'umi';

export default function HomePage() {
  return (
    <div>
      <h1>🎉 Nginx + Tomcat 学习示例</h1>
      <Link to="/user">点击查看用户列表 →</Link>
    </div>
  );
}
```

**学习要点**：
- Umi 约定式路由：文件名即路由路径
- `Link` 组件实现 SPA 内部跳转，不触发整页刷新

---

### 5️⃣ `src/pages/user.tsx` - 用户管理页

**作用**：演示前后端完整交互，包括数据查询和新增。

**路由映射**：`src/pages/user.tsx` → `/user`

**核心功能**：
- 加载时自动获取用户列表（GET `/api/users`）
- 表单提交新增用户（POST `/api/users`）
- 实时刷新列表

**状态管理**：
```typescript
const [users, setUsers] = useState<User[]>([]);     // 用户列表
const [loading, setLoading] = useState(false);       // 加载状态
const [name, setName] = useState('');                // 表单姓名
const [age, setAge] = useState('');                  // 表单年龄
```

**数据流**：
```
组件挂载 → useEffect → fetchUsers() → GET /api/users
                                      ↓
                              Nginx 代理到 Tomcat
                                      ↓
                              更新 users 状态 → 渲染表格

提交表单 → handleSubmit() → POST /api/users
                                      ↓
                              成功后重新 fetchUsers()
```

**学习要点**：
- React Hooks（`useState`, `useEffect`）的使用
- 异步数据获取与状态更新
- 表单受控组件模式

---

### 6️⃣ `package.json` - 项目配置

**核心脚本**：

```json
{
  "scripts": {
    "dev": "umi dev",      // 启动开发服务器（带热更新）
    "build": "umi build",  // 构建生产版本
    "start": "npm run dev" // dev 的别名
  }
}
```

**依赖说明**：
- **dependencies**：`umi` - 核心框架
- **devDependencies**：`typescript`, `@types/react` - 类型定义

---

### 7️⃣ `tsconfig.json` - TypeScript 配置

**作用**：定义 TypeScript 编译选项（由 Umi 自动生成和管理）。

---

## 开发流程

### 本地开发

```bash
# 1. 安装依赖
cd frontend
pnpm install

# 2. 启动开发服务器（访问 http://localhost:8000）
npm run dev
```

**开发时请求流程**：
```
浏览器发起 /api/users 请求
        ↓
Umi Dev Server（localhost:8000）
        ↓
proxy 转发到 http://127.0.0.1:8080/backend/api/users
        ↓
Tomcat 处理请求并返回 JSON
```

### 生产构建

```bash
# 构建生产版本（输出到 dist/ 目录）
npm run build
```

**构建产物**：
```
dist/
├── index.html           # 入口 HTML
├── umi.js               # 应用代码（含 React）
├── umi.css              # 样式文件
└── ...                  # 其他静态资源
```

---

## 构建与部署

### 部署到 Nginx

1. **构建前端**：
   ```bash
   npm run build
   ```

2. **配置 Nginx**（`nginx/conf.d/default.conf`）：
   ```nginx
   server {
       listen 80;
       
       # 前端静态资源
       location / {
           root /path/to/frontend/dist;
           index index.html;
           try_files $uri $uri/ /index.html;  # 解决 SPA 刷新 404
       }
       
       # 后端 API 代理
       location /api {
           proxy_pass http://127.0.0.1:8080/backend;
       }
   }
   ```

3. **重启 Nginx**：
   ```bash
   nginx -s reload
   ```

### 为什么需要 `try_files`？

单页应用只有一个 `index.html`，所有路由都由前端 JavaScript 处理。当用户直接访问 `/user` 时：

- ❌ **没有 `try_files`**：Nginx 查找 `/user` 文件，找不到返回 404
- ✅ **有 `try_files`**：Nginx 返回 `index.html`，前端路由接管并渲染正确页面

---

## 与 Nginx 的协作

### 请求流转图

```
用户访问 http://localhost/
        ↓
   Nginx (端口 80)
        ↓
   ┌────┴────┐
   │ 判断路径 │
   └────┬────┘
        │
   ┌────┴────────────┐
   │                 │
/static files    /api/*
   │                 │
   ↓                 ↓
dist/ 目录      proxy_pass
(直接返回)    http://127.0.0.1:8080/backend
                   ↓
              Tomcat (端口 8080)
                   ↓
              Spring Boot 应用
```

### 开发环境与生产环境的差异

| 特性 | 开发环境 | 生产环境 |
|------|----------|----------|
| **服务器** | Umi Dev Server | Nginx |
| **端口** | 8000 | 80 |
| **API 代理** | `.umirc.ts` 中的 `proxy` | Nginx `proxy_pass` |
| **热更新** | ✅ 支持 | ❌ 不支持 |
| **代码压缩** | ❌ 不压缩 | ✅ 自动压缩 |

---

## 常见问题

### Q1: 刷新页面出现 404？

**原因**：Nginx 未配置 `try_files`，无法将未知路由 fallback 到 `index.html`。

**解决**：在 Nginx 配置中添加：
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

### Q2: 开发时请求跨域？

**原因**：前端运行在 `localhost:8000`，后端在 `localhost:8080`。

**解决**：`.umirc.ts` 已配置 `proxy`，确保请求路径以 `/api` 开头。

### Q3: 如何添加新页面？

**步骤**：
1. 在 `src/pages/` 下创建新文件，如 `about.tsx`
2. 自动映射到 `/about` 路由
3. 使用 `<Link to="/about">` 进行导航

### Q4: 如何调用新的 API？

**步骤**：
1. 在 `src/services/api.ts` 中已有 `get` 和 `post` 封装
2. 在组件中导入并使用：
   ```typescript
   import { get } from '@/services/api';
   
   const data = await get<YourType>('/your-endpoint');
   ```

---

## 总结

本前端项目展示了：

✅ **现代化 React 开发**：使用 UmiJS 4 + TypeScript  
✅ **约定优于配置**：自动路由、零配置启动  
✅ **前后端分离**：通过 Nginx 反向代理整合  
✅ **SPA 最佳实践**：History 路由、懒加载、错误处理  

这是一个最小化但完整的前端示例，可作为学习 Nginx + Tomcat 全栈部署的起点。
## umirc.ts作用，前端配置的 proxy的作用

### 核心区别：开发环境 vs 生产环境

#### 1️⃣ **前端配置的 proxy（仅开发时使用）**

```typescript
// frontend/.umirc.ts - 只在 npm run dev 时生效
proxy: {
  '/api': {
    target: 'http://127.0.0.1:8081/backend',
  }
}
```


**作用时机：**
```
开发环境流程：
npm run dev (启动 Umi 开发服务器，端口 8000)
  ↓
浏览器访问 http://localhost:8000
  ↓
前端代码请求 fetch('/api/users')
  ↓
Umi 开发服务器拦截并转发到 http://127.0.0.1:8081/backend/api/users
  ↓
后端返回数据
```


**为什么需要它？**
- ✅ **解决跨域**：`localhost:8000` → `localhost:8081` 不同端口，浏览器会阻止
- ✅ **开发便利**：不需要手动配置 Nginx，一键启动就能联调
- ✅ **热更新**：修改代码自动刷新，Nginx 做不到

---

#### 2️⃣ **Nginx 配置的 proxy（生产环境使用）**

```nginx
# nginx/conf.d/default.conf - 部署到服务器时使用
server {
  listen 8088;
  
  # 前端静态资源
  location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;
  }
  
  # 后端 API 代理
  location /api {
    proxy_pass http://127.0.0.1:8080/backend;
  }
}
```


**作用时机：**
```
生产环境流程：
用户访问 http://example.com:8088
  ↓
Nginx 接收请求
  ↓
如果是 /api/users → 转发到 http://127.0.0.1:8080/backend/api/users
如果是 / → 返回前端静态文件 index.html
```


**为什么需要它？**
- ✅ **统一入口**：前端和后端都通过 8088 端口访问
- ✅ **性能优化**：Nginx 处理静态资源比 Node.js 快得多
- ✅ **负载均衡**：可以配置多个后端服务器
- ✅ **SSL 终止**：HTTPS 在 Nginx 层处理

---

### 对比总结

| 特性 | 前端 proxy (.umirc.ts) | Nginx proxy (nginx.conf) |
|------|------------------------|--------------------------|
| **使用场景** | 开发环境 (`npm run dev`) | 生产环境 (部署后) |
| **运行者** | Umi 开发服务器 (Node.js) | Nginx 服务器 |
| **目的** | 解决开发跨域、快速联调 | 反向代理、负载均衡、静态资源服务 |
| **是否打包进产物** | ❌ 不会 | ✅ 是最终配置 |
| **性能** | 一般 (Node.js) | 优秀 (C 语言编写) |
| **热更新** | ✅ 支持 | ❌ 不支持 |

---

### 实际工作流程




**已查看文件** *run-dev.sh*

**已查看文件** *start-local.sh*


完美！现在看脚本就清楚了：

### 两种启动方式对比

#### 🔧 **开发模式** (`./scripts/run-dev.sh`)
```bash
# 启动流程：
1. 启动 Spring Boot (内嵌 Tomcat) → localhost:8081
2. 启动 Umi Dev Server → localhost:8000
3. 前端 proxy 生效：/api → http://localhost:8081/backend/api
```


**此时：**
- ❌ **不使用 Nginx**
- ✅ 使用前端配置的 proxy
- 📝 代码修改自动热更新

---

#### 🚀 **生产模式** (`./scripts/start-local.sh`)
```bash
# 启动流程：
1. 构建前端 → frontend/dist/ (静态文件)
2. 打包后端 → backend.war → tomcat/webapps/
3. 启动系统 Nginx → 监听 8088
4. 启动外置 Tomcat → 监听 8080
5. Nginx 配置生效：
   - / → 返回 frontend/dist/index.html
   - /api → 代理到 http://localhost:8080/backend/api
```


**此时：**
- ✅ **使用 Nginx 反向代理**
- ❌ 前端 proxy 不生效（已打包成静态文件）
- 📦 部署的是编译后的产物

---

### 为什么这样设计？

#### 问题场景：如果只用 Nginx 做开发

```bash
# 每次改代码都要：
1. npm run build          # 重新打包前端 (慢)
2. cp dist/* /usr/share/nginx/html/  # 复制到 Nginx 目录
3. sudo nginx -s reload   # 重载 Nginx
4. 刷新浏览器             # 才能看到效果
```

😱 **太麻烦了！开发效率极低！**

#### 解决方案：开发用 Node.js，生产用 Nginx

```typescript
// 开发时 (.umirc.ts)
proxy: { '/api': { target: 'http://localhost:8081' } }
// ✅ 改代码立即生效，无需打包
// ✅ 自动解决跨域

// 生产时 (nginx.conf)
location /api {
    proxy_pass http://localhost:8080/backend;
}
// ✅ 高性能处理静态资源
// ✅ 负载均衡、SSL、缓存等高级功能
```


---

### 总结

| 阶段 | 谁来代理 | 配置文件 | 优点 |
|------|---------|---------|------|
| **开发** | Umi Dev Server (Node.js) | `.umirc.ts` | 热更新、快速迭代 |
| **生产** | Nginx | `nginx/conf.d/default.conf` | 高性能、高可用 |

**核心思想：**
- 开发追求**效率** → 用 Node.js 代理
- 生产追求**性能** → 用 Nginx 代理

这就是为什么会有两套配置的原因！🎯