#!/bin/bash
set -e

CRITIC_NAME="$1"
WORK_ID="$2"

if [ -z "$CRITIC_NAME" ] || [ -z "$WORK_ID" ]; then
    echo "Usage: spawn-critic.sh <critic-name> <work-bead-id>"
    exit 1
fi

WORKSPACE="/atlantis/philosophy/critics/$CRITIC_NAME"
SESSION="atlantis-critic-$CRITIC_NAME"

echo "📋 Spawning Critic: $CRITIC_NAME for work $WORK_ID"

# Check if session already exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "❌ Session $SESSION already exists"
    echo "   Kill it first: tmux kill-session -t $SESSION"
    exit 1
fi

# Create tmux session
echo "🖥️  Creating tmux session: $SESSION"
tmux new-session -d -s "$SESSION" -c "$WORKSPACE"

# Start Claude with bypass permissions and Opus model
echo "🤖 Starting Claude Code with Opus model..."
tmux send-keys -t "$SESSION" "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-opus-4-5\"}'" C-m

# Wait for Claude to start
sleep 3

# Send initial prompt
echo "📤 Sending review prompt..."
PROMPT="You are Critic $CRITIC_NAME. Read your ASSIGNMENT.md file and begin your review of the assigned work. Follow the review structure in your role template carefully. When complete, run 'gt done'."

tmux send-keys -t "$SESSION" -l "$PROMPT"
tmux send-keys -t "$SESSION" C-m

echo ""
echo "✅ Critic $CRITIC_NAME spawned successfully!"
echo ""
echo "Next steps:"
echo "  1. Attach to accept bypass consent:"
echo "     docker compose exec atlantis tmux attach -t $SESSION"
echo "     (Press Down arrow, Enter, Enter)"
echo ""
echo "  2. Detach to let critic work:"
echo "     (Press Ctrl+B, then D)"
echo ""
echo "  3. Monitor progress:"
echo "     docker compose exec atlantis tmux attach -t $SESSION"
echo ""
