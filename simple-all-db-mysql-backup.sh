#!/bin/bash
################################################################
##
##   MySQL Database Backup Script 
##   Written By: Rahul Kumar
##   URL: https://tecadmin.net/bash-script-mysql-database-backup/
##   Last Update: Jan 05, 2019
##
################################################################
export PATH=/bin:/usr/bin:/usr/local/bin

################################################################
################## Update below values  ########################
DB_BACKUP_PATH='/backup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='backup'
MYSQL_PASSWORD='supersecretpassword'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy
# DB skip list
DB_SKIP="information_schema"
#################################################################

TODAY=`date +"%F_%H-%M-%S"`
DIR_TODAY=`date +"%F"`

mkdir -p ${DB_BACKUP_PATH}/${DIR_TODAY}

DBS="$(mysql -h $MYSQL_HOST -p MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASSWORD -Bse 'show databases')"
for db in $DBS
do
    skipdb=-1
    if [ "$DB_SKIP" != "" ];
    then
		for i in $DB_SKIP
		do
			[ "$db" == "$i" ] && skipdb=1 || :
		done
    fi
 
    if [ "$skipdb" == "-1" ] ; then
        echo "Backup started for database - ${db}"
        mysqldump -h ${MYSQL_HOST} \
                  -P ${MYSQL_PORT} \
                  -u ${MYSQL_USER} \
                  -p${MYSQL_PASSWORD} \
                  ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${DIR_TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz
        if [ $? -eq 0 ]; then
            echo "Database backup successfully completed"
        else
            echo "Error found during backup"
        fi
    fi
done

if [ $? -eq 0 ]; then
    echo "Database backup successfully completed"
else
    echo "Error found during backup"
    exit 1
fi

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
DBDELDATE=`date +"%F" --date="${BACKUP_RETAIN_DAYS} days ago"`
if [ ! -z ${DB_BACKUP_PATH} ]; then
    echo "Removing backups older than ${BACKUP_RETAIN_DAYS} days..."
    cd ${DB_BACKUP_PATH}
    if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
        rm -rf ${DBDELDATE}
    fi
fi
### End of script ####