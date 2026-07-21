#!/usr/bin/env bash

# get all the windows in a session
ttys=$(tmux list-windows -F "#{pane_tty}")
declare -A stats

# get the stats for each window/tty
echo "$ttys"
for tty in $ttys; do
  # awk '{stats[cpu]+=$1; stats[mem]+=$2}'
  # NOTE: date can have a line break in it, which will break the output
  data=$(ps -t "$tty" -o %cpu,%mem | grep -v "%CPU")
  # stats[cpu]=$(cut -d' ' -f2 <<<"$data")
  stats[cpu]=$(cut -d' ' -f2 <<<"$data")
  stats[mem]=$(cut -d' ' -f4 <<<"$data")
done
echo "CPU: ${stats[cpu]} MEM: ${stats[mem]}"
