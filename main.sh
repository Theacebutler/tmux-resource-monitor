#!/usr/bin/env bash

# get all the windows in a session
ttys=$(tmux list-windows -F "#{pane_tty}")
declare -A stats

# get the stats for each window/tty
echo "$ttys"
for tty in $ttys; do
  # awk '{stats[cpu]+=$1; stats[mem]+=$2}'
  data=$(ps -t "$tty" -o %cpu,%mem | grep -v "%CPU")
  # echo "$data"
  # stats[cpu]=$(cut -d' ' -f2 <<<"$data")
  stats[cpu]=$(cut -d' ' -f2 <<<"$data")
  stats[mem]=$(cut -d' ' -f4 <<<"$data")
done
echo "Total cpu usage: ${stats[cpu]}"
echo "Total mem usage:  ${stats[mem]}"
