#!/usr/bin/env bash

# Get the current tmux session name
session=$(tmux display-message -p "#{session_name}" 2>/dev/null)

# If not in a tmux session, exit gracefully
if [ -z "$session" ]; then
  echo "CPU:  0.0% | MEM:  0.0%"
  exit 0
fi

# Read total CPU jiffies from /proc/stat
read_total_cpu() {
  awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8}' /proc/stat
}

# Read per-process CPU jiffies (user + system) from /proc/[pid]/stat
read_pid_cpu() {
  local pid=$1
  if [ -f "/proc/$pid/stat" ]; then
    awk '{print $14+$15}' "/proc/$pid/stat" 2>/dev/null
  fi
}

# Collect PIDs from all panes in the session
pids=()
for tty in $(tmux list-panes -t "$session" -F "#{pane_tty}" 2>/dev/null); do
  while read -r pid; do
    [ -n "$pid" ] && pids+=("$pid")
  done < <(ps -t "$tty" -o pid= 2>/dev/null)
done

# If no processes, output zeros
if [ ${#pids[@]} -eq 0 ]; then
  printf "CPU:%5.1f%% | MEM:%5.1f%%" "0.0" "0.0"
  exit 0
fi

# Sample 1: total CPU and per-process CPU
total_cpu_1=$(read_total_cpu)
declare -A pid_cpu_1
for pid in "${pids[@]}"; do
  pid_cpu_1[$pid]=$(read_pid_cpu "$pid")
done

# Wait for a short interval to measure instantaneous usage
sleep 0.5

# Sample 2: total CPU and per-process CPU
total_cpu_2=$(read_total_cpu)
declare -A pid_cpu_2
for pid in "${pids[@]}"; do
  pid_cpu_2[$pid]=$(read_pid_cpu "$pid")
done

# Calculate delta total CPU jiffies
delta_total=$((total_cpu_2 - total_cpu_1))
if [ "$delta_total" -le 0 ]; then
  delta_total=1
fi

# Sum per-process CPU deltas and normalize
total_cpu_pct=0
for pid in "${pids[@]}"; do
  c1=${pid_cpu_1[$pid]:-0}
  c2=${pid_cpu_2[$pid]:-0}
  delta=$((c2 - c1))
  if [ "$delta" -gt 0 ]; then
    pct=$(awk "BEGIN {printf \"%.1f\", ($delta / $delta_total) * 100}")
    total_cpu_pct=$(awk "BEGIN {printf \"%.1f\", $total_cpu_pct + $pct}")
  fi
done

# Clamp to 100.0 max
total_cpu_pct=$(awk "BEGIN {v = $total_cpu_pct; if (v > 100) v = 100; printf \"%.1f\", v}")

# Memory: sum %mem from all processes in the session (already normalized to total RAM)
total_mem=0
for tty in $(tmux list-panes -t "$session" -F "#{pane_tty}" 2>/dev/null); do
  while read -r mem; do
    [ -z "$mem" ] && continue
    total_mem=$(awk "BEGIN {printf \"%.1f\", $total_mem + $mem}")
  done < <(ps -t "$tty" -o %mem= 2>/dev/null)
done

# Clamp memory to 100.0 max
total_mem=$(awk "BEGIN {v = $total_mem; if (v > 100) v = 100; printf \"%.1f\", v}")

printf "CPU:%5.1f%% | MEM:%5.1f%%" "$total_cpu_pct" "$total_mem"
