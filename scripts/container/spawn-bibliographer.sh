#!/bin/bash
# Container-native script to spawn the Bibliographer
# Run this FROM INSIDE the container (e.g., by Convener agent)
#
# Beads integration: Creates a bibliography bead for tracking. Closes on completion.

set -e

SYMPOSIUM_DIR="$1"   # Path to symposium directory
SYMPOSIUM_BEAD="$2"  # Parent symposium bead ID (optional)

if [ -z "$SYMPOSIUM_DIR" ]; then
    cat <<EOF
Usage: spawn-bibliographer.sh <symposium-dir> [symposium-bead]

Example:
  spawn-bibliographer.sh /atlantis/philosophy/first-works/symposium-governance-2026-01 ph-symp-01

Arguments:
  symposium-dir  - Path to the symposium directory containing all phase outputs
  symposium-bead - (Optional) Parent symposium bead ID for linking

This script runs INSIDE the container. The Bibliographer extracts citations
from all symposium outputs and updates the master bibliography.

EOF
    exit 1
fi

SESSION_NAME="atlantis-bibliographer"
WORKSPACE="/atlantis/philosophy/bibliographer"
SYMPOSIUM_NAME=$(basename "$SYMPOSIUM_DIR")

echo "════════════════════════════════════════════════"
echo "Spawning Bibliographer"
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

# Create bibliography bead
echo "Creating bibliography bead..."
cd /atlantis/philosophy
BEAD_TITLE="Bibliography: $SYMPOSIUM_NAME"
if [ -n "$SYMPOSIUM_BEAD" ]; then
    BIB_BEAD=$(bd create --title "$BEAD_TITLE" --label bibliography --parent "$SYMPOSIUM_BEAD" 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
else
    BIB_BEAD=$(bd create --title "$BEAD_TITLE" --label bibliography 2>/dev/null | grep -oE 'ph-[a-z0-9.]+' | head -1)
fi

if [ -n "$BIB_BEAD" ]; then
    echo "Created bead: $BIB_BEAD"
    bd update "$BIB_BEAD" --status in_progress 2>/dev/null || true
else
    echo "Could not create bead (continuing without bead tracking)"
    BIB_BEAD="none"
fi
cd "$WORKSPACE"

# Create assignment
echo "Creating ASSIGNMENT.md..."
cat > "$WORKSPACE/ASSIGNMENT.md" <<ASSIGNMENT_EOF
# Bibliographer Assignment

**Symposium**: $SYMPOSIUM_DIR
**Master bibliography**: /atlantis/philosophy/philosophy-references.bib
**Output report**: $SYMPOSIUM_DIR/bibliographer-report.md

---

## Your Task

Extract all citations from the symposium outputs and update the master bibliography.

## Steps

1. **Scan all markdown files** in the symposium directory for citations
   - Look for [@cite-key] format references
   - Look for inline references to authors, works, concepts
   - Look for bibliographic entries at the end of documents

2. **Read the existing bibliography**:
   \`\`\`bash
   cat /atlantis/philosophy/philosophy-references.bib
   \`\`\`

3. **Add new entries** to the bibliography for any works cited that aren't already present
   - Use standard BibTeX format
   - Include: author, title, year, publisher/journal
   - For philosophical works, prefer authoritative editions

4. **Write a bibliographer report** to $SYMPOSIUM_DIR/bibliographer-report.md:
   - Total citations found
   - New entries added to bibliography
   - Citations that couldn't be verified
   - Most frequently cited works
   - Any citation inconsistencies across scholars

5. **Update the master bibliography**:
   \`\`\`bash
   # Edit /atlantis/philosophy/philosophy-references.bib with new entries
   \`\`\`

## Completion

**Your bead**: $BIB_BEAD

When finished:
1. Commit your report:
   \`\`\`bash
   cd /atlantis/philosophy && git add philosophy-references.bib && git commit -m "Bibliography: Update for $SYMPOSIUM_NAME"
   \`\`\`
2. Close your bead:
   \`\`\`bash
   cd /atlantis/philosophy && bd close $BIB_BEAD
   \`\`\`
3. Mail the Convener:
   \`\`\`bash
   export ATLANTIS_AGENT_NAME=bibliographer
   atlantis-mail send convener "BIBLIOGRAPHER_DONE" "Bibliography updated - bead $BIB_BEAD closed"
   \`\`\`
4. Exit Claude

## Standards

- Accuracy over completeness (don't guess)
- Standard BibTeX format
- Preserve existing entries (add, don't remove)
ASSIGNMENT_EOF

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$WORKSPACE"

# Start Claude with Haiku model (cost-efficient for detail work)
echo "Starting Claude (Haiku)..."
tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --model haiku" C-m

sleep 5

# Send initial prompt
echo "Sending bibliographer prompt..."
PROMPT="You are the Bibliographer. Read ASSIGNMENT.md and extract all citations from the symposium at $SYMPOSIUM_DIR. Update /atlantis/philosophy/philosophy-references.bib with any new entries and write a report to $SYMPOSIUM_DIR/bibliographer-report.md. Follow the completion instructions when done."

tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter

echo ""
echo "Bibliographer spawned successfully"
echo ""
echo "Session: $SESSION_NAME"
echo "Workspace: $WORKSPACE"
echo "Symposium: $SYMPOSIUM_DIR"
echo "Bibliography Bead: $BIB_BEAD"
echo ""
echo "Monitor with:"
echo "  tmux attach -t $SESSION_NAME"
echo ""
echo "Check bead status:"
echo "  cd /atlantis/philosophy && bd show $BIB_BEAD"
echo ""
echo "Detach with: Ctrl+B then D"
echo ""
