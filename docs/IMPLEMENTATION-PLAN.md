# Implementation Plan: Closing the Gaps

**Date**: 2026-01-28
**Status**: Active — tracks work needed to align implementation with `ARCHITECTURE.md`
**Companion to**: `docs/ARCHITECTURE.md`

---

## Summary

Three symposia have run, but all used filesystem-based state management (`.completions/`, `.current-phase`). The architecture calls for beads as source of truth, formula-driven workflows, and autonomous Convener phase transitions. This plan closes the gap between what's documented and what actually works.

---

## Work Items

### WI-1: Convener Autonomous Phase Transitions (Bead-Based Polling)

**Status**: IMPLEMENTED (2026-01-28) — needs live testing
**Priority**: Critical — blocking next symposium
**Depends on**: Nothing

**Problem**: The Convener spawns agents for Phase 1 then sits idle. No mechanism wakes it when a phase completes. Previous approach (Convener loops with `sleep 300`) doesn't survive conversation turn boundaries. The slimmed-down `/convener-role` skill says "just query beads" but doesn't explain how or when.

**Solution**: Hybrid approach — background bash polling script + Convener editorial control.

After spawning agents for a phase, the Convener creates and launches a background monitor script:

```bash
#!/bin/bash
# monitor-phase.sh — polls bead status, nudges Convener when phase complete
# Created by Convener at the start of each phase

SYMPOSIUM_BEAD="$1"
PHASE_NAME="$2"
EXPECTED_COUNT="$3"  # How many child beads should close for this phase
CONVENER_SESSION="atlantis-convener"

while true; do
    sleep 120  # Check every 2 minutes

    cd /atlantis/philosophy

    # Count closed children of the symposium bead
    CLOSED=$(bd show "$SYMPOSIUM_BEAD" 2>/dev/null | grep -c "✓" || echo 0)

    if [ "$CLOSED" -ge "$EXPECTED_COUNT" ]; then
        # Mail the Convener
        export ATLANTIS_AGENT_NAME=monitor
        atlantis-mail send convener "PHASE_COMPLETE $PHASE_NAME" \
            "All $EXPECTED_COUNT beads closed for $PHASE_NAME. Ready to transition."

        # Nudge the Convener's tmux session to wake it up
        tmux send-keys -t "$CONVENER_SESSION" "" 2>/dev/null  # Empty string to trigger
        sleep 1
        tmux send-keys -t "$CONVENER_SESSION" -l \
            "Phase $PHASE_NAME is complete ($CLOSED/$EXPECTED_COUNT beads closed). Check your mail and transition to the next phase." 2>/dev/null
        sleep 1
        tmux send-keys -t "$CONVENER_SESSION" Enter 2>/dev/null

        exit 0  # Monitor's job is done
    fi
done
```

**Changes needed**:

1. **Update `/convener-role` skill** to include:
   - Instructions to create a `monitor-phase.sh` after spawning each phase's agents
   - Run it with `nohup ./monitor-phase.sh $SYMPOSIUM_BEAD "phase-N" $COUNT &`
   - What to do when woken up (check mail, verify bead status, transition)
   - How to count expected beads per phase (3 scholars for Phase 1, 3 critics for Phase 2, etc.)

2. **Update Convener ASSIGNMENT.md** (in `spawn-convener.sh`) to reference the monitor pattern

3. **Test**: Run a mini-workflow (2 phases, 1 agent each) to validate the wake-up mechanism

**Acceptance criteria**:
- [ ] Convener spawns agents, launches monitor script, then waits
- [ ] When all phase beads close, monitor mails + nudges Convener
- [ ] Convener wakes up, reads mail, transitions to next phase
- [ ] Works for at least 3 consecutive phase transitions

---

### WI-2: Bibliographer Phase and Spawn Script

**Status**: IMPLEMENTED (2026-01-28) — needs live testing
**Priority**: High
**Depends on**: Nothing (can be done in parallel with WI-1)

**Problem**: No container-side spawn script for the bibliographer. The bibliographer ran ad-hoc in Symposium #3 but isn't part of the formula.

**Solution**:

1. **Create `scripts/container/spawn-bibliographer.sh`**
   - Model: Haiku 3.5 (cost-efficient)
   - Input: Symposium directory (reads all essays, reviews, synthesis)
   - Output: Updated `philosophy-references.bib` + `bibliographer-report.md`
   - Creates a bead linked to symposium parent
   - Closes bead on completion

2. **Add a step to `symposium.formula.toml`**:
   ```toml
   [[steps]]
   id = "phase-10b"
   title = "Phase 10b: Bibliography"
   needs = ["phase-9"]
   description = """
   Bibliographer extracts and verifies citations from all symposium outputs.
   Updates philosophy-references.bib.
   """
   ```
   Note: This runs after the Convener report (phase-9) but can run in parallel with Recognition (phase-10). Alternatively, place it between phase-9 and phase-10 as a dependency. Either way, it runs before the archive phase (WI-3).

3. **Update `/convener-role` skill** to include bibliographer spawning in the phase transition table

**Acceptance criteria**:
- [ ] `spawn-bibliographer.sh` creates bead, spawns Haiku agent, agent closes bead
- [ ] Formula includes bibliography step
- [ ] Convener knows when to spawn the bibliographer

---

### WI-3: Archive Phase (Container-Side README) + Host-Side Cleanup Script

**Status**: IMPLEMENTED (2026-01-28) — needs live testing
**Priority**: High
**Depends on**: WI-2 (bibliography should complete before archiving)

**Problem**: The existing `archive-symposium.sh` creates a YAML manifest but doesn't copy outputs to host, generate a README, commit, or push. The README was written manually by the Convener or human in previous symposia.

**Solution**: Split archiving into two parts:

**Part A: Container-side archive step (Convener does this)**

Add a final step to the symposium formula:
```toml
[[steps]]
id = "phase-11"
title = "Phase 11: Archive"
needs = ["phase-10", "phase-10b"]
description = """
Convener generates README.md for the symposium archive.
"""
```

The Convener writes `README.md` in the symposium directory with:
- Symposium question and date
- Participants (scholars, critics, traditions) — from beads or metadata files
- Phase navigation links (auto-generated from directory listing)
- Key findings (extracted from synthesis)
- Statistics (word count, document count, cost estimate)
- Citation format

This is editorial work appropriate for the Convener (Sonnet), not a bash script.

**Part B: Host-side cleanup script**

Create `scripts/cleanup-symposium.sh` (new, replaces `archive-symposium.sh`):

```bash
./scripts/cleanup-symposium.sh <symposium-name>
```

Steps:
1. `docker compose cp` to copy symposium directory from container to `first-works/`
2. Kill tmux sessions (with confirmation)
3. `git add first-works/<name>/`
4. `git commit -m "Archive: Symposium <name>"`
5. `git push`

This script handles only mechanical tasks — no editorial judgment.

**Acceptance criteria**:
- [ ] Formula has an archive phase
- [ ] Convener generates README.md with links and summary
- [ ] `cleanup-symposium.sh` copies, commits, pushes in one command
- [ ] Old `archive-symposium.sh` deprecated or replaced

---

### WI-4: Public Essay Uses Convener

**Status**: IMPLEMENTED (2026-01-29) — needs live testing
**Priority**: Medium
**Depends on**: WI-1 (needs working Convener phase transitions)

**Problem**: `run-public-essay.sh` is a standalone orchestration script that pours the molecule and spawns a scholar, but doesn't transition between phases. The public-essay formula was designed to test beads-based workflows but ended up being a manual multi-step process.

**Solution**: The public-essay formula should be driven by the same Convener + monitor pattern as the symposium.

1. **Update `/convener-role` skill** to handle any formula, not just the symposium:
   - Convener reads the formula file to determine phases and dependencies
   - Phase transition logic is generic: "check bead status → spawn next phase agents"
   - Phase-specific spawning instructions come from the formula step descriptions
   - Add a section: "Handling Different Formulas" with examples for symposium and public-essay

2. **Update `spawn-convener.sh`** to accept a formula parameter:
   ```bash
   ./scripts/spawn-convener.sh <symposium-dir> [formula-name]
   # Default formula: symposium
   ```

3. **Create `scripts/container/spawn-copyeditor.sh`** (for the polish phase):
   - Similar to spawn-critic but with copyediting instructions
   - Model: Sonnet 4.5 (prose polish, not deep philosophy)

4. **Deprecate `scripts/container/run-public-essay.sh`** — replaced by Convener + formula

**Acceptance criteria**:
- [x] Convener can pour and execute the public-essay formula
- [ ] All 4 phases transition automatically (needs live testing)
- [x] Same monitoring pattern as symposium (monitor script + nudge)
- [x] `run-public-essay.sh` marked as deprecated

---

### WI-5: Remaining Gap Fixes

**Status**: MOSTLY DONE (2026-01-28)
**Priority**: Medium
**Depends on**: WI-1 through WI-4

These are smaller fixes identified in the gap analysis:

**5a. Synthesizer spawn script**

Create `scripts/container/spawn-synthesizer.sh`:
- Model: Opus 4.5
- Input: All scholar essays + reviews + revisions
- Output: Integrated synthesis essay
- Currently the Convener spawns this manually via raw tmux commands

**5b. `bd mol pour` integrated into Convener workflow**

Update Convener ASSIGNMENT.md and skill to:
- Pour the formula at the start (`bd mol pour symposium`)
- Use the generated step beads for tracking (instead of manually creating beads)
- Map formula step IDs to phase bead IDs

**5c. Fix `spawn-convener.sh` to use `Enter` instead of `C-m`**

Line 196 of `scripts/spawn-convener.sh` uses `C-m`. Change to:
```bash
sleep 1
tmux send-keys -t "$SESSION_NAME" Enter
```

**5d. Container-native `spawn-convener.sh`**

Create `scripts/container/spawn-convener.sh` for cases where the Founder agent (running inside the container) needs to spawn a Convener. Follows the same pattern as other container scripts.

**5e. Tradition examples file**

The Convener ASSIGNMENT.md references `tradition-examples.yml` — verify this file exists and is current. If not, create it from the tradition registry in `ARCHITECTURE.md`.

**Acceptance criteria**:
- [x] Synthesizer has a spawn script (`scripts/container/spawn-synthesizer.sh`)
- [ ] Convener uses `bd mol pour` to start a symposium (formula is read directly; `mol pour` integration deferred)
- [x] `C-m` → `Enter` fix applied in `spawn-convener.sh`
- [ ] Container-native convener spawn script exists (deferred — host-side script works)
- [ ] `tradition-examples.yml` exists and is accurate (deferred)

---

## Implementation Order

```
WI-1 (Convener polling)  ─────────────────────────────────────────┐
                                                                   │
WI-2 (Bibliographer)  ──── can be parallel with WI-1 ────────────┤
                                                                   │
WI-3 (Archive phase + cleanup script)  ── depends on WI-2 ───────┤
                                                                   │
WI-4 (Public essay via Convener)  ── depends on WI-1 ────────────┤
                                                                   │
WI-5 (Remaining fixes)  ── depends on WI-1 through WI-4 ─────────┘
```

**Recommended session plan**:
- Session 1: WI-1 (convener polling) + WI-2 (bibliographer) in parallel
- Session 2: WI-3 (archive) + WI-5a-5c (small fixes)
- Session 3: WI-4 (public essay rework) + WI-5d-5e
- Session 4: End-to-end test with a real symposium

---

## Validation: First Beads-Native Symposium

After all work items are complete, run a full symposium to validate:

1. Human + Founder select topic
2. Convener is spawned from host
3. Convener pours symposium formula (`bd mol pour symposium`)
4. Convener spawns Phase 1 scholars + monitor script
5. Monitor detects Phase 1 completion, nudges Convener
6. Convener transitions through all 10+ phases autonomously
7. Bibliographer runs, bibliography updated
8. Convener generates README
9. Human runs `cleanup-symposium.sh` — outputs appear on GitHub

If this works end-to-end with zero human intervention during phases 1-10, the architecture is validated.

---

*This plan is a living document. Update status fields as work progresses.*
*Companion to: `docs/ARCHITECTURE.md`*
