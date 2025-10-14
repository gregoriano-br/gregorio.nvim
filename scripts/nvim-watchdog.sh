#!/usr/bin/env bash
# Run a Neovim headless command with a timeout watchdog to prevent hangs
# Usage: nvim-watchdog.sh <timeout-seconds> -- <nvim args...>

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <timeout-seconds> -- <nvim args...>" >&2
  exit 2
fi

TIMEOUT=$1
shift
if [[ "$1" != "--" ]]; then
  echo "Missing -- separator before nvim args" >&2
  exit 2
fi
shift

if command -v timeout >/dev/null 2>&1; then
  exec timeout --preserve-status --signal=TERM --kill-after=2 "$TIMEOUT" nvim "$@"
else
  # Fallback watchdog using background process
  (
    sleep "$TIMEOUT"
    echo "[watchdog] Timeout (${TIMEOUT}s) reached; sending TERM to nvim (pid $$)" >&2
    pkill -TERM -P $$ nvim || true
    sleep 2
    pkill -KILL -P $$ nvim || true
  ) &
  WD_PID=$!
  nvim "$@"
  STATUS=$?
  kill "$WD_PID" >/dev/null 2>&1 || true
  exit "$STATUS"
fi
