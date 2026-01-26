#!/bin/bash
# Activate a symposium from the queue
# Use this to start a symposium when the Founder is unavailable

set -e

SYMPOSIUM_FILE="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# List available symposia if no argument
if [ -z "$SYMPOSIUM_FILE" ]; then
    echo "Usage: activate-symposium.sh <symposium-proposal>"
    echo ""
    echo "Activates a symposium from the queue, spawning a Convener to manage it."
    echo ""
    echo "Available symposia in queue:"
    echo ""
    if [ -d "symposia-queue" ] && [ "$(ls -A symposia-queue/*.md 2>/dev/null)" ]; then
        for f in symposia-queue/*.md; do
            NAME=$(basename "$f" .md)
            # Extract title from file
            TITLE=$(grep -m1 "^# " "$f" | sed 's/^# //' || echo "$NAME")
            STATUS=$(grep -m1 "^\*\*Status\*\*:" "$f" | sed 's/.*: //' || echo "unknown")
            echo "  $NAME"
            echo "    Title: $TITLE"
            echo "    Status: $STATUS"
            echo ""
        done
    else
        echo "  (no symposia in queue)"
    fi
    echo ""
    echo "Example:"
    echo "  ./scripts/activate-symposium.sh excellence-and-quality-standards"
    exit 1
fi

# Find the symposium file
if [ -f "$SYMPOSIUM_FILE" ]; then
    PROPOSAL_PATH="$SYMPOSIUM_FILE"
elif [ -f "symposia-queue/$SYMPOSIUM_FILE" ]; then
    PROPOSAL_PATH="symposia-queue/$SYMPOSIUM_FILE"
elif [ -f "symposia-queue/$SYMPOSIUM_FILE.md" ]; then
    PROPOSAL_PATH="symposia-queue/$SYMPOSIUM_FILE.md"
else
    echo "Symposium proposal not found: $SYMPOSIUM_FILE"
    echo ""
    echo "Looked in:"
    echo "  - $SYMPOSIUM_FILE"
    echo "  - symposia-queue/$SYMPOSIUM_FILE"
    echo "  - symposia-queue/$SYMPOSIUM_FILE.md"
    exit 1
fi

echo "════════════════════════════════════════════════════════════════"
echo "ACTIVATING SYMPOSIUM"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Proposal: $PROPOSAL_PATH"
echo ""

# Extract key info from proposal
TITLE=$(grep -m1 "^# " "$PROPOSAL_PATH" | sed 's/^# //' || echo "Unknown")
echo "Title: $TITLE"
echo ""

# Generate symposium name from filename
SYMPOSIUM_NAME=$(basename "$PROPOSAL_PATH" .md)
SYMPOSIUM_DATE=$(date +%Y-%m)
SYMPOSIUM_DIR="first-works/symposium-${SYMPOSIUM_NAME}-${SYMPOSIUM_DATE}"

echo "Symposium directory: $SYMPOSIUM_DIR"
echo ""

# Confirm
read -p "Activate this symposium? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Creating symposium directory structure..."

# Create directories
mkdir -p "$SYMPOSIUM_DIR"
mkdir -p "$SYMPOSIUM_DIR/.completions"

# Copy proposal to symposium directory
cp "$PROPOSAL_PATH" "$SYMPOSIUM_DIR/PROPOSAL.md"

# Initialize metadata
echo "phase-0-initialization" > "$SYMPOSIUM_DIR/.current-phase"

# Create symposium README
cat > "$SYMPOSIUM_DIR/README.md" <<README_EOF
# Symposium: $TITLE

**Activated**: $(date -I)
**Status**: Active (Phase 0 - Initialization)

## Proposal

See [PROPOSAL.md](PROPOSAL.md) for the full symposium proposal.

## Phases

- [ ] Phase 1: Independent Work
- [ ] Phase 2: Independent Review
- [ ] Phase 3: Independent Revision
- [ ] Phase 4: Cross-Review
- [ ] Phase 5: Cross-Work Review
- [ ] Phase 6: Synthesis
- [ ] Phase 7: Opposition
- [ ] Phase 8: Final Critique
- [ ] Phase 9: Convener Report
- [ ] Phase 10: Recognition

## Directory Structure

\`\`\`
$SYMPOSIUM_DIR/
├── PROPOSAL.md           # Original proposal
├── README.md             # This file
├── .current-phase        # Current phase tracking
├── .scholars             # Scholar names (created by Convener)
├── .critics              # Critic names (created by Convener)
├── .completions/         # Completion markers
├── phase-1-independent-work/
├── phase-2-independent-review/
└── ...
\`\`\`
README_EOF

echo "✓ Created symposium directory: $SYMPOSIUM_DIR"

# Copy proposal into container
echo ""
echo "Syncing to container..."
docker compose exec -T atlantis mkdir -p "/atlantis/philosophy/$SYMPOSIUM_DIR"
docker cp "$SYMPOSIUM_DIR/." "new-atlantis:/atlantis/philosophy/$SYMPOSIUM_DIR/"

echo "✓ Synced to container"

# Spawn Convener
echo ""
echo "Spawning Convener to manage the symposium..."
echo ""

# Check if convener session already exists
if docker compose exec -T atlantis tmux has-session -t atlantis-convener 2>/dev/null; then
    echo "⚠️  A Convener session already exists."
    echo "The existing Convener will need to pick up this symposium."
    echo ""
    echo "To check on the Convener:"
    echo "  ./scripts/monitor-agents.sh convener"
else
    # Spawn convener using the existing spawn script if it exists, otherwise manual
    if [ -f "scripts/spawn-convener.sh" ]; then
        ./scripts/spawn-convener.sh "$SYMPOSIUM_DIR"
    else
        # Manual spawn
        docker compose exec -T atlantis tmux new-session -d -s atlantis-convener -c /atlantis/philosophy
        sleep 2
        docker compose exec -T atlantis tmux send-keys -t atlantis-convener "claude --permission-mode bypassPermissions --model sonnet" C-m
        sleep 3

        CONVENER_PROMPT="You are the Convener of New Atlantis. A new symposium has been activated at /atlantis/philosophy/$SYMPOSIUM_DIR. Read the PROPOSAL.md, select appropriate philosophical traditions for the scholars, and begin Phase 1 by spawning 3 scholars. Use container-native spawn scripts in /atlantis/philosophy/scripts/container/. Follow the Symposium Molecule workflow (10 phases)."

        docker compose exec -T atlantis tmux send-keys -t atlantis-convener -l "$CONVENER_PROMPT"
        docker compose exec -T atlantis tmux send-keys -t atlantis-convener C-m
    fi

    echo "✓ Convener spawned"
fi

# Commit the activation
echo ""
echo "Committing activation..."
git add "$SYMPOSIUM_DIR"
git commit -m "Activate Symposium: $TITLE

Symposium directory: $SYMPOSIUM_DIR
Proposal: $PROPOSAL_PATH

Co-Authored-By: activate-symposium.sh"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "SYMPOSIUM ACTIVATED"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Symposium: $TITLE"
echo "Directory: $SYMPOSIUM_DIR"
echo ""
echo "Next steps:"
echo "  1. Monitor the Convener: ./scripts/monitor-agents.sh convener"
echo "  2. List all agents: ./scripts/monitor-agents.sh list"
echo "  3. Check symposium status: cat $SYMPOSIUM_DIR/.current-phase"
echo ""
echo "The Convener will:"
echo "  - Select 3 philosophical traditions"
echo "  - Spawn 3 scholars for Phase 1"
echo "  - Manage the 10-phase workflow autonomously"
echo ""
