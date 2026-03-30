#!/bin/bash
# docker-check.sh — Docker 快速巡检
# 用法: ./docker-check.sh

set -e

echo "=========================================="
echo "  Docker Health Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# Docker 版本
echo ""
echo "### Docker 版本"
docker version --format "Docker {{.Server.Version}} ({{.Server.Os}}/{{.Server.Arch}})"

# 容器总数
echo ""
echo "### 容器概览"
RUNNING=$(docker ps -q | wc -l | tr -d ' ')
TOTAL=$(docker ps -aq | wc -l | tr -d ' ')
STOPPED=$(docker ps -aq --filter "status=exited" | wc -l | tr -d ' ')
echo "运行中: $RUNNING / 总计: $TOTAL（停止: $STOPPED）"

# 非 Up 状态的容器
echo ""
echo "### ⚠️ 异常容器"
docker ps -a --filter "status=exited" --filter "status=restarting" --format "table {{.Names}}\t{{.Status}}\t{{.ExitCode}}" 2>/dev/null || echo "无"

# 资源占用
echo ""
echo "### 资源占用（运行中容器）"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "无运行中容器"

# Docker 磁盘
echo ""
echo "### Docker 磁盘使用"
docker system df 2>/dev/null | head -10

# TOP 5 大镜像
echo ""
echo "### TOP 5 大镜像"
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" 2>/dev/null | sort -rh -k2 | head -5

# 悬空镜像
DANGLING=$(docker images -f "dangling=true" -q | wc -l | tr -d ' ')
echo ""
echo "### 悬空镜像: $DANGLING 个"
if [ "$DANGLING" -gt 0 ]; then
    echo "建议运行: docker image prune"
fi

# 网络
echo ""
echo "### Docker 网络"
docker network ls --format "{{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>/dev/null

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
