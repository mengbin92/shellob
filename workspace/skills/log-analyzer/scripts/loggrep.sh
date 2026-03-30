#!/bin/bash
# loggrep.sh — 快速搜索常用错误模式
# 用法: ./loggrep.sh <日志文件> [模式] [上下文行数]
# 不带模式时搜索: ERROR, FATAL, Exception, OutOfMemory, timeout

LOG_FILE="$1"
PATTERN="${2:-ERROR|FATAL|Exception|OutOfMemory|timeout|refused}"
CONTEXT="${3:-5}"

if [ -z "$LOG_FILE" ]; then
    echo "用法: $0 <日志文件> [模式] [上下文行数]"
    echo "示例: $0 /var/log/app.log 'ERROR|FATAL' 10"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "文件不存在: $LOG_FILE"
    exit 1
fi

# 检测压缩文件
if [[ "$LOG_FILE" == *.gz ]]; then
    CMD="zcat -f"
else
    CMD="cat"
fi

echo "========== 日志搜索 =========="
echo "文件: $LOG_FILE"
echo "模式: $PATTERN"
echo "上下文: ${CONTEXT}行"
echo "================================"

$CMD "$LOG_FILE" | grep -E "$PATTERN" | tail -100

echo ""
echo "========== 统计 =========="
$CMD "$LOG_FILE" | grep -E "$PATTERN" | wc -l | xargs echo "匹配行数:"
