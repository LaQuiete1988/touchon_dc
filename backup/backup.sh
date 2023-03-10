#!/usr/bin/env sh                                                                                                                                                                                                                                                                                                                       back>

# Directory to store backups
sourceDir="/var/backup"
backupDir="~/vn/backup_test"
sshUser=${SSH_USER}
sshServer=${SSH_SERVER}

function userscriptsBackup ()
{
    # rsync -azvP --delete /var/www/server/userscripts ${sourceDir}/daily
    rsync -azh --delete /var/www/server/userscripts ${sourceDir}/$1
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

    if [[ $coreBackupVersion:-0.0 != "$coreCurrentVersion" || \
          $admBackupVersion:-0.0 != "$admCurrentVersion" ]]; then
        echo -e "CORE version $coreCurrentVersion\nADM version $admCurrentVersion" > ${sourceDir}/$1/versions.txt
    fi
}


userscriptsBackup daily
readmeBackup daily

tar zcvf - /var/backup/daily | \
ssh ${sshUser}@${sshServer} "[ -d ${backupDir}/${CLIENT_DIR} ] || mkdir ${backupDir}/${CLIENT_DIR} \
&& cat > ~/vn/backup_test/${CLIENT_DIR}/daily.tar.gz"

# rsync -arvt -t /var/backup/daily root@5.188.118.203:/root/backup/snapshot/$DATE

if [[ $(date +'%u') == 1 ]]; then
    userscriptsBackup weekly
    readmeBackup weekly
    cp ${sourceDir}/daily/db_backup.sql.gz ${sourceDir}/weekly
    tar zcvf - /var/backup/weekly | ssh ${sshUser}@${sshServer} "cat > ${backupDir}/${CLIENT_DIR}/weekly.tar.gz"
fi

