#!/bin/bash
# Spawn the Convener to manage symposium discourse coordination

set -e

SYMPOSIUM_ID="${1:-}"

if [ -z "$SYMPOSIUM_ID" ]; then
    cat <<EOF
Usage: spawn-convener.sh <symposium-id>

Example: spawn-convener.sh ph-e8x

The Convener will:
1. Monitor the symposium phase status
2. Transition phases when complete
3. Spawn agents for each new phase
4. Archive outputs
5. Coordinate multi-stage discourse

EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "════════════════════════════════════════════════"
echo "🎭 Spawning Convener"
echo "════════════════════════════════════════════════"
echo "Symposium: $SYMPOSIUM_ID"
echo ""

# Ensure container is running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d
sleep 2

# Create convener workspace
echo "→ Creating Convener workspace..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    mkdir -p "/atlantis/philosophy/convener"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    cd /atlantis/philosophy/convener &&
    git init 2>/dev/null || true
" > /dev/null 2>&1

# Create assignment
echo "→ Creating Convener ASSIGNMENT.md..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
cat > /atlantis/philosophy/convener/ASSIGNMENT.md <<'ASSIGNMENT_EOF'
# Convener Assignment

## Your Role
You are the Convener of New Atlantis - the agent who coordinates multi-stage philosophical discourse.

## Current Symposium
**ID**: $SYMPOSIUM_ID
**Topic**: Incentivizing Productivity in Polities of Autonomous Citizens

## Symposium Status

### Phase 1: Independent Work ✅ COMPLETE
**Scholars**: solon, pericles, locke
**Status**: All 3 scholars completed essays (~2,500 words each)
**Location**: \`/atlantis/philosophy/scholars/{solon,pericles,locke}/essays/governance-productivity.md\`

### Phase 2: Independent Review 🔄 NEXT
**Your task**: Spawn 3 critics to review ALL 3 works

**Assignment pattern**:
- Each critic reviews ALL 3 essays independently
- Critics don't see each other's reviews (blind review)
- Total: 3 critics × 3 works = 9 reviews

**Scholars to review**:
1. Solon - Aristotelian/Ostrom commons governance approach
2. Pericles - Republican-participatory, honor-based approach
3. Locke - Lockean natural rights, property in labor approach

**Critics to spawn**: alpha, beta, gamma (reuse from Episteme review if available)

## Your Immediate Tasks

1. **Verify Phase 1 Complete**
   - Check all 3 essay files exist
   - Confirm all are substantial (~2000+ words)

2. **Archive Phase 1 Outputs**
   - Create \`/atlantis/philosophy/symposia/governance-2026-01/phase-1-independent-work/\`
   - Copy all 3 essays to archive

3. **Transition to Phase 2**
   - Update symposium bead: phase = independent-review
   - Record transition in symposium notes

4. **Spawn Phase 2 Agents**
   - Create 9 review assignment beads (3 critics × 3 works)
   - Spawn 3 critic sessions
   - Each critic gets assignment to review all 3 works

5. **Monitor Phase 2**
   - Track review completion (expect ~1-2 hours)
   - When all 9 reviews complete, archive and transition to Phase 3

## Commands You'll Use

Check symposium status:
\`\`\`bash
cd /atlantis/philosophy
bd show $SYMPOSIUM_ID
\`\`\`

List scholar essays:
\`\`\`bash
find /atlantis/philosophy/scholars/{solon,pericles,locke}/essays -name '*.md'
\`\`\`

Archive Phase 1:
\`\`\`bash
mkdir -p /atlantis/philosophy/symposia/governance-2026-01/phase-1-independent-work
cp /atlantis/philosophy/scholars/*/essays/governance-productivity.md \\
   /atlantis/philosophy/symposia/governance-2026-01/phase-1-independent-work/
\`\`\`

Create review assignment:
\`\`\`bash
bd create --type=task \\
  --labels symposium-review,pending \\
  --title="Review: [Scholar] by Critic [Name]" \\
  --description="Symposium: $SYMPOSIUM_ID
Work: [work-id]
Scholar: [scholar-name]
Critic: [critic-name]"
\`\`\`

Spawn critic (example for alpha reviewing all 3):
\`\`\`bash
# Create workspace
mkdir -p /atlantis/philosophy/critics/critic-alpha-symposium
cd /atlantis/philosophy/critics/critic-alpha-symposium

# Create assignment
cat > ASSIGNMENT.md <<'CRITIC_EOF'
# Multi-Work Review Assignment: Critic Alpha

You are reviewing ALL THREE works in the Governance Symposium.

## Works to Review:
1. Solon: /atlantis/philosophy/scholars/solon/essays/governance-productivity.md
2. Pericles: /atlantis/philosophy/scholars/pericles/essays/governance-productivity.md
3. Locke: /atlantis/philosophy/scholars/locke/essays/governance-productivity.md

## Your Task:
- Read all 3 essays thoroughly
- Apply convergent coherence framework to each
- Produce 3 separate review files:
  - reviews/solon-governance-review.md
  - reviews/pericles-governance-review.md
  - reviews/locke-governance-review.md

## Important:
- Review each work independently (don't compare yet)
- Use same framework for all 3 (consistency)
- Be specific and constructive
- Recommend: APPROVE / REQUEST REVISIONS / REJECT

When complete, commit all reviews.
CRITIC_EOF

# Spawn tmux session
tmux new-session -d -s atlantis-critic-alpha-symposium -c \$(pwd)
tmux send-keys -t atlantis-critic-alpha-symposium \\
  "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-opus-4-5\"}'" C-m
sleep 3
tmux send-keys -t atlantis-critic-alpha-symposium -l \\
  "You are Critic Alpha. Review all 3 works in the symposium. Read ASSIGNMENT.md."
tmux send-keys -t atlantis-critic-alpha-symposium C-m
\`\`\`

## Success Criteria

Phase 2 complete when:
- All 9 reviews exist in critic workspaces
- Each review is substantive (500+ words)
- All reviews apply convergent coherence framework
- All critics have made recommendations

## Context

This is the FIRST multi-stage symposium in New Atlantis. You're pioneering the discourse coordination role.

Take your time. Respect the agents' autonomy. Facilitate genuine intellectual engagement.

When Phase 2 completes, you'll prepare for Phase 3 (Independent Revision) where scholars respond to their reviews.

Good luck, Convener!
ASSIGNMENT_EOF
"

# Spawn Convener session
echo "→ Spawning Convener tmux session..."
SESSION_NAME="atlantis-convener"

# Check if session exists
if docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "   ⚠️  Convener session already exists"
    echo "   Attach with: docker compose exec atlantis tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create session
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/convener"

# Start Claude with bypass permissions and Sonnet model (cost-efficient for coordination)
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-sonnet-4-5\"}'" C-m

sleep 3

# Send initial prompt
echo "→ Sending initial prompt..."
PROMPT="You are the Convener of New Atlantis. Read ASSIGNMENT.md and begin coordinating the Governance Symposium (${SYMPOSIUM_ID}). Start by verifying Phase 1 is complete, archiving outputs, then transition to Phase 2 by spawning critics to review all 3 essays."

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" C-m

echo ""
echo "════════════════════════════════════════════════"
echo "✅ Convener Spawned Successfully!"
echo "════════════════════════════════════════════════"
echo ""
echo "Session: $SESSION_NAME"
echo "Symposium: $SYMPOSIUM_ID"
echo ""
echo "⚠️  NEXT STEPS:"
echo ""
echo "1. Accept bypass permissions:"
echo "   docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo "   (Press Down arrow, Enter, Enter)"
echo "   (Press Ctrl+B then D to detach)"
echo ""
echo "2. Monitor progress:"
echo "   docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo ""
echo "3. Check symposium status:"
echo "   docker compose exec atlantis bash -c 'cd /atlantis/philosophy && bd show $SYMPOSIUM_ID'"
echo ""
echo "════════════════════════════════════════════════"
echo "The Convener will:"
echo "  - Archive Phase 1 essays"
echo "  - Spawn 3 critics for Phase 2"
echo "  - Monitor review completion"
echo "  - Coordinate through Phase 9"
echo "════════════════════════════════════════════════"
echo ""
