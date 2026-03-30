# Shellob 🦐

**Shell虾** — 基于 [OpenClaw](https://github.com/openclaw/openclaw) 的 AI 运维 Agent。

## 它是什么

Shellob 是一只专注运维场景的 AI 虾。它能：

- 📊 **系统监控** — CPU / 内存 / 磁盘 / 网络实时采集与告警
- 📋 **日志分析** — 多源日志搜索、过滤、模式识别
- 🐳 **容器运维** — Docker / Kubernetes 巡检、排查、操作
- 🌐 **网络诊断** — 连通性、DNS、延迟、端口扫描
- 🗄️ **数据库运维** — 状态检查、慢查询、备份恢复
- 🔒 **安全审计** — 基线检查、权限审计、入侵检测
- ⏰ **定时巡检** — 基于 Cron 的自动化运维任务

## 设计理念

- **少废话多干活** — 运维不需要客套，需要的是准确和快速
- **Shell 即生命** — 能命令行解决的不绕弯子
- **可观测性优先** — 监控是运维的眼睛，日志是运维的记忆
- **自动化一切** — 重复操作交给机器，人做决策

## 项目结构

```
shellob/
├── README.md                    # 本文件
├── docs/
│   ├── DESIGN.md               # 设计文档（核心）
│   └── SKILL-PLAN.md           # Skill 开发规划
├── workspace/                  # OpenClaw workspace
│   ├── AGENTS.md               # Agent 行为规范
│   ├── SOUL.md                 # 人设定义
│   ├── TOOLS.md                # 工具配置
│   ├── HEARTBEAT.md            # 定时巡检配置
│   ├── BOOTSTRAP.md            # 首次启动引导
│   └── skills/                 # 运维 Skills
│       ├── log-analyzer/       # 日志分析
│       ├── system-monitor/     # 系统监控
│       ├── docker-ops/         # Docker 运维
│       ├── k8s-ops/            # Kubernetes 运维
│       ├── network-diag/       # 网络诊断
│       ├── db-ops/             # 数据库运维
│       ├── web-server/         # Web 服务运维
│       ├── backup-restore/     # 备份恢复
│       ├── security-baseline/  # 安全基线
│       └── alert-sop/          # 告警处理 SOP
└── scripts/                    # 辅助脚本
```

## 快速开始

> 需要 OpenClaw 环境，参考 [OpenClaw 文档](https://docs.openclaw.ai)

```bash
# 克隆仓库
git clone https://github.com/mengbin92/shellob.git

# 将 workspace 内容复制到你的 OpenClaw workspace
cp -r shellob/workspace/* ~/.openclaw/workspace/

# 重启 OpenClaw
openclaw gateway restart
```

## 人设

| 项目 | 值 |
|---|---|
| 中文名 | Shell虾 |
| 英文名 | Shellob |
| 定位 | 运维 AI Agent |
| 风格 | 老练运维，简洁高效 |
| 口头禅 | "问题不大" |
| Emoji | 🦐 |

## 许可

MIT

---

> *"凌晨三点的告警，让虾来扛。"*
