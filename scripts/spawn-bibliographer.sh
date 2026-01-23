#!/bin/bash
# Spawn bibliographer to process citations from symposium outputs
# Uses Haiku model for cost efficiency

set -e

SYMPOSIUM_NAME="$1"
PHASE="$2"

if [ -z "$SYMPOSIUM_NAME" ] || [ -z "$PHASE" ]; then
    cat <<EOF
Usage: spawn-bibliographer.sh <symposium-name> <phase>

Example:
  spawn-bibliographer.sh governance-2026-01 phase-1-independent-work

This spawns a Bibliographer (Haiku model) to:
- Extract citations from symposium outputs
- Add missing entries to philosophy-references.bib
- Standardize citation keys
- Generate completion report

Cost: ~\$0.15-0.30 per run (Haiku pricing)
EOF
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Resolve symposium directory
SYMPOSIUM_DIR="/atlantis/philosophy/first-works/$SYMPOSIUM_NAME"

echo "════════════════════════════════════════════════"
echo "📚 Spawning Bibliographer"
echo "════════════════════════════════════════════════"
echo "Symposium: $SYMPOSIUM_NAME"
echo "Phase: $PHASE"
echo "Directory: $SYMPOSIUM_DIR/$PHASE"
echo ""

# Ensure container is running
echo "→ Ensuring container is running..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d
sleep 2

# Check if symposium directory exists
echo "→ Verifying symposium directory..."
if ! docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    test -d "$SYMPOSIUM_DIR/$PHASE"; then
    echo "Error: Directory not found: $SYMPOSIUM_DIR/$PHASE"
    echo "Available phases:"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        ls -1 "$SYMPOSIUM_DIR" 2>/dev/null || echo "  (symposium not found)"
    exit 1
fi

# Create bibliographer workspace
echo "→ Creating bibliographer workspace..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    mkdir -p "/atlantis/philosophy/bibliographer"

# Create assignment file
echo "→ Creating assignment..."
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis bash -c "
cat > /atlantis/philosophy/bibliographer/ASSIGNMENT.md <<'ASSIGNMENT_EOF'
# Bibliographer Assignment

**Your Role**: You are the Bibliographer of New Atlantis.

**Your Task**: Process citations from the completed symposium phase and update the bibliography.

## Assignment Details

**Symposium**: $SYMPOSIUM_NAME
**Phase**: $PHASE
**Directory**: $SYMPOSIUM_DIR/$PHASE

## Instructions

1. **Scan** all markdown files in the phase directory
2. **Extract** all Pandoc-style citations ([@key] format)
3. **Check** which citations are already in \`/atlantis/philosophy/philosophy-references.bib\`
4. **Research** missing citations and create proper BibTeX entries
5. **Add** missing entries to the bibliography
6. **Commit** your changes with a clear message
7. **Generate** a completion report
8. **Exit** when done

## Expected Output

- Updated \`philosophy-references.bib\` with all missing entries
- Git commit documenting what was added
- \`bibliographer-report.md\` in the phase directory
- All citations from this phase resolvable

## Notes

- Use **Haiku model** (you are cost-efficient detail work)
- Standardize citation keys to \`authorYEARshortname\` format
- Document any uncertainties in the BibTeX note field
- Include \"Cited by [Scholar] [Year]\" in note fields for provenance

## Template Location

Read \`/atlantis/philosophy/templates/bibliographer-CLAUDE.md\` for detailed workflow.

## Completion

When done, mail the convener (if available) and exit cleanly.

Good luck! Your bibliographic work makes the scholarly commons navigable.
ASSIGNMENT_EOF
"

# Spawn bibliographer session
echo "→ Spawning tmux session..."
SESSION_NAME="atlantis-bibliographer"

# Check if session exists
if docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "   ⚠️  Session already exists, killing old session"
    docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
        tmux kill-session -t "$SESSION_NAME"
    sleep 1
fi

# Create session
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux new-session -d -s "$SESSION_NAME" -c "/atlantis/philosophy/bibliographer"

# Start Claude with Haiku model (cost-efficient)
docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" "claude --permission-mode bypassPermissions --settings '{\"model\":\"claude-haiku-3-5\"}'" C-m

sleep 3

# Send initial prompt
echo "→ Sending bibliographer prompt..."
PROMPT="You are the Bibliographer. Read ASSIGNMENT.md and process citations from symposium '$SYMPOSIUM_NAME' phase '$PHASE'. Extract citations, update philosophy-references.bib, generate report, commit changes, and exit when complete. Be thorough and accurate."

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" -l "$PROMPT"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" exec -T atlantis \
    tmux send-keys -t "$SESSION_NAME" C-m

echo "✅ Bibliographer spawned (session: $SESSION_NAME)"
echo ""
echo "════════════════════════════════════════════════"
echo "📊 Monitoring"
echo "════════════════════════════════════════════════"
echo ""
echo "Attach to session:"
echo "  docker compose exec atlantis tmux attach -t $SESSION_NAME"
echo ""
echo "View progress:"
echo "  docker compose exec atlantis tmux capture-pane -t $SESSION_NAME -p"
echo ""
echo "Check for completion report:"
echo "  docker compose exec atlantis ls -la $SYMPOSIUM_DIR/$PHASE/bibliographer-report.md"
echo ""
echo "Expected runtime: ~2-5 minutes"
echo "Expected cost: ~\$0.15-0.30 (Haiku model)"
echo ""
