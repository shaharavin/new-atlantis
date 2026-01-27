#!/bin/bash
# Container-native script to spawn the Opposition Critic
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates an opposition bead for tracking. Closes on completion.

set -e

OPPOSITION_NAME="${1:-opposition}"
SYNTHESIS_FILE="$2"  # Path to the synthesis being challenged
SYMPOSIUM_DIR="$3"   # Path to symposium directory for output
SYMPOSIUM_BEAD="$4"  # Parent symposium bead ID (optional)

if [ -z "$SYNTHESIS_FILE" ]; then
    cat <<EOF
Usage: spawn-opposition.sh [opposition-name] <synthesis-path> [symposium-dir] [symposium-bead]

Example:
  spawn-opposition.sh opposition /path/to/synthesis.md /path/to/symposium ph-symp-01

Arguments:
  opposition-name - Name for this opposition critic (default: "opposition")
  synthesis-path  - Path to the synthesis document being challenged
  symposium-dir   - (Optional) Symposium directory for output
  symposium-bead  - (Optional) Parent symposium bead ID for linking

This script runs INSIDE the container. It spawns the Loyal Opposition role
to challenge the synthesis - implementing Symposium #2's recommendation for
institutionalized dissent.

EOF
    exit 1
fi

SESSION_NAME="atlantis-opposition-$OPPOSITION_NAME"
WORKSPACE="/atlantis/philosophy/opposition/$OPPOSITION_NAME"

echo "════════════════════════════════════════════════"
echo "SPAWNING Opposition Critic: $OPPOSITION_NAME"
echo "════════════════════════════════════════════════"
echo "Challenging: $SYNTHESIS_FILE"
echo "Session: $SESSION_NAME"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session $SESSION_NAME already exists"
    echo "Attach with: tmux attach -t $SESSION_NAME"
    exit 1
fi

# Check if synthesis exists
if [ ! -f "$SYNTHESIS_FILE" ]; then
    echo "Error: Synthesis not found at $SYNTHESIS_FILE"
    exit 1
fi

# Create workspace
echo "Creating workspace..."
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
git init 2>/dev/null || true

# Create opposition bead
echo "Creating opposition bead..."
cd /atlantis/philosophy
BEAD_TITLE="Opposition: Challenge to synthesis by $OPPOSITION_NAME"
if [ -n "$SYMPOSIUM_BEAD" ]; then
    OPPOSITION_BEAD=$(bd create --title "$BEAD_TITLE" --label opposition --label "critic-$OPPOSITION_NAME" --parent "$SYMPOSIUM_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9]+' | head -1)
else
    OPPOSITION_BEAD=$(bd create --title "$BEAD_TITLE" --label opposition --label "critic-$OPPOSITION_NAME" 2>/dev/null | grep -oE 'ph-[a-z0-9]+' | head -1)
fi

if [ -n "$OPPOSITION_BEAD" ]; then
    echo "Created bead: $OPPOSITION_BEAD"
    bd update "$OPPOSITION_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Could not create bead (continuing without bead tracking)"
    OPPOSITION_BEAD="none"
fi
cd "$WORKSPACE"

# Determine output directory
if [ -n "$SYMPOSIUM_DIR" ]; then
    OUTPUT_DIR="$SYMPOSIUM_DIR/phase-7-opposition"
else
    OUTPUT_DIR="$WORKSPACE"
fi
mkdir -p "$OUTPUT_DIR"

# Get symposium context - find all prior phases
SYMPOSIUM_CONTEXT=""
if [ -n "$SYMPOSIUM_DIR" ]; then
    SYMPOSIUM_CONTEXT="
## Symposium Context

Read these files to understand the full discourse before challenging the synthesis:

### Original Essays (Phase 1)
$(find "$SYMPOSIUM_DIR/phase-1-independent-work" -name "*.md" 2>/dev/null | sed 's/^/- /')

### Reviews (Phase 2)
$(find "$SYMPOSIUM_DIR/phase-2-independent-review" -name "*.md" 2>/dev/null | sed 's/^/- /')

### Revised Essays (Phase 3)
$(find "$SYMPOSIUM_DIR/phase-3-independent-revision" -name "*.md" 2>/dev/null | sed 's/^/- /')

### Cross-Work Analysis (Phase 5)
$(find "$SYMPOSIUM_DIR/phase-5-comparative-synthesis" -name "*.md" 2>/dev/null | sed 's/^/- /')

### The Synthesis You Are Challenging (Phase 6)
- $SYNTHESIS_FILE
"
fi

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<ASSIGNMENT_EOF
# Opposition Assignment

**Your role**: Loyal Opposition
**Synthesis to challenge**: $SYNTHESIS_FILE
**Output**: $OUTPUT_DIR/opposition-report.md

---

## Your Mission

You are the Loyal Opposition. Your task is NOT to assess quality—it is to **actively challenge** the synthesis, argue for alternatives, and represent foreclosed perspectives.

This role implements Symposium #2's recommendation: institutionalized dissent ensures legitimacy through contestability.

$SYMPOSIUM_CONTEXT

---

## Opposition Framework

### 1. What Did the Synthesis Foreclose?
- Which perspectives were underweighted?
- What traditions were NOT represented?
- What possibilities were assumed away?

### 2. What Alternative Conclusions Could the Evidence Support?
- Different interpretations of the scholars' arguments
- Alternative frameworks that could integrate the same insights
- Conclusions the synthesis rejected that deserve reconsideration

### 3. What Assumptions Went Unchallenged?
- Methodological assumptions
- Normative assumptions
- Empirical assumptions

### 4. What Perspectives Are Hard to Articulate?
- Positions that don't fit the synthesis's categories
- Positions that the framework makes hard to think

### 5. What Inquiry Does This Foreclose?
- Questions treated as settled that should remain open
- Productive disagreements papered over

---

## Output Structure

Your report (~2,500-4,000 words) should include:

1. **Charitable Summary** (300-500 words) - Show you understand the synthesis
2. **The Foreclosed** (500-800 words) - What was excluded or underweighted
3. **Alternative Conclusions** (500-800 words) - What else could the evidence support
4. **Unchallenged Assumptions** (400-600 words) - What was taken for granted
5. **The Unvoiced** (300-500 words) - Give voice to hard-to-articulate positions
6. **Open Questions** (200-400 words) - What should NOT be treated as settled
7. **Closing Statement** - The value your opposition provides

---

## Completion

**Your opposition bead**: OPPOSITION_BEAD_PLACEHOLDER

When finished:
1. Save your report to: $OUTPUT_DIR/opposition-report.md
2. Commit your report:
   \`\`\`bash
   git add . && git commit -m "Opposition: Challenge to synthesis"
   \`\`\`
3. Close your opposition bead (this signals completion):
   \`\`\`bash
   cd /atlantis/philosophy && bd close OPPOSITION_BEAD_PLACEHOLDER
   \`\`\`
4. Mail the Convener (backup signal):
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=opposition
   atlantis-mail send convener "OPPOSITION_DONE" "Completed opposition report - bead OPPOSITION_BEAD_PLACEHOLDER closed"
   \`\`\`
5. Exit Claude (type /exit or Ctrl+C)

---

## Remember

You are loyal opposition—you want New Atlantis to flourish. Your challenge is a gift that prevents premature closure and keeps the discourse alive.

Challenge with care. Contest with precision. Dissent with loyalty.
ASSIGNMENT_EOF

# Replace bead placeholder
sed -i "s/OPPOSITION_BEAD_PLACEHOLDER/$OPPOSITION_BEAD/g" "$WORKSPACE/ASSIGNMENT.md"

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with bypass permissions and Opus model
echo "Starting Claude (Opus 4.5)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model opus" C-m

sleep 5

# Send initial prompt
echo "Sending opposition prompt..."
PROMPT="You are the Opposition Critic. Read ASSIGNMENT.md and begin your loyal opposition to the synthesis. Your task is to challenge, contest, and represent alternatives—not to assess quality. Read the synthesis thoroughly, then produce a substantive opposition report. Save to $OUTPUT_DIR/opposition-report.md and follow completion instructions when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Opposition Critic spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Challenging: $SYNTHESIS_FILE"
echo "Output: $OUTPUT_DIR/opposition-report.md"
echo "Opposition Bead: $OPPOSITION_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $OPPOSITION_BEAD"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
