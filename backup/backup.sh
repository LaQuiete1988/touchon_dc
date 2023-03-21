#!/usr/bin/env sh                                                                                                                                                                                                                                                                                                                       back>

# Directory to store backups
sourceDir="/var/backup"
backupDir=${SSH_BACKUP_DIR}
sshUser=${SSH_USER}
sshServer=${SSH_SERVER}
sshPort=${SSH_PORT}
sshClientDir=${SSH_CLIENT_DIR}

function userscriptsBackup ()
{
    rsync -azh --delete /var/www/server/userscripts ${sourceDir}/$1
    if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Userscripts $1 backup done." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Userscripts $1 backup failed." \
                >> /var/log/cron.log
        fi
}

function readmeBackup ()
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

    if [[ ! -f ${sourceDir}/$1/versions.txt ]]; then
        touch ${sourceDir}/$1/versions.txt
    else
        coreBackupVersion=$(cat ${sourceDir}/$1/versions.txt | grep 'CORE' | awk '{printf $3}')
        admBackupVersion=$(cat ${sourceDir}/$1/versions.txt | grep 'ADM' | awk '{printf $3}')
    fi

    if [[ "$coreBackupVersion" != "$coreCurrentVersion" || \
          "$admBackupVersion" != "$admCurrentVersion" ]]; then
        echo -e "CORE version $coreCurrentVersion\nADM version $admCurrentVersion" > ${sourceDir}/$1/versions.txt
        echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Adm and core versions updated." \
                >> /var/log/cron.log
    fi
}

if [[ $sshClientDir ]]; then

    userscriptsBackup daily
    readmeBackup daily

    tar zcvf - /var/backup/daily | \
    ssh ${sshUser}@${sshServer} -p ${sshPort} "[ -d $backupDir/$sshClientDir ] || mkdir $backupDir/$sshClientDir \
        && cat > $backupDir/$sshClientDir/daily.tar.gz"

    if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Daily backup was syncronized with BackupServer." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Daily backup has not syncronized with BackupServer." \
                >> /var/log/cron.log
        fi

    if [[ $(date +'%u') == 1 ]]; then
        
        userscriptsBackup weekly
        readmeBackup weekly
        cp ${sourceDir}/daily/db_backup.sql.gz $sourceDir/weekly
        tar zcvf - /var/backup/weekly | ssh $sshUser@$sshServer -p $sshPort "cat > $backupDir/$sshClientDir/weekly.tar.gz"
        
        if [ $? -eq 0 ]; then
            echo "$(date +'%b %d %H:%M:%S')  Backup [OK] Weekly backup was syncronized with BackupServer." \
                >> /var/log/cron.log
        else
            echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] Weekly backup has not syncronized with BackupServer." \
                >> /var/log/cron.log
        fi

    fi

else
    echo "$(date +'%b %d %H:%M:%S')  Backup [ERROR] SSH_CLIENT_DIR variable in .env file is not set." \
        >> /var/log/cron.log
fi
