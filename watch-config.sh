#!/bin/bash

set -e;

WATCHED_FOLDERS="./folder.tmp/"; # TODO param
FSWATCH_PID_FILE="/tmp/fswatchPid.tmp";

printHelp () {
    echo "Usage:";
    echo "watch-config [OPTION]";
    echo;
    echo "Options:";
    echo -e " --no-hup, -n\t\tWatch folder in background, immune to hangups";
    echo -e " --stop-watch, -s\tKill fswatch processes launched by --no-hup";
    echo -e " --help, -h\t\tPrint this help";
}

# Check arguments
checkArgs () {
    while test $# -gt 0
    do
        case "$1" in
            --no-hup) ;&
            -n) NOHUP=true;
                ;;

            --stop-watch) ;&                
            -s)
                STOP_WATCH=true;
                ;;

            --help) ;&
            -h) printHelp;
                exit 0;
                ;;

            *) >&2 echo "Invalid option '$1'";
                printHelp;
                exit 1;
                ;;
        esac
        shift;
    done
}

checkWorkingFolder () {
    if ! test -f "./script.sh"; then
        echo >&2 "Please cd into the BWC root directory before running this script.";
        exit 1;
    fi
}

# Test if watched folders exists
# https://stackoverflow.com/questions/6363441/check-if-a-file-exists-with-wildcard-in-shell-script
checkWatchedFolders () {
    if ! ls $WATCHED_FOLDERS 1> /dev/null 2>&1; then
        echo "$WATCHED_FOLDERS doesn't exist. Exiting";
        exit 1;
    fi
}

# Pretty print list of watched folders
printWatchedFolders () {
    echo "Watching : ";
    for f in $WATCHED_FOLDERS
    do
        echo -e "\t$(readlink -f $f)"; # Print absolute location
    done
}

# Test if fswatch is intalled
# Very good explaination on how to do that properly
# https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
checkFswatchInstalled () {
    command -v fswatch >/dev/null 2>&1 || {

        echo "fswatch is not installed, you have to install it";
        echo "On Ubuntu 18.04 and above : apt install fswatch";
        echo "On other Linux version by compiling it : https://github.com/emcrisostomo/fswatch#installation";
        echo "You can also see install-fswatch script to help you do it";
        echo;
        echo "Exiting without watching folders";
        exit 0;
    }    
}

# Test if fswatch is already running and ask the user if if wants to kill them.
# Only kill fswatch processes launched by this script
killFswatchProcesses () {
    fswatchPids=`pidof fswatch` || true; # pidof return a non-zero code when it find no process
    echo "fswatchPids: $fswatchPids"
    if [[ ! -z "$fswatchPids" ]]; then
        read -ra fswatchPids <<< $fswatchPids; # Transform string into an array

        tmpPids=($(cat $FSWATCH_PID_FILE));
        echo "last temp BWC PIDs: $tmpPids"

        # Compare current fswatch processes pid with pid saved in the tmp file
        for tmpPid in "${tmpPids[@]}"; do
            for fswatchPid in "${fswatchPids[@]}"; do
                if [ "$fswatchPid" = "$tmpPid" ] ; then
                    echo $fswatchPid >> $FSWATCH_PID_FILE;
                    fswatchPids="$fswatchPids $fswatchPid"
                    break;
                fi
            done
        done

        # Stop this function if there is no match between current fswatch pid and pid saved in the tmp file
        if [ -z "$fswatchPids" ]; then
            echo "No matches have been found, exiting"
            return 0;
        fi

        # If the user launched the script with --stop-watch argument :
        # kill the fswatch process and exit the script.
        if [ "$STOP_WATCH" = true ]; then
            kill -9 $fswatchPids;
            echo "Processes killed (PID: $fswatchPids)";
            echo > $FSWATCH_PID_FILE; # Empty the file
            exit 0;
        else
            read -p "It seems fswatch is already running. You should stop these processes ($fswatchPids ). Would you like to kill them ? (Yes, No, Abort) [y/n/A] : " killYN;
        fi

        case $killYN in
            [Yy]* )
                kill -9 $fswatchPids;
                echo "Processes killed (PID: $fswatchPids)";
                echo > $FSWATCH_PID_FILE; # Empty the file
                ;;

            [Nn]* )
                ;;

            * )
                echo "Aborting";
                exit 0;
                ;;
        esac
    fi
}

NOHUP=false;
STOP_WATCH=false;
checkArgs $*;
checkWorkingFolder;
checkWatchedFolders;
checkFswatchInstalled;
killFswatchProcesses;

# Do not watch if the user launched the script with --stop-watch argument
if [ "$STOP_WATCH" = true ]; then
    exit 0;
fi

printWatchedFolders;

# fswatch documentation : http://emcrisostomo.github.io/fswatch/doc/
if [ "$NOHUP" = true ]; then
    nohup fswatch -0r --event Created --event Updated -l 5 $WATCHED_FOLDERS | xargs -0I {} ./script.sh --no-hup {} &
    lastCommandPid=$(($! - 1)); # xargs is the last command. Fswatch id is the last minus one.
    echo $lastCommandPid >> $FSWATCH_PID_FILE;
    echo "fswatch PID : $lastCommandPid";
else
    fswatch -0r --event Created --event Updated -l 5 $WATCHED_FOLDERS | xargs -0I {} ./script.sh {};
    # Do not write the fswatch PID in the tmp file since the process will be terminated by a ctrl-c
fi
