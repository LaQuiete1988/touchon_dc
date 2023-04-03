#!/usr/bin/env sh                                                                                                                                                                                                                                                                                                                       back>

# Directory to store backups
sourceDir=${SSH_SOURCE_DIR}
backupDir=${SSH_BACKUP_DIR}
sshUser=${SSH_USER}
sshServer=${SSH_SERVER}
sshPort=${SSH_PORT}
sshClientDir=${SSH_CLIENT_DIR}
mysqlHost=${MYSQL_HOST}
mysqlUser=${MYSQL_USER}
mysqlPassword=${MYSQL_PASSWORD}
mysqlDatabase=${MYSQL_DATABASE}


function userscriptsBackup ()
{
    rsync -azh --delete /var/www/server/userscripts $sourceDir/daily
    if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Userscripts daily backup succeeded." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Userscripts daily backup failed." \
                >> /var/log/cron.log
        fi
}


function dbBackup ()
{
    mysqldump --host=$mysqlHost --user=$mysqlUser --password=$mysqlPassword $mysqlDatabase \
        | gzip > $sourceDir/daily/db_backup.sql.gz

    if [[ -f $sourceDir/daily/db_backup.sql.gz ]]; then
        echo "$(date +'%b %d %H:%M:%S')  MySQL [OK] DB daily backup is succeeded" >> /var/log/cron.log
    else
        echo "$(date +'%b %d %H:%M:%S')  MySQL [ERROR] DB daily backup failed" >> /var/log/cron.log
    fi
}


function versionsBackup ()
{
    if [[ -f /var/www/server/readme.md ]]; then
        coreCurrentVersion=$(sed -n '/.*ver /s///p' < /var/www/server/readme.md)
    else
        coreCurrentVersion=$(sed -n '/.*ver /s///p' < /var/www/server/README.MD)
    fi

    if [[ -f /var/www/adm/readme.md ]]; then
        admCurrentVersion=$(sed -n '/.*ver /s///p' < /var/www/adm/readme.md)
    else
        admCurrentVersion=$(sed -n '/.*ver /s///p' < /var/www/adm/README.MD)
    fi

    if [[ ! -f $sourceDir/daily/versions.txt ]]; then
        touch $sourceDir/daily/versions.txt
    else
        coreBackupVersion=$(cat $sourceDir/daily/versions.txt | grep 'CORE' | awk '{printf $3}')
        admBackupVersion=$(cat $sourceDir/daily/versions.txt | grep 'ADM' | awk '{printf $3}')
    fi

    if [[ "$coreBackupVersion" != "$coreCurrentVersion" || \
          "$admBackupVersion" != "$admCurrentVersion" ]]; then
        echo -e "CORE version $coreCurrentVersion\nADM version $admCurrentVersion" > $sourceDir/daily/versions.txt
        echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Adm and core versions updated." \
                >> /var/log/cron.log
    fi
}

if [[ ! -d $sourceDir/daily ]]; then
    mkdir $sourceDir/daily
fi

if [[ ! -d $sourceDir/weekly ]]; then
    mkdir $sourceDir/weekly
fi

if [[ "${sshClientDir:-unset}" == "unset" ]]; then
    
    echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] SSH_CLIENT_DIR variable in .env file is not set." \
        >> /var/log/cron.log

else

    userscriptsBackup
    versionsBackup
    dbBackup

    tar zcvf - -C $sourceDir/daily . | \
        ssh $sshUser@$sshServer -p $sshPort "[ -d $backupDir/$sshClientDir ] || mkdir $backupDir/$sshClientDir \
        && cat > $backupDir/$sshClientDir/daily.tar.gz"

    if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Daily backup syncronization with BackupServer succeeded." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Daily backup syncronization with BackupServer failed." \
                >> /var/log/cron.log
        fi

    if [[ $(date +'%u') == 3 ]]; then
        
        cp -r $sourceDir/daily/* $sourceDir/weekly

        tar zcvf - -C $sourceDir/weekly . | \
            ssh $sshUser@$sshServer -p $sshPort "cat > $backupDir/$sshClientDir/weekly.tar.gz"
        
        if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Weekly backup syncronization with BackupServer succeeded." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Weekly backup syncronization with BackupServer failed." \
                >> /var/log/cron.log
        fi

    fi

fi
