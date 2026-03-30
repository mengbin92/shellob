---
name: backup-restore
description: Use when checking backup status, verifying backup files, or generating backup scripts for databases and files.
---

# Backup & Restore

## 概述

备份恢复 skill。用于检查备份状态、生成备份脚本、验证备份完整性、提供恢复指导。

## 核心能力

- 文件系统备份（rsync、tar）
- 数据库备份（MySQL、PostgreSQL、Redis、MongoDB）
- 备份脚本生成
- 备份文件验证
- 恢复演练指导
- 备份策略建议

## 命令清单

### 文件系统备份

```bash
# rsync 基本备份（增量）
rsync -avz /source/path/ /backup/path/

# rsync 删除源不存在的文件（镜像）
rsync -avz --delete /source/path/ /backup/path/

# rsync 显示进度
rsync -avz --progress /source/path/ /backup/path/

# rsync 限速（避免带宽占满）
rsync -avz --bwlimit=1000 /source/path/ /backup/path/

# rsync 通过 SSH（加密传输）
rsync -avz -e ssh /source/path/ user@host:/backup/path/

# tar 打包
tar -czvf backup.tar.gz /path/to/dir

# tar 打包排除某些文件
tar -czvf backup.tar.gz --exclude='*.log' --exclude='tmp/' /path/to/dir

# tar 增量备份（配合 find 和 --newer）
tar -czvf backup.tar.gz --newer="2026-03-01" /path/to/dir

# 查看 tar 包内容
tar -tzvf backup.tar.gz | head -20

# 解压到指定目录
tar -xzvf backup.tar.gz -C /target/path/
```

### MySQL 备份

```bash
# 单数据库备份
mysqldump -h <host> -P <port> -u <user> -p<password> \
    --single-transaction \
    --routines --triggers \
    <database> > backup.sql

# 所有数据库备份
mysqldump -h <host> -P <port> -u <user> -p<password> \
    --all-databases \
    --single-transaction > full_backup.sql

# 压缩备份
mysqldump -h <host> -P <port> -u <user> -p<password> \
    <database> | gzip > backup.sql.gz

# 指定表备份
mysqldump -h <host> -P <port> -u <user> -p<password> \
    <database> <table1> <table2> > tables.sql

# 远程备份（一条命令）
mysqldump -h <host> -P <port> -u <user> -p<password> \
    <database> | gzip | ssh user@backup-server "cat > /backup/db.sql.gz"

# 恢复
mysql -h <host> -P <port> -u <user> -p<password> <database> < backup.sql

# 压缩备份恢复
gunzip < backup.sql.gz | mysql -h <host> -P <port> -u <user> -p<password> <database>
```

### PostgreSQL 备份

```bash
# 单数据库备份
pg_dump -h <host> -p <port> -U <user> -d <database> -f backup.sql

# 压缩备份
pg_dump -h <host> -p <port> -U <user> -d <database> | gzip > backup.sql.gz

# 全量备份
pg_dumpall -h <host> -p <port> -U <user> -f full_backup.sql

# 远程备份
pg_dump -h <host> -p <port> -U <user> -d <database> | ssh user@backup-server "cat > /backup/db.sql"

# 恢复
psql -h <host> -p <port> -U <user> -d <database> -f backup.sql

# 全量恢复
psql -h <host> -p <port> -U <user> -f full_backup.sql
```

### Redis 备份

```bash
# RDB 快照备份（同步，会阻塞）
redis-cli -h <host> -p <port> save

# BGSAVE（异步，不阻塞）
redis-cli -h <host> -p <port> bgsave

# 查看上次保存时间
redis-cli -h <host> -p <port> lastsave

# 复制备份文件（默认路径 /var/lib/redis/ 或 ~/.redis/）
# 具体路径查看 CONFIG GET dir
redis-cli -h <host> -p <port> CONFIG GET dir

# AOF 备份（追加文件）
# AOF 通常在 dir 目录下，文件名 appendonly.aof

# 远程复制备份文件
scp user@redis-server:/var/lib/redis/dump.rdb ./backup/

# 恢复：将备份文件复制到目标 Redis 的 dir 路径后重启
```

### MongoDB 备份

```bash
# 备份单个数据库
mongodump --host <host> --port <port> --db <database> --out /backup/

# 压缩备份
mongodump --host <host> --port <port> --db <database> --gzip --out /backup/

# 备份所有数据库
mongodump --host <host> --port <port> --out /backup/

# 备份到指定路径（压缩）
mongodump --host <host> --port <port> --db <database> --archive=/backup/db.gz --gzip

# 恢复
mongorestore --host <host> --port <port> --db <database> /backup/<database>/

# 从压缩文件恢复
mongorestore --host <host> --port <port> --db <database> --gzip --archive=/backup/db.gz

# drop 原数据库后恢复
mongorestore --host <host> --port <port> --db <database> --drop /backup/<database>/
```

### 备份验证

```bash
# 文件备份验证：校验 checksum
md5sum backup.tar.gz          # Linux
md5 backup.tar.gz              # macOS
sha256sum backup.tar.gz        # 更安全

# 备份前后对比文件数量
find /source -type f | wc -l   # 备份前
tar -tzvf backup.tar.gz | wc -l  # 备份后

# MySQL 备份验证：检查 SQL 文件行数和表结构
wc -l backup.sql
grep -c "CREATE TABLE" backup.sql

# 数据库备份恢复测试（恢复到一个临时库）
mysql -h <host> -P <port> -u <user> -p<password> -e "CREATE DATABASE IF NOT EXISTS test_restore"
mysql -h <host> -P <port> -u <user> -p<password> test_restore < backup.sql

# Redis 备份验证：检查 .rdb 文件存在且有内容
ls -lh /var/lib/redis/dump.rdb
file /var/lib/redis/dump.rdb
```

### 备份文件管理

```bash
# 查看备份目录大小
du -sh /backup/

# 备份文件按时间排序
ls -lth /backup/

# 删除 N 天前的备份
find /backup -name "*.sql" -mtime +7 -delete

# 保留最近 N 个备份（滚动）
ls -t /backup/*.sql.gz | tail -n +6 | xargs rm -f

# 检查备份文件是否在增长（防止备份失败）
ls -l /backup/*.sql.gz
```

## 备份策略建议

### 3-2-1 原则
- **3** 份数据副本
- **2** 种不同介质（本地 + 异地）
- **1** 份离线副本（防勒索软件）

### 备份频率

| 数据类型 | 频率 | 保留 |
|---|---|---|
| 数据库（全量） | 每天 | 7 天 |
| 数据库（增量/binlog） | 每小时 | 3 天 |
| 文件（重要） | 每天 | 30 天 |
| 配置文件 | 每次变更 | 永久 |
| 日志 | 每周轮转 | 90 天 |

### 常用备份脚本模板

**MySQL 每日备份 + 保留 7 天：**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
mysqldump -h localhost -u root -p<password> --all-databases | gzip > /backup/mysql_$DATE.sql.gz
find /backup -name "mysql_*.sql.gz" -mtime +7 -delete
```

**rsync 每日增量：**
```bash
#!/bin/bash
rsync -avz --delete /data/ /backup/data/
```

## 输出格式

```
## 备份状态报告

**时间：** YYYY-MM-DD HH:MM
**主机：** hostname

---

### 最新备份

| 类型 | 文件 | 大小 | 时间 | 状态 |
|---|---|---|---|---|
| MySQL | app_20260330.sql.gz | 1.2GB | 03:00 | ✅ 成功 |
| 文件 | /data | 5.6GB | 02:00 | ✅ 成功 |
| Redis | dump.rdb | 120MB | 02:30 | ✅ 成功 |

### 备份验证
- 备份文件数量：3
- 最近一次备份大小：正常（与上次对比）
- 备份文件权限：✅ OK

### ⚠️ 警告
1. MySQL 备份文件比昨天小 30%，建议检查
2. `/backup` 磁盘使用率 78%，注意清理

### 建议
1. 备份脚本已运行 30 天，建议加入监控告警
2. 考虑将重要备份同步到异地存储
```

## 恢复演练清单

> 每次恢复前务必确认以下内容

```
恢复前：
- [ ] 确认恢复目标环境
- [ ] 确认备份文件完整性
- [ ] 确认恢复点时间（RPO）
- [ ] 通知相关人员
- [ ] 准备回滚方案

恢复后：
- [ ] 验证数据完整性
- [ ] 验证应用功能
- [ ] 确认无数据丢失
- [ ] 通知相关人员恢复完成
```

## 注意事项

1. **备份前检查磁盘空间** — 备份失败常因磁盘满
2. **生产环境备份在低峰期** — 全量备份会锁表或占用 IO
3. **备份要加密存储** — 敏感数据用 gpg 或 openssl 加密
4. **定期做恢复演练** — 备份的意义在于能恢复
5. **备份脚本加日志** — 记录开始/结束时间、成功/失败状态

## 脚本工具

`scripts/backup-check.sh` — 备份状态检查

---

*记录版本：v0.1*
