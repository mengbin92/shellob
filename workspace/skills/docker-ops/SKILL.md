---
name: docker-ops
description: Use when inspecting Docker containers, checking container status, logs, resource usage, or managing Docker images.
---

# Docker Ops

## 概述

Docker 运维 skill。用于容器巡检、故障排查、日志查看、资源监控、镜像管理。

## 核心能力

- 容器状态巡检（非 Up 容器告警）
- 资源占用查看（CPU、内存、网络）
- 日志查看和搜索
- 进入容器调试
- 镜像管理（查看、清理）
- Docker 网络和卷检查
- Docker Compose / Swarm 基本操作

## 命令清单

### 容器列表

```bash
# 列出运行中的容器
docker ps

# 列出所有容器（包括停止的）
docker ps -a

# 格式化输出（易读表格）
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Created}}"

# 只看非 Up 状态的容器
docker ps -a --filter "status=exited"
docker ps -a --filter "status=restarting"

# 按名称过滤
docker ps -a --filter "name=nginx"
```

### 容器资源

```bash
# 实时资源占用（Ctrl+C 退出）
docker stats

# 非实时（一次性）
docker stats --no-stream

# 指定容器
docker stats <container-name>

# 格式化输出
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# 容器进程
docker top <container-name>
```

### 容器日志

```bash
# 查看最后 N 行
docker logs --tail 100 <container>

# 跟踪日志（实时）
docker logs -f <container>

# 最近 N 分钟的日志
docker logs --since 30m <container>

# 时间范围
docker logs --since "2026-03-30T10:00" --until "2026-03-30T11:00" <container>

# 搜索错误
docker logs <container> 2>&1 | grep -E "ERROR|FATAL"

# 带时间戳
docker logs -t <container> --tail 100
```

### 进入容器

```bash
# 进入运行中的容器（bash）
docker exec -it <container> /bin/bash

# 不用 bash（alpine 等精简镜像）
docker exec -it <container> /bin/sh

# 单次命令执行
docker exec <container> ls -la /app

# 指定用户
docker exec -u postgres <container> psql
```

### 容器操作

```bash
# 启动容器
docker start <container>

# 停止容器
docker stop <container>

# 重启容器
docker restart <container>

# 强制停止（卡死时）
docker kill <container>

# 删除容器（先停止）
docker rm <container>

# 强制删除（不停止）
docker rm -f <container>

# 查看容器详细信息
docker inspect <container>

# 查看容器 IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container>

# 查看端口映射
docker port <container>

# 重命名容器
docker rename old_name new_name
```

### 镜像管理

```bash
# 列出镜像
docker images

# 格式化输出
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# 删除悬空镜像（<none>）
docker image prune

# 删除未使用镜像
docker image prune -a

# 强制删除指定镜像
docker rmi <image-id>

# 查看镜像历史
docker history <image-name>

# 拉取镜像
docker pull <image>:<tag>
```

### Docker 磁盘

```bash
# Docker 磁盘使用概览
docker system df

# 详细
docker system df -v

# 清理（删除停止的容器、悬空镜像、未使用网络）
docker system prune

# 清理（包括未使用的卷）
docker system prune --volumes

# 清理所有（⚠️ 慎用）
docker system prune -a --volumes
```

### 网络

```bash
# 列出网络
docker network ls

# 网络详情
docker network inspect <network-name>

# 创建网络
docker network create --driver bridge <network-name>

# 连接容器到网络
docker network connect <network-name> <container>

# 断开连接
docker network disconnect <network-name> <container>
```

### 卷

```bash
# 列出卷
docker volume ls

# 卷详情
docker volume inspect <volume-name>

# 创建卷
docker volume create <volume-name>

# 删除未使用的卷
docker volume prune
```

### Docker Compose

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f

# 重新构建
docker compose build --no-cache

# 强制重新创建
docker compose up -d --force-recreate
```

### Docker Swarm（可选）

```bash
# 查看节点
docker node ls

# 查看服务
docker service ls

# 查看服务任务
docker service ps <service-name>

# 服务日志
docker service logs <service-name>

# 扩缩容
docker service scale <service-name>=3
```

## 巡检清单

执行巡检时，按以下顺序检查：

```
1. docker ps -a → 确认所有容器状态
2. docker stats --no-stream → 确认资源占用正常
3. docker logs --tail 50 <异常容器> → 定位错误
4. docker inspect <异常容器> → 查看详细信息
5. docker system df → 确认磁盘空间
```

## 常见问题

| 问题 | 排查命令 | 可能原因 |
|---|---|---|
| 容器无法启动 | `docker logs <container>` | 配置错误、端口占用、依赖服务未启动 |
| 容器自动退出 | `docker inspect <container>` | 进程退出、健康检查失败、资源不足 |
| 容器卡死 | `docker exec top` | CPU 跑满、死锁、OOM |
| 磁盘满 | `docker system df -v` | 日志过多、镜像堆积、卷未清理 |
| 网络不通 | `docker inspect` + `docker port` | 网络模式错误、端口映射错误 |

## 输出格式

### 巡检报告

```
## Docker 巡检报告

**主机：** hostname
**时间：** YYYY-MM-DD HH:MM
**Docker 版本：** 29.3.1

---

### 容器状态
| 名称 | 状态 | CPU | 内存 | 端口 |
|---|---|---|---|---|
| nginx | Up 2 hours | 0.5% | 120MB | 80:8080 |
| app | **Exited (1)** | - | - | - |

⚠️ 异常容器：app（状态：Exited，退出码：1）

### 资源占用
- 运行中容器：2
- 总 CPU：1.2%
- 总内存：340MB

### Docker 磁盘
- 镜像：1.2GB
- 容器：500MB
- 卷：200MB
- 总计：1.9GB / 50GB（3.8%）

### 建议
1. 清理 app 容器的异常日志
2. 磁盘使用率正常
```

## 注意事项

1. **危险操作先确认** — `docker rm -f`、`docker system prune -a` 等不可逆操作要先确认
2. **日志搜索先缩小范围** — 用 `--since` 或 `--tail` 避免输出过大
3. **exec 进入容器会留下进程** — 调试完成后确认退出
4. **磁盘清理前确认** — 清理前检查是否有重要数据未持久化

## 脚本工具

`scripts/docker-check.sh` — Docker 快速巡检脚本

---

*记录版本：v0.1*
