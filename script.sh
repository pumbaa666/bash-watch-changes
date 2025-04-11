#!/bin/bash

# This script is meant to be invoked by watch-folder.sh when it detects a change.

set -e

FILE_CHANGED=""
EVENT_TRIGGERED=""
TIMESTAMP=""
LOG_FILE="./logs/fswatch_events.log"

checkArgs () {
    # TIMESTAMP=$(echo "$1" | awk '{print $1}')
    EVENT_TRIGGERED=$(echo "$1" | awk '{print $1}')
    FILE_CHANGED=$(echo "$1" | awk '{print $2}')
}

logEvents() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$TIMESTAMP | ⚡ $EVENT_TRIGGERED | 📁 $FILE_CHANGED" >> "$LOG_FILE"
    echo -e "Logged: ⚡ $EVENT_TRIGGERED on 📁 $FILE_CHANGED at $TIMESTAMP"
}

mainScript() {
    # Implements your logic here
    echo "coucou"
}

checkArgs "$@"
logEvents
mainScript
