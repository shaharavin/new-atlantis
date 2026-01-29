#!/bin/bash
# Container-native script to spawn the Synthesizer
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates a synthesis bead for tracking. Closes on completion.

set -e

SYNTHESIZER_NAME="${1:-omega}"
SYMPOSIUM_DIR="$2"   # Path to symposium directory
SYMPOSIUM_BEAD="$3"  # Parent symposium bead ID (optional)

if [ -z "$SYMPOSIUM_DIR" ]; then
    cat <<EOF
Usage: spawn-synthesizer.sh [name] <symposium-dir> [symposium-bead]

Example:
  spawn-synthesizer.sh omega /atlantis/philosophy/first-works/symposium-governance-2026-01 ph-symp-01

Arguments:
  name           - Name for the synthesizer (default: "omega")
  symposium-dir  - Path to the symposium directory containing phase outputs
  symposium-bead - (Optional) Parent symposium bead ID for linking

This script runs INSIDE the container. The Synthesizer integrates perspectives
from all scholars into a unified framework.

EOF
    exit 1
fi

SESSION_NAME="atlantis-synthesizer-$SYNTHESIZER_NAME"
WORKSPACE="/atlantis/philosophy/synthesizers/$SYNTHESIZER_NAME"

echo "════════════════════════════════════════════════"
echo "Spawning Synthesizer: $SYNTHESIZER_NAME"
echo "════════════════════════════════════════════════"
echo "Symposium: $SYMPOSIUM_DIR"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Check if symposium directory exists
if [ ! -d "$SYMPOSIUM_DIR" ]; then
    echo "Error: Symposium directory not found: $SYMPOSIUM_DIR"
    exit 1
fi

# Create workspace
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create synthesis bead
echo "Creating synthesis bead..."
cd /atlantis/philosophy
BEAD_TITLE="Synthesis: Integrated framework by $SYNTHESIZER_NAME"
if [ -n "$SYMPOSIUM_BEAD" ]; then
    SYNTHESIS_BEAD=$(bd create --title "$BEAD_TITLE" --label synthesis --label "synthesizer-$SYNTHESIZER_NAME" --parent "$SYMPOSIUM_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    SYNTHESIS_BEAD=$(bd create --title "$BEAD_TITLE" --label synthesis --label "synthesizer-$SYNTHESIZER_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$SYNTHESIS_BEAD" ]; then
    echo "Created bead: $SYNTHESIS_BEAD"
    bd update "$SYNTHESIS_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Could not create bead (continuing without bead tracking)"
    SYNTHESIS_BEAD="none"
fi
cd "$WORKSPACE"

# Build context of all symposium phases
OUTPUT_DIR="$SYMPOSIUM_DIR/phase-6-synthesis"
mkdir -p "$OUTPUT_DIR"

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<ASSIGNMENT_EOF
# Synthesizer Assignment

**Your name**: $SYNTHESIZER_NAME
**Symposium**: $SYMPOSIUM_DIR
**Output**: $OUTPUT_DIR/synthesis.md

---

## Your Task

Integrate the perspectives from all scholars into a unified framework that is stronger than any individual essay. This is not a summary — it is a synthesis that creates something new.

## Source Materials

Read ALL of these before writing:

### Original Essays (Phase 1)
$(find "$SYMPOSIUM_DIR/phase-1-independent-work" -name "*.md" 2>/dev/null | sort | sed 's/^/- /')

### Reviews (Phase 2)
$(find "$SYMPOSIUM_DIR/phase-2-independent-review" -name "*.md" 2>/dev/null | sort | sed 's/^/- /')

### Revised Essays (Phase 3)
$(find "$SYMPOSIUM_DIR/phase-3-independent-revision" -name "*.md" 2>/dev/null | sort | sed 's/^/- /')

### Cross-Review (Phase 4)
$(find "$SYMPOSIUM_DIR/phase-4-cross-review" -name "*.md" 2>/dev/null | sort | sed 's/^/- /')

### Cross-Work Review (Phase 5)
$(find "$SYMPOSIUM_DIR/phase-5-cross-work-review" -name "*.md" 2>/dev/null | sort | sed 's/^/- /')

## Synthesis Requirements

Write 3000-5000 words that:

1. **Identify convergence**: Where do the traditions agree? What claims survived critique?
2. **Map divergence**: Where do they genuinely disagree? Why?
3. **Integrate**: Create a framework that incorporates the strongest elements of each tradition
4. **Transcend**: Go beyond what any single scholar argued
5. **Acknowledge limits**: What tensions remain unresolved? What questions stay open?

## Structure

1. **Introduction**: The question and why multiple perspectives matter
2. **Points of Convergence**: What the traditions agree on (and why this is significant)
3. **Points of Divergence**: Where they disagree (and why the disagreement is productive)
4. **Integrated Framework**: Your synthesis — the unified position
5. **Remaining Tensions**: Honest assessment of what can't be resolved
6. **Implications**: What follows from this framework?

## Completion

**Your synthesis bead**: $SYNTHESIS_BEAD

When finished:
1. Save your synthesis to: $OUTPUT_DIR/synthesis.md
2. Commit your work:
   \`\`\`bash
   git add . && git commit -m "Synthesis: Integrated framework"
   \`\`\`
3. Close your bead:
   \`\`\`bash
   cd /atlantis/philosophy && bd close $SYNTHESIS_BEAD
   \`\`\`
4. Mail the Convener:
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=$SYNTHESIZER_NAME
   atlantis-mail send convener "SYNTHESIZER_DONE" "Synthesis complete - bead $SYNTHESIS_BEAD closed"
   \`\`\`
5. Exit Claude

## Remember

You are creating something new — not summarizing what exists. The synthesis should be a philosophical contribution in its own right.
ASSIGNMENT_EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with bypass permissions and Opus model
echo "Starting Claude (Opus 4.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m

sleep 5

# Send initial prompt
echo "Sending synthesizer prompt..."
PROMPT="You are Synthesizer $SYNTHESIZER_NAME. Read ASSIGNMENT.md and begin your synthesis of the symposium. Read all source materials thoroughly before writing. Create an integrated framework that transcends any single perspective. Save to $OUTPUT_DIR/synthesis.md and follow the completion instructions when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Synthesizer $SYNTHESIZER_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Output: $OUTPUT_DIR/synthesis.md"
echo "Synthesis Bead: $SYNTHESIS_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $SYNTHESIS_BEAD"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
