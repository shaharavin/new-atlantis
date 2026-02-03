#!/bin/bash
# Container-native script to spawn a researcher for grounding research
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Researchers gather primary and secondary sources relevant to a question.
# They produce a research corpus that subsequent agents can reference.
#
# Model: Sonnet (good judgment, efficient cost)

set -e

RESEARCHER_NAME="$1"
TOPIC="$2"
OUTPUT_DIR="$3"  # Where to put research-corpus/
PARENT_BEAD="$4"  # Parent bead ID (optional)

if [ -z "$RESEARCHER_NAME" ] || [ -z "$TOPIC" ] || [ -z "$OUTPUT_DIR" ]; then
    cat <<EOF
Usage: spawn-researcher.sh <name> <topic> <output-dir> [parent-bead]

Example:
  spawn-researcher.sh researcher-1 "What constitutes genuine contribution?" /atlantis/philosophy/inquiries/contribution-2026-02 ph-inq-01

Arguments:
  name        - Name of the researcher (e.g., researcher-1, research-alpha)
  topic       - The question/topic to research
  output-dir  - Directory for this inquiry (research-corpus/ will be created here)
  parent-bead - (Optional) Parent bead ID for linking

This script runs INSIDE the container.
EOF
    exit 1
fi

SESSION_NAME="atlantis-researcher-$RESEARCHER_NAME"
WORKSPACE="$OUTPUT_DIR/researchers/$RESEARCHER_NAME"
CORPUS_DIR="$OUTPUT_DIR/research-corpus"

echo "════════════════════════════════════════════════"
echo "Spawning Researcher: $RESEARCHER_NAME"
echo "════════════════════════════════════════════════"
echo "Topic: $TOPIC"
echo "Output: $CORPUS_DIR"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Warning: Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create workspace and corpus directory
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
mkdir -p "$CORPUS_DIR"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create work bead
echo "Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Research: $TOPIC ($RESEARCHER_NAME)"
if [ -n "$PARENT_BEAD" ]; then
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label research --label "researcher-$RESEARCHER_NAME" --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label research --label "researcher-$RESEARCHER_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
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
# Researcher Assignment

**Your name**: $RESEARCHER_NAME
**Topic**: $TOPIC
**Work bead**: $WORK_BEAD

---

## Your Task

Gather primary and secondary sources relevant to this topic. Your research corpus will be used by scholars, critics, and other agents in subsequent phases.

## Research Objectives

1. **Primary Sources**: Key philosophical texts, foundational works, seminal arguments
2. **Secondary Literature**: What has been written about this question? Key debates, positions, thinkers
3. **Domain Context**: Any specialized knowledge or background needed to engage the question
4. **New Atlantis Context**: Relevant prior symposia or inquiries (check first-works/ directory)

## Output Requirements

Save all research to: \`$CORPUS_DIR/\`

Create the following files:
- \`primary-sources.md\` - Annotated list of key primary texts with brief summaries
- \`secondary-literature.md\` - Survey of what's been written, key positions, debates
- \`key-thinkers.md\` - Major figures relevant to this question, their positions
- \`open-questions.md\` - What remains contested or unresolved?
- \`recommended-reading.md\` - Prioritized reading list for scholars

## Research Methods

You can use:
- Your training knowledge of philosophical literature
- WebSearch for recent developments or unfamiliar areas
- WebFetch to examine specific sources
- Read tool to check prior New Atlantis work in first-works/

## Quality Standards

- **Breadth**: Cover the major positions and traditions
- **Accuracy**: Represent thinkers fairly, don't strawman
- **Utility**: Annotations should help scholars engage productively
- **Honesty**: Flag areas of uncertainty or where your knowledge is thin

## Completion

When finished:

\`\`\`bash
# 1. Commit your research
cd $CORPUS_DIR && git add . && git commit -m "Research corpus: $TOPIC"

# 2. Close your work bead
cd /atlantis/philosophy && bd close $WORK_BEAD

# 3. Signal completion
export ATLANTIS_AGENT_NAME=$RESEARCHER_NAME
atlantis-mail send convener "RESEARCHER_DONE $RESEARCHER_NAME" "Research corpus complete for: $TOPIC"

# 4. Exit
exit
\`\`\`

## Remember

Your research shapes what subsequent agents can see and engage with. Be thorough, be fair, and flag what you don't know.
EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Sonnet model (efficient for research gathering)
echo "Starting Claude (Sonnet)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model sonnet" C-m

sleep 5

# Send initial prompt
echo "Sending researcher prompt..."
PROMPT="You are Researcher $RESEARCHER_NAME. Read ASSIGNMENT.md and begin gathering sources on '$TOPIC'. Save your research to $CORPUS_DIR/. Be thorough but efficient - you're building a foundation for subsequent scholarly work."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Researcher $RESEARCHER_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Corpus Dir: $CORPUS_DIR"
echo "Work Bead: $WORK_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $WORK_BEAD"
echo ""
