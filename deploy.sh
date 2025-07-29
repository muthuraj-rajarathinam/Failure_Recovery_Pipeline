#!/bin/bash

echo "🔄 Killing existing Node.js processes..."
pkill node || echo "No Node.js process found."

echo "🚀 Starting app..."

# Go to workspace if needed
cd "$WORKSPACE" || { echo "❌ Failed to cd into $WORKSPACE"; exit 1; }

# Start the Node app
nohup node app.js > app.log 2>&1 &

echo "✅ App deployed!"
