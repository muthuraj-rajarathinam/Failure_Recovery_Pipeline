#!/bin/bash

APP_DIR="/home/ec2-user/myapp"

echo "🔄 Killing existing Node.js processes..."
pkill node || echo "No Node.js process found."

echo "Deploying new version..."

# Remove old app & deploy new one
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
cp -r $WORKSPACE/* "$APP_DIR"

cd "$APP_DIR" || { echo "❌ Failed to cd into $APP_DIR"; exit 1; }

npm install

echo "🚀 Starting app..."
nohup node app.js > app.log 2>&1 &

echo "✅ App deployed!"
