#!/bin/bash
# =============================================================================
# stop-local.sh：停止 Tomcat（Nginx 为系统服务，由 systemd 管理）
# =============================================================================
# 使用方法：
#   chmod +x scripts/stop-local.sh
#   ./scripts/stop-local.sh
#
# 如果需要停止系统 Nginx，请手动执行：
#   sudo systemctl stop nginx
# =============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

TOMCAT_HOME="$PROJECT_DIR/tomcat/apache-tomcat-10.1.56"
TOMCAT_BASE="$PROJECT_DIR/tomcat"

# ---------------------------------------------------------------------------
# 停止 Tomcat
# ---------------------------------------------------------------------------
echo "【1/1】停止 Tomcat..."
if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
    export CATALINA_HOME="$TOMCAT_HOME"
    export CATALINA_BASE="$TOMCAT_BASE"
    "$TOMCAT_HOME/bin/shutdown.sh" || true
    echo "Tomcat 已停止。"
else
    echo "找不到 Tomcat shutdown 脚本。"
fi

echo ""
echo "Tomcat 已停止。"
echo "系统 Nginx 仍在运行，如需停止请执行：sudo systemctl stop nginx"
