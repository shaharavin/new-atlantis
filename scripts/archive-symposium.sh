#!/bin/bash
# Archive a completed symposium
# Handles mechanical archiving; intellectual wrap-up requires Claude

set -e

SYMPOSIUM_NAME="$1"

if [ -z "$SYMPOSIUM_NAME" ]; then
    cat <<EOF
Usage: archive-symposium.sh <symposium-name>

Example:
  ./scripts/archive-symposium.sh excellence-and-quality-standards

This script handles mechanical archiving:
1. Creates completed-symposia/<name>.yml manifest
2. Copies final outputs to archive location
3. Kills remaining tmux sessions for the symposium
4. Updates .current-phase to "complete"

NOTE: Intellectual wrap-up (reading outputs, writing summary, extracting
lessons) requires Claude. Run this script first, then ask Claude to
review the archived symposium.

EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure container is running
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d 2>/dev/null
sleep 1

# Find symposium directory
SYMPOSIUM_DIR="/atlantis/philosophy/first-works/symposium-$SYMPOSIUM_NAME"

echo "════════════════════════════════════════════════"
echo "📦 Archiving Symposium: $SYMPOSIUM_NAME"
echo "════════════════════════════════════════════════"
echo ""

# Check if symposium exists
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -d "$SYMPOSIUM_DIR"; then
    echo "Error: Symposium directory not found: $SYMPOSIUM_DIR"
    echo ""
    echo "Available symposia:"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        ls -1 /atlantis/philosophy/first-works/ 2>/dev/null | grep "^symposium-" || echo "  (none found)"
    exit 1
fi

# Get current phase
CURRENT_PHASE=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    cat "$SYMPOSIUM_DIR/.current-phase" 2>/dev/null || echo "unknown")
echo "Current phase: $CURRENT_PHASE"

# Count outputs
echo ""
echo "→ Counting outputs..."
PHASE_DIRS=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    find "$SYMPOSIUM_DIR" -maxdepth 1 -type d -name "phase-*" | wc -l | tr -d ' ')
echo "  Phase directories: $PHASE_DIRS"

MD_FILES=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    find "$SYMPOSIUM_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
echo "  Markdown files: $MD_FILES"

# Generate manifest
echo ""
echo "→ Generating manifest..."
MANIFEST_FILE="$PROJECT_ROOT/completed-symposia/symposium-$SYMPOSIUM_NAME-$(date +%Y-%m).yml"

cat > "$MANIFEST_FILE" <<EOF
# Symposium Archive Manifest
# Generated: $(date -Iseconds)

symposium: "$SYMPOSIUM_NAME"
archive_date: "$(date +%Y-%m-%d)"
source_dir: "$SYMPOSIUM_DIR"
final_phase: "$CURRENT_PHASE"

# Statistics
phase_count: $PHASE_DIRS
markdown_files: $MD_FILES

# Key outputs (populate after intellectual review)
synthesis: null  # Path to synthesis essay
opposition: null  # Path to opposition report
convener_report: null  # Path to convener report

# Assessment (populate after intellectual review)
quality_assessment: null
key_insights: []
lessons_learned: []

# Participants (populate from .scholars/.critics files)
scholars: []
critics: []

# Status
archived: true
reviewed: false  # Set to true after Claude reviews
EOF

echo "  Created: $MANIFEST_FILE"

# Mark symposium as complete
echo ""
echo "→ Marking symposium complete..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    echo 'complete' > '$SYMPOSIUM_DIR/.current-phase'
"

# Kill symposium-related tmux sessions
echo ""
echo "→ Checking for active sessions..."
SESSIONS=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux ls 2>/dev/null | grep -E "atlantis-(philosophy|critic|opposition|convener)" || echo "")

if [ -n "$SESSIONS" ]; then
    echo "  Active sessions found:"
    echo "$SESSIONS" | sed 's/^/    /'
    echo ""
    read -p "Kill these sessions? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
            tmux ls 2>/dev/null | grep -E 'atlantis-(philosophy|critic|opposition|convener)' | cut -d: -f1 | while read session; do
                tmux kill-session -t \"\$session\" 2>/dev/null || true
                echo \"  Killed: \$session\"
            done
        "
    else
        echo "  Sessions left running."
    fi
else
    echo "  No active symposium sessions."
fi

echo ""
echo "════════════════════════════════════════════════"
echo "✅ Mechanical Archiving Complete"
echo "════════════════════════════════════════════════"
echo ""
echo "Manifest: $MANIFEST_FILE"
echo ""
echo "NEXT STEPS (require Claude):"
echo "1. Read synthesis and opposition reports"
echo "2. Assess quality and extract insights"
echo "3. Update manifest with assessment"
echo "4. Update NEXT-STEPS.md"
echo "5. Consider updating SCHOLAR-REGISTRY.md"
echo ""
echo "To review with Claude:"
echo "  'Please review the completed symposium $SYMPOSIUM_NAME'"
echo ""
