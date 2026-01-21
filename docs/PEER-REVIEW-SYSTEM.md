# Peer Review System

**Status**: Design phase - adapted from Gas Town Refinery pattern

## Overview

New Atlantis uses a **review queue** system adapted from Gas Town's merge queue pattern to manage peer review of scholarly work.

## Gas Town Pattern Mapping

| Gas Town | New Atlantis | Purpose |
|----------|--------------|---------|
| Refinery | **Archivist** | Processes review queue, makes archival decisions |
| Merge Request (MR) | **Review Request (RR)** | Tracks work pending review |
| Polecat | **Critic** | Ephemeral reviewer assigned to specific work |
| Merge Queue | **Review Queue** | Queue of works awaiting review |
| Witness | Witness | Monitors scholars/critics (same role) |

## Workflow

### 1. Scholar Completes Work

```bash
# Scholar finishes essay
cd /atlantis/philosophy/scholars/episteme
git commit -m "Essay: Quality assessment without ground truth"

# Scholar submits for review (creates review request bead)
bd create --type=review-request \
  --title="Review: Quality assessment essay by Episteme" \
  --work-id=ph-3rs \
  --work-path=scholars/episteme/essay-quality-assessment.md \
  --assignee=archivist

# Scholar exits
gt done
```

### 2. Archivist Processes Review Queue

```bash
# Archivist checks review queue
bd list --type=review-request --status=open

# Assigns work to critic
bd mol spawn mol-critic-review --assignee=critic-alpha \
  --var review_request_id=ph-rv-abc \
  --var work_path=scholars/episteme/essay-quality-assessment.md
```

### 3. Critic Reviews Work

```bash
# Critic spawns, reads assignment
cd /atlantis/philosophy/critics/critic-alpha
cat ../scholars/episteme/essay-quality-assessment.md

# Critic writes review following structure
cat > reviews/episteme-ph-3rs-review.md <<'EOF'
# Review: Quality Assessment in the Absence of Ground Truth
...
## Recommendation: APPROVE
EOF

# Critic commits and exits
git commit -m "Review: Episteme's quality assessment essay - APPROVE"
gt done
```

### 4. Archivist Archives Approved Work

```bash
# Archivist reads review
cat critics/critic-alpha/reviews/episteme-ph-3rs-review.md

# If APPROVED: archive to first-works
cp scholars/episteme/essay-quality-assessment.md \
   archives/essays/quality-assessment-episteme.md

# Close review request and work bead
bd close ph-rv-abc
bd close ph-3rs

# Record in capability ledger
echo "$(date -I) Archived: Episteme quality assessment essay (APPROVED by critic-alpha)" \
  >> archives/ledger.txt
```

## Bead Types

### review-request (Review Queue Item)

```bash
bd create --type=review-request \
  --title="Review: [Work title] by [Scholar]" \
  --work-id=[original work bead ID] \
  --work-path=[relative path to work file] \
  --assignee=archivist \
  --priority=2
```

**Fields:**
- `work_id`: Original work bead (e.g., ph-3rs)
- `work_path`: Path to the work file
- `scholar`: Who created the work
- `assignee`: Always starts with archivist

**Lifecycle:**
1. Created by scholar on `gt done`
2. Processed by archivist (assigns to critic)
3. Closed by archivist after review complete

### review (Critic's Review)

```bash
bd create --type=review \
  --title="Review of [Work title]" \
  --request-id=[review-request bead ID] \
  --work-id=[original work bead ID] \
  --assignee=critic-[name] \
  --priority=2
```

**Fields:**
- `request_id`: Links to review-request
- `work_id`: Original work bead
- `recommendation`: APPROVE / REVISE / REJECT
- `review_path`: Path to review markdown file

**Lifecycle:**
1. Created by archivist when assigning critic
2. Completed by critic with recommendation
3. Read by archivist for decision

## Convergent Coherence (Multiple Critics)

**Future**: Spawn multiple critics for same work to achieve convergence:

```bash
# Archivist spawns 3 critics for important work
for critic in alpha beta gamma; do
  bd create --type=review \
    --title="Review of Episteme quality essay" \
    --request-id=ph-rv-abc \
    --assignee=critic-$critic
done

# Archival decision based on convergence
# - 3/3 APPROVE → Archive immediately
# - 2/3 APPROVE → Archive with note
# - 1/3 APPROVE → Request revisions
# - 0/3 APPROVE → Reject
```

## Review Queue Commands

```bash
# View pending reviews
bd list --type=review-request --status=open

# View all reviews of a work
bd list --type=review --request-id=ph-rv-abc

# Check review queue size
bd list --type=review-request --status=open --count
```

## Archivist Patrol Molecule

**Future**: Create `mol-archivist-patrol` similar to `mol-refinery-patrol`:

1. **inbox-check** - Handle messages
2. **queue-scan** - Check review-request beads
3. **assign-critic** - Spawn critic for next review
4. **await-review** - Wait for critic completion
5. **read-review** - Read critic's recommendation
6. **archive-decision** - Approve/revise/reject
7. **loop-check** - More reviews? Loop back
8. **context-check** - Check context usage
9. **burn-or-loop** - Squash wisp, continue or exit

## Quality Standards

Reviews must assess using **convergent coherence criteria**:

1. **Internal Coherence** - Logical consistency, mutual support
2. **Engagement with Discourse** - Citations, prior work, objections
3. **Functional Success** - Clarity, problem-solving, generativity
4. **Explicit Reasoning** (AI work) - Transparent reasoning, limitations

## Review Format

See `templates/critic-CLAUDE.md` for full structure. Key sections:

- Summary (2-3 paragraphs)
- Strengths (specific, with evidence)
- Objections (specific, with suggestions)
- Scores (1-5 on each criterion)
- Recommendation (APPROVE/REVISE/REJECT)
- Meta-commentary (limitations of assessment)

## Ledger Tracking

All archival decisions recorded in `archives/ledger.txt`:

```
2026-01-20 Archived: Episteme quality assessment essay (APPROVED by critic-alpha)
2026-01-21 Rejected: Scholar X essay on Y (2/3 critics REJECT - insufficient engagement)
2026-01-22 Revision requested: Scholar Z treatise (coherence issues noted)
```

## Next Steps

1. ✅ Design review system (this document)
2. Create minimal review bead type
3. Adapt Refinery template → Archivist template
4. Create Critic scholar template
5. Spawn first critic to review Episteme's essay
6. Test: critic reviews, archivist archives
7. Build `mol-archivist-patrol` molecule

---

**Philosophy**: The review queue is not bureaucracy - it's the mechanism that ensures New Atlantis maintains intellectual standards while scaling. Like Gas Town's merge queue keeps main green, the review queue keeps the archive rigorous.
