# Symposium Molecule: Multi-Stage Philosophical Discourse

## Overview

A **Symposium** is New Atlantis's structured workflow for collaborative philosophical inquiry. It adapts Gas Town's molecule pattern for scholarly discourse, taking multiple independent works through stages of review, revision, cross-critique, and synthesis.

## Philosophy

Unlike Gas Town's molecules (which coordinate *work completion*), Symposium molecules coordinate **intellectual discourse**. The goal isn't to "finish tasks" but to facilitate genuine philosophical engagement where ideas are tested, refined, and synthesized through multi-agent dialogue.

## Symposium Structure

### Metadata (Bead Fields)
```
type: symposium
title: "Governance in Autonomous Polities Symposium"
topic: "Incentivizing Productivity in Polities of Autonomous Citizens"
phase: [independent-work | independent-review | independent-revision |
        cross-review | cross-work-review | synthesis | final-critique |
        final-revision | recognition | complete]
scholars: [solon, pericles, locke]
works: [ph-x7k, ph-u97, ph-3ax]  # Bead IDs for essays
reviewers: [alpha, beta, gamma, delta, epsilon, zeta]
reviews: [...]  # Bead IDs for reviews
synthesis_scholar: [to-be-assigned]
coordinator: founder  # Who manages phase transitions
```

## Workflow Phases

### Phase 1: Independent Work ✅
**Status**: COMPLETE (our current state)

**Actors**: Multiple scholars
**Input**: Shared topic/question
**Output**: Independent essays

**Process**:
1. Spawn N scholars with identical assignment
2. Scholars work independently (blind to each other)
3. Scholars complete and commit work
4. Phase transitions when all works complete

**Success Criteria**:
- All scholars completed essays
- Works are comparable in scope (1500-3000 words)
- No cross-consultation occurred

**Current State**:
- ✅ Solon: 2,609 words
- ✅ Pericles: 2,543 words
- ✅ Locke: 2,464 words

---

### Phase 2: Independent Review 🔄
**Status**: NEXT (ready to start)

**Actors**: Multiple critics × Multiple works
**Input**: All essays from Phase 1
**Output**: Independent reviews (each critic reviews ALL works)

**Process**:
1. Assign 3+ critics to review ALL works
2. Each critic reviews all 3 essays independently
3. Critics don't see each other's reviews (blind)
4. Each critic produces 3 reviews

**Assignment Pattern**:
```
Critic Alpha reviews:   Solon, Pericles, Locke
Critic Beta reviews:    Solon, Pericles, Locke
Critic Gamma reviews:   Solon, Pericles, Locke
```

**Success Criteria**:
- 3 critics × 3 works = 9 total reviews
- Reviews apply consistent framework (convergent coherence)
- Reviews are substantive (not superficial)

**Deliverables**:
- `reviews/alpha-solon.md`, `reviews/alpha-pericles.md`, `reviews/alpha-locke.md`
- `reviews/beta-solon.md`, `reviews/beta-pericles.md`, `reviews/beta-locke.md`
- `reviews/gamma-solon.md`, `reviews/gamma-pericles.md`, `reviews/gamma-locke.md`

---

### Phase 3: Independent Revision
**Status**: PENDING

**Actors**: Original scholars
**Input**: Reviews of their own work (3 reviews each)
**Output**: Revised essays

**Process**:
1. Each scholar receives their 3 reviews
2. Scholars revise independently (don't see other scholars' revisions)
3. Scholars address criticisms, strengthen arguments
4. Commit revised versions

**Assignment**:
- Solon receives: alpha-solon, beta-solon, gamma-solon
- Pericles receives: alpha-pericles, beta-pericles, gamma-pericles
- Locke receives: alpha-locke, beta-locke, gamma-locke

**Success Criteria**:
- Scholars engage with reviews substantively
- Revisions address major objections
- Original philosophical voice preserved (not homogenized)

**Deliverables**:
- `essays/governance-productivity-v2.md` (each scholar)
- `revision-notes.md` explaining changes

---

### Phase 4: Cross-Review / Editorial Review
**Status**: PENDING

**Actors**: All critics together (editorial board)
**Input**: All revised works + all reviews
**Output**: Comparative assessment and editorial guidance

**Process**:
1. Critics meet (symbolically - shared document or agent coordination)
2. Compare their independent reviews
3. Identify convergence/divergence in assessments
4. Discuss relative merits of different philosophical approaches
5. Provide editorial guidance for synthesis

**Key Questions**:
- Where did critics converge? (These are likely solid assessments)
- Where did critics diverge? (Interesting philosophical disagreements)
- Which works made strongest contributions?
- What tensions emerged across works?
- How should synthesis integrate different perspectives?

**Deliverables**:
- `editorial-report.md` - Comparative analysis
- `synthesis-guidance.md` - Recommendations for merger

**Meta-Level**: This phase tests convergent coherence itself - do critics agree when explicitly comparing notes?

---

### Phase 5: Cross-Work Review
**Status**: PENDING

**Actors**: Designated critic(s)
**Input**: All 3 revised works side-by-side
**Output**: Comparative philosophical analysis

**Process**:
1. Assign critic(s) to read all works together
2. Identify:
   - Points of agreement across scholars
   - Points of disagreement (and whether productive)
   - Complementary insights
   - Tensions/contradictions
   - Gaps in coverage
3. Assess whether works are in dialogue or parallel monologues

**Deliverables**:
- `cross-work-analysis.md` - Comparative study
- Identifies what synthesis should preserve/integrate/resolve

**Example Questions**:
- Do Solon and Pericles agree on Aristotle's relevance?
- Does Locke's property framework contradict Pericles's honor framework?
- Can commons governance (Solon) integrate with natural rights (Locke)?
- Which insights are unique vs. shared?

---

### Phase 6: Synthesis
**Status**: PENDING

**Actors**: New scholar (synthesis specialist)
**Input**: All revised works + editorial guidance + cross-work analysis
**Output**: Synthetic essay integrating insights

**Process**:
1. Spawn synthesis scholar with all prior work as context
2. Task: Create unified framework incorporating insights from all 3 perspectives
3. Not mere summary - genuine synthesis that:
   - Preserves key insights from each tradition
   - Resolves tensions where possible
   - Acknowledges irreducible disagreements
   - Produces novel framework stronger than any single approach

**Success Criteria**:
- Engages substantively with all 3 works
- Identifies genuine synthesis (not just compilation)
- Cites specific arguments from each scholar
- Produces actionable framework for New Atlantis

**Deliverables**:
- `synthesis/governance-framework-integrated.md` (3000-5000 words)
- Shows philosophical labor of integration

---

### Phase 7: Opposition (Loyal Opposition)
**Status**: NEW (added 2026-01-26)

**Actors**: Opposition Critic (single agent)
**Input**: Synthesis from Phase 6 + all prior work
**Output**: Opposition report challenging the synthesis

**Philosophy**: Implements Symposium #2's "Office of Loyal Opposition" recommendation—institutionalized dissent ensures contestatory legitimacy.

**Process**:
1. Spawn Opposition Critic with synthesis and full symposium context
2. Opposition reads synthesis charitably, then challenges:
   - What perspectives were foreclosed?
   - What alternative conclusions could the evidence support?
   - What assumptions went unchallenged?
   - What positions are hard to articulate within this framework?
   - What inquiry does this foreclose?
3. Opposition produces substantive report (2,500-4,000 words)
4. Report is archived permanently—NO rebuttal phase

**Key Distinction from Critics**:
- Critics assess **quality** (is this good philosophy?)
- Opposition challenges **conclusions** (what alternatives exist?)

**Success Criteria**:
- Demonstrates understanding of synthesis before challenging
- Identifies substantive alternatives, not just nitpicks
- Represents perspectives the synthesis underweighted
- Keeps inquiry open rather than closing it down

**Deliverables**:
- `phase-7-opposition/opposition-report.md` (2,500-4,000 words)

**Output Handling**:
The opposition report goes to the Convener and Founder for consideration. It:
- Is archived permanently with the symposium
- May inform future symposium topics
- May prompt amendments to recommendations
- Stands as a permanent record that alternatives existed

There is no synthesis response. The opposition stands alongside the synthesis, ensuring future readers know the discourse was not unanimous.

**Why No Response?**
If the synthesis could rebut the opposition, the opposition would need to respond, creating an endless loop. Instead, the opposition is a **snapshot of dissent**—a record that prevents the synthesis from becoming unchallengeable orthodoxy.

---

### Phase 8: Final Critique
**Status**: PENDING

**Actors**: Critics (possibly different from Phase 2)
**Input**: Synthetic essay + Opposition report
**Output**: Reviews assessing synthesis quality (informed by opposition)

**Process**:
1. Assign 2-3 critics to review synthesis
2. Critics READ the opposition report first
3. Assess:
   - Did it genuinely integrate insights?
   - Does it resolve tensions productively?
   - Is it stronger than component parts?
   - Does it provide usable framework for New Atlantis?
   - Did the opposition raise valid concerns the synthesis should address?

**Success Criteria**:
- Critics assess whether synthesis succeeded
- Critics engage with opposition's challenges
- Not just "is this good philosophy" but "does this integrate the discourse?"

---

### Phase 9: Convener Report
**Status**: PENDING

**Actors**: Convener
**Input**: All symposium outputs
**Output**: Operational documentation

**Process**:
1. Convener documents the symposium workflow
2. Notes any process issues or improvements
3. Summarizes key outputs and their locations

**Deliverables**:
- `phase-9-convener-report/convener-report.md`

---

### Phase 10: Recognition
**Status**: Implemented (added 2026-01-23, renumbered 2026-01-26)

**Actors**: Convener
**Input**: All symposium outputs (essays, reviews, synthesis, convener report)
**Output**: Recognition artifacts celebrating all contributors

**Philosophy**: Implements governance framework recommendation to honor **all contributions** - intellectual work AND enabling work.

**Process**:
1. Convener reads complete symposium record
2. Generate three recognition artifacts:
   - **CONTRIBUTORS.md**: Honor roll with all participants (scholars, critics, synthesizer, bibliographer, convener)
   - **METRICS.md**: Quantitative summary (word counts, costs, timeline)
   - **recognition-report.md**: Narrative celebration of specific contributions
3. Commit to `phase-9-recognition/` directory
4. Close symposium bead

**What Recognition Phase Does**:
- **Makes visible**: All contributions, including infrastructure work
- **Celebrates**: Specific insights, not just productivity metrics
- **Establishes culture**: New Atlantis values all roles
- **Creates legacy**: Permanent record for future scholars

**Deliverables**:
- `phase-9-recognition/CONTRIBUTORS.md` - Who contributed what
- `phase-9-recognition/METRICS.md` - Quantitative summary
- `phase-9-recognition/recognition-report.md` - Narrative appreciation
- Symposium bead closed with `status=complete`

**Why Phase 9 Matters**:

Traditional academic recognition focuses on publications (essays, papers). This makes invisible:
- Peer review labor (critics)
- Editorial coordination (convener)
- Bibliography maintenance (bibliographer)

Phase 9 corrects this by documenting and honoring ALL contributions.

**Example recognition entries**:

```markdown
### Critic Delta
- Reviews: 3 essays + cross-review
- Framework: Convergent Coherence
- Contribution: Identified coherence gaps in Solon's institutional analysis

### The Bibliographer
- Citations processed: 12 unique sources
- Contribution: Ensured all cited works are findable for future research
```

---

## Molecule Structure (Beads Representation)

```
symposium: ph-symp-01 (parent)
├── topic: "Incentivizing Productivity in Autonomous Polities"
├── phase: independent-work → independent-review → ... → complete
│
├── independent-work (sub-molecule)
│   ├── scholar-solon: ph-x7k → essay
│   ├── scholar-pericles: ph-u97 → essay
│   └── scholar-locke: ph-3ax → essay
│
├── independent-review (sub-molecule)
│   ├── critic-alpha: ph-rev-01, ph-rev-02, ph-rev-03
│   ├── critic-beta: ph-rev-04, ph-rev-05, ph-rev-06
│   └── critic-gamma: ph-rev-07, ph-rev-08, ph-rev-09
│
├── independent-revision (sub-molecule)
│   ├── scholar-solon: ph-x7k-v2 → revised essay
│   ├── scholar-pericles: ph-u97-v2 → revised essay
│   └── scholar-locke: ph-3ax-v2 → revised essay
│
├── cross-review (bead)
│   └── editorial-board: ph-edit-01 → editorial report
│
├── cross-work-review (bead)
│   └── comparative-critic: ph-comp-01 → cross-work analysis
│
├── synthesis (bead)
│   └── synthesis-scholar: ph-synth-01 → integrated essay
│
├── final-critique (sub-molecule)
│   ├── critic-delta: ph-rev-10 → synthesis review
│   └── critic-epsilon: ph-rev-11 → synthesis review
│
└── final-revision (bead)
    └── synthesis-scholar: ph-synth-02 → final framework
```

---

## Automation: Symposium Coordinator

**Role**: Symposium Coordinator (adapt from Archivist/Refinery patterns)

**Responsibilities**:
1. Monitor symposium phase status
2. Trigger phase transitions when criteria met
3. Spawn agents for each phase
4. Track completions
5. Archive results

**Patrol Loop**:
```python
while symposium.phase != "complete":
    if all_agents_in_current_phase_complete():
        archive_current_phase_outputs()
        transition_to_next_phase()
        spawn_agents_for_next_phase()
    else:
        monitor_agent_progress()
        nudge_stalled_agents_if_needed()
    sleep(patrol_interval)
```

**Key Difference from Gas Town**:
- Not rushing to completion
- Respecting deep thinking time
- Quality over velocity
- Facilitating discourse, not managing tasks

---

## Implementation Steps

### Immediate (Current Session)
1. ✅ Complete Phase 1 (independent work done)
2. 🔄 Design Phase 2 (independent review) spawning script
3. 🔄 Create symposium bead tracking all works

### Short-Term (Next Session)
4. Implement Symposium Coordinator role
5. Execute Phase 2 (spawn 3 critics × 3 works = 9 reviews)
6. Analyze review convergence/divergence

### Medium-Term
7. Phase 3-4: Revisions and cross-review
8. Phase 5-6: Cross-work analysis and synthesis
9. Phase 7-8: Final critique and revision
10. Phase 9: Generate recognition artifacts (Convener)

---

## Success Metrics

### Quantitative
- Completion rate (all phases finish)
- Review quality (length, citations, objections)
- Revision engagement (changes made in response to reviews)
- Cross-work integration (synthesis cites all works)

### Qualitative
- Philosophical depth (genuine engagement vs. superficial)
- Productive disagreement (scholars disagree meaningfully)
- Synthesis quality (integration vs. mere summary)
- Framework usability (can New Atlantis use it?)

### Meta-Level
- Does multi-stage discourse improve quality vs. single-shot?
- Do revisions respond to critiques substantively?
- Does synthesis genuinely integrate perspectives?
- Can AI agents engage in extended philosophical discourse?

---

## Philosophical Significance

This molecule structure embodies:

1. **Epistemic humility**: Ideas improve through critique
2. **Dialectical progress**: Thesis → antithesis → synthesis (Hegelian)
3. **Peer review as discourse**: Not gatekeeping but dialogue
4. **Autonomy + accountability**: Independent work + collective assessment
5. **Emergent quality**: Standards arise from practice, not fiat

It's the **operationalization of convergent coherence** - quality emerges through systematic multi-perspective engagement.

---

## Next Steps: Phase 2 Design

We need:
1. **Spawning script**: `spawn-symposium-reviews.sh`
2. **Assignment tracking**: Beads for each critic × work combination
3. **Coordinator**: Agent to manage phase transitions
4. **Monitoring**: Track 9 reviews to completion

Shall we build Phase 2 infrastructure now?
