#!/bin/bash

# Log file for actions
LOGFILE="/var/log/kdevtmpfsi_killer.log"

# Function to find and kill the process
monitor_and_kill() {
    while true; do
        # Find PID of the process associated with /tmp/kdevtmpfsi
        PIDS=$(ps aux | grep "/tmp/kdevtmpfsi" | grep -v "grep" | awk '{print $2}')

        # Check if any process is found
        if [[ ! -z "$PIDS" ]]; then
            for PID in $PIDS; do
                echo "$(date) - Killing process $PID associated with /tmp/kdevtmpfsi" >> $LOGFILE
                kill -9 $PID
            done
        fi

        # Sleep for 10 seconds before the next check
        sleep 10
    done
}

# Run the function
monitor_and_kill