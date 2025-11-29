#!/bin/bash

LOGFILE="$HOME/.config/hypr/logs/newWindow_event.log"

echo "==== $(date) ====" >> "$LOGFILE"
echo "New Window event received" >> "$LOGFILE"

# Capture JSON from argument (Hyprhook passes it as $1)
json="$1"

# Extract workspace id from json using jq
workspace_id=$(echo "$json" | jq '.workspace.id')

# Logging
echo "$json" >> "$LOGFILE"
echo "Workspace ID: $workspace_id" >> "$LOGFILE"

# Write to pipe
PIPE="$HOME/.config/hypr/pipes/fullscreen_pipe"

# Create pipe so it doesnt fail when daemon is not running
[ -p "$PIPE" ] || mkfifo "$PIPE"
echo "newWindow $workspace_id" >> "$PIPE" 