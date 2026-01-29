#!/bin/bash
# Container-native script to spawn a single critic
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates a review bead for tracking. Critic closes bead on completion.

set -e

CRITIC_NAME="$1"
WORK_TO_REVIEW="$2"  # Path to the work being reviewed
SYMPOSIUM_DIR="$3"   # Path to symposium directory for output
SYMPOSIUM_BEAD="$4"  # Parent symposium bead ID (optional)

if [ -z "$CRITIC_NAME" ] || [ -z "$WORK_TO_REVIEW" ]; then
    cat <<EOF
Usage: spawn-critic.sh <critic-name> <work-path> [symposium-dir] [symposium-bead]

Example:
  spawn-critic.sh delta /path/to/essay.md /path/to/symposium ph-symp-01

Arguments:
  critic-name    - Name of the critic (e.g., delta, epsilon, zeta)
  work-path      - Path to the essay/work being reviewed
  symposium-dir  - (Optional) Symposium directory for review output
  symposium-bead - (Optional) Parent symposium bead ID for linking

This script runs INSIDE the container. For host-side spawning, use ../spawn-critic.sh

EOF
    exit 1
fi

SESSION_NAME="atlantis-critic-$CRITIC_NAME"
WORKSPACE="/atlantis/philosophy/critics/$CRITIC_NAME"

# Extract work name from path for the review filename
WORK_BASENAME=$(basename "$WORK_TO_REVIEW" .md)

echo "════════════════════════════════════════════════"
echo "🔍 Spawning Critic: $CRITIC_NAME"
echo "════════════════════════════════════════════════"
echo "Reviewing: $WORK_TO_REVIEW"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Check if work exists
if [ ! -f "$WORK_TO_REVIEW" ]; then
    echo "❌ Error: Work not found at $WORK_TO_REVIEW"
    exit 1
fi

# Create workspace
echo "→ Creating workspace..."
mkdir -p "$WORKSPACE/reviews"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Set up skills symlink
mkdir -p "$WORKSPACE/.claude"
ln -sf /atlantis/philosophy/.claude/skills "$WORKSPACE/.claude/skills" 2>/dev/null || true

# Create review bead for this critic
echo "→ Creating review bead..."
cd /atlantis/philosophy
BEAD_TITLE="Review: $WORK_BASENAME by Critic $CRITIC_NAME"
if [ -n "$SYMPOSIUM_BEAD" ]; then
    REVIEW_BEAD=$(bd create --title "$BEAD_TITLE" --label review --label "critic-$CRITIC_NAME" --parent "$SYMPOSIUM_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    REVIEW_BEAD=$(bd create --title "$BEAD_TITLE" --label review --label "critic-$CRITIC_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$REVIEW_BEAD" ]; then
    echo "→ Created bead: $REVIEW_BEAD"
    bd update "$REVIEW_BEAD" --status in_progress 2>/dev/null || true
else
    echo "⚠️  Could not create bead (continuing without bead tracking)"
    REVIEW_BEAD="none"
fi
cd "$WORKSPACE"

# Determine output directory
if [ -n "$SYMPOSIUM_DIR" ]; then
    REVIEW_OUTPUT_DIR="$SYMPOSIUM_DIR/phase-2-independent-review"
else
    REVIEW_OUTPUT_DIR="$WORKSPACE/reviews"
fi
mkdir -p "$REVIEW_OUTPUT_DIR"

# Create assignment
echo "→ Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<ASSIGNMENT_EOF
# Critic Assignment

**Your name**: $CRITIC_NAME
**Work to review**: $WORK_TO_REVIEW

---

## Your Task

Review the assigned work using the convergent coherence framework. Produce a rigorous, substantive critique.

## Review Framework: Convergent Coherence

Apply these four criteria:

### 1. Internal Coherence (Reflective Equilibrium)
- Are claims mutually consistent?
- Do examples support the generalizations?
- Do arguments follow logically from premises?
- Are there internal contradictions?

### 2. Engagement with Discourse (Community Standards)
- Does the work engage existing literature appropriately?
- Are citations accurate and relevant?
- Does it address known objections?
- Does it position itself within ongoing debates?

### 3. Functional Success (Pragmatist Criteria)
- Does the work clarify concepts or resolve puzzles?
- Does it open productive new questions?
- Is it generative - does it enable further inquiry?
- Does it withstand immediate critical scrutiny?

### 4. Explicit Reasoning (AI-Specific Requirement)
- Are steps of reasoning visible, not hidden in black-box associations?
- Does the work explain WHY claims follow, not merely THAT they follow?
- Can a reader follow and evaluate the argumentative chain?

## Review Structure

Your review should include:

1. **Summary** (200-300 words): What is the work arguing?
2. **Strengths** (300-500 words): What does the work do well?
3. **Weaknesses** (300-500 words): Where does it fall short?
4. **Detailed Critique** (500-1000 words): Apply each convergent coherence criterion
5. **Recommendation**: ACCEPT / REVISE / REJECT with justification
6. **Questions for the Author**: 2-3 questions the author should address

## Output

Save your review to: $REVIEW_OUTPUT_DIR/$CRITIC_NAME-review-$WORK_BASENAME.md

## Completion

**Your review bead**: REVIEW_BEAD_PLACEHOLDER

When finished:
1. Review your critique for rigor and fairness
2. Commit your review:
   \`\`\`bash
   git add . && git commit -m "Review: $WORK_BASENAME by $CRITIC_NAME"
   \`\`\`
3. Close your review bead (this signals completion):
   \`\`\`bash
   cd /atlantis/philosophy && bd close REVIEW_BEAD_PLACEHOLDER
   \`\`\`
4. Mail the Convener (backup signal):
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=$CRITIC_NAME
   atlantis-mail send convener "CRITIC_DONE $CRITIC_NAME" "Completed review of $WORK_BASENAME - bead REVIEW_BEAD_PLACEHOLDER closed"
   \`\`\`
5. Exit Claude (type /exit or Ctrl+C)

## Standards

- Be rigorous but fair
- Engage substantively with arguments, not superficially
- Identify genuine weaknesses, not nitpicks
- Acknowledge genuine strengths
- Your review will be compared with other critics' assessments (convergent coherence test)

Work independently. Think critically. Write constructively.
ASSIGNMENT_EOF

# Replace bead placeholder
sed -i "s/REVIEW_BEAD_PLACEHOLDER/$REVIEW_BEAD/g" "$WORKSPACE/ASSIGNMENT.md"

# Create tmux session
echo "→ Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with bypass permissions and Opus model
echo "→ Starting Claude (Opus 4.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m

sleep 5

# Send initial prompt
echo "→ Sending critic prompt..."
PROMPT="You are Critic $CRITIC_NAME. Read ASSIGNMENT.md and begin your review of the assigned work. Apply the convergent coherence framework rigorously. Save your review to the specified location and follow the completion instructions when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "✅ Critic $CRITIC_NAME spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Reviewing: $WORK_TO_REVIEW"
echo "Output: $REVIEW_OUTPUT_DIR/$CRITIC_NAME-review-$WORK_BASENAME.md"
echo "Review Bead: $REVIEW_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $REVIEW_BEAD"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
