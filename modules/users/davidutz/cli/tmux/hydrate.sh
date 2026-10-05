#!/usr/bin/env bash
set -euo pipefail

ROOT_PERSONAL="$HOME/personal"
ROOT_WORK="$HOME/work"
PWD="$(pwd)"

if [[ "$PWD" != "$ROOT_PERSONAL"* && "$PWD" != "$ROOT_WORK"* ]]; then
  clear
  exit 0
fi

SESSION="$(tmux display-message -p '#S')"

has_file() {
  [[ -f "$1" ]]
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

window_exists() {
  tmux list-windows -F "#W" | grep -qx "$1"
}

new_window() {
  local name="$1"
  shift

  if ! window_exists "$name"; then
    tmux new-window -d -n "$name" "$@"
  fi
}

# windows

tmux rename-window nvim
tmux send-keys -t "$SESSION:nvim" "nvim ." C-m

new_window "scratch"
tmux send-keys -t "$SESSION:scratch" "clear" C-m

new_window "runner"
tmux select-window -t "$SESSION:runner"

new_window "logs"
new_window "ai"

# setups

setup_laravel() {
  # runner
  tmux kill-pane -a

  tmux split-window -h
  tmux select-pane -L
  tmux send-keys "php artisan serve" C-m

  tmux select-pane -R
  tmux send-keys "pnpm dev" C-m

  # logs
  tmux select-window -t "$SESSION:logs"
  tmux send-keys "tail -f storage/logs/laravel.log" C-m
}

if has_file artisan && has_file package.json; then
  setup_laravel
else
  tmux send-keys "clear" C-m
  # tmux display-message "no runner detected"
fi

tmux select-window -t "$SESSION:nvim"
clear
