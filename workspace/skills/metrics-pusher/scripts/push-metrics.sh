#!/bin/bash
# push-metrics.sh — 采集指标并推送到 PushGateway
# 用法: ./push-metrics.sh [PushGateway URL]
# 示例: ./push-metrics.sh http://localhost:9091

PUSHGATEWAY="${1:-http://localhost:9091}"
JOB="shellob"
HOST="$(hostname)"
LOG_FILE="/var/log/shellob-metrics.log"
METRICS_FILE="/tmp/shellob-metrics-$$.tmp"

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 采集指标
log "采集指标..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/collect-metrics.sh" > "$METRICS_FILE" 2>&1

if [ $? -ne 0 ]; then
    log "ERROR: 指标采集失败"
    cat "$METRICS_FILE" >> "$LOG_FILE"
    rm -f "$METRICS_FILE"
    exit 1
fi

# 推送到 PushGateway
log "推送到 PushGateway ($PUSHGATEWAY)..."
curl -s -X PUT \
    --data-binary @"$METRICS_FILE" \
    "$PUSHGATEWAY/metrics/job/$JOB/instance/$HOST" \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log "推送成功: $(hostname)"
else
    log "ERROR: 推送失败"
    exit 1
fi

# 清理
rm -f "$METRICS_FILE"

# 输出本次推送的指标摘要
echo ""
echo "========== 本次推送摘要 =========="
"$SCRIPT_DIR/collect-metrics.sh" | grep "^shellob_" | grep -v "^#" | head -10
echo "==================================="
