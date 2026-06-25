/**
 * UmiJS 的运行时配置文件。
 *
 * 学习点：
 * 1. app.ts 是 Umi 4 约定式的运行时配置入口。
 * 2. 这里可以配置路由守卫、全局初始化、请求封装等。
 * 3. 本示例保持最小化，仅做注释说明。
 *
 * 注意：不要导出 Umi 不认识的 key，否则生产构建运行时会报错
 *       "register failed, invalid key xxx"，导致页面空白。
 */

// 应用首次渲染前可以在这里执行初始化逻辑
// export const onInitialStateChange = () => {
//   // 示例：可以在这里打印日志或做权限校验
// };
