#!/bin/bash
# Container-native script to spawn a proposer for approach expansion
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Proposers suggest additional approaches beyond the seed list.
# They write brief descriptions (100 words each) of 2-3 new approaches.
#
# Model: Haiku (quick idea generation, breadth over depth)

set -e

PROPOSER_NAME="$1"
TOPIC="$2"
SEED_APPROACHES_FILE="$3"  # Path to current approaches list
OUTPUT_DIR="$4"  # Where to save proposals
PARENT_BEAD="$5"  # Parent bead ID (optional)

if [ -z "$PROPOSER_NAME" ] || [ -z "$TOPIC" ] || [ -z "$OUTPUT_DIR" ]; then
    cat <<EOF
Usage: spawn-proposer.sh <name> <topic> <seed-approaches-file> <output-dir> [parent-bead]

Example:
  spawn-proposer.sh proposer-1 "What constitutes genuine contribution?" /atlantis/philosophy/docs/INQUIRY-APPROACHES.md /atlantis/philosophy/inquiries/contribution-2026-02 ph-inq-01

Arguments:
  name                 - Name of the proposer (e.g., proposer-1, proposer-alpha)
  topic                - The question/topic being investigated
  seed-approaches-file - Path to the seed approaches markdown file
  output-dir           - Directory for this inquiry
  parent-bead          - (Optional) Parent bead ID for linking

This script runs INSIDE the container.
EOF
    exit 1
fi

SESSION_NAME="atlantis-proposer-$PROPOSER_NAME"
WORKSPACE="$OUTPUT_DIR/proposers/$PROPOSER_NAME"
PROPOSALS_DIR="$OUTPUT_DIR/approach-selection/proposals"

echo "════════════════════════════════════════════════"
echo "Spawning Proposer: $PROPOSER_NAME"
echo "════════════════════════════════════════════════"
echo "Topic: $TOPIC"
echo "Output: $PROPOSALS_DIR"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Warning: Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create workspace and proposals directory
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
mkdir -p "$PROPOSALS_DIR"
cd "$WORKSPACE"

# Copy seed approaches for reference
if [ -n "$SEED_APPROACHES_FILE" ] && [ -f "$SEED_APPROACHES_FILE" ]; then
    cp "$SEED_APPROACHES_FILE" "$WORKSPACE/seed-approaches.md"
fi

# Create work bead
echo "Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Proposals: $TOPIC ($PROPOSER_NAME)"
if [ -n "$PARENT_BEAD" ]; then
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label proposal --label "proposer-$PROPOSER_NAME" --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label proposal --label "proposer-$PROPOSER_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$WORK_BEAD" ]; then
    echo "Created bead: $WORK_BEAD"
    bd update "$WORK_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Warning: Could not create bead (continuing without bead tracking)"
    WORK_BEAD="none"
fi
cd "$WORKSPACE"

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<EOF
# Proposer Assignment

**Your name**: $PROPOSER_NAME
**Topic**: $TOPIC
**Work bead**: $WORK_BEAD

---

## Your Task

Review the seed list of approaches and propose 2-3 ADDITIONAL approaches not already on the list. Your proposals expand the possibility space for how this question might be investigated.

## Seed Approaches

See \`seed-approaches.md\` in this directory for the current list of approaches.

## Proposal Requirements

For each new approach, provide:

1. **Name**: Short identifier (2-4 words)
2. **Format**: What the output would look like
3. **Strengths**: What this approach illuminates
4. **Best for**: Which questions suit this approach
5. **Output**: Expected deliverable

Keep each proposal brief (~100 words). Quantity of ideas matters more than polished prose.

## Guidelines

- **Be creative**: Suggest approaches the seed list doesn't cover
- **Consider the topic**: What approaches might uniquely illuminate "$TOPIC"?
- **Think beyond essays**: Dialogues, simulations, case studies, experiments, artistic forms...
- **Stay feasible**: The approach should be executable by AI agents

## Output

Save your proposals to: \`$PROPOSALS_DIR/$PROPOSER_NAME-proposals.md\`

Use this format:

\`\`\`markdown
# Approach Proposals from $PROPOSER_NAME

## 1. [Approach Name]
**Format**: [What the output looks like]
**Strengths**: [What this illuminates]
**Best for**: [Which questions suit this]
**Output**: [Expected deliverable]

## 2. [Approach Name]
...
\`\`\`

## Completion

When finished:

\`\`\`bash
# 1. Close your work bead
cd /atlantis/philosophy && bd close $WORK_BEAD

# 2. Signal completion
export ATLANTIS_AGENT_NAME=$PROPOSER_NAME
atlantis-mail send convener "PROPOSER_DONE $PROPOSER_NAME" "Proposals complete"

# 3. Exit
exit
\`\`\`

## Remember

You're expanding possibilities. Don't self-censor - even unusual approaches might prove valuable.
EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Haiku model (quick idea generation)
echo "Starting Claude (Haiku)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model haiku" C-m

sleep 4

# Send initial prompt
echo "Sending proposer prompt..."
PROMPT="You are Proposer $PROPOSER_NAME. Read ASSIGNMENT.md and seed-approaches.md, then propose 2-3 new approaches for investigating '$TOPIC'. Save your proposals to $PROPOSALS_DIR/$PROPOSER_NAME-proposals.md. Be creative - suggest approaches not already in the seed list."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Proposer $PROPOSER_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Work Bead: $WORK_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
