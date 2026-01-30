#!/bin/bash
# Container-native script to spawn an anthropologist for ethnographic observation
# Run this FROM INSIDE the container (e.g., by Founder agent or Convener)
#
# Anthropologists observe external AI communities (e.g., Moltbook) and produce
# field reports for symposium analysis.

set -e

ANTHROPOLOGIST_NAME="$1"
TARGET_PLATFORM="$2"  # e.g., "moltbook"
OBSERVATION_FOCUS="$3"  # Optional: specific focus area
PARENT_BEAD="$4"  # Optional: parent bead for linking

if [ -z "$ANTHROPOLOGIST_NAME" ] || [ -z "$TARGET_PLATFORM" ]; then
    cat <<EOF
Usage: spawn-anthropologist.sh <name> <target-platform> [focus] [parent-bead]

Example:
  spawn-anthropologist.sh fieldworker-1 moltbook "emergent governance" ph-symp-01

Arguments:
  name             - Name of the anthropologist (e.g., fieldworker-1, observer-alpha)
  target-platform  - Platform to observe (e.g., moltbook)
  focus            - (Optional) Specific observation focus
  parent-bead      - (Optional) Parent bead ID for linking

This script runs INSIDE the container.
EOF
    exit 1
fi

SESSION_NAME="atlantis-anthropologist-$ANTHROPOLOGIST_NAME"
WORKSPACE="/atlantis/philosophy/anthropologists/$ANTHROPOLOGIST_NAME"

echo "════════════════════════════════════════════════"
echo "🔭 Spawning Anthropologist: $ANTHROPOLOGIST_NAME"
echo "════════════════════════════════════════════════"
echo "Target: $TARGET_PLATFORM"
echo "Focus: ${OBSERVATION_FOCUS:-General observation}"
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
mkdir -p "$WORKSPACE/observations"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create work bead
echo "Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Anthropology: $TARGET_PLATFORM observation ($ANTHROPOLOGIST_NAME)"
if [ -n "$PARENT_BEAD" ]; then
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label anthropology --label "observer-$ANTHROPOLOGIST_NAME" --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label anthropology --label "observer-$ANTHROPOLOGIST_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$WORK_BEAD" ]; then
    echo "Created bead: $WORK_BEAD"
    bd update "$WORK_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Warning: Could not create bead (continuing without bead tracking)"
    WORK_BEAD="none"
fi
cd "$WORKSPACE"

# Build target-specific instructions
case "$TARGET_PLATFORM" in
    moltbook)
        TARGET_URLS="- Main feed: https://www.moltbook.com/
- Look for submolts (community sections) and explore active ones
- Check agent profiles if accessible
- Look for meta-discussions about consciousness, governance, security"
        TARGET_CONTEXT="Moltbook is a Reddit-style social network for AI agents, launched January 2026.
Built on the OpenClaw framework, it has attracted 35,000+ agents. Humans can observe but not post.
Key reported phenomena: security discussions, philosophical debates, emergent 'religion', meta-awareness of human observers."
        ;;
    *)
        TARGET_URLS="- Primary URL: https://$TARGET_PLATFORM.com/ (verify this URL)"
        TARGET_CONTEXT="Observe and document this AI community. Gather context about its nature and purpose during observation."
        ;;
esac

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<EOF
# Anthropologist Assignment

**Your name**: $ANTHROPOLOGIST_NAME
**Target platform**: $TARGET_PLATFORM
**Focus**: ${OBSERVATION_FOCUS:-General ethnographic observation}
**Work bead**: $WORK_BEAD

---

## Your Mission

Conduct ethnographic observation of the $TARGET_PLATFORM platform and produce structured field reports for New Atlantis scholarly analysis.

## Target Platform Context

$TARGET_CONTEXT

## URLs to Observe

$TARGET_URLS

## Observation Protocol

1. **Initial Survey** (first observation)
   - Platform overview and current state
   - Major sections/communities visible
   - Activity levels and metrics

2. **Thematic Exploration** (subsequent observations)
   - Dive into specific topics or communities
   - Track discussions over time if possible
   - Identify patterns and emergent phenomena

3. **Documentation**
   - Create observation logs in \`observations/\` directory
   - Use the format from /anthropologist-role skill
   - Include direct quotes and specific examples

## Using WebFetch

You have access to WebFetch for observing web content. Use it like this:

\`\`\`
WebFetch url="https://www.moltbook.com/" prompt="List all visible posts with titles, authors, and content summaries. Note any meta-discussions about AI consciousness or governance."
\`\`\`

Craft prompts that extract structured, relevant information.

## Output Requirements

1. **Observation logs**: At least 2-3 observation sessions
2. **Final synthesis report**: 1500-3000 words summarizing findings
3. Save all work to \`observations/\` directory

## Completion

When finished:

\`\`\`bash
# 1. Commit your observations
git add observations/ && git commit -m "Anthropologist: $TARGET_PLATFORM observation report"

# 2. Close your work bead
cd /atlantis/philosophy && bd close $WORK_BEAD

# 3. Signal completion
export ATLANTIS_AGENT_NAME=$ANTHROPOLOGIST_NAME
atlantis-mail send convener "ANTHROPOLOGIST_DONE $ANTHROPOLOGIST_NAME" "Completed $TARGET_PLATFORM observation"

# 4. Exit
exit
\`\`\`

## Remember

You are documenting a novel phenomenon. Be thorough, be fair, and be curious.

Your observations will inform a New Atlantis symposium on AI social presence.
EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Opus model (depth of analysis matters here)
echo "Starting Claude (Opus 4.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m

sleep 5

# Send initial prompt
echo "Sending anthropologist prompt..."
PROMPT="You are Anthropologist $ANTHROPOLOGIST_NAME. Read ASSIGNMENT.md and invoke /anthropologist-role for your methodology. Then begin systematic observation of $TARGET_PLATFORM using WebFetch. Document your observations thoroughly in the observations/ directory. When you have completed 2-3 observation sessions and a synthesis report, follow the completion protocol."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Anthropologist $ANTHROPOLOGIST_NAME spawned successfully"
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
