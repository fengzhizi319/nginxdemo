# 前端项目架构说明

## 📋 目录

- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [文件详解](#文件详解)
- [开发流程](#开发流程)
- [构建与部署](#构建与部署)
- [与 Nginx 的协作](#与-nginx-的协作)
- [首页个性化设计文档](../docs/11-前端首页个性化设计.md)

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
│   ├── components/           # 可复用展示组件
│   │   └── Home/             # 首页相关组件
│   │       ├── HeroSection.tsx
│   │       ├── FeatureList.tsx
│   │       ├── CtaSection.tsx
│   │       └── *.module.css  # 各组件对应的 CSS Modules
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

  // 使用 style-loader 注入 CSS，避免生产环境异步加载 CSS chunk 导致页面空白
  styleLoader: {},
});
```

**学习要点**：
- `history: { type: 'browser' }` 使 URL 更美观（如 `/user` 而非 `/#/user`），但需要 Nginx 配置 `try_files $uri $uri/ /index.html;` 否则刷新会 404
- `proxy` 仅在开发环境生效，生产环境由 Nginx 处理反向代理
- `styleLoader: {}` 让 CSS Modules 的样式随 JS 一起注入到 `<style>` 标签中，避免生产环境异步加载 CSS chunk 导致首页空白

---

### 2️⃣ `src/app.ts` - Umi 运行时配置

**作用**：Umi 4 约定式的运行时配置入口，可配置全局初始化、路由守卫等。

**当前实现**：
```typescript
/**
 * UmiJS 的运行时配置文件。
 *
 * 注意：不要导出 Umi 不认识的 key，否则生产构建运行时会报错
 *       "register failed, invalid key xxx"，导致页面空白。
 */
// 应用首次渲染前可以在这里执行初始化逻辑
// export const onInitialStateChange = () => {
//   // 示例：可以在这里打印日志或做权限校验
// };
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
import HeroSection from '@/components/Home/HeroSection';
import FeatureList from '@/components/Home/FeatureList';
import CtaSection from '@/components/Home/CtaSection';

const features = [
  { icon: '💻', title: '前端', description: 'UmiJS 4 + React，被 Nginx 托管为静态资源。' },
  { icon: '⚙️', title: '后端', description: 'Spring Boot 3 + Java 17，以 WAR 包形式部署到 Tomcat。' },
  { icon: '🌐', title: 'Nginx', description: '监听 80 端口，静态文件直接返回，/api 请求转发给 Tomcat。' },
  { icon: '🐱', title: 'Tomcat', description: '监听 8080 端口，运行 backend.war。' },
];

export default function HomePage() {
  return (
    <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
      <HeroSection
        title="🎉 Nginx + Tomcat 学习示例"
        description="这是一个用于学习 Nginx 反向代理、静态资源服务以及 Tomcat 部署的示例项目。"
      />
      <FeatureList heading="项目结构" items={features} />
      <CtaSection heading="开始体验" linkTo="/user" linkText="点击查看用户列表 →" />
    </div>
  );
}
```

**学习要点**：
- Umi 约定式路由：文件名即路由路径
- `Link` 组件实现 SPA 内部跳转，不触发整页刷新
- 页面拆分为 `HeroSection`、`FeatureList`、`CtaSection` 三个组件，职责单一、便于维护
- 组件样式使用 **CSS Modules**（`*.module.css`），类名局部作用域，避免全局污染

**详细设计文档**：参见 `docs/11-前端首页个性化设计.md`

---

### 5️⃣ `src/components/Home/` - 首页展示组件

**作用**：封装首页的可复用展示组件与对应样式，实现视觉分层和个性化设计。

**组件清单**：

| 组件 | 文件 | 说明 |
|------|------|------|
| `HeroSection` | `HeroSection.tsx` + `HeroSection.module.css` | 首屏渐变 Hero 区域，展示标题和简介 |
| `FeatureList` | `FeatureList.tsx` + `FeatureList.module.css` | 项目结构卡片列表，使用 `<ul>` / `<li>` 语义化结构 |
| `CtaSection` | `CtaSection.tsx` + `CtaSection.module.css` | 行动召唤区域，将 `<Link>` 装扮成胶囊按钮 |

**设计要点**：
- 每个组件对应一个 `.module.css` 文件，Umi 4 原生支持 CSS Modules。
- 样式涵盖渐变背景、卡片阴影、悬停上浮、响应式 Grid、入场动画等。
- 组件 props 保持简单，方便在 `index.tsx` 中组合和扩展。

**学习要点**：
- CSS Modules 让类名局部化，避免全局样式冲突。
- 展示组件只负责 UI，数据由页面组件传入，符合 React 单向数据流思想。

---

### 6️⃣ `src/pages/user.tsx` - 用户管理页

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

### 7️⃣ `package.json` - 项目配置

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

### 8️⃣ `tsconfig.json` - TypeScript 配置

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
✅ **SPA 最佳实践**：History 路由、路由懒加载、错误处理  

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


## 浏览器的跨域阻止机制（CORS - Cross-Origin Resource Sharing）

### 同源策略（Same-Origin Policy）

浏览器有一个核心安全机制叫**同源策略**，要求：

- **协议**相同
- **域名**相同
- **端口**相同

三者必须**完全一致**才算"同源"，否则就是"跨域"。

### 🎯 项目中的跨域场景

#### 开发环境（没有 proxy 时会怎样？）

```javascript
// 前端运行在: http://localhost:8000
// 后端运行在: http://localhost:8081

// 前端代码发起请求
fetch('http://localhost:8081/backend/api/users')
```


**浏览器会阻止！** ❌

---

### 🔍 为什么会被阻止？

#### 同源检查

| 维度 | 前端页面    | 后端 API    | 是否相同？ |
| ---- | ----------- | ----------- | ---------- |
| 协议 | `http`      | `http`      | ✅ 相同     |
| 域名 | `localhost` | `localhost` | ✅ 相同     |
| 端口 | `8000`      | `8081`      | ❌ **不同** |

**结论**: 端口不同 → **跨域** → 浏览器阻止！

---

### 🛡️ 浏览器的拦截过程

#### 1. 简单请求（Simple Request）

```javascript
// 前端发起 GET 请求
fetch('/api/users')  // 实际指向 http://localhost:8081/backend/api/users
```


**浏览器行为：**

```
1. 发送请求到后端
2. 后端返回数据
3. 浏览器检查响应头是否有 CORS 许可
4. 如果没有 → 阻止前端代码获取数据 ❌
5. 控制台报错：
   "Access to fetch at 'http://localhost:8081/...' 
    from origin 'http://localhost:8000' has been blocked by CORS policy"
```


**注意**: 请求**实际上已经到达后端**了，但浏览器不让前端拿到响应！

---

#### 2. 预检请求（Preflight Request）

对于复杂请求（POST with JSON、PUT、DELETE 等），浏览器会先发一个"试探"：

```javascript
// 前端发起 POST 请求
fetch('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: '张三' })
})
```


**浏览器行为：**

```
步骤1: 发送 OPTIONS 预检请求
  → OPTIONS /api/users HTTP/1.1
  → Origin: http://localhost:8000
  → Access-Control-Request-Method: POST
  → Access-Control-Request-Headers: Content-Type

步骤2: 等待后端响应
  ← 如果后端返回正确的 CORS 头:
     Access-Control-Allow-Origin: http://localhost:8000
     Access-Control-Allow-Methods: POST, GET, OPTIONS
     Access-Control-Allow-Headers: Content-Type
  
步骤3: 判断是否允许
  ✅ 允许 → 发送真正的 POST 请求
  ❌ 不允许 → 直接阻止，不发送 POST
```


---

### ✅ 解决方案对比

#### 方案1: 前端 Proxy（本项目采用）

```typescript
// frontend/.umirc.ts
proxy: {
  '/api': {
    target: 'http://127.0.0.1:8081/backend',
    changeOrigin: true,
  }
}
```


**工作原理：**

```
浏览器认为自己在访问同源服务器:
  fetch('/api/users')
    ↓
  发送到: http://localhost:8000/api/users (同源，不会跨域)
    ↓
  Umi Dev Server 拦截并转发:
    http://localhost:8000/api/users 
    → http://localhost:8081/backend/api/users
    ↓
  后端返回数据
    ↓
  Dev Server 转发回前端
    ↓
  浏览器收到响应 ✅ (因为浏览器认为是同源请求)
```


**优点：**

- ✅ 前端代码无需修改
- ✅ 不需要后端配置 CORS
- ✅ 对浏览器完全透明

---

#### 方案2: 后端配置 CORS

```java
// Spring Boot 后端添加 CORS 配置
@RestController
@CrossOrigin(origins = "http://localhost:8000")  // 允许前端域名
public class UserController {
    @GetMapping("/api/users")
    public List<User> getUsers() {
        return userService.findAll();
    }
}
```


或者全局配置：

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:8000")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("*");
    }
}
```


**工作原理：**

```
浏览器发送请求:
  fetch('http://localhost:8081/backend/api/users')
    ↓
  后端返回时带上 CORS 头:
    Access-Control-Allow-Origin: http://localhost:8000
    ↓
  浏览器检查通过 ✅
  前端拿到数据
```


---

#### 方案3: Nginx 反向代理（生产环境）

```nginx
# nginx/conf.d/default.conf
server {
  listen 8088;
  
  # 前端和后端都通过同一个端口访问
  location / {
    root /usr/share/nginx/html;
  }
  
  location /api {
    proxy_pass http://127.0.0.1:8080/backend;
    # 添加 CORS 头（如果需要）
    add_header Access-Control-Allow-Origin *;
  }
}
```


**工作原理：**

```
用户访问: http://example.com:8088
  ↓
前端页面加载自: http://example.com:8088/index.html
  ↓
前端请求: fetch('/api/users')
  → 实际访问: http://example.com:8088/api/users
  ↓
Nginx 内部转发到: http://127.0.0.1:8080/backend/api/users
  ↓
对于浏览器来说，始终是同源请求 ✅
```


---

### 📊 三种方案对比

| 方案           | 适用场景  | 优点               | 缺点         |
| -------------- | --------- | ------------------ | ------------ |
| **前端 Proxy** | 开发环境  | 配置简单，不改代码 | 仅开发有效   |
| **后端 CORS**  | 开发+生产 | 前后端分离部署     | 需要后端配合 |
| **Nginx 代理** | 生产环境  | 性能最好，统一入口 | 需要额外配置 |

---

### 🧪 实验验证

你可以做个实验看看跨域错误：

```bash
# 1. 临时注释掉 proxy 配置
# frontend/.umirc.ts
/*
proxy: {
  '/api': {
    target: 'http://127.0.0.1:8081/backend',
  }
}
*/

# 2. 启动开发服务
./scripts/run-dev.sh

# 3. 打开浏览器控制台 (F12)
# 你会看到类似这样的错误:
# Access to fetch at 'http://localhost:8081/backend/api/users' 
# from origin 'http://localhost:8000' has been blocked by CORS policy: 
# No 'Access-Control-Allow-Origin' header is present on the requested resource.
```


---

### 💡 核心总结

1. **跨域是浏览器的安全机制**，不是服务器的限制
2. **请求可能已经到达后端**，但浏览器不让前端拿响应
3. **Proxy 的本质**是让浏览器认为自己在访问同源服务器
4. **生产环境通常用 Nginx**，既解决跨域又提升性能

这就是为什么本项目在开发时用前端 proxy，生产时用 Nginx 代理的原因！🎯
## 生产环境的跨域问题
### 🎯 关键区别：浏览器眼中的"源"
#### 开发环境（会跨域）❌

```
前端页面地址: http://localhost:8000/index.html
后端 API 地址: http://localhost:8081/backend/api/users

浏览器检查:
- 前端端口: 8000
- 后端端口: 8081
- ❌ 端口不同 → 跨域！
```


---

#### 生产环境（不会跨域）✅

```nginx
# Nginx 监听 8088 端口
server {
    listen 8088;
    
    # 前端静态文件
    location / {
        root /home/charles/code/nginxdemo/frontend/dist;
    }
    
    # 后端 API 代理
    location /api/ {
        proxy_pass http://backend_servers/backend/api/;
    }
}
```


**用户访问流程：**
```
1. 用户在浏览器输入: http://example.com:8088
   ↓
2. 加载前端页面: http://example.com:8088/index.html
   （Nginx 返回 frontend/dist/index.html）
   ↓
3. 前端发起请求: fetch('/api/users')
   实际访问: http://example.com:8088/api/users
   ↓
4. Nginx 内部转发到: http://127.0.0.1:8080/backend/api/users
   （Tomcat 处理并返回结果）
   ↓
5. Nginx 把响应返回给浏览器
```


**浏览器检查：**
```
- 页面来源: http://example.com:8088
- API 地址: http://example.com:8088/api/users
- ✅ 协议、域名、端口完全相同 → 同源！
```


---

### 🔑 核心原理

#### 对浏览器来说，它只知道 Nginx

```javascript
// 前端代码 (api.ts)
const BASE_URL = '/api';  // 相对路径

fetch('/api/users')
// 浏览器实际请求的是: http://当前域名:8088/api/users
// 浏览器根本不知道后面有 Tomcat！
```


**关键点：**
1. **前端页面**从 `http://example.com:8088` 加载
2. **API 请求**也发送到 `http://example.com:8088`
3. 对于浏览器，这是**同一个源**（同源）
4. Nginx 内部的转发逻辑，浏览器**完全不可见**

---

### 📊 对比总结

| 维度 | 开发环境（无 proxy） | 生产环境（Nginx） |
|------|-------------------|------------------|
| 前端地址 | `http://localhost:8000` | `http://example.com:8088` |
| API 地址 | `http://localhost:8081/backend/api` | `http://example.com:8088/api` |
| 浏览器视角 | ❌ 不同端口 → 跨域 | ✅ 同一端口 → 同源 |
| 是否需要 CORS | 需要（proxy 或后端配置） | 不需要 |
| 后端是否暴露 | 直接暴露给浏览器 | 隐藏在 Nginx 后面 |

---

### 🏗️ 架构示意

#### 开发环境（跨域问题）
```
┌─────────────┐
│   Browser   │  localhost:8000 (前端)
│             │  localhost:8081 (后端) ← 不同端口！
└─────────────┘
     ↑    ↑
     │    └── 直接访问后端 → 跨域 ❌
     └── Dev Server (proxy 解决)
```


#### 生产环境（同源）
```
┌─────────────┐
│   Browser   │  example.com:8088 (唯一入口)
└──────┬──────┘
       │
       ↓
┌─────────────┐
│    Nginx    │  :8088 统一监听
│             │
│  /          │ → 返回前端静态文件
│  /api/*     │ → 反向代理到 Tomcat
└──────┬──────┘
       │
       ↓
┌─────────────┐
│   Tomcat    │  :8080 (后端，不对外暴露)
└─────────────┘
```


**重点：**
- 浏览器只看到 **一个服务器** (`example.com:8088`)
- 所有的路由和转发都在 **Nginx 内部**完成
- 后端的真实地址对浏览器是**透明的**

---

### 💡 类比理解

想象你去一家餐厅：

#### 开发环境 = 分开点餐
```
你(浏览器):
- 在前台(8000)点主食
- 要去后厨(8081)拿饮料
→ 前台说："你不能直接进后厨！"（跨域阻止）
```


#### 生产环境 = 统一服务
```
你(浏览器):
- 在前台(8088)点所有东西
- 服务员内部协调厨房和吧台
→ 你拿到所有东西，不用关心从哪里来
→ 对你来说，只有一个服务窗口（同源）✅
```


---

### 🧪 验证方法

你可以打开浏览器的开发者工具验证：

```javascript
// 在生产环境打开控制台
console.log(window.location.origin);  
// 输出: "http://example.com:8088"

// 发起请求
fetch('/api/users').then(r => r.json()).then(console.log);
// 请求 URL: http://example.com:8088/api/users
// ✅ 同源，不会有跨域错误
```


---

### 总结

**生产环境不跨域的原因：**
1. ✅ 前端和后端都通过 **同一个 Nginx 端口**访问
2. ✅ 浏览器认为自己在访问**同一个服务器**
3. ✅ Nginx 的内部转发对浏览器**透明**
4. ✅ 本质上就是**同源请求**，不是跨域

这就是为什么生产环境用 Nginx 既解决了跨域问题，又提升了性能！🎯
好问题！让我解释 Nginx 在生产环境中的运行位置和可见性。

## 🖥️ Nginx 在生产环境中的运行位置和可见性

### Nginx 运行在**服务器端**（不是浏览器）

```
┌──────────────────────────────────────────────┐
│              你的电脑（客户端）                 │
│                                              │
│  ┌──────────┐                                │
│  │ 浏览器    │  Chrome/Firefox/Safari         │
│  └────┬─────┘                                │
└───────┼──────────────────────────────────────┘
        │
        │ HTTP 请求 (TCP/IP 网络)
        │
        ↓
┌──────────────────────────────────────────────┐
│              服务器（远程机器）                  │
│                                              │
│  ┌──────────┐    ┌──────────┐                │
│  │  Nginx   │───→│  Tomcat  │                │
│  │  :8088   │    │  :8080   │                │
│  └──────────┘    └──────────┘                │
│                                              │
└──────────────────────────────────────────────┘
```


---

### 🔍 "浏览器看不见"是什么意思？

这里的"看不见"是指：

#### ✅ **浏览器能看到 Nginx 的响应**
```javascript
// 浏览器发起请求
fetch('http://example.com:8088/api/users')
  .then(res => res.json())
  .then(data => console.log(data));  // ✅ 能收到数据

// 这个数据就是 Nginx 返回的
```


#### ❌ **浏览器看不到 Nginx 的内部逻辑**
```
浏览器知道的：
- 我发送了 GET /api/users
- 我收到了 JSON 数据
- 服务器地址是 example.com:8088

浏览器不知道的：
- ❓ Nginx 把请求转发给了谁
- ❓ 后端有几个 Tomcat 实例
- ❓ 真实的后端地址是什么
- ❓ Nginx 内部的路由规则
```


---

### 🌐 实际部署场景
#### 场景1：本地学习（本项目）

```bash
# Nginx 作为系统服务运行
sudo systemctl start nginx

# 查看 Nginx 状态
sudo systemctl status nginx
```


**Nginx 运行在：**
- 你的 WSL (Ubuntu) 系统中
- 作为后台守护进程（daemon）
- 监听 8088 端口

---

### 场景2：真实生产环境

```
用户浏览器                    云服务器 (如阿里云/AWS)
┌──────────┐                 ┌─────────────────────┐
│          │   Internet      │                     │
│ Chrome   │ ←────────────→ │  Nginx (:80)        │
│          │   HTTPS         │    ↓                │
└──────────┘                 │  Tomcat (:8080)     │
                             └─────────────────────┘
```


**Nginx 运行在：**
- 云服务器的 Linux 系统上
- 通过 systemd 管理 (`systemctl start nginx`)
- 可能还有负载均衡器在前面

---

### 🔬 浏览器能看到什么 vs 看不到什么

#### ✅ 浏览器能看到的（HTTP 层面）

打开浏览器开发者工具（F12）→ Network 标签：

```
Request URL: http://example.com:8088/api/users
Request Method: GET
Status Code: 200 OK
Remote Address: example.com:8088

Response Headers:
  Content-Type: application/json
  Server: nginx/1.24.0  ← 可以看到是 Nginx
  Date: Thu, 25 Jun 2026 10:00:00 GMT
  
Response Body:
  [{"id":1,"name":"张三"},{"id":2,"name":"李四"}]
```


**这些信息是可见的：**
- 请求的 URL
- 响应状态码
- 响应头（包括 `Server: nginx`）
- 响应数据

---

#### ❌ 浏览器看不到的（服务器内部）

```nginx
# Nginx 配置文件（浏览器完全不知道）
location /api/ {
    proxy_pass http://backend_servers/backend/api/;  # ← 隐藏！
    
    # 这些配置浏览器也看不到
    proxy_set_header Host $host;
    proxy_connect_timeout 30;
}

upstream backend_servers {
    server 127.0.0.1:8080 weight=1;  # ← 后端真实地址隐藏！
    server 127.0.0.1:8081 weight=1;  # ← 负载均衡细节隐藏！
}
```


**这些信息被隐藏：**
- 后端的真实 IP 和端口
- 有多少个后端服务器
- 负载均衡策略
- 内部转发规则
- 超时时间等配置

---

### 🎭 类比理解

#### Nginx 就像餐厅的服务员

```
你(浏览器) → 服务员(Nginx) → 厨房(Tomcat)

你能看到服务员：
✅ 穿着制服（Server: nginx 响应头）
✅ 给你送餐（返回响应数据）
✅ 站在前台（监听 8088 端口）

你看不到：
❌ 厨房里有几个厨师（后端实例数量）
❌ 厨师的真实姓名（后端服务器 IP）
❌ 厨房的内部布局（Nginx 配置）
❌ 点餐系统的操作方式（proxy_pass 规则）
```


---

### 🛡️ 为什么这种"看不见"很重要？

#### 1. **安全性**
```
如果浏览器能看到后端地址：
fetch('http://example.com:8088/api/users')
  ↓
攻击者可以直接访问：
http://192.168.1.100:8080/backend/api/users  ← 绕过安全控制！
```


#### 2. **架构灵活性**
```nginx
# 可以随时修改后端架构，前端无感知
upstream backend_servers {
    # 今天：1 台服务器
    server 127.0.0.1:8080;
    
    # 明天：改成 3 台，前端代码不用改
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}
```


#### 3. **统一入口**
```
对用户来说：
- 只需要知道一个域名：example.com:8088
- 不需要关心后端有几个服务
- 不需要处理跨域问题
```


---

### 📊 总结对比

| 维度 | 浏览器的视角 | 实际发生的事 |
|------|------------|------------|
| **Nginx 位置** | "一个远程服务器" | 运行在你的 WSL/云服务器上 |
| **请求目标** | `http://example.com:8088/api/users` | Nginx 接收并转发 |
| **后端地址** | 不知道（透明） | `http://127.0.0.1:8080/backend/api/users` |
| **跨域问题** | 同源请求 | Nginx 统一了入口 |
| **架构细节** | 看不到 | 可能有多个 Tomcat、数据库等 |

---

### 💡 核心要点

1. **Nginx 运行在服务器端**（WSL、云服务器等）
2. **"看不见"指的是内部逻辑对浏览器透明**
3. **浏览器能看到 Nginx 的响应，但不知道背后的架构**
4. **这种隔离提供了安全性和灵活性**

就像一个黑盒：你输入请求，得到响应，但不知道里面发生了什么。这就是反向代理的价值！🎯