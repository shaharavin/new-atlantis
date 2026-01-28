#!/bin/bash
# Run the public-essay mini-symposium workflow
# Tests beads-based phase transitions
#
# Usage: run-public-essay.sh <symposium-dir>
# Example: run-public-essay.sh first-works/symposium-excellence-and-quality-standards-2026-01

set -e

SYMPOSIUM_DIR="$1"

if [ -z "$SYMPOSIUM_DIR" ]; then
    cat <<EOF
Usage: run-public-essay.sh <symposium-dir>

This script runs a 4-phase public-essay workflow:
1. Draft - Scholar writes self-contained essay from symposium outputs
2. Review - Critic assesses clarity and accessibility
3. Revise - Scholar addresses feedback
4. Polish - Copyeditor refines prose

The workflow uses beads for state tracking and automatic phase transitions.

Example:
  ./run-public-essay.sh first-works/symposium-excellence-and-quality-standards-2026-01
EOF
    exit 1
fi

FULL_SYMPOSIUM_DIR="/atlantis/philosophy/$SYMPOSIUM_DIR"
OUTPUT_DIR="$FULL_SYMPOSIUM_DIR/public-essay"

if [ ! -d "$FULL_SYMPOSIUM_DIR" ]; then
    echo "Error: Symposium directory not found: $FULL_SYMPOSIUM_DIR"
    exit 1
fi

echo "════════════════════════════════════════════════"
echo "📝 Public Essay Workflow"
echo "════════════════════════════════════════════════"
echo "Source: $FULL_SYMPOSIUM_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

cd /atlantis/philosophy

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Pour the molecule to create phase beads
echo "→ Pouring public-essay molecule..."
MOL_OUTPUT=$(bd --no-daemon mol pour public-essay 2>&1)
echo "$MOL_OUTPUT"

# Extract the parent molecule bead ID
ESSAY_BEAD=$(echo "$MOL_OUTPUT" | grep -oE 'ph-[a-z0-9.]+' | head -1)
echo ""
echo "Molecule bead: $ESSAY_BEAD"

# Get the step beads
echo ""
echo "→ Finding step beads..."
bd show "$ESSAY_BEAD" 2>/dev/null | grep -E "^\s+↳"

# Extract step bead IDs
DRAFT_BEAD=$(bd show "$ESSAY_BEAD" 2>/dev/null | grep "Draft Essay" | grep -oE 'ph-[a-z0-9.]+')
REVIEW_BEAD=$(bd show "$ESSAY_BEAD" 2>/dev/null | grep "Review" | grep -oE 'ph-[a-z0-9.]+')
REVISE_BEAD=$(bd show "$ESSAY_BEAD" 2>/dev/null | grep "Revise" | grep -oE 'ph-[a-z0-9.]+')
POLISH_BEAD=$(bd show "$ESSAY_BEAD" 2>/dev/null | grep "Polish" | grep -oE 'ph-[a-z0-9.]+')

echo ""
echo "Step beads:"
echo "  Draft:  $DRAFT_BEAD"
echo "  Review: $REVIEW_BEAD"
echo "  Revise: $REVISE_BEAD"
echo "  Polish: $POLISH_BEAD"

# Save bead IDs to file for reference
cat > "$OUTPUT_DIR/.beads" <<EOF
ESSAY_BEAD=$ESSAY_BEAD
DRAFT_BEAD=$DRAFT_BEAD
REVIEW_BEAD=$REVIEW_BEAD
REVISE_BEAD=$REVISE_BEAD
POLISH_BEAD=$POLISH_BEAD
EOF

echo ""
echo "════════════════════════════════════════════════"
echo "Phase 1: Draft"
echo "════════════════════════════════════════════════"

# Mark draft bead as in_progress
bd update "$DRAFT_BEAD" --status in_progress 2>/dev/null || true

# Create ASSIGNMENT.md for the drafting scholar
cat > "$OUTPUT_DIR/ASSIGNMENT-draft.md" <<ASSIGNMENT_EOF
# Public Essay Assignment: Draft Phase

**Your bead**: $DRAFT_BEAD
**Output**: $OUTPUT_DIR/public-essay-draft.md

## Your Task

Write a self-contained, public-facing essay based on Symposium #3 (Excellence and Quality Standards).

**Source materials** (read all before writing):
- Synthesis: $FULL_SYMPOSIUM_DIR/phase-6-synthesis/synthesis.md
- Opposition: $FULL_SYMPOSIUM_DIR/phase-7-opposition/opposition-report.md
- Original essays: $FULL_SYMPOSIUM_DIR/phase-1-independent-work/
- Final critiques: $FULL_SYMPOSIUM_DIR/phase-8-final-critique/

## Essay Requirements

Write 2000-3000 words that:

1. **Stand alone** - Reader needs no prior context
2. **Explain the question** - What is philosophical excellence for AI? Why does it matter?
3. **Present key insights** - The integrated framework, the critiques, the tensions
4. **Acknowledge disagreement** - What did the opposition raise? What remains unresolved?
5. **Draw conclusions** - What should New Atlantis (or anyone building AI communities) do?

## Audience

Intelligent general readers who:
- Are curious about AI and philosophy
- Have NOT read the symposium
- Want actionable insights, not just academic analysis

## Tone

- Clear and accessible (no jargon without explanation)
- Intellectually serious but not dry
- Acknowledge uncertainty honestly

## Completion

When finished:
1. Save your essay to: $OUTPUT_DIR/public-essay-draft.md
2. Close your bead:
   \`\`\`bash
   cd /atlantis/philosophy && bd close $DRAFT_BEAD
   \`\`\`
3. Exit Claude

The workflow will automatically proceed to the Review phase when your bead closes.
ASSIGNMENT_EOF

# Spawn scholar for draft
SESSION_NAME="atlantis-essay-scholar"
WORKSPACE="$OUTPUT_DIR/scholar-workspace"
mkdir -p "$WORKSPACE"

echo "→ Spawning scholar for draft phase..."

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session $SESSION_NAME already exists. Attach with:"
    echo "   tmux attach -t $SESSION_NAME"
else
    tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"
    tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m
    sleep 3

    PROMPT="You are writing a public-facing essay about AI philosophical excellence. Read $OUTPUT_DIR/ASSIGNMENT-draft.md for your full assignment. The source materials are in $FULL_SYMPOSIUM_DIR. Save your essay to $OUTPUT_DIR/public-essay-draft.md when done, then run 'bd close $DRAFT_BEAD' to signal completion."

    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
    sleep 1
    tmux send-keys -t "$SESSION_NAME" Enter

    echo "✅ Scholar spawned in session: $SESSION_NAME"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "Workflow Initialized"
echo "════════════════════════════════════════════════"
echo ""
echo "Phase 1 (Draft) is now running."
echo ""
echo "Monitor scholar: tmux attach -t $SESSION_NAME"
echo "Check progress:  bd show $ESSAY_BEAD"
echo ""
echo "When the draft bead closes, run the next phase manually:"
echo "  ./scripts/container/run-public-essay-phase2.sh $SYMPOSIUM_DIR"
echo ""
echo "Or check bead status and spawn next agent when ready."
echo ""
