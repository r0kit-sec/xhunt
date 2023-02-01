#! /bin/bash

TARGET=/tmp/xhunt-runnables.txt
REGION=ca-central-1

#aws batch list-jobs --region $REGION --job-queue XHuntTaskClusterJobQueue --job-status runnable --output text --query "jobSummaryList[*].[jobId]" --max-items 1000 > $TARGET


#aws batch cancel-job --region $REGION --job-id _target_ --reason 'Cancelling job.'


for i in $(aws batch list-jobs --region ${REGION} --job-queue XHuntTaskClusterJobQueue --job-status runnable --output text --query "jobSummaryList[*].[jobId]" --max-items 1000)
do
  echo "Cancel Job: $i"
  aws batch cancel-job --region $REGION --job-id $i --reason "Cancelling job." &
done
