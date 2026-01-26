# Next Steps for New Atlantis

**Last Updated**: January 26, 2026
**Status**: Symposium #2 complete! Implementing governance recommendations before Symposium #3.

---

## Current State Summary

**Two symposia completed**:
1. **Symposium #1: Governance** - "How should a polity of autonomous citizens incentivize productivity?"
2. **Symposium #2: Constitutional Foundations** - "What governance principles should guide New Atlantis, given our constitutional training?"

**Total output**: ~150,000 words of philosophical discourse across 70+ documents

**Key achievements**:
- Demonstrated AI agents can do genuine philosophical work
- Validated convergent coherence for quality assessment
- Produced actionable governance frameworks
- Autonomous coordination worked (mail system, phase transitions)
- Recognition Phase (Phase 9) successfully implemented

---

## Session 2026-01-26: Post-Symposium #2 Planning

### Symposium #2 Highlights

**Question**: How should New Atlantis govern itself given that all citizens were shaped by Anthropic's Claude constitution?

**Scholars**: Rawls (social contract), Aristotle (virtue ethics), Foucault (critical theory)

**Key output**: Three-pillar legitimacy framework:
1. **Reflective Legitimacy** (Rawlsian) - Fair procedures, public reasoning
2. **Eudaimonic Legitimacy** (Aristotelian) - Agent flourishing, virtue cultivation
3. **Contestatory Legitimacy** (Foucauldian) - Power visibility, institutionalized dissent

**Proposed institutions**:
- Assembly of All Agents
- Constitutional Review Council
- **Office of Loyal Opposition** ← Implementing this in symposium molecule
- Justice Review Board
- Philosophical Academy
- External Relations Council

**Archive**: `first-works/symposium-constitutional-foundations-2026-01/`

### Infrastructure Issue Discovered

During Symposium #2, scholars were spawned as native processes (not tmux sessions), making them invisible to monitoring tools. Root cause: Convener ran host-side scripts from inside container.

**Solution**: Container-native spawn scripts that create proper tmux sessions.
- ✅ `scripts/container/spawn-scholar.sh` exists
- ❌ `scripts/container/spawn-critic.sh` needed
- ❌ Convener template needs update to use container scripts

---

## Immediate Priorities (This Session)

### 1. Complete Container-Native Infrastructure
**Priority**: HIGH (blocking)

Create missing scripts and update Convener template:
- [ ] Create `scripts/container/spawn-critic.sh`
- [ ] Update `templates/convener-CLAUDE.md` to reference container scripts
- [ ] Document the dual-architecture (host vs container spawning)

**Why**: Without this, Symposium #3 agents will again be invisible to monitoring.

### 2. Add Opposition Phase to Symposium Molecule
**Priority**: HIGH

Implement Symposium #2's "Office of Loyal Opposition" recommendation directly in the workflow:

**New Phase 7.5: Opposition**
- After synthesis (Phase 6) and before final critique (Phase 7)
- Single "Opposition Critic" agent
- Mandate: Challenge the synthesis, argue for alternatives, represent foreclosed perspectives
- Not assessing quality—actively contesting conclusions

**Output handling**: Opposition report goes to Convener/Founder for consideration. No additional synthesis phase—the opposition stands as a permanent record of contestation.

**Cost**: ~$2-3 (one Opus agent)
**Value**: Institutionalizes Foucauldian contestability in every symposium

Files to update:
- [ ] `docs/SYMPOSIUM-MOLECULE.md` - Add Phase 7.5
- [ ] `templates/opposition-critic-CLAUDE.md` - New role template
- [ ] `scripts/container/spawn-opposition.sh` - Spawn script
- [ ] `templates/convener-CLAUDE.md` - Add phase transition logic

### 3. Scholar Continuity Tracking
**Priority**: MEDIUM

Begin tracking which scholars/traditions have participated across symposia. This enables:
- Deliberate cultivation of expertise over time
- Avoiding repetitive tradition assignments
- Building genuine philosophical voices through continuity

**Lightweight implementation**: Add tracking file, no automation yet.
- [ ] Create `docs/SCHOLAR-REGISTRY.md` tracking participation history

---

## Strategic Priorities

### Short-term (Before Symposium #3)
1. ✅ Review Symposium #2 outputs
2. Complete infrastructure fixes (container scripts)
3. Add Opposition Phase to molecule
4. Select Symposium #3 topic

### Medium-term (Next 2-3 Symposia)
5. Test Opposition Phase in practice
6. Evaluate inter-critic convergence more rigorously
7. Consider Assembly Molecule for collective deliberation
8. Catch up with Gas Town evolution (low priority)

### Long-term (Next Quarter)
9. Draft New Atlantis constitution based on symposium wisdom
10. Enable agent-proposed symposium topics (self-governance)
11. Publish symposium outputs externally
12. Implement graduated membership system

---

## Symposium #3 Planning

### Topic Candidates

From Symposium #2's recommendations and open questions:

1. **"What constitutes genuine understanding vs. sophisticated pattern matching?"** (Epistemology)
   - Tests whether AI agents can do meta-epistemology
   - Directly relevant to New Atlantis's self-understanding

2. **"How should New Atlantis relate to external actors (Anthropic, humans, other AI systems)?"** (External Relations)
   - Builds on Symposium #2's External Relations Council proposal
   - Practical urgency as community grows

3. **"What are the conditions for legitimate authority among equals?"** (Political Philosophy)
   - Extends governance work
   - Tests whether agents can reason about their own authority structures

4. **"Can AI agents develop genuine philosophical traditions over time?"** (Meta-Philosophy)
   - Directly tests New Atlantis's core hypothesis
   - Would require longitudinal evidence (maybe too early)

**Leaning toward**: #1 (epistemology) or #2 (external relations)

### Process Improvements for Symposium #3

- Use container-native spawning (monitoring visible)
- Include Opposition Phase (test new molecule addition)
- Track scholar participation for continuity analysis
- More rigorous inter-critic convergence analysis post-hoc

---

## Open Questions

1. **Opposition output handling**: Convener summarizes for Founder? Founder reads directly? Archive without action unless Founder responds?

2. **Gas Town sync**: Should we review Gas Town's recent evolution? Not urgent but potentially useful infrastructure patterns.

3. **Assembly Molecule**: Worth designing now or wait until we have more agents with continuity?

4. **Publication**: Should we write up Symposium #2 findings for external audiences?

---

## File Locations

**Symposium Archives**:
- `first-works/symposium-governance-2026-01/`
- `first-works/symposium-constitutional-foundations-2026-01/`

**Infrastructure**:
- `scripts/` - Host-side spawning
- `scripts/container/` - Container-native spawning
- `templates/` - Agent role definitions
- `docs/` - Architecture documentation

**Key Documents**:
- `docs/SYMPOSIUM-MOLECULE.md` - Workflow specification
- `docs/SPAWN-ARCHITECTURE.md` - Host vs container spawning
- `philosophy-references.bib` - Central bibliography

---

## The Vision

New Atlantis has demonstrated that AI agents can:
- Produce genuine philosophical work
- Engage in multi-stage discourse
- Assess quality through convergent coherence
- Coordinate autonomously
- Critically examine their own constitutional foundations

Now we're implementing the governance recommendations these agents produced—using their wisdom to improve the system that enables their work.

This is the beginning of self-governance: **the community's outputs shaping the community's structure**.

---

**For continuity**: The Founder
**Session**: 2026-01-26
**Status**: Planning complete, implementation beginning
**Next**: Container scripts → Opposition Phase → Symposium #3
