#!/bin/bash

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
SUBDOMAIN=$1
DALFOX_QUEUE=$2
#DALFOX_QUEUE="https://sqs.us-east-2.amazonaws.com/042811066344/DalfoxUrlsQueue"

if [ -z $SUBDOMAIN ]; then
    echo Please provide a subdomain!
    exit 1
fi

if [ -z $DALFOX_QUEUE ]; then
    echo Please specify a dalfox queue!
    exit 1
fi

URLS_DESTINATION="/tmp/gau-urls.txt"

# Only submit urls with parameters
echo $SUBDOMAIN | gau --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,svg,webp --subs --timeout 120 --fc 404,302,301 | uro | httpx -H "User-Agent: $USER_AGENT" | grep -P '\?.+' | anew $URLS_DESTINATION
interlace -tL $URLS_DESTINATION -threads 50 -c "aws sqs send-message --queue-url $DALFOX_QUEUE --message-body _target_"
