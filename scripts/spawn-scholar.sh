#!/bin/bash
# Spawn a New Atlantis scholar non-interactively using tmux
# Based on Gas Town's polecat spawning pattern

set -e

SCHOLAR_NAME="${1:-}"
BEAD_ID="${2:-}"

if [ -z "$SCHOLAR_NAME" ] || [ -z "$BEAD_ID" ]; then
    echo "Usage: $0 <scholar-name> <bead-id>"
    echo "Example: $0 episteme ph-3rs"
    exit 1
fi

# Load environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
if [ -f "$PROJECT_DIR/.env" ]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

echo "=== Spawning Scholar: $SCHOLAR_NAME ==="
echo "Bead: $BEAD_ID"
echo ""

# Tmux session name
SESSION_NAME="atlantis-philosophy-${SCHOLAR_NAME}"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    echo "Or kill with: tmux kill-session -t $SESSION_NAME"
    exit 1
fi

# Start container if not running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d

# Scholar workspace path
SCHOLAR_WORKSPACE="/atlantis/philosophy/scholars/${SCHOLAR_NAME}"

# Create tmux session inside container (detached)
echo "→ Creating tmux session: $SESSION_NAME"
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T atlantis \
    tmux new-session -d -s "$SESSION_NAME" -c "$SCHOLAR_WORKSPACE"

# Start Claude Code in the session with skip-permissions flag
echo "→ Starting Claude Code with --dangerously-skip-permissions"
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "claude --dangerously-skip-permissions" C-m

# Wait a moment for Claude to initialize
echo "→ Waiting for Claude to initialize..."
sleep 3

# Update bead status
echo "→ Updating bead status to in_progress"
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T atlantis \
    bash -c "cd /atlantis/philosophy && BEADS_IGNORE_REPO_MISMATCH=1 bd update $BEAD_ID --status in_progress"

# Send initial prompt (propulsion nudge)
echo "→ Sending initial prompt to scholar..."
INITIAL_PROMPT="Read your ASSIGNMENT.md and begin your philosophical inquiry following the 4-phase workflow. Start with Phase 1: Orientation."

docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$INITIAL_PROMPT"

# Send Enter key
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" C-m

echo ""
echo "✅ Scholar $SCHOLAR_NAME spawned successfully!"
echo ""
echo "Monitor progress:"
echo "  tmux attach -t $SESSION_NAME   # Attach to session"
echo "  docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo ""
echo "Check workspace:"
echo "  ./scripts/atlantis-container.sh exec \"cd $SCHOLAR_WORKSPACE && git log --oneline\""
echo ""
echo "View tmux sessions:"
echo "  docker compose exec atlantis tmux ls"
