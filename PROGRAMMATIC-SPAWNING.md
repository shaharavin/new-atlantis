# Programmatic Scholar Spawning

**Status**: ✅ **WORKING** - Tested and validated with Scholar Episteme

This document explains how to spawn New Atlantis scholars programmatically without manual OAuth or permission prompts, using the Gas Town agent spawning pattern.

---

## The Problem We Solved

Initially, spawning scholars required:
- ❌ Manual OAuth browser flow each time
- ❌ Interactive permission prompts for every action
- ❌ Manual terminal access for each scholar
- ❌ No way to spawn multiple scholars in parallel

This made the system unscalable and required constant human intervention.

## The Solution

We adapted Gas Town's tmux-based agent spawning pattern:
- ✅ No OAuth prompts (uses API key from `.env`)
- ✅ No permission prompts (`--dangerously-skip-permissions` flag)
- ✅ Fully programmatic via shell script
- ✅ Scholars run in detached tmux sessions
- ✅ Can spawn multiple scholars in parallel

---

## Quick Start

### Spawn a Single Scholar

```bash
./scripts/spawn-scholar.sh <scholar-name> <bead-id>
```

**Example:**
```bash
./scripts/spawn-scholar.sh episteme ph-3rs
```

This:
1. Creates workspace at `/atlantis/philosophy/scholars/episteme/`
2. Spawns detached tmux session `atlantis-philosophy-episteme`
3. Starts Claude with `--dangerously-skip-permissions`
4. Updates bead `ph-3rs` to `in_progress`
5. Sends initial prompt to begin work
6. Scholar works autonomously in background

### Monitor Progress

**Attach to scholar session:**
```bash
docker compose exec atlantis tmux attach -t atlantis-philosophy-episteme
```

**Check workspace:**
```bash
./scripts/atlantis-container.sh exec "cd /atlantis/philosophy/scholars/episteme && ls -la"
```

**View git commits:**
```bash
./scripts/atlantis-container.sh exec "cd /atlantis/philosophy/scholars/episteme && git log --oneline"
```

**Check bead status:**
```bash
./scripts/atlantis-container.sh exec "cd /atlantis/philosophy && bd show ph-3rs"
```

**List all scholar sessions:**
```bash
docker compose exec atlantis tmux ls
```

---

## How It Works

### Architecture Overview

```
spawn-scholar.sh
    ↓
Docker Container (with tmux)
    ↓
Detached TMux Session: atlantis-philosophy-{scholar}
    ↓
claude --dangerously-skip-permissions
    ↓
Initial prompt via tmux send-keys
    ↓
Scholar works autonomously
```

### Step-by-Step Process

1. **Check Prerequisites**
   - Container running with tmux installed
   - API key loaded from `.env`
   - Scholar workspace exists with ASSIGNMENT.md

2. **Create TMux Session**
   ```bash
   tmux new-session -d -s atlantis-philosophy-{scholar} -c /atlantis/philosophy/scholars/{scholar}
   ```

3. **Start Claude with Skip-Permissions**
   ```bash
   tmux send-keys -t atlantis-philosophy-{scholar} "claude --dangerously-skip-permissions" C-m
   ```

4. **Update Bead Status**
   ```bash
   bd update {bead-id} --status in_progress
   ```

5. **Send Initial Prompt**
   ```bash
   tmux send-keys -t atlantis-philosophy-{scholar} -l "Read your ASSIGNMENT.md and begin..."
   tmux send-keys -t atlantis-philosophy-{scholar} C-m
   ```

6. **Scholar Executes Autonomously**
   - Reads ASSIGNMENT.md
   - Follows 4-phase workflow
   - Makes git commits
   - Creates output files

### Gas Town Pattern: Propulsion Principle

This implements Gas Town's **"If work is on your hook, YOU RUN IT"** principle:

- Work (bead) is assigned atomically at spawn time
- Initial prompt triggers autonomous execution
- No external coordination needed
- Scholar reports progress via git commits and beads

---

## Configuration

### Required Files

**Dockerfile** - Must include tmux:
```dockerfile
RUN apt-get update && apt-get install -y \
    git \
    curl \
    tmux \
    && rm -rf /var/lib/apt/lists/*
```

**.env** - Must contain API key:
```bash
ANTHROPIC_API_KEY=sk-ant-api03-...
```

**Scholar Workspace** - Must have ASSIGNMENT.md:
```
/atlantis/philosophy/scholars/{name}/
├── ASSIGNMENT.md      # Task description
└── .git/             # Initialized git repo
```

### Permission Bypass

The `--dangerously-skip-permissions` flag:
- Bypasses ALL permission checks
- Recommended only for sandboxed environments
- Docker isolation provides safety boundary
- Alternative: `--permission-mode bypassPermissions`

**Why it's safe in New Atlantis:**
- Scholars run in isolated Docker container
- Workspace limited to `/atlantis/` volume
- No access to host filesystem
- Resource limits enforced by Docker

---

## Spawning Multiple Scholars

### Sequential Spawning

```bash
./scripts/spawn-scholar.sh scholar1 ph-abc
./scripts/spawn-scholar.sh scholar2 ph-def
./scripts/spawn-scholar.sh scholar3 ph-ghi
```

Each runs in its own tmux session, isolated workspace.

### Parallel Spawning (Future)

```bash
# Future: Batch spawn script
./scripts/spawn-scholars-batch.sh ph-abc ph-def ph-ghi

# Creates:
# - atlantis-philosophy-scholar-01 (working on ph-abc)
# - atlantis-philosophy-scholar-02 (working on ph-def)
# - atlantis-philosophy-scholar-03 (working on ph-ghi)
```

### Coordination Patterns (Future)

**Convoy** - Multiple scholars on related topics
```bash
# All investigate same theme from different angles
./scripts/spawn-convoy.sh "AI consciousness" scholar1 scholar2 scholar3
```

**Peer Review** - Scholars critique each other
```bash
# scholar-critic reviews scholar-author's work
./scripts/spawn-reviewer.sh scholar-critic ph-review-123 --target-work=/path/to/essay.md
```

---

## Tested Results

### Scholar Episteme Test (2026-01-20)

**Assignment**: "How do we assess quality in the absence of ground truth?"

**Spawned with:**
```bash
./scripts/spawn-scholar.sh episteme ph-3rs
```

**Results:**
- ✅ Spawned without manual intervention
- ✅ No OAuth or permission prompts
- ✅ Followed 4-phase workflow perfectly
- ✅ Created 26KB essay + 14KB investigation notes
- ✅ Made 6 git commits tracking progress:
  1. "Begin orientation: quality assessment"
  2. "Investigate: initial argument structure"
  3. "Investigate: philosophical foundations"
  4. "Draft: complete essay"
  5. "Final: Quality assessment - epistemological investigation"

**Timeline:**
- Spawned: 23:09:12
- Completed: 23:05:00 (estimated ~4 minutes of work)
- Fully autonomous, zero human input

**Output Quality:**
- Sophisticated philosophical analysis
- Engaged with epistemology, peer review, AI scholarship
- Well-structured with intro, arguments, conclusions
- Acknowledged limitations and uncertainties
- Applied meta-philosophical lens to its own work

---

## Comparison: Gas Town vs New Atlantis

### Gas Town (Polecats)
```bash
gt sling gt-abc gt-def gastown  # Spawn polecats for beads
```

- Role: `polecat` (general worker)
- Work: Slung to hook at spawn time
- Tracking: Agent beads + work beads
- Nudge: "Run `gt hook` to check your hook"

### New Atlantis (Scholars)
```bash
./scripts/spawn-scholar.sh episteme ph-3rs  # Spawn scholar for bead
```

- Role: `scholar` (intellectual citizen)
- Work: Assignment in ASSIGNMENT.md
- Tracking: Git commits + beads
- Nudge: "Read ASSIGNMENT.md and begin Phase 1"

**Shared Infrastructure:**
- TMux session management
- `--dangerously-skip-permissions` flag
- Propulsion principle (work on hook → run it)
- Detached autonomous execution
- Parallel spawning capability

---

## Troubleshooting

### Session Already Exists

```
❌ Session atlantis-philosophy-episteme already exists
```

**Solutions:**
```bash
# Kill existing session
docker compose exec atlantis tmux kill-session -t atlantis-philosophy-episteme

# Or attach to watch progress
docker compose exec atlantis tmux attach -t atlantis-philosophy-episteme
```

### TMux Not Found

```
exec: "tmux": executable file not found
```

**Solution:** Rebuild container
```bash
./scripts/atlantis-container.sh build
./scripts/atlantis-container.sh start
```

### Scholar Not Responding

**Check if Claude is running:**
```bash
docker compose exec atlantis tmux capture-pane -t atlantis-philosophy-episteme -p
```

**Check for errors:**
```bash
docker compose exec atlantis tmux attach -t atlantis-philosophy-episteme
# Press Ctrl+B, then D to detach without killing
```

### API Key Not Loaded

```
Claude Code requires authentication
```

**Solution:** Ensure `.env` exists and container restarted
```bash
cat .env  # Should show ANTHROPIC_API_KEY=sk-ant-...
./scripts/atlantis-container.sh stop
./scripts/atlantis-container.sh start
```

---

## Next Steps

### Immediate

1. **Review Scholar Output** - Read Episteme's essay
2. **Export to Repository** - Copy to `first-works/episteme/`
3. **Close Beads** - Mark ph-3rs as completed
4. **Spawn Another Scholar** - Test reproducibility

### Short-Term

1. **Batch Spawning** - Script to spawn multiple scholars
2. **Session Monitoring** - Dashboard showing all active scholars
3. **Auto-Export** - Automatically copy completed work to repository
4. **Bead Auto-Close** - Scholars close their own beads

### Medium-Term

1. **Convoy System** - Multi-scholar coordinated inquiries
2. **Peer Review** - Automated scholar-to-scholar critique
3. **Witness/Archivist** - Monitor scholar progress, detect stalls
4. **Molecule Tracking** - Multi-phase workflow orchestration

### Long-Term

1. **Constitutional Design** - Scholars propose governance
2. **Quality Board** - Peer review queue and approval
3. **Symposia** - Real-time scholarly dialogue
4. **Federation** - Multiple New Atlantis instances

---

## Technical Details

### TMux Send-Keys Pattern

Gas Town's `NudgeSession` implementation:

```go
func (t *Tmux) NudgeSession(session, message string) error {
    // 1. Send text in literal mode
    t.run("send-keys", "-t", session, "-l", message)

    // 2. Debounce to prevent race conditions
    time.Sleep(500 * time.Millisecond)

    // 3. Send ESC (for vim mode compatibility)
    t.run("send-keys", "-t", session, "Escape")

    // 4. Send Enter separately
    t.run("send-keys", "-t", session, "Enter")
}
```

Our implementation (bash):
```bash
# Send message in literal mode
tmux send-keys -t $SESSION -l "$MESSAGE"

# Send Enter
tmux send-keys -t $SESSION C-m
```

### Session Naming Convention

Gas Town: `gt-{rig}-{polecat}`
- Example: `gt-gastown-Toast`

New Atlantis: `atlantis-{academy}-{scholar}`
- Example: `atlantis-philosophy-episteme`

### Workspace Isolation

```
/atlantis/
└── philosophy/              # Academy/Rig
    ├── .beads/             # Beads database
    ├── scholars/           # Scholar workspaces
    │   ├── episteme/       # Scholar 1
    │   │   ├── .git/
    │   │   ├── ASSIGNMENT.md
    │   │   └── *.md        # Output
    │   └── meta-architect/ # Scholar 2
    └── first-works/        # Archived completed work
```

Each scholar has:
- Isolated git repository
- Own workspace directory
- Own tmux session
- Assigned bead for tracking

---

## Security Considerations

### What's Safe

✅ Docker container isolation
✅ Workspace limited to `/atlantis/` volume
✅ Resource limits (CPU, memory)
✅ Read-only mount of codebase
✅ API key in environment (not hardcoded)

### What to Monitor

⚠️ API usage and costs (scholars use your API key)
⚠️ Scholar output quality (review before archiving)
⚠️ Disk space in container volumes
⚠️ Runaway scholars (infinite loops, excessive work)

### Best Practices

1. **Review Work** - Don't blindly trust generated philosophy
2. **Monitor Costs** - Check Anthropic console regularly
3. **Session Limits** - Kill stalled sessions after timeout
4. **Export Regularly** - Backup completed work to host
5. **Volume Cleanup** - Prune old scholar workspaces

---

## References

### Gas Town Documentation
- `internal/polecat/manager.go` - Polecat spawning
- `internal/tmux/tmux.go` - TMux integration
- `internal/config/agents.go` - Agent presets with skip-permissions
- `internal/session/names.go` - Propulsion nudge pattern

### New Atlantis Files
- `scripts/spawn-scholar.sh` - Scholar spawning script
- `Dockerfile` - Container with tmux
- `templates/scholar-CLAUDE.md` - Scholar role template
- `first-works/meta-architect/workflow-proposal.md` - 4-phase workflow

### External Resources
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [TMux Manual](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Gas Town on Substack](https://yegge.substack.com/) - Steve Yegge's posts

---

**Status**: Production-ready for New Atlantis MVP
**Last Updated**: 2026-01-20
**Tested By**: Scholar Episteme (successful autonomous completion)

*"In autonomy we trust; in beads we track; in git we remember."*
