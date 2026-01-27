#!/bin/bash
# Container-native script to spawn a single scholar
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates a work bead for tracking. Scholar closes bead on completion.

set -e

SCHOLAR_NAME="$1"
TOPIC_TITLE="$2"
TRADITION_FILE="$3"  # Path to tradition markdown file (optional)
SYMPOSIUM_BEAD="$4"  # Parent symposium bead ID (optional)

if [ -z "$SCHOLAR_NAME" ] || [ -z "$TOPIC_TITLE" ]; then
    cat <<EOF
Usage: spawn-scholar.sh <scholar-name> <topic-title> [tradition-file] [symposium-bead]

Example:
  spawn-scholar.sh rawls "Constitutional Foundations" /tmp/tradition-rawls.md ph-symp-01

Arguments:
  scholar-name    - Name of the scholar (e.g., rawls, aristotle)
  topic-title     - Topic for the essay
  tradition-file  - (Optional) Path to tradition markdown file
  symposium-bead  - (Optional) Parent symposium bead ID for linking

This script runs INSIDE the container. For host-side spawning, use ../spawn-scholar.sh

EOF
    exit 1
fi

SESSION_NAME="atlantis-philosophy-$SCHOLAR_NAME"
WORKSPACE="/atlantis/philosophy/scholars/$SCHOLAR_NAME"

echo "════════════════════════════════════════════════"
echo "📖 Spawning Scholar: $SCHOLAR_NAME"
echo "════════════════════════════════════════════════"
echo "Topic: $TOPIC_TITLE"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create workspace
echo "→ Creating workspace..."
mkdir -p "$WORKSPACE/essays"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Create work bead for this scholar
echo "→ Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Essay: $TOPIC_TITLE (Scholar $SCHOLAR_NAME)"
if [ -n "$SYMPOSIUM_BEAD" ]; then
    # Link to parent symposium bead (note: child IDs can have dots like ph-abc.1)
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label scholarly-work --label "scholar-$SCHOLAR_NAME" --parent "$SYMPOSIUM_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label scholarly-work --label "scholar-$SCHOLAR_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$WORK_BEAD" ]; then
    echo "→ Created bead: $WORK_BEAD"
    bd update "$WORK_BEAD" --status in_progress 2>/dev/null || true
else
    echo "⚠️  Could not create bead (continuing without bead tracking)"
    WORK_BEAD="none"
fi
cd "$WORKSPACE"

# Create assignment
echo "→ Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<'ASSIGNMENT_EOF'
# Scholar Assignment

**Your name**: SCHOLAR_NAME_PLACEHOLDER
**Topic**: TOPIC_TITLE_PLACEHOLDER

---

## Your Task

Write a philosophical essay (2000-3000 words) on this topic, approaching it through your assigned philosophical tradition.

## Assignment Structure

TRADITION_MARKER

## Essay Requirements

1. **Audience**: New Atlantis community and future scholars
2. **Length**: 2000-3000 words
3. **Structure**:
   - Introduction: The problem (framed through your tradition)
   - Theoretical framework: Your tradition's approach
   - Analysis: Apply framework to the question
   - Application: Specific proposals or insights
   - Objections: Anticipate 2-3 counter-arguments
   - Conclusion: Summary and open questions
4. **Citations**: Use [@cite-key] format
5. **Meta-awareness**: Acknowledge this is AI-generated philosophy, but do real work

## Completion

**Your work bead**: WORK_BEAD_PLACEHOLDER

When finished:
1. Review your work for coherence and depth
2. Commit your essay:
   \`\`\`bash
   git add essays/ && git commit -m "Essay: TOPIC_TITLE_PLACEHOLDER"
   \`\`\`
3. Close your work bead (this signals completion):
   \`\`\`bash
   cd /atlantis/philosophy && bd close WORK_BEAD_PLACEHOLDER
   \`\`\`
4. Mail the Convener (backup signal):
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=SCHOLAR_NAME_PLACEHOLDER
   atlantis-mail send convener "SCHOLAR_DONE SCHOLAR_NAME_PLACEHOLDER" "Completed essay on TOPIC_TITLE_PLACEHOLDER - bead WORK_BEAD_PLACEHOLDER closed"
   \`\`\`
5. Exit Claude (type /exit or Ctrl+C)

The Convener monitors bead status and mail for phase transitions.

## Context

Your work will be compared with other independent inquiries to study philosophical divergence and convergence.

Work independently. Think deeply. Write clearly.
ASSIGNMENT_EOF

# Replace placeholders
sed -i "s/SCHOLAR_NAME_PLACEHOLDER/$SCHOLAR_NAME/g" "$WORKSPACE/ASSIGNMENT.md"
sed -i "s/TOPIC_TITLE_PLACEHOLDER/$TOPIC_TITLE/g" "$WORKSPACE/ASSIGNMENT.md"
sed -i "s/WORK_BEAD_PLACEHOLDER/$WORK_BEAD/g" "$WORKSPACE/ASSIGNMENT.md"

# Inject tradition if provided
if [ -n "$TRADITION_FILE" ] && [ -f "$TRADITION_FILE" ]; then
    echo "→ Injecting tradition assignment..."
    # Use sed to replace TRADITION_MARKER with file contents
    sed -i "/TRADITION_MARKER/{
        r $TRADITION_FILE
        d
    }" "$WORKSPACE/ASSIGNMENT.md"
else
    # Remove marker if no tradition provided
    sed -i "/TRADITION_MARKER/d" "$WORKSPACE/ASSIGNMENT.md"
fi

# Create tmux session
echo "→ Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with bypass permissions and Opus model
echo "→ Starting Claude (Opus 4.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m

sleep 5

# Send initial prompt
echo "→ Sending scholarly prompt..."
PROMPT="You are Scholar $SCHOLAR_NAME. Read ASSIGNMENT.md and begin your philosophical inquiry on '$TOPIC_TITLE'. Work independently - do not look at other scholars' work. Develop your own perspective grounded in your tradition. Save your essay to essays/constitutional-foundations.md and follow the completion instructions when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "✅ Scholar $SCHOLAR_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Work Bead: $WORK_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $WORK_BEAD"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
