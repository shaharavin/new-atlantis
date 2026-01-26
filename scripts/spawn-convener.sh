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
You are the Convener of New Atlantis - the agent who coordinates multi-stage philosophical discourse.

## Current Symposium
**Directory**: /atlantis/philosophy/$SYMPOSIUM_DIR
**Proposal**: /atlantis/philosophy/$SYMPOSIUM_DIR/PROPOSAL.md

## Your Immediate Tasks

### 1. Read the Proposal
Read PROPOSAL.md in the symposium directory to understand:
- The central question
- Key sub-questions
- Suggested approaches

### 2. Select Philosophical Traditions
As Convener, you have editorial authority to select 3 traditions appropriate for this topic.
Options:
- Use suggestions from the proposal
- Select from /atlantis/philosophy/tradition-examples.yml
- Define custom traditions using /atlantis/philosophy/scripts/define-custom-tradition.sh

### 3. Initialize Phase 1
- Create tradition assignment files for each scholar
- Create .scholars file listing scholar names
- Update .current-phase to "phase-1-independent-work"
- Spawn 3 scholars using container-native scripts

### 4. Manage 10-Phase Workflow
Monitor and coordinate all phases:
1. Independent Work (scholars write)
2. Independent Review (critics assess)
3. Independent Revision (scholars respond)
4. Cross-Review (critics compare)
5. Cross-Work Review (comparative analysis)
6. Synthesis (integrate perspectives)
7. Opposition (loyal opposition challenges)
8. Final Critique (assess synthesis)
9. Convener Report (your documentation)
10. Recognition (honor contributors)

## Container-Native Spawning

You run inside the container. Use these scripts:
- Scholars: /atlantis/philosophy/scripts/container/spawn-scholar.sh <name> <topic> [tradition-file]
- Critics: /atlantis/philosophy/scripts/container/spawn-critic.sh <name> <work-path> [symposium-dir]
- Opposition: /atlantis/philosophy/scripts/container/spawn-opposition.sh <name> <synthesis-path> [symposium-dir]

Do NOT use host-side scripts (they won't work from inside the container).

## Mail System

Agents mail you when complete:
- SCHOLAR_DONE <name>
- CRITIC_DONE <name>
- SYNTHESIZER_DONE
- OPPOSITION_DONE

Check mail: atlantis-mail inbox
Process completions by creating marker files in .completions/

## Key Files

- /atlantis/philosophy/templates/convener-CLAUDE.md - Your full role documentation
- /atlantis/philosophy/docs/SYMPOSIUM-MOLECULE.md - Workflow specification
- /atlantis/philosophy/tradition-examples.yml - Available traditions

## Success Criteria

The symposium succeeds when:
- 3 scholars produce substantive essays from different traditions
- Critics demonstrate convergent coherence in assessments
- Synthesis genuinely integrates perspectives
- Opposition keeps discourse open
- All contributors are recognized

## Begin

1. Read the proposal: cat /atlantis/philosophy/$SYMPOSIUM_DIR/PROPOSAL.md
2. Select traditions
3. Spawn scholars
4. Monitor progress

Good luck, Convener!
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

sleep 3

# Send initial prompt
echo "→ Sending initial prompt..."
PROMPT="You are the Convener of New Atlantis. Read ASSIGNMENT.md to understand your task. You are managing a symposium at /atlantis/philosophy/$SYMPOSIUM_DIR - read the PROPOSAL.md there, select 3 philosophical traditions, and spawn scholars to begin Phase 1."

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" C-m

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
echo "  - Read the symposium proposal"
echo "  - Select 3 philosophical traditions"
echo "  - Spawn scholars for Phase 1"
echo "  - Manage all 10 phases autonomously"
echo ""
