#!/bin/bash
# collect-metrics.sh — 采集系统指标，输出 Prometheus 格式
# 用法: ./collect-metrics.sh

HOST="$(hostname)"
OS="$(uname -s)"
DATE="$(date +%s)"

echo "# HELP shellob_collected_at Unix timestamp of collection"
echo "# TYPE shellob_collected_at counter"
echo "shellob_collected_at{host=\"$HOST\"} $DATE"
echo ""

# CPU
if [ "$OS" = "Darwin" ]; then
    CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%' || echo "0")
else
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%' || echo "0")
fi
echo "# HELP shellob_cpu_usage_percent CPU usage percent"
echo "# TYPE shellob_cpu_usage_percent gauge"
echo "shellob_cpu_usage_percent{host=\"$HOST\"} $CPU"

# 内存
if [ "$OS" = "Darwin" ]; then
    MEM=$(vm_stat | awk '/Pages active/ {active=$3} /Pages wired/ {wired=$4} /Pages free/ {free=$3} END {total=active+wired+free; if(total>0) printf "%.1f", (total-free)/total*100; else print "0"}')
else
    MEM=$(free | awk '/^Mem:/ {printf "%.1f", ($3/$2)*100}')
fi
echo "# HELP shellob_memory_usage_percent Memory usage percent"
echo "# TYPE shellob_memory_usage_percent gauge"
echo "shellob_memory_usage_percent{host=\"$HOST\"} ${MEM:-0}"

# 磁盘（根分区）
DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "# HELP shellob_disk_usage_percent Disk usage percent (root)"
echo "# TYPE shellob_disk_usage_percent gauge"
echo "shellob_disk_usage_percent{host=\"$HOST\",mount=\"/\"} $DISK"

# Docker
if command -v docker &>/dev/null; then
    DOCKER_RUNNING=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
    DOCKER_TOTAL=$(docker ps -a -q 2>/dev/null | wc -l | tr -d ' ')
    DOCKER_MEMORY=$(docker stats --no-stream --format "{{.MemUsage}}" 2>/dev/null | awk '{sum+=$1} END {print sum+0}')

    echo "# HELP shellob_docker_running_containers Number of running containers"
    echo "# TYPE shellob_docker_running_containers gauge"
    echo "shellob_docker_running_containers{host=\"$HOST\"} $DOCKER_RUNNING"

    echo "# HELP shellob_docker_total_containers Total number of containers"
    echo "# TYPE shellob_docker_total_containers gauge"
    echo "shellob_docker_total_containers{host=\"$HOST\"} $DOCKER_TOTAL"

    echo "# HELP shellob_docker_memory_usage_mb Docker total memory usage in MB"
    echo "# TYPE shellob_docker_memory_usage_mb gauge"
    echo "shellob_docker_memory_usage_mb{host=\"$HOST\"} $DOCKER_MEMORY"
fi

# 网络连接数
if [ "$OS" = "Darwin" ]; then
    NET_CONN=$(lsof -i -P -n 2>/dev/null | grep -c ESTABLISHED || echo "0")
else
    NET_CONN=$(ss -tunap 2>/dev/null | grep -c ESTAB || echo "0")
fi
echo "# HELP shellob_network_connections Number of established network connections"
echo "# TYPE shellob_network_connections gauge"
echo "shellob_network_connections{host=\"$HOST\"} $NET_CONN"

# 负载（Linux only）
if [ "$OS" = "Linux" ]; then
    LOAD1=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    LOAD5=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $2}' | tr -d ',')
    LOAD15=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $3}' | tr -d ',')
    echo "# HELP shellob_load_average_1m System load average 1 minute"
    echo "# TYPE shellob_load_average_1m gauge"
    echo "shellob_load_average_1m{host=\"$HOST\"} $LOAD1"
    echo "# HELP shellob_load_average_5m System load average 5 minutes"
    echo "# TYPE shellob_load_average_5m gauge"
    echo "shellob_load_average_5m{host=\"$HOST\"} $LOAD5"
    echo "# HELP shellob_load_average_15m System load average 15 minutes"
    echo "# TYPE shellob_load_average_15m gauge"
    echo "shellob_load_average_15m{host=\"$HOST\"} $LOAD15"
fi

# 进程数
PROC_COUNT=$(ps aux | wc -l | tr -d ' ')
echo "# HELP shellob_process_count Total number of processes"
echo "# TYPE shellob_process_count gauge"
echo "shellob_process_count{host=\"$HOST\"} $PROC_COUNT"
