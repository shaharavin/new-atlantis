#!/bin/bash
# Clean up a completed symposium: copy from container, kill sessions, commit, push
#
# This is the host-side counterpart to the Convener's archive phase.
# The Convener writes the README inside the container; this script handles
# the mechanical tasks that require host access.

set -e

SYMPOSIUM_NAME="$1"

if [ -z "$SYMPOSIUM_NAME" ]; then
    cat <<EOF
Usage: cleanup-symposium.sh <symposium-name>

Example:
  ./scripts/cleanup-symposium.sh symposium-governance-2026-01

This script:
1. Copies symposium outputs from container to host (first-works/)
2. Kills remaining tmux sessions
3. Git commits the archive
4. Git pushes to GitHub

Prerequisites:
- Convener has written README.md inside the container
- Symposium bead is closed
- Container is running

EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTAINER_DIR="/atlantis/philosophy/first-works/$SYMPOSIUM_NAME"
HOST_DIR="$PROJECT_ROOT/first-works/$SYMPOSIUM_NAME"

echo "════════════════════════════════════════════════"
echo "Cleaning up: $SYMPOSIUM_NAME"
echo "════════════════════════════════════════════════"
echo ""

# Ensure container is running
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d 2>/dev/null
sleep 1

# Verify symposium exists in container
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -d "$CONTAINER_DIR"; then
    echo "Error: Symposium not found in container: $CONTAINER_DIR"
    echo ""
    echo "Available symposia:"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        ls -1 /atlantis/philosophy/first-works/ 2>/dev/null | grep "^symposium-" || echo "  (none)"
    exit 1
fi

# Check for README (indicates Convener completed archive phase)
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -f "$CONTAINER_DIR/README.md"; then
    echo "Warning: No README.md found. The Convener may not have completed the archive phase."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ─── Step 1: Copy from container to host ───
echo ""
echo "Step 1: Copying outputs to host..."

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

# Copy entire symposium directory
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
git add "first-works/$SYMPOSIUM_NAME/"
git add "philosophy-references.bib" 2>/dev/null || true

# Check if there's anything to commit
if git diff --cached --quiet; then
    echo "  Nothing new to commit (files may already be tracked)."
else
    git commit -m "Archive: $SYMPOSIUM_NAME

Symposium outputs copied from container and archived.
$([ -f "$HOST_DIR/README.md" ] && head -5 "$HOST_DIR/README.md" | grep -E "^\*\*|^#" | head -2 || echo "")

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
echo "Cleanup complete: $SYMPOSIUM_NAME"
echo "════════════════════════════════════════════════"
echo ""
echo "Archive: $HOST_DIR"
echo "Files: $FILE_COUNT markdown files"
echo ""
echo "View on GitHub after push completes."
echo ""
