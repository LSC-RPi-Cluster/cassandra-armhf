#!/bin/bash

# Waiting until the cluster ring stabilizes

if [ -z "$TASK_NAME" ] || [ -z "$WAIT_TIME" ]
then
    echo "TASK_NAME and WAIT_TIME is not defined."
else
    echo "TASK_NAME: $TASK_NAME"
    wait_time=$(($(cut -d"." -f2 <<< $TASK_NAME) * $WAIT_TIME))
    echo "Waiting $wait_time seconds until the ring stabilizes..."
    sleep $wait_time
fi

echo "Starting the entrypoint..."
