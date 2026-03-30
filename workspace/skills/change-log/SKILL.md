---
name: change-log
description: Use when recording configuration changes, deployments, or operations performed by Shellob — creates structured audit logs.
---

# Change Log

## 概述

变更记录 skill。记录所有通过 Shellob 执行的重要操作，形成可追溯的运维审计日志。

## 核心能力

- 记录操作变更（时间、操作者、变更内容、影响范围）
- 支持分类（配置变更、部署、扩缩容、清理、告警响应）
- 自动关联相关资源
- 生成变更报告
- 支持事后复盘查询

## 日志格式

日志文件位置：`memory/changes/YYYY-MM.csv`

```
timestamp,category,operator,action,target,impact,risk_level,rollback,notes
2026-03-30 15:00:00,config,shellob,Nginx配置重载,nginx,服务无中断,low,nginx -s reload,"修改 upstream 配置"
2026-03-30 14:30:00,deploy,shellob,Docker镜像更新,app:v2.1,容器重启,medium,docker stop/start,"升级到 v2.1"
```

## 分类定义

| 分类 | 代码 | 说明 |
|---|---|---|
| 配置变更 | `config` | 配置文件修改、参数调整 |
| 部署 | `deploy` | 应用部署、更新、回滚 |
| 扩缩容 | `scale` | 容器/实例数量变更 |
| 清理 | `cleanup` | 日志清理、镜像删除、临时文件 |
| 告警响应 | `incident` | 告警处理、故障恢复 |
| 数据库 | `database` | 数据库操作、备份恢复 |
| 安全 | `security` | 用户、权限、证书等安全相关 |
| 其他 | `other` | 不属于以上分类 |

## 风险等级

| 等级 | 定义 | 记录要求 |
|---|---|---|
| `low` | 无服务中断，可快速回滚 | 记录即可 |
| `medium` | 可能短暂影响，需关注 | 必须记录 + 影响说明 |
| `high` | 可能影响核心服务 | 需二次确认，记录 + 回滚方案 |
| `critical` | 数据丢失或服务长时间不可用风险 | 需审批 + 完整记录 |

## 命令清单

### 记录变更

```bash
# 基本记录（手动）
cat >> memory/changes/$(date +%Y-%m).csv <<'EOF'
2026-03-30 15:00:00,config,shellob,Nginx重载,nginx,无中断,low,nginx -s reload,更新 upstream 配置
EOF

# 通过脚本记录
/path/to/scripts/change-log.sh record \
    --category deploy \
    --action "Docker 镜像更新" \
    --target "app:v2.1" \
    --impact "容器重启，约 30 秒不可用" \
    --risk medium \
    --rollback "docker stop app && docker start app"

# 查询变更（按日期）
grep "2026-03-30" memory/changes/2026-03.csv

# 查询变更（按分类）
grep ",config," memory/changes/2026-03.csv

# 查询变更（按风险）
grep ",high," memory/changes/2026-03.csv

# 查询最近 N 条
tail -20 memory/changes/$(date +%Y-%m).csv
```

### 查询和分析

```bash
# 变更统计（按分类）
awk -F',' 'NR>1 {counts[$2]++} END {for(c in counts) print c, counts[c]}' memory/changes/$(date +%Y-%m).csv | sort -rn

# 变更统计（按操作者）
awk -F',' 'NR>1 {counts[$3]++} END {for(o in counts) print o, counts[o]}' memory/changes/$(date +%Y-%m).csv | sort -rn

# 高风险变更
grep ",high\|,critical" memory/changes/$(date +%Y-%m).csv

# 按日期范围查询
awk -F',' 'NR>1 && $1>="2026-03-01" && $1<="2026-03-31"' memory/changes/2026-03.csv

# 生成变更报告
/path/to/scripts/change-log.sh report --month 2026-03
```

## 自动记录规则

Shellob 执行以下操作时，**必须**自动记录变更日志：

| 操作类型 | 记录时机 | 风险等级 |
|---|---|---|
| 服务重启/停止 | 执行前 | medium |
| 配置修改 | 修改前 | medium |
| 镜像删除 | 执行前 | high |
| 数据库写操作 | 执行前 | high |
| 扩缩容 | 执行前 | medium |
| 证书更新 | 执行后 | low |
| 日志清理 | 执行后 | low |
| 告警处理 | 执行后 | medium |

## 输出格式

### 变更记录报告（月报）

```
## Shellob 变更记录月报

**月份：** 2026-03
**生成时间：** 2026-03-30 18:00

---

### 变更统计

| 分类 | 次数 |
|---|---|
| config | 12 |
| deploy | 5 |
| cleanup | 8 |
| incident | 2 |
| scale | 3 |

### 高风险变更（需关注）
| 时间 | 操作 | 影响 | 回滚方案 |
|---|---|---|---|
| 03-15 10:30 | 删除旧镜像 12 个 | 磁盘释放 50GB | 重新拉取镜像 |
| 03-22 14:00 | 数据库表结构变更 | 写入短暂中断 | DDL 回滚 |

### 本月亮点
- 配置变更：12 次（自动化程度提升）
- 告警响应：2 次（P1 告警平均恢复时间 8 分钟）
- 清理操作：8 次（释放磁盘 80GB）

### 下月建议
1. `/data` 磁盘使用率持续增长，建议排查日志轮转
2. Docker 镜像清理可加入自动化（每周一次）
```

### 单次变更记录

```
## 变更记录

**时间：** 2026-03-30 15:00:00
**操作者：** shellob
**分类：** config
**操作：** Nginx upstream 配置重载
**目标：** nginx

**影响范围：** 无服务中断
**风险等级：** low
**回滚方案：** nginx -s reload

**详细说明：**
更新 upstream app:v2 的后端地址，从 10.0.0.11 改为 10.0.0.12

**关联告警（如有）：**
无

**备注：**
联系人为 老大，通过 QQ 确认后执行
```

## 回滚方案模板

每次高风险变更必须记录回滚方案：

```bash
# 格式
rollback_command: <如何回滚>
rollback_time: <预计回滚时间>
rollback_verification: <如何验证回滚成功>

# 示例
rollback_command: docker stop app && docker run --name app -v old-config:/app/config app:v2.0
rollback_time: 约 2 分钟
rollback_verification: curl http://localhost/health 返回 200
```

## 脚本工具

`scripts/change-log.sh` — 变更记录管理脚本

`scripts/change-report.sh` — 变更月报生成脚本

## 注意事项

1. **变更前记录** — 高风险操作先记录再执行
2. **回滚方案必填** — medium 及以上风险必须记录回滚方案
3. **影响范围要准确** — 不要写"无影响"，除非确认无影响
4. **关联资源** — 配置变更写清楚哪个配置文件
5. **定期归档** — 历史月份日志移到 `memory/changes/archive/`

## 文件结构

```
memory/
  changes/
    2026-03.csv        # 本月变更
    2026-02.csv        # 历史
    archive/
      2026-01.csv      # 归档
```

---

*记录版本：v0.1*
