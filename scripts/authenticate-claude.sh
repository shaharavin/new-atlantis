#!/bin/bash
# One-time Claude Code authentication for New Atlantis container
# Run this once to set up credentials, then spawn-scholar.sh will work

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
if [ -f "$PROJECT_DIR/.env" ]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

echo "=== Claude Code One-Time Authentication ===="
echo ""
echo "This script will help you authenticate Claude Code in the container."
echo "You only need to do this ONCE. Credentials will persist in the"
echo "'claude-config' Docker volume."
echo ""
echo "Steps:"
echo "1. We'll start Claude Code interactively"
echo "2. Select '2. Anthropic Console account'"
echo "3. Claude will use the API key from .env automatically"
echo "4. Exit Claude (Ctrl+C)"
echo "5. Future scholars will use these credentials automatically"
echo ""
read -p "Press Enter to continue..."

# Ensure container is running
echo ""
echo "→ Starting container..."
docker compose -f "$PROJECT_DIR/docker-compose.yml" up -d

# Run Claude interactively to authenticate
echo ""
echo "→ Starting Claude Code for authentication..."
echo ""
echo "IMPORTANT: When prompted, select option 2 (Anthropic Console account)"
echo "           Then exit with Ctrl+C once you see the Claude prompt"
echo ""
read -p "Press Enter to launch Claude..."

docker compose -f "$PROJECT_DIR/docker-compose.yml" exec atlantis \
    bash -c "cd /atlantis && claude --dangerously-skip-permissions"

echo ""
echo "✅ Authentication complete!"
echo ""
echo "Credentials are now saved in the 'claude-config' volume."
echo "You can now spawn scholars non-interactively with:"
echo ""
echo "  ./scripts/spawn-scholar.sh <scholar-name> <bead-id>"
echo ""
