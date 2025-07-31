#!/bin/bash

aws sns publish \
  --topic-arn arn:aws:sns:ap-south-1:idsns:ci-cd-alerts \
  --message "❌ Failure: Deployment failed." \
  --region ap-south-1
