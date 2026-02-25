#!/bin/bash

DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backup"
DB_USER="moodleuser"
DB_PASS="12345"
FILENAME="backup_$DATE.tar.gz"

TMP_DIR="/tmp/backup_proses"
mkdir -p $TMP_DIR

mysqldump -u $DB_USER -p$DB_PASS --databases moodle > $TMP_DIR/moodle.sql

tar -czf $BACKUP_DIR/$FILENAME -C $TMP_DIR .

rm -rf $TMP_DIR
find $BACKUP_DIR -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;

echo "Backup berhasil disimpan di $BACKUP_DIR/$FILENAME"
