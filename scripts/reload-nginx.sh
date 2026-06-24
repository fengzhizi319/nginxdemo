#!/bin/bash
# =============================================================================
# reload-nginx.sh：重新加载系统 Nginx 配置
# =============================================================================
# 修改了 /etc/nginx/sites-available/nginxdemo 后，执行此脚本使配置生效。
# 不需要重启 Nginx，不会中断现有连接。
# =============================================================================

set -euo pipefail

echo "测试 Nginx 配置..."
sudo nginx -t

echo "重新加载 Nginx..."
sudo systemctl reload nginx

echo "Nginx 配置已重载。"
