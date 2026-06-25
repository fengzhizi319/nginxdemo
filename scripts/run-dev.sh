#!/bin/bash
# =============================================================================
# run-dev.sh：前后端同时启动（开发模式）
# =============================================================================
# 使用方法：
#   chmod +x scripts/run-dev.sh
#   ./scripts/run-dev.sh
#
# 本脚本会完成：
# 1. 在后台启动 Spring Boot 后端（mvn spring-boot:run），监听 http://127.0.0.1:8081
# 2. 等待后端健康检查接口可用。
# 3. 在前台启动 UmiJS 开发服务器（pnpm run dev），监听 http://127.0.0.1:8000
# 4. 当前台 dev 服务器退出时，自动停止后台的后端进程。
#
# 端口说明：
#   - 前端 dev server：8000
#   - 后端嵌入 Tomcat：8081，上下文路径 /backend
#   - 前端通过 .umirc.ts 中的 proxy 把 /api 请求转发到 http://127.0.0.1:8081/backend
#
# 前置条件：
#   - JDK 17+
#   - Maven 3.8+
#   - Node.js 18+ / pnpm
# =============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "项目目录：$PROJECT_DIR"

PKG_MGR="corepack pnpm"
BACKEND_URL="http://127.0.0.1:8081/backend/api/users/health"
BACKEND_PID=""

# 清理函数：脚本退出时停止后端
cleanup() {
    echo ""
    echo "正在停止后端服务..."
    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        kill "$BACKEND_PID" 2>/dev/null || true
        wait "$BACKEND_PID" 2>/dev/null || true
        echo "后端服务已停止（PID: $BACKEND_PID）。"
    else
        echo "后端服务已不在运行。"
    fi
}
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
# 1. 启动后端
# ---------------------------------------------------------------------------
echo ""
echo "【1/3】启动后端 Spring Boot（嵌入 Tomcat，端口 8081）..."
cd "$PROJECT_DIR/backend"

# 在后台启动 mvn spring-boot:run，并把输出重定向到日志文件
mvn spring-boot:run >"$PROJECT_DIR/backend/backend-dev.log" 2>&1 &
BACKEND_PID=$!
echo "后端进程已启动，PID: $BACKEND_PID"
echo "后端日志：$PROJECT_DIR/backend/backend-dev.log"

# ---------------------------------------------------------------------------
# 2. 等待后端就绪
# ---------------------------------------------------------------------------
echo ""
echo "【2/3】等待后端健康检查接口就绪：$BACKEND_URL"
MAX_RETRY=30
RETRY=0
while [ "$RETRY" -lt "$MAX_RETRY" ]; do
    if curl -s "$BACKEND_URL" >/dev/null 2>&1; then
        echo "后端已就绪！"
        echo "  健康检查：$BACKEND_URL"
        echo "  用户列表：http://127.0.0.1:8081/backend/api/users"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "  等待后端启动中... ($RETRY/$MAX_RETRY)"
    sleep 2
done

if [ "$RETRY" -eq "$MAX_RETRY" ]; then
    echo "错误：后端在 $MAX_RETRY 次尝试后仍未就绪，请查看日志：$PROJECT_DIR/backend/backend-dev.log"
    exit 1
fi

# ---------------------------------------------------------------------------
# 3. 启动前端 dev server（前台运行，按 Ctrl+C 退出）
# ---------------------------------------------------------------------------
echo ""
echo "【3/3】启动前端 UmiJS dev server（端口 8000）..."
echo ""
echo "  访问地址："
echo "    - 前端页面：http://127.0.0.1:8000"
echo "    - 用户列表 API（经前端代理）：http://127.0.0.1:8000/api/users"
echo ""
echo "  提示："
echo "    - 前端 /api/* 请求会被代理到 http://127.0.0.1:8081/backend"
echo "    - 按 Ctrl+C 可同时停止前端 dev server 和后端 Spring Boot"
echo ""

cd "$PROJECT_DIR/frontend"
$PKG_MGR install
$PKG_MGR run dev

# 当前台 dev server 退出后，trap 会自动执行 cleanup 停止后端
