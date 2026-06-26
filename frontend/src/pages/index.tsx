import HeroSection from '@/components/Home/HeroSection';
import FeatureList from '@/components/Home/FeatureList';
import CtaSection from '@/components/Home/CtaSection';

/**
 * 首页组件。
 *
 * 学习点：
 * 1. Umi 4 使用约定式路由：src/pages/index.tsx 自动映射到根路径 '/'。
 * 2. Link 组件来自 umi，用于单页应用内部跳转，不会触发整页刷新。
 * 3. 页面会被 Nginx 作为静态资源直接返回，只有 /api 请求会转发到 Tomcat。
 * 4. 通过拆分 HeroSection / FeatureList / CtaSection 组件，并用 CSS Modules 修饰，
 *    实现更现代、更易维护的首页界面。
 */

// 项目结构数据：保持 4 个条目，分别对应前端、后端、Nginx、Tomcat
const features = [
  {
    icon: '💻',
    title: '前端',
    description: 'UmiJS 4 + React，被 Nginx 托管为静态资源。',
  },
  {
    icon: '⚙️',
    title: '后端',
    description: 'Spring Boot 3 + Java 17，以 WAR 包形式部署到 Tomcat。',
  },
  {
    icon: '🌐',
    title: 'Nginx',
    description: '监听 80 端口，静态文件直接返回，/api 请求转发给 Tomcat。',
  },
  {
    icon: '🐱',
    title: 'Tomcat',
    description: '监听 8080 端口，运行 backend.war。',
  },
];

export default function HomePage() {
  return (
    // 保留外层 div 的内联样式，确保现有测试与视觉一致性
    <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
      <HeroSection
        title="🎉 Nginx + Tomcat 学习示例"
        description="这是一个用于学习 Nginx 反向代理、静态资源服务以及 Tomcat 部署的示例项目。"
      />
      <FeatureList heading="项目结构" items={features} />
      <CtaSection
          heading="开始体验"
          linkTo="/user"
          linkText="点击查看用户列表 →"
          onButtonClick={(e) => {
            console.log('来自父组件的自定义逻辑');
            // 可以发送埋点、显示提示等
            //   e.preventDefault();  // 手动阻止
            //   console.log('阻止跳转');
          }}
      />
    </div>
  );
}
