#!/usr/bin/env bash

# resource-monitor.tmux — TPM plugin entry point
# Displays CPU and memory usage for the current tmux session in the status bar.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Read user options with defaults
interval=$(tmux show-option -gqv @resource_monitor_interval)
interval=${interval:-5}

enabled=$(tmux show-option -gqv @resource_monitor_enabled)
enabled=${enabled:-1}

cpu_format=$(tmux show-option -gqv @resource_monitor_cpu_format)
cpu_format=${cpu_format:-"CPU:%5.1f%%"}

mem_format=$(tmux show-option -gqv @resource_monitor_mem_format)
mem_format=${mem_format:-"MEM:%5.1f%%"}

separator=$(tmux show-option -gqv @resource_monitor_separator)
separator=${separator:-" | "}

# Export variables so the script can use them
export RM_CPU_FORMAT="$cpu_format"
export RM_MEM_FORMAT="$mem_format"
export RM_SEPARATOR="$separator"

if [ "$enabled" = "1" ]; then
    tmux set-option -g status-interval "$interval"
    tmux set-option -g status-right "#(bash ${SCRIPT_DIR}/scripts/resource-monitor.sh)"
fi

# Toggle keybinding: prefix + M
tmux bind-key M if-shell \
    "[ \"$(tmux show-option -gqv @resource_monitor_enabled 2>/dev/null || echo '1')\" = '1' ]" \
    "set-option -g @resource_monitor_enabled 0; set-option -g status-right ''; display-message 'Resource monitor: OFF'" \
    "set-option -g @resource_monitor_enabled 1; set-option -g status-right \"#(bash ${SCRIPT_DIR}/scripts/resource-monitor.sh)\"; display-message 'Resource monitor: ON'"
