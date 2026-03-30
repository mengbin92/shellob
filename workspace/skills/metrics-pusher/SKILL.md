---
name: metrics-pusher
description: Use when collecting system metrics and pushing them to Prometheus PushGateway or generating Prometheus-format metrics for Grafana dashboards.
---

# Metrics Pusher

## 概述

指标采集与推送 skill。将系统指标（CPU、内存、磁盘、Docker）格式化为 Prometheus 指标，或直接推送到 PushGateway，供 Grafana 展示和告警。

## 核心能力

- 采集系统指标（CPU、内存、磁盘、网络）
- 采集 Docker 容器指标
- 格式化为 Prometheus exposition format
- 推送到 Prometheus PushGateway
- 生成 Grafana dashboard JSON
- 本地 HTTP 服务暴露指标（可选）

## 前置条件

```bash
# 安装 prometheus PushGateway 客户端（pushgateway）
# macOS
brew install prometheus

# 或直接下载
# https://github.com/prometheus/pushgateway/releases

# 验证
pushgateway --version
```

## 命令清单

### 1. Prometheus 指标格式

Prometheus exposition format（文本格式）：

```
# HELP <metric_name> <description>
# TYPE <metric_name> <type>
<metric_name>{<label_name>="<label_value>"} <value>
```

示例：
```
# HELP shellob_cpu_usage_percent CPU usage percent
# TYPE shellob_cpu_usage_percent gauge
shellob_cpu_usage_percent{host="prod-01"} 87.5

# HELP shellob_memory_usage_percent Memory usage percent
# TYPE shellob_memory_usage_percent gauge
shellob_memory_usage_percent{host="prod-01"} 72.3
```

### 2. 指标采集命令

```bash
# CPU 使用率（macOS）
top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%'

# CPU 使用率（Linux）
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%us'

# 内存使用率（macOS）
vm_stat | awk '/Pages active/ {active=$3} /Pages wired/ {wired=$4} /Pages free/ {free=$3} END {total=active+wired+free; printf "%.1f", (total-free)/total*100}'

# 内存使用率（Linux）
free | awk '/^Mem:/ {printf "%.1f", ($3/$2)*100}'

# 磁盘使用率
df -h / | awk 'NR==2 {print $5}' | tr -d '%'

# Docker 容器数量
docker ps -q | wc -l | tr -d ' '

# Docker 总内存使用
docker stats --no-stream --format "{{.MemUsage}}" | awk '{sum+=$1} END {print sum}'

# 网络连接数
lsof -i -P -n 2>/dev/null | grep -c ESTABLISHED || echo 0
```

### 3. 推送到 PushGateway

```bash
# 安装 pushgateway
brew install prometheus

# 启动 pushgateway（默认端口 9091）
pushgateway &

# 推送指标（单个指标）
echo "shellob_cpu_usage_percent{host=\"$(hostname)\"} $(top -l 1 | grep 'CPU usage' | awk '{print $3}' | tr -d '%')" | curl --data-binary @- http://localhost:9091/metrics/job/shellob

# 推送多指标文件
cat <<'EOF' | curl --data-binary @- http://localhost:9091/metrics/job/shellob/instance/$(hostname)
# HELP shellob_cpu_usage_percent CPU usage percent
# TYPE shellob_cpu_usage_percent gauge
shellob_cpu_usage_percent{host="$(hostname)"} 87.5
# HELP shellob_memory_usage_percent Memory usage percent
# TYPE shellob_memory_usage_percent gauge
shellob_memory_usage_percent{host="$(hostname)"} 72.3
EOF

# 带标签推送
cat <<'EOF' | curl --data-binary @- http://localhost:9091/metrics/job/shellob/instance/prod-01/env/production
shellob_cpu_usage_percent 87.5
shellob_memory_usage_percent 72.3
shellob_disk_usage_percent 65.0
EOF

# 查看 pushgateway 上的指标
curl http://localhost:9091/metrics | grep shellob

# 删除推送的指标
curl -X DELETE http://localhost:9091/metrics/job/shellob/instance/prod-01
```

### 4. Prometheus 配置

在 Prometheus server 端添加 PushGateway scrape 配置：

```yaml
# /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'shellob'
    static_configs:
      - targets: ['localhost:9091']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
```

### 5. Grafana Dashboard

通过 Import 或手动创建，Key metrics：

| Metric | Type | Panel |
|---|---|---|
| `shellob_cpu_usage_percent` | Gauge | CPU 使用率 |
| `shellob_memory_usage_percent` | Gauge | 内存使用率 |
| `shellob_disk_usage_percent` | Gauge | 磁盘使用率 |
| `shellob_docker_running_containers` | Gauge | 运行容器数 |
| `shellob_docker_total_memory_mb` | Gauge | Docker 总内存 |
| `shellob_network_connections` | Gauge | 网络连接数 |

### 6. 告警规则（Prometheus）

```yaml
# /etc/prometheus/rules/shellob.yml
groups:
  - name: shellob_alerts
    rules:
      - alert: HighCPU
        expr: shellob_cpu_usage_percent > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU on {{ $labels.instance }}"

      - alert: HighMemory
        expr: shellob_memory_usage_percent > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High Memory on {{ $labels.instance }}"

      - alert: DiskSpaceLow
        expr: shellob_disk_usage_percent > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space low on {{ $labels.instance }}"
```

### 7. 定时推送（Cron）

```bash
# 每分钟推送一次
# crontab -e
* * * * * /path/to/scripts/push-metrics.sh >> /var/log/shellob-metrics.log 2>&1
```

## 脚本工具

`scripts/collect-metrics.sh` — 采集所有指标并输出 Prometheus 格式

`scripts/push-metrics.sh` — 采集 + 推送到 PushGateway

`scripts/grafana-dashboard.json` — Grafana Dashboard 模板

## 输出格式

推送到 PushGateway 后，可在 Grafana 中查看：

```
## 指标推送报告

**主机：** prod-01
**时间：** YYYY-MM-DD HH:MM:SS
**PushGateway：** localhost:9091

---

### 已推送指标
| 指标 | 值 | 类型 |
|---|---|---|
| shellob_cpu_usage_percent | 87.5% | gauge |
| shellob_memory_usage_percent | 72.3% | gauge |
| shellob_disk_usage_percent | 65.0% | gauge |
| shellob_docker_running_containers | 5 | gauge |
| shellob_network_connections | 142 | gauge |

### 告警状态
- HighCPU：✅ 正常（87.5% < 80%）
- HighMemory：✅ 正常（72.3% < 90%）
- DiskSpaceLow：✅ 正常（65.0% < 85%）
```

## 注意事项

1. **PushGateway 无认证** — 生产环境用防火墙限制访问
2. **指标被覆盖** — PushGateway 是覆盖式推送，同 job/instance 会覆盖
3. **单位一致** — CPU/内存/磁盘统一用百分比，避免混淆
4. **合理标签** — 标签不要过多，影响查询性能
5. **推送失败要记录** — 推送失败时写日志，便于排查

## 部署检查清单

- [ ] PushGateway 已安装并启动
- [ ] Prometheus 已配置 PushGateway scrape
- [ ] Grafana 已导入 Dashboard
- [ ] 告警规则已配置
- [ ] Cron 任务已设置
- [ ] 日志目录已创建

---

*记录版本：v0.1*
