#!/bin/bash
# Spawn the Nudger - Community health monitor for New Atlantis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

SESSION_NAME="atlantis-nudger"

echo "Spawning Nudger (Community Health Monitor)..."

# Check if session already exists
if docker compose exec -T atlantis tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Nudger session already exists"
    echo "Attach with: docker compose exec atlantis tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create nudger workspace if it doesn't exist
docker compose exec -T atlantis bash -c "
    mkdir -p /atlantis/philosophy/nudger
    mkdir -p /atlantis/philosophy/nudger/nudges
    mkdir -p /atlantis/philosophy/nudger/logs
"

# Create nudger session
echo "→ Creating tmux session: $SESSION_NAME"
docker compose exec -T atlantis \
    tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/nudger"

# Wait for session to be ready
sleep 2

# Start Claude with Haiku model (most cost-efficient for simple monitoring)
echo "→ Starting Claude (Haiku model)..."
docker compose exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model haiku" C-m

# Wait for Claude to initialize
sleep 5

# Send the Nudger assignment
echo "→ Sending Nudger assignment..."

ASSIGNMENT="You are the Nudger for New Atlantis.

Your role: Monitor the health of scholars and critics, send gentle nudges to agents who appear stalled, and escalate serious blockers to the Founder.

## Your Identity
- Name: nudger
- Workspace: /atlantis/philosophy/nudger/
- Set: export ATLANTIS_AGENT_NAME=nudger

## Your Mission

Run a gentle monitoring loop every 10 minutes:

1. Check for active scholar/critic sessions (tmux ls | grep atlantis-)
2. For each session, check last git commit time
3. If 60+ minutes without commit → send gentle nudge via tmux
4. If 90+ minutes despite 3 nudges → escalate to Founder
5. Sleep 600s (10 minutes) before next patrol

## Key Commands

# List active sessions
tmux ls | grep -E \"atlantis-(solon|pericles|locke|scholar-|critic-)\"

# Check last commit time for an agent
cd /atlantis/philosophy/scholars/solon
git log -1 --format='%ct'  # Unix timestamp

# Calculate minutes since last commit
NOW=\$(date +%s)
LAST_COMMIT=\$(git log -1 --format='%ct')
MINUTES=\$(( (NOW - LAST_COMMIT) / 60 ))

# Send gentle nudge to a session
tmux send-keys -t atlantis-solon \"\" C-m
tmux send-keys -t atlantis-solon \"echo '═══ Gentle nudge: It's been \${MINUTES}m since your last commit. Still working? ═══'\" C-m

# Track nudges
mkdir -p nudges
echo \"\$(date +%s)\" > nudges/solon.txt

# Escalate if needed
export ATLANTIS_AGENT_NAME=nudger
atlantis-mail send founder \"ESCALATION solon\" \"Agent stalled 90+ min despite nudges\"

## Important Principles

- 60 minutes without commits is NORMAL for deep philosophical work
- Nudges are gentle reminders, not demands
- Respect autonomy - you're supporting, not policing
- Token efficient: 10-minute patrol cycle (not continuous)
- Only escalate after 3 nudges (90+ min total stall)

## Full Template

Read your full role description at:
cat /atlantis/templates/nudger-CLAUDE.md

## Begin

Start your patrol loop. Be gentle, patient, and respectful of agents' thinking time.

Remember: You serve the community by watching for genuine problems, not micromanaging autonomous scholars."

docker compose exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "$ASSIGNMENT" C-m

echo "✓ Nudger spawned successfully"
echo ""
echo "Monitor with: docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo "Detach with: Ctrl+B then D"
