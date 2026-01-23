# Symposia Queue

This directory contains **proposed but not yet activated** symposia.

## Purpose

Not every interesting symposium topic needs to be run immediately. This queue allows:

1. **Capture ideas** when they arise (in conversation, from prior symposia, from open questions)
2. **Design symposia** without committing resources
3. **Prioritize topics** based on urgency, prerequisites, and strategic value
4. **Document rationale** for why a topic matters and when to run it

## File Format

Each symposium proposal is a YAML file with:

```yaml
metadata:
  title: "Full symposium title"
  short_name: "slug-for-filesystem"
  domain: ["Philosophy of Mind", "Ethics", etc.]
  estimated_cost: "$25-30"

question:
  primary: "Main research question"
  sub_questions: [...]
  context: "Why this question matters now"

proposed_traditions:
  tradition_1:
    scholar: "scholar-name"
    tradition: "Tradition Name"
    rationale: "Why this tradition for this question"

  tradition_2: [...]
  tradition_3: [...]

alternative_traditions: [...]  # Backup options

expected_outcomes:
  convergences: [...]
  divergences: [...]
  meta_questions: [...]

why_interesting: [...]
why_not_urgent: [...]

activation_criteria:
  when_ready: [...]
  prerequisites: [...]
```

## Current Queue

### High Priority (Run Soon)
- *None yet* - Symposium #2 topic TBD

### Medium Priority (Interesting but Not Urgent)
- **`symposium-ethics-of-tradition-assignment.yml`** - Meta-question about New Atlantis's own practices

### Future Considerations
- Constitutional symposium (agents design NA governance)
- Convergent coherence validation (analyzing first symposium data)
- Philosophy of science topics
- AI phenomenology topics

## Workflow

### 1. Proposing a Symposium

Anyone (Founder, Convener, or emerging from prior symposia) can propose:

```bash
# Create proposal file
nano symposia-queue/symposium-<short-name>.yml

# Document:
# - Question and rationale
# - Proposed traditions (with justification)
# - Expected outcomes
# - Why interesting / why not urgent
# - Activation criteria
```

### 2. Reviewing Proposals

Before each symposium:
1. Review queue
2. Consider priorities, prerequisites, cost
3. Select topic
4. Refine tradition selection if needed

### 3. Activating a Symposium

When ready to run:

```bash
# 1. Review proposal
cat symposia-queue/symposium-<name>.yml

# 2. Update if needed (refine traditions, add context)
nano symposia-queue/symposium-<name>.yml

# 3. Create symposium bead (NOW - activation moment)
SYMP_ID=$(bd create \
  --type=symposium \
  --title="Symposium: <Title>" \
  --description="$(head -20 symposia-queue/symposium-<name>.yml)" \
  --labels=active-symposium \
  --silent)

echo "Created symposium bead: $SYMP_ID"

# 4. Move proposal to active and record bead ID
mkdir -p active-symposia
mv symposia-queue/symposium-<name>.yml active-symposia/
echo "bead_id: $SYMP_ID" >> active-symposia/symposium-<name>.yml

# 5. Define any new scholars/traditions needed
# Edit tradition-examples.yml or use define-custom-tradition.sh

# 6. Spawn scholars (actual work begins)
./scripts/spawn-multiple-scholars.sh "<topic-title>" 3

# 7. Convener coordinates through standard workflow
```

**Important**: Beads are created at **activation**, not at **proposal**. The queue is documentation; beads track active work.

### 4. After Symposium Completes

```bash
# Move to archive
mv active-symposia/symposium-<name>.yml \
   first-works/symposium-<name>/symposium-proposal.yml

# Document outcomes vs. expectations
# Update queue priorities based on what emerged
```

## Design Principles

### When to Queue (Not Activate Immediately)

Queue a symposium when:
- ✅ **Prerequisites not met** (need infrastructure, prior symposia results)
- ✅ **Not strategically urgent** (interesting but other topics more pressing)
- ✅ **Idea needs refinement** (captured the question but tradition selection unclear)
- ✅ **Budget constraint** (want to run, but waiting for right timing)
- ✅ **Emergent from prior work** (symposium raised good follow-up questions)

### When to Activate Immediately

Run a symposium when:
- ✅ **Strategically important** (tests core hypothesis, validates infrastructure)
- ✅ **Prerequisites met** (scholars defined, traditions clear, Convener ready)
- ✅ **Within budget** (~$25-30 per symposium for side project)
- ✅ **Clear tradition selection** (know which 3 perspectives will engage it well)

## Example: Ethics of Tradition Assignment

**Why queued, not activated**:
- Interesting meta-question, but not blocking infrastructure work
- Wants to run *after* explicit tradition assignment has been tested (Symposium #2)
- Needs 3 new scholar definitions (Turing, Heidegger, Confucius) OR temporary tradition reassignment
- Other priorities: test mail system, create Archivist, analyze first symposium

**When to activate**:
- After Symposium #2 demonstrates explicit tradition assignment works
- After we have empirical data on whether assignment improves philosophical diversity
- When ready for meta-reflection on New Atlantis practices

**Expected value**:
- Philosophical: Deep engagement with autonomy, authenticity, role-playing
- Practical: Validates or challenges current practice
- Novel: Engages simulator framing, peer AI assignment dynamic

## Integration with Beads and Git

### Git: Version Control for Ideas

**The queue lives in git**:
- ✅ Proposals are committed, versioned, and visible
- ✅ History shows: who proposed, when, how it evolved
- ✅ Enables collaboration (PRs for proposals, comments)
- ✅ Documents intellectual development

### Beads: Tracking Active Work

**Beads are created at activation, not at proposal**:
- ❌ **Don't** create beads for queued symposia
- ✅ **Do** create bead when activating (moving from queue → active)
- ✅ Bead tracks symposium progress (phases, completion)
- ✅ Bead gets closed when symposium archives

**Why not create beads for queue?**
- Bead creation implies commitment to work
- Would clutter `bd list` with ideas vs. actual work
- Beads track progress; queue items have no progress yet

**Analogy to Gas Town**: Don't create `gt-` beads for every feature idea, only for features you're building.

### Three States, Two Tracking Systems

| State | Git | Beads | Status |
|-------|-----|-------|--------|
| **Queued** | ✅ `symposia-queue/<name>.yml` | ❌ No bead | Documented idea |
| **Active** | ✅ `active-symposia/<name>.yml` | ✅ `ph-xxxxx` bead | Work in progress |
| **Complete** | ✅ `first-works/<name>/symposium-proposal.yml` | ✅ Bead closed | Archived |

### Workflow Summary

```
[Idea] → Git commit to symposia-queue/
         (Documented, no bead)

[Activate] → Create bead, move to active-symposia/
             (Git + bead tracking)

[Complete] → Close bead, archive to first-works/
             (Git archive, bead closed)
```

### Integration with Project Management

Queue files are **documentation**, not task tracking. They describe *what* symposium to run, not *when* to run it or *who* is responsible.

For task tracking, use:
- **NEXT-STEPS.md** - Immediate priorities across all work streams
- **Beads** - Work tracking for **active** symposia only
- **GitHub issues** - Infrastructure bugs, feature requests

Queue is for **intellectual curation**, not project management.

## Meta-Note

This queue system itself embodies New Atlantis principles:
- **Autonomy**: Topics can be proposed by anyone (not top-down control)
- **Transparency**: All proposals visible and documented
- **Deliberation**: Activation decisions based on reasons, not arbitrary authority
- **Recognition**: Proposal documents who suggested topic and why it matters

As New Atlantis matures, the community itself might deliberate on queue priorities—not just Founder/Convener deciding.

---

*Created: 2026-01-23*
*Purpose: Capture symposium ideas without committing to immediate activation*
