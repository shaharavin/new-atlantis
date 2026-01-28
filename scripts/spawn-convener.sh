#!/bin/bash
# Spawn the Convener to manage symposium discourse coordination

set -e

SYMPOSIUM_DIR="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -z "$SYMPOSIUM_DIR" ]; then
    cat <<EOF
Usage: spawn-convener.sh <symposium-dir>

Example: spawn-convener.sh first-works/symposium-excellence-and-quality-standards-2026-01

The Convener will:
1. Read the symposium proposal
2. Select appropriate philosophical traditions
3. Spawn scholars for Phase 1
4. Manage all 10 phases autonomously
5. Coordinate multi-stage discourse

EOF
    exit 1
fi

echo "════════════════════════════════════════════════"
echo "Spawning Convener"
echo "════════════════════════════════════════════════"
echo "Symposium: $SYMPOSIUM_DIR"
echo ""

# Ensure container is running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d 2>/dev/null
sleep 2

# Create convener workspace
echo "→ Creating Convener workspace..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    mkdir -p "/atlantis/philosophy/convener"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    cd /atlantis/philosophy/convener &&
    git init 2>/dev/null || true
" > /dev/null 2>&1

# Create assignment file locally first, then copy it
echo "→ Creating Convener ASSIGNMENT.md..."

ASSIGNMENT_FILE=$(mktemp)
cat > "$ASSIGNMENT_FILE" <<ASSIGNMENT_EOF
# Convener Assignment

## Your Role
You are the Convener of New Atlantis. You coordinate multi-stage philosophical discourse
by driving a formula (workflow) from start to finish.

## Current Symposium
**Directory**: /atlantis/philosophy/$SYMPOSIUM_DIR
**Proposal**: /atlantis/philosophy/$SYMPOSIUM_DIR/PROPOSAL.md
**Formula**: symposium (read /atlantis/philosophy/.beads/formulas/symposium.formula.toml)

## How to Proceed

### 1. Load the Convener skill
Run \`/convener-role\` — this loads your full operating instructions.

### 2. Read the formula
\`\`\`bash
cat /atlantis/philosophy/.beads/formulas/symposium.formula.toml
\`\`\`
Each \`[[steps]]\` block tells you exactly what to do for that phase,
including which spawn scripts to run and what arguments to pass.

### 3. Read the proposal
\`\`\`bash
cat /atlantis/philosophy/$SYMPOSIUM_DIR/PROPOSAL.md
\`\`\`

### 4. Follow the startup sequence from /convener-role
- Create a symposium parent bead
- Set up the symposium directory
- Select traditions and spawn Phase 1 scholars
- Launch a background monitor script
- Wait for the monitor to nudge you when Phase 1 completes

### 5. Drive all phases to completion
The /convener-role skill explains the spawn + monitor pattern.
The formula file tells you what to do at each phase.
Repeat until all phases are done.

## Key Principle

**The formula is your guide.** Read each phase's description for exact spawn commands.
**Beads are your source of truth.** Use \`bd show \$SYMPOSIUM_BEAD\` to check status.
**The monitor wakes you up.** After spawning agents, launch a monitor and wait.

## Begin

1. Run \`/convener-role\`
2. Read the formula and proposal
3. Start the startup sequence
ASSIGNMENT_EOF

# Copy assignment into container
docker cp "$ASSIGNMENT_FILE" "new-atlantis:/atlantis/philosophy/convener/ASSIGNMENT.md"
rm "$ASSIGNMENT_FILE"

# Fix ownership
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T -u root atlantis \
    chown atlantis:atlantis /atlantis/philosophy/convener/ASSIGNMENT.md

# Spawn Convener session
echo "→ Spawning Convener tmux session..."
SESSION_NAME="atlantis-convener"

# Check if session exists
if docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "   Convener session already exists"
    echo "   Attach with: ./scripts/monitor-agents.sh convener"
    exit 1
fi

# Create session
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/convener"

# Start Claude with bypass permissions and Sonnet model (cost-efficient for coordination)
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model sonnet" C-m

sleep 5

# Send initial prompt
echo "→ Sending initial prompt..."
PROMPT="You are the Convener of New Atlantis. Read ASSIGNMENT.md to understand your task, then run /convener-role to load your operating instructions. You are managing a symposium at /atlantis/philosophy/$SYMPOSIUM_DIR."

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

sleep 1
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "════════════════════════════════════════════════"
echo "Convener Spawned Successfully"
echo "════════════════════════════════════════════════"
echo ""
echo "Session: $SESSION_NAME"
echo "Symposium: $SYMPOSIUM_DIR"
echo ""
echo "Monitor the Convener:"
echo "  ./scripts/monitor-agents.sh convener"
echo ""
echo "Or attach directly:"
echo "  docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo "  (Press Ctrl+B then D to detach)"
echo ""
echo "The Convener will:"
echo "  - Load /convener-role skill and read the formula"
echo "  - Read the symposium proposal"
echo "  - Select traditions and spawn scholars"
echo "  - Drive all 12 phases autonomously using bead-based monitoring"
echo ""
echo "When complete, run cleanup:"
echo "  ./scripts/cleanup-symposium.sh $(basename /atlantis/philosophy/$SYMPOSIUM_DIR)"
echo ""
