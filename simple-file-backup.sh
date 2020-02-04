#!/bin/bash

##########################
#   SIMPLE FILE BACKUP   #
#        ver 0.9.3       #
##########################

# SETTINGS
## Backup name will be included in archive file name. If empty only date will be included
## $backupName-$now.tar.gz or $now.tar.gz
## Default: file-backup
backupName='file-backup'

## Date format in filename in linux date format
## Default: %Y-%m-%d
dateFormat='%Y-%m-%d'

## Location of backup archives (directory must exist)
## Default: /backups
targetDir='/backups'

## Location of directory to backup
## Default: /data
sourceDir='/data'

## Backup type:
## COPY - copy sourceDir to tempDir then archive tempDir
## DIRECT - directly archive sourceDir without local copy (useful for big dirs)
## Default: DIRECT
backupType='DIRECT'

## Temporary dir while using backupType=COPY
## Will be REMOVED after backup!
## Default: /tmp/simple-file-backup
tempDir='/tmp/simple-file-backup'

## Overwrite backup file if exist
## Default: false
overwriteBackup=false

## Send backup to FTP? (Using CURL)
## Default: false
send2FTP=false

## FTP Host
## IP or DOMAIN (using standard port 21)
## IP:PORT or DOMAIN:PORT
ftpHost='ftp.domain.com'

## FTP username
ftpUser='ftpUser'

## FTP password
ftpPasswd='superSecretPassword'

## FTP remote dir
## Empty means root directory of ftp account
ftpDir=''

# MAIN SCRIPT
now=$(date +${dateFormat})

if [ -z $backupName ]; then
    fileName="$now.tar.gz"
else
    fileName="$backupName-$now.tar.gz"
fi

if [ ! -d "${targetDir:+$targetDir/}" ]; then
    echo 'Target directory does not exist!'
    exit 0
fi

if [ ! -d "${sourceDir:+$sourceDir/}" ]; then
    echo 'Source directory does not exist!'
    exit 0
fi

if [ -e "filename" ] && [ $overwriteBackup ]; then
    rm -f "$targetDir/$fileName"
fi

echo 'Starting backup ...'
case $backupType in
'COPY')
    echo 'Making local copy of source dir ...'
    mkdir "$tempDir"
    cd "$tempDir" || exit
    cp -R "$sourceDir" "$tempDir"
    cd "$sourceDir" || exit
    echo 'Compressing files ...'
    tar czf "$targetDir/$fileName" -C "$sourceDir" .
    echo 'Removing temp dir ...'
    rm -rf "$tempDir"
    ;;
'DIRECT')
    echo 'Compressing files ...'
    tar czf "$targetDir/$fileName" -C "$sourceDir" .
    ;;
*)
   echo 'Wrong backup type! Chose COPY or DIRECT'
   exit 0
esac

if [ "$send2FTP" ]; then
    echo 'Sending backup to FTP Server ...'
    curl -T "$targetDir/$fileName" -u $ftpUser:$ftpPasswd $ftpHost/"$ftpDir"/
fi

echo 'Done!'
