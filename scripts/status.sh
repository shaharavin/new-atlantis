#!/bin/bash
# Show status of all New Atlantis agents

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "════════════════════════════════════════════════════════════"
echo "           NEW ATLANTIS - AGENT STATUS"
echo "════════════════════════════════════════════════════════════"
echo ""

# Function to get last commit time for an agent
get_last_commit() {
    local workspace=$1
    if [ -d "$workspace" ]; then
        docker compose exec -T atlantis bash -c "
            cd $workspace 2>/dev/null || exit 1
            LAST_COMMIT=\$(git log -1 --format='%ct' 2>/dev/null || echo 0)
            NOW=\$(date +%s)
            if [ \$LAST_COMMIT -eq 0 ]; then
                echo 'no commits'
            else
                MINUTES=\$(( (NOW - LAST_COMMIT) / 60 ))
                if [ \$MINUTES -lt 60 ]; then
                    echo \"\${MINUTES}m ago\"
                else
                    HOURS=\$(( MINUTES / 60 ))
                    echo \"\${HOURS}h ago\"
                fi
            fi
        " 2>/dev/null || echo "unknown"
    else
        echo "no workspace"
    fi
}

# Check sessions
echo "COORDINATORS:"
echo "─────────────────────────────────────────────────────────────"

if docker compose exec -T atlantis tmux has-session -t atlantis-convener 2>/dev/null; then
    echo "  ✓ Convener     [RUNNING]"
else
    echo "  ✗ Convener     [STOPPED]"
fi

if docker compose exec -T atlantis tmux has-session -t atlantis-nudger 2>/dev/null; then
    echo "  ✓ Nudger       [RUNNING]"
else
    echo "  ✗ Nudger       [STOPPED]"
fi

echo ""
echo "SCHOLARS:"
echo "─────────────────────────────────────────────────────────────"

for scholar in solon pericles locke; do
    if docker compose exec -T atlantis tmux has-session -t "atlantis-$scholar" 2>/dev/null; then
        LAST_COMMIT=$(get_last_commit "/atlantis/philosophy/scholars/$scholar")
        echo "  ✓ $scholar     [RUNNING] - Last commit: $LAST_COMMIT"
    else
        LAST_COMMIT=$(get_last_commit "/atlantis/philosophy/scholars/$scholar")
        echo "  ✗ $scholar     [STOPPED] - Last commit: $LAST_COMMIT"
    fi
done

echo ""
echo "CRITICS:"
echo "─────────────────────────────────────────────────────────────"

for critic in critic-alpha critic-beta critic-gamma critic-delta critic-epsilon critic-zeta; do
    if docker compose exec -T atlantis tmux has-session -t "atlantis-$critic" 2>/dev/null; then
        LAST_COMMIT=$(get_last_commit "/atlantis/philosophy/critics/$critic")
        echo "  ✓ $critic  [RUNNING] - Last commit: $LAST_COMMIT"
    else
        # Only show if workspace exists
        if docker compose exec -T atlantis test -d "/atlantis/philosophy/critics/$critic" 2>/dev/null; then
            LAST_COMMIT=$(get_last_commit "/atlantis/philosophy/critics/$critic")
            echo "  ✗ $critic  [STOPPED] - Last commit: $LAST_COMMIT"
        fi
    fi
done

echo ""
echo "SYMPOSIUM STATUS:"
echo "─────────────────────────────────────────────────────────────"

# Check current symposium phase
SYMPOSIUM_DIR="/atlantis/philosophy/symposia/governance-2026-01"
if docker compose exec -T atlantis test -d "$SYMPOSIUM_DIR" 2>/dev/null; then
    PHASES=$(docker compose exec -T atlantis bash -c "ls -1d $SYMPOSIUM_DIR/phase-* 2>/dev/null | wc -l" | tr -d '\r')
    echo "  Active: Governance & Productivity (2026-01)"
    echo "  Phases completed: $PHASES"

    # Show latest phase
    LATEST=$(docker compose exec -T atlantis bash -c "ls -1d $SYMPOSIUM_DIR/phase-* 2>/dev/null | tail -1" | tr -d '\r')
    if [ -n "$LATEST" ]; then
        PHASE_NAME=$(basename "$LATEST")
        echo "  Latest phase: $PHASE_NAME"
    fi
else
    echo "  No active symposium"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "MONITORING OPTIONS:"
echo "  ./scripts/monitor-agents.sh scholar      # Watch scholars"
echo "  ./scripts/monitor-agents.sh critic       # Watch critics"
echo "  ./scripts/monitor-agents.sh coordinator  # Watch convener + nudger"
echo ""
echo "ATTACH TO SPECIFIC AGENT:"
echo "  docker compose exec atlantis tmux attach -t atlantis-<name>"
echo ""
