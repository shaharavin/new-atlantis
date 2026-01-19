#!/bin/bash
# New Atlantis Container Management Script
# Provides convenient commands for managing the containerized intellectual community

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

usage() {
    cat <<EOF
New Atlantis Container Management

Usage: $0 <command>

Commands:
    build       Build the New Atlantis container image
    start       Start the container (create if doesn't exist)
    stop        Stop the running container
    shell       Open a bash shell in the container
    scholar     Spawn a new scholar workspace in the container
    exec        Execute a command in the container
    logs        View container logs
    inspect     Inspect the atlantis workspace volume
    reset       Reset the atlantis workspace (DESTRUCTIVE)
    clean       Stop and remove container and volumes (DESTRUCTIVE)
    status      Show container status

Examples:
    $0 build
    $0 start
    $0 shell
    $0 exec "ls -la /atlantis"
    $0 scholar aristotle

EOF
    exit 1
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: Docker Compose is not installed${NC}"
        exit 1
    fi
}

build() {
    echo -e "${BLUE}Building New Atlantis container...${NC}"
    cd "$PROJECT_DIR"
    docker compose build
    echo -e "${GREEN}✓ Container built successfully${NC}"
}

start() {
    echo -e "${BLUE}Starting New Atlantis container...${NC}"
    cd "$PROJECT_DIR"
    docker compose up -d
    echo -e "${GREEN}✓ Container started${NC}"
    echo -e "${YELLOW}Run '$0 shell' to access the container${NC}"
}

stop() {
    echo -e "${BLUE}Stopping New Atlantis container...${NC}"
    cd "$PROJECT_DIR"
    docker compose stop
    echo -e "${GREEN}✓ Container stopped${NC}"
}

shell() {
    echo -e "${BLUE}Opening shell in New Atlantis container...${NC}"
    cd "$PROJECT_DIR"
    docker compose exec atlantis /bin/bash
}

scholar() {
    local scholar_name="$1"
    if [ -z "$scholar_name" ]; then
        echo -e "${RED}Error: Scholar name required${NC}"
        echo "Usage: $0 scholar <name>"
        exit 1
    fi

    echo -e "${BLUE}Spawning scholar workspace: $scholar_name${NC}"
    cd "$PROJECT_DIR"
    docker compose exec atlantis /bin/bash -c "
        mkdir -p /atlantis/scholars/$scholar_name
        cd /atlantis/scholars/$scholar_name
        if [ ! -f CLAUDE.md ]; then
            cp /new-atlantis-repo/templates/scholar-CLAUDE.md ./CLAUDE.md
            echo -e '${GREEN}✓ Scholar template created${NC}'
            echo -e '${YELLOW}Edit /atlantis/scholars/$scholar_name/CLAUDE.md to customize the assignment${NC}'
        else
            echo -e '${YELLOW}Scholar workspace already exists${NC}'
        fi
        if [ ! -d .git ]; then
            git init
            git add CLAUDE.md
            git commit -m 'Initialize Scholar $scholar_name workspace'
            echo -e '${GREEN}✓ Git repository initialized${NC}'
        fi
        echo -e '${GREEN}✓ Scholar workspace ready${NC}'
        echo -e '${YELLOW}To spawn the scholar, run: $0 exec \"cd /atlantis/scholars/$scholar_name && claude\"${NC}'
    "
}

exec_cmd() {
    local cmd="$1"
    if [ -z "$cmd" ]; then
        echo -e "${RED}Error: Command required${NC}"
        echo "Usage: $0 exec \"<command>\""
        exit 1
    fi

    cd "$PROJECT_DIR"
    docker compose exec atlantis /bin/bash -c "$cmd"
}

logs() {
    cd "$PROJECT_DIR"
    docker compose logs -f atlantis
}

inspect() {
    echo -e "${BLUE}Inspecting atlantis workspace volume...${NC}"
    docker run --rm -v new-atlantis-workspace:/atlantis:ro ubuntu:22.04 ls -laR /atlantis
}

reset() {
    echo -e "${RED}WARNING: This will delete all scholar work in the atlantis workspace!${NC}"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted"
        exit 1
    fi

    echo -e "${BLUE}Resetting atlantis workspace...${NC}"
    cd "$PROJECT_DIR"
    docker compose down
    docker volume rm new-atlantis-workspace
    echo -e "${GREEN}✓ Workspace reset${NC}"
    echo -e "${YELLOW}Run '$0 start' to create a fresh workspace${NC}"
}

clean() {
    echo -e "${RED}WARNING: This will delete the container and all scholar work!${NC}"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted"
        exit 1
    fi

    echo -e "${BLUE}Cleaning up New Atlantis container...${NC}"
    cd "$PROJECT_DIR"
    docker compose down -v
    echo -e "${GREEN}✓ Container and volumes removed${NC}"
}

status() {
    echo -e "${BLUE}Container Status:${NC}"
    cd "$PROJECT_DIR"
    docker compose ps
    echo ""
    echo -e "${BLUE}Volume Status:${NC}"
    docker volume ls | grep new-atlantis || echo "No volumes found"
}

# Main command dispatcher
check_docker

case "${1:-}" in
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    shell)
        shell
        ;;
    scholar)
        scholar "$2"
        ;;
    exec)
        exec_cmd "$2"
        ;;
    logs)
        logs
        ;;
    inspect)
        inspect
        ;;
    reset)
        reset
        ;;
    clean)
        clean
        ;;
    status)
        status
        ;;
    *)
        usage
        ;;
esac
