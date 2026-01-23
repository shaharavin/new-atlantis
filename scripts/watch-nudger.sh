#!/bin/bash
# Watch Nudger patrol activity in real-time

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "Watching Nudger patrol activity..."
echo "Press Ctrl+C to exit"
echo ""

# Create a named pipe for nudger output
NUDGER_LOG="/tmp/nudger-watch-$$.log"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Stopped watching Nudger"
    rm -f "$NUDGER_LOG"
    exit 0
}
trap cleanup INT TERM

# Capture tmux output from nudger session
docker compose exec -T atlantis bash -c "
    # Create a simple monitor loop
    while true; do
        # Capture current pane content
        tmux capture-pane -t atlantis-nudger -p 2>/dev/null || echo 'Nudger session not found'
        echo '─────────────────────────────────────────'
        echo \"Last updated: \$(date '+%H:%M:%S')\"
        sleep 10
    done
"
