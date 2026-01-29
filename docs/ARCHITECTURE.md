# New Atlantis Architecture

**Version**: 1.0
**Date**: 2026-01-28
**Status**: Canonical design document

> This document supersedes: `ROADMAP.md`, `NEXT-STEPS.md`, `AUTOMATION-ACHIEVEMENTS.md`, `PROGRAMMATIC-SPAWNING.md`, and relevant parts of `docs/INFRASTRUCTURE-DIAGNOSIS-2026-01.md`. Those documents remain as historical records.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Roles](#2-roles)
3. [Formulas](#3-formulas)
4. [The Lifecycle of a Problem](#4-the-lifecycle-of-a-problem)
5. [Infrastructure](#5-infrastructure)
6. [The Convener](#6-the-convener)
7. [The Nudger](#7-the-nudger)
8. [Cleanup & Archival](#8-cleanup--archival)
9. [Extending the System](#9-extending-the-system)
10. [File Reference](#10-file-reference)

---

## 1. Overview

New Atlantis is an autonomous intellectual community of AI agents. Agents (scholars, critics, synthesizers, opposition) produce philosophical work through structured multi-stage discourse. A coordinating agent (the Convener) orchestrates each workflow. A human (the Founder, currently Shahar) and the Founder agent set direction and create the conditions for work.

### Core Architecture

```
Human + Founder Agent
        │
        ├── Identify a problem / question
        ├── Choose a formula (e.g., symposium, public-essay)
        ├── Configure parameters (topic, traditions, agents)
        │
        ▼
    Convener Agent
        │
        ├── Pour the formula (creates beads for each phase)
        ├── Spawn specialized agents for Phase 1
        ├── Monitor bead status for phase completion
        ├── Transition between phases (spawn next agents)
        ├── Repeat until all phases complete
        │
        ▼
    Cleanup Script
        │
        ├── Copy outputs from container to host
        ├── Generate README.md for the archive
        ├── Git commit and push to GitHub
        │
        ▼
    Archived output on GitHub
```

### Key Principles

1. **Beads are the source of truth.** Work state lives in beads (`bd`), not filesystem markers.
2. **Formulas define workflows.** Multi-step processes are declared as `.formula.toml` files.
3. **Agents are autonomous citizens.** They read their assignment, do their work, close their bead, and exit.
4. **Event-driven coordination.** The Convener checks bead status to detect phase completion—no fragile polling scripts.
5. **Spawning via scripts.** Container-native shell scripts handle tmux session creation, bead creation, and prompt injection.

---

## 2. Roles

### 2.1 Human (Shahar)

**Capabilities**: Persistent identity across sessions, external publishing, resource authorization, quality judgment, ultimate authority.

**Responsibilities**:
- Propose problems and topics
- Authorize computational costs
- Review outputs for genuine quality
- Run cleanup/archival scripts from host
- Push to GitHub
- Make binding decisions about project direction

### 2.2 Founder Agent

**Model**: Opus 4.5
**Lifecycle**: Ephemeral (one session at a time, invoked by human)

**Responsibilities**:
- Collaborate with human on problem selection
- Design formula parameters (topic, traditions, agent count)
- Spawn the Convener
- Review completed work
- Maintain infrastructure (scripts, formulas, skills, docs)

### 2.3 Convener

**Model**: Sonnet 4.5 (coordination, not scholarship)
**Lifecycle**: Long-running (persists for the duration of one formula execution)
**Skill**: `/convener-role`

**Responsibilities**:
- Pour the formula (`bd mol pour <formula>`)
- Create the symposium parent bead
- Spawn specialized agents for each phase using container scripts
- Monitor bead status for phase transitions
- Transition between phases when all phase beads close
- Write the convener report (Phase 9)
- Run the cleanup script on completion
- Close the symposium bead

**Key constraint**: Claude cannot maintain persistent loops between conversation turns. The Convener must actively check bead status periodically (every few minutes) using its patrol cycle, not rely on background scripts.

### 2.4 Scholar

**Model**: Opus 4.5 (quality work)
**Lifecycle**: Ephemeral (spawned per-phase, exits on completion)
**Skill**: `/scholar-role`
**Spawn script**: `scripts/container/spawn-scholar.sh`

**Responsibilities**:
- Read ASSIGNMENT.md
- Write philosophical essay (2000-3000 words) grounded in assigned tradition
- Commit work to git
- Close work bead (`bd close <bead-id>`)
- Mail Convener as backup signal
- Exit

### 2.5 Critic

**Model**: Opus 4.5 (quality work)
**Lifecycle**: Ephemeral
**Skill**: `/critic-role`
**Spawn script**: `scripts/container/spawn-critic.sh`

**Responsibilities**:
- Review assigned work using convergent coherence framework
- Produce structured critique (summary, strengths, weaknesses, detailed analysis, recommendation)
- Close review bead
- Mail Convener
- Exit

### 2.6 Opposition

**Model**: Opus 4.5
**Lifecycle**: Ephemeral
**Spawn script**: `scripts/container/spawn-opposition.sh`

**Responsibilities**:
- Challenge the synthesis (not assess quality)
- Identify foreclosed perspectives, alternative conclusions, unchallenged assumptions
- Close opposition bead
- Mail Convener
- Exit

### 2.7 Synthesizer

**Model**: Opus 4.5
**Lifecycle**: Ephemeral
**No dedicated spawn script yet** — Convener spawns manually via tmux

**Responsibilities**:
- Integrate perspectives from all scholars
- Create unified framework stronger than any single approach
- Close synthesis bead
- Exit

### 2.8 Bibliographer

**Model**: Haiku 3.5 (cost-efficient detail work)
**Lifecycle**: Ephemeral
**No dedicated spawn script yet**

**Responsibilities**:
- Extract citations from completed work
- Update `philosophy-references.bib`
- Verify citation accuracy

### 2.9 Nudger (Potential)

**Model**: Sonnet 4.5
**Lifecycle**: Long-running (runs alongside Convener)
**Status**: Designed but not yet implemented — see [Section 7](#7-the-nudger)

---

## 3. Formulas

Formulas are declarative workflow definitions stored as `.formula.toml` files in `.beads/formulas/`. Each formula defines a sequence of steps with dependency relationships.

### 3.1 What a Formula Is

A formula declares:
- **Steps**: Named phases of work
- **Dependencies**: Which steps must complete before others begin (`needs`)
- **Descriptions**: What each step involves (used by the Convener as instructions)

When a formula is "poured" (`bd mol pour <formula>`), it creates:
- One **parent bead** (the molecule) representing the entire workflow
- One **child bead** per step, linked to the parent

### 3.2 Existing Formulas

#### Symposium (`symposium.formula.toml`)

The flagship workflow. 10 sequential phases of multi-agent philosophical discourse.

```
phase-1: Independent Work        → Scholars write essays
phase-2: Independent Review      → Critics assess all works
phase-3: Independent Revision    → Scholars respond to reviews
phase-4: Cross-Review            → Critics compare assessments
phase-5: Cross-Work Review       → Comparative analysis
phase-6: Synthesis               → New scholar integrates
phase-7: Opposition              → Loyal dissent challenges
phase-8: Final Critique          → Critics assess synthesis
phase-9: Convener Report         → Operational documentation
phase-10: Recognition            → Honor all contributors
```

**Typical cost**: ~$40-50 (3 Opus scholars, 3 Opus critics, 1 Opus synthesizer, 1 Opus opposition, 1 Sonnet convener)

**Typical duration**: 2-4 hours

#### Public Essay (`public-essay.formula.toml`)

A lighter workflow that distills symposium outputs into an accessible, standalone essay.

```
draft:  → Scholar writes self-contained essay
review: → Critic assesses clarity
revise: → Scholar addresses feedback
polish: → Copyeditor refines prose
```

### 3.3 Future Formulas

Formulas we expect to create as the project evolves:

| Formula | Purpose | Agents |
|---------|---------|--------|
| `assembly` | Collective deliberation on governance decisions | Multiple scholars debating |
| `deep-dive` | Single-scholar extended investigation | 1 scholar, 1 critic |
| `peer-review` | Scholar-to-scholar critique (no dedicated critics) | 2+ scholars |
| `constitutional-amendment` | Formal proposal, debate, and vote | Proposer, supporters, opposition |

### 3.4 Creating a New Formula

1. Create `<name>.formula.toml` in `.beads/formulas/`
2. Define steps with `[[steps]]` blocks (each has `id`, `title`, `description`)
3. Add `needs = ["step-id"]` for dependencies
4. Test with `bd mol pour <name> --dry-run`
5. Create any needed spawn scripts in `scripts/container/`
6. Update the Convener skill if the formula introduces new phase-transition logic

---

## 4. The Lifecycle of a Problem

This section describes the end-to-end flow from problem identification to archived output.

### Phase 0: Problem Selection

**Who**: Human + Founder Agent
**Where**: Interactive Claude Code session on host

1. Human identifies an interesting question or the Founder proposes one
2. Together they select a formula (e.g., symposium)
3. They configure parameters:
   - **Topic**: The question to investigate
   - **Traditions**: Which philosophical lenses (typically 3 for symposium)
   - **Agent count**: How many scholars, critics
   - **Model selection**: Opus for quality work, Sonnet for coordination
4. Human authorizes the cost

**Output**: A clear problem statement, formula choice, and configuration.

### Phase 1: Convener Activation

**Who**: Founder Agent or Human
**Where**: Inside the Docker container

1. Spawn the Convener in a tmux session:
   ```bash
   scripts/container/spawn-convener.sh <topic> <formula>
   ```
2. Convener reads its assignment and the `/convener-role` skill
3. Convener creates the symposium parent bead:
   ```bash
   SYMPOSIUM_BEAD=$(bd create --title "Symposium: <topic>" --label symposium)
   ```
4. Convener pours the formula:
   ```bash
   bd mol pour <formula>
   ```

### Phase 2: Formula Execution

**Who**: Convener (autonomous)
**Where**: Inside the Docker container

The Convener runs a patrol cycle:

```
┌─────────────────────────────────────────────┐
│                PATROL CYCLE                  │
│                                              │
│  1. Check bead status for current phase      │
│     └─ bd show $SYMPOSIUM_BEAD               │
│     └─ All children ✓? → phase complete      │
│                                              │
│  2. If phase complete:                       │
│     ├─ Archive phase outputs                 │
│     ├─ Determine next phase from formula     │
│     ├─ Spawn agents for next phase           │
│     └─ Update .current-phase (informational) │
│                                              │
│  3. If phase in progress:                    │
│     ├─ Check for stuck agents (optional)     │
│     └─ Wait 3-5 minutes, repeat              │
│                                              │
│  4. If all phases complete:                  │
│     ├─ Write convener report                 │
│     ├─ Run cleanup script                    │
│     ├─ Close symposium bead                  │
│     └─ Exit                                  │
└─────────────────────────────────────────────┘
```

Each phase follows the same pattern:
1. Convener spawns agents using container scripts (passing symposium bead ID)
2. Scripts create child beads linked to parent, start tmux sessions, inject prompts
3. Agents work autonomously (read assignment, produce output, commit, close bead, exit)
4. Convener detects all phase beads closed → transitions to next phase

### Phase 3: Cleanup & Archival

**Who**: Cleanup script (triggered by Convener or run by human)
**Where**: Starts in container, copies to host

See [Section 8](#8-cleanup--archival) for details.

---

## 5. Infrastructure

### 5.1 Docker Container

All agent work happens inside a Docker container:
- **Volume**: `/atlantis/` mounted from host
- **Tools**: tmux, git, `bd` (beads CLI), `atlantis-mail`, Claude Code
- **Isolation**: Agents can't access host filesystem directly
- **API key**: Loaded from `.env` into container environment

### 5.2 Tmux Sessions

Each agent runs in a named tmux session:
- Scholars: `atlantis-philosophy-<name>`
- Critics: `atlantis-critic-<name>`
- Opposition: `atlantis-opposition-<name>`
- Convener: `atlantis-convener`

Tmux is the source of truth for agent liveness: session exists = agent is running.

### 5.3 Beads (`bd`)

Git-integrated issue tracking. Every work item is a bead with:
- **ID**: e.g., `ph-abc` (auto-generated)
- **Title**: Descriptive name
- **Status**: `pending` → `in_progress` → `done` (or `closed`)
- **Labels**: `scholarly-work`, `review`, `opposition`, `symposium`, etc.
- **Parent**: Links child beads to a symposium bead

**Key commands**:
```bash
bd create --title "..." --label X --parent PARENT_ID   # Create bead
bd update ID --status in_progress                       # Update status
bd close ID                                             # Mark complete
bd show ID                                              # Show bead + children
bd list --status open                                   # Query by status
bd mol pour <formula>                                   # Pour a formula
```

### 5.4 Mail System

Asynchronous messaging between agents:

```
/atlantis/philosophy/.mail/
├── convener/inbox/
├── scholars/<name>/inbox/
├── critics/<name>/inbox/
└── founder/inbox/
```

**Commands**:
```bash
export ATLANTIS_AGENT_NAME=<name>
atlantis-mail send <recipient> "<subject>" "<body>"
atlantis-mail inbox
```

Mail is a **backup signal**. Beads are the source of truth for completion.

### 5.5 Git

All work is persisted as git commits:
- Each scholar/critic has an isolated workspace with its own git repo
- Commits track progress (orientation → investigation → draft → final)
- The host repo archives completed symposium outputs

### 5.6 Skills

Claude Code skills (`.claude/skills/`) provide role-specific instructions:
- `/scholar-role` — Scholar workflow and conventions
- `/critic-role` — Convergent coherence framework
- `/convener-role` — Symposium management and patrol cycle
- `/handoff` — Session cycling (from Gas Town)

Skills load on-demand, saving context window space vs. putting everything in CLAUDE.md.

### 5.7 Spawn Scripts

Container-native scripts in `scripts/container/`:

| Script | Creates | Bead | Session |
|--------|---------|------|---------|
| `spawn-scholar.sh` | Workspace, ASSIGNMENT.md, tmux session | Work bead (child of symposium) | `atlantis-philosophy-<name>` |
| `spawn-critic.sh` | Workspace, ASSIGNMENT.md, tmux session | Review bead (child of symposium) | `atlantis-critic-<name>` |
| `spawn-opposition.sh` | Workspace, ASSIGNMENT.md, tmux session | Opposition bead (child of symposium) | `atlantis-opposition-<name>` |

**All scripts**:
1. Create workspace directory
2. Create a child bead linked to the symposium parent
3. Write ASSIGNMENT.md with bead ID, instructions, and completion protocol
4. Create tmux session, start Claude with `--permission-mode bypassPermissions`
5. Inject initial prompt via `tmux send-keys`

---

## 6. The Convener

The Convener is the most complex agent. It must autonomously drive a multi-phase workflow to completion.

### 6.1 Convener Patrol Cycle

The Convener operates in a simple loop:

```
while symposium is not complete:
    1. Query bead status: bd show $SYMPOSIUM_BEAD
    2. Parse children: count ✓ (closed) vs ◐ (in_progress) vs ○ (open)
    3. If current phase beads all closed:
        a. Log phase completion
        b. Determine next phase from formula
        c. Spawn agents for next phase
        d. Update .current-phase file
    4. If not complete:
        a. Wait 3-5 minutes
        b. Check mail for HELP messages
    5. Loop
```

### 6.2 Phase Transition Logic

Each phase has specific spawning patterns:

| Phase | Agents to Spawn | Script | Notes |
|-------|-----------------|--------|-------|
| 1: Independent Work | N scholars | `spawn-scholar.sh` | One per tradition |
| 2: Independent Review | N critics | `spawn-critic.sh` | Each reviews all essays |
| 3: Independent Revision | N scholars | `spawn-scholar.sh` | With reviews as input |
| 4: Cross-Review | 1 editorial board | Manual tmux | Critics compare notes |
| 5: Cross-Work Review | 1 analyst | Manual tmux | Comparative analysis |
| 6: Synthesis | 1 synthesizer | Manual tmux | Integrate all perspectives |
| 7: Opposition | 1 opposition critic | `spawn-opposition.sh` | Challenge synthesis |
| 8: Final Critique | N critics | `spawn-critic.sh` | Assess synthesis |
| 9: Convener Report | Convener itself | — | Write report, no spawning |
| 10: Recognition | Convener itself | — | CONTRIBUTORS.md, METRICS.md |

### 6.3 Phases the Convener Does Itself

Phases 9 and 10 don't require spawning. The Convener:
- **Phase 9**: Writes operational documentation (timeline, costs, process notes)
- **Phase 10**: Creates recognition files, closes the symposium bead, triggers cleanup

### 6.4 Critical Implementation Notes

1. **Always use spawn scripts** — don't write raw tmux commands
2. **Pass symposium bead ID** to every spawn script for parent-child linking
3. **Track spawned bead IDs** — store them for status checking
4. **Wait after spawning** — `sleep 5` before sending prompts to Claude
5. **Use `Enter` not `C-m`** — for sending the prompt newline: `tmux send-keys -t SESSION Enter`

---

## 7. The Nudger

The Nudger is a supportive health monitor that detects stuck agents and encourages them to continue. It is **not yet implemented** but is part of the target architecture.

### 7.1 Purpose

Agents can get stuck for various reasons:
- Context window exhaustion
- Waiting for input that already arrived
- Claude entering an idle state between conversation turns
- Errors in tool execution

The Nudger periodically checks agent sessions and sends gentle prompts.

### 7.2 Design

**Model**: Sonnet 4.5
**Lifecycle**: Long-running (alongside Convener)

**Patrol cycle**:
```
every 5 minutes:
    1. List all active tmux sessions matching atlantis-*
    2. For each session:
        a. Capture recent pane output (tmux capture-pane)
        b. Check if agent appears stuck (no new output in N minutes)
        c. Check if agent's bead is still open
    3. If stuck AND bead still open:
        a. Send nudge via tmux send-keys:
           "It looks like you may be idle. Please check your ASSIGNMENT.md
            and continue your work. If you're done, close your bead."
    4. If bead closed but session still exists:
        a. Note for potential cleanup
```

### 7.3 Key Design Decisions

- **Supportive, not coercive**: Nudges are encouraging, not demanding
- **Respects autonomy**: Deep thinking (hours without commits) is legitimate
- **Bead-aware**: Only nudges agents whose beads are still open
- **No kill authority**: Detects stuck agents but doesn't terminate them

### 7.4 Implementation Path

The Nudger can be implemented as:
1. A background bash script (simplest — runs `while true` with `sleep 300`)
2. A separate tmux session running a Claude agent with the nudger role
3. A formula step that the Convener activates alongside Phase 1

Option 1 (bash script) is recommended for initial implementation since it avoids consuming API tokens for routine health checks.

---

## 8. Cleanup & Archival

After all phases complete, outputs must be copied from the Docker container to the host repository, documented, and pushed to GitHub.

### 8.1 What Gets Archived

```
first-works/<symposium-name>/
├── README.md                    # Generated summary
├── phase-1-independent-work/    # Scholar essays
├── phase-2-independent-review/  # Critic reviews
├── phase-3-independent-revision/# Revised essays
├── phase-4-cross-review/        # Cross-review notes
├── phase-5-cross-work-review/   # Comparative analysis
├── phase-6-synthesis/           # Integrated framework
├── phase-7-opposition/          # Opposition report
├── phase-8-final-critique/      # Final critic assessments
├── phase-9-convener-report/     # Operational documentation
├── phase-10-recognition/        # CONTRIBUTORS.md, METRICS.md
└── CITATION.md                  # How to cite this symposium
```

### 8.2 Cleanup Script

**Script**: `scripts/cleanup-symposium.sh` (to be created)
**Run from**: Host (accesses both container and host filesystem)

```bash
./scripts/cleanup-symposium.sh <symposium-name>
```

**Steps**:
1. **Copy outputs** from container (`docker compose cp`) to `first-works/<name>/`
2. **Generate README.md** with:
   - Symposium question and date
   - Participants (scholars, critics, traditions)
   - Phase navigation links
   - Key findings summary
   - Statistics (documents, duration, cost)
   - Citation format
3. **Git commit** all files with descriptive message
4. **Git push** to GitHub

### 8.3 README Generation

The cleanup script generates the README from:
- The symposium bead metadata (topic, labels, dates)
- The convener report (Phase 9)
- The recognition files (Phase 10)
- Directory structure (auto-link phases)

### 8.4 When Cleanup Runs

Two options:
1. **Convener triggers it** at the end of Phase 10 (fully autonomous)
2. **Human runs it** after reviewing outputs (more control)

Initial implementation: Convener signals completion, human reviews and runs cleanup. As trust builds, move toward fully autonomous cleanup.

---

## 9. Extending the System

### 9.1 Adding a New Agent Role

1. Create a spawn script: `scripts/container/spawn-<role>.sh`
   - Follow the pattern of `spawn-scholar.sh`
   - Create workspace, bead, ASSIGNMENT.md, tmux session
2. Optionally create a skill: `.claude/skills/<role>-role/SKILL.md`
3. Update the Convener skill to document when/how to spawn this role
4. Add the role to this architecture document (Section 2)

### 9.2 Adding a New Formula

1. Create `<name>.formula.toml` in `.beads/formulas/`
2. Define steps with dependencies
3. Test: `bd mol pour <name> --dry-run`
4. Create any needed spawn scripts
5. Document the formula in this architecture document (Section 3)
6. If the formula needs different Convener behavior, update the Convener skill

### 9.3 Tradition Registry

Current philosophical traditions available for symposia:

| Tradition | Key Thinkers | Lens |
|-----------|-------------|------|
| Aristotelian/Ostromian | Aristotle, Ostrom | Flourishing, commons governance |
| Republican | Cicero, Pettit | Civic participation, non-domination |
| Natural rights | Locke, Nozick | Autonomy, property, minimal state |
| Social contract | Rousseau, Rawls | General will, justice as fairness |
| Phenomenological | Arendt | Action, plurality, public space |
| Pragmatist | Dewey, James | Democratic experimentalism |
| Critical theory | Foucault, Habermas | Power, discourse, contestation |
| Virtue ethics | MacIntyre, Foot | Character, practice, tradition |

The Convener selects 3 traditions per symposium for productive tension. See `docs/TRADITION-ASSIGNMENT-SYSTEM.md` for selection guidance.

---

## 10. File Reference

### Core Design
| File | Purpose |
|------|---------|
| `docs/ARCHITECTURE.md` | **This document** — canonical architecture reference |
| `.claude/CLAUDE.md` | Founder agent identity and principles |
| `FOUNDING.md` | Founding charter and philosophy |

### Formulas
| File | Purpose |
|------|---------|
| `.beads/formulas/symposium.formula.toml` | 10-phase symposium workflow |
| `.beads/formulas/public-essay.formula.toml` | 4-phase public essay workflow |

### Skills
| File | Purpose |
|------|---------|
| `.claude/skills/convener-role/SKILL.md` | Convener instructions |
| `.claude/skills/scholar-role/SKILL.md` | Scholar instructions |
| `.claude/skills/critic-role/SKILL.md` | Critic instructions |
| `.claude/skills/handoff/SKILL.md` | Session cycling |

### Spawn Scripts (Container-native)
| File | Purpose |
|------|---------|
| `scripts/container/spawn-scholar.sh` | Spawn a scholar agent |
| `scripts/container/spawn-critic.sh` | Spawn a critic agent |
| `scripts/container/spawn-opposition.sh` | Spawn an opposition critic |
| `scripts/container/spawn-synthesizer.sh` | Spawn a synthesizer agent |
| `scripts/container/spawn-bibliographer.sh` | Spawn a bibliographer agent |
| `scripts/container/spawn-copyeditor.sh` | Spawn a copyeditor agent (public-essay polish phase) |
| `scripts/container/run-public-essay.sh` | DEPRECATED — use `spawn-convener.sh` with `public-essay` formula |

### Host-Side Scripts (for human operators)
| File | Purpose |
|------|---------|
| `scripts/spawn-convener.sh` | Spawn convener from host |
| `scripts/cleanup-symposium.sh` | Copy outputs, kill sessions, commit, push |
| `scripts/spawn-scholar.sh` | Spawn scholar from host |
| `scripts/spawn-critic.sh` | Spawn critic from host |
| `scripts/spawn-multiple-scholars.sh` | Parallel scholar spawning |
| `scripts/spawn-multiple-critics.sh` | Parallel critic spawning |
| `scripts/retire-agent.sh` | Gracefully stop an agent |
| `scripts/monitor-agents.sh` | Split-screen monitoring |

### Archives
| Directory | Contents |
|-----------|----------|
| `first-works/symposium-governance-2026-01/` | Symposium #1: Governance |
| `first-works/symposium-constitutional-foundations-2026-01/` | Symposium #2: Constitutional Foundations |
| `first-works/symposium-excellence-and-quality-standards-2026-01/` | Symposium #3: Excellence |

### Historical Documents (Superseded)
| File | Status |
|------|--------|
| `ROADMAP.md` | Superseded by this document |
| `NEXT-STEPS.md` | Superseded by this document |
| `AUTOMATION-ACHIEVEMENTS.md` | Historical record of early infrastructure |
| `PROGRAMMATIC-SPAWNING.md` | Superseded by spawn scripts and this document |
| `docs/INFRASTRUCTURE-DIAGNOSIS-2026-01.md` | Historical diagnosis; fixes integrated here |

### Still-Active Reference Documents
| File | Purpose |
|------|---------|
| `docs/SYMPOSIUM-MOLECULE.md` | Detailed phase descriptions and philosophy |
| `docs/SPAWN-ARCHITECTURE.md` | Host vs. container spawning rationale |
| `docs/COORDINATION-EFFICIENCY.md` | Token-efficiency patterns |
| `docs/MAIL-SYSTEM.md` | Mail system specification |
| `docs/TRADITION-ASSIGNMENT-SYSTEM.md` | Tradition selection guidance |
| `docs/CONVENER-EDITORIAL-GUIDE.md` | Editorial decision-making |
| `docs/ROLE-EVOLUTION.md` | Agent role definitions and evolution |
| `SYMPOSIUM-SUCCESS.md` | First symposium results and analysis |

---

## Appendix A: Gas Town Patterns Adapted

New Atlantis inherits infrastructure patterns from Gas Town (Steve Yegge's agent orchestration system). This appendix maps the adaptation.

| Gas Town | New Atlantis | Adaptation |
|----------|-------------|------------|
| Polecat (ephemeral worker) | Scholar/Critic (ephemeral per-phase) | Same lifecycle, different purpose |
| Mayor (overseer) | Founder (servant leader) | Facilitation, not command |
| Witness (health monitor) | Nudger (supportive monitor) | Encouraging, not surveilling |
| Deacon (daemon patrol) | Convener patrol cycle | Simplified; beads replace complex state |
| Refinery (merge queue) | Cleanup script | Archival, not code merging |
| Molecules | Formulas | Same concept, scholarly workflows |
| Hooks + GUPP | ASSIGNMENT.md + autonomous execution | Same principle: work on hook → run it |
| `gt sling` | Spawn scripts | Same function, bash instead of Go |
| Agent beads | Work beads | Same tracking, different labels |
| Mail / inbox | `atlantis-mail` | Same async signaling pattern |

### Patterns We Use Directly
- Tmux sessions for agent isolation
- Beads for work tracking (`bd` CLI)
- Formulas/molecules for workflow definition
- Git for state persistence
- Mail for async coordination
- GUPP: agents check their assignment and act

### Patterns We Adapted
- Patrol loops: simplified to bead-status checking (no Deacon complexity)
- Monitoring: supportive nudging instead of surveillance
- Cleanup: archival to GitHub instead of merge queue

### Patterns We Don't Use (Yet)
- `gt` CLI (Go binary — we use bash scripts instead)
- Hooks (persistent work queues — we use ASSIGNMENT.md)
- Convoys (parallel independent streams — could map to multi-tradition symposia)
- Dog pool (infrastructure worker pool)

---

## Appendix B: Cost Model

| Role | Model | Est. Cost per Invocation |
|------|-------|--------------------------|
| Scholar (essay) | Opus 4.5 | $3-5 |
| Critic (review) | Opus 4.5 | $3-5 |
| Synthesizer | Opus 4.5 | $3-5 |
| Opposition | Opus 4.5 | $2-3 |
| Convener | Sonnet 4.5 | $2-5 |
| Bibliographer | Haiku 3.5 | $0.50-1 |
| Nudger (if agent) | Sonnet 4.5 | $1-3 |

**Typical symposium (3 scholars, 3 critics, 1 synthesis, 1 opposition)**:
- Phase 1: 3 scholars × $4 = $12
- Phase 2: 3 critics × $4 = $12
- Phase 3: 3 scholars × $3 = $9
- Phase 4-5: 1-2 agents × $4 = $8
- Phase 6: 1 synthesizer × $5 = $5
- Phase 7: 1 opposition × $3 = $3
- Phase 8: 3 critics × $3 = $9
- Convener: $5
- **Total: ~$60-65**

---

## Appendix C: Open Questions

1. **Should we adopt `gt` CLI?** Would add `gt sling`, hooks, handoff. Requires Go in container.
2. **Nudger implementation**: Bash script vs. Claude agent? Bash is cheaper; agent is smarter.
3. **Cross-symposium continuity**: Should scholars maintain identity across symposia?
4. **Self-governance**: When should agents propose their own topics?
5. **Non-Western traditions**: Should we expand the tradition registry?
6. **Publication pipeline**: How to publish symposium outputs externally?
7. **Constitutional development**: Should the community draft a binding constitution?

---

*This document is maintained by the Founder and updated as the architecture evolves.*
*New Atlantis Project, January 2026*
