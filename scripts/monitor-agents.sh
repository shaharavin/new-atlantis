#!/bin/bash
# Monitor multiple New Atlantis agents in split screen

AGENT_TYPE="${1:-scholar}"  # scholar or critic
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

if [ "$AGENT_TYPE" = "scholar" ]; then
    echo "Monitoring scholars in split screen..."

    # Get active scholar sessions (matches scholars, not critics or coordinators)
    # Excludes: critic-, convener, nudger
    SESSIONS=$(docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" | grep -v -E "(critic-|convener|nudger)" | cut -d: -f1 || echo "")

    if [ -z "$SESSIONS" ]; then
        echo "No active scholar sessions found"
        exit 1
    fi

    # Convert to array
    SESSIONS_ARRAY=($SESSIONS)

    echo "Found ${#SESSIONS_ARRAY[@]} scholars:"
    for sess in "${SESSIONS_ARRAY[@]}"; do
        echo "  - $sess"
    done
    echo ""

    # Create monitoring session with splits
    if [ ${#SESSIONS_ARRAY[@]} -eq 1 ]; then
        # Just one scholar, attach directly
        docker compose exec atlantis tmux attach -t "${SESSIONS_ARRAY[0]}"
    elif [ ${#SESSIONS_ARRAY[@]} -eq 2 ]; then
        # Two scholars, side by side
        tmux new-session -d -s monitor-scholars \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[0]}" C-m \; \
            split-window -h \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[1]}" C-m

        echo "Attaching to monitoring session..."
        echo "Use Ctrl+B Arrow Keys to move between panes"
        echo "Use Ctrl+B Z to zoom a pane full screen"
        sleep 2
        tmux attach -t monitor-scholars
    else
        # Three or more scholars, grid layout
        tmux new-session -d -s monitor-scholars \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[0]}" C-m \; \
            split-window -h \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[1]}" C-m \; \
            split-window -v \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[2]}" C-m \; \
            select-pane -t 0 \; \
            split-window -v

        # If there are more, add them
        if [ ${#SESSIONS_ARRAY[@]} -gt 3 ]; then
            tmux send-keys -t monitor-scholars "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[3]}" C-m
        fi

        echo "Attaching to monitoring session..."
        echo "Layout: 2x2 grid"
        echo "Use Ctrl+B Arrow Keys to move between panes"
        echo "Use Ctrl+B Z to zoom a pane full screen"
        echo "Use Ctrl+B D to detach"
        sleep 2
        tmux attach -t monitor-scholars
    fi

elif [ "$AGENT_TYPE" = "critic" ]; then
    echo "Monitoring critics in split screen..."

    SESSIONS=$(docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-critic-" | cut -d: -f1 || echo "")

    if [ -z "$SESSIONS" ]; then
        echo "No active critic sessions found"
        exit 1
    fi

    SESSIONS_ARRAY=($SESSIONS)

    echo "Found ${#SESSIONS_ARRAY[@]} critics:"
    for sess in "${SESSIONS_ARRAY[@]}"; do
        echo "  - $sess"
    done
    echo ""

    # Create monitoring session
    if [ ${#SESSIONS_ARRAY[@]} -eq 1 ]; then
        docker compose exec atlantis tmux attach -t "${SESSIONS_ARRAY[0]}"
    elif [ ${#SESSIONS_ARRAY[@]} -eq 2 ]; then
        tmux new-session -d -s monitor-critics \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[0]}" C-m \; \
            split-window -h \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[1]}" C-m

        echo "Attaching to monitoring session..."
        sleep 2
        tmux attach -t monitor-critics
    else
        tmux new-session -d -s monitor-critics \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[0]}" C-m \; \
            split-window -h \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[1]}" C-m \; \
            split-window -v \; \
            send-keys "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[2]}" C-m \; \
            select-pane -t 0 \; \
            split-window -v

        if [ ${#SESSIONS_ARRAY[@]} -gt 3 ]; then
            tmux send-keys -t monitor-critics "docker compose exec atlantis tmux attach -t ${SESSIONS_ARRAY[3]}" C-m
        fi

        echo "Attaching to monitoring session..."
        sleep 2
        tmux attach -t monitor-critics
    fi
elif [ "$AGENT_TYPE" = "coordinator" ]; then
    echo "Monitoring coordinators (convener + nudger) in split screen..."

    # Check if both sessions exist
    HAS_CONVENER=$(docker compose exec -T atlantis tmux has-session -t atlantis-convener 2>/dev/null && echo "yes" || echo "no")
    HAS_NUDGER=$(docker compose exec -T atlantis tmux has-session -t atlantis-nudger 2>/dev/null && echo "yes" || echo "no")

    if [ "$HAS_CONVENER" = "yes" ] && [ "$HAS_NUDGER" = "yes" ]; then
        echo "Monitoring both convener and nudger..."
        echo ""

        # Kill existing monitoring session if it exists
        tmux kill-session -t monitor-coordinators 2>/dev/null || true

        # Create split view on HOST that runs docker compose exec commands
        tmux new-session -d -s monitor-coordinators \; \
            send-keys "docker compose exec atlantis tmux attach -t atlantis-convener" C-m \; \
            split-window -h \; \
            send-keys "docker compose exec atlantis tmux attach -t atlantis-nudger" C-m

        echo "Layout: Convener (left) | Nudger (right)"
        echo "Use Ctrl+B Arrow Keys to move between panes"
        echo "Use Ctrl+B Z to zoom a pane full screen"
        echo "Use Ctrl+B D to detach"
        echo ""
        sleep 2

        # Attach to the HOST monitoring session
        tmux attach -t monitor-coordinators

    elif [ "$HAS_CONVENER" = "yes" ]; then
        echo "Only convener is running, attaching..."
        docker compose exec atlantis tmux attach -t atlantis-convener
    elif [ "$HAS_NUDGER" = "yes" ]; then
        echo "Only nudger is running, attaching..."
        docker compose exec atlantis tmux attach -t atlantis-nudger
    else
        echo "No coordinator sessions found"
        exit 1
    fi

elif [ "$AGENT_TYPE" = "list" ]; then
    echo "Active agent sessions:"
    echo ""
    docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" || echo "  (no sessions found)"
    echo ""
    echo "Use './scripts/monitor-agents.sh <session-name>' to attach to a specific agent"

else
    # Try to attach to a specific named session
    SESSION_NAME="$AGENT_TYPE"

    # Check if it's a full session name or partial
    if docker compose exec -T atlantis tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Attaching to session: $SESSION_NAME"
        echo "Use Ctrl+B D to detach"
        echo ""
        docker compose exec atlantis tmux attach -t "$SESSION_NAME"
    elif docker compose exec -T atlantis tmux has-session -t "atlantis-$SESSION_NAME" 2>/dev/null; then
        echo "Attaching to session: atlantis-$SESSION_NAME"
        echo "Use Ctrl+B D to detach"
        echo ""
        docker compose exec atlantis tmux attach -t "atlantis-$SESSION_NAME"
    elif docker compose exec -T atlantis tmux has-session -t "atlantis-philosophy-$SESSION_NAME" 2>/dev/null; then
        echo "Attaching to session: atlantis-philosophy-$SESSION_NAME"
        echo "Use Ctrl+B D to detach"
        echo ""
        docker compose exec atlantis tmux attach -t "atlantis-philosophy-$SESSION_NAME"
    else
        echo "Session not found: $SESSION_NAME"
        echo ""
        echo "Available sessions:"
        docker compose exec -T atlantis tmux ls 2>/dev/null | grep "atlantis-" || echo "  (no sessions found)"
        echo ""
        echo "Usage: monitor-agents.sh [scholar|critic|coordinator|list|<session-name>]"
        echo ""
        echo "Examples:"
        echo "  ./scripts/monitor-agents.sh scholar                    # Monitor all scholars in split screen"
        echo "  ./scripts/monitor-agents.sh critic                     # Monitor all critics in split screen"
        echo "  ./scripts/monitor-agents.sh coordinator                # Monitor convener + nudger side-by-side"
        echo "  ./scripts/monitor-agents.sh list                       # List all active sessions"
        echo "  ./scripts/monitor-agents.sh test-scholar               # Attach to specific agent by name"
        echo "  ./scripts/monitor-agents.sh atlantis-philosophy-rawls  # Attach to full session name"
        exit 1
    fi
fi
