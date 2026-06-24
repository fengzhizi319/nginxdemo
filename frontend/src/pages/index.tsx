import { Link } from 'umi';

/**
 * 首页组件。
 *
 * 学习点：
 * 1. Umi 4 使用约定式路由：src/pages/index.tsx 自动映射到根路径 '/'。
 * 2. Link 组件来自 umi，用于单页应用内部跳转，不会触发整页刷新。
 * 3. 页面会被 Nginx 作为静态资源直接返回，只有 /api 请求会转发到 Tomcat。
 */
export default function HomePage() {
  return (
    <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
      <h1>🎉 Nginx + Tomcat 学习示例</h1>
      <p>
        这是一个用于学习 Nginx 反向代理、静态资源服务以及 Tomcat 部署的示例项目。
      </p>
      <h2>项目结构</h2>
      <ul>
        <li>
          <strong>前端</strong>：UmiJS 4 + React，被 Nginx 托管为静态资源。
        </li>
        <li>
          <strong>后端</strong>：Spring Boot 3 + Java 17，以 WAR 包形式部署到 Tomcat。
        </li>
        <li>
          <strong>Nginx</strong>：监听 80 端口，静态文件直接返回，/api 请求转发给 Tomcat。
        </li>
        <li>
          <strong>Tomcat</strong>：监听 8080 端口，运行 backend.war。
        </li>
      </ul>
      <h2>开始体验</h2>
      <p>
        <Link to="/user" style={{ fontSize: 18, color: '#1890ff' }}>
          点击查看用户列表 →
        </Link>
      </p>
    </div>
  );
}
