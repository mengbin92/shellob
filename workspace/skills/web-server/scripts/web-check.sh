#!/bin/bash
# web-check.sh — Web 服务（Nginx/Apache）快速巡检
# 用法: ./web-check.sh [nginx|apache]

SERVER="${1:-nginx}"

echo "=========================================="
echo "  Web Server Health Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# Nginx
if [ "$SERVER" = "nginx" ]; then
    echo ""
    echo "### Nginx 服务状态"
    ps aux | grep -v grep | grep nginx && echo "✅ 运行中" || echo "❌ 未运行"

    echo ""
    echo "### 配置语法检查"
    nginx -t 2>&1

    echo ""
    echo "### 错误日志（最近10行）"
    ERROR_LOG="/usr/local/var/log/nginx/error.log"
    [ -f "$ERROR_LOG" ] && tail -10 "$ERROR_LOG" || echo "日志文件不存在"

    echo ""
    echo "### TOP 5 请求 IP"
    ACCESS_LOG="/usr/local/var/log/nginx/access.log"
    [ -f "$ACCESS_LOG" ] && awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -5 || echo "日志文件不存在"

    echo ""
    echo "### 状态码分布"
    [ -f "$ACCESS_LOG" ] && awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -rn || echo "日志文件不存在"

# Apache
elif [ "$SERVER" = "apache" ]; then
    echo ""
    echo "### Apache 服务状态"
    ps aux | grep -v grep | grep httpd && echo "✅ 运行中" || echo "❌ 未运行"

    echo ""
    echo "### 配置语法检查"
    apachectl configtest 2>&1

    echo ""
    echo "### 错误日志（最近十行）"
    ERROR_LOG="/usr/local/var/log/httpd/error_log"
    [ -f "$ERROR_LOG" ] && tail -10 "$ERROR_LOG" || echo "日志文件不存在"

    echo ""
    echo "### TOP 5 请求 IP"
    ACCESS_LOG="/usr/local/var/log/httpd/access_log"
    [ -f "$ACCESS_LOG" ] && awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -rn | head -5 || echo "日志文件不存在"

    echo ""
    echo "### 状态码分布"
    [ -f "$ACCESS_LOG" ] && awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -rn || echo "日志文件不存在"

else
    echo "用法: $0 [nginx|apache]"
fi

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
