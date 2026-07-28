# tmux-resource-monitor

A tmux plugin that displays CPU and memory usage for all processes in the current tmux session, shown in the status bar.

> NOTE: This is a work in progress and might not work as expected, please report any issues or better yet, PRs!

## Installation

### TPM (Recommended)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'theacebutler/tmux-resource-monitor'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/theacebutler/tmux-resource-monitor.git
echo 'run-resource-monitor /path/to/tmux-resource-monitor' >> ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

## Usage

Once installed, the status bar will show CPU and memory usage automatically:

```txt
CPU: 12.3% | MEM:  4.5%
```

### Toggle On/Off

Press `prefix + M` to toggle the resource monitor on or off.

## Configuration

Set these options in your `~/.tmux.conf` before running `prefix + I`:

| Option                        | Default  | Description                   |
| ----------------------------- | -------- | ----------------------------- |
| `@resource_monitor_interval`  | `5`      | Refresh interval in seconds   |
| `@resource_monitor_enabled`   | `1`      | `1` to enable, `0` to disable |
| `@resource_monitor_separator` | `" \| "` | Separator between CPU and MEM |

### Example

```tmux
set -g @plugin 'theacebutler/tmux-resource-monitor'
set -g @resource_monitor_interval 10
set -g @resource_monitor_separator " -- "
```

## Supported Platforms

- Linux
- macOS
