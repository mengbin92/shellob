#!/bin/bash
# backup-check.sh — 备份状态检查
# 用法: ./backup-check.sh [备份目录]

BACKUP_DIR="${1:-/backup}"

echo "=========================================="
echo "  Backup Status Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

echo ""
echo "### 备份目录"
echo "路径: $BACKUP_DIR"

# 目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ 备份目录不存在"
    exit 1
fi

echo ""
echo "### 备份文件列表"
ls -lth "$BACKUP_DIR" 2>/dev/null | head -20

echo ""
echo "### 备份文件大小统计"
du -sh "$BACKUP_DIR"/*
du -sh "$BACKUP_DIR"

echo ""
echo "### 备份目录磁盘使用"
df -h "$BACKUP_DIR"

echo ""
echo "### 最近的备份文件（最近7天）"
find "$BACKUP_DIR" -type f -mtime -7 -ls 2>/dev/null | head -20 || echo "无"

echo ""
echo "### 需要清理的旧备份（超过30天）"
find "$BACKUP_DIR" -type f -mtime +30 -ls 2>/dev/null || echo "无超过30天的备份"

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
