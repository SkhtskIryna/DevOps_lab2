#!/bin/bash

# Infinite loop to send requests asynchronously
while true; do

    # Sleep for a random time between 5 to 10 seconds
    sleep_time=$((5 + RANDOM % 6))
    sleep "$sleep_time"
    echo "Sleeping for $sleep_time seconds..."

    # Call the function to make a request asynchronously
    curl -i -X GET 127.0.0.1/compute
    echo "Request sent at $(date)"
    echo "---------------------------------------"
done
