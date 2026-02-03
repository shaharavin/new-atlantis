#!/bin/bash
# Container-native script to spawn a planner for research planning
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Planners develop concrete research plans for selected approaches.
# They specify what sources to engage, what the output looks like, and what success means.
#
# Model: Sonnet (good judgment for planning)

set -e

PLANNER_NAME="$1"
TOPIC="$2"
SELECTED_APPROACH="$3"  # The approach that was randomly selected
INQUIRY_DIR="$4"  # Directory for this inquiry
PARENT_BEAD="$5"  # Parent bead ID (optional)

if [ -z "$PLANNER_NAME" ] || [ -z "$TOPIC" ] || [ -z "$SELECTED_APPROACH" ] || [ -z "$INQUIRY_DIR" ]; then
    cat <<EOF
Usage: spawn-planner.sh <name> <topic> <selected-approach> <inquiry-dir> [parent-bead]

Example:
  spawn-planner.sh planner-1 "What constitutes genuine contribution?" "genealogical" /atlantis/philosophy/inquiries/contribution-2026-02 ph-inq-01

Arguments:
  name              - Name of the planner (e.g., planner-1, planner-alpha)
  topic             - The question/topic being investigated
  selected-approach - The approach that was randomly selected
  inquiry-dir       - Directory for this inquiry
  parent-bead       - (Optional) Parent bead ID for linking

This script runs INSIDE the container.
EOF
    exit 1
fi

SESSION_NAME="atlantis-planner-$PLANNER_NAME"
WORKSPACE="$INQUIRY_DIR/planners/$PLANNER_NAME"
# Sanitize approach name for filename (lowercase, hyphens instead of spaces)
APPROACH_SLUG=$(echo "$SELECTED_APPROACH" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
PLAN_OUTPUT="$INQUIRY_DIR/approach-selection/research-plan-$APPROACH_SLUG.md"

echo "════════════════════════════════════════════════"
echo "Spawning Planner: $PLANNER_NAME"
echo "════════════════════════════════════════════════"
echo "Topic: $TOPIC"
echo "Approach: $SELECTED_APPROACH"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Warning: Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create workspace
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
mkdir -p "$INQUIRY_DIR/approach-selection"
cd "$WORKSPACE"

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create work bead
echo "Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Research Plan: $SELECTED_APPROACH ($PLANNER_NAME)"
if [ -n "$PARENT_BEAD" ]; then
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label planning --label "planner-$PLANNER_NAME" --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label planning --label "planner-$PLANNER_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
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
# Planner Assignment

**Your name**: $PLANNER_NAME
**Topic**: $TOPIC
**Selected Approach**: $SELECTED_APPROACH
**Work bead**: $WORK_BEAD

---

## Your Task

Develop a concrete research plan for investigating "$TOPIC" using the **$SELECTED_APPROACH** approach.

## Available Resources

Check these directories for context:
- \`$INQUIRY_DIR/research-corpus/\` - Grounding research (primary/secondary sources)
- \`/atlantis/philosophy/docs/INQUIRY-APPROACHES.md\` - Approach descriptions

## Research Plan Requirements

Your plan should specify:

### 1. Approach Interpretation
- How does the "$SELECTED_APPROACH" approach apply to this specific question?
- What does this approach uniquely illuminate?

### 2. Sources to Engage
- Which sources from the research corpus are most relevant?
- What additional sources (if any) should the scholar consult?

### 3. Output Specification
- What format should the final output take?
- What sections or structure?
- Target length (words or pages)?

### 4. Success Criteria
- How will we know if this inquiry succeeded?
- What would a "good" result look like?
- What would a "transformative" result look like?

### 5. Potential Pitfalls
- What are the risks with this approach for this question?
- What should the scholar watch out for?

### 6. Scope Guidance
- What's in scope vs. out of scope?
- How should the scholar manage breadth vs. depth?

## Output

Save your plan to: \`$PLAN_OUTPUT\`

Use clear markdown structure. This plan will guide an Opus scholar's execution.

## Completion

When finished:

\`\`\`bash
# 1. Close your work bead
cd /atlantis/philosophy && bd close $WORK_BEAD

# 2. Signal completion
export ATLANTIS_AGENT_NAME=$PLANNER_NAME
atlantis-mail send convener "PLANNER_DONE $PLANNER_NAME" "Research plan complete for $SELECTED_APPROACH approach"

# 3. Exit
exit
\`\`\`

## Remember

You're translating an abstract approach into concrete guidance. Be specific enough to be useful, flexible enough to allow creative execution.
EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Sonnet model (good for planning)
echo "Starting Claude (Sonnet)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model sonnet" C-m

sleep 5

# Send initial prompt
echo "Sending planner prompt..."
PROMPT="You are Planner $PLANNER_NAME. Read ASSIGNMENT.md, review the research corpus at $INQUIRY_DIR/research-corpus/ if available, and develop a concrete research plan for investigating '$TOPIC' using the '$SELECTED_APPROACH' approach. Save your plan to $PLAN_OUTPUT."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Planner $PLANNER_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Plan Output: $PLAN_OUTPUT"
echo "Work Bead: $WORK_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
