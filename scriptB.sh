#!/bin/bash

# Infinite loop to send requests asynchronously
while true; do

    # Sleep for a random time between 5 to 10 seconds
    sleep_time=$((5 + RANDOM % 6))
    sleep "$sleep_time"
    echo "Sleeping for $sleep_time seconds..."

    # Measure start time
    start_time=$(date +%s%3N)

    # Call the function to make a request
    curl -i -X GET 127.0.0.1/compute

    # Measure end time
    end_time=$(date +%s%3N)

    # Calculate the response time
    response_time=$((end_time - start_time))
    echo "Request sent at $(date)"
    echo "Response time: ${response_time} ms"
    echo "---------------------------------------"
done
