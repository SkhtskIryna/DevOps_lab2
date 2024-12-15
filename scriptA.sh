#!/bin/bash

get_cpu_load() {
    docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | grep "$1" | awk '{print $2}' | sed 's/%//'
}

get_cpu_index() {
    case $1 in
        srv1) echo "0" ;;
        srv2) echo "1" ;;
        srv3) echo "2" ;;
        *) echo "0" ;;
    esac
}

start_container() {
    if docker ps --format "{{.Names}}" | grep -q "^$1$"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Container $1 already exists. Removing it..."
        docker rm -f "$1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Starting container $1 on core cpu #$2"
    docker run --name "$1" --cpuset-cpus="$2" --network bridge -d skhtskiryna/my-http-server
}

update_containers() {
    pull_result=$(docker pull skhtskiryna/my-http-server | grep "Downloaded newer image")
    if [ -n "$pull_result" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): New image detected ------> updating containers..."
        containers=("srv1" "srv2" "srv3")
        for container in "${containers[@]}"; do
            if sudo docker ps --format "{{.Names}}" | grep -q "^$container$"; then
                new_container="${container}_new"
                
                # Start new container
                start_container "$new_container" "$(get_cpu_index "$container")"
                
                # Stop and remove old container
                docker kill "$container"
                docker rm "$container"
                
                # Rename the new container to replace the old one
                docker rename "$new_container" "$container"
                echo "$container has been updated."
            fi
        done
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): No new image available."
    fi
}

manage_containers() {
    while true; do

        # srv1
        if docker ps --format "{{.Names}}" | grep -q "srv1"; then
            cpu_srv1=$(get_cpu_load "srv1")
            if (( $(echo "$cpu_srv1 > 45.0" | bc -l) )); then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): srv1 is busy. Starting srv2..."
                if ! docker ps --format "{{.Names}}" | grep -q "srv2"; then
                    start_container "srv2" 1
                fi
            fi
        else
            start_container "srv1" 0
        fi

        # srv2
        if docker ps --format "{{.Names}}" | grep -q "srv2"; then
            cpu_srv2=$(get_cpu_load "srv2")
            if (( $(echo "$cpu_srv2 > 27.0" | bc -l) )); then
                echo "$(date '+%Y-%m-%d %H:%M:%S'): srv2 is busy. Starting srv3..."
                if ! docker ps --format "{{.Names}}" | grep -q "srv3"; then
                    start_container "srv3" 2
                fi
            fi
        fi

        # Idle containers
        for container in srv3 srv2; do
            if docker ps --format "{{.Names}}" | grep -q "$container"; then
                cpu=$(get_cpu_load "$container")
                if (( $(echo "$cpu < 1.0" | bc -l) )); then
                    echo "$(date '+%Y-%m-%d %H:%M:%S'): $container is idle -----> terminating..."
                    docker kill "$container"
                    docker rm "$container"
                fi
            fi
        done

        # Update
        update_containers
        sleep 120
    done
}

manage_containers
