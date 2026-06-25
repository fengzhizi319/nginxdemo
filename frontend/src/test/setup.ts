/**
 * 测试环境设置文件。
 * 
 * 在每次测试运行前自动执行，用于：
 * 1. 导入 @testing-library/jest-dom 的自定义匹配器（如 toBeInTheDocument）
 * 2. 配置全局 mock
 * 3. 清理测试环境
 */

import '@testing-library/jest-dom';

// 如果需要，可以在这里添加全局的 mock 或配置
// 例如：mock localStorage、window 对象等
