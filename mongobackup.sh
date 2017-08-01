#!/bin/sh
# 
# Creates backup files (bson) of all MongoDb databases on a given server.
# Default behaviour dumps the mongo database and tars the output into a file
# named after the current date. ex: 2016-12-19.tar.gz
#


HOST="localhost"
PORT="27017" # default mongo port is 27017
USERNAME=""
PASSWORD=""


BACKUP_PATH="/mnt/backup/mongo" 
FILE_NAME="DATE"

 

MONGO_DUMP_BIN_PATH="$(which mongodump)"
TAR_BIN_PATH="$(which tar)"

TODAYS_DATE=`date "+%Y-%m-%d"`

BACKUP_PATH="${BACKUP_PATH//DATE/$TODAYS_DATE}"

[ ! -d $BACKUP_PATH ] && mkdir -p $BACKUP_PATH || :

if [ -d "$BACKUP_PATH" ]; then

    cd $BACKUP_PATH
    
    TMP_BACKUP_DIR="mongodb-$TODAYS_DATE"
    
    echo; echo "=> Backing up Mongo Server: $HOST:$PORT"; echo -n '   ';
    
    if [ "$USERNAME" != "" -a "$PASSWORD" != "" ]; then 
        $MONGO_DUMP_BIN_PATH --host $HOST:$PORT -u $USERNAME -p $PASSWORD --out $TMP_BACKUP_DIR >> /dev/null
    else 
        $MONGO_DUMP_BIN_PATH --host $HOST:$PORT --out $TMP_BACKUP_DIR >> /dev/null
    fi
    
    if [ -d "$TMP_BACKUP_DIR" ]; then
    
        if [ "$FILE_NAME" == "" ]; then
            FILE_NAME="$TODAYS_DATE"
        fi
    
        FILE_NAME="${FILE_NAME//DATE/$TODAYS_DATE}"

        $TAR_BIN_PATH --remove-files -czf $FILE_NAME.tar.gz $TMP_BACKUP_DIR >> /dev/null

        if [ -f "$FILE_NAME.tar.gz" ]; then
            echo "=> Success: `du -sh $FILE_NAME.tar.gz`"; echo;
    

            if [ -d "$BACKUP_PATH/$TMP_BACKUP_DIR" ]; then
                rm -rf "$BACKUP_PATH/$TMP_BACKUP_DIR"
            fi
        else
             echo "!!!=> Failed to create backup file: $BACKUP_PATH/$FILE_NAME.tar.gz"; echo;
        fi
    else 
        echo; echo "!!!=> Failed to backup mongoDB"; echo;    
    fi
else

    echo "!!!=> Failed to create backup path: $BACKUP_PATH"

fi
