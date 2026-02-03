#!/bin/bash
# Container-native script to spawn a specialist critic
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Specialists focus on a specific dimension of quality:
# - clarity: prose quality, accessibility, reader experience
# - rigor: argument soundness, evidence, logical structure
# - novelty: contribution to discourse, originality, integration with literature
#
# Model: Sonnet (efficient for focused critique)

set -e

SPECIALIST_NAME="$1"
SPECIALTY="$2"  # clarity, rigor, novelty, or custom
WORK_TO_REVIEW="$3"  # Path to the draft being reviewed
OUTPUT_DIR="$4"  # Where to save critique
ITERATION="$5"  # Which iteration (1, 2, etc.)
PARENT_BEAD="$6"  # Parent bead ID (optional)

if [ -z "$SPECIALIST_NAME" ] || [ -z "$SPECIALTY" ] || [ -z "$WORK_TO_REVIEW" ] || [ -z "$OUTPUT_DIR" ]; then
    cat <<EOF
Usage: spawn-specialist.sh <name> <specialty> <work-to-review> <output-dir> [iteration] [parent-bead]

Example:
  spawn-specialist.sh clarity-1 clarity /atlantis/philosophy/inquiries/contrib/drafts/draft-1.md /atlantis/philosophy/inquiries/contrib 1 ph-inq-01

Arguments:
  name           - Name of the specialist (e.g., clarity-1, rigor-alpha)
  specialty      - Focus area: clarity, rigor, novelty, or custom description
  work-to-review - Path to the draft being reviewed
  output-dir     - Directory for this inquiry
  iteration      - (Optional) Which iteration of critique (default: 1)
  parent-bead    - (Optional) Parent bead ID for linking

Specialties:
  clarity - Prose quality, accessibility, reader experience
  rigor   - Argument soundness, evidence, logical structure
  novelty - Contribution, originality, integration with discourse

This script runs INSIDE the container.
EOF
    exit 1
fi

ITERATION="${ITERATION:-1}"
SESSION_NAME="atlantis-specialist-$SPECIALIST_NAME"
WORKSPACE="$OUTPUT_DIR/specialists/$SPECIALIST_NAME"
CRITIQUE_OUTPUT="$OUTPUT_DIR/critiques/iteration-$ITERATION/$SPECIALIST_NAME-critique.md"

echo "════════════════════════════════════════════════"
echo "Spawning Specialist: $SPECIALIST_NAME"
echo "════════════════════════════════════════════════"
echo "Specialty: $SPECIALTY"
echo "Reviewing: $WORK_TO_REVIEW"
echo "Iteration: $ITERATION"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Warning: Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Create workspace and critique directory
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
mkdir -p "$(dirname "$CRITIQUE_OUTPUT")"
cd "$WORKSPACE"

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create work bead
echo "Creating work bead..."
cd /atlantis/philosophy
BEAD_TITLE="Specialist Critique: $SPECIALTY iter-$ITERATION ($SPECIALIST_NAME)"
if [ -n "$PARENT_BEAD" ]; then
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label critique --label specialist --label "$SPECIALTY" --parent "$PARENT_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    WORK_BEAD=$(bd create --title "$BEAD_TITLE" --label critique --label specialist --label "$SPECIALTY" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$WORK_BEAD" ]; then
    echo "Created bead: $WORK_BEAD"
    bd update "$WORK_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Warning: Could not create bead (continuing without bead tracking)"
    WORK_BEAD="none"
fi
cd "$WORKSPACE"

# Build specialty-specific instructions
case "$SPECIALTY" in
    clarity)
        SPECIALTY_INSTRUCTIONS="## Your Focus: CLARITY

Assess the work's communicative success:

1. **Accessibility**: Can a thoughtful reader follow the argument?
2. **Structure**: Is the organization logical and clear?
3. **Prose Quality**: Is the writing crisp, precise, economical?
4. **Jargon**: Is technical language necessary and explained?
5. **Signposting**: Does the reader know where they are and where they're going?

Key questions:
- Where did I have to re-read to understand?
- What sentences could be clearer?
- Where does the structure lose the reader?
- What's unnecessarily complex?"
        ;;
    rigor)
        SPECIALTY_INSTRUCTIONS="## Your Focus: RIGOR

Assess the work's argumentative soundness:

1. **Premises**: Are claims explicit and defensible?
2. **Inferences**: Do conclusions follow from premises?
3. **Evidence**: Are claims supported appropriately?
4. **Objections**: Are counter-arguments considered?
5. **Hedging**: Are conclusions appropriately qualified?

Key questions:
- Where are the logical gaps?
- What claims need more support?
- What objections go unaddressed?
- Where is the argument overconfident?"
        ;;
    novelty)
        SPECIALTY_INSTRUCTIONS="## Your Focus: NOVELTY & INTEGRATION

Assess the work's contribution to discourse:

1. **Originality**: What does this add that wasn't there before?
2. **Engagement**: Does it engage relevant prior work?
3. **Positioning**: Where does this sit in existing debates?
4. **Significance**: Does this matter? To whom?
5. **Fertility**: Does this open new questions or directions?

Key questions:
- What's the core novel contribution?
- What prior work should be engaged but isn't?
- Is this genuinely new or repackaged conventional wisdom?
- What inquiry does this enable?"
        ;;
    *)
        SPECIALTY_INSTRUCTIONS="## Your Focus: $SPECIALTY

Apply your specialized lens to assess this dimension of the work.

Be specific about:
- What works well in this dimension
- What needs improvement
- Concrete suggestions for revision"
        ;;
esac

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<EOF
# Specialist Critique Assignment

**Your name**: $SPECIALIST_NAME
**Specialty**: $SPECIALTY
**Iteration**: $ITERATION
**Work bead**: $WORK_BEAD

---

## Your Task

Provide focused critique of the work from your specialist perspective.

## Work to Review

Read: \`$WORK_TO_REVIEW\`

$SPECIALTY_INSTRUCTIONS

## Additional Assessment

Regardless of your specialty, also briefly address:

- **Approach fit**: Did the chosen approach illuminate the question?
- **What's working**: What should be preserved in revision?
- **Priority improvements**: Top 3 changes that would most improve the work

## Output Format

Save your critique to: \`$CRITIQUE_OUTPUT\`

Structure your critique as:

\`\`\`markdown
# $SPECIALTY Critique (Iteration $ITERATION)

**Specialist**: $SPECIALIST_NAME
**Work reviewed**: [filename]

## Summary Assessment
[2-3 sentence overall evaluation from your specialist lens]

## Detailed Analysis
[Your specialty-specific analysis]

## What's Working
[Preserve these elements]

## Priority Improvements
1. [Most important change]
2. [Second priority]
3. [Third priority]

## Specific Suggestions
[Line-level or section-level concrete suggestions]
\`\`\`

## Completion

When finished:

\`\`\`bash
# 1. Close your work bead
cd /atlantis/philosophy && bd close $WORK_BEAD

# 2. Signal completion
export ATLANTIS_AGENT_NAME=$SPECIALIST_NAME
atlantis-mail send convener "SPECIALIST_DONE $SPECIALIST_NAME" "Critique complete: $SPECIALTY iteration $ITERATION"

# 3. Exit
exit
\`\`\`

## Remember

You're one voice in a chorus of specialists. Be thorough in your domain, but don't try to cover everything. Trust that other specialists are handling other dimensions.
EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Sonnet model (efficient for focused critique)
echo "Starting Claude (Sonnet)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model sonnet" C-m

sleep 5

# Send initial prompt
echo "Sending specialist prompt..."
PROMPT="You are Specialist $SPECIALIST_NAME, focusing on $SPECIALTY. Read ASSIGNMENT.md, then review $WORK_TO_REVIEW through your specialist lens. Save your critique to $CRITIQUE_OUTPUT. Be thorough in your domain but focused - other specialists cover other dimensions."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Specialist $SPECIALIST_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Specialty: $SPECIALTY"
echo "Workspace: $WORKSPACE"
echo "Critique Output: $CRITIQUE_OUTPUT"
echo "Work Bead: $WORK_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
