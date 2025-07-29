#!/bin/bash

APP_DIR="/home/ec2-user/myapp"
LOG_FILE="/home/ec2-user/deploy.log"

echo "⚠️ Running rollback..."    # <-- [ADDED: visible in Jenkins console]
echo "⚠️ Rollback started at $(date)" >> $LOG_FILE

cd $APP_DIR || exit

# Revert to previous commit
git reset --hard HEAD~1

# Install dependencies
npm install

# Restart Node.js app
pkill node || true
nohup node server.js > app.log 2>&1 &

echo "✅ Rollback finished!"     # <-- [ADDED: visible in Jenkins console]
echo "✅ Rollback complete at $(date)" >> $LOG_FILE
