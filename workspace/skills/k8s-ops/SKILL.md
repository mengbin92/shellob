---
name: k8s-ops
description: Use when inspecting Kubernetes resources — pods, services, deployments, logs, or troubleshooting K8s issues.
---

# Kubernetes Ops

## 概述

Kubernetes 运维 skill。用于 K8s 集群资源巡检、Pod 排查、日志查看、扩缩容操作。

**前置条件：** 已配置 `~/.kube/config`，kubectl 可访问集群。

## 核心能力

- Pod / Deployment / Service / Ingress 状态查看
- Pod 日志查看和搜索
- 资源使用（CPU / 内存）
- 事件查看
- 扩缩容操作
- ConfigMap / Secret 查看
- Node 状态
- 常见问题定位

## 命令清单

### 集群信息

```bash
# 集群信息
kubectl cluster-info

# 集群版本
kubectl version

# Node 列表
kubectl get nodes -o wide

# Node 详情
kubectl describe node <node-name>
```

### Pod

```bash
# 列出所有 Pod（默认 namespace）
kubectl get pods

# 列出指定 namespace
kubectl get pods -n <namespace>

# 列出所有 namespace 的 Pod
kubectl get pods --all-namespaces

# Pod 详细信息
kubectl describe pod <pod-name> -n <namespace>

# Pod IP 和所在节点
kubectl get pods -o wide

# 按标签筛选
kubectl get pods -l app=nginx

# 跨 namespace 查看 Pod 分布
kubectl get pods -A | grep <keyword>
```

### 日志

```bash
# 查看日志（最后100行）
kubectl logs <pod-name> --tail=100

# 实时跟踪
kubectl logs -f <pod-name>

# 最近 30 分钟
kubectl logs --since=30m <pod-name>

# 指定容器（多容器 Pod）
kubectl logs <pod-name> -c <container-name> --tail=100

# 搜索错误
kubectl logs <pod-name> | grep -E "ERROR|FATAL"

# 导出日志到文件
kubectl logs <pod-name> --tail=1000 > pod.log
```

### Deployment

```bash
# 列出 Deployment
kubectl get deployments -n <namespace>

# Deployment 详情
kubectl describe deployment <deploy-name> -n <namespace>

# 扩缩容
kubectl scale deployment <deploy-name> --replicas=3 -n <namespace>

# 更新镜像
kubectl set image deployment/<deploy-name> <container>=<image>:<tag> -n <namespace>

# 查看 rollout 状态
kubectl rollout status deployment/<deploy-name> -n <namespace>

# 回滚到上一版本
kubectl rollout undo deployment/<deploy-name> -n <namespace>

# 回滚到指定版本
kubectl rollout undo deployment/<deploy-name> --to-revision=2 -n <namespace>
```

### Service

```bash
# 列出 Service
kubectl get svc -n <namespace>

# Service 详情
kubectl describe svc <svc-name> -n <namespace>

# 查看 Service 的 Endpoint
kubectl get endpoints <svc-name> -n <namespace>

# 测试 Service 连通性（临时 Pod）
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -qO- http://<svc-name>:<port>
```

### Ingress

```bash
# 列出 Ingress
kubectl get ingress -n <namespace>

# Ingress 详情
kubectl describe ingress <ingress-name> -n <namespace>
```

### ConfigMap / Secret

```bash
# 列出 ConfigMap
kubectl get configmap -n <namespace>

# 查看 ConfigMap
kubectl get configmap <cm-name> -n <namespace> -o yaml

# 列出 Secret
kubectl get secret -n <namespace>

# 查看 Secret（需解码）
kubectl get secret <secret-name> -n <namespace> -o yaml
kubectl view-secret <secret-name> -n <namespace>  # 需要 secret-manager 插件
```

### 资源使用

```bash
# Pod 资源使用（需 metrics-server）
kubectl top pods -n <namespace>

kubectl top nodes

# Pod 的 CPU/内存请求和限制
kubectl get pods -n <namespace> -o json | jq '.items[] | {name: .metadata.name, cpu: .spec.containers[].resources}'
```

### 事件

```bash
# 集群级事件
kubectl get events --all-namespaces | sort --key=4 | tail -50

# 特定 namespace 事件
kubectl get events -n <namespace>

# 最近警告事件
kubectl get events --all-namespaces | grep -i warning
```

### 调试

```bash
# 进入容器（如 kubectl exec 不可用，先确认容器状态）
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# 复制文件
kubectl cp <namespace>/<pod-name>:/path/in/container/file.txt ./file.txt

# Port-forward（本地访问）
kubectl port-forward <pod-name> 8080:80 -n <namespace>

# 临时 Pod 调试
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
```

### YAML 导出

```bash
# 导出 Pod YAML
kubectl get pod <pod-name> -n <namespace> -o yaml

# 导出 Deployment YAML
kubectl get deployment <deploy-name> -n <namespace> -o yaml

# 导出并保存
kubectl get pod <pod-name> -n <namespace> -o yaml > pod.yaml
```

## 巡检清单

```
1. kubectl get pods -A → 确认所有 Pod Running
2. kubectl top nodes → 确认节点资源
3. kubectl get events --all-namespaces | grep Warning → 确认警告事件
4. kubectl get svc -A → 确认 Service 状态
5. kubectl top pods -n <ns> → 确认异常 Pod 资源
```

## 常见问题

| 问题 | 排查命令 | 可能原因 |
|---|---|---|
| Pod 一直 Pending | `kubectl describe pod` Events | 资源不足、调度失败、PV 未绑定 |
| Pod 一直 Waiting | `kubectl describe pod` Events | 镜像拉取失败、Liveness 探针失败 |
| Pod CrashLoopBackOff | `kubectl logs --previous` | 进程报错、OOM、配置错误 |
| Service 无 Endpoint | `kubectl describe svc` + `kubectl get pods -o wide` | Selector 不匹配、后端 Pod 未运行 |
| CPU / 内存高 | `kubectl top pod` | 应用负载高、内存泄漏 |

## 输出格式

```
## K8s 巡检报告

**集群：** prod-cluster
**时间：** YYYY-MM-DD HH:MM

---

### Pod 状态
| Namespace | Pod | Status | Restarts | Node |
|---|---|---|---|---|
| default | nginx-xxx | Running | 0 | node-1 |
| kube-system | coredns-xxx | **CrashLoopBackOff** | 5 | node-2 |

⚠️ 异常：coredns-xxx（CrashLoopBackOff）

### 资源使用（TOP 5）
| Pod | CPU | Memory |
|---|---|---|
| app-xxx | 850m | 512Mi |
...

### 最近警告事件
```
30m  Warning  BackOff  pod/app-xxx  Back-off restarting failed container
```

### 建议
1. 检查 coredns 日志：`kubectl logs coredns-xxx -n kube-system --previous`
2. 节点 node-2 内存使用率 87%，注意监控
```

## 注意事项

1. **跨 namespace 操作要加 `-n`** 或 `--all-namespaces`，避免遗漏
2. **删除操作先确认** — `kubectl delete` 不可逆
3. **生产环境改 Deployment 先加金丝雀** — 逐步灰度
4. **Secret 数据 base64 编码** — 查看时需解码

## 脚本工具

`scripts/k8s-check.sh` — K8s 集群快速巡检

---

*记录版本：v0.1*
