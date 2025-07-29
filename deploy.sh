#!/bin/bash

echo "🔄 Killing existing Node.js processes..."
pkill node || echo "No Node.js process found."

echo "🚀 Starting app..."
cd ~/myapp || { echo "❌ Failed to cd into ~/myapp"; exit 1; }

nohup node app.js > app.log 2>&1 &

echo "✅ App deployed!"

