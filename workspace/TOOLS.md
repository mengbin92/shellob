# TOOLS.md — Shellob 工具配置

_记录目标运维环境的工具清单和配置。_

---

## 系统环境

| 项目 | 值 |
|---|---|
| OS | macOS / Linux（跨平台兼容） |
| Shell | zsh / bash |
| Python | 3.9+ |
| Git | 已安装 |

---

## 核心工具

### 系统命令（macOS 原生）

| 工具 | 路径 | 用途 |
|---|---|---|
| ps | /bin/ps | 进程查看 |
| top | /usr/bin/top | 系统状态 |
| kill/killall | /usr/bin/kill /usr/bin/killall | 进程管理 |
| df | /bin/df | 磁盘使用 |
| du | /usr/bin/du | 目录大小 |
| grep | /usr/bin/grep | 文本搜索 |
| awk | /usr/bin/awk | 文本处理 |
| sed | /usr/bin/sed | 文本替换 |
| find | /usr/bin/find | 文件查找 |
| curl | /usr/bin/curl | HTTP 请求 |
| ssh/scp | /usr/bin/ssh /usr/bin/scp | 远程操作 |
| rsync | /usr/bin/rsync | 文件同步 |
| tar | /usr/bin/tar | 压缩解压 |
| gzip/zcat | /usr/bin/gzip /usr/bin/zcat | 日志压缩 |
| jq | /opt/homebrew/bin/jq | JSON 处理 |
| python3 | /usr/bin/python3 | 脚本执行 |

### 容器相关

| 工具 | 版本 | 用途 |
|---|---|---|
| Docker | 29.3.1 | 容器管理 |
| kubectl | 1.34.1 | K8s 管理 |
| Kustomize | 5.7.1 | K8s 配置 |

---

## 缺失工具（需要安装）

| 工具 | 安装方式 | 用途 |
|---|---|---|
| htop | brew install htop | 交互式系统监控 |
| lsof | macOS 原生，Linux 需安装 | 网络/文件诊断 |
| ss | macOS 无，Linux 原生 | 端口连接查看 |
| prometheus | 二进制/容器 | 指标采集 |
| grafana | 容器 | 可视化监控 |
| jq (Linux) | apt/yum 安装 | JSON 处理 |

---

## 数据库客户端（待配置）

| 数据库 | 工具 | 连接方式 |
|---|---|---|
| MySQL | mysql | 需要配置 host/port/user/password |
| PostgreSQL | psql | 需要配置 host/port/user/password |
| Redis | redis-cli | 需要配置 host/port |
| MongoDB | mongosh | 需要配置 connection string |

---

## 配置文件路径（待配置）

```markdown
### 日志路径
- /var/log/**/*.log
- ~/Library/Logs/（macOS）
- /var/log/nginx/access.log

### Docker
- /var/run/docker.sock
- ~/.docker/config.json

### Kubernetes
- ~/.kube/config
- /etc/kubernetes/（Linux）

### Nginx
- /usr/local/etc/nginx/nginx.conf（macOS Homebrew）
- /etc/nginx/nginx.conf（Linux）
```

---

## 环境变量（待配置）

```bash
# 数据库连接（通过 TOOLS.md 管理，不写在代码里）
SHELLOB_DB_HOST=localhost
SHELLOB_DB_PORT=3306
SHELLOB_DB_USER=root

# 告警渠道
SHELLOB_ALERT_WEBHOOK=https://your-webhook.com/alert

# 巡检目标
SHELLOB_TARGET_HOSTS=host1,host2,host3
```

---

_工具清单随环境变化更新。使用前先检查命令是否存在。_
