# Infrastructure Diagnosis: Drift from Gas Town Patterns

**Date**: 2026-01-27
**Session**: Founder + Shahar infrastructure review
**Status**: Diagnosis complete, roadmap for course correction

---

## Summary

New Atlantis has drifted from Gas Town's beads-centric architecture. We designed a beads-based system (documented in `SYMPOSIUM-MOLECULE.md`) but implemented a parallel filesystem-based system instead. This drift has made the Convener unnecessarily complex and fragile.

**Root cause**: At some point, the container-native spawn scripts were created without beads integration, and state tracking shifted to filesystem artifacts (`.completions/`, `.current-phase` files, mail signals) rather than bead status.

**Impact**: The Convener must do work that Gas Town's `gt` CLI and beads would handle automatically:
- Manual phase tracking via text files
- Custom completion detection via `.done` marker files
- Background bash monitor scripts (fragile)
- Procedural phase transition logic

---

## Evidence of Drift

### What We Designed (SYMPOSIUM-MOLECULE.md)

```
symposium: ph-symp-01 (parent bead)
├── topic: "Incentivizing Productivity in Autonomous Polities"
├── phase: independent-work → ... → complete (bead field)
│
├── independent-work (sub-molecule)
│   ├── scholar-solon: ph-x7k → essay (bead)
│   ├── scholar-pericles: ph-u97 → essay (bead)
│   └── scholar-locke: ph-3ax → essay (bead)
│
├── independent-review (sub-molecule)
│   ├── critic-alpha: ph-rev-01, ph-rev-02, ph-rev-03 (beads)
│   ...
```

### What We Actually Implemented

```
symposium-governance-2026-01/
├── .current-phase          # Text file: "phase-6-synthesis"
├── .scholars               # Text file: "solon\npericles\nlocke"
├── .critics                # Text file: "delta\nepsilon\nzeta"
├── .completions/           # Directory of marker files
│   ├── scholar-solon.done      # Empty file = completion signal
│   ├── critic-delta.done
│   └── ...
├── phase-1-independent-work/
│   └── [essays as files, no bead IDs]
```

### Comparison Table

| Aspect | Designed (Beads) | Implemented (Filesystem) |
|--------|------------------|--------------------------|
| Symposium identity | Parent bead `ph-symp-01` | Directory name |
| Phase tracking | Bead field `phase: X` | `.current-phase` text file |
| Scholar list | Bead field `scholars: [...]` | `.scholars` text file |
| Work items | Child beads with IDs | Files in directories |
| Completion signal | `bd close <bead-id>` | Create `.done` marker file |
| Status query | `bd list --status open` | `ls .completions/` + count |
| Phase transition | Molecule step progression | Convener procedural logic |

### Container Scripts Have No Beads

The host-side scripts use beads:
```bash
# scripts/spawn-scholar.sh (host-side)
bd update $BEAD_ID --status in_progress
```

But container-native scripts don't:
```bash
# scripts/container/spawn-scholar.sh
# Zero bd commands - all filesystem-based
```

---

## Impact on Convener Complexity

The Convener template is **1,030 lines** because it reimplements what `gt`/`bd` would provide:

| Convener Responsibility | Lines | Gas Town Equivalent |
|------------------------|-------|---------------------|
| Track phase completion | ~50 | `bd list --status closed` |
| Parse metadata files | ~40 | Bead field queries |
| Phase transition logic | ~100 | Molecule step progression |
| Background monitor scripts | ~50 | `gt` daemon / witness |
| Spawn agent coordination | ~200 | `gt sling` |
| Mail processing | ~50 | `gt mail` / hooks |

**With beads**: Convener queries bead status, molecule handles transitions.
**Without beads**: Convener must implement all this logic manually.

---

## Why This Matters

1. **Fragility**: Bash monitor scripts can fail silently; beads are persistent
2. **Complexity**: 1000+ line Convener vs. simple phase-checking
3. **Inconsistency**: Some scripts use beads, others don't
4. **Lost features**: We're not using molecules, hooks, convoys, slinging
5. **Debugging**: Filesystem state is harder to query than `bd list`

---

## Roadmap: Course Correction

### Phase 1: Beads in Container (Immediate)

**Goal**: Make `bd` available inside the container

**Status**: ✅ COMPLETE (2026-01-27)

Tasks:
- [x] Install beads CLI in Docker container (was already installed!)
- [x] Verify `bd` commands work in container
- [x] Fix repo ID mismatch with `bd migrate --update-repo-id`
- [x] Test basic operations: `bd create`, `bd update`, `bd list`, `bd close`

**Notes**: Beads was already installed in the Dockerfile (line 27-28). The issue was a repo ID mismatch from earlier work. Fixed with migration command. `bd` version 0.47.1 confirmed working.

### Phase 2: Bead-Based Symposium Tracking (Short-term)

**Goal**: Track symposia and work items as beads, not files

**Status**: ✅ MOSTLY COMPLETE (2026-01-27)

Tasks:
- [x] Update `spawn-scholar.sh` to create work beads and use `bd close`
- [x] Update `spawn-critic.sh` to create review beads and use `bd close`
- [x] Update `spawn-opposition.sh` to create opposition beads and use `bd close`
- [x] Fix bead ID parsing for parent-child relationships (IDs like `ph-abc.1`)
- [x] Dry-run tested: parent-child linking works correctly
- [ ] Create symposium as parent bead when activated (Convener's job)
- [ ] Keep `.current-phase` for human readability (beads are source of truth)

**Notes**: Spawn scripts now create child beads linked to symposium parent. Convener uses `bd show SYMPOSIUM_BEAD` to see children with status indicators (✓ closed, ◐ in_progress).

### Phase 3: Slim the Convener (Short-term)

**Goal**: Convener queries beads instead of managing filesystem state

**Status**: ✅ SKILL UPDATED (2026-01-27)

Tasks:
- [x] Update `/convener-role` skill to use bead queries instead of `.completions/`
- [x] Remove background monitor script instructions (beads persist state)
- [x] Simplify patrol cycle to just query beads
- [x] Clarify `bd show SYMPOSIUM_BEAD` as best completion check method
- [x] Slim `templates/convener-CLAUDE.md` to 5-line redirect
- [ ] Test with a real symposium (next symposium will be first beads-native)

**Notes**: Template now just says "run /convener-role" - no context waste.

### Phase 4: Evaluate Gas Town's `gt` CLI (Medium-term)

**Goal**: Determine if we should use/adapt `gt` for New Atlantis

**Status**: 🔄 PARTIAL PROGRESS (2026-01-27)

**Findings**:
- `bd mol` commands work without `gt` installed
- Created working `.beads/formulas/symposium.formula.toml`
- `bd --no-daemon mol pour symposium --dry-run` creates all 10 phase beads
- `gt` would add: sling (work dispatch), hooks (agent queues), handoff

**Quick wins achieved**:
- [x] Symposium formula created and validated
- [x] `bd cook`, `bd mol pour`, `bd mol current` available in container

**Would need `gt` for**:
- `gt sling` - work dispatch (we use spawn scripts instead)
- `gt hook` - agent work queues (we use ASSIGNMENT.md)
- `gt handoff` - session refresh with context

Tasks:
- [x] Map Symposium Molecule to `bd` formula format
- [x] Test `bd mol pour` - creates 11 beads (1 parent + 10 phases)
- [ ] Install `gt` in container (requires Go, bigger change)
- [ ] Decide: use spawn scripts + bd mol, or adopt full gt

### Phase 5: Full Gas Town Alignment (Long-term)

**Goal**: New Atlantis uses Gas Town patterns properly

Potential outcomes:
- Use `gt` for agent orchestration
- Symposium Molecule as a `gt` protomolecule
- Convener becomes thin coordinator (like Mayor)
- Agents work via hooks (GUPP: "if work on hook, run it")

---

## Key Gas Town Concepts We Should Adopt

### 1. GUPP (Gas Town Universal Propulsion Principle)
> "If there is work on your Hook, YOU MUST RUN IT."

Agents don't wait for instructions - they check their hook and act.

### 2. Molecules
Durable multi-step workflows where each step is a bead. The molecule defines the workflow; `gt` handles progression.

### 3. Hooks
Each agent has a persistent work queue (their "hook"). Work is assigned via `gt sling`, not custom spawn scripts.

### 4. Beads as Source of Truth
Work state lives in beads, not filesystem artifacts. Queries are `bd list`, not `ls .completions/`.

### 5. NDI (Nondeterministic Idempotence)
Orchestration ensures completion even when individual operations fail. Beads persist across agent restarts.

---

## Files to Modify

### High Priority
- `Dockerfile` - Install `bd` CLI
- `scripts/container/spawn-scholar.sh` - Add bead operations
- `scripts/container/spawn-critic.sh` - Add bead operations
- `templates/convener-CLAUDE.md` - Simplify with bead queries
- `.claude/skills/convener-role/SKILL.md` - Update for beads

### Medium Priority
- `scripts/activate-symposium.sh` - Create parent bead
- `docs/SYMPOSIUM-MOLECULE.md` - Mark as canonical design
- `templates/scholar-CLAUDE.md` - Completion via `bd close`
- `templates/critic-CLAUDE.md` - Completion via `bd close`

### Low Priority (Phase 4+)
- Evaluate `gt` CLI adoption
- Potential `gt` protomolecule for symposia

---

## Success Criteria

1. **`bd` works in container**: Can run `bd list` inside Docker
2. **Symposium tracked as bead**: Parent bead with phase field
3. **Work items are beads**: Each essay/review has a bead ID
4. **Completion via beads**: `bd close` replaces `.done` files
5. **Convener simplified**: Template under 400 lines
6. **No custom state files**: Remove `.completions/`, `.current-phase`

---

## References

- `docs/SYMPOSIUM-MOLECULE.md` - Our beads-centric design (follow this!)
- Gas Town README: https://github.com/steveyegge/gastown
- Gas Town glossary: Molecules, Hooks, GUPP, NDI
- `internal/beads/molecule.go` - Gas Town molecule implementation

---

## Session Notes

This diagnosis emerged from reviewing:
1. `NEXT-STEPS.md` - Current project state
2. `AUTOMATION-ACHIEVEMENTS.md` - What we built
3. `templates/convener-CLAUDE.md` - 1030 lines of complexity
4. `scripts/container/*.sh` - No bead integration
5. Gas Town's `origin-gastown` remote - What we're missing
6. `docs/SYMPOSIUM-MOLECULE.md` - What we designed but didn't implement

The drift was not intentional - it happened gradually as container-native infrastructure was built without following the beads-centric design we documented.

**Key insight**: We have a beautiful design doc that describes exactly what we should build. We just need to actually build it.

---

*Document created for continuity across Founder sessions.*
