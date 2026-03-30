#!/bin/bash
# netdiag.sh — 网络诊断一键检查
# 用法: ./netdiag.sh <host> [port]

HOST="$1"
PORT="${2:-443}"

if [ -z "$HOST" ]; then
    echo "用法: $0 <host> [port]"
    echo "示例: $0 example.com 443"
    exit 1
fi

echo "=========================================="
echo "  Network Diagnostics"
echo "  Host: $HOST:$PORT"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# DNS 解析
echo ""
echo "### DNS 解析"
nslookup "$HOST" 2>/dev/null || dig "$HOST" +short 2>/dev/null || echo "解析失败"

# 端口连通性
echo ""
echo "### 端口检测 ($PORT)"
nc -zv "$HOST" "$PORT" -w 5 2>&1

# HTTP 检测
echo ""
echo "### HTTP 检测"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "https://$HOST" 2>/dev/null)
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --connect-timeout 5 "https://$HOST" 2>/dev/null)
echo "HTTP 状态码: ${HTTP_CODE:-无法连接}"
echo "响应时间: ${RESPONSE_TIME:-N/A}s"

# SSL 证书
echo ""
echo "### SSL 证书"
echo | openssl s_client -connect "$HOST:$PORT" -servername "$HOST" 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null || echo "无法获取证书"

# TLS 版本
echo ""
echo "### TLS 版本"
echo | openssl s_client -tls1_2 -connect "$HOST:$PORT" -servername "$HOST" 2>/dev/null | grep "Protocol" | head -1 || echo "无法获取"

echo ""
echo "=========================================="
echo "  诊断完成"
echo "=========================================="
