---
name: network-diag
description: Use when diagnosing network issues — connectivity, DNS, ports, HTTP, TLS certificates, or latency problems.
---

# Network Diagnostics

## 概述

网络诊断 skill。用于连通性检查、DNS 解析、端口扫描、HTTP 健康检查、SSL 证书验证、延迟测试。

## 核心能力

- 端口连通性（TCP / UDP）
- HTTP/HTTPS 健康检查
- DNS 解析验证
- SSL 证书检查（有效期、问题）
- 延迟和吞吐量测试
- 本地端口占用
- 路由追踪

## 命令清单

### 端口连通性

```bash
# TCP 端口检测（Linux: nc, macOS: nc）
nc -zv host port -w 5

# 示例
nc -zv example.com 443 -w 3

# UDP 端口检测
nc -zuv host port -w 5

# 批量端口检测（1-1024）
for port in 22 80 443 8080; do
    nc -zv host $port -w 2 && echo "Port $port OPEN" || echo "Port $port CLOSED"
done

# lsof 端口占用（macOS）
lsof -i :8080
lsof -i -P -n | grep LISTEN

# ss 端口监听（Linux）
ss -tlnp | grep :8080
```

### HTTP 检查

```bash
# HEAD 请求（只检查响应头）
curl -I https://example.com

# 检查 HTTP 状态码
curl -s -o /dev/null -w "%{http_code}" https://example.com

# 完整响应信息
curl -s -w "\nHTTP Code: %{http_code}\nTime: %{time_total}s\n" https://example.com

# 带 Header 的请求
curl -s -H "Host: example.com" https://IP -I

# 跟踪重定向
curl -I -L https://example.com

# POST 请求
curl -X POST -d "key=value" https://example.com/api

# JSON POST
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://example.com/api
```

### DNS 解析

```bash
# DNS 查询
nslookup example.com

# 详细 DNS 解析
dig example.com ANY

# 跟踪 DNS 解析路径
dig +trace example.com

# 指定 DNS 服务器查询
dig @8.8.8.8 example.com

# 反向 DNS
dig -x 8.8.8.8

# 查看 CNAME
host -v example.com
```

### 延迟测试

```bash
# HTTP 延迟（单次）
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://example.com

# HTTP 延迟（多次）
for i in {1..5}; do
    curl -w "Time: %{time_total}s\n" -o /dev/null -s https://example.com
done

# TCP 连接延迟
nc -zv example.com 443 -w 5 2>&1 | grep -o "time=[0-9.]*"

# ping（macOS/Linux）
ping -c 5 example.com

# ping 统计
ping -c 100 example.com | tail -1
```

### SSL / TLS 证书

```bash
# 检查证书有效期
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates

# 证书详情（过期天数、颁发者）
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -issuer -subject -dates

# 检查证书链
echo | openssl s_client -connect example.com:443 -showcerts 2>/dev/null | head -50

# 检查支持的 TLS 版本
echo | openssl s_client -tls1_2 -connect example.com:443 2>/dev/null | grep "Protocol"

# 检查 SNI
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -subject

# SSL Labs 评分（在线，需联网）
curl -s "https://api.ssllabs.com/api/v3/analyze?host=example.com" | jq .
```

### 路由追踪

```bash
# traceroute（Linux）
traceroute example.com

# traceroute（macOS）
traceroute example.com

# MTR（结合 ping + traceroute，需安装）
mtr example.com

# 路由表
ip route show      # Linux
route -n get default  # macOS

# 查看特定 IP 路由
ip route get 8.8.8.8   # Linux
route -n get 8.8.8.8   # macOS
```

### 本地网络

```bash
# 本地 IP 地址
ifconfig | grep "inet " | awk '{print $2}'
ip addr show | grep "inet "    # Linux

# 所有网卡
ifconfig -a
ip link show

# 网卡流量统计
netstat -ib | head -20    # macOS
cat /proc/net/dev          # Linux

# ARP 表
arp -a
ip neigh show              # Linux

# DNS 缓存（macOS）
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# DNS 缓存（Linux systemd）
systemd-resolve --flush-caches
```

### curl 高级用法

```bash
# 下载文件
curl -O https://example.com/file.zip

# 限速下载（100KB/s）
curl --limit-rate 100k -O https://example.com/file.zip

# 重试
curl --retry 3 --retry-delay 5 https://example.com

# 超时设置
curl -m 10 --connect-timeout 5 https://example.com

# 跳过 SSL 验证（测试用）
curl -k https://example.com

# 输出响应头
curl -D - -s https://example.com -o /dev/null

# 保存 cookie
curl -c cookies.txt -b cookies.txt https://example.com
```

## 输出格式

```
## 网络诊断报告

**目标：** example.com
**时间：** YYYY-MM-DD HH:MM

---

### 连通性
- 443 端口：✅ OPEN
- 80 端口：✅ OPEN

### DNS 解析
- A 记录：93.184.216.34
- CNAME：无
- 解析延迟：12ms

### HTTP 状态
- 状态码：200
- 响应时间：245ms
- Content-Type：text/html

### SSL 证书
- 域名：example.com
- 颁发者：DigiCert Inc
- 有效期至：2026-08-15（剩余 138 天）
- TLS 版本：TLS 1.2 ✅

### 路由追踪
1. 192.168.1.1
2. 10.0.0.1
3. 93.184.216.34

### 结论
- 网络正常
- 证书有效期充足
- 建议：无
```

## 常见问题

| 问题 | 排查命令 | 可能原因 |
|---|---|---|
| 连接被拒 | `nc -zv host port` | 服务未启动、防火墙拦截、端口错误 |
| DNS 解析失败 | `nslookup host` | DNS 配置错误、域名不存在、网络不通 |
| HTTPS 证书错误 | `openssl s_client` | 证书过期、域名不匹配、自签名 |
| HTTP 重定向过多 | `curl -I -L` | 配置了强制 HTTPS、CDN 跳转 |
| 延迟高 | `curl -w "time_total"` | 网络拥塞、CDN 节点远、服务器负载高 |

## 注意事项

1. **防火墙可能导致误判** — 某些端口被防火墙拦截显示 CLOSED，不一定是服务问题
2. **DNS 缓存** — 修改 DNS 后需清缓存
3. **SNI** — 访问泛域名证书需要 `-servername` 参数
4. **ping 被禁** — 很多服务器禁 ping，用 curl 或 nc 测

## 脚本工具

`scripts/netdiag.sh` — 网络诊断一键检查

---

*记录版本：v0.1*
