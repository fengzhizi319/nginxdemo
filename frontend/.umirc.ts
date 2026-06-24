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

  // 路由基础路径
  base: '/',

  // 静态资源公共路径
  publicPath: '/',

  // 使用浏览器路由（History 模式）
  history: { type: 'browser' },

  // 开发时代理：把 /api 开头的请求转发到 Tomcat 上的后端
  proxy: {
    '/api': {
      target: 'http://127.0.0.1:8080/backend',
      changeOrigin: true,
      // pathRewrite 把 /api 重写为空，因为后端接口前缀已经是 /api
      pathRewrite: { '^/api': '/api' },
    },
  },

  // 构建产物目录，Nginx 会把该目录作为静态资源根目录
  outputPath: 'dist',
});
