#!/bin/bash
# =============================================================================
# test.sh：一键运行前后端所有单元测试
# =============================================================================
# 使用方法：
#   chmod +x scripts/test.sh
#   ./scripts/test.sh
#
# 本脚本会完成：
# 1. 后端：运行 Maven 测试（mvn test）。
# 2. 前端：安装依赖（若需要）并运行 Vitest 测试套件（pnpm run test:run）。
#
# 前置条件：
#   - JDK 17+
#   - Maven 3.8+
#   - Node.js 18+ / pnpm（项目使用 corepack pnpm）
# =============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "项目目录：$PROJECT_DIR"

PKG_MGR="corepack pnpm"
BACKEND_TEST_FAILED=0
FRONTEND_TEST_FAILED=0

# ---------------------------------------------------------------------------
# 1. 后端测试
# ---------------------------------------------------------------------------
echo ""
echo "【1/2】运行后端 Maven 测试..."
cd "$PROJECT_DIR/backend"

if mvn test; then
    echo "后端测试通过。"
else
    echo "后端测试失败。"
    BACKEND_TEST_FAILED=1
fi

# ---------------------------------------------------------------------------
# 2. 前端测试
# ---------------------------------------------------------------------------
echo ""
echo "【2/2】运行前端 Vitest 测试..."
cd "$PROJECT_DIR/frontend"

# 确保依赖已安装（pnpm 会快速检查，已安装时不会重复下载）
$PKG_MGR install

if $PKG_MGR run test:run; then
    echo "前端测试通过。"
else
    echo "前端测试失败。"
    FRONTEND_TEST_FAILED=1
fi

# ---------------------------------------------------------------------------
# 3. 结果汇总
# ---------------------------------------------------------------------------
echo ""
echo "【测试汇总】"
if [ "$BACKEND_TEST_FAILED" -eq 0 ] && [ "$FRONTEND_TEST_FAILED" -eq 0 ]; then
    echo "  ✅ 后端测试通过"
    echo "  ✅ 前端测试通过"
    echo ""
    echo "所有测试全部通过！"
    exit 0
else
    [ "$BACKEND_TEST_FAILED" -eq 0 ] && echo "  ✅ 后端测试通过" || echo "  ❌ 后端测试失败"
    [ "$FRONTEND_TEST_FAILED" -eq 0 ] && echo "  ✅ 前端测试通过" || echo "  ❌ 前端测试失败"
    echo ""
    echo "部分测试未通过，请查看上方日志。"
    exit 1
fi
