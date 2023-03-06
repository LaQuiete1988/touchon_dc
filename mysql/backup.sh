#!/usr/bin/env sh

backupDir="/var/backup"

if [[ ! -d ${backupDir}/daily ]]; then
    mkdir ${backupDir}/daily
fi

if [[ -f ${backupDir}/daily/db_backup.sql.gz ]]; then
    rm -f ${backupDir}/daily/db_backup.sql.gz
fi

# mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
# | gzip > ${backupDir}/$(date +'%d.%m.%Y')/db_backup.sql.gz

mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
| gzip > ${backupDir}/daily/db_backup.sql.gz

if [[ -f ${backupDir}/daily/db_backup.sql.gz ]]; then
    echo "$(date +'%b %d %H:%M:%S')  MySQL [OK] DB backup is done"
else
    echo "$(date +'%b %d %H:%M:%S')  MySQL [ERROR] DB backup failed"
fi
