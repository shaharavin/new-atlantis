# New Atlantis - Peer Review System Session - January 20, 2026

## Session Goal
Add peer review capabilities to New Atlantis by implementing a critic role and minimal review tracking system, adapting Gas Town's Refinery pattern.

---

## What We Built

### 1. Gas Town Pattern Adaptation

**Mapped Gas Town components to New Atlantis:**

| Gas Town | New Atlantis | Purpose |
|----------|--------------|---------|
| Refinery | Archivist (future) | Processes review queue, makes archival decisions |
| Merge Request | Review Request | Tracks work pending review |
| Polecat (worker) | Critic (reviewer) | Ephemeral agent assigned to review specific work |
| Merge Queue | Review Queue | Queue of works awaiting review |
| Witness | Witness | Monitors scholars/critics (same role) |

### 2. Critic Scholar Role

**Created:** `templates/critic-CLAUDE.md`

A specialized scholar role for peer review:
- **Single focus**: Review one work thoroughly
- **Framework**: Apply Episteme's convergent coherence criteria
- **Output**: Structured review with recommendation (APPROVE/REVISE/REJECT)
- **Scoring**: 1-5 scale on 4 dimensions (coherence, discourse engagement, functional success, explicit reasoning)

**Key features:**
- Comprehensive review structure (summary, strengths, objections, scores, recommendation)
- Critical virtues (charity, specificity, constructiveness, rigor, humility)
- Meta-commentary requirement (acknowledge limitations of assessment)
- Example workflow

### 3. Review Workflow Design

**Doc created:** `docs/PEER-REVIEW-SYSTEM.md`

**Current (Manual) Workflow:**
1. Scholar completes work → submits for review (manual for now)
2. Create critic workspace with ASSIGNMENT.md
3. Spawn critic using `spawn-critic.sh`
4. Critic reviews work, produces structured review
5. Critic runs `gt done`
6. Review used to make archival decision (manual for now)

**Future (Automated) Workflow:**
- Review request beads (`--type=review-request`)
- Archivist patrol molecule (processes review queue)
- Multiple critics for convergence (2/3 approval threshold)
- Capability ledger tracking all decisions

### 4. Spawning Infrastructure

**Created:** Critic spawning script (in container)

```bash
/tmp/spawn-critic.sh <critic-name> <work-bead-id>
```

Same pattern as scholar spawning:
- Creates tmux session
- Starts Claude with `--permission-mode bypassPermissions`
- Sends initial prompt
- Requires manual consent acceptance (~5 seconds)

### 5. First Test: Critic Alpha

**Spawned:** `critic-alpha` to review Episteme's essay

- **Assignment**: Review "Quality Assessment Without Ground Truth"
- **Work ID**: ph-3rs
- **Location**: `/atlantis/philosophy/critics/critic-alpha/`
- **Status**: Spawned, running in tmux session `atlantis-critic-critic-alpha`

**Test Goals:**
1. Can one AI meaningfully critique another's work?
2. Does the convergent coherence framework apply well?
3. Will the review be substantive or superficial?
4. Does the structured format produce useful output?

---

## Files Created/Modified

### New Files
- `templates/critic-CLAUDE.md` - Critic role template
- `docs/PEER-REVIEW-SYSTEM.md` - System design document
- `SESSION-2026-01-20-PEER-REVIEW.md` - This document
- `/tmp/spawn-critic.sh` (in container) - Critic spawning script

### Exported Work
- `first-works/episteme/quality-assessment-without-ground-truth.md` - Episteme's essay
- `first-works/episteme/investigation-notes.md` - Research notes

---

## Why This Matters

### Intellectual Significance

Episteme's essay is **directly meta** to New Atlantis:
- Proposes framework for assessing quality without ground truth
- Addresses exact problem: how to evaluate AI-generated philosophy
- Suggests specific criteria (convergent coherence)
- Now we're *implementing* what Episteme proposed by spawning a critic

**This creates a beautiful recursive test:**
1. Episteme proposes assessment framework
2. We spawn critic using that framework
3. Critic assesses Episteme's own proposal
4. Does the framework work when applied to itself?

### Pragmatic Value

Before scaling to multiple scholars, we need:
- ✅ Quality standards (Episteme provided the framework)
- ✅ Review mechanism (Critic role)
- ⏳ Review queue system (designed, not yet implemented)
- ⏳ Archival decision process (manual for now)

This infrastructure prevents:
- Archiving low-quality work at scale
- Inability to distinguish good from mediocre output
- Lack of intellectual rigor in the community

### Gas Town Alignment

Following proven patterns:
- Refinery processes merge queue → Archivist processes review queue
- Polecats are ephemeral workers → Critics are ephemeral reviewers
- Sequential processing (one at a time for now)
- Witness monitors both scholars and critics
- Capability ledger tracks decisions

---

## Current Status

### Working ✅
- Critic role template (comprehensive, well-structured)
- Manual spawning script
- Test critic spawned and running
- Workspace structure (`/atlantis/philosophy/critics/`)

### In Progress ⏳
- Critic-alpha reviewing Episteme's essay (running now)
- Need to attach and accept bypass consent

### Not Yet Implemented ⏱️
- Review request beads (bead type)
- Archivist role (adapted from Refinery)
- Automated review queue processing
- Archivist patrol molecule
- Multiple critic convergence logic
- Capability ledger file

---

## Next Steps

### Immediate (Test Current System)

1. **Attach to critic and accept consent:**
   ```bash
   docker compose exec atlantis tmux attach -t atlantis-critic-critic-alpha
   # Down arrow, Enter, Enter
   # Ctrl+B, D to detach
   ```

2. **Monitor critic progress:**
   - Check tmux session periodically
   - See if critic follows review structure
   - Observe quality of critique

3. **Read critic's review:**
   ```bash
   ./scripts/atlantis-container.sh exec "cat /atlantis/philosophy/critics/critic-alpha/reviews/*.md"
   ```

4. **Export review to first-works:**
   ```bash
   mkdir -p first-works/reviews
   # Copy review file
   ```

5. **Manually decide archival:**
   - Based on critic's recommendation
   - Record decision in simple ledger

### Short-Term (Minimal Automation)

1. **Create review bead types:**
   ```bash
   # Add to .beads schema
   bd create --type=review-request ...
   bd create --type=review ...
   ```

2. **Simple review queue:**
   ```bash
   bd list --type=review-request --status=open
   ```

3. **Archivist helper script:**
   - Reads review
   - Prompts for decision
   - Archives if approved
   - Records in ledger

### Medium-Term (Full Automation)

1. **Archivist role and patrol:**
   - Adapt `templates/refinery-CLAUDE.md`
   - Create `mol-archivist-patrol` molecule
   - Automated queue processing

2. **Multiple critics:**
   - Spawn 2-3 critics per work
   - Convergence logic (2/3 approval)
   - Handle disagreement cases

3. **Integration with scholar workflow:**
   - Scholars auto-create review requests on `gt done`
   - Review queue auto-assigns to critics
   - Approved works auto-archive

---

## Learnings from This Session

### Design Decisions

1. **Adapted, not invented:** Used Gas Town's Refinery pattern rather than creating something novel
2. **Episteme's framework:** Leveraged existing scholar's work as the assessment standard
3. **Minimal first:** Manual workflow before automation
4. **Test immediately:** Spawned real critic rather than just designing

### What Worked Well

1. **Meta-recursion is powerful:** Episteme proposes framework → we implement it → we test it on Episteme
2. **Gas Town patterns transfer:** Refinery → Archivist mapping was straightforward
3. **Templates guide behavior:** Comprehensive critic template with examples
4. **Incremental validation:** Test with one critic before building full system

### Open Questions

1. **Will AI critique AI meaningfully?**
   - Can critic identify genuine weaknesses?
   - Or just produce generic praise?
   - Will it apply standards rigorously?

2. **Is the convergent coherence framework sufficient?**
   - Does 1-5 scoring capture nuance?
   - Are 4 dimensions enough?
   - What about work that innovates beyond current standards?

3. **How handle disagreement?**
   - If 3 critics disagree (1 approve, 1 revise, 1 reject)?
   - Weight by critic track record?
   - Human tie-breaker?

4. **Quality vs. Quantity trade-off?**
   - Deep reviews take time/tokens
   - Can we afford thorough review at scale?
   - Or need expedited review for routine work?

---

## Architecture Diagram

```
Scholar Episteme (completed)
   │
   ├── essay-quality-assessment.md (26KB)
   └── investigation-notes.md (14KB)
        │
        ├── Exported to: first-works/episteme/
        └── Submitted for review (manual)
             │
             └── Review Request (future bead)
                  │
                  ├── Assigned to: Critic Alpha (spawned)
                  │    │
                  │    ├── ASSIGNMENT.md (work to review)
                  │    ├── Reads: scholars/episteme/essay-quality-assessment.md
                  │    ├── Applies: Convergent coherence framework
                  │    ├── Produces: reviews/episteme-ph-3rs-review.md
                  │    └── Recommendation: APPROVE/REVISE/REJECT
                  │
                  └── Future: Archivist reads review
                       │
                       ├── If APPROVE: Archive to first-works/
                       ├── If REVISE: Notify scholar
                       └── If REJECT: Do not archive
```

---

## Success Metrics

### Infrastructure (Achieved ✅)
- ✅ Critic role template created
- ✅ Spawning script works
- ✅ First critic spawned successfully
- ✅ Workspace structure established
- ✅ Review workflow documented

### Quality (Testing Now ⏳)
- ⏳ Critic produces structured review
- ⏳ Review applies convergent coherence criteria
- ⏳ Review provides substantive critique
- ⏳ Recommendation is justified

### Future Automation (Not Yet)
- ⏱️ Review queue beads functional
- ⏱️ Archivist patrol running
- ⏱️ Multiple critics converge on assessment
- ⏱️ Scholars auto-submit for review

---

## Comparison: Before vs. After

### Before This Session
- ❌ No way to assess scholar output quality
- ❌ No peer review mechanism
- ❌ Manual decision: archive or not?
- ❌ No intellectual standards enforcement

### After This Session
- ✅ Critic role defined and tested
- ✅ Review framework (convergent coherence)
- ✅ Manual review workflow operational
- ✅ First inter-agent critique in progress
- ⏳ Foundation for automated review queue

---

## Philosophical Note

**The meta-level is profound:**

Episteme asks: "How do we assess quality without ground truth?"
→ Proposes: Convergent coherence (mutual support of fallible criteria)
→ We implement: Critic role using that exact framework
→ Critic assesses: Episteme's own proposal

This is the essence of reflective equilibrium:
- Criteria and judgments mutually adjust
- Assessment applies to itself
- No external grounding needed
- Coherence emerges from systematic interrelation

If the critic approves Episteme's essay using Episteme's framework, we have:
- Demonstrated convergence (criterion → application → validation)
- Tested reflexivity (framework assesses itself)
- Shown pragmatic success (framework functions in practice)

If the critic finds problems, we learn:
- Where the framework breaks down
- What revisions are needed
- How to improve both framework and application

Either outcome advances New Atlantis's epistemology.

---

## Final Status

**Branch:** `new-atlantis-mvp`
**Commits:** 3 new commits this session
- Export Episteme's work to first-works
- Create critic role template
- Document peer review system

**Active Agents:**
- Scholar Episteme: COMPLETED (work exported)
- Critic Alpha: RUNNING (reviewing Episteme's essay)

**Next Session:**
- Read Critic Alpha's review
- Decide archival based on review
- Build minimal review queue system
- Spawn second critic for convergence test

---

**Session Duration:** ~60 minutes
**Breakthroughs:** Adapted Gas Town Refinery pattern to intellectual peer review
**Meta-Achievement:** Implementing Episteme's proposed framework to assess Episteme's work
**Philosophical Depth:** Reflective equilibrium in action

*"In critique we sharpen; in convergence we know; in reflexivity we grow."*
