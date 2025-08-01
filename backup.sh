#!/bin/bash

APP_DIR="/home/ec2-user/myapp"
BACKUP_DIR="/home/ec2-user/myapp_backup"

echo "Creating backup..."

# Remove ANY previous backup
rm -rf "$BACKUP_DIR"

# Only back up if app exists (first deploy might not)
if [ -d "$APP_DIR" ]; then
    cp -r "$APP_DIR" "$BACKUP_DIR"
    echo "Backup completed at $BACKUP_DIR"
else
    echo "No app to backup. Skipping."
fi
