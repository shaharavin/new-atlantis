#!/bin/bash
# List all New Atlantis tmux sessions organized by type

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "════════════════════════════════════════════════════════════"
echo "           NEW ATLANTIS - ACTIVE SESSIONS"
echo "════════════════════════════════════════════════════════════"
echo ""

# Get all atlantis sessions
ALL_SESSIONS=$(docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" | cut -d: -f1 || echo "")

if [ -z "$ALL_SESSIONS" ]; then
    echo "No active sessions found"
    exit 0
fi

# Categorize sessions
COORDINATORS=""
SCHOLARS=""
CRITICS=""
OTHER=""

for session in $ALL_SESSIONS; do
    case $session in
        atlantis-convener|atlantis-nudger)
            COORDINATORS="$COORDINATORS$session\n"
            ;;
        atlantis-critic-*)
            CRITICS="$CRITICS$session\n"
            ;;
        atlantis-*)
            # Not a critic or coordinator, must be a scholar
            SCHOLARS="$SCHOLARS$session\n"
            ;;
    esac
done

# Display coordinators
if [ -n "$COORDINATORS" ]; then
    echo "COORDINATORS:"
    echo "─────────────────────────────────────────────────────────────"
    echo -e "$COORDINATORS" | grep -v "^$" | sed 's/atlantis-/  ✓ /'
    echo ""
fi

# Display scholars
if [ -n "$SCHOLARS" ]; then
    echo "SCHOLARS / SYNTHESIZERS:"
    echo "─────────────────────────────────────────────────────────────"
    echo -e "$SCHOLARS" | grep -v "^$" | sed 's/atlantis-/  ✓ /'
    echo ""
fi

# Display critics
if [ -n "$CRITICS" ]; then
    echo "CRITICS:"
    echo "─────────────────────────────────────────────────────────────"
    echo -e "$CRITICS" | grep -v "^$" | sed 's/atlantis-/  ✓ /'
    echo ""
fi

echo "════════════════════════════════════════════════════════════"
echo ""
echo "ATTACH TO SESSION:"
echo "  docker compose exec atlantis tmux attach -t <session-name>"
echo ""
echo "MONITOR BY TYPE:"
echo "  ./scripts/monitor-agents.sh scholar      # All scholars/synthesizers"
echo "  ./scripts/monitor-agents.sh critic       # All critics"
echo "  ./scripts/monitor-agents.sh coordinator  # Convener + Nudger"
echo ""
