/**
 * 首页组件单元测试。
 * 
 * 测试目标：
 * 1. 验证页面正确渲染标题和描述
 * 2. 验证项目结构说明正确显示
 * 3. 验证导航链接存在且指向正确路径
 */

import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import HomePage from '../pages/index';

// Mock umi 模块
// 注意：vi.mock 的工厂函数会被提升到文件顶部，因此不能引用外部变量，
// 必须直接在工厂函数内定义 mock 组件。
vi.mock('umi', () => ({
  Link: ({ to, children }: { to: string; children: React.ReactNode }) => (
    <a href={to}>{children}</a>
  ),
}));

describe('HomePage Component', () => {
  it('应该正确渲染页面标题', () => {
    render(<HomePage />);
    
    const heading = screen.getByRole('heading', { level: 1 });
    expect(heading).toBeInTheDocument();
    expect(heading).toHaveTextContent('🎉 Nginx + Tomcat 学习示例');
  });

  it('应该包含项目介绍文本', () => {
    render(<HomePage />);
    
    const description = screen.getByText(/这是一个用于学习 Nginx 反向代理、静态资源服务以及 Tomcat 部署的示例项目/);
    expect(description).toBeInTheDocument();
  });

  it('应该显示项目结构说明', () => {
    render(<HomePage />);
    
    const structureHeading = screen.getByRole('heading', { level: 2, name: /项目结构/i });
    expect(structureHeading).toBeInTheDocument();
    
    // 验证关键技术栈说明（使用更精确的选择器，避免标题/描述中的重复文本造成歧义）
    const listItems = screen.getAllByRole('listitem');
    expect(listItems).toHaveLength(4);
    expect(listItems[0]).toHaveTextContent(/前端/i);
    expect(listItems[1]).toHaveTextContent(/后端/i);
    expect(listItems[2]).toHaveTextContent(/Nginx/i);
    expect(listItems[3]).toHaveTextContent(/Tomcat/i);
  });

  it('应该包含技术栈详细说明', () => {
    render(<HomePage />);
    
    // 验证前端技术栈
    const frontendText = screen.getByText(/UmiJS 4 \+ React/i);
    expect(frontendText).toBeInTheDocument();
    
    // 验证后端技术栈
    const backendText = screen.getByText(/Spring Boot 3 \+ Java 17/i);
    expect(backendText).toBeInTheDocument();
    
    // 验证 Nginx 配置说明
    const nginxText = screen.getByText(/监听 80 端口/i);
    expect(nginxText).toBeInTheDocument();
    
    // 验证 Tomcat 配置说明
    const tomcatText = screen.getByText(/监听 8080 端口/i);
    expect(tomcatText).toBeInTheDocument();
  });

  it('应该显示"开始体验"部分', () => {
    render(<HomePage />);
    
    const experienceHeading = screen.getByRole('heading', { level: 2, name: /开始体验/i });
    expect(experienceHeading).toBeInTheDocument();
  });

  it('应该包含跳转到用户页面的链接', () => {
    render(<HomePage />);
    
    const link = screen.getByRole('link', { name: /点击查看用户列表/i });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', '/user');
  });

  it('应该使用正确的样式', () => {
    const { container } = render(<HomePage />);
    
    // 页面根容器是 <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
    const rootDiv = container.firstElementChild as HTMLElement;
    expect(rootDiv).toHaveStyle('padding: 24px');
    expect(rootDiv).toHaveStyle('font-family: system-ui, sans-serif');
  });

  it('应该包含完整的项目架构列表项', () => {
    render(<HomePage />);
    
    // 验证四个主要组件都被提及
    const listItems = screen.getAllByRole('listitem');
    expect(listItems).toHaveLength(4);
    
    // 验证每个列表项包含 strong 标签
    listItems.forEach((item) => {
      expect(item.querySelector('strong')).toBeInTheDocument();
    });
  });

  it('应该是纯展示组件，不包含交互元素（除了链接）', () => {
    render(<HomePage />);
    
    // 验证没有按钮
    const buttons = screen.queryAllByRole('button');
    expect(buttons).toHaveLength(0);
    
    // 验证没有输入框
    const inputs = screen.queryAllByRole('textbox');
    expect(inputs).toHaveLength(0);
  });
});
