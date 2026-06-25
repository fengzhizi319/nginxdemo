import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  test: {
    // 测试环境配置
    environment: 'jsdom',
    
    // 全局设置文件，用于导入 @testing-library/jest-dom 的匹配器
    setupFiles: ['./src/test/setup.ts'],
    
    // 包含的文件模式
    include: ['**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    
    // 排除的文件模式
    exclude: ['node_modules', 'dist', '.umi', '.umi-production'],
    
    // 全局超时时间（毫秒）
    testTimeout: 10000,
    
    // 覆盖率配置
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        'src/.umi*/',
      ],
    },
    
    // 模拟浏览器环境
    globals: true,
  },
});
