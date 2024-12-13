#!/bin/bash

# Infinite loop to send HTTP requests periodically
while :
do
    # Generate a random delay between 5 and 10 seconds
    delay=$(( RANDOM % 6 + 5 ))

    # Wait for the generated delay time
    sleep "$delay"

    # Send an HTTP GET request to the server
    response=$(curl -i -X GET 127.0.0.1:8081/compute 2>/dev/null)

    # Print the response and the timestamp
    echo "Sent HTTP request at $(date)"
    echo "$response"

    echo "---------------------------------------"
done
