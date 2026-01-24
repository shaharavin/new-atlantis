# Spawn Script Architecture: Host vs Container

**Issue discovered**: 2026-01-23, Symposium #2
**Problem**: Monitoring and nudging infrastructure can't see scholars

---

## The Problem

During Symposium #2, the Convener successfully spawned scholars and they wrote essays, but:
- ❌ No tmux sessions visible to monitoring tools
- ❌ Nudger can't detect or nudge scholars
- ❌ Host-side tools (monitor-agents.sh, list-sessions.sh) see nothing
- ✅ Scholars ARE working (essays written, git commits made)

**Root cause**: Architectural mismatch between where scripts run and where they're designed to run.

---

## Architecture Overview

### Host-Side Scripts (`scripts/spawn-*.sh`)
**Location**: Run from host machine (macOS, Linux, etc.)
**Pattern**: Use `docker compose exec atlantis` to run commands in container
**Example**:
```bash
# Host script pattern
docker compose exec atlantis tmux new-session -d -s atlantis-philosophy-rawls
docker compose exec atlantis tmux send-keys -t atlantis-philosophy-rawls "claude ..." C-m
```

**Designed for**: Human operators running from terminal

### Container-Side Scripts (`scripts/container/spawn-*.sh`)
**Location**: Run from inside container (by Convener, other agents)
**Pattern**: Direct tmux/shell commands (already inside container)
**Example**:
```bash
# Container script pattern
tmux new-session -d -s atlantis-philosophy-rawls
tmux send-keys -t atlantis-philosophy-rawls "claude ..." C-m
```

**Designed for**: Autonomous agents (Convener) running inside container

---

## What Happened in Symposium #2

1. **Convener spawned** from host → runs inside container
2. **Convener tried** to use `scripts/spawn-multiple-scholars.sh`
3. **Script attempted** `docker compose exec` from inside container
4. **Docker commands failed** (no docker socket access)
5. **Convener adapted** by creating files directly, spawning Claude processes
6. **Result**: Scholars work, but not in trackable tmux sessions

**Evidence**:
- Scholar directories exist: `/atlantis/philosophy/scholars/{rawls,aristotle,foucault}/`
- Essays written: 5,201 + 5,126 + 5,454 = 15,781 words total
- Git commits exist: "Add constitutional foundations essay..."
- No tmux sessions: `tmux ls` shows only convener, nudger, monitor
- Claude processes running: `ps aux | grep claude` shows 3 processes

---

## Solution: Dual Script Architecture

### For Host Operators (Humans)
Use existing scripts in `scripts/`:
- `spawn-multiple-scholars.sh`
- `spawn-critic.sh`
- `spawn-convener.sh`
- `spawn-nudger.sh`

### For Container Agents (Convener, etc.)
Use new scripts in `scripts/container/`:
- `spawn-scholar.sh` - Spawn single scholar (container-native)
- `spawn-critic.sh` - Spawn single critic (container-native)
- More to be added as needed

---

## Container Script Design Principles

1. **No docker compose calls**: Scripts run inside container, no need to exec in
2. **Direct tmux commands**: `tmux new-session`, not `docker compose exec atlantis tmux`
3. **Named sessions**: Use same naming convention as host scripts
4. **Bypass permissions**: Use `--permission-mode bypassPermissions` for autonomy
5. **Mail completion**: Remind scholars/critics to mail Convener when done

---

## Convener Template Update Needed

The Convener template should be updated to use container-side scripts:

**Current (broken)**:
```bash
# Convener tries to run host script from inside container
./scripts/spawn-multiple-scholars.sh "Topic" symposium-id scholar1:tradition1 ...
```

**Fixed**:
```bash
# Convener uses container-native script
for scholar in scholar1 scholar2 scholar3; do
    /atlantis/philosophy/scripts/container/spawn-scholar.sh \
        "$scholar" \
        "Topic Title" \
        "/tmp/tradition-$scholar.md"
done
```

---

## Monitoring Implications

**With container-native spawning**:
- ✅ Scholars appear in `tmux ls`
- ✅ `scripts/monitor-agents.sh scholar` works
- ✅ Nudger can detect and nudge scholars
- ✅ `scripts/list-sessions.sh` shows all agents
- ✅ Git activity visible to monitoring tools

**Without it** (current Symposium #2):
- ❌ Invisible to monitoring infrastructure
- ❌ Nudger can't help stalled scholars
- ❌ Manual checking required: `find /atlantis/philosophy/scholars -name "*.md"`

---

## Migration Plan

**For Symposium #2** (active now):
- Let it complete as-is (scholars are working)
- Monitor manually via git logs and file checks
- Document learnings

**For Symposium #3**:
1. Create full suite of container-native spawn scripts
2. Update Convener template to use container scripts
3. Test that monitoring tools see spawned agents
4. Verify Nudger can detect and nudge

**Scripts to create**:
- [x] `scripts/container/spawn-scholar.sh`
- [ ] `scripts/container/spawn-critic.sh`
- [ ] `scripts/container/spawn-multiple-scholars.sh` (wrapper)
- [ ] `scripts/container/spawn-multiple-critics.sh` (wrapper)

---

## Testing Checklist (Symposium #3)

Before spawning scholars:
- [ ] Container spawn scripts exist in `/atlantis/philosophy/scripts/container/`
- [ ] Scripts are executable (`chmod +x`)
- [ ] Convener template references container scripts, not host scripts

After spawning scholars:
- [ ] Run `tmux ls` - should see `atlantis-philosophy-<name>` sessions
- [ ] Run `scripts/monitor-agents.sh scholar` - should show split view
- [ ] Check Nudger can see sessions: `scripts/list-sessions.sh`
- [ ] Verify git activity visible: `git log --oneline`

---

## Key Insight

**Gas Town pattern**: Mayor runs scripts from host (has docker access)
**New Atlantis pattern**: Convener runs inside container (needs container-native scripts)

This is a fundamental architectural difference. New Atlantis agents are more autonomous (running persistently in container) vs. Gas Town's coordination from outside.

**Trade-off**:
- ✅ **Autonomy**: Convener can spawn agents without human intervention
- ⚠️ **Complexity**: Need dual script architecture (host + container versions)
- ✅ **Monitoring**: Container-native scripts create trackable sessions

---

**Status**: Issue identified, solution designed, implementation in progress
**Next**: Complete container script suite and update Convener template for Symposium #3
