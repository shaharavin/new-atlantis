#!/bin/bash
# Container-native script to spawn a copyeditor agent
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates a copyedit bead for tracking. Copyeditor closes bead on completion.

set -e

WORK_DIR="$1"       # Path to the public-essay work directory
PARENT_BEAD="$2"    # Parent bead ID (optional)

if [ -z "$WORK_DIR" ]; then
    cat <<EOF
Usage: spawn-copyeditor.sh <work-dir> [parent-bead]

Example:
  spawn-copyeditor.sh /atlantis/philosophy/first-works/symposium-excellence-2026-01/public-essay ph-essay-01

Arguments:
  work-dir     - Path to the public-essay directory containing public-essay-revised.md
  parent-bead  - (Optional) Parent bead ID for linking

This script runs INSIDE the container.
EOF
    exit 1
fi

SESSION_NAME="atlantis-copyeditor"
WORKSPACE="$WORK_DIR/copyeditor-workspace"

echo "════════════════════════════════════════════════"
echo "Spawning Copyeditor"
echo "════════════════════════════════════════════════"
echo "Work dir: $WORK_DIR"
echo "Session:  $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Check if revised essay exists
if [ ! -f "$WORK_DIR/public-essay-revised.md" ]; then
    echo "Error: Revised essay not found at $WORK_DIR/public-essay-revised.md"
    exit 1
fi

# Create workspace
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Create copyedit bead
echo "Creating copyedit bead..."
cd /atlantis/philosophy
BEAD_TITLE="Copyedit: Public Essay Polish"
if [ -n "$PARENT_BEAD" ]; then
    COPYEDIT_BEAD=$(bd create --title "$BEAD_TITLE" --label copyedit --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    COPYEDIT_BEAD=$(bd create --title "$BEAD_TITLE" --label copyedit 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$COPYEDIT_BEAD" ]; then
    echo "Created bead: $COPYEDIT_BEAD"
    bd update "$COPYEDIT_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Could not create bead (continuing without bead tracking)"
    COPYEDIT_BEAD="none"
fi
cd "$WORKSPACE"

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<ASSIGNMENT_EOF
# Copyeditor Assignment

**Your bead**: $COPYEDIT_BEAD

---

## Your Task

Polish the revised public essay for publication. You are the final step before this essay
goes public.

## Input

Read the revised essay:
\`\`\`bash
cat $WORK_DIR/public-essay-revised.md
\`\`\`

You may also want to check the original draft and review for context:
- Draft: $WORK_DIR/public-essay-draft.md
- Review: $WORK_DIR/review.md

## Copyediting Checklist

### 1. Prose Refinement
- Improve flow and rhythm
- Sharpen word choices (remove vague language)
- Vary sentence structure
- Cut unnecessary words

### 2. Structure
- Ensure headers are compelling (not generic)
- Check paragraph transitions
- Verify the opening hooks the reader
- Confirm the conclusion lands

### 3. Consistency
- Terminology used consistently throughout
- Formatting matches throughout
- Tone consistent (accessible but intellectually serious)

### 4. Links and References
- Add hyperlinks to relevant sources if appropriate
- Ensure any citations are formatted consistently

### 5. Final Proofread
- Grammar and punctuation
- Spelling
- Typos

## Output

Save your polished essay to: $WORK_DIR/public-essay-final.md

This should be publication-ready. A human should be able to publish this essay directly.

## Completion

When finished:
1. Review your work one final time
2. Save the final essay
3. Commit your work:
   \`\`\`bash
   git add . && git commit -m "Copyedit: Final polish of public essay"
   \`\`\`
4. Close your bead:
   \`\`\`bash
   cd /atlantis/philosophy && bd close $COPYEDIT_BEAD
   \`\`\`
5. Mail the Convener:
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=copyeditor
   atlantis-mail send convener "COPYEDIT_DONE" "Public essay polished and saved to $WORK_DIR/public-essay-final.md - bead $COPYEDIT_BEAD closed"
   \`\`\`
6. Exit Claude

## Standards

- Be precise but not precious
- Preserve the author's voice while improving clarity
- Focus on readability for general audiences
- The essay should be enjoyable to read
ASSIGNMENT_EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with bypass permissions and Haiku model (cost-efficient for copyediting)
echo "Starting Claude (Haiku 3.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model haiku" C-m

sleep 5

# Send initial prompt
echo "Sending copyeditor prompt..."
PROMPT="You are a copyeditor. Read ASSIGNMENT.md and polish the revised public essay for publication. Focus on prose quality, consistency, and readability. Save the final version to $WORK_DIR/public-essay-final.md and close your bead when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Copyeditor spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Input: $WORK_DIR/public-essay-revised.md"
echo "Output: $WORK_DIR/public-essay-final.md"
echo "Bead: $COPYEDIT_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
