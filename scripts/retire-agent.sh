#!/bin/bash
# Retire (gracefully stop) a New Atlantis agent
# Use this when you need to stop an agent manually

set -e

AGENT_NAME="$1"
FORCE="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ -z "$AGENT_NAME" ]; then
    echo "Usage: retire-agent.sh <agent-name> [--force]"
    echo ""
    echo "Gracefully retires (stops) an agent's tmux session."
    echo ""
    echo "Arguments:"
    echo "  agent-name   Session name or partial name (e.g., 'test-scholar', 'rawls')"
    echo "  --force      Kill immediately without confirmation"
    echo ""
    echo "Active sessions:"
    docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" || echo "  (no sessions found)"
    echo ""
    echo "Examples:"
    echo "  ./scripts/retire-agent.sh test-scholar"
    echo "  ./scripts/retire-agent.sh atlantis-philosophy-rawls"
    echo "  ./scripts/retire-agent.sh rawls --force"
    exit 1
fi

# Find the full session name
SESSION_NAME=""
if docker compose exec -T atlantis tmux has-session -t "$AGENT_NAME" 2>/dev/null; then
    SESSION_NAME="$AGENT_NAME"
elif docker compose exec -T atlantis tmux has-session -t "atlantis-$AGENT_NAME" 2>/dev/null; then
    SESSION_NAME="atlantis-$AGENT_NAME"
elif docker compose exec -T atlantis tmux has-session -t "atlantis-philosophy-$AGENT_NAME" 2>/dev/null; then
    SESSION_NAME="atlantis-philosophy-$AGENT_NAME"
elif docker compose exec -T atlantis tmux has-session -t "atlantis-critic-$AGENT_NAME" 2>/dev/null; then
    SESSION_NAME="atlantis-critic-$AGENT_NAME"
elif docker compose exec -T atlantis tmux has-session -t "atlantis-opposition-$AGENT_NAME" 2>/dev/null; then
    SESSION_NAME="atlantis-opposition-$AGENT_NAME"
else
    echo "Session not found: $AGENT_NAME"
    echo ""
    echo "Available sessions:"
    docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" || echo "  (no sessions found)"
    exit 1
fi

echo "Found session: $SESSION_NAME"

# Check for uncommitted work
echo ""
echo "Checking for uncommitted work..."

# Try to find the agent's workspace
WORKSPACE=""
if [[ "$SESSION_NAME" == *"philosophy"* ]]; then
    AGENT_SHORT=$(echo "$SESSION_NAME" | sed 's/atlantis-philosophy-//')
    WORKSPACE="/atlantis/philosophy/scholars/$AGENT_SHORT"
elif [[ "$SESSION_NAME" == *"critic"* ]]; then
    AGENT_SHORT=$(echo "$SESSION_NAME" | sed 's/atlantis-critic-//')
    WORKSPACE="/atlantis/philosophy/critics/$AGENT_SHORT"
elif [[ "$SESSION_NAME" == *"opposition"* ]]; then
    WORKSPACE="/atlantis/philosophy/opposition"
fi

if [ -n "$WORKSPACE" ]; then
    GIT_STATUS=$(docker compose exec -T atlantis sh -c "cd $WORKSPACE 2>/dev/null && git status --porcelain 2>/dev/null" || echo "")
    if [ -n "$GIT_STATUS" ]; then
        echo "⚠️  WARNING: Uncommitted changes detected in $WORKSPACE"
        echo "$GIT_STATUS"
        echo ""
        if [ "$FORCE" != "--force" ]; then
            read -p "Retire anyway? (y/N) " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Aborted."
                exit 1
            fi
        fi
    else
        echo "✓ No uncommitted changes detected"
    fi
fi

# Confirm unless --force
if [ "$FORCE" != "--force" ]; then
    echo ""
    read -p "Retire agent '$SESSION_NAME'? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Kill the session
echo ""
echo "Retiring agent..."
docker compose exec -T atlantis tmux kill-session -t "$SESSION_NAME"

echo "✓ Agent '$SESSION_NAME' has been retired"
echo ""

# Show remaining sessions
REMAINING=$(docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" || echo "")
if [ -n "$REMAINING" ]; then
    echo "Remaining active sessions:"
    echo "$REMAINING"
else
    echo "No remaining agent sessions."
fi
