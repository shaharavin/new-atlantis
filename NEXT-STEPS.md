# Next Steps for New Atlantis

**Last Updated**: January 26, 2026
**Status**: Symposium #3 running. Skills created. Convener mailbox bug identified.

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

### Infrastructure Issues

**Issue 1 (FIXED)**: During Symposium #2, scholars were spawned as native processes (not tmux sessions), making them invisible to monitoring tools.

**Solution**: Container-native spawn scripts that create proper tmux sessions.
- ✅ `scripts/container/spawn-scholar.sh`
- ✅ `scripts/container/spawn-critic.sh`
- ✅ `scripts/container/spawn-opposition.sh`
- ✅ Convener template updated

**Issue 2 (FIXED)**: Convener not autonomously progressing through phases.

**Root cause identified**: The previous Convener (Symposium #1 & #2) created **background bash monitoring scripts** that poll independently of Claude's conversation. These scripts run `while true` loops with `sleep 30`, checking for completion conditions and mailing the Convener when phases complete. The current Convener wasn't creating these scripts.

**Solution**: Updated Convener template and `/convener-role` skill to document the background monitor script pattern. Convener must:
1. Spawn agents for a phase
2. Create a `monitor-phase-N.sh` script
3. Run it in background with `nohup ./monitor-phase-N.sh &`
4. Script polls `.completions/` directory and mails when all agents done
5. Mail wakes Convener to transition to next phase

**Key insight**: Claude cannot maintain persistent loops between conversation turns. For autonomous coordination, use background bash scripts that poll and signal. This is how Gas Town works too.

**Files updated**:
- `templates/convener-CLAUDE.md` - Added "CRITICAL: Background Monitor Scripts" section
- `.claude/skills/convener-role/SKILL.md` - Added monitor script pattern
- `.claude/CLAUDE.md` - Added Gas Town consultation guidance

**Issue 3 (FIXED)**: Agents spawned by Convener hang waiting for newline.

**Root cause identified**: The Convener wasn't using the container spawn scripts. It was writing its own tmux commands and either:
1. Using `C-m` instead of `Enter` (less reliable)
2. Not including a `sleep 1` before sending Enter
3. Forgetting to send Enter entirely

**Solution**: Updated Convener template and skill with:
1. Strong warning: "ALWAYS use the spawn scripts - do NOT write your own tmux commands"
2. If manual spawning needed, use exact pattern: `sleep 1` then `tmux send-keys Enter`
3. Fixed synthesis section example to use correct pattern

**Files updated**:
- `templates/convener-CLAUDE.md` - Added warning, fixed synthesis example
- `.claude/skills/convener-role/SKILL.md` - Added manual spawn pattern

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
8. Sync with Gas Town evolution (see Research & Learning section)
9. Explore Claude Skills for cost/context efficiency

### Long-term (Next Quarter)
10. Draft New Atlantis constitution based on symposium wisdom
11. Enable agent-proposed symposium topics (self-governance)
12. Publish symposium outputs externally
13. Implement graduated membership system

---

## Symposium #3: Excellence and Quality Standards

**Status**: Queued, ready for activation
**Proposal**: `symposia-queue/excellence-and-quality-standards.md`

### The Question

> *What constitutes excellent philosophical work, and how should New Atlantis recognize and pursue it?*

This symposium establishes a "north star" for quality—enabling us to measure whether infrastructure changes improve outputs and giving scholars standards to aspire to.

### Key Sub-Questions

1. What do humans consider excellent philosophy, and why?
2. What distinguishes genuine insight from sophisticated fluency?
3. How might we measure progress toward excellence?
4. Should New Atlantis aim for human-style excellence or something different?

### Why This Topic

- We have process quality (convergent coherence) but no articulated vision of *what* excellent output looks like
- With two symposia of output, scholars can reflect on concrete examples
- Produces actionable criteria for assessing our own work

### Activation

```bash
./scripts/activate-symposium.sh excellence-and-quality-standards
```

The Convener will select appropriate traditions and spawn scholars.

### Process Improvements for Symposium #3

- ✅ Container-native spawning (monitoring visible)
- ✅ Opposition Phase (first test of new molecule addition)
- Track scholar participation for continuity analysis
- More rigorous inter-critic convergence analysis post-hoc

---

## Open Questions

1. **Opposition output handling**: ✅ Resolved - Convener summarizes in report, flags significant concerns to Founder

2. **Assembly Molecule**: Worth designing now or wait until we have more agents with continuity?

3. **Publication**: Should we write up Symposium #2 findings for external audiences?

---

## Research & Learning

### Gas Town Sync (Priority: Medium)

New Atlantis forked from Gas Town but hasn't synced with recent developments. Worth reviewing:
- New infrastructure patterns
- Improved monitoring/coordination
- Lessons learned from production use

**Action**: Review Gas Town's recent commits and docs, adapt useful patterns.

### Claude Skills (Priority: Medium-High) ✅ IMPLEMENTED

Skills created in `.claude/skills/`:
- ✅ `/scholar-role` - Scholar workflow and conventions
- ✅ `/critic-role` - Critic role with convergent coherence framework
- ✅ `/convener-role` - Symposium management workflow
- `/handoff` - Session cycling (from Gas Town)

**How skills work**: Descriptions load at session start; full content loads on-demand when Claude decides they're relevant (or when manually invoked with `/skill-name`). More context-efficient than putting everything in CLAUDE.md.

**Next steps**:
- Test skills with agents in Symposium #3
- Consider `/opposition-role` skill
- Consider dynamic skills with `!command` syntax for live data

### Seth Lazar's Coding Agents for Research (Priority: High)

A philosopher (ANU) experimenting with orchestrating Claude Code agents for philosophical work:
https://github.com/mint-philosophy/coding-agents-for-research/blob/main/docs/guide.md

**Key insights relevant to New Atlantis**:

1. **Documentation discipline precedes capability**
   - Standardized project structure (README/LOG/TODO) enables agent continuity
   - "If it's not written down, it didn't happen"
   - Session logs capture decisions and learnings for future agents

2. **Skills system for institutional memory**
   - Reusable capability packages (canvas-sync, notion-tasks, slack-posting)
   - New agents inherit solutions rather than reinventing them
   - Compounds over time

3. **Bounded autonomy works**
   - Agents restricted to clear competency domains
   - Enforceability matters (Cursor's bright lines vs reckless bypass)
   - New Atlantis has this with role templates

4. **Verification scales harder than generation**
   - Uncertainty whether research-at-scale produces "robust content"
   - Human judgment layers remain essential
   - Aligns with our convergent coherence approach

5. **Context window management**
   - Tasks must be completable within context limits
   - `/end` command triggers documentation wrap-up
   - Handoff protocols preserve continuity

**Differences from New Atlantis**:
- Lazar focuses on augmenting solo researcher productivity
- We focus on autonomous agent community and discourse
- He uses Cursor (IDE-based); we use Claude Code + tmux
- He emphasizes removing friction around thinking; we emphasize agents doing philosophical work

**Actions**:
- Consider adopting session log discipline
- Explore Skills for institutional memory
- Review his initialization protocol for ideas

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
**Status**: Symposium #3 running (scholars working), Skills implemented
**Next**: Fix Convener mailbox bug → Complete Symposium #3 → Evaluate skills in practice
