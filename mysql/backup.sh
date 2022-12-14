#!/usr/bin/env sh

# Directory to store backups
dir="/var/backup/"

# Store backups for ${days}
days=5

date=$(date +"%d.%m.%Y")
mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} | gzip > ${dir}${date}.db_backup.sql.gz

find ${dir} -type f -mtime +${days} -exec rm -f {} \;