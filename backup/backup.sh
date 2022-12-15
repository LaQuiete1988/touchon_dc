#!/usr/bin/env sh

# Directory to store backups
dir="/var/backup/"

tar 10-8-0-1_mobile.tar.gz ${dir}/*

# rsync -azq --delete --remove-source-files \
# /var/backup/10-8-0-1_mobile.tar.gz \
# engineer@188.120.233.76:/home/devices/test/