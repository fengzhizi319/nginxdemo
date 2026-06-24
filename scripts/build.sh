#!/bin/bash
# =============================================================================
# build.sh：一键构建前端和后端
# =============================================================================
# 使用方法：
#   chmod +x scripts/build.sh
#   ./scripts/build.sh
#
# 本脚本会完成：
# 1. 后端：使用 Maven 打成 WAR 包，并复制到 tomcat/webapps。
# 2. 前端：安装依赖并使用 Umi 构建，产物放到 frontend/dist。
# =============================================================================

# 启用严格模式：遇到错误立即退出，未定义变量报错
set -euo pipefail

# 获取项目根目录（脚本所在目录的上级）
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "项目目录：$PROJECT_DIR"

# 在 WSL 中，PATH 里可能混入了 Windows 的 npm，导致安装失败。
# 这里使用 corepack 提供的 pnpm（与 Node 绑定，不依赖 Windows 路径）。
PKG_MGR="corepack pnpm"

# ---------------------------------------------------------------------------
# 1. 构建后端
# ---------------------------------------------------------------------------
echo ""
echo "【1/3】构建后端 Spring Boot WAR 包..."
cd "$PROJECT_DIR/backend"

# 执行 Maven 打包，跳过测试以加快构建
mvn clean package -DskipTests

# 把生成的 WAR 包复制到 Tomcat 的 webapps 目录
# WAR 包名是 backend.war，Tomcat 会自动部署为 /backend 上下文路径
mkdir -p "$PROJECT_DIR/tomcat/webapps"
cp "$PROJECT_DIR/backend/target/backend.war" "$PROJECT_DIR/tomcat/webapps/backend.war"
echo "后端 WAR 已复制到：$PROJECT_DIR/tomcat/webapps/backend.war"

# ---------------------------------------------------------------------------
# 2. 构建前端
# ---------------------------------------------------------------------------
echo ""
echo "【2/3】构建前端 UmiJS 项目..."
cd "$PROJECT_DIR/frontend"

# 安装依赖（如果 node_modules 已存在，会快速检查）
$PKG_MGR install

# 生产构建，产物输出到 frontend/dist
$PKG_MGR run build

echo "前端构建完成，产物目录：$PROJECT_DIR/frontend/dist"

# ---------------------------------------------------------------------------
# 3. 构建结果汇总
# ---------------------------------------------------------------------------
echo ""
echo "【3/3】构建完成！"
echo "  - 后端 WAR：$PROJECT_DIR/tomcat/webapps/backend.war"
echo "  - 前端静态资源：$PROJECT_DIR/frontend/dist"
echo ""
echo "下一步可以执行：./scripts/start-local.sh"
