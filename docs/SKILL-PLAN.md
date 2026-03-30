# Shellob Skill 开发规划

## Skill 开发规范

每个 Skill 是一个独立目录，放在 `workspace/skills/` 下，结构如下：

```
skill-name/
├── SKILL.md          # 核心定义：描述、触发条件、使用方法
├── scripts/          # 辅助脚本（如有）
├── references/       # 参考文档（如有）
└── state/            # 状态文件（如有）
```

### SKILL.md 模板

```markdown
# Skill 名称

## 描述
这个 Skill 做什么。

## 触发条件
什么情况下使用这个 Skill。

## 使用方法
用户如何调用。

## 命令清单
- 命令1：用做什么
- 命令2：用于做什么

## 输出格式
结果以什么形式返回。

## 注意事项
风险点、限制条件等。
```

---

## P0 — 必装（影响核心排查能力）

### 1. log-analyzer（日志分析）

**目标：** 快速定位问题，节省排查时间

**核心能力：**
- 多文件关键字搜索（grep + 正则）
- 时间范围过滤
- 错误模式识别（ERROR、FATAL、Exception）
- 日志统计（TOP N 错误、访问量）
- 日志聚合（多主机）

**命令示例：**
```bash
# 搜索错误
grep -E "ERROR|FATAL" /var/log/**/*.log

# 时间范围
awk '/2026-03-30 10:/ && /ERROR/' app.log

# 统计 TOP 5 错误
grep ERROR app.log | cut -d' ' -f5 | sort | uniq -c | sort -rn | head -5
```

---

### 2. system-monitor（系统监控）

**目标：** 随时掌握机器健康状态

**核心能力：**
- CPU / 内存 / 磁盘 / 网络 采集
- 历史基线对比
- 阈值告警
- Markdown 报告生成

**命令示例：**
```bash
# CPU 和内存
top -l 1 -n 5 | head -20

# 磁盘
df -h

# 网络连接
lsof -i -P -n | head -30
```

---

### 3. docker-ops（Docker 运维）

**目标：** 容器日常巡检和故障排查

**核心能力：**
- 容器列表（状态、资源占用）
- 日志查看（支持 tail、since）
- 进入容器调试
- 镜像清理
- 异常退出检测

**命令示例：**
```bash
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker stats --no-stream
docker logs --tail 100 --since 30m <container>
```

---

## P1 — 重要（常规运维高频）

### 4. k8s-ops（Kubernetes 运维）

**核心能力：**
- Pod/Service/Deployment 状态排查
- Pod 日志查看
- 资源使用（CPU/内存）
- 扩缩容操作
- 事件查看

**命令示例：**
```bash
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name> --tail=100
kubectl top pod
```

---

### 5. network-diag（网络诊断）

**核心能力：**
- 端口连通性（TCP/UDP）
- HTTP 健康检查
- DNS 解析验证
- 延迟测试
- 路由追踪（traceroute）

**命令示例：**
```bash
curl -I https://example.com
nc -zv host port
nslookup example.com
curl -w "Time: %{time_total}s\n" https://example.com
```

---

### 6. db-ops（数据库运维）

**核心能力：**
- 连接数、会话管理
- 慢查询分析
- 表空间/索引状态
- 基本备份/恢复

**注意：** 需要配置数据库连接信息，支持 MySQL/PostgreSQL/MongoDB/Redis

---

## P2 — 建议（完善运维体系）

### 7. web-server（Nginx/Web 运维）

**核心能力：**
- Nginx 配置校验
- Nginx 日志分析（TOP IP、TOP URL、状态码统计）
- SSL 证书检查（过期时间）
- Apache（如果使用）

---

### 8. backup-restore（备份恢复）

**核心能力：**
- 备份方案生成
- 数据库备份脚本
- 文件 rsync 备份
- 恢复演练指导

---

### 9. security-baseline（安全基线）

**核心能力：**
- 用户/组审计
- 防火墙规则检查
- SSH 配置审计
- 异常文件检测（SUID、隐藏进程）

---

## P3 — 可选（特定场景）

### 10. alert-sop（告警处理 SOP）

**核心能力：**
- 常见告警决策树
- 告警分级（P0/P1/P2/P3）
- 处理步骤引导

---

## Skill 优先级开发顺序

```
log-analyzer     → system-monitor   → docker-ops
       ↓
     k8s-ops    → network-diag     → db-ops
       ↓
    web-server  → backup-restore    → security-baseline
       ↓
     alert-sop
```

---

*规划版本：v0.1*
