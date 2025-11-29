#!/bin/bash

PIPE="$HOME/.config/hypr/pipes/fullscreen_pipe"

# Ensure the pipe exists but first remove it so its flushed
rm "$PIPE"
[ -p "$PIPE" ] || mkfifo "$PIPE"

echo "Daemon started. Waiting for fullscreen events..."

# Infinite loop

workspacesInFs=()

while true; do
    read -r event wsid < "$PIPE"
    echo "Received command: $event"
    echo "Received WorkspaceId: $wsid"

    registered=0

    for item in "${workspacesInFs[@]}"; do
        if [[ "$item" == "$wsid" ]]; then
            registered=1
            break;
        fi
    done

    if [[ $registered -eq 1 ]]; then
        tmpArray=()
        for item in "${workspacesInFs[@]}"; do
            if [[ "$item" != "$wsid" ]]; then
                tmpArray+=("$item")
            fi
        done
        workspacesInFs=("${tmpArray[@]}")    
        registered=0    
    else
        workspacesInFs+=("$wsid")
    fi
    
    # Send a notification
    DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" \
    notify-send "Hyprland" "Fullscreen event: ${workspacesInFs[*]}" -t 3000
    
done
