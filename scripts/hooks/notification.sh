#!/bin/bash
# notification.sh - Notification Hook
# Desktop notification for permission prompts / idle state (0 tokens)
# Official Guide: https://code.claude.com/docs/en/hooks-guide
set -euo pipefail

INPUT=$(cat)
TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude Code Notification"')

# Notification function (OS-specific)
send_notification() {
  local title="$1"
  local body="$2"
  
  # macOS
  if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$body\" with title \"$title\"" 2>/dev/null || true
    return
  fi
  
  # Linux (notify-send)
  if command -v notify-send &>/dev/null; then
    notify-send "$title" "$body" 2>/dev/null || true
    return
  fi
  
  # Windows (PowerShell)
  if command -v powershell.exe &>/dev/null; then
    powershell.exe -Command "[System.Windows.Forms.MessageBox]::Show('$body', '$title')" 2>/dev/null || true
    return
  fi
}

case "$TYPE" in
  permission_prompt)
    send_notification "Claude Code" "🔐 Permission required"
    ;;
  idle_prompt)
    send_notification "Claude Code" "⏳ Waiting for input"
    ;;
  *)
    # Ignore other notifications (to save tokens/resources)
    ;;
esac

exit 0
