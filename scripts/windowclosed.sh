#!/bin/bash

LOGFILE="$HOME/.config/hypr/logs/windowclosed.log"

echo "==== $(date) ====" >> "$LOGFILE"
echo "Window Closed event received" >> "$LOGFILE"

# Capture JSON from argument (Hyprhook passes it as $1)
json="$1"

# Extract relevant values from json using jq
workspace_id=$(echo "$json" | jq '.workspace.id')
address=$(echo "$json" | jq '.address')

# Logging
echo "$json" >> "$LOGFILE"
echo "Address: $pid" >> "$LOGFILE"

# Define PIPE
PIPE="$HOME/.config/hypr/pipes/fullscreen_pipe"


# Create pipe so it doesnt fail when daemon is not running
[ -p "$PIPE" ] || mkfifo "$PIPE"

# Write to PIPE
echo "winclosed $workspace_id $address" >> "$PIPE" 