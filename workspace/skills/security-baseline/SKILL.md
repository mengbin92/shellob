---
name: security-baseline
description: Use when performing security audits — checking user accounts, file permissions, SSH hardening, firewall rules, or suspicious processes.
---

# Security Baseline

## 概述

安全基线审计 skill。用于系统安全检查、用户审计、权限检查、SSH 加固、防火墙规则、异常检测。

## 核心能力

- 用户和组审计
- SSH 配置审计
- 文件权限检查（SUID、敏感文件）
- 防火墙规则审计
- 异常进程和网络连接
- 日志安全事件分析
- 系统基线检查（Linux/macOS）

## 命令清单

### 用户与认证

```bash
# 查看所有用户（Linux）
cat /etc/passwd | grep -v "nologin\|false" | awk -F: '{print $1, $3, $7}'

# 查看所有用户（macOS）
dscl . list /Users | grep -v "^_"

# 查看 sudo 组用户
getent group sudo   # Linux
dscl . read /Groups/sudo  # macOS

# 最近登录的用户
lastlog | tail -20

# 最近创建的账户
grep -E "useradd|newusers" /var/log/auth.log 2>/dev/null | tail -10

# 密码策略（Linux）
cat /etc/login.defs | grep -E "PASS_MIN_LEN|PASS_MAX_DAYS"

# 密码策略（macOS）
pwpolicy -getstatus

# 查看空密码用户
awk -F: '($2 == "") {print $1}' /etc/shadow

# 锁定的账户
passwd -S <username>  # Linux
```

### SSH 加固审计

```bash
# SSH 配置文件位置
# Linux: /etc/ssh/sshd_config
# macOS: /etc/ssh/sshd_config

# 检查 SSH 配置
sshd -T

# 关键审计项
echo "=== SSH 审计 ==="
grep "^PermitRootLogin" /etc/ssh/sshd_config
grep "^PasswordAuthentication" /etc/ssh/sshd_config
grep "^PubkeyAuthentication" /etc/ssh/sshd_config
grep "^MaxAuthTries" /etc/ssh/sshd_config
grep "^PermitEmptyPasswords" /etc/ssh/sshd_config
grep "^X11Forwarding" /etc/ssh/sshd_config

# SSH 允许的密钥
ls -la ~/.ssh/

# 检查 SSH 密钥权限
ls -la ~/.ssh/authorized_keys 2>/dev/null
```

### 文件权限

```bash
# SUID 文件（提权风险）
find / -perm -4000 -type f 2>/dev/null | head -20

# SGID 文件
find / -perm -2000 -type f 2>/dev/null | head -20

# 任何人可写的文件
find / -perm -2 ! -type d 2>/dev/null | head -20

# 敏感文件权限检查
ls -la /etc/passwd /etc/shadow /etc/group
ls -la /etc/sudoers

# crontab 检查
crontab -l        # 当前用户
cat /var/spool/cron/crontabs/* 2>/dev/null  # Linux
ls -la /var/at/  # macOS

# 检查 SSH 密钥文件
ls -la ~/.ssh/
find ~/.ssh -type f -exec ls -l {} \;
```

### 防火墙

```bash
# macOS 防火墙
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --listapps

# Linux: iptables
iptables -L -n -v
iptables -L -n --line-numbers

# Linux: ufw
ufw status verbose
ufw numbered

# Linux: firewalld
firewall-cmd --list-all

# 开放端口检查
ss -tlnp | grep LISTEN
lsof -i -P -n | grep LISTEN
```

### 进程和网络

```bash
# 监听端口（异常端口要关注）
lsof -i -P -n | grep LISTEN

# 非本地连接
lsof -i -P -n | grep -v "127.0.0.1\|::1\|localhost"

# 异常进程（隐藏进程、消耗 CPU/内存异常的高）
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# 僵尸进程
ps aux | grep -w Z

# 进程树异常
ps auxf | head -50

# 网络连接异常
netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

### 系统日志安全事件

```bash
# Linux: 失败登录
grep -E "Failed password|Failed publickey" /var/log/auth.log 2>/dev/null | tail -20

# Linux: 成功登录
grep -E "Accepted password|Accepted publickey" /var/log/auth.log 2>/dev/null | tail -20

# Linux: sudo 使用
grep -E "sudo|" /var/log/auth.log 2>/dev/null | tail -20

# macOS: 登录历史
log show --predicate 'eventMessage contains "login"' --last 24h 2>/dev/null | tail -30

# macOS: 认证失败
log show --predicate 'eventMessage contains "authentication failure"' --last 24h 2>/dev/null | tail -20

# SSH 暴力破解检测
grep "Invalid user\|Failed password" /var/log/auth.log 2>/dev/null | awk '{print $NF}' | sort | uniq -c | sort -rn | head -10
```

### 系统基线（Linux）

```bash
# 系统版本
cat /etc/os-release

# 运行时间
uptime

# 内核版本
uname -r

# SELinux 状态
getenforce  # 或 sestatus

# 系统账户（UID 为 0 的非 root 账户）
awk -F: '($3 == 0) {print $1}' /etc/passwd

# DNS 配置
cat /etc/resolv.conf

# hosts 文件
cat /etc/hosts
```

### 系统基线（macOS）

```bash
# 系统版本
sw_vers

# SIP 状态
csrutil status

# Gatekeeper
spctl --status

# 文件共享
launchctl list | grep AppleFileServer
```

## 输出格式

```
## 安全基线审计报告

**主机：** hostname
**时间：** YYYY-MM-DD HH:MM
**系统：** macOS 14.x / Ubuntu 22.04

---

### 用户与认证
- 系统账户：12 个（正常）
- sudo 组用户：3 个
- ⚠️ 警告：存在空密码用户（test）

### SSH 配置
- PermitRootLogin：no ✅
- PasswordAuthentication：no ✅
- PubkeyAuthentication：yes ✅
- MaxAuthTries：3 ✅

### 文件权限
- SUID 文件：5 个（正常范围）
- SGID 文件：3 个（正常范围）
- ⚠️ 任何人可写：2 个文件需要检查

### 防火墙
- macOS 防火墙：开启 ✅
- 监听端口：22, 80, 443（正常）

### ⚠️ 安全警告
1. test 账户为空密码，建议设置密码或禁用
2. `/tmp` 下存在 SUID 文件，建议检查

### 建议
1. 启用 SSH 公钥登录，禁用密码登录
2. 定期审计 sudo 组用户
3. 开启系统日志审计
```

## 常见问题

| 问题 | 检测命令 | 风险 |
|---|---|---|
| 空密码账户 | `awk -F: '($2==""){print $1}' /etc/shadow` | 严重 |
| Root 直接登录 | `grep "^PermitRootLogin" sshd_config` | 高 |
| SUID 文件过多 | `find / -perm -4000` | 中 |
| 开放过多端口 | `lsof -i -P -n \| grep LISTEN` | 中 |
| SSH 暴力破解 | `grep "Failed password" auth.log` | 高 |

## 注意事项

1. **只读审计操作** — 不要修改配置，只检查和报告
2. **敏感信息脱敏** — 报告中不要暴露密码、密钥内容
3. **异常不一定等于入侵** — SUID 多不等于被黑，先确认是否正常
4. **macOS 和 Linux 命令有差异** — 注意判断 OS 类型
5. **审计前先备份配置文件** — 如需改动，先备份再操作

## 脚本工具

`scripts/sec-audit.sh` — 安全基线快速审计

---

*记录版本：v0.1*
