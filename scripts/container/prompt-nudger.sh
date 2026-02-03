#!/bin/bash
# Prompt Nudger - Kicks agents that are stuck at initial prompts
#
# Problem: Claude Code sessions sometimes need an extra Enter after the
# welcome screen before they process the initial prompt sent by spawn scripts.
#
# Solution: Periodically check all atlantis-* sessions. If a session shows
# the bypass permissions line but no activity indicator (spinning/thinking),
# send an Enter to kick it.
#
# Usage:
#   ./prompt-nudger.sh           # Run once
#   ./prompt-nudger.sh --daemon  # Run continuously every 30 seconds

set -euo pipefail

INTERVAL=30  # seconds between checks in daemon mode

nudge_stuck_sessions() {
    echo "$(date '+%H:%M:%S') - Checking for stuck sessions..."

    local nudged=0

    # Get all atlantis sessions
    while IFS= read -r session; do
        session_name=$(echo "$session" | cut -d: -f1)

        # Skip the convener - it manages itself
        if [[ "$session_name" == "atlantis-convener" ]]; then
            continue
        fi

        # Capture the last 10 lines of the pane
        local pane_content
        pane_content=$(tmux capture-pane -t "$session_name" -p -S -10 2>/dev/null) || continue

        # Check if it looks stuck:
        # - Has "bypass permissions" (Claude Code is loaded)
        # - Has the prompt indicator "❯"
        # - Does NOT have activity indicators (spinning, thinking, etc.)
        if echo "$pane_content" | grep -q "bypass permissions" && \
           echo "$pane_content" | grep -q "❯" && \
           ! echo "$pane_content" | grep -qE "(Thinking|thinking|Brewing|brewing|Cooking|cooking|Sautéing|Baking|Hatching|Tinkering|Effecting|Cogitat|ctrl\+c to interrupt)"; then

            # Additional check: is there a pending prompt (text after ❯)?
            if echo "$pane_content" | grep -E "❯.*[A-Za-z]" | grep -qv "^❯ *$"; then
                echo "  📤 Nudging $session_name (stuck at prompt)"
                tmux send-keys -t "$session_name" Enter 2>/dev/null || true
                ((nudged++)) || true
                sleep 0.5
            fi
        fi

    done < <(tmux ls 2>/dev/null | grep "^atlantis-" || true)

    if [[ $nudged -eq 0 ]]; then
        echo "  ✓ No stuck sessions found"
    else
        echo "  ✓ Nudged $nudged session(s)"
    fi
}

# Main
if [[ "${1:-}" == "--daemon" ]]; then
    echo "Starting prompt nudger daemon (interval: ${INTERVAL}s)"
    echo "Press Ctrl+C to stop"
    echo ""
    while true; do
        nudge_stuck_sessions
        sleep "$INTERVAL"
    done
else
    nudge_stuck_sessions
fi
