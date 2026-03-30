#!/bin/bash
# sysreport.sh — 生成系统监控报告
# 用法: ./sysreport.sh

HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M")
OS=$(uname -s)
OS_VERSION=$(sw_vers 2>/dev/null | awk 'NR==2 {print $2}' || uname -r)

echo "==================================="
echo "  System Monitor Report"
echo "  $DATE"
echo "==================================="

echo ""
echo "### 系统信息"
echo "- 主机名: $HOSTNAME"
echo "- 操作系统: $OS $OS_VERSION"

# CPU
echo ""
echo "### CPU"
if [ "$OS" = "Darwin" ]; then
    CPU_MODEL=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    CPU_NCPU=$(sysctl -n hw.ncpu 2>/dev/null)
    LOAD=$(uptime | awk -F'load averages:' '{print $2}')
    echo "- 型号: ${CPU_MODEL:-unknown}"
    echo "- 核心数: $CPU_NCPU"
    echo "- 负载: $LOAD"
    echo "- CPU: $(top -l 1 -n 2 | awk '/CPU usage/ {print $3}' | tail -1)"
else
    echo "- 型号: $(cat /proc/cpuinfo | grep "model name" | head -1 | cut -d: -f2)"
    echo "- 核心数: $(nproc)"
    echo "- 负载: $(uptime | awk -F'load average:' '{print $2}')"
fi

# 内存
echo ""
echo "### 内存"
if [ "$OS" = "Darwin" ]; then
    MEM_TOTAL=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f GB", $1/1024/1024/1024}')
    vm_stat | awk '/Pages active/ {printf "已用: %.1f GB\n", $3/1024/1024*4096/1024/1024/1024}'
    echo "总计: $MEM_TOTAL"
    echo "空闲: $(vm_stat | awk '/Pages free/ {printf "%.1f GB", $3/1024/1024*4096/1024/1024/1024}')"
else
    free -h | awk '/^Mem/ {print "总计: "$2" 已用: "$3" 空闲: "$4}'
fi

# 磁盘
echo ""
echo "### 磁盘"
df -h | awk 'NR==1 || /\/$|\/data|\/home/ {print "- "$0}'

# 网络连接
echo ""
echo "### 网络连接"
if [ "$OS" = "Darwin" ]; then
    EST=$(lsof -i -P -n 2>/dev/null | grep -c ESTABLISHED || echo "0")
    TIMEWAIT=$(lsof -i -P -n 2>/dev/null | grep -c TIME_WAIT || echo "0")
    LISTEN=$(lsof -i -P -n 2>/dev/null | grep -c LISTEN || echo "0")
else
    EST=$(ss -tunap 2>/dev/null | grep -c ESTAB || echo "0")
    TIMEWAIT=$(ss -tunap 2>/dev/null | grep -c TIME-WAIT || echo "0")
    LISTEN=$(ss -tlnp 2>/dev/null | grep -c LISTEN || echo "0")
fi
echo "- ESTABLISHED: $EST"
echo "- TIME_WAIT: $TIMEWAIT"
echo "- LISTEN: $LISTEN"

# TOP 5 CPU 进程
echo ""
echo "### TOP 5 CPU 进程"
ps aux | sort -rk 3 | head -6 | awk '{printf "%.1f%% %s %s\n", $3, $11, $12}' | column -t

# TOP 5 内存进程
echo ""
echo "### TOP 5 内存进程"
ps aux | sort -rk 4 | head -6 | awk '{printf "%.1f%% %s %s\n", $4, $11, $12}' | column -t

echo ""
echo "==================================="
echo "  Report End"
echo "==================================="
