#!/bin/bash


LOG_GROUP=/xhunt/task-cluster/dalfox-reflected-xss
NOW=`date +%s`000
YESTERDAY=$((${NOW} - 86400000))

aws logs filter-log-events --log-group-name $LOG_GROUP --region $AWS_REGION --start-time $YESTERDAY --end-time $NOW | jq '.events[].message'
# aws logs filter-log-events --log-group-name my-group [--log-stream-names LIST_OF_STREAMS_TO_SEARCH] [--start-time 1482197400000] [--end-time 1482217558365] [--filter-pattern VALID_METRIC_FILTER_PATTERN]
