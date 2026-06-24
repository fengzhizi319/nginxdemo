import { useEffect, useState } from 'react';
import { get, post } from '@/services/api';
import { Link } from 'umi';

/**
 * 用户列表页。
 *
 * 学习点：
 * 1. 页面路径 src/pages/user.tsx 自动映射到路由 /user。
 * 2. 组件加载时调用 /api/users 获取数据，该请求会经过 Nginx 转发到 Tomcat 后端。
 * 3. 新增用户时调用 POST /api/users，演示前后端完整交互。
 */

// 用户对象的类型定义
interface User {
  id: number;
  name: string;
  age: number;
}

export default function UserPage() {
  // 用户列表状态
  const [users, setUsers] = useState<User[]>([]);
  // 加载状态
  const [loading, setLoading] = useState(false);
  // 表单状态
  const [name, setName] = useState('');
  const [age, setAge] = useState('');

  /**
   * 拉取用户列表。
   * 请求地址 /api/users 会被 Nginx 代理到 http://localhost:8080/backend/api/users。
   */
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const data = await get<User[]>('/users');
      setUsers(data);
    } catch (error) {
      console.error('获取用户失败：', error);
      alert('获取用户失败，请检查后端和 Nginx 是否正常运行');
    } finally {
      setLoading(false);
    }
  };

  // 组件挂载时自动拉取数据
  useEffect(() => {
    fetchUsers();
  }, []);

  /**
   * 提交新增用户表单。
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !age) {
      alert('请填写姓名和年龄');
      return;
    }
    try {
      await post<User>('/users', { name, age: Number(age) });
      setName('');
      setAge('');
      // 新增成功后刷新列表
      fetchUsers();
    } catch (error) {
      console.error('新增用户失败：', error);
      alert('新增用户失败');
    }
  };

  return (
    <div style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
      <Link to="/" style={{ color: '#1890ff' }}>← 返回首页</Link>
      <h1>👥 用户管理</h1>

      <section style={{ marginBottom: 24, padding: 16, border: '1px solid #ddd', borderRadius: 8 }}>
        <h2>新增用户</h2>
        <form onSubmit={handleSubmit}>
          <label style={{ marginRight: 8 }}>
            姓名：
            <input value={name} onChange={(e) => setName(e.target.value)} />
          </label>
          <label style={{ marginRight: 8 }}>
            年龄：
            <input type="number" value={age} onChange={(e) => setAge(e.target.value)} />
          </label>
          <button type="submit">提交</button>
        </form>
      </section>

      <section>
        <h2>用户列表</h2>
        {loading ? (
          <p>加载中...</p>
        ) : (
          <table border={1} cellPadding={8} style={{ borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                <th>ID</th>
                <th>姓名</th>
                <th>年龄</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td>{user.name}</td>
                  <td>{user.age}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
