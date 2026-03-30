#!/bin/bash
# db-check.sh — 数据库快速巡检（MySQL / PostgreSQL / Redis）
# 用法: ./db-check.sh <mysql|postgres|redis> [host] [port]

DB_TYPE="${1:-}"
HOST="${2:-localhost}"
PORT="${3:-}"

echo "=========================================="
echo "  Database Health Check"
echo "  Type: ${DB_TYPE:-未指定}"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# MySQL
mysql_check() {
    local HOST="$1"
    local PORT="${2:-3306}"
    echo ""
    echo "### MySQL 巡检 ($HOST:$PORT)"
    echo "- 连接数: $(mysql -h "$HOST" -P "$PORT" -u root -p -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | awk 'NR==2 {print $2}')"
    echo "- 运行中线程: $(mysql -h "$HOST" -P "$PORT" -u root -p -e "SHOW STATUS LIKE 'Threads_running';" 2>/dev/null | awk 'NR==2 {print $2}')"
    echo "- 慢查询数: $(mysql -h "$HOST" -P "$PORT" -u root -p -e "SHOW STATUS LIKE 'Slow_queries';" 2>/dev/null | awk 'NR==2 {print $2}')"
    echo "- QPS: $(mysql -h "$HOST" -P "$PORT" -u root -p -e "SHOW GLOBAL STATUS LIKE 'Queries';" 2>/dev/null | awk 'NR==2 {print $2}')"
    echo "- 最大连接数: $(mysql -h "$HOST" -P "$PORT" -u root -p -e "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | awk 'NR==2 {print $2}')"
}

# PostgreSQL
postgres_check() {
    local HOST="$1"
    local PORT="${2:-5432}"
    echo ""
    echo "### PostgreSQL 巡检 ($HOST:$PORT)"
    echo "- 当前连接数: $(psql -h "$HOST" -p "$PORT" -U postgres -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | tail -1 | tr -d ' ')"
    echo "- 最大连接数: $(psql -h "$HOST" -p "$PORT" -U postgres -c "SHOW max_connections;" 2>/dev/null | tail -1 | tr -d ' ')"
    echo "- 事务数: $(psql -h "$HOST" -p "$PORT" -U postgres -c "SELECT sum(xact_commit) FROM pg_stat_database;" 2>/dev/null | tail -1 | tr -d ' ')"
}

# Redis
redis_check() {
    local HOST="$1"
    local PORT="${2:-6379}"
    echo ""
    echo "### Redis 巡检 ($HOST:$PORT)"
    redis-cli -h "$HOST" -p "$PORT" info clients 2>/dev/null | grep -E "connected_clients|blocked_clients"
    redis-cli -h "$HOST" -p "$PORT" info memory 2>/dev/null | grep -E "used_memory_human|maxmemory_human"
    redis-cli -h "$HOST" -p "$PORT" dbsize 2>/dev/null
    echo "- 持久化状态:"
    redis-cli -h "$HOST" -p "$PORT" info persistence 2>/dev/null | grep -E "rdb_last_save_time|aof_last_write_status"
}

# 根据类型执行
case "$DB_TYPE" in
    mysql)
        mysql_check "$HOST" "${PORT:-3306}"
        ;;
    postgres)
        postgres_check "$HOST" "${PORT:-5432}"
        ;;
    redis)
        redis_check "$HOST" "${PORT:-6379}"
        ;;
    *)
        echo ""
        echo "用法: $0 <mysql|postgres|redis> [host] [port]"
        echo "示例: $0 mysql localhost 3306"
        ;;
esac

echo ""
echo "=========================================="
echo "  检查完成"
echo "=========================================="
