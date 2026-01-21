# Review Queue - Quick Start Guide

## Overview

The review queue manages peer review of scholarly work using Gas Town's merge queue pattern adapted for intellectual discourse.

## Basic Workflow

### 1. Scholar Completes Work

```bash
# Scholar writes essay, commits, ready for review
cd /atlantis/philosophy/scholars/episteme
git add essay-quality-assessment.md
git commit -m "Essay: Quality assessment without ground truth"
```

### 2. Submit for Review

```bash
# Create review request bead
./scripts/review-queue.sh submit ph-3rs \
  scholars/episteme/essay-quality-assessment.md \
  episteme

# Output: Review request created: ph-7zj
```

### 3. List Pending Reviews

```bash
./scripts/review-queue.sh list

# Output:
# ○ ph-7zj [● P2] [task] [pending-review review-request] - Review: episteme work (ph-3rs)
```

### 4. Assign to Critic

```bash
# Assign review to a critic (creates workspace and assignment)
./scripts/review-queue.sh assign ph-7zj critic-alpha

# Then spawn the critic
docker compose exec atlantis /tmp/spawn-critic.sh critic-alpha ph-3rs

# Attach to accept bypass consent
docker compose exec atlantis tmux attach -t atlantis-critic-critic-alpha
# (Down arrow, Enter, Enter, then Ctrl+B D to detach)
```

### 5. Monitor Critic Progress

```bash
# Attach to watch
docker compose exec atlantis tmux attach -t atlantis-critic-critic-alpha

# Check workspace
./scripts/atlantis-container.sh exec "ls -la /atlantis/philosophy/critics/critic-alpha/"

# View review (when complete)
./scripts/atlantis-container.sh exec "cat /atlantis/philosophy/critics/critic-alpha/REVIEW-*.md"
```

### 6. Complete Review

```bash
# After reading the critic's review, mark it complete
./scripts/review-queue.sh complete ph-7zj APPROVE
# or: REVISE / REJECT
```

### 7. Archive Approved Work

```bash
# Archive to first-works
./scripts/review-queue.sh archive ph-3rs ph-7zj

# This:
# - Copies work to first-works/episteme/
# - Records in ledger (first-works/LEDGER.txt)
# - Closes review bead and work bead
```

## Commands Reference

```bash
# Submit work for review
./scripts/review-queue.sh submit <work-id> <work-path> <scholar>

# List pending reviews
./scripts/review-queue.sh list

# Assign review to critic
./scripts/review-queue.sh assign <review-id> <critic-name>

# Mark review complete with recommendation
./scripts/review-queue.sh complete <review-id> <APPROVE|REVISE|REJECT>

# Archive approved work
./scripts/review-queue.sh archive <work-id> <review-id>

# Show review details
./scripts/review-queue.sh show <review-id>

# Help
./scripts/review-queue.sh help
```

## Review Beads

Review requests are tracked as beads with labels:
- Type: `task`
- Labels: `review-request`, `pending-review` (before assignment)
- Labels: `review-request`, `in-review` (during review)
- Labels: `review-request`, `completed` (after review)

Query reviews:
```bash
# In container
cd /atlantis/philosophy
bd list --label=review-request --label=pending-review  # Pending
bd list --label=review-request --label=in-review       # In progress
bd list --label=review-request --label=completed       # Complete
```

## Ledger

All archival decisions are recorded in `first-works/LEDGER.txt`:

```
2026-01-21 ARCHIVED: episteme - essay-quality-assessment.md (Review: ph-7zj)
```

## Multiple Critics (Future)

To get convergent assessment, spawn multiple critics:

```bash
# Submit once
./scripts/review-queue.sh submit ph-3rs scholars/episteme/essay.md episteme

# Assign to multiple critics
./scripts/review-queue.sh assign ph-7zj critic-alpha
./scripts/review-queue.sh assign ph-7zj critic-beta
./scripts/review-queue.sh assign ph-7zj critic-gamma

# Spawn all
docker compose exec atlantis /tmp/spawn-critic.sh critic-alpha ph-3rs
docker compose exec atlantis /tmp/spawn-critic.sh critic-beta ph-3rs
docker compose exec atlantis /tmp/spawn-critic.sh critic-gamma ph-3rs

# Read all reviews, decide based on convergence
# - 3/3 APPROVE → Archive
# - 2/3 APPROVE → Archive with note
# - 1/3 or 0/3 → Revise or reject
```

## Troubleshooting

### Review bead not found
```bash
# Check it exists
./scripts/atlantis-container.sh exec "cd /atlantis/philosophy && bd show ph-7zj"
```

### Critic not responding
```bash
# Attach to session
docker compose exec atlantis tmux attach -t atlantis-critic-critic-alpha

# Check if it needs consent
# (Should show bypass permissions prompt if not yet accepted)
```

### Review file not created
```bash
# Check critic workspace
./scripts/atlantis-container.sh exec "ls -la /atlantis/philosophy/critics/critic-alpha/"

# Check tmux session
docker compose exec atlantis tmux capture-pane -t atlantis-critic-critic-alpha -p | tail -50
```

## Tips

- **One review per critic instance**: Each critic spawned reviews exactly one work
- **Manual for now**: This is a minimal manual workflow; automation comes next
- **Track in beads**: All reviews tracked as beads for visibility
- **Ledger is canonical**: `first-works/LEDGER.txt` is the permanent record

## Next: Automation

Future improvements:
- Archivist patrol (auto-processes review queue)
- Auto-spawn critics when reviews submitted
- Convergence logic (multiple critic agreement)
- Auto-archive on approval
