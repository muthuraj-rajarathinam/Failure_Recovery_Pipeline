#!/bin/bash

echo "🔄 Killing existing Node.js processes..."
pkill node

echo "🚀 Starting app..."
cd ~/myapp
nohup node app.js > app.log 2>&1 &

echo "✅ App deployed!"

