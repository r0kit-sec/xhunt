#!/bin/bash

URL=$1

if [ -z $URL ]; then
    echo Please submit a URL!
    exit 1
fi


DALFOX_NOTIFY_SCRIPT="/opt/notify/dalfox-notify.sh"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"

dalfox url -S --skip-grepping --skip-headless --skip-mining-all --no-color --found-action "$DALFOX_NOTIFY_SCRIPT @@query@@ @@type@@" $URL
