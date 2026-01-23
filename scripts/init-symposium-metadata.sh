#!/bin/bash
# Initialize symposium metadata files for Convener tracking
# This creates the metadata files that support mail-based completion detection

set -e

SYMPOSIUM_NAME="$1"
shift  # Remaining args are scholar names

if [ -z "$SYMPOSIUM_NAME" ]; then
    cat <<EOF
Usage: init-symposium-metadata.sh <symposium-name> <scholar1> [scholar2] [scholar3] ...

Example:
  init-symposium-metadata.sh governance-2026-01 solon pericles locke

Creates symposium metadata files for mail-based completion tracking:
  - .current-phase (set to "phase-1-independent-work")
  - .scholars (list of scholar names)
  - .completions/ (empty directory for completion markers)

Must be run AFTER symposium directory exists.
EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Resolve symposium directory
SYMPOSIUM_DIR="/atlantis/philosophy/first-works/symposium-$SYMPOSIUM_NAME"

echo "════════════════════════════════════════════════"
echo "📋 Initializing Symposium Metadata"
echo "════════════════════════════════════════════════"
echo "Symposium: $SYMPOSIUM_NAME"
echo "Directory: $SYMPOSIUM_DIR"
echo "Scholars: $@"
echo ""

# Ensure container is running
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d 2>/dev/null
sleep 1

# Check if symposium directory exists
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -d "$SYMPOSIUM_DIR"; then
    echo "Error: Symposium directory not found: $SYMPOSIUM_DIR"
    echo "Create it first or check the symposium name."
    exit 1
fi

# Create .current-phase
echo "→ Creating .current-phase..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    echo 'phase-1-independent-work' > '$SYMPOSIUM_DIR/.current-phase'
"

# Create .scholars with list of scholar names
echo "→ Creating .scholars..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
    cat > '$SYMPOSIUM_DIR/.scholars' <<'SCHOLARS_EOF'
$(for scholar in "$@"; do echo "$scholar"; done)
SCHOLARS_EOF
"

# Create .completions directory
echo "→ Creating .completions/ directory..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    mkdir -p "$SYMPOSIUM_DIR/.completions"

echo ""
echo "✅ Symposium metadata initialized"
echo ""
echo "Convener will now use mail-based completion tracking:"
echo "  1. Scholars mail: SCHOLAR_DONE <name>"
echo "  2. Convener creates: $SYMPOSIUM_DIR/.completions/scholar-<name>.done"
echo "  3. When all .done files exist, phase is complete"
echo ""
echo "Verify:"
echo "  docker compose exec atlantis ls -la $SYMPOSIUM_DIR"
echo ""
