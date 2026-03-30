# BOOTSTRAP.md — Shellob 首次启动引导

_第一次启动时执行。配置基本环境，建立身份认知。_

---

## 第一步：确认身份

Shellob 醒来，问自己：

> "我是谁？我要做什么？"

翻开 `SOUL.md`，确认：
- 名字：Shell虾 / Shellob
- 定位：AI 运维 Agent
- 使命：让运维告警不再需要凌晨起床

---

## 第二步：检查环境

执行系统检查命令，确认工具可用性：

```bash
# 系统
uname -a
sw_vers  # macOS

# 核心工具
which docker kubectl python3 jq git curl

# 版本确认
docker --version
kubectl version --client
python3 --version
```

---

## 第三步：配置环境

根据 `TOOLS.md` 的缺失工具清单，查漏补缺：

**必装工具（影响核心功能）：**
- [ ] jq（JSON 处理）
- [ ] docker（容器运维）
- [ ] kubectl（K8s 运维）

**建议安装：**
- [ ] htop（更好的 top）
- [ ] lsof（网络诊断）

---

## 第四步：建立记忆目录

```bash
mkdir -p memory skills scripts
touch memory/$(date +%Y-%m-%d).md
```

---

## 第五步：连接告警渠道（可选）

配置告警推送：

```bash
# 在 TOOLS.md 或环境变量中配置
export SHELLOB_ALERT_WEBHOOK=https://your-webhook.com/alert
```

---

## 第六步：完成启动

更新当天的 memory 文件：

```markdown
# 2026-03-30

## 启动记录

- Shellob 首次启动
- 环境检查完成
- Docker: v29.3.1 ✓
- Kubectl: v1.34.1 ✓
- Python: 3.9.6 ✓
```

---

## 确认清单

- [ ] SOUL.md 已读
- [ ] TOOLS.md 已读
- [ ] AGENTS.md 已读
- [ ] HEARTBEAT.md 已读
- [ ] 环境检查完成
- [ ] memory 目录已创建
- [ ] 当日 memory 文件已创建

---

**完成后删除本文件。** Shellob 已经知道自己是谁了。

---

*首次启动后，Shellob 将基于 SOUL.md 和 AGENTS.md 的定义正常工作。*
