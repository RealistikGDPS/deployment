#!/bin/bash
# Dumps MySQL and archives object storage into BACKUP_PATH, then prunes
# archives older than BACKUP_RETENTION_DAYS. Redis is rebuildable and skipped.
# Reads .env for paths. COMPOSE overrides the compose command, as in the Makefile.
set -euo pipefail

cd "$(dirname "$0")/.."
set -a
source .env
set +a

backup_path="${BACKUP_PATH:-./backups}"
retention_days="${BACKUP_RETENTION_DAYS:-14}"
data_path="${DATA_PATH:-./volumes}"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
compose="${COMPOSE:-docker compose}"

mkdir -p "$backup_path"

# Written under a temporary name so a failed dump never leaves a truncated
# archive that looks like a good backup.
echo "Dumping MySQL."
$compose exec -T mysql sh -c \
    'mysqldump --single-transaction --no-tablespaces --quick --routines --triggers -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
    | gzip > "${backup_path}/mysql-${stamp}.sql.gz.partial"
mv "${backup_path}/mysql-${stamp}.sql.gz.partial" "${backup_path}/mysql-${stamp}.sql.gz"

echo "Archiving object storage."
tar -czf "${backup_path}/storage-${stamp}.tar.gz.partial" -C "$data_path" storage
mv "${backup_path}/storage-${stamp}.tar.gz.partial" "${backup_path}/storage-${stamp}.tar.gz"

echo "Pruning archives older than ${retention_days} days."
find "$backup_path" -maxdepth 1 -type f \( -name 'mysql-*.sql.gz' -o -name 'storage-*.tar.gz' \) \
    -mtime "+${retention_days}" -print -delete

echo "Backup ${stamp} complete."
