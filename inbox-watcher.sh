#!/usr/bin/env bash
# inbox-watcher.sh - prints one line per new .txt file dropped into an inbox folder,
# then moves the file to inbox/sent. Built to run under Claude Code's Monitor tool:
# each printed line becomes a notification in the session.
#
# Usage:  bash inbox-watcher.sh [inbox_dir]      (default: ./inbox)
# Send a message:  echo "who is messi" > inbox/q1.txt

INBOX="${1:-inbox}"
mkdir -p "$INBOX/sent"

while true; do
  for f in "$INBOX"/*.txt; do
    [ -e "$f" ] || continue
    sleep 0.3                                   # let the writer finish
    echo "INBOX $(basename "$f"): $(tr '\r\n' '  ' < "$f")"
    mv "$f" "$INBOX/sent/$(date +%Y%m%d-%H%M%S)-$(basename "$f")"
  done
  sleep 1
done
