#!/bin/bash
# Spawn the Convener to manage any formula-driven workflow
#
# The Convener reads the formula file to know what to do at each phase.
# The /convener-role skill teaches the generic spawn+monitor pattern.

set -e

SYMPOSIUM_DIR="${1:-}"
FORMULA_NAME="${2:-symposium}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -z "$SYMPOSIUM_DIR" ]; then
    cat <<EOF
Usage: spawn-convener.sh <work-dir> [formula-name]

Arguments:
  work-dir       - Path to the work directory (relative to /atlantis/philosophy/)
  formula-name   - Formula to execute (default: symposium)
                   Available: symposium, public-essay

Examples:
  spawn-convener.sh first-works/symposium-excellence-2026-01
  spawn-convener.sh first-works/symposium-excellence-2026-01/public-essay public-essay

The Convener will:
1. Load /convener-role skill
2. Read the formula file to learn what to do at each phase
3. Drive all phases autonomously using bead-based monitoring

EOF
    exit 1
fi

# Validate formula exists
FORMULA_PATH=".beads/formulas/$FORMULA_NAME.formula.toml"
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -f "/atlantis/philosophy/$FORMULA_PATH" 2>/dev/null; then
    echo "Error: Formula not found: $FORMULA_PATH"
    echo ""
    echo "Available formulas:"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        ls /atlantis/philosophy/.beads/formulas/*.formula.toml 2>/dev/null | \
        sed 's|.*/||; s|\.formula\.toml||' | sed 's/^/  /'
    exit 1
fi

echo "════════════════════════════════════════════════"
echo "Spawning Convener"
echo "════════════════════════════════════════════════"
echo "Work dir: $SYMPOSIUM_DIR"
echo "Formula:  $FORMULA_NAME"
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

# Ensure skills are available in the convener workspace
echo "→ Setting up skills..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    # Copy skills from repo to philosophy workspace if not present
    if [ ! -d /atlantis/philosophy/.claude/skills ]; then
        mkdir -p /atlantis/philosophy/.claude
        cp -r /new-atlantis-repo/.claude/skills /atlantis/philosophy/.claude/
    fi
    # Symlink skills into convener workspace
    mkdir -p /atlantis/philosophy/convener/.claude
    ln -sf /atlantis/philosophy/.claude/skills /atlantis/philosophy/convener/.claude/skills 2>/dev/null || true
"

# Create assignment file locally first, then copy it
echo "→ Creating Convener ASSIGNMENT.md..."

ASSIGNMENT_FILE=$(mktemp)
cat > "$ASSIGNMENT_FILE" <<ASSIGNMENT_EOF
# Convener Assignment

## Your Role
You are the Convener of New Atlantis. You coordinate multi-stage philosophical discourse
by driving a formula (workflow) from start to finish.

## Current Workflow
**Directory**: /atlantis/philosophy/$SYMPOSIUM_DIR
**Formula**: $FORMULA_NAME (read /atlantis/philosophy/$FORMULA_PATH)

## How to Proceed

### 1. Load the Convener skill
Run \`/convener-role\` — this loads your full operating instructions.

### 2. Read the formula
\`\`\`bash
cat /atlantis/philosophy/$FORMULA_PATH
\`\`\`
Each \`[[steps]]\` block tells you exactly what to do for that phase,
including which spawn scripts to run and what arguments to pass.

### 3. Read the work directory
\`\`\`bash
ls /atlantis/philosophy/$SYMPOSIUM_DIR/
\`\`\`
Understand what source material exists (proposals, prior symposium outputs, etc.)

### 4. Follow the startup sequence from /convener-role
- Create a parent bead for this workflow
- Set up output directories as needed
- Spawn agents for the first phase
- Launch a background monitor script
- Wait for the monitor to nudge you when the phase completes

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
PROMPT="You are the Convener of New Atlantis. Read ASSIGNMENT.md to understand your task, then run /convener-role to load your operating instructions. You are managing a $FORMULA_NAME workflow at /atlantis/philosophy/$SYMPOSIUM_DIR."

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

sleep 1
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" Enter

# Start the prompt nudger daemon (prevents agents from getting stuck at prompts)
echo "→ Starting prompt nudger daemon..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c '
    # Copy nudger script from repo if needed
    if [ ! -f /atlantis/philosophy/scripts/container/prompt-nudger.sh ]; then
        cp /new-atlantis-repo/scripts/container/prompt-nudger.sh /atlantis/philosophy/scripts/container/ 2>/dev/null || true
        chmod +x /atlantis/philosophy/scripts/container/prompt-nudger.sh 2>/dev/null || true
    fi

    # Kill any existing nudger
    if [ -f /atlantis/philosophy/nudger/prompt-nudger.pid ]; then
        OLD_PID=$(cat /atlantis/philosophy/nudger/prompt-nudger.pid)
        kill $OLD_PID 2>/dev/null || true
    fi

    # Start nudger daemon
    mkdir -p /atlantis/philosophy/nudger
    nohup /atlantis/philosophy/scripts/container/prompt-nudger.sh --daemon \
        > /atlantis/philosophy/nudger/prompt-nudger.log 2>&1 &
    echo $! > /atlantis/philosophy/nudger/prompt-nudger.pid
    echo "   Nudger daemon started (PID: $!)"
'

echo ""
echo "════════════════════════════════════════════════"
echo "Convener Spawned Successfully"
echo "════════════════════════════════════════════════"
echo ""
echo "Session: $SESSION_NAME"
echo "Work dir: $SYMPOSIUM_DIR"
echo "Formula:  $FORMULA_NAME"
echo ""
echo "Monitor the Convener:"
echo "  ./scripts/monitor-agents.sh convener"
echo ""
echo "Or attach directly:"
echo "  docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo "  (Press Ctrl+B then D to detach)"
echo ""
echo "The Convener will:"
echo "  - Load /convener-role skill and read the $FORMULA_NAME formula"
echo "  - Drive all phases autonomously using bead-based monitoring"
echo ""
echo "The prompt nudger daemon is running to prevent agents getting stuck."
echo "  Log: docker compose exec atlantis tail -f /atlantis/philosophy/nudger/prompt-nudger.log"
echo ""
echo "When complete, run cleanup:"
echo "  ./scripts/cleanup-symposium.sh \$(basename $SYMPOSIUM_DIR)"
echo ""
