# HEARTBEAT.md — Shellob 定时巡检配置

_定义定时巡检任务，异常时推送报告，正常时保持安静。_

---

## 巡检任务清单

### 每小时（高优先级）

**1. Docker 容器状态**
```bash
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -v "Up" 
```
> 异常：列出非 Up 状态的容器，报告名称和状态

**2. 告警检查**
- 检查是否有未处理的告警（可配置 webhook 或日志）
- 异常时推送到配置的告警渠道

---

### 每6小时（中优先级）

**3. 系统资源报告**

采集以下数据，生成 Markdown 报告：

| 指标 | 命令 |
|---|---|
| CPU | `top -l 1 -n 2 \| head -20` |
| 内存 | `vm_stat \| head -10` |
| 磁盘 | `df -h` |
| Docker | `docker stats --no-stream` |

> 异常值（CPU > 80%、内存 > 90%、磁盘 > 85%）标粗突出

---

### 每天（低优先级）

**4. 日志异常扫描**
```bash
# 扫描最近 24 小时的 ERROR 日志
grep -r "ERROR" /var/log/**/*.log 2>/dev/null | tail -50
```
> 统计错误数量，列出 TOP 10 错误类型

**5. Docker 镜像清理检查**
```bash
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "<none>" 
```
> 列出 dangling 镜像，评估是否需要清理

**6. 备份检查（需配置）**
- 检查备份文件是否存在
- 检查备份文件更新时间是否在合理范围内

---

## 巡检状态记录

状态文件：`memory/heartbeat-state.json`

```json
{
  "lastChecks": {
    "docker": 1703275200,
    "system": 1703260800,
    "logs": 1703232000
  }
}
```

---

## 告警推送

配置告警推送渠道（通过环境变量或 TOOLS.md）：

```bash
SHELLOB_ALERT_WEBHOOK=https://your-webhook.com/alert
```

推送格式：
```
[Shellob 巡检告警] <时间>
<告警类型>
<告警内容>
<处理建议>
```

---

## 执行原则

1. **正常 → 沉默** — 不发无意义的"一切正常"
2. **异常 → 报告** — 推送结构化报告，标明异常项
3. **严重 → 多次确认** — P0 级别告警可重复推送

---

_巡检配置随运维需求调整。建议先用 crontab 或 OpenClaw cron 功能实现。_
