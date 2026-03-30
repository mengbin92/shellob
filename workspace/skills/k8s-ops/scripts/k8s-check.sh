#!/bin/bash
# k8s-check.sh — Kubernetes 集群快速巡检
# 用法: ./k8s-check.sh [namespace]

NS="${1:-}"

echo "=========================================="
echo "  K8s Cluster Health Check"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 集群版本
echo ""
echo "### 集群版本"
kubectl version --short 2>/dev/null || kubectl version

# Node 状态
echo ""
echo "### Node 状态"
kubectl get nodes -o wide 2>/dev/null || echo "无法获取 Node 信息"

# 资源使用（Node）
echo ""
echo "### Node 资源"
kubectl top nodes 2>/dev/null || echo "metrics-server 未安装或不可用"

# Pod 状态
echo ""
echo "### Pod 状态概览"
if [ -n "$NS" ]; then
    kubectl get pods -n "$NS" -o wide 2>/dev/null
else
    kubectl get pods -A -o wide 2>/dev/null
fi

# 非 Running Pod
echo ""
echo "### ⚠️ 非 Running Pod"
if [ -n "$NS" ]; then
    kubectl get pods -n "$NS" | grep -v "Running\|Completed" || echo "无"
else
    kubectl get pods -A | grep -v "Running\|Completed" || echo "无"
fi

# 警告事件
echo ""
echo "### ⚠️ 警告事件（最近1小时）"
kubectl get events -A --sort-by='.lastTimestamp' 2>/dev/null | grep -i "warning\|error\|fail" | tail -20 || echo "无"

# Service 状态
echo ""
echo "### Service 概览"
if [ -n "$NS" ]; then
    kubectl get svc -n "$NS" 2>/dev/null
else
    kubectl get svc -A 2>/dev/null
fi

# Deployment 状态
echo ""
echo "### Deployment 状态"
if [ -n "$NS" ]; then
    kubectl get deployments -n "$NS" 2>/dev/null
else
    kubectl get deployments -A 2>/dev/null
fi

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
