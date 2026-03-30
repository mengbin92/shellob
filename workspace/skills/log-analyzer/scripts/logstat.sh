#!/bin/bash
# logstat.sh — 日志统计分析
# 用法: ./logstat.sh <日志文件>

LOG_FILE="$1"

if [ -z "$LOG_FILE" ]; then
    echo "用法: $0 <日志文件>"
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

echo "========== 日志统计 =========="
echo "文件: $LOG_FILE"

# 总行数
TOTAL=$($CMD "$LOG_FILE" | wc -l | tr -d ' ')
echo "总行数: $TOTAL"

# 错误行数
ERRORS=$($CMD "$LOG_FILE" | grep -cE "ERROR|FATAL" 2>/dev/null || echo "0")
echo "错误行数: $ERRORS"

# 警告行数
WARNINGS=$($CMD "$LOG_FILE" | grep -cE "WARN" 2>/dev/null || echo "0")
echo "警告行数: $WARNINGS"

# 文件大小
SIZE=$(du -h "$LOG_FILE" | cut -f1)
echo "文件大小: $SIZE"

echo ""
echo "========== 错误类型 TOP 10 =========="
$CMD "$LOG_FILE" | grep -oE "ERROR[:\s].*" | cut -d' ' -f2- | sort | uniq -c | sort -rn | head -10

echo ""
echo "========== 时间分布（小时） =========="
$CMD "$LOG_FILE" | grep -oE "^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}" | cut -d' ' -f2 | sort | uniq -c | sort -k2

echo ""
echo "========== 完成 =========="
