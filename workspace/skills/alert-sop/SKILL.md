---
name: alert-sop
description: Use when receiving system alerts — provides decision trees for common alert types like high CPU, memory OOM, disk full, service down, or network issues.
---

# Alert SOP

## 概述

告警处理标准操作程序。提供常见告警的决策树、分级标准、处理步骤。遇到告警时优先使用此 Skill。

## 核心能力

- 告警分级（P0/P1/P2/P3）
- 常见告警类型处理决策树
- 紧急响应步骤
- 升级路径
- 事后复盘指导

## 告警分级标准

| 级别 | 定义 | 响应时间 | 示例 |
|---|---|---|---|
| **P0** | 服务完全不可用、数据丢失风险 | 5 分钟 | 网站无法访问、数据库挂了 |
| **P1** | 核心功能受损、部分不可用 | 15 分钟 | 登录失败、支付失败 |
| **P2** | 性能下降、非核心功能异常 | 1 小时 | 响应慢、偶发超时 |
| **P3** | 警告、潜在风险 | 4 小时 | 磁盘接近满、证书快过期 |

---

## 常见告警处理

### 1. CPU 使用率过高

**触发条件：** CPU > 80%（持续 5 分钟）

```
判断流程：
1. 确认是持续高还是瞬时高？
   └─ 瞬时高 → 观察，不处理
   └─ 持续高 → 进入步骤 2

2. 确认哪个进程导致？
   └─ 业务进程 → 分析业务负载，考虑扩容
   └─ 非业务进程 → 检查是否为攻击或挖矿

3. 是否有外部请求异常？
   └─ 是 → 检查上游服务
   └─ 否 → 本机分析
```

**处理步骤：**
```bash
# 1. 确认 CPU 使用率
top -l 1 -n 3

# 2. 找到 CPU 占用最高的进程
ps aux --sort=-%cpu | head -10

# 3. 如果是业务进程，检查请求量
docker ps
curl -s -o /dev/null -w "%{http_code}" http://localhost/health

# 4. 如果是非业务进程，检查网络
lsof -i -P -n | grep -v LISTEN

# 5. 临时处理：限制进程 CPU（cgroup 或 kill）
# kill <pid>  # 慎用，先确认进程
```

**常见原因：**
- 业务流量突增（促销、爬虫、攻击）
- 程序死循环或内存泄漏
- 定时任务重叠执行
- 攻击或挖矿病毒

---

### 2. 内存 OOM / 使用率过高

**触发条件：** 内存 > 90% 或 OOM Killer 触发

```
判断流程：
1. 是否发生 OOM（进程被 kill）？
   └─ 是 → 查看 dmesg 或 /var/log/messages
   └─ 否 → 进入步骤 2

2. 确认哪个进程内存占用最高
   └─ 业务进程 → 分析内存泄漏或正常增长
   └─ 非业务进程 → 检查是否为攻击
```

**处理步骤：**
```bash
# 1. 查看内存使用
top -l 1 -n 5 | grep "PhysMem"

# 2. 查看 OOM 日志（Linux）
dmesg | grep -i "out of memory"
cat /var/log/messages | grep -i oom

# 3. 查看内存最高的进程
ps aux --sort=-%mem | head -10

# 4. Docker 内存占用
docker stats --no-stream

# 5. 临时处理：杀进程
kill -15 <pid>   # 优雅停止
kill -9 <pid>    # 强制停止（最后手段）
```

**常见原因：**
- 内存泄漏
- JVM 堆内存配置过小
- 缓存未清理
- 同时运行太多进程

---

### 3. 磁盘空间不足

**触发条件：** 磁盘使用率 > 85%

```
判断流程：
1. 确认是哪个分区满了？
   └─ / → 系统盘，可能日志或临时文件
   └─ /data → 数据盘，可能是数据文件
   └─ /var → 日志文件

2. 确认占用最大的目录/文件
```

**处理步骤：**
```bash
# 1. 查看磁盘使用
df -h

# 2. 找到大文件和大目录
du -h --max-depth=2 / | sort -rh | head -20

# 3. 查看日志目录大小
du -sh /var/log/*
du -sh /usr/local/var/log/*

# 4. 查看大文件
find / -type f -size +100M 2>/dev/null | head -10

# 5. 清理日志
truncate -s 0 /var/log/nginx/access.log
docker system prune -f

# 6. 清理旧备份
find /backup -type f -mtime +30 -delete
```

**常见原因：**
- 日志文件未轮转，增长过大
- Docker 镜像/容器堆积
- 备份文件未清理
- 大数据文件

---

### 4. 服务不可用（HTTP 5xx）

**触发条件：** HTTP 5xx 错误率 > 1%

```
判断流程：
1. 确认是自身服务问题还是上游问题？
   └─ 上游正常、自身 5xx → 服务自身问题
   └─ 上游也异常 → 上游问题

2. 确认是代码问题还是资源问题？
   └─ CPU/内存正常 → 代码问题
   └─ CPU/内存高 → 资源问题
```

**处理步骤：**
```bash
# 1. 检查服务状态
curl -I http://localhost/health

# 2. 查看错误日志
docker logs <container> --tail 50 | grep -E "ERROR|FATAL"

# 3. 检查资源
docker stats --no-stream
top

# 4. 检查上游依赖
curl -I http://upstream:8080/health

# 5. 如果是代码问题，查看最近的部署
kubectl rollout history deployment/<name>

# 6. 回滚（如果需要）
kubectl rollout undo deployment/<name>
```

---

### 5. 进程/容器退出

**触发条件：** 容器或进程非预期退出

```
判断流程：
1. 查看退出原因
   └─ Exit Code 0 → 正常退出，可能是 restart policy 触发
   └─ Exit Code 1 → 应用程序错误
   └─ Exit Code 137 → OOM Kill 或被 kill -9
   └─ Exit Code 143 → 被 kill -15（优雅停止）
```

**处理步骤：**
```bash
# 1. Docker 容器：查看日志
docker logs <container> --tail 100 --previous

# 2. Kubernetes：查看 Pod 事件
kubectl describe pod <pod-name>

# 3. 查看系统日志
dmesg | tail -50

# 4. 查看 OOM Killer
dmesg | grep -i "killed process"

# 5. 重新启动（临时恢复）
docker start <container>
kubectl rollout restart deployment/<name>
```

---

### 6. 网络不可达

**触发条件：** ping / telnet / curl 失败

```
判断流程：
1. 确认是自身网络问题还是目标问题？
   └─ 能 ping 其他地址 → 自身正常
   └─ ping 不通任何地址 → 自身网络问题

2. 确认是 DNS 问题还是路由问题？
   └─ ping IP 成功、ping 域名失败 → DNS 问题
   └─ 都失败 → 路由/防火墙问题
```

**处理步骤：**
```bash
# 1. ping 测试
ping -c 5 8.8.8.8
ping -c 5 example.com

# 2. DNS 测试
nslookup example.com
dig example.com

# 3. 路由追踪
traceroute example.com
mtr example.com

# 4. 端口检测
nc -zv host port -w 5

# 5. 查看防火墙规则
iptables -L -n
ufw status
```

---

### 7. SSL 证书即将过期

**触发条件：** 证书有效期 < 30 天

```
判断流程：
1. 确认是自有证书还是云厂商证书？
   └─ Let's Encrypt → 自动续期脚本
   └─ 云厂商（阿里云/腾讯云） → 手动续期
   └─ 自签证书 → 手动替换
```

**处理步骤：**
```bash
# 1. 检查证书过期时间
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

# 2. Let's Encrypt 续期
certbot renew --dry-run
certbot renew

# 3. 续期后重载 Nginx
nginx -t && nginx -s reload

# 4. 检查泛域名证书（需 DNS 验证）
certbot renew --cert-name "*.example.com"
```

---

## 升级路径

```
P0 告警：
  → 立即处理
  → 5 分钟内通知负责人
  → 如果 15 分钟内无法恢复，升级

P1 告警：
  → 15 分钟内响应
  → 处理过程中更新状态
  → 如果 1 小时内无法恢复，升级

P2/P3 告警：
  → 正常工作时间处理
  → 记录到工单系统
  → 按计划排期处理
```

## 复盘指导

告警处理完成后，填写复盘报告：

```
## 告警复盘报告

**告警时间：** YYYY-MM-DD HH:MM
**恢复时间：** YYYY-MM-DD HH:MM
**持续时间：** X 分钟
**影响范围：** 描述
**告警级别：** P0/P1/P2/P3

### 根因分析
（5 Why 分析）

### 处理过程
1. ... 2. ...

### 后续改进
- 短期：...
- 长期：

### 预防措施
- 监控阈值调整：...
- 架构优化：...
```

## 常用命令速查

```bash
# CPU 高
ps aux --sort=-%cpu | head

# 内存高
ps aux --sort=-%mem | head

# 磁盘满
df -h && du -h --max-depth=2 / | sort -rh | head

# 服务挂了
docker ps -a | grep -v Up
systemctl status <service>

# 网络
ping 8.8.8.8
nslookup example.com
nc -zv host port -w 5
```

---

*记录版本：v0.1*
