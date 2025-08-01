#!/bin/bash

APP_DIR="/home/ec2-user/myapp"
BACKUP_DIR="/home/ec2-user/myapp_backup"
LOG_FILE="/home/ec2-user/deploy.log"

echo "⚠️ Running rollback..." | tee -a $LOG_FILE
echo "⚠️ Rollback started at $(date)" >> $LOG_FILE

if [ -d "$BACKUP_DIR" ]; then
    rm -rf "$APP_DIR"
    cp -r "$BACKUP_DIR" "$APP_DIR"
    cd "$APP_DIR" || exit

    npm install

    pkill node || true
    nohup node app.js > app.log 2>&1 &

    echo "✅ Rollback finished!" | tee -a $LOG_FILE
    echo "✅ Rollback complete at $(date)" >> $LOG_FILE
else
    echo "❌ No backup found. Rollback failed!" | tee -a $LOG_FILE
    exit 1
fi
