#!/bin/bash

PIPE="$HOME/.config/hypr/pipes/fullscreen_pipe"

# Ensure the pipe exists but first remove it so it's flushed
[ -p "$PIPE" ] && rm "$PIPE"
mkfifo "$PIPE"

echo "Daemon started. Waiting for fullscreen events..."

# Associative array: wsid => address
declare -A workspacesInFs

# Boolean used to handle the hyprland fullscreen closing problem
ignoreNextEvent=0

while true; do
    read -r event wsid address < "$PIPE"
    echo "Received command: $event"
    echo "Received WorkspaceId: $wsid"
    echo "Received Address: $address"

    # Check if workspace is registered
    if [[ -v workspacesInFs["$wsid"] ]]; then
        # Workspace is already fullscreen
        if [[ "$event" == "fullscreen" && ignoreNextEvent -eq 0 ]]; then
            # Remove from dictionary
            unset "workspacesInFs[$wsid]"
        # Send Message when a new window gets created
        elif [[ "$event" == "newWindow" ]]; then
            echo "Display message"
            DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" \
            notify-send $'Your friendly daemon \U0001F608' \
            $'You are in full screen mode but the new window has been created :)' -t 3000
        # Window gets closed event handling
        elif [[ "$event" == "winclosed" ]]; then
            # If window that is in fullscreen gets closed remove the workspace from array
            if [[ "${workspacesInFs[$wsid]}" == "$address" ]]; then
                echo "remove workspace"
                unset "workspacesInFs[$wsid]"
                ignoreNextEvent=1
            fi
        fi
    # Workspace is not registered
    elif [[ "$event" == "fullscreen" && ignoreNextEvent -eq 0 ]]; then
        # Add kvp
        workspacesInFs["$wsid"]="$address"
    fi

    # Reset ignoreNextEvent after skipping one fullscreen event
    if [[ $ignoreNextEvent -eq 1 && "$event" == "fullscreen" ]]; then
        ignoreNextEvent=0
    fi
done
