#!/bin/bash

while true; do

    echo "-----------------------------------------"
    echo "$(date): Checking for a newer image on the server..."
    echo "-----------------------------------------"

    pullResult=$(docker pull skhtskiryna/my-http-server | grep "Downloaded newer image")

    if [ -n "$pullResult" ]; then
        echo "[INFO] Newer image detected."
        echo "[ACTION] Restarting 'srv1':"

        echo "  -> Sending SIGINT to 'srv1'..."
        docker kill --signal=SIGINT srv1

        echo "  -> Waiting for 'srv1' to terminate..."
        docker wait srv1

        echo "  -> Starting a new instance of 'srv1'..."
        docker run --name srv1 --rm -d skhtskiryna/my-http-server

        echo "[SUCCESS] 'srv1' has been successfully restarted with the newer image."
    else
        echo "[INFO] Image is already up-to-date."
    fi

    echo "-----------------------------------------"
    echo "[INFO] Sleeping for 10 seconds before the next check..."
    sleep 10

done
