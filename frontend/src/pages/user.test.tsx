/**
 * 用户管理页面单元测试。
 * 
 * 测试目标：
 * 1. 验证页面初始渲染和加载状态
 * 2. 验证用户列表正确显示
 * 3. 验证表单交互和数据提交
 * 4. 验证错误处理
 */

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import UserPage from '../pages/user';
import * as api from '../services/api';

// Mock umi Link 组件
// 注意：vi.mock 的工厂函数会被提升到文件顶部，因此不能引用外部变量，
// 必须直接在工厂函数内定义 mock 组件。
vi.mock('umi', () => ({
  Link: ({ to, children }: { to: string; children: React.ReactNode }) => (
    <a href={to}>{children}</a>
  ),
}));

// Mock API 模块
vi.mock('../services/api', () => ({
  get: vi.fn(),
  post: vi.fn(),
}));

describe('UserPage Component', () => {
  const mockUsers = [
    { id: 1, name: '张三', age: 25 },
    { id: 2, name: '李四', age: 30 },
    { id: 3, name: '王五', age: 28 },
  ];

  beforeEach(() => {
    vi.clearAllMocks();
    // 默认让初始加载返回空数组，避免不关心初始数据的测试触发意外状态更新和警告。
    // 需要特定数据的测试可以单独覆盖此 mock。
    (api.get as any).mockResolvedValue([]);
  });

  // 辅助函数：渲染页面并等待初始加载完成，消除 React act() 警告
  const renderAndWaitForInitialLoad = async () => {
    const result = render(<UserPage />);
    await waitFor(() => {
      expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
    });
    return result;
  };

  describe('初始渲染和加载状态', () => {
    it('应该在加载时显示加载文本', async () => {
      // Mock API 延迟响应
      (api.get as any).mockImplementation(() => 
        new Promise((resolve) => setTimeout(() => resolve(mockUsers), 100))
      );

      render(<UserPage />);
      
      // 验证加载状态
      expect(screen.getByText(/加载中/i)).toBeInTheDocument();
      
      // 等待数据加载完成
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
    });

    it('应该在数据加载完成后显示用户列表', async () => {
      (api.get as any).mockResolvedValue(mockUsers);

      render(<UserPage />);
      
      // 等待数据加载
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });

      // 验证表格标题
      expect(screen.getByRole('heading', { level: 2, name: /用户列表/i })).toBeInTheDocument();
      
      // 验证表头
      expect(screen.getByText('ID')).toBeInTheDocument();
      expect(screen.getByText('姓名')).toBeInTheDocument();
      expect(screen.getByText('年龄')).toBeInTheDocument();
    });
  });

  describe('用户列表渲染', () => {
    it('应该正确渲染所有用户数据', async () => {
      (api.get as any).mockResolvedValue(mockUsers);

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });

      // 验证每个用户都显示
      expect(screen.getByText('张三')).toBeInTheDocument();
      expect(screen.getByText('25')).toBeInTheDocument();
      expect(screen.getByText('李四')).toBeInTheDocument();
      expect(screen.getByText('30')).toBeInTheDocument();
      expect(screen.getByText('王五')).toBeInTheDocument();
      expect(screen.getByText('28')).toBeInTheDocument();
    });

    it('应该在空列表时显示空表格', async () => {
      (api.get as any).mockResolvedValue([]);

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });

      // 表格应该存在但没有数据行
      const table = screen.getByRole('table');
      expect(table).toBeInTheDocument();
      
      // 验证表头存在
      expect(screen.getByText('ID')).toBeInTheDocument();
    });

    it('应该正确渲染表格结构', async () => {
      (api.get as any).mockResolvedValue(mockUsers);

      const { container } = render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });

      // 验证表格元素
      const table = screen.getByRole('table');
      expect(table).toHaveAttribute('border', '1');
      
      // 验证表头和表体
      const thead = container.querySelector('thead');
      const tbody = container.querySelector('tbody');
      expect(thead).toBeInTheDocument();
      expect(tbody).toBeInTheDocument();
      
      // 验证数据行数
      const rows = tbody?.querySelectorAll('tr');
      expect(rows).toHaveLength(mockUsers.length);
    });
  });

  describe('新增用户表单', () => {
    it('应该显示新增用户表单', async () => {
      await renderAndWaitForInitialLoad();
      
      expect(screen.getByRole('heading', { level: 2, name: /新增用户/i })).toBeInTheDocument();
      expect(screen.getByLabelText(/姓名：/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/年龄：/i)).toBeInTheDocument();
      expect(screen.getByRole('button', { name: /提交/i })).toBeInTheDocument();
    });

    it('应该允许输入姓名和年龄', async () => {
      await renderAndWaitForInitialLoad();
      
      const nameInput = screen.getByLabelText(/姓名：/i) as HTMLInputElement;
      const ageInput = screen.getByLabelText(/年龄：/i) as HTMLInputElement;
      
      fireEvent.change(nameInput, { target: { value: '赵六' } });
      fireEvent.change(ageInput, { target: { value: '35' } });
      
      expect(nameInput.value).toBe('赵六');
      expect(ageInput.value).toBe('35');
    });

    it('应该在提交时调用 POST API', async () => {
      const newUser = { name: '赵六', age: 35 };
      (api.get as any).mockResolvedValue([...mockUsers, { id: 4, ...newUser }]);
      (api.post as any).mockResolvedValue({ id: 4, ...newUser });

      render(<UserPage />);
      
      // 等待初始数据加载
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
      
      // 填写表单
      const nameInput = screen.getByLabelText(/姓名：/i);
      const ageInput = screen.getByLabelText(/年龄：/i);
      const submitButton = screen.getByRole('button', { name: /提交/i });
      
      fireEvent.change(nameInput, { target: { value: newUser.name } });
      fireEvent.change(ageInput, { target: { value: newUser.age.toString() } });
      fireEvent.click(submitButton);
      
      // 验证 API 被调用
      await waitFor(() => {
        expect(api.post).toHaveBeenCalledWith('/users', {
          name: newUser.name,
          age: newUser.age,
        });
      });
    });

    it('应该在提交成功后清空表单并刷新列表', async () => {
      const newUser = { name: '孙七', age: 40 };
      (api.get as any)
        .mockResolvedValueOnce(mockUsers) // 初始加载
        .mockResolvedValueOnce([...mockUsers, { id: 5, ...newUser }]); // 提交后刷新
      (api.post as any).mockResolvedValue({ id: 5, ...newUser });

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
      
      // 填写并提交
      const nameInput = screen.getByLabelText(/姓名：/i);
      const ageInput = screen.getByLabelText(/年龄：/i);
      const submitButton = screen.getByRole('button', { name: /提交/i });
      
      fireEvent.change(nameInput, { target: { value: newUser.name } });
      fireEvent.change(ageInput, { target: { value: newUser.age.toString() } });
      fireEvent.click(submitButton);
      
      // 验证表单清空
      // 注意：type="number" 的 input 在值为空时，toHaveValue 接收到的实际值为 null
      await waitFor(() => {
        expect(nameInput).toHaveValue('');
        expect(ageInput).toHaveValue(null);
      });
      
      // 验证列表刷新（会再次调用 GET）
      expect(api.get).toHaveBeenCalledTimes(2);
    });

    it('应该在姓名为空时显示警告', async () => {
      await renderAndWaitForInitialLoad();
      
      const submitButton = screen.getByRole('button', { name: /提交/i });
      
      // Mock alert
      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});
      
      fireEvent.click(submitButton);
      
      expect(mockAlert).toHaveBeenCalledWith('请填写姓名和年龄');
      mockAlert.mockRestore();
    });

    it('应该在年龄为空时显示警告', async () => {
      await renderAndWaitForInitialLoad();
      
      const nameInput = screen.getByLabelText(/姓名：/i);
      const submitButton = screen.getByRole('button', { name: /提交/i });
      
      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});
      
      fireEvent.change(nameInput, { target: { value: '周八' } });
      fireEvent.click(submitButton);
      
      expect(mockAlert).toHaveBeenCalledWith('请填写姓名和年龄');
      mockAlert.mockRestore();
    });

    it('应该在提交失败时显示错误提示', async () => {
      (api.get as any).mockResolvedValue(mockUsers);
      (api.post as any).mockRejectedValue(new Error('网络错误'));

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
      
      const nameInput = screen.getByLabelText(/姓名：/i);
      const ageInput = screen.getByLabelText(/年龄：/i);
      const submitButton = screen.getByRole('button', { name: /提交/i });
      
      fireEvent.change(nameInput, { target: { value: '吴九' } });
      fireEvent.change(ageInput, { target: { value: '45' } });
      
      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});
      
      fireEvent.click(submitButton);
      
      await waitFor(() => {
        expect(mockAlert).toHaveBeenCalledWith('新增用户失败');
      });
      
      mockAlert.mockRestore();
    });
  });

  describe('错误处理', () => {
    it('应该在获取用户失败时显示错误提示', async () => {
      (api.get as any).mockRejectedValue(new Error('网络错误'));

      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});
      
      render(<UserPage />);
      
      await waitFor(() => {
        expect(mockAlert).toHaveBeenCalledWith('获取用户失败，请检查后端和 Nginx 是否正常运行');
      });
      
      mockAlert.mockRestore();
    });

    it('应该在获取用户失败时结束加载状态', async () => {
      (api.get as any).mockRejectedValue(new Error('网络错误'));

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
    });
  });

  describe('导航链接', () => {
    it('应该包含返回首页的链接', async () => {
      await renderAndWaitForInitialLoad();
      
      const backLink = screen.getByRole('link', { name: /← 返回首页/i });
      expect(backLink).toBeInTheDocument();
      expect(backLink).toHaveAttribute('href', '/');
    });
  });

  describe('页面布局', () => {
    it('应该按正确顺序渲染各个部分', async () => {
      const { container } = await renderAndWaitForInitialLoad();
      
      // 验证返回链接在最前面
      const elements = container.querySelectorAll('div > *');
      expect(elements[0]).toContainHTML('← 返回首页');
      
      // 验证主标题
      expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('👥 用户管理');
    });

    it('应该使用正确的样式', async () => {
      await renderAndWaitForInitialLoad();
      
      const mainHeading = screen.getByRole('heading', { level: 1 });
      expect(mainHeading).toBeInTheDocument();
    });
  });

  describe('数据流完整性', () => {
    it('应该在组件挂载时自动获取数据', async () => {
      (api.get as any).mockResolvedValue(mockUsers);

      render(<UserPage />);
      
      // 验证 API 被调用
      expect(api.get).toHaveBeenCalledWith('/users');
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
    });

    it('应该正确处理用户数据的类型', async () => {
      const typedUsers: Array<{ id: number; name: string; age: number }> = mockUsers;
      (api.get as any).mockResolvedValue(typedUsers);

      render(<UserPage />);
      
      await waitFor(() => {
        expect(screen.queryByText(/加载中/i)).not.toBeInTheDocument();
      });
      
      // 验证数据正确渲染
      typedUsers.forEach((user) => {
        expect(screen.getByText(user.name)).toBeInTheDocument();
        expect(screen.getByText(user.age.toString())).toBeInTheDocument();
      });
    });
  });
});
