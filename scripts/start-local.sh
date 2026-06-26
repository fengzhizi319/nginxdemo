#!/bin/bash
# =============================================================================
# start-local.sh：启动 Tomcat（Nginx 已改为系统服务，由 systemd 管理）
# =============================================================================
# 使用方法：
#   chmod +x scripts/start-local.sh
#   ./scripts/start-local.sh
#
# 本脚本会完成：
# 1. 检查必要文件是否存在。
# 2. 确认系统 Nginx 已启动并加载了 nginxdemo 配置。
# 3. 启动 Tomcat（使用项目内的配置目录作为 CATALINA_BASE）。
# 4. 等待并打印访问地址。
#
# Nginx 系统服务常用命令：
#   sudo systemctl start nginx    # 启动
#   sudo systemctl stop nginx     # 停止
#   sudo systemctl reload nginx   # 重载配置
#   sudo systemctl status nginx   # 查看状态
# =============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "项目目录：$PROJECT_DIR"

TOMCAT_HOME="$PROJECT_DIR/tomcat/apache-tomcat-10.1.56"
TOMCAT_BASE="$PROJECT_DIR/tomcat"
BACKEND_WAR="$PROJECT_DIR/tomcat/webapps/backend.war"
FRONTEND_DIST="$PROJECT_DIR/frontend/dist"

# ---------------------------------------------------------------------------
# 1. 检查必要文件
# ---------------------------------------------------------------------------
echo ""
echo "【1/4】检查必要文件..."

if [ ! -d "$TOMCAT_HOME" ]; then
    echo "错误：找不到 Tomcat 安装目录：$TOMCAT_HOME"
    exit 1
fi

if [ ! -f "$BACKEND_WAR" ]; then
    echo "错误：找不到后端 WAR 包：$BACKEND_WAR"
    echo "请先运行 ./scripts/build.sh"
    exit 1
fi

if [ ! -d "$FRONTEND_DIST" ]; then
    echo "错误：找不到前端构建产物：$FRONTEND_DIST"
    echo "请先运行 ./scripts/build.sh"
    exit 1
fi

echo "检查通过。"

# ---------------------------------------------------------------------------
# 2. 检查系统 Nginx 状态
# ---------------------------------------------------------------------------
echo ""
echo "【2/4】检查系统 Nginx 状态..."

if systemctl is-active --quiet nginx; then
    echo "系统 Nginx 已启动。"
else
    echo "系统 Nginx 未启动，正在启动..."
    sudo systemctl start nginx
    echo "系统 Nginx 已启动。"
fi

# 确认 nginxdemo 站点配置已加载
if [ -L /etc/nginx/sites-enabled/nginxdemo ] && sudo nginx -t >/dev/null 2>&1; then
    echo "nginxdemo 站点配置已加载。"
else
    echo "警告：未能确认 nginxdemo 站点配置是否已加载，请检查 /etc/nginx/sites-enabled/nginxdemo"
fi

# ---------------------------------------------------------------------------
# 3. 启动 Tomcat
# ---------------------------------------------------------------------------
echo ""
echo "【3/4】启动 Tomcat..."

export CATALINA_HOME="$TOMCAT_HOME"
export CATALINA_BASE="$TOMCAT_BASE"

"$TOMCAT_HOME/bin/startup.sh"

# 等待 Tomcat 启动完成
sleep 3

if ss -tlnp 2>/dev/null | grep -q ':8080'; then
    echo "Tomcat 已成功启动，监听端口：8080"
else
    echo "警告：Tomcat 可能尚未完成启动，请查看日志：$TOMCAT_BASE/logs/catalina.out"
fi

# ---------------------------------------------------------------------------
# 4. 访问地址
# ---------------------------------------------------------------------------
echo ""
echo "【4/4】服务启动完成！"
echo ""
echo "  访问地址："
echo "    - 前端页面：http://127.0.0.1:8088"
echo "    - 用户列表 API：http://127.0.0.1:8088/api/users"
echo "    - 后端直接访问：http://127.0.0.1:8080/backend/api/users"
echo ""
echo "  Nginx 系统服务管理命令："
echo "    sudo systemctl start nginx"
echo "    sudo systemctl stop nginx"
echo "    sudo systemctl reload nginx"
echo "    sudo systemctl status nginx"
echo ""
echo "  Tomcat 日志："
echo "    tail -f $TOMCAT_BASE/logs/catalina.out"
echo ""
