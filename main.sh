#!/usr/bin/env bash
# get all the windows in a session
ttys=$(tmux list-windows -F "#{pane_tty}")
