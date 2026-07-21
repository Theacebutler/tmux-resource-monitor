#!/usr/bin/env bash

# Check for input parameter
if [[ -z "$1" ]]; then
  echo "Usage: ./getpaneprocessid.sh <pane name> <show PID tree> <socket file name>"
  echo "Where <pane name> is required, and the others are optional"
  exit 1
fi

# Get param
panName="$1"
outputTree="$2"
tmuxCallback="$3"

if [ "$outputTree" = '' ]; then
  outputTree=false
fi

# Get tty
if [ "$tmuxCallback" = '' ]; then
  sessions=$(tmux list-s -F "#{session_name} #{pane_tty}" | grep "^$panName " 2>/dev/null)
else
  sessions=$(tmux -S "$tmuxCallback" list-s -F "#{session_name} #{pane_tty}" | grep "^$panName " 2>/dev/null)
fi

if [ "$?" -ne "0" ]; then
  echo "No running tmux sessions detected."
  exit 1
fi

# Extract TTY
tty=$(echo "$sessions" | awk '{print $2}')

# Extract process IDs from tty
itemIndex=0
for p in $(ps -o pid -t "$tty" | tail -n +2); do
  process="$(awk -v PID=$p '{print PID}' /proc/$p/stat awk '{print $2}' 2>/dev/null)"
  if [[ $counter -eq "0" ]]; then
    result=$(printf "%s%s" "$result" "$process")
  else
    result=$(printf "%s\n%s" "$result" "$process")
  fi
  ((counter++))
done

if [ "$outputTree" = "true" ]; then
  echo "$result"
else
  echo "$result" | tail -1
fi

exit 1
