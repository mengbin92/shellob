---
name: log-analyzer
description: Use when searching, filtering, or analyzing log files for errors, patterns, or anomalies.
---

# Log Analyzer

## 概述

日志分析 skill。用于快速定位问题、统计异常、追踪链路。

## 核心能力

- 关键字/正则搜索
- 时间范围过滤
- 错误模式识别（ERROR、FATAL、Exception、panic）
- 日志统计（TOP N、出现频率）
- 多文件聚合

## 命令清单

### 基础搜索

```bash
# 搜索关键字（支持正则）
grep -E "ERROR|FATAL" /path/to/log

# 递归搜索 .log 文件
grep -r --include="*.log" "ERROR" /var/log/

# 忽略大小写
grep -i "exception" /path/to/log
```

### 时间范围过滤（awk）

```bash
# 过滤时间范围（示例：2026-03-30 10:00~11:00）
awk '/2026-03-30 10:00/,/2026-03-30 11:00/' /path/to/app.log

# 组合：时间范围 + 关键字
awk '/2026-03-30 10:00/,/2026-03-30 11:00/ && /ERROR/' /path/to/app.log
```

### 错误统计

```bash
# 统计 ERROR 行数
grep -c ERROR /path/to/log

# 统计 TOP 5 错误类型（假设错误在第5列）
grep ERROR app.log | cut -d' ' -f5 | sort | uniq -c | sort -rn | head -5

# 统计每种错误出现次数
grep -oE "error\[code=[0-9]+\]" app.log | sort | uniq -c | sort -rn

# 统计最近 N 分钟的错误趋势
grep "ERROR" app.log | awk '{print $4}' | cut -d: -f1 | sort | uniq -c
```

### 日志查看（分页）

```bash
# 查看最后 N 行
tail -n 100 /path/to/log

# 实时跟踪（Ctrl+C 退出）
tail -f /path/to/log

# 查看最近 N 分钟的日志
tail -n 1000 /path/to/log | grep "$(date -v-30M '+%H:%M')"

# 分页查看
less +G /path/to/log
```

### 压缩日志处理

```bash
# 解压 .gz 日志并搜索
zcat /path/to/log.gz | grep "ERROR"

# 解压并统计
zcat /path/to/log.gz | grep -c ERROR

# 搜索多个压缩日志
zcat -f /path/to/log*.gz | grep "ERROR"
```

### JSON 日志（jq）

```bash
# 提取 error 字段
jq 'select(.level=="error")' app.json.log

# 统计错误级别分布
jq -r '.level' app.json.log | sort | uniq -c | sort -rn

# 提取时间戳和错误信息
jq -r '"\(.timestamp) \(.message)"' app.json.log | grep ERROR
```

### 访问日志统计

```bash
# TOP 10 请求 IP
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# TOP 10 请求 URL
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -10

# 状态码分布
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 慢请求（按响应时间，假设第 N 列是响应时间）
awk '$NF > 5 {print}' access.log | head -20
```

### Docker 容器日志

```bash
# 查看容器日志（最后100行）
docker logs --tail 100 <container>

# 跟踪日志
docker logs -f <container>

# 搜索错误
docker logs <container> 2>&1 | grep -E "ERROR|FATAL"

# 时间范围
docker logs --since "2026-03-30T10:00" --until "2026-03-30T11:00" <container>
```

### K8s Pod 日志

```bash
# 查看日志
kubectl logs <pod-name> --tail=100

# 跟踪日志
kubectl logs -f <pod-name>

# 多容器选择
kubectl logs <pod-name> -c <container-name> --tail=100

# 搜索错误
kubectl logs <pod-name> | grep -E "ERROR|FATAL"

# 最近 N 分钟
kubectl logs --since=30m <pod-name>
```

## 输出格式

分析完成后，按以下结构输出：

```
## 日志分析报告

**文件：** /path/to/log
**时间范围：** YYYY-MM-DD HH:MM ~ HH:MM
**关键字：** ERROR|FATAL

### 摘要
- 总行数：N
- 错误行数：N（占比 X%）
- 错误类型：N 种

### TOP 5 错误
1. `error_code=500` — 120 次
2. `null pointer` — 45 次
...

### 最近错误（示例）
```
10:15:32 ERROR [service] Connection timeout
10:15:33 ERROR [db] Query failed
```

### 结论
可能原因：...
建议排查：...
```

## 常见模式

| 模式 | 含义 | 排查方向 |
|---|---|---|
| `OutOfMemoryError` | 内存溢出 | 堆内存配置、内存泄漏 |
| `Connection refused` | 连接被拒 | 服务未启动、端口不通、防火墙 |
| `Connection timeout` | 连接超时 | 网络问题、对端负载高 |
| `SQLException` | 数据库异常 | SQL 错误、连接池满 |
| `401 Unauthorized` | 认证失败 | Token 过期、权限不足 |
| `503 Service Unavailable` | 服务不可用 | 后端挂掉、限流 |

## 注意事项

1. 大文件优先用 `grep -c` 统计行数，避免全量读取
2. 压缩日志用 `zcat -f` 处理多个文件
3. 敏感信息（密码、Token）出现时要脱敏
4. Docker/K8s 日志优先用原生命令，效率更高

## 脚本工具

辅助脚本放在 `scripts/` 目录：
- `loggrep.sh` — 快速搜索常用错误模式
- `logstat.sh` — 日志统计报告生成

---

*记录版本：v0.1*
