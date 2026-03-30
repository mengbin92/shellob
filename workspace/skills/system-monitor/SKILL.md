---
name: system-monitor
description: Use when checking system resource status — CPU, memory, disk, network, or generating monitoring reports.
---

# System Monitor

## 概述

系统监控 skill。采集 CPU、内存、磁盘、网络状态，生成可读的 Markdown 监控报告。

## 核心能力

- 系统资源采集（CPU、内存、磁盘、网络）
- 进程排名（CPU/内存占用）
- 磁盘使用分析
- 网络连接统计
- Markdown 报告生成
- 阈值告警（CPU > 80%、内存 > 90% 等）

## 命令清单

### CPU

```bash
# macOS — CPU 使用（单次采样）
top -l 1 -n 5 | head -20

# Linux — CPU 使用
top -bn1 | head -20

# CPU 核心数
sysctl -n hw.ncpu          # macOS
nproc                        # Linux

# CPU 型号
sysctl -n machdep.cpu.brand_string  # macOS
cat /proc/cpuinfo | grep "model name" | head -1  # Linux
```

### 内存

```bash
# macOS — 内存状态
vm_stat | head -10

# Linux — 内存使用
free -h

# 内存详情（macOS）
top -l 1 -n 5 | grep "PhysMem"

# 交换内存
sysctl vm.swapusage  # macOS
cat /proc/swaps       # Linux
```

### 磁盘

```bash
# 磁盘使用率（所有挂载点）
df -h

# 指定目录大小
du -sh /path/to/dir

# TOP 10 大目录
du -h --max-depth=2 /path 2>/dev/null | sort -rh | head -10

# inode 使用（Linux）
df -i

# 磁盘 I/O（Linux）
iostat -x 1 1
```

### 网络

```bash
# 网络连接统计（macOS）
lsof -i -P -n | head -30

# 网络连接（Linux）
ss -tunap

# 端口占用
lsof -i :8080  # macOS
netstat -tlnp :8080  # Linux

# 网卡流量（macOS）
netstat -ib | head -10

# 网卡流量（Linux）
cat /proc/net/dev

# ARP 表
arp -a

# 路由表
route -n get default  # macOS
ip route show          # Linux
```

### 进程

```bash
# TOP 10 CPU 进程
ps aux | sort -rk 3 | head -11

# TOP 10 内存进程
ps aux | sort -rk 4 | head -11

# 指定用户进程
ps -u username

# 僵尸进程
ps aux | grep -w Z

# 线程数
ps -M PID

# 进程树
ps auxf
```

### 系统负载

```bash
# 负载均值（macOS）
uptime

# 负载均值（Linux）
uptime
cat /proc/loadavg

# 运行时间
uptime -p

# 系统时间
date
```

### Docker 资源

```bash
# 容器资源占用
docker stats --no-stream

# 容器列表（状态）
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Docker 磁盘使用
docker system df
```

## 输出格式：监控报告

```
## 系统监控报告

**主机：** hostname
**时间：** YYYY-MM-DD HH:MM
**系统：** macOS 14.x / Ubuntu 22.04

---

### CPU
- 型号：Apple M2 Pro / Intel i7-9700K
- 核心数：12（8P+4E）/ 8
- 当前负载：2.3, 1.8, 1.5（1/5/15分钟）
- **⚠️ CPU 使用率：87%**（超过 80% 阈值）

### 内存
- 总计：32 GB
- 已用：26 GB（81%）
- 空闲：6 GB
- **⚠️ 内存使用率：81%**（超过 80% 阈值）

### 磁盘
| 挂载点 | 总计 | 已用 | 使用率 |
|---|---|---|---|
| / | 500G | 350G | 70% |
| /data | 1T | 850G | 85% |

### 网络
- 连接数：142
- TIME_WAIT：23
- ESTABLISHED：89

### TOP 5 进程（CPU）
1. chrome — 15.2%
2. docker — 8.3%
3. node — 5.1%
...

### 结论
- 内存使用率偏高，建议关注
- /data 磁盘使用率达 85%，注意清理
```

## 阈值告警

| 指标 | 警告 | 严重 |
|---|---|---|
| CPU | > 80% | > 95% |
| 内存 | > 80% | > 95% |
| 磁盘 | > 80% | > 95% |
| INODE | > 80% | > 95% |

**告警格式：**
```
[告警] <指标> <当前值>（<阈值>）
可能原因：...
建议操作：...
```

## 脚本工具

`scripts/sysreport.sh` — 生成完整 Markdown 监控报告

---

*记录版本：v0.1*
