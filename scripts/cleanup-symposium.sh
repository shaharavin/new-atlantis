#!/bin/bash
# Clean up completed work: copy from container, kill sessions, commit, push
#
# This is the host-side counterpart to the Convener's archive phase.
# The Convener writes the README/WORKFLOW_COMPLETE inside the container;
# this script handles the mechanical tasks that require host access.

set -e

WORK_PATH="$1"

if [ -z "$WORK_PATH" ]; then
    cat <<EOF
Usage: cleanup-symposium.sh <work-path>

Arguments:
  work-path  - Path relative to first-works/ (can include subdirectories)

Examples:
  # Full symposium
  ./scripts/cleanup-symposium.sh symposium-governance-2026-01

  # Public essay within a symposium
  ./scripts/cleanup-symposium.sh symposium-constitutional-foundations-2026-01/public-essay

This script:
1. Copies outputs from container to host (first-works/)
2. Kills remaining tmux sessions (with confirmation)
3. Git commits the archive
4. Git pushes to GitHub

Prerequisites:
- Convener has completed the workflow (README.md or WORKFLOW_COMPLETE.md exists)
- Container is running

EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTAINER_DIR="/atlantis/philosophy/first-works/$WORK_PATH"
HOST_DIR="$PROJECT_ROOT/first-works/$WORK_PATH"

# Extract just the name for display (last path component)
WORK_NAME=$(basename "$WORK_PATH")

echo "════════════════════════════════════════════════"
echo "Cleaning up: $WORK_PATH"
echo "════════════════════════════════════════════════"
echo ""

# Ensure container is running
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d 2>/dev/null
sleep 1

# Verify work directory exists in container
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -d "$CONTAINER_DIR"; then
    echo "Error: Work directory not found in container: $CONTAINER_DIR"
    echo ""
    echo "Available in first-works/:"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        find /atlantis/philosophy/first-works/ -maxdepth 2 -type d -name "symposium-*" -o -name "public-essay" 2>/dev/null | \
        sed 's|/atlantis/philosophy/first-works/||' | grep -v "^$" | sort | sed 's/^/  /' || echo "  (none)"
    exit 1
fi

# Check for completion marker (README.md or WORKFLOW_COMPLETE.md)
HAS_README=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -f "$CONTAINER_DIR/README.md" && echo "yes" || echo "no")
HAS_WORKFLOW=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -f "$CONTAINER_DIR/WORKFLOW_COMPLETE.md" && echo "yes" || echo "no")

if [ "$HAS_README" = "no" ] && [ "$HAS_WORKFLOW" = "no" ]; then
    echo "Warning: No README.md or WORKFLOW_COMPLETE.md found."
    echo "The Convener may not have completed the workflow."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ─── Step 1: Copy from container to host ───
echo ""
echo "Step 1: Copying outputs to host..."

# Create parent directory if needed (for nested paths like symposium/public-essay)
mkdir -p "$(dirname "$HOST_DIR")"

# Remove old host copy if it exists (we're replacing it)
if [ -d "$HOST_DIR" ]; then
    echo "  Removing old host copy..."
    rm -rf "$HOST_DIR"
fi

# Get container name
CONTAINER_ID=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps -q atlantis)
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: Could not find container ID"
    exit 1
fi

# Copy entire work directory
docker cp "$CONTAINER_ID:$CONTAINER_DIR" "$HOST_DIR"
echo "  Copied to: $HOST_DIR"

# Count what we got
FILE_COUNT=$(find "$HOST_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
echo "  Markdown files: $FILE_COUNT"

# Also copy updated bibliography if it exists
echo "  Copying bibliography..."
docker cp "$CONTAINER_ID:/atlantis/philosophy/philosophy-references.bib" \
    "$PROJECT_ROOT/philosophy-references.bib" 2>/dev/null || echo "  (no bibliography changes)"

# ─── Step 2: Kill tmux sessions ───
echo ""
echo "Step 2: Cleaning up tmux sessions..."

SESSIONS=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux ls 2>/dev/null | grep -E "atlantis-" || echo "")

if [ -n "$SESSIONS" ]; then
    echo "  Active sessions:"
    echo "$SESSIONS" | sed 's/^/    /'
    echo ""
    read -p "  Kill these sessions? (Y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
            tmux ls 2>/dev/null | grep -E 'atlantis-' | cut -d: -f1 | while read session; do
                tmux kill-session -t \"\$session\" 2>/dev/null || true
                echo \"    Killed: \$session\"
            done
        "
    fi
else
    echo "  No active sessions."
fi

# ─── Step 3: Git commit ───
echo ""
echo "Step 3: Committing to git..."

cd "$PROJECT_ROOT"
git add "first-works/$WORK_PATH/"
git add "philosophy-references.bib" 2>/dev/null || true

# Check if there's anything to commit
if git diff --cached --quiet; then
    echo "  Nothing new to commit (files may already be tracked)."
else
    # Get summary from completion file
    SUMMARY=""
    if [ -f "$HOST_DIR/WORKFLOW_COMPLETE.md" ]; then
        SUMMARY=$(head -10 "$HOST_DIR/WORKFLOW_COMPLETE.md" | grep -E "^#|^\*\*" | head -2)
    elif [ -f "$HOST_DIR/README.md" ]; then
        SUMMARY=$(head -10 "$HOST_DIR/README.md" | grep -E "^#|^\*\*" | head -2)
    fi

    git commit -m "Archive: $WORK_PATH

Outputs copied from container and archived.
$SUMMARY

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
    echo "  Committed."
fi

# ─── Step 4: Git push ───
echo ""
echo "Step 4: Pushing to GitHub..."
git push
echo "  Pushed."

# ─── Done ───
echo ""
echo "════════════════════════════════════════════════"
echo "Cleanup complete: $WORK_PATH"
echo "════════════════════════════════════════════════"
echo ""
echo "Archive: $HOST_DIR"
echo "Files: $FILE_COUNT markdown files"
echo ""
echo "View on GitHub after push completes."
echo ""
