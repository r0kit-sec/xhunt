#!/bin/bash

URL=$1
DALFOX_QUEUE=$2

if [ -z $URL ]; then
    echo Please submit a URL!
    exit 1
fi


if [ -z $DALFOX_QUEUE ]; then
    echo Please specify the Dalfox queue URL!
    exit 1
fi

WORDLIST="/opt/wordlists/all_params.txt"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
OUTPUT_FILE="/tmp/arjun.txt"

arjun --headers "User-Agent: $USER_AGENT" -oT $OUTPUT_FILE -u $URL
interlace -tL $OUTPUT_FILE -threads 10 -c "aws sqs send-message --queue-url $DALFOX_QUEUE --message-body _target_"
