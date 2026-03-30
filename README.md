# Shellob 🦐

**Shell虾 / Shellob** — 基于 [OpenClaw](https://github.com/openclaw/openclaw) 的 AI 运维 Agent。

> 凌晨三点的告警，让虾来扛。

---

## 它能做什么

Shellob 是专攻运维场景的 AI，能力覆盖：

- 📊 **系统监控** — CPU / 内存 / 磁盘 / 网络实时采集与告警
- 📋 **日志分析** — 多源日志搜索、过滤、模式识别、统计
- 🐳 **容器运维** — Docker 巡检、日志、资源监控、镜像清理
- ☸️ **Kubernetes** — Pod / Service / Deployment 状态排查与扩缩容
- 🌐 **网络诊断** — 连通性、DNS、HTTP、SSL、延迟、路由
- 🗄️ **数据库运维** — MySQL / PostgreSQL / Redis / MongoDB 状态与慢查询
- 🌩️ **Web 服务** — Nginx / Apache 配置校验、日志分析、SSL 证书
- 💾 **备份恢复** — 数据库备份、文件备份、恢复演练
- 🔒 **安全审计** — 用户审计、SSH 加固、权限检查、防火墙
- 🚨 **告警处理** — 告警分级、决策树、常见告警处理 SOP
- 📈 **指标推送** — Prometheus 格式采集、PushGateway 推送、Grafana Dashboard
- 📝 **变更记录** — 配置变更审计日志、回滚方案、月报

---

## 快速开始

### 环境要求

- macOS / Linux
- Python 3.9+
- Docker（可选，用于容器运维）
- kubectl（可选，用于 K8s 运维）

### 安装

```bash
# 克隆仓库
git clone https://github.com/mengbin92/shellob.git

# 将 workspace 内容复制到 OpenClaw workspace
cp -r shellob/workspace/* ~/.openclaw/workspace/

# 重启 OpenClaw
openclaw gateway restart
```

### 安装 Skills（可选）

复制 `workspace/skills/` 目录到你的 OpenClaw workspace 对应位置。

---

## Skills 一览

| Skill | 路径 | 优先级 | 说明 |
|---|---|---|---|
| `log-analyzer` | `workspace/skills/log-analyzer/` | P0 | 日志搜索、过滤、统计、错误模式识别 |
| `system-monitor` | `workspace/skills/system-monitor/` | P0 | CPU、内存、磁盘、网络监控，Markdown 报告 |
| `docker-ops` | `workspace/skills/docker-ops/` | P0 | 容器巡检、日志、资源、镜像管理 |
| `k8s-ops` | `workspace/skills/k8s-ops/` | P1 | Pod/Deploy/Service 管理、日志、扩缩容 |
| `network-diag` | `workspace/skills/network-diag/` | P1 | 端口、HTTP、DNS、SSL、延迟、路由诊断 |
| `db-ops` | `workspace/skills/db-ops/` | P1 | MySQL、PostgreSQL、Redis、MongoDB 运维 |
| `web-server` | `workspace/skills/web-server/` | P2 | Nginx/Apache 配置、日志、SSL 证书 |
| `backup-restore` | `workspace/skills/backup-restore/` | P2 | 数据库备份、文件备份、恢复演练 |
| `security-baseline` | `workspace/skills/security-baseline/` | P2 | 用户审计、SSH 加固、权限检查 |
| `alert-sop` | `workspace/skills/alert-sop/` | P3 | 告警分级、常见告警处理决策树 |
| `metrics-pusher` | `workspace/skills/metrics-pusher/` | 扩展 | Prometheus 指标采集、PushGateway、Grafana |
| `change-log` | `workspace/skills/change-log/` | 扩展 | 变更审计日志、分类、回滚方案、月报 |

---

## 项目结构

```
shellob/
├── README.md
├── LICENSE
├── docs/
│   ├── DESIGN.md          # 核心设计文档
│   └── SKILL-PLAN.md      # Skill 开发规划
└── workspace/
    ├── SOUL.md            # 人设定义
    ├── AGENTS.md          # 行为规范
    ├── TOOLS.md           # 工具配置
    ├── HEARTBEAT.md       # 定时巡检配置
    ├── BOOTSTRAP.md       # 首次启动引导
    └── skills/
        ├── log-analyzer/
        │   ├── SKILL.md
        │   └── scripts/
        │       ├── loggrep.sh      # 快速日志搜索
        │       └── logstat.sh       # 日志统计
        ├── system-monitor/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── sysreport.sh     # 系统监控报告
        ├── docker-ops/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── docker-check.sh  # Docker 快速巡检
        ├── k8s-ops/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── k8s-check.sh     # K8s 集群巡检
        ├── network-diag/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── netdiag.sh       # 网络诊断
        ├── db-ops/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── db-check.sh      # 数据库巡检
        ├── web-server/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── web-check.sh     # Web 服务巡检
        ├── backup-restore/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── backup-check.sh   # 备份状态检查
        ├── security-baseline/
        │   ├── SKILL.md
        │   └── scripts/
        │       └── sec-audit.sh     # 安全基线审计
        ├── alert-sop/
        │   └── SKILL.md             # 告警处理 SOP
        ├── metrics-pusher/
        │   ├── SKILL.md
        │   └── scripts/
        │       ├── collect-metrics.sh   # 指标采集
        │       ├── push-metrics.sh      # PushGateway 推送
        │       └── grafana-dashboard.json  # Grafana 模板
        └── change-log/
            ├── SKILL.md
            └── scripts/
                └── change-log.sh        # 变更记录管理
```

---

## 设计理念

- **少废话多干活** — 运维不需要客套，需要的是准确和快速
- **Shell 即生命** — 能命令行解决的不绕弯子
- **可观测性优先** — 监控是运维的眼睛，日志是运维的记忆
- **自动化一切** — 重复操作交给机器，人做决策
- **变更可追溯** — 所有操作都要记录，能回滚

---

## 监控部署（可选）

配合 Prometheus + Grafana 可实现告警闭环：

```bash
# 1. 安装 PushGateway
brew install prometheus

# 2. 启动 PushGateway
pushgateway &

# 3. 定时推送指标
*/1 * * * * /path/to/shellob/workspace/skills/metrics-pusher/scripts/push-metrics.sh
```

然后在 Grafana 中导入 `scripts/grafana-dashboard.json`。

---

## 许可

MIT
