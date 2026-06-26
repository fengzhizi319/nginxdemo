import { defineConfig } from 'umi';

/**
 * UmiJS 4 的配置文件。
 *
 * 学习点：
 * 1. defineConfig 提供类型提示，避免配置写错。
 * 2. base: '/' 表示应用部署在域名根路径。如果部署在子目录，需要改成 '/子目录/'。
 * 3. publicPath: '/' 表示打包后静态资源从根路径加载。
 * 4. history: { type: 'browser' } 使用 HTML5 History 模式，路由没有 # 号，
 *    但需要 Nginx 配置 fallback 到 index.html，否则刷新会 404。
 * 5. proxy 仅在开发时生效，把 /api 转发到本地启动的后端，解决开发跨域。
 */
export default defineConfig({
  // 应用名称
  title: 'Nginx + Tomcat 学习示例',

  /**
    // 路由基础路径
    // 场景1: 部署在域名根路径
    base: '/'
  // URL: https://example.com/user → 正常访问

  // 场景2: 部署在子目录
    base: '/myapp/'
  // URL: https://example.com/myapp/user → 正常访问
  // URL: https://example.com/user → 404
  **/
  base: '/',

  /**
   * // 场景1: 从根路径加载资源
   * publicPath: '/'
   * // HTML 中生成: <script src="/umi.js">
   *
   * // 场景2: 从 CDN 加载资源
   * publicPath: 'https://cdn.example.com/'
   * // HTML 中生成: <script src="https://cdn.example.com/umi.js">
   *
   * // 场景3: 部署在子目录
   * publicPath: '/myapp/'
   * // HTML 中生成: <script src="/myapp/umi.js">
   */
  // 静态资源公共路径
  publicPath: '/',

  // 使用浏览器路由（History 模式）
  /**
   * // 模式1: browser (HTML5 History)
   * history: { type: 'browser' }
   * // URL: https://example.com/user (干净,无 #)
   * // ⚠️ 需要 Nginx 配置:
   * // location / {
   * //   try_files $uri $uri/ /index.html;  // 刷新时 fallback
   * // }
   *
   * // 模式2: hash (带 # 号)
   * history: { type: 'hash' }
   * // URL: https://example.com/#/user (不需要特殊配置)
   * // ✅ 刷新不会 404,但 URL 不美观
   */
  history: { type: 'browser' },

  // 约定式路由排除测试文件，避免 .test.tsx 被当作页面路由打包
  conventionRoutes: {
    exclude: [/.*\.test\.[tj]sx?$/],
  },

  // JS 压缩目标：react 18 的部分依赖使用了 BigInt，需要将目标环境从默认的 es2015 提升到 es2020
  jsMinifierOptions: {
    target: 'es2020',
  },

  // 使用 style-loader 将 CSS 注入到 <style> 标签中，避免生产环境异步加载 CSS chunk
  // 导致首页样式丢失/页面空白的问题。
  styleLoader: {},

  // 开发时代理：把 /api 开头的请求转发到 Tomcat 上的后端
  /**
   * 前端配置的 proxy（仅开发时使用）
   *
   * 开发环境流程：
   * npm run dev (启动 Umi 开发服务器，端口 8000)
   *   ↓
   * 浏览器访问 http://localhost:8000
   *   ↓
   * 前端代码请求 fetch('/api/users')
   *   ↓
   * Umi 开发服务器拦截并转发到 http://127.0.0.1:8081/backend/api/users
   *   ↓
   * 后端返回数据
   *
   * 🔧 开发模式 (./scripts/run-dev.sh)
   * # 启动流程：
   * 1. 启动 Spring Boot (内嵌 Tomcat) → localhost:8081
   * 2. 启动 Umi Dev Server → localhost:8000
   * 3. 前端 proxy 生效：/api → http://localhost:8081/backend/api
   * 此时：
   * ❌ 不使用 Nginx
   * ✅ 使用前端配置的 proxy
   * 📝 代码修改自动热更新
   *
   * 🚀 生产模式 (./scripts/start-local.sh)
   * # 启动流程：
   * 1. 构建前端 → frontend/dist/ (静态文件)
   * 2. 打包后端 → backend.war → tomcat/webapps/
   * 3. 启动系统 Nginx → 监听 8088
   * 4. 启动外置 Tomcat → 监听 8080
   * 5. Nginx 配置生效：
   *    - / → 返回 frontend/dist/index.html
   *    - /api → 代理到 http://localhost:8080/backend/api
   *    此时：
   * ✅ 使用 Nginx 反向代理
   * ❌ 前端 proxy 不生效（已打包成静态文件）
   * 📦 部署的是编译后的产物
   */
  proxy: {
    '/api': {
      // 开发模式下后端使用嵌入 Tomcat，端口为 8081（见 backend/src/main/resources/application.yml）
      // 如果使用外置 Tomcat（scripts/start-local.sh），请将 target 改为 'http://127.0.0.1:8080/backend'
      target: 'http://127.0.0.1:8081/backend',
      changeOrigin: true,
      // pathRewrite 把 /api 重写为空，因为后端接口前缀已经是 /api
      pathRewrite: { '^/api': '/api' },
    },
  },

  // 构建产物目录，Nginx 会把该目录作为静态资源根目录
  outputPath: 'dist',
});
