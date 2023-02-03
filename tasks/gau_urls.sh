#!/bin/bash

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
SUBDOMAIN=$1
DALFOX_QUEUE=$2
ARJUN_PARAMETER_MINING_QUEUE=$3
SUBDOMAINS_URLS_DB_WRITER_QUEUE=$4
#DALFOX_QUEUE="https://sqs.us-east-2.amazonaws.com/042811066344/DalfoxUrlsQueue"

if [ -z $SUBDOMAIN ]; then
    echo Please provide a subdomain!
    exit 1
fi

if [ -z $DALFOX_QUEUE ]; then
    echo Please specify a dalfox queue!
    exit 1
fi

if [ -z $ARJUN_PARAMETER_MINING_QUEUE ]; then
    echo Please specify an arjun parameter mining queue!
    exit 1
fi

if [ -z $SUBDOMAINS_URLS_DB_WRITER_QUEUE ]; then
    echo Please specify a subdomains db urls writer queue!
    exit 1
fi

FILTERED_URLS_DESTINATION="/tmp/gau-filtered-urls.txt"
ALL_URLS_DESTINATION="/tmp/gau-urls.txt"

# Only submit urls with parameters
echo $SUBDOMAIN | gau --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,svg,webp --subs --timeout 120 --fc 404,302,301 --mt 'text/html,application/json' | uro | httpx -H "User-Agent: $USER_AGENT" > $ALL_URLS_DESTINATION
grep -P '(\.php.?\?|\.aspx?\?|\.do\?|\.jsp\?|\.cgi\?|\.html?\?|\.cfm\?).+' $ALL_URLS_DESTINATION > $FILTERED_URLS_DESTINATION

# Submit to dalfox
interlace -tL $FILTERED_URLS_DESTINATION -threads 50 -c "aws sqs send-message --queue-url $DALFOX_QUEUE --message-body _target_"

# Submit to arjun for more parameter mining
interlace -tL $FILTERED_URLS_DESTINATION -threads 50 -c "aws sqs send-message --queue-url $ARJUN_PARAMETER_MINING_QUEUE --message-body _target_"

# Process and store all URLs in the database
interlace -tL $ALL_URLS_DESTINATION -threads 50 -c "aws sqs send-message --queue-url $SUBDOMAINS_URLS_DB_WRITER_QUEUE --message-body _target_"
