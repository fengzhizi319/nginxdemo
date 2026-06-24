/**
 * 前端请求后端 API 的封装。
 *
 * 学习点：
 * 1. 生产环境通过 Nginx 反向代理访问后端，因此请求地址只需写相对路径 /api/xxx。
 *    Nginx 会把 /api 转发到 Tomcat 的 /backend/api。
 * 2. 开发环境通过 .umirc.ts 中的 proxy 配置自动转发到 http://127.0.0.1:8080/backend。
 * 3. fetch 是浏览器原生 API，无需额外安装 axios。
 */

const BASE_URL = '/api';

/**
 * 统一封装 GET 请求。
 * @param path 接口路径，例如 /users
 */
export async function get<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`);
  if (!response.ok) {
    throw new Error(`请求失败：${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}

/**
 * 统一封装 POST 请求。
 * @param path 接口路径
 * @param body 请求体对象
 */
export async function post<T>(path: string, body: Record<string, unknown>): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error(`请求失败：${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}
