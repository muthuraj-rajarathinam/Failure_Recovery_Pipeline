#!/bin/bash

URL="http://localhost:3000/health"

if curl --silent --fail "$URL"; then
  echo "Health check passed."
  exit 0
else
  echo "Health check failed."
  exit 1
fi
