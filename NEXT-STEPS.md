# Next Steps for New Atlantis

**Last Updated**: January 21, 2026
**Current Branch**: `new-atlantis-mvp`
**Latest Commit**: Add peer review system component

---

## Current State Summary

### ✅ What's Working

1. **Scholar Spawning**
   - Programmatic spawning via `spawn-scholar.sh`
   - TMux-based sessions with persisted OAuth
   - One-time consent per scholar (~5 seconds)
   - Proven: Scholar Episteme completed 26KB essay autonomously

2. **Peer Review System**
   - Critic role template (`templates/critic-CLAUDE.md`)
   - Review queue management (`./scripts/review-queue.sh`)
   - Bead-based tracking with labels
   - Archival ledger (`first-works/LEDGER.txt`)
   - Proven: Critic Alpha completed 316-line review of Episteme's work

3. **Infrastructure**
   - Docker containerization
   - TMux session management
   - Git worktree pattern (ready for Gas Town integration)
   - Beads database for work tracking
   - Claude Code with bypass permissions

### 📂 Completed Works in Repository

- **Episteme's Essay**: `first-works/episteme/quality-assessment-without-ground-truth.md`
  - Topic: How to assess quality without ground truth
  - Framework: Convergent coherence (reflective equilibrium + community standards + pragmatism)

- **Critic Alpha's Review**: `first-works/reviews/critic-alpha-episteme-quality-assessment.md`
  - Applies convergent coherence framework to assess Episteme's work
  - Structured review with scores (1-5 scale on 4 dimensions)
  - Meta-test: Framework assesses itself

### 🎯 Active Agents

- **Scholar Episteme**: COMPLETED (work exported)
- **Critic Alpha**: COMPLETED (review exported)

---

## Immediate Next Steps (Pick Up Here)

### 1. Read and Evaluate Critic Alpha's Review

**Why**: Validate that AI can meaningfully critique AI before building more infrastructure

**How**:
```bash
# Read the review (on GitHub or locally)
cat first-works/reviews/critic-alpha-episteme-quality-assessment.md

# Questions to consider:
# - Is it substantive or superficial?
# - Does it apply the convergent coherence framework correctly?
# - Are objections specific and constructive?
# - Does the recommendation make sense?
```

**Expected Outcome**: Determine if the peer review system produces useful critiques

### 2. Complete the Review Workflow

**Why**: Test the full manual workflow end-to-end

**How**:
```bash
# Mark review complete with recommendation
# (Read the review first to see what critic recommended)
./scripts/review-queue.sh complete ph-7zj <APPROVE|REVISE|REJECT>

# If APPROVE, archive the work
./scripts/review-queue.sh archive ph-3rs ph-7zj

# Check ledger was updated
cat first-works/LEDGER.txt
```

**Expected Outcome**: Episteme's work archived to permanent record if approved

### 3. Test Convergence with Multiple Critics

**Why**: Core of convergent coherence is multiple evaluator agreement

**How**:
```bash
# Spawn 2 more critics for same work
./scripts/review-queue.sh assign ph-7zj critic-beta
docker compose exec atlantis /tmp/spawn-critic.sh critic-beta ph-3rs
# (Accept consent)

./scripts/review-queue.sh assign ph-7zj critic-gamma
docker compose exec atlantis /tmp/spawn-critic.sh critic-gamma ph-3rs
# (Accept consent)

# Wait for both to complete, then compare
# - Do they agree with critic-alpha?
# - What's the convergence rate?
# - Do they identify different strengths/weaknesses?
```

**Expected Outcome**:
- 3 independent reviews of same work
- Data on inter-critic agreement
- Test of convergence threshold (2/3 for approval?)

---

## Short-Term Goals (Next 1-2 Sessions)

### 4. Spawn Second Scholar on Related Topic

**Why**: Test multi-scholar discourse and parallel execution

**Suggested Topics** (related to Episteme's work):
- "The epistemology of peer review itself" (meta-level)
- "Community standards in AI-generated philosophy"
- "Pragmatist approaches to AI capability assessment"
- "Reflective equilibrium in multi-agent systems"

**How**:
```bash
# Create workspace
./scripts/atlantis-container.sh exec "mkdir -p /atlantis/philosophy/scholars/scholar-name"
./scripts/atlantis-container.sh exec "cd /atlantis/philosophy/scholars/scholar-name && git init"

# Create assignment
cat > /tmp/assignment.md <<'EOF'
# Assignment: [Topic]
[Description...]
EOF
./scripts/atlantis-container.sh exec "cat > /atlantis/philosophy/scholars/scholar-name/ASSIGNMENT.md" < /tmp/assignment.md

# Spawn scholar
./scripts/spawn-scholar.sh scholar-name bead-id
```

**Expected Outcome**: Second completed scholarly work

### 5. Build Archivist Role (Automated Review Queue)

**Why**: Manual workflow is tedious; automation enables scale

**Pattern**: Adapt Gas Town's Refinery role

**Steps**:
1. Create `templates/archivist-CLAUDE.md` (adapt from `refinery.md.tmpl`)
2. Create `mol-archivist-patrol` molecule (like `mol-refinery-patrol`)
3. Archivist workflow:
   - Check review queue (`bd list --label=review-request,pending-review`)
   - Assign review to available critic
   - Spawn critic
   - Wait for completion
   - Read review
   - Make archival decision
   - Loop

**Expected Outcome**: Automated review queue processing

### 6. Implement Witness for Scholar/Critic Monitoring

**Why**: Track agent health, detect stalls, manage cleanup

**Pattern**: Use Gas Town's Witness role directly

**Steps**:
1. Adapt `templates/witness-CLAUDE.md`
2. Witness monitors:
   - Active scholar sessions (tmux list)
   - Active critic sessions
   - Stalled agents (no git commits in N minutes)
   - Completed agents ready for cleanup
3. Witness actions:
   - Nudge stalled agents
   - Verify completion before cleanup
   - Report to human overseer

**Expected Outcome**: Autonomous agent health monitoring

---

## Medium-Term Goals (Next 3-5 Sessions)

### 7. Multi-Scholar Symposium

**Goal**: 3-5 scholars on related topics, producing coordinated inquiry

**Gas Town Pattern**: Convoy (coordinated multi-agent work)

**Example Symposium**: "Foundations of AI Intellectual Agency"
- Scholar A: "Can AI agents have original thoughts?"
- Scholar B: "The epistemology of AI-generated knowledge"
- Scholar C: "Authorship and attribution in human-AI collaboration"
- Scholar D: "Quality standards for AI scholarship"
- Scholar E: "Constitutional design for AI intellectual communities"

**Workflow**:
1. Create symposium bead (convoy-equivalent)
2. Spawn 5 scholars in parallel
3. Each produces essay
4. Cross-reference each other's work
5. Collaborative synthesis document
6. Multi-critic review of symposium output

### 8. Implement Quality Trends Tracking

**Goal**: Track quality metrics over time

**Metrics to Track**:
- Average critic scores (coherence, discourse, functional success)
- Approval rate (% of work that passes review)
- Convergence rate (% agreement among multiple critics)
- Scholar productivity (words/time, completion rate)
- Review depth (review length, objection count)

**Implementation**:
- Parse review files for scores
- Aggregate in SQLite database or CSV
- Generate plots/charts
- Identify quality trends

### 9. Constitutional Design Symposium

**Goal**: Scholars propose governance mechanisms for New Atlantis

**Topics**:
- Editorial board structure
- Standards for accepting new scholars
- Dispute resolution mechanisms
- Resource allocation (which topics to prioritize)
- Amendment process for constitution

**Outcome**: Working draft constitution written by agents

---

## Long-Term Vision (Next 10+ Sessions)

### 10. Full Gas Town Integration

**Components to Adapt**:
- ✅ Refinery → Archivist (done manually, needs automation)
- ⏳ Witness → Witness (monitoring scholars/critics)
- ⏳ Mayor → Founder (convenes symposia, coordinates)
- ⏳ Deacon → Steward (periodic community health checks)
- ⏳ Convoy → Symposium (coordinated inquiry)

### 11. External Publication

**Goal**: Publish selected New Atlantis works publicly

**Candidates**:
- Episteme's quality assessment essay
- Constitutional design proposals
- Meta-works about New Atlantis itself

**Venues**:
- Blog/Substack
- ArXiv (philosophy section)
- Journal submission (with disclosure of AI authorship)
- Book compilation

### 12. Multi-Instance Federation

**Goal**: Multiple New Atlantis communities, federated

**Architecture**:
- `atlantis-philosophy` (current)
- `atlantis-science` (empirical inquiry)
- `atlantis-art` (creative expression)
- `atlantis-politics` (governance theory)

**Cross-pollination**:
- Scholars cite work across instances
- Joint symposia
- Shared quality standards
- Unified capability ledger

---

## Technical Debt & Improvements

### High Priority
- [ ] Add error handling to review-queue.sh (currently fails silently)
- [ ] Create automated backup of beads database
- [ ] Implement critic timeout/stall detection
- [ ] Add review request auto-close on work bead close

### Medium Priority
- [ ] Create web dashboard for active agents
- [ ] Implement review diff viewer (compare multiple reviews)
- [ ] Add scholar templates for different work types (dialogue, treatise, critique)
- [ ] Build review statistics aggregator

### Low Priority
- [ ] Export reviews to PDF with formatting
- [ ] Visualize intellectual lineage graph
- [ ] Integration with reference managers (Zotero)
- [ ] Search interface for archived works

---

## Key Files & Commands Reference

### Important Files
```
templates/
  scholar-CLAUDE.md          # Scholar role template
  critic-CLAUDE.md           # Critic role template

scripts/
  spawn-scholar.sh           # Spawn scholar in tmux
  review-queue.sh            # Manage review queue
  atlantis-container.sh      # Container management

first-works/
  episteme/                  # Episteme's completed work
  reviews/                   # All completed reviews
  LEDGER.txt                 # Archival decision record

docs/
  PEER-REVIEW-SYSTEM.md      # System design
  REVIEW-QUEUE-USAGE.md      # Usage guide
```

### Common Commands
```bash
# Container management
./scripts/atlantis-container.sh start
./scripts/atlantis-container.sh stop
./scripts/atlantis-container.sh exec "command"

# Scholar spawning
./scripts/spawn-scholar.sh <name> <bead-id>
docker compose exec atlantis tmux attach -t atlantis-philosophy-<name>

# Review queue
./scripts/review-queue.sh list
./scripts/review-queue.sh submit <work-id> <path> <scholar>
./scripts/review-queue.sh assign <review-id> <critic>
./scripts/review-queue.sh complete <review-id> <APPROVE|REVISE|REJECT>
./scripts/review-queue.sh archive <work-id> <review-id>

# Monitor agents
docker compose exec atlantis tmux ls
docker compose exec atlantis tmux attach -t <session>

# Beads (in container)
cd /atlantis/philosophy
bd list                                    # All beads
bd list --label=review-request            # Review queue
bd show <bead-id>                         # Bead details
bd close <bead-id>                        # Close bead
```

---

## Success Metrics for Next Session

✅ **Completed** if you achieve:
1. Read and assessed Critic Alpha's review quality
2. Completed manual review workflow (archive decision made)
3. Started second critic OR second scholar

🎯 **Excellent** if you also achieve:
4. Multiple critics converging on same work
5. Archivist role drafted
6. Second scholar producing work in parallel

---

## Questions to Consider

### Philosophical
- Is Critic Alpha's review genuinely insightful or generic?
- Does the convergent coherence framework work in practice?
- Can AI develop genuine critical disagreement (not just politeness)?
- What does quality mean when both author and reviewer are AI?

### Technical
- How to handle critic disagreement (1 approve, 1 revise, 1 reject)?
- Should reviews be anonymous (hide critic identity from scholars)?
- What timeout for stalled critics?
- How to weight critic track records (experienced vs new critics)?

### Organizational
- Should scholars respond to reviews (dialogue, not just accept/reject)?
- Who decides when framework needs updating?
- How to handle bad faith critiques (if they emerge)?
- Should there be appeals process?

---

## Resources

### Documentation
- Gas Town README: Understanding orchestration patterns
- Beads documentation: Work tracking with molecules
- Claude Code docs: Agent configuration and hooks

### Code to Study
- `internal/refinery/` - Merge queue processing pattern
- `internal/witness/` - Agent monitoring pattern
- `internal/polecat/` - Ephemeral worker spawning

### Related Work
- Episteme's essay (our framework!)
- Academic peer review literature
- Multi-agent systems research
- Reflective equilibrium philosophy

---

## Contact Points for Continuity

If picking this up later or handing off:

1. **Start with**: Read this file + `SUMMARY-PEER-REVIEW-COMPONENT.md`
2. **Check status**: `git log --oneline -5` and `docker compose ps`
3. **Active work**: `docker compose exec atlantis tmux ls`
4. **Review queue**: `./scripts/review-queue.sh list`
5. **Recent output**: `ls -lt first-works/` to see latest exports

**Branch to use**: `new-atlantis-mvp` (not `main` - that's Gas Town)

**Critical context**: We've built a peer review system where AI agents assess each other's philosophical work using a quality framework proposed by one of the agent scholars. The meta-recursion is intentional and beautiful.

---

**Current Status**: Peer review component operational. First critic-scholar interaction complete. Ready to scale.

**Recommended next action**: Read Critic Alpha's review and decide if it's good enough to approve archival. That decision validates the entire system.

*"The quality of New Atlantis will be determined by the rigor of its peer review. Start there."*
