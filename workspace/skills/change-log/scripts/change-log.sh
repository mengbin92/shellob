#!/bin/bash
# change-log.sh — 变更记录管理脚本
# 用法:
#   ./change-log.sh record --category deploy --action "xxx" --target "xxx" ...
#   ./change-log.sh query --category config --days 7
#   ./change-log.sh report --month 2026-03

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHANGE_DIR="${CHANGE_DIR:-$HOME/.openclaw/workspace/memory/changes}"
mkdir -p "$CHANGE_DIR"

# 默认值
TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"
OPERATOR="shellob"
RISK="low"

usage() {
    echo "用法: $0 <command> [options]"
    echo ""
    echo "命令:"
    echo "  record   记录变更"
    echo "  query    查询变更"
    echo "  report   生成报告"
    echo ""
    echo "record 选项:"
    echo "  --category <config|deploy|scale|cleanup|incident|database|security|other>"
    echo "  --action  <操作描述>"
    echo "  --target  <操作目标>"
    echo "  --impact  <影响范围>"
    echo "  --risk    <low|medium|high|critical>"
    echo "  --rollback <回滚方案>"
    echo "  --notes   <备注>"
    echo ""
    echo "query 选项:"
    echo "  --category <分类>"
    echo "  --days     <最近N天>"
    echo "  --risk     <风险等级>"
    echo ""
    echo "示例:"
    echo "  $0 record --category deploy --action 'Docker 镜像更新' --target 'app:v2.1' --impact '容器重启' --risk medium"
    echo "  $0 query --days 7"
    echo "  $0 report --month 2026-03"
    exit 1
}

# 记录变更
cmd_record() {
    local category action target impact risk rollback notes

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --category) category="$2"; shift 2 ;;
            --action) action="$2"; shift 2 ;;
            --target) target="$2"; shift 2 ;;
            --impact) impact="$2"; shift 2 ;;
            --risk) risk="$2"; shift 2 ;;
            --rollback) rollback="$2"; shift 2 ;;
            --notes) notes="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$category" ] || [ -z "$action" ]; then
        echo "错误: --category 和 --action 必填"
        exit 1
    fi

    local month="${TIMESTAMP:0:7}"
    local log_file="$CHANGE_DIR/${month}.csv"
    local header="timestamp,category,operator,action,target,impact,risk_level,rollback,notes"

    # 创建文件并写入表头（如不存在）
    if [ ! -f "$log_file" ]; then
        echo "$header" > "$log_file"
    fi

    # 追加记录
    echo "$TIMESTAMP,$category,$OPERATOR,\"$action\",\"$target\",\"$impact\",$risk,\"$rollback\",\"$notes\"" >> "$log_file"

    echo "✅ 变更已记录"
    echo "文件: $log_file"
    echo "分类: $category | 操作: $action | 风险: $risk"
}

# 查询变更
cmd_query() {
    local category days risk pattern

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --category) category="$2"; shift 2 ;;
            --days) days="$2"; shift 2 ;;
            --risk) risk="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    # 确定要查询的文件
    local files=""
    if [ -n "$days" ]; then
        local start_date=$(date -v-${days}d +%Y-%m 2>/dev/null || date -d "$days days ago" +%Y-%m 2>/dev/null)
        files=$(ls "$CHANGE_DIR"/${start_date}*.csv 2>/dev/null || echo "")
    else
        files=$(ls -t "$CHANGE_DIR"/*.csv 2>/dev/null | head -3)
    fi

    if [ -z "$files" ]; then
        echo "无变更记录"
        return
    fi

    # 构建 grep 模式
    pattern=""
    [ -n "$category" ] && pattern="${pattern}${category}"
    [ -n "$risk" ] && pattern="${pattern}${risk}"

    echo "========== 变更查询 =========="
    echo "时间范围: ${days:-所有} 天"
    [ -n "$category" ] && echo "分类: $category"
    [ -n "$risk" ] && echo "风险: $risk"
    echo ""

    for f in $files; do
        echo "--- $(basename $f) ---"
        if [ -n "$pattern" ]; then
            grep -E "$pattern" "$f" | tail -20
        else
            tail -20 "$f"
        fi
    done
}

# 生成报告
cmd_report() {
    local month

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --month) month="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    [ -z "$month" ] && month="$(date +%Y-%m)"
    local log_file="$CHANGE_DIR/${month}.csv"

    if [ ! -f "$log_file" ]; then
        echo "无 $month 的变更记录"
        return
    fi

    echo "=========================================="
    echo "  Shellob 变更记录月报"
    echo "  $month"
    echo "=========================================="

    # 总数
    local total=$(($(wc -l < "$log_file") - 1))
    echo ""
    echo "变更总数: $total"

    # 按分类统计
    echo ""
    echo "### 分类统计"
    awk -F',' 'NR>1 {counts[$2]++} END {for(c in counts) printf "  %-12s %3d\n", c, counts[c]}' "$log_file" | sort -rn -k2

    # 按风险统计
    echo ""
    echo "### 风险分布"
    awk -F',' 'NR>1 {counts[$7]++} END {for(r in counts) printf "  %-10s %3d\n", r, counts[r]}' "$log_file" | sort -rn -k2

    # 高风险变更
    echo ""
    echo "### 高风险变更"
    grep -E "high|critical" "$log_file" | awk -F',' '{printf "  [%s] %s | %s | 回滚: %s\n", $1, $2, $4, $8}'

    # 最近变更
    echo ""
    echo "### 最近变更（最后10条）"
    tail -10 "$log_file" | awk -F',' '{printf "  [%s] %s | %s\n", $1, $2, $4}'

    echo ""
    echo "=========================================="
}

# 主命令分发
case "${1:-}" in
    record) shift; cmd_record "$@" ;;
    query) shift; cmd_query "$@" ;;
    report) shift; cmd_report "$@" ;;
    *) usage ;;
esac
