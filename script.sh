#!/bin/bash

# This script is meant to be invoqued by watch-config.sh when it detect a change in the folder it's watching.

set -e

PARAM=""
REST_OF_PARAMS=""

checkArgs () {
    if [ "$1" = "--param" ]; then
        PARAM="$1";
        shift;
    fi
    REST_OF_PARAMS="$@";
}

mainScript() {
    # TODO
    echo "Hello World from Bash-Watch-Changes by Pumbaa"
    echo -e "PARAM: $PARAM\nREST_OF_PARAMS: $REST_OF_PARAMS"
}

checkArgs $*;
mainScript