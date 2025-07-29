#!/bin/bash
aws sns publish \
  --topic-arn arn:aws:sns:ap-south-1:616461148225:ci-cd-alerts \
  --message "✅ Success: App deployed successfully." \
  --region ap-south-1
