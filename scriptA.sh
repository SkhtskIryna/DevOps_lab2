#!/bin/bash

# Utility function to start a container
start_container() {
    local container_name=$1
    local cpu_core=$2

    if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Container $container_name already exists. Removing it..."
        docker rm -f "$container_name"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Starting container $container_name on CPU core #$cpu_core"
    docker run --name "$container_name" --cpuset-cpus="$cpu_core" --network bridge -d skhtskiryna/my-http-server
}

# Utility function to stop a container
stop_container() {
    local container_name=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Stopping container $container_name"
    docker kill "$container_name"
}

# Get CPU load for a container
get_cpu_load() {
    local container_name=$1
    docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | grep "$container_name" | awk '{print $2}' | sed 's/%//'
}

# Get CPU core index based on container name
get_cpu_index() {
    case $1 in
        srv1) echo "0" ;;
        srv2) echo "1" ;;
        srv3) echo "2" ;;
        *) echo "0" ;; # Default core
    esac
}

# Pull new Docker image if available
pull_new_image() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Checking for a new image..."
    if docker pull skhtskiryna/my-http-server | grep -q "Downloaded newer image"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): New image found."
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S'): No new image found."
        return 1
    fi
}

# Update all containers
update_containers() {
    local containers=("srv1" "srv2" "srv3")
    for container in "${containers[@]}"; do
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Updating $container..."
        stop_container "$container"
        start_container "$container" "$(get_cpu_index "$container")"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): $container has been updated."
    done
}

# Monitor and manage containers
monitor_containers() {
    local srv1_busy_count=0
    local srv2_busy_count=0
    local srv2_idle_count=0
    local srv3_idle_count=0

    while true; do
        # Monitor srv1 for high CPU load
        if docker ps --format "{{.Names}}" | grep -q "^srv1$"; then
            local cpu_srv1=$(get_cpu_load "srv1")
            if (( $(echo "$cpu_srv1 > 47.0" | bc -l) )); then
                srv1_busy_count=$((srv1_busy_count + 1))
                if (( srv1_busy_count >= 2 )); then
                    echo "$(date '+%Y-%m-%d %H:%M:%S'): srv1 is busy. Starting srv2..."
                    if ! docker ps --format "{{.Names}}" | grep -q "^srv2$"; then
                        start_container "srv2" 1
                    fi
                fi
            else
                srv1_busy_count=0
            fi
        else
            start_container "srv1" 0
        fi

        # Monitor srv2 for high CPU load
        if docker ps --format "{{.Names}}" | grep -q "^srv2$"; then
            local cpu_srv2=$(get_cpu_load "srv2")
            if (( $(echo "$cpu_srv2 > 52.0" | bc -l) )); then
                srv2_busy_count=$((srv2_busy_count + 1))
                if (( srv2_busy_count >= 2 )); then
                    echo "$(date '+%Y-%m-%d %H:%M:%S'): srv2 is busy. Starting srv3..."
                    if ! docker ps --format "{{.Names}}" | grep -q "^srv3$"; then
                        start_container "srv3" 2
                    fi
                fi
            else
                srv2_busy_count=0
            fi
        fi

        # Monitor idle containers (srv3 and srv2)
        for container in srv3 srv2; do
            if docker ps --format "{{.Names}}" | grep -q "^$container$"; then
                local cpu=$(get_cpu_load "$container")
                if (( $(echo "$cpu < 1.0" | bc -l) )); then
                    if [[ "$container" == "srv3" ]]; then
                        srv3_idle_count=$((srv3_idle_count + 1))
                        if (( srv3_idle_count >= 2 )); then
                            echo "$(date '+%Y-%m-%d %H:%M:%S'): $container is idle. Stopping..."
                            stop_container "$container"
                        fi
                    elif [[ "$container" == "srv2" ]]; then
                        srv2_idle_count=$((srv2_idle_count + 1))
                        if (( srv2_idle_count >= 2 )); then
                            echo "$(date '+%Y-%m-%d %H:%M:%S'): $container is idle. Stopping..."
                            stop_container "$container"
                        fi
                    fi
                else
                    [[ "$container" == "srv3" ]] && srv3_idle_count=0
                    [[ "$container" == "srv2" ]] && srv2_idle_count=0
                fi
            fi
        done

        # Check for new image every 2 minutes
        if pull_new_image; then
            update_containers
        fi
        sleep 120
    done
}

# Trap SIGINT/SIGTERM for graceful shutdown
trap "echo 'Terminating script...'; exit 0" SIGINT SIGTERM

# Start monitoring
monitor_containers

