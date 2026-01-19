# New Atlantis Docker Container Guide

Running New Atlantis in a Docker container provides complete isolation between your host system and the agent-driven scholarly work. This ensures that automated agents cannot affect your main filesystem.

## Prerequisites

- Docker Desktop installed and running
- Docker Compose v2+
- Your `ANTHROPIC_API_KEY` environment variable set

## Quick Start

### 1. Build the Container

```bash
cd /Users/shaharavin/Code/new-atlantis
./scripts/atlantis-container.sh build
```

This creates an Ubuntu-based container with:
- Git
- Node.js and Claude Code
- Isolated `/atlantis` workspace
- Non-root `atlantis` user for security

### 2. Start the Container

```bash
./scripts/atlantis-container.sh start
```

This starts the container in detached mode with:
- Read-only access to New Atlantis codebase
- Isolated persistent workspace volume
- API key from your environment

### 3. Access the Container

```bash
./scripts/atlantis-container.sh shell
```

You're now in a bash shell inside the container as the `atlantis` user.

## Container Architecture

### Directory Structure

```
Container:
├── /atlantis/                  # Isolated workspace (persistent volume)
│   ├── scholars/               # Scholar workspaces
│   ├── philosophy/             # Academy rigs
│   ├── .beads/                 # Beads metadata
│   └── ...
├── /new-atlantis-repo/         # Read-only mount of codebase
│   ├── templates/
│   ├── .beads/
│   └── ...
└── /home/atlantis/
    └── outputs/                # Shared with host for viewing results

Host:
├── ~/Code/new-atlantis/        # Development code (mounted read-only)
└── ~/Code/new-atlantis/container-outputs/  # Results exported from container
```

### Isolation Features

✅ **Filesystem Isolation**: Agents can only access `/atlantis` and read-only code
✅ **Resource Limits**: 4GB RAM max, 2 CPU cores
✅ **Network Isolation**: Container has its own network namespace
✅ **User Isolation**: Runs as non-root `atlantis` user
✅ **Volume Persistence**: Work survives container restarts

## Common Workflows

### Spawning a New Scholar

Method 1: Using the convenience script
```bash
./scripts/atlantis-container.sh scholar aristotle
```

Method 2: Manual process
```bash
# Enter the container
./scripts/atlantis-container.sh shell

# Inside container:
mkdir -p /atlantis/scholars/aristotle
cd /atlantis/scholars/aristotle
cp /new-atlantis-repo/templates/scholar-CLAUDE.md ./CLAUDE.md

# Edit CLAUDE.md with the scholar's assignment
# (Use vi, nano, or edit from host via outputs mount)

# Initialize git
git init
git add CLAUDE.md
git commit -m "Initialize Scholar Aristotle workspace"

# Spawn the scholar
claude
# In the Claude session, say: "Start working on your assignment"
```

### Viewing Scholar Work

Option 1: Inside the container
```bash
./scripts/atlantis-container.sh shell
cat /atlantis/scholars/aristotle/essays/ai-citizenship.md
```

Option 2: Copy to host for viewing
```bash
./scripts/atlantis-container.sh exec "cp -r /atlantis/scholars/aristotle/essays /home/atlantis/outputs/"
# Now view at: ~/Code/new-atlantis/container-outputs/essays/
```

Option 3: Inspect the volume
```bash
./scripts/atlantis-container.sh inspect
```

### Running Gas Town Commands (Future)

Once Gas Town integration is complete:

```bash
# Enter container
./scripts/atlantis-container.sh shell

# Inside container, run adapted commands:
cd /atlantis
at academy create philosophy
at assign topic "Your philosophical question" --scholar aristotle
at founder convene
```

## Management Commands

All commands are available through `./scripts/atlantis-container.sh`:

| Command | Description |
|---------|-------------|
| `build` | Build/rebuild the container image |
| `start` | Start the container |
| `stop` | Stop the container |
| `shell` | Open bash shell in container |
| `scholar <name>` | Create scholar workspace |
| `exec "<cmd>"` | Execute a command in container |
| `logs` | View container logs |
| `inspect` | Inspect workspace volume contents |
| `status` | Show container and volume status |
| `reset` | Delete workspace volume (DESTRUCTIVE) |
| `clean` | Remove container and volumes (DESTRUCTIVE) |

## Environment Variables

The container inherits these from your host environment:

- `ANTHROPIC_API_KEY` - Required for Claude Code
- `ATLANTIS_WORKSPACE=/atlantis` - Default workspace path
- `NEW_ATLANTIS_REPO=/new-atlantis-repo` - Read-only code path

To pass additional environment variables, edit `docker-compose.yml`.

## Development Workflow

### Making Code Changes

1. Edit code on host: `~/Code/new-atlantis/`
2. Changes are immediately visible in container at `/new-atlantis-repo/`
3. Rebuild container if Dockerfile or dependencies change:
   ```bash
   ./scripts/atlantis-container.sh stop
   ./scripts/atlantis-container.sh build
   ./scripts/atlantis-container.sh start
   ```

### Testing Changes with Scholars

1. Make code changes on host
2. Enter container: `./scripts/atlantis-container.sh shell`
3. Spawn test scholar and verify behavior
4. If good, commit on host; if bad, iterate

### Resetting After Experimentation

```bash
# Nuclear option: delete everything and start fresh
./scripts/atlantis-container.sh clean

# Softer option: keep container, reset workspace only
./scripts/atlantis-container.sh reset
```

## Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker ps

# Check container status
./scripts/atlantis-container.sh status

# View logs
./scripts/atlantis-container.sh logs
```

### API Key Not Working

```bash
# Verify key is set on host
echo $ANTHROPIC_API_KEY

# Check if passed to container
./scripts/atlantis-container.sh exec "echo \$ANTHROPIC_API_KEY"

# Restart container to pick up new environment
./scripts/atlantis-container.sh stop
./scripts/atlantis-container.sh start
```

### Workspace Volume Full

```bash
# Check volume size
docker system df -v

# Inspect what's using space
./scripts/atlantis-container.sh inspect

# If needed, prune old data
./scripts/atlantis-container.sh exec "cd /atlantis && du -sh *"
```

### Permission Denied Errors

The container runs as the `atlantis` user (UID 1000). If you encounter permission issues:

```bash
# Inside container, verify user
./scripts/atlantis-container.sh exec "whoami"
# Should output: atlantis

# Check file ownership
./scripts/atlantis-container.sh exec "ls -la /atlantis"
# Should be owned by atlantis:atlantis
```

## Security Considerations

### What's Protected

✅ Your host filesystem is safe from agent writes
✅ Agents cannot access files outside `/atlantis`
✅ Resource usage is limited (4GB RAM, 2 CPU)
✅ Container runs as non-root user
✅ Network isolation prevents unintended connections

### What's NOT Protected

⚠️ Agents can still make API calls (they need this for Claude Code)
⚠️ Agents can use your ANTHROPIC_API_KEY (incurs costs)
⚠️ Container can access the network (needed for npm, git, etc.)

### Best Practices

1. **Monitor API usage**: Check your Anthropic console for unexpected costs
2. **Review scholar output**: Don't blindly trust generated work
3. **Use read-only mounts**: Code is mounted read-only by default
4. **Regular resets**: Clean up test workspaces frequently
5. **Backup important work**: Export scholar essays you want to keep

## Advanced Usage

### Mounting Additional Directories

Edit `docker-compose.yml` to add volumes:

```yaml
volumes:
  - ./:/new-atlantis-repo:ro
  - atlantis-workspace:/atlantis
  - ./container-outputs:/home/atlantis/outputs
  - /path/to/research/papers:/home/atlantis/library:ro  # Add this
```

### Adjusting Resource Limits

Edit `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'      # Increase CPU
      memory: 8G       # Increase RAM
```

### Running Multiple Containers

To run multiple isolated New Atlantis instances:

1. Copy the project directory
2. Edit `docker-compose.yml` to use different container/volume names
3. Run each instance separately

## Integration with Gas Town

Once Phase 3 is complete, the container will support:

- Full `at` command suite (adapted from `gt`)
- Automated scholar orchestration
- Multi-academy coordination
- Persistent hooks and worktrees

The containerization ensures all this automation stays safely isolated.

## Exporting Scholar Work

To archive completed scholar work to the main repository:

```bash
# Method 1: Copy from container to host
./scripts/atlantis-container.sh exec "cp /atlantis/scholars/aristotle/essays/ai-citizenship.md /home/atlantis/outputs/"
cp container-outputs/ai-citizenship.md first-works/aristotle/

# Method 2: Git workflow
./scripts/atlantis-container.sh shell
# Inside container:
cd /atlantis/scholars/aristotle
git remote add origin file:///home/atlantis/outputs/export.git
git push origin main
# Then on host, clone from container-outputs/export.git
```

## Next Steps

Now that you have a safe containerized environment:

1. Spawn your first containerized scholar
2. Validate the workflow end-to-end
3. Begin Gas Town integration with confidence
4. Scale up to multiple scholars

The container gives you freedom to experiment without fear of system contamination.

---

**Welcome to the safe harbor of New Atlantis.** 🏛️🐳
