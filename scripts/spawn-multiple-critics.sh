#!/bin/bash
# Spawn multiple critics in parallel for the same work
# Implements multi-critic convergence testing

set -e

WORK_ID="$1"
NUM_CRITICS="${2:-3}"

if [ -z "$WORK_ID" ]; then
    echo "Usage: spawn-multiple-critics.sh <work-bead-id> [num-critics=3]"
    echo ""
    echo "Example: spawn-multiple-critics.sh ph-3rs 3"
    echo "  Spawns 3 critics (critic-beta, critic-gamma, critic-delta) to review work ph-3rs"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Critic name pool (avoiding alpha since it already reviewed)
CRITIC_NAMES=("beta" "gamma" "delta" "epsilon" "zeta" "eta")

echo "════════════════════════════════════════════════"
echo "🔬 Multi-Critic Convergence Test"
echo "════════════════════════════════════════════════"
echo "Work ID: $WORK_ID"
echo "Critics to spawn: $NUM_CRITICS"
echo ""

# Ensure container is running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d
sleep 2

# Track spawned critics
SPAWNED_CRITICS=()

for i in $(seq 1 $NUM_CRITICS); do
    idx=$((i-1))
    CRITIC_NAME="critic-${CRITIC_NAMES[$idx]}"

    echo ""
    echo "────────────────────────────────────────────────"
    echo "📋 Spawning Critic $i/$NUM_CRITICS: $CRITIC_NAME"
    echo "────────────────────────────────────────────────"

    # Create review request bead
    echo "→ Creating review request bead..."
    REVIEW_ID=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy &&
        BEADS_IGNORE_REPO_MISMATCH=1 bd create \
            --type=task \
            --labels review-request,pending-review \
            --priority=2 \
            --title='Multi-critic review: $CRITIC_NAME for $WORK_ID' \
            --description='Work ID: $WORK_ID
Critic: $CRITIC_NAME
Convergence test: Critic $i of $NUM_CRITICS
Status: Pending spawn' \
            --silent
    " | tr -d '\r')

    echo "   Review ID: $REVIEW_ID"

    # Update with assignment
    echo "→ Assigning review to $CRITIC_NAME..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy &&
        BEADS_IGNORE_REPO_MISMATCH=1 bd update $REVIEW_ID \
            --assignee=$CRITIC_NAME \
            --add-label in-review
    " > /dev/null

    # Create critic workspace
    echo "→ Creating workspace..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        mkdir -p "/atlantis/philosophy/critics/$CRITIC_NAME"

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy/critics/$CRITIC_NAME &&
        git init 2>/dev/null || true
    " > /dev/null 2>&1

    # Create assignment file
    echo "→ Creating ASSIGNMENT.md..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cat > /atlantis/philosophy/critics/$CRITIC_NAME/ASSIGNMENT.md <<'ASSIGNMENT_EOF'
# Review Assignment: $CRITIC_NAME

## Multi-Critic Convergence Test
You are participating in a convergence test with ${NUM_CRITICS} critics reviewing the same work.

## Your Task
Review the scholarly work independently and produce a structured peer review.

**CRITICAL**: Do NOT consult other critics' reviews. This is a blind review to test convergence.

## Work to Review
Work ID: $WORK_ID
Location: \`/atlantis/philosophy/first-works/episteme/quality-assessment-without-ground-truth.md\`

## Review Framework
Apply the convergent coherence framework:
1. **Internal Coherence** - logical consistency, mutual support of claims
2. **Engagement with Discourse** - citations, positioning in debates
3. **Functional Success** - clarity, problem-solving, generativity
4. **Explicit Reasoning** - transparent argument structure

## Instructions
1. Read the work thoroughly (it's ~4,100 words)
2. Take notes on strengths and concerns
3. Write a structured review following your role template
4. Provide scores (1-5) for each criterion
5. Make a recommendation: APPROVE / REQUEST REVISIONS / REJECT
6. Run \`gt done\` when complete

## Output
Save your review to: \`reviews/episteme-$WORK_ID-review.md\`

## Context
Your review will be compared with ${NUM_CRITICS} other independent reviews to test whether convergent coherence produces inter-critic agreement. This is a meta-test of the framework the work itself proposes.
ASSIGNMENT_EOF
    "

    # Spawn critic session
    echo "→ Spawning tmux session..."
    SESSION_NAME="atlantis-critic-$CRITIC_NAME"

    # Check if session exists
    if docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "   ⚠️  Session already exists, skipping spawn"
        continue
    fi

    # Create session
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/critics/$CRITIC_NAME"

    # Start Claude with bypass permissions and Opus model
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-opus-4-5\"}'" C-m

    sleep 3

    # Send initial prompt
    echo "→ Sending review prompt..."
    PROMPT="You are Critic $CRITIC_NAME. Read ASSIGNMENT.md and begin your independent review. This is a blind review - do not look at other critics' work. Follow the convergent coherence framework carefully. Save your review to reviews/episteme-$WORK_ID-review.md and run 'gt done' when complete."

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" C-m

    echo "✅ $CRITIC_NAME spawned (session: $SESSION_NAME)"
    SPAWNED_CRITICS+=("$CRITIC_NAME:$SESSION_NAME")

    # Small delay between spawns
    sleep 2
done

echo ""
echo "════════════════════════════════════════════════"
echo "✅ All Critics Spawned Successfully!"
echo "════════════════════════════════════════════════"
echo ""
echo "⚠️  NEXT STEPS - Accept Bypass Permissions:"
echo ""

for i in "${!SPAWNED_CRITICS[@]}"; do
    critic_info="${SPAWNED_CRITICS[$i]}"
    critic_name="${critic_info%%:*}"
    session_name="${critic_info##*:}"

    echo "Critic $((i+1)): $critic_name"
    echo "  docker compose exec atlantis tmux attach -t $session_name"
    echo "  (Press Down arrow, Enter, Enter to accept)"
    echo "  (Press Ctrl+B then D to detach)"
    echo ""
done

echo "════════════════════════════════════════════════"
echo "📊 Monitoring Commands:"
echo "════════════════════════════════════════════════"
echo ""
echo "View all critic sessions:"
echo "  docker compose exec atlantis tmux ls | grep critic"
echo ""
echo "Check review queue:"
echo "  ./scripts/review-queue.sh list"
echo ""
echo "Monitor specific critic:"
echo "  docker compose exec atlantis tmux attach -t atlantis-critic-<name>"
echo ""
echo "Check critic workspace:"
echo "  docker compose exec atlantis ls -la /atlantis/philosophy/critics/critic-beta/reviews/"
echo ""
echo "════════════════════════════════════════════════"
echo "🔬 Convergence Analysis (when complete):"
echo "════════════════════════════════════════════════"
echo "Compare reviews:"
echo "  docker compose exec atlantis bash -c 'cat /atlantis/philosophy/critics/*/reviews/*.md'"
echo ""
echo "Extract recommendations:"
echo "  docker compose exec atlantis bash -c 'grep -A 2 \"^## Recommendation\" /atlantis/philosophy/critics/*/reviews/*.md'"
echo ""
echo "Extract scores:"
echo "  docker compose exec atlantis bash -c 'grep \"Score:\" /atlantis/philosophy/critics/*/reviews/*.md'"
echo ""
