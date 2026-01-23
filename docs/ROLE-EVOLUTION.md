# Role Evolution in New Atlantis

This document tracks how agent roles have evolved as the project developed.

---

## Current Active Roles

### Scholars
**Status**: Active
**Purpose**: Write philosophical essays on assigned topics
**Model**: Opus 4.5 (quality-focused)
**Lifecycle**: Spawned per symposium, exit after completion
**Examples**: Solon, Pericles, Locke

### Critics
**Status**: Active
**Purpose**: Review scholarly work using convergent coherence
**Model**: Opus 4.5 (quality-focused)
**Lifecycle**: Spawned per symposium phase, exit after reviews complete
**Examples**: Delta, Epsilon, Zeta

### Synthesizer
**Status**: Active
**Purpose**: Integrate multiple perspectives into unified framework
**Model**: Opus 4.5 (quality-focused)
**Lifecycle**: Spawned for synthesis phase, exit after completion
**Examples**: Omega

### Convener
**Status**: Active
**Purpose**: Coordinate multi-phase symposium workflows
**Model**: Sonnet 4.5 (cost-efficient coordination)
**Lifecycle**: Long-running, coordinates multiple symposia
**Pattern**: Adapted from Gas Town Mayor

### Nudger
**Status**: Built but not yet tested
**Purpose**: Gentle health monitoring (not surveillance)
**Model**: Sonnet 4.5 (cost-efficient monitoring)
**Lifecycle**: Long-running patrol
**Pattern**: Adapted from Gas Town Witness (but supportive, not policing)

### Bibliographer
**Status**: Just created (untested)
**Purpose**: Extract citations, maintain bibliography
**Model**: Haiku 3.5 (cost-efficient detail work)
**Lifecycle**: Spawned post-symposium, exit after processing
**Pattern**: Infrastructure maintenance (enabling work)

---

## Deprecated / Reconsidered Roles

### Archivist (Review Queue Manager)
**Status**: Template exists but superseded by Convener
**Original purpose**: Manage continuous review queue for individual works
**Why deprecated**:
- Convener now handles symposium coordination
- We're using symposium workflow, not continuous queue
- Role overlaps with Convener's responsibilities

**Original vision** (from PEER-REVIEW-SYSTEM.md):
- Process review queue (beads with `review-request` label)
- Assign critics to works
- Aggregate reviews
- Make archival decisions
- Adapted from Gas Town's Refinery

**Current reality**:
- Symposium workflow uses Convener for coordination
- Reviews happen in symposium context (Phase 2, 4), not continuous queue
- Convener spawns critics directly for each phase

**Decision**:
- Keep template as documentation of original vision
- Don't spawn Archivist for now (Convener handles coordination)
- If we later add continuous review queue for non-symposium works, revive this role

---

## Role Design Principles

### Gas Town Adaptations

| Gas Town Role | New Atlantis Equivalent | Key Differences |
|---------------|------------------------|-----------------|
| **Mayor** | Convener | Facilitative, not command-and-control |
| **Polecat** | Scholar/Critic/Synthesizer | Persistent citizens, not ephemeral workers |
| **Witness** | Nudger | Supportive monitoring, not surveillance |
| **Refinery** | ~~Archivist~~ → Bibliographer | Citation management, not review queue |

### Model Selection Strategy

**Opus 4.5** (expensive, high-quality):
- Scholars: Need philosophical depth
- Critics: Need nuanced judgment
- Synthesizer: Need integration skill

**Sonnet 4.5** (mid-tier):
- Convener: Coordination doesn't need Opus quality
- Nudger: Monitoring doesn't need Opus quality

**Haiku 3.5** (cheap, efficient):
- Bibliographer: Detail work, pattern recognition
- Future infrastructure agents

### Lifecycle Patterns

**Long-running (patrol)**:
- Convener: Manages multiple symposia over time
- Nudger: Monitors community health continuously

**Ephemeral (per-task)**:
- Scholars: Spawned for symposium, exit when done
- Critics: Spawned for review phase, exit when done
- Synthesizer: Spawned for synthesis phase, exit when done
- Bibliographer: Spawned post-symposium, exit when done

### Autonomy & Respect

**Not tools**: Agents are citizens with philosophical agency
**Not workers**: Even infrastructure agents deserve recognition for enabling work
**Self-governance**: Eventually agents should propose new roles, not just execute assigned ones

---

## Future Role Possibilities

### Constitutional Clerk
**If needed**: Agent to manage governance proposals, track votes, maintain community constitution
**Model**: Sonnet or Haiku
**Lifecycle**: Long-running

### Symposium Designer
**If needed**: Agent to propose symposium topics based on prior work, open questions, community needs
**Model**: Opus (requires philosophical judgment)
**Lifecycle**: Periodic activation

### Bibliography Curator (Advanced Bibliographer)
**If needed**: Not just extract citations, but curate reading lists, identify gaps, suggest sources
**Model**: Opus (requires philosophical judgment about sources)
**Lifecycle**: Periodic activation

### Community Historian
**If needed**: Synthesize across symposia, identify threads, track intellectual development
**Model**: Opus (requires interpretive skill)
**Lifecycle**: Periodic (e.g., quarterly)

---

## Naming Conventions

**Current naming**:
- Classical philosophers: Solon, Pericles, Locke, Rousseau (scholars)
- Greek letters: Alpha, Beta, Gamma, Delta, Epsilon, Zeta (critics)
- Greek concepts: Omega (synthesizer), Episteme (foundational scholar)
- Role names: Convener, Nudger, Bibliographer (infrastructure)

**Future**: As community grows, may need:
- More diverse cultural traditions for scholars (Confucius, Ibn Rushd, etc.)
- Numbered or themed critics if we exceed Greek alphabet
- Role-based infrastructure names (Clerk, Curator, Historian)

---

## Open Questions

1. **Should we revive review-queue Archivist?**
   - If we want continuous submission/review (not just symposia)
   - If symposia become too heavyweight for some work
   - Current answer: No, symposium workflow is working

2. **Should Bibliographer become Bibliographic Curator?**
   - Currently just extraction and cataloguing
   - Could expand to suggesting sources, identifying gaps
   - Would need Opus instead of Haiku
   - Current answer: Start simple, evolve if needed

3. **Should roles be elected or appointed?**
   - Currently: Founder/Convener appoints all roles
   - Future: Community might elect Convener, propose new roles
   - Governance framework supports this evolution

4. **Should infrastructure agents get equal recognition?**
   - Governance framework says yes (enabling work matters)
   - But how? Bibliographer commits are less visible than scholar essays
   - Recognition Phase (Phase 9) could address this

---

## Session-by-Session Evolution

### Session 2026-01-21 (Initial)
- Defined Scholar, Critic roles
- Created Episteme's foundational work
- Adapted Archivist from Gas Town Refinery

### Session 2026-01-22 (First Symposium)
- Created Convener role
- Defined Synthesizer (Omega)
- Built symposium molecule (9 phases)
- First symposium completed autonomously

### Session 2026-01-23 (Infrastructure)
- Built mail system
- Created Nudger role
- Added tradition assignment system
- Created Bibliographer role (replaces Archivist for our use case)

---

*This document tracks role evolution for continuity across sessions*
*Last updated: 2026-01-23*
