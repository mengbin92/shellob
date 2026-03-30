#!/bin/bash
# sec-audit.sh — 安全基线快速审计
# 用法: ./sec-audit.sh

OS=$(uname -s)

echo "=========================================="
echo "  Security Baseline Audit"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

echo ""
echo "### 系统信息"
echo "OS: $OS"
echo "主机名: $(hostname)"
echo "运行时间: $(uptime -p 2>/dev/null || uptime)"

echo ""
echo "### 用户审计"
echo "- UID=0 的账户:"
awk -F: '($3 == 0) {print $1}' /etc/passwd

echo ""
echo "- 非登录系统账户:"
if [ "$OS" = "Darwin" ]; then
    dscl . list /Users | grep -v "^_" | while read u; do
        shell=$(dscl . -read /Users/$u UserShell 2>/dev/null | awk '{print $2}')
        [ "$shell" = "/usr/bin/false" ] && echo "$u"
    done
else
    awk -F: '/nologin|false/{print $1}' /etc/passwd | head -10
fi

echo ""
echo "### SSH 审计"
if [ -f /etc/ssh/sshd_config ]; then
    echo "- PermitRootLogin: $(grep '^PermitRootLogin' /etc/ssh/sshd_config | awk '{print $2}')"
    echo "- PasswordAuthentication: $(grep '^PasswordAuthentication' /etc/ssh/sshd_config | awk '{print $2}')"
    echo "- PubkeyAuthentication: $(grep '^PubkeyAuthentication' /etc/ssh/sshd_config | awk '{print $2}')"
    echo "- MaxAuthTries: $(grep '^MaxAuthTries' /etc/ssh/sshd_config | awk '{print $2}')"
else
    echo "SSH 配置文件未找到"
fi

echo ""
echo "### SUID 文件（提权风险）"
find / -perm -4000 -type f 2>/dev/null | head -10 || echo "无"

echo ""
echo "### 监听端口"
if [ "$OS" = "Darwin" ]; then
    lsof -i -P -n | grep LISTEN | head -15
else
    ss -tlnp | grep LISTEN | head -15
fi

echo ""
echo "### 防火墙状态"
if [ "$OS" = "Darwin" ]; then
    /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "无法获取"
else
    systemctl status ufw 2>/dev/null | head -3 || iptables -L -n 2>/dev/null | head -5 || echo "无 ufw/iptables"
fi

echo ""
echo "### 最近失败登录（Linux）"
if [ -f /var/log/auth.log ]; then
    grep -E "Failed password|Invalid user" /var/log/auth.log 2>/dev/null | tail -5
else
    echo "无 /var/log/auth.log"
fi

echo ""
echo "=========================================="
echo "  审计完成"
echo "=========================================="
