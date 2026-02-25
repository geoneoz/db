sed -i 's/\r$//' db/db.sh
0 2 * * * /backup/backup_db.sh >> /var/log/backup_db.log 2>&1
