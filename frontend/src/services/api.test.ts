/**
 * API 服务层单元测试。
 * 
 * 测试目标：
 * 1. 验证 GET 请求正确构造 URL 并返回解析后的 JSON
 * 2. 验证 POST 请求正确发送数据和 headers
 * 3. 验证错误处理逻辑（非 2xx 状态码抛出异常）
 */

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { get, post } from '../services/api';

// Mock fetch 全局函数
const mockFetch = vi.fn();
global.fetch = mockFetch;

describe('API Service', () => {
  beforeEach(() => {
    // 每个测试前重置 mock
    mockFetch.mockClear();
  });

  describe('get 函数', () => {
    it('应该正确发起 GET 请求并返回数据', async () => {
      // 准备测试数据
      const mockData = [
        { id: 1, name: '张三', age: 25 },
        { id: 2, name: '李四', age: 30 },
      ];

      // Mock fetch 成功响应
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        statusText: 'OK',
        json: async () => mockData,
      } as Response);

      // 执行被测试函数
      const result = await get('/users');

      // 验证结果
      expect(result).toEqual(mockData);
      
      // 验证 fetch 被正确调用
      expect(mockFetch).toHaveBeenCalledTimes(1);
      expect(mockFetch).toHaveBeenCalledWith('/api/users');
    });

    it('应该正确处理带参数的 GET 请求', async () => {
      const mockData = { id: 1, name: '张三' };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        statusText: 'OK',
        json: async () => mockData,
      } as Response);

      const result = await get('/users/1');

      expect(result).toEqual(mockData);
      expect(mockFetch).toHaveBeenCalledWith('/api/users/1');
    });

    it('应该在请求失败时抛出错误', async () => {
      // Mock fetch 失败响应
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
      } as Response);

      // 验证异步错误抛出
      await expect(get('/invalid')).rejects.toThrow('请求失败：404 Not Found');
    });

    it('应该在服务器错误时抛出错误', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
      } as Response);

      await expect(get('/error')).rejects.toThrow('请求失败：500 Internal Server Error');
    });
  });

  describe('post 函数', () => {
    it('应该正确发起 POST 请求并返回数据', async () => {
      const newData = { name: '王五', age: 28 };
      const mockResponse = { id: 3, ...newData };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 201,
        statusText: 'Created',
        json: async () => mockResponse,
      } as Response);

      const result = await post('/users', newData);

      expect(result).toEqual(mockResponse);
      expect(mockFetch).toHaveBeenCalledTimes(1);
      expect(mockFetch).toHaveBeenCalledWith('/api/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newData),
      });
    });

    it('应该正确序列化请求体', async () => {
      const testData = { name: '赵六', age: 35, email: 'zhaoliu@example.com' };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 201,
        statusText: 'Created',
        json: async () => ({ id: 4, ...testData }),
      } as Response);

      await post('/users', testData);

      // 验证 body 被正确序列化为 JSON 字符串
      expect(mockFetch).toHaveBeenCalledWith(
        '/api/users',
        expect.objectContaining({
          body: JSON.stringify(testData),
        })
      );
    });

    it('应该在 POST 失败时抛出错误', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        statusText: 'Bad Request',
      } as Response);

      await expect(post('/users', { name: '' })).rejects.toThrow(
        '请求失败：400 Bad Request'
      );
    });
  });

  describe('BASE_URL 常量', () => {
    it('应该使用正确的 API 基础路径', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        statusText: 'OK',
        json: async () => [],
      } as Response);

      await get('/test');

      // 验证 URL 以 /api 开头
      expect(mockFetch).toHaveBeenCalledWith('/api/test');
    });
  });
});
