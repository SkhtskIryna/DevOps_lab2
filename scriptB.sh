#!/bin/bash

# URL of the server
SERVER_URL="127.0.0.1/compute"

# Function to make a GET request
make_request() {
    curl -i -X GET $SERVER_URL
}

# Infinite loop to send requests asynchronously
while true; do
    # Sleep for a random time between 5 to 10 seconds
    sleep_time=$((5 + RANDOM % 6))
    sleep $sleep_time

    # Call the function to make a request asynchronously
    make_request &

    # Optional: print the time of the request for logging
    echo "Request sent at $(date)"
    echo "---------------------------------------"
done
