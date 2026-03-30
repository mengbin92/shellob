---
name: db-ops
description: Use when inspecting database status — checking connections, slow queries, table stats, or backup status for MySQL, PostgreSQL, MongoDB, or Redis.
---

# Database Ops

## 概述

数据库运维 skill。统一支持 MySQL / PostgreSQL / MongoDB / Redis 的状态检查、会话管理、慢查询分析。

**前置条件：** 相应客户端已安装并配置连接信息。

## 核心能力

- 数据库连接状态
- 会话/连接数统计
- 慢查询分析（MySQL / PostgreSQL）
- 表空间/索引状态
- 备份状态检查
- Redis 内存和 key 统计
- MongoDB 集合状态

## 命令清单

### MySQL

```bash
# 连接数据库
mysql -h <host> -P <port> -u <user> -p<password>

# 连接（不暴露密码）
mysql -h <host> -P <port> -u <user> -p

# 查看数据库列表
mysql -h <host> -P <port> -u <user> -p -e "SHOW DATABASES;"

# 查看连接数
mysql -h <host> -P <port> -u <user> -p -e "SHOW STATUS LIKE 'Threads_connected';"
mysql -h <host> -P <port> -u <user> -p -e "SHOW PROCESSLIST;"

# 查看最大连接数
mysql -h <host> -P <port> -u <user> -p -e "SHOW VARIABLES LIKE 'max_connections';"

# 杀掉长时间运行的查询
mysql -h <host> -P <port> -u <user> -p -e "KILL <process_id>;"

# 查看慢查询配置
mysql -h <host> -P <port> -u <user> -p -e "SHOW VARIABLES LIKE 'slow_query%';"
mysql -h <host> -P <port> -u <user> -p -e "SHOW VARIABLES LIKE 'long_query_time';"

# 查看慢查询日志
mysql -h <host> -P <port> -u <user> -p -e "SHOW GLOBAL STATUS LIKE 'Slow_queries';"

# 查看数据库大小
mysql -h <host> -P <port> -u <user> -p -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"

# 查看表大小
mysql -h <host> -P <port> -u <user> -p -e "SELECT table_schema, table_name, ROUND(data_length / 1024 / 1024, 2) AS 'Data (MB)', ROUND(index_length / 1024 / 1024, 2) AS 'Index (MB)' FROM information_schema.tables ORDER BY data_length DESC LIMIT 10;"

# MySQL 备份
mysqldump -h <host> -P <port> -u <user> -p<password> --single-transaction <database> > backup.sql

# 全量备份
mysqldump -h <host> -P <port> -u <user> -p<password> --all-databases > full_backup.sql
```

### PostgreSQL

```bash
# 连接数据库
psql -h <host> -p <port> -U <user> -d <database>

# 连接（用环境变量或 ~/.pgpass）
psql -h <host> -p <port> -U <user> -d <database> -c "\l"

# 查看连接数
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT count(*) FROM pg_stat_activity;"

# 查看活动连接
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT pid, usename, application_name, state, query_start FROM pg_stat_activity WHERE state != 'idle';"

# 查看最大连接数
psql -h <host> -p <port> -U <user> -d <database> -c "SHOW max_connections;"

# 杀掉连接
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT pg_terminate_backend(<pid>);"

# 查看慢查询（pg_stat_statements 需安装）
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT query, calls, mean_time, total_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# 查看数据库大小
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"

# 查看表大小
psql -h <host> -p <port> -U <user> -d <database> -c "SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) AS total_size FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 10;"

# PostgreSQL 备份
pg_dump -h <host> -p <port> -U <user> -d <database> -f backup.sql

# 全量备份（需 pg_dumpall）
pg_dumpall -h <host> -p <port> -U <user> -f full_backup.sql
```

### Redis

```bash
# 连接
redis-cli -h <host> -p <port>

# 认证（如需要）
redis-cli -h <host> -p <port> -a <password>

# Ping
redis-cli -h <host> -p <port> ping

# 查看连接数
redis-cli -h <host> -p <port> info clients

# 查看内存使用
redis-cli -h <host> -p <port> info memory

# 查看 key 数量
redis-cli -h <host> -p <port> dbsize

# 查看 Key 类型
redis-cli -h <host> -p <port> type <key>

# 查看所有 Key（生产环境慎用）
redis-cli -h <host> -p <port> keys "*"

# 模糊搜索 Key
redis-cli -h <host> -p <port> keys "user:*"

# 查看大 Key
redis-cli -h <host> -p <port> --bigkeys

# 内存分析
redis-cli -h <host> -p <port> memory stats

# 查看持久化状态
redis-cli -h <host> -p <port> info persistence

# 查看复制状态
redis-cli -h <host> -p <port> info replication

# 杀掉客户端连接
redis-cli -h <host> -p <port> client kill <ip>:<port>

# Redis 备份（RDB）
redis-cli -h <host> -p <port> save  # 同步保存
redis-cli -h <host> -p <port> bgsave  # 异步保存
```

### MongoDB

```bash
# 连接
mongosh "mongodb://<host>:<port>/<database>" -u <user> -p <password>

# 查看数据库列表
mongosh "mongodb://<host>:<port>" --quiet --eval "db.adminCommand('listDatabases')"

# 切换数据库
use <database>

# 查看集合
show collections

# 查看集合统计
db.<collection>.stats()

# 查看索引
db.<collection>.getIndexes()

# 查看连接数
db.adminCommand({connectionStatus: 1})

# 查看慢查询（需开启 Profiler）
db.getSiblingDB('admin').system.profile.find().limit(10)

# 集合大小
db.<collection>.dataSize()
db.<collection>.totalSize()

# 查看当前操作
db.currentOp()

# 杀掉慢查询
db.killOp(<opid>)

# MongoDB 备份（mongodump）
mongodump --host <host> --port <port> --db <database> --out /backup/

# 恢复
mongorestore --host <host> --port <port> --db <database> /backup/<database>
```

## 输出格式

```
## 数据库巡检报告

**数据库：** MySQL / PostgreSQL / Redis / MongoDB
**主机：** host:port
**时间：** YYYY-MM-DD HH:MM

---

### 连接状态
- 当前连接数：45 / 500（最大）
- 活动连接：38
- 休眠连接：7

### 性能指标
- QPS：1250
- 慢查询：3（最近 1 小时）
- 缓存命中率：98.5%

### 表/Key 统计
- 总 Key 数：1,234,567
- 内存使用：2.3GB / 8GB

### ⚠️ 异常
- 连接数接近上限（90%）
- 存在 1 个长时间运行查询（> 30s）

### 建议
1. 关注连接数增长，必要时调大 max_connections
2. 分析慢查询 `SELECT * FROM slow_log LIMIT 10`
```

## 常见问题

| 问题 | 排查命令 | 可能原因 |
|---|---|---|
| 连接数满 | `SHOW PROCESSLIST` / `pg_stat_activity` | 连接泄漏、慢查询堆积 |
| 慢查询 | `SHOW FULL PROCESSLIST` / `pg_stat_statements` | 缺索引、全表扫描 |
| Redis OOM | `redis-cli info memory` | key 过多、大 key、内存配置不足 |
| MongoDB 连接超时 | `db.adminCommand({connectionStatus:1})` | 连接池配置、网络问题 |
| 备份失败 | 检查磁盘空间和权限 | 磁盘满、权限不足 |

## 注意事项

1. **生产环境查询要加 LIMIT** — 全表扫描可能造成严重后果
2. **密码不写在命令里** — 用环境变量或配置文件
3. **杀掉查询要谨慎** — 强制终止可能造成锁表
4. **备份前检查磁盘空间** — 备份文件可能很大

## 脚本工具

`scripts/db-check.sh` — 数据库快速巡检（支持 MySQL / PostgreSQL / Redis）

---

*记录版本：v0.1*
