---
name: web-server
description: Use when managing Nginx or Apache — checking config syntax, parsing access/error logs, or inspecting SSL certificates.
---

# Web Server Ops

## 概述

Web 服务器运维 skill。专注于 Nginx / Apache 的配置校验、日志分析、SSL 证书检查、性能监控。

## 核心能力

- Nginx / Apache 配置校验和语法检查
- 访问日志分析（TOP IP、TOP URL、状态码）
- 错误日志分析
- SSL 证书检查（有效期、配置、评分）
- 服务管理（重载、重启）
- 性能监控（连接数、请求速率）
- 泛域名证书识别

## 命令清单

### Nginx

```bash
# 检查 Nginx 是否运行
ps aux | grep nginx | grep -v grep

# 测试配置语法
nginx -t

# 查看 Nginx 配置
nginx -T  # 输出完整配置（含 include）

# 配置文件位置
# macOS (Homebrew): /usr/local/etc/nginx/nginx.conf
# Linux: /etc/nginx/nginx.conf
# Debian/Ubuntu: /etc/nginx/sites-enabled/default

# 重载配置（不中断服务）
nginx -s reload

# 优雅停止
nginx -s quit

# 强制停止
nginx -s stop

# 直接控制 systemd
systemctl reload nginx
systemctl restart nginx
```

### Apache

```bash
# 检查运行状态
ps aux | grep httpd | grep -v grep

# 测试配置语法
apachectl configtest

# 查看配置
apachectl -S

# 配置文件位置
# macOS: /usr/local/etc/httpd/httpd.conf
# Linux: /etc/httpd/conf/httpd.conf
# Debian/Ubuntu: /etc/apache2/apache2.conf

# 重载配置
apachectl graceful

# 直接控制 systemd
systemctl reload apache2
systemctl restart apache2
```

### 访问日志分析

```bash
# Nginx 访问日志路径
# macOS: /usr/local/var/log/nginx/access.log
# Linux: /var/log/nginx/access.log

# Apache 访问日志路径
# macOS: /usr/local/var/log/httpd/access_log
# Linux: /var/log/httpd/access_log

# TOP 10 请求 IP
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# TOP 10 请求 URL
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -10

# 状态码分布
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 5xx 错误请求
awk '$9 ~ /5[0-9][0-9]/ {print $1, $7, $9, $4}' access.log | head -20

# 慢请求（按响应时间，nginx 默认格式 $request_time）
awk '$NF > 5 {print $1, $7, $NF}' access.log | sort -k3 -rn | head -20

# 每小时请求量
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c

# 带宽统计（按 URL）
awk '{sum[$7]+=$10} END {for (url in sum) print sum[url]/1024/1024 "MB", url}' access.log | sort -rn | head -10
```

### 错误日志分析

```bash
# Nginx 错误日志路径
# macOS: /usr/local/var/log/nginx/error.log
# Linux: /var/log/nginx/error.log

# 错误级别统计
grep -oE "\[error\]|\[warn\]|\[crit\]" error.log | sort | uniq -c | sort -rn

# 最近 error
grep "\[error\]" error.log | tail -20

# 最近 warn
grep "\[warn\]" error.log | tail -20

# 连接失败（upstream 相关）
grep "upstream" error.log | tail -20

# 权限错误
grep "permission denied" error.log

# Open file limit
grep "too many open files" error.log
```

### SSL 证书

```bash
# 检查证书信息
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -dates -subject -issuer

# 检查证书链
echo | openssl s_client -connect example.com:443 -showcerts 2>/dev/null | head -50

# 检查 TLS 版本
echo | openssl s_client -tls1_2 -connect example.com:443 2>/dev/null | grep "Protocol"
echo | openssl s_client -tls1_3 -connect example.com:443 2>/dev/null | grep "Protocol"

# 检查 DH 参数
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl dhparam -in /dev/stdin -noout 2>/dev/null || echo "无 DH 参数"

# 检查证书过期
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -enddate

# 检查证书有效期天数
end_date=$(echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
days_left=$(($(date -d "$end_date" +%s) - $(date +%s) / 86400))
echo "剩余: $days_left 天"

# 检查 SNI 配置
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -subject

# 泛域名证书
echo | openssl s_client -connect example.com:443 -servername "*.example.com" 2>/dev/null | openssl x509 -noout -subject
```

### 连接与性能

```bash
# Nginx 连接状态
ngx_http_stub_status_module 或 ngxtop
# 需要先开启 stub_status on; 在 server {} 中

# 当前连接数
curl http://localhost/nginx_status 2>/dev/null

# 查看并发连接
netstat -an | grep :80 | grep ESTABLISHED | wc -l

# 查看 TIME_WAIT
netstat -an | grep :80 | grep TIME_WAIT | wc -l

# 请求速率（每秒）
awk 'END {print NR}' access.log  # 日志总行数
tail -1000 access.log | wc -l   # 最近 1000 行

# 查看 gzip 压缩率
awk -F'"' '{print $10}' access.log | awk '{sum+=$1; n++} END {print "avg:", sum/n}' access.log
```

## 输出格式

```
## Web 服务巡检报告

**服务器：** example.com
**Web 服务：** Nginx 1.24
**时间：** YYYY-MM-DD HH:MM

---

### 服务状态
- Nginx：✅ Running
- PID：12345
- 配置文件语法：✅ OK

### 访问统计（最近 1 小时）
- 总请求：45,230
- 峰值 QPS：128
- 5xx 错误：23（0.05%）

### TOP 5 请求 IP
1. 1.2.3.4 — 12,340 次
2. 5.6.7.8 — 8,230 次
...

### 状态码分布
- 200：42,000（93%）
- 404：2,100（4.6%）
- 5xx：130（0.3%）

### SSL 证书
- 域名：example.com
- 颁发者：Let's Encrypt
- 有效期至：2026-06-15（剩余 77 天）
- TLS 版本：TLS 1.2 ✅ / TLS 1.3 ✅

### ⚠️ 警告
1. 证书将在 77 天后过期，建议更新
2. 存在 404 请求 `/api/v2/users`（接口可能已废弃）

### 建议
1. 证书快过期前设置自动续期
2. 排查 `/api/v2/users` 的 404 请求
```

## 常见问题

| 问题 | 排查命令 | 可能原因 |
|---|---|---|
| 502 Bad Gateway | `grep "upstream" error.log` | upstream 服务挂了、超时 |
| 504 Gateway Timeout | `tail error.log` | upstream 响应慢、防火墙 |
| 403 Forbidden | `nginx -t` + 文件权限 | 文件权限不足、SELinux |
| 413 Request Too Large | `grep "client_body" error.log` | 上传文件超限 |
| SSL 证书错误 | `openssl s_client` | 证书过期、域名不匹配、SNI |
| 连接数过高 | `netstat -an | grep :80` | 攻击、爬虫、连接泄漏 |

## 注意事项

1. **改配置前先备份** — `nginx -t` 通过后再 `reload`
2. **日志切割** — 大流量站点日志文件可能很大，用 `logrotate` 管理
3. **error.log 不记录 5xx** — 5xx 通常在 access.log 里
4. **泛域名证书** — 需在每个子域名上配置 `server_name` 和 `ssl_certificate`

## 脚本工具

`scripts/web-check.sh` — Web 服务巡检脚本

---

*记录版本：v0.1*
