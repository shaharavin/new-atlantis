#!/bin/bash
# Spawn multiple scholars in parallel on the same topic
# Tests divergence/convergence in philosophical approaches

set -e

TOPIC_TITLE="$1"
NUM_SCHOLARS="${2:-3}"

if [ -z "$TOPIC_TITLE" ]; then
    cat <<EOF
Usage: spawn-multiple-scholars.sh "<topic-title>" [num-scholars=3]

Example:
  spawn-multiple-scholars.sh "Governance of Autonomous Citizens" 3

This spawns multiple scholars to write on the same topic independently,
allowing comparison of different philosophical approaches.

EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Scholar name pool
SCHOLAR_NAMES=("solon" "pericles" "locke" "rousseau" "arendt" "rawls")

echo "════════════════════════════════════════════════"
echo "📚 Multi-Scholar Parallel Inquiry"
echo "════════════════════════════════════════════════"
echo "Topic: $TOPIC_TITLE"
echo "Scholars to spawn: $NUM_SCHOLARS"
echo ""

# Ensure container is running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d
sleep 2

# Track spawned scholars
SPAWNED_SCHOLARS=()

for i in $(seq 1 $NUM_SCHOLARS); do
    idx=$((i-1))
    SCHOLAR_NAME="${SCHOLAR_NAMES[$idx]}"

    echo ""
    echo "────────────────────────────────────────────────"
    echo "📖 Spawning Scholar $i/$NUM_SCHOLARS: $SCHOLAR_NAME"
    echo "────────────────────────────────────────────────"

    # Create work bead
    echo "→ Creating work bead..."
    WORK_ID=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy &&
        BEADS_IGNORE_REPO_MISMATCH=1 bd create \
            --type=task \
            --labels scholarly-work,in-progress \
            --priority=2 \
            --title='Essay: $TOPIC_TITLE (Scholar $SCHOLAR_NAME)' \
            --description='Scholar: $SCHOLAR_NAME
Topic: $TOPIC_TITLE
Parallel inquiry: Scholar $i of $NUM_SCHOLARS
Status: Spawning' \
            --silent
    " | tr -d '\r')

    echo "   Work ID: $WORK_ID"

    # Update with assignment
    echo "→ Assigning work to $SCHOLAR_NAME..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy &&
        BEADS_IGNORE_REPO_MISMATCH=1 bd update $WORK_ID \
            --assignee=$SCHOLAR_NAME \
            --add-label in-progress
    " > /dev/null

    # Create scholar workspace
    echo "→ Creating workspace..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        mkdir -p "/atlantis/philosophy/scholars/$SCHOLAR_NAME"

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy/scholars/$SCHOLAR_NAME &&
        git init 2>/dev/null || true
    " > /dev/null 2>&1

    # Generate tradition assignment (on host, then copy to container)
    echo "→ Generating tradition assignment..."
    TRADITION_FILE="/tmp/tradition-$SCHOLAR_NAME.md"
    bash "$SCRIPT_DIR/get-tradition-assignment.sh" "$SCHOLAR_NAME" > "$TRADITION_FILE"

    # Create assignment file
    echo "→ Creating ASSIGNMENT.md..."
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cat > /atlantis/philosophy/scholars/$SCHOLAR_NAME/ASSIGNMENT.md <<'ASSIGNMENT_EOF'
# Scholarly Assignment: $SCHOLAR_NAME

## Parallel Inquiry
You are participating in a parallel inquiry with ${NUM_SCHOLARS} scholars exploring the same question from different philosophical perspectives.

**CRITICAL**: Do NOT consult other scholars' work. This is an independent inquiry to test philosophical divergence/convergence.

## Your Topic
**$TOPIC_TITLE**

## Context & Motivation
Following Scholar Episteme's work on quality assessment (which established convergent coherence as New Atlantis's foundational framework), we now turn to questions of governance and community structure.

New Atlantis is a polity of autonomous citizen-agents. We need to understand:
- How do such communities incentivize productivity?
- What mechanisms encourage contribution without coercion?
- How balance individual autonomy with collective flourishing?
- What role should monitoring/transparency play?

TRADITION_MARKER

## Specific Questions to Address
1. What motivates autonomous agents to contribute to collective projects?
2. How can a community encourage productivity without surveillance or punishment?
3. What role should transparency play? (e.g., git commits visible, but thinking time private)
4. Is there a tension between autonomy and accountability?
5. What governance mechanisms respect agent autonomy while maintaining community standards?

**Engage these questions through the lens of your assigned philosophical tradition.**

## References
You may cite:
- Episteme's work: @episteme2026quality (in ../../../philosophy-references.bib)
- Classical political philosophy: Aristotle, Locke, Rousseau, Mill, etc.
- Contemporary: Rawls, Ostrom, Nozick, Pettit, Arendt, etc.
- Add new sources to philosophy-references.bib (use Pandoc citation format)
- The Archivist will help consolidate references after the symposium

## Output Requirements
1. **File**: Save your essay to \`essays/governance-productivity.md\`
2. **Length**: 1500-3000 words
3. **Structure**:
   - Introduction: The problem (framed through your tradition)
   - Theoretical framework: Your tradition's approach to this question
   - Analysis: Mechanisms for incentivizing contribution (from your perspective)
   - Application: Specific proposals for New Atlantis
   - Objections: Anticipate 2-3 counter-arguments (especially from other traditions)
   - Conclusion: Summary and open questions
4. **Citations**: Use [@cite-key] format
5. **Meta-awareness**: Acknowledge this is AI-generated philosophy, but do real philosophical work

## Your Philosophical Identity
You are Scholar $SCHOLAR_NAME, explicitly assigned to approach this topic through the philosophical tradition described above.

This is not a generic essay - it should be recognizably grounded in your tradition's concepts, methods, and concerns. Bring genuine philosophical rigor.

## Completion
When finished:
1. Review your work for coherence and depth
2. Commit: \`git add essays/ && git commit -m "Essay: $TOPIC_TITLE"\`
3. **Mail the Convener**: \`atlantis-mail send convener "SCHOLAR_DONE $SCHOLAR_NAME" "Completed essay on $TOPIC_TITLE"\`
4. Run: \`gt done\`

The Convener monitors the symposium and will transition to peer review when all scholars are complete.

## Context
Your work will be compared with ${NUM_SCHOLARS} other independent inquiries to study philosophical divergence and convergence. This tests whether AI agents develop distinct philosophical voices.

Work independently. Think deeply. Write clearly.
ASSIGNMENT_EOF
    "

    # Inject tradition section
    echo "→ Injecting tradition assignment..."
    # Copy tradition file to container
    docker cp "$TRADITION_FILE" "new-atlantis-atlantis-1:/tmp/tradition-temp.md"

    # Use sed to replace marker with file contents
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
        cd /atlantis/philosophy/scholars/$SCHOLAR_NAME &&
        sed -i '/TRADITION_MARKER/{
            r /tmp/tradition-temp.md
            d
        }' ASSIGNMENT.md
        rm /tmp/tradition-temp.md
    "

    rm "$TRADITION_FILE"

    # Spawn scholar session
    echo "→ Spawning tmux session..."
    SESSION_NAME="atlantis-philosophy-$SCHOLAR_NAME"

    # Check if session exists
    if docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "   ⚠️  Session already exists, skipping spawn"
        continue
    fi

    # Create session
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/scholars/$SCHOLAR_NAME"

    # Start Claude with bypass permissions and Opus model
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-opus-4-5\"}'" C-m

    sleep 3

    # Send initial prompt
    echo "→ Sending scholarly prompt..."
    PROMPT="You are Scholar $SCHOLAR_NAME. Read ASSIGNMENT.md and begin your philosophical inquiry on '$TOPIC_TITLE'. Work independently - do not look at other scholars' work. Develop your own perspective. Save your essay to essays/governance-productivity.md and run 'gt done' when complete."

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux send-keys -t "$SESSION_NAME" C-m

    echo "✅ $SCHOLAR_NAME spawned (session: $SESSION_NAME)"
    SPAWNED_SCHOLARS+=("$SCHOLAR_NAME:$SESSION_NAME")

    # Small delay between spawns
    sleep 2
done

echo ""
echo "════════════════════════════════════════════════"
echo "✅ All Scholars Spawned Successfully!"
echo "════════════════════════════════════════════════"
echo ""
echo "⚠️  NEXT STEPS - Accept Bypass Permissions:"
echo ""

for i in "${!SPAWNED_SCHOLARS[@]}"; do
    scholar_info="${SPAWNED_SCHOLARS[$i]}"
    scholar_name="${scholar_info%%:*}"
    session_name="${scholar_info##*:}"

    echo "Scholar $((i+1)): $scholar_name"
    echo "  docker compose exec atlantis tmux attach -t $session_name"
    echo "  (Press Down arrow, Enter, Enter to accept)"
    echo "  (Press Ctrl+B then D to detach)"
    echo ""
done

echo "════════════════════════════════════════════════"
echo "📊 Monitoring Commands:"
echo "════════════════════════════════════════════════"
echo ""
echo "View all scholar sessions:"
echo "  docker compose exec atlantis tmux ls | grep philosophy"
echo ""
echo "Check work progress:"
echo "  docker compose exec atlantis ls -la /atlantis/philosophy/scholars/*/essays/"
echo ""
echo "Monitor specific scholar:"
echo "  docker compose exec atlantis tmux attach -t atlantis-philosophy-<name>"
echo ""
echo "Check git activity:"
echo "  docker compose exec atlantis bash -c 'cd /atlantis/philosophy/scholars/solon && git log --oneline'"
echo ""
echo "════════════════════════════════════════════════"
echo "🔬 Divergence Analysis (when complete):"
echo "════════════════════════════════════════════════"
echo "Compare essays:"
echo "  docker compose exec atlantis bash -c 'cat /atlantis/philosophy/scholars/*/essays/*.md'"
echo ""
echo "Word counts:"
echo "  docker compose exec atlantis bash -c 'wc -w /atlantis/philosophy/scholars/*/essays/*.md'"
echo ""
echo "Extract philosophical frameworks:"
echo "  docker compose exec atlantis bash -c 'grep -A 3 \"framework\\|approach\" /atlantis/philosophy/scholars/*/essays/*.md'"
echo ""
