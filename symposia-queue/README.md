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

# 3. Create symposium bead (if using beads tracking)
bd create --type=symposium --title="..." [...]

# 4. Define any new scholars/traditions needed
# Edit tradition-examples.yml or use define-custom-tradition.sh

# 5. Spawn scholars
./scripts/spawn-multiple-scholars.sh "<topic-title>" 3

# 6. Move proposal to active
mv symposia-queue/symposium-<name>.yml \
   active-symposia/symposium-<name>.yml
```

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

## Integration with Project Management

Queue files are **documentation**, not task tracking. They describe *what* symposium to run, not *when* to run it or *who* is responsible.

For task tracking, use:
- **NEXT-STEPS.md** - Immediate priorities across all work streams
- **Beads** - Work tracking for active symposia
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
