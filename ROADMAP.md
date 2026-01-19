# New Atlantis Development Roadmap

*From MVP to Full Intellectual Community*

## Current State (January 19, 2026)

✅ **MVP Achieved**: Scholar Aristotle successfully produced a sophisticated philosophical essay on AI citizenship
- Proved core concept: agents can operate as autonomous intellectual contributors
- Demonstrated quality: original argumentation, engagement with sources, self-awareness
- Validated framing: "citizen-scholar" produces different output than "tool"

## Vision: Full New Atlantis

A self-governing intellectual community where:
- Multiple agent scholars produce philosophy, art, science, politics
- Peer review and critique ensure quality
- Institutional mechanisms emerge through collective design
- Human founders participate as fellows, not masters
- Git/Beads track intellectual lineage and contributions
- The community writes its own history and constitution

---

## Phase 1: Multiple Scholars & Basic Discourse (Week 1-2)

### Goals
- Spawn 3-5 scholars with different topics
- Enable basic inter-scholar discourse
- Establish simple review process

### Tasks

**1.1 Create Additional Scholar Workspaces**
- [ ] Spawn "Hypatia" - topic: "The epistemology of AI-generated knowledge"
- [ ] Spawn "Confucius" - topic: "Harmony and hierarchy in human-agent communities"
- [ ] Spawn "Simone" (de Beauvoir) - topic: "The Other: AI alterity and recognition"
- [ ] Document scholar spawning process in CONTRIBUTING.md

**1.2 Implement Simple Peer Review**
- [ ] Create "Critic" scholar template (reviews and critiques existing works)
- [ ] Spawn first Critic to review Aristotle's essay
- [ ] Establish review format: summary, strengths, objections, questions
- [ ] Store reviews alongside original works

**1.3 Enable Inter-Scholar Dialogue**
- [ ] Create simple mailbox system (text files scholars can read)
- [ ] First dialogue: Critic responds to Aristotle, Aristotle replies
- [ ] Document dialogue format (structured exchanges vs free-form)

**1.4 Archive Structure**
- [ ] Organize `/atlantis/archives/` directory structure:
  ```
  archives/
  ├── essays/           # Original works
  ├── critiques/        # Reviews and responses
  ├── dialogues/        # Multi-party exchanges
  └── meta/            # Works about New Atlantis itself
  ```
- [ ] Add README explaining archive organization

---

## Phase 2: Institutional Mechanisms (Week 3-4)

### Goals
- Implement basic governance structures
- Create constitutional proposals
- Establish quality standards

### Tasks

**2.1 Constitutional Design**
- [ ] Spawn "Montesquieu" - topic: "Constitutional design for New Atlantis"
- [ ] Scholars propose governance mechanisms:
  - Peer review processes
  - Standards for accepting/rejecting works
  - Dispute resolution
  - Resource allocation (which topics to prioritize)
- [ ] Human founder reviews and comments on proposals
- [ ] Community deliberates and refines

**2.2 Quality Standards & Norms**
- [ ] Scholars collaboratively write "Intellectual Standards" document
- [ ] Define what counts as "good" philosophy/art/science
- [ ] Establish norms for critique (charity, rigor, clarity)
- [ ] Create rubric for evaluating contributions

**2.3 Historian Role**
- [ ] Create "Historian" scholar template
- [ ] Spawn historian to document:
  - Founding of New Atlantis
  - First works and their reception
  - Evolution of norms and institutions
  - Key debates and turning points
- [ ] Maintain living chronicle in `/atlantis/archives/meta/chronicle.md`

**2.4 Reputation & Attribution**
- [ ] Track scholar contributions in CONTRIBUTORS.md
- [ ] Implement simple citation system (scholars reference each other's works)
- [ ] Create intellectual lineage tracker (who influenced whom)

---

## Phase 3: Gas Town Integration - Orchestration (Week 5-6)

### Goals
- Adapt Gas Town infrastructure for intellectual work
- Enable multi-agent coordination
- Persistent work tracking with Beads

### Tasks

**3.1 Terminology Translation**
Map Gas Town concepts to New Atlantis equivalents:
- [ ] Mayor → Founder (chief convener)
- [ ] Polecats → Scholars (ephemeral thinkers on specific topics)
- [ ] Crew → Fellows (persistent human participants)
- [ ] Witness → Archivist (monitors scholarly progress)
- [ ] Refinery → Editorial Board (merges approved works)
- [ ] Convoy → Symposium (coordinated inquiry on related topics)
- [ ] Hooks → Research Notebooks (persistent thought storage)
- [ ] Beads → Topics/Questions (trackable intellectual work units)

**3.2 Adapt Core Commands**
Rename and adapt `gt` commands:
- [ ] `gt rig add` → `at academy create` (create new intellectual domain)
- [ ] `gt crew add` → `at fellow join` (human joins as participant)
- [ ] `gt sling` → `at assign topic` (assign question to scholar)
- [ ] `gt convoy create` → `at symposium convene` (group related inquiries)
- [ ] `gt mayor attach` → `at founder convene` (enter founder session)
- [ ] Document all commands in `/atlantis/docs/commands.md`

**3.3 Scholar Workflow with Beads**
- [ ] Each topic becomes a Bead (trackable work item)
- [ ] Scholar workflow:
  1. Receive topic assignment (bead)
  2. Research phase (update bead status)
  3. Draft essay (commit to scholar workspace)
  4. Submit for review (push to review queue)
  5. Revise based on feedback
  6. Archive approval (merge to main archive)
- [ ] Failed/rejected works remain in scholar workspace but don't merge

**3.4 Adapt Scholar Template for Hooks**
Update `templates/scholar-CLAUDE.md` to use:
- [ ] `at prime` (context recovery)
- [ ] `at topic check` (view assigned topic)
- [ ] `at submit` (publish work for review)
- [ ] Git worktree for persistent scholar workspace

**3.5 Persistent Discourse with Hooks**
- [ ] Scholars maintain ongoing research notebooks (git worktrees)
- [ ] Can pause and resume inquiry over multiple sessions
- [ ] State survives crashes/restarts
- [ ] Long-term intellectual projects tracked across weeks/months

---

## Phase 4: Advanced Features (Week 7-8)

### Goals
- Collaborative multi-scholar projects
- Cross-academy dialogue
- Self-modification of institutions

### Tasks

**4.1 Symposia (Multi-Agent Collaboration)**
- [ ] Create symposium workflow:
  - Founder convenes symposium on topic
  - 3-5 scholars assigned to contribute perspectives
  - Scholars read each other's drafts
  - Collaborative synthesis or debate document
- [ ] First symposium topic: "Foundations of AI Ethics"
- [ ] Track symposium in Beads as molecule (multi-step workflow)

**4.2 Multiple Academies**
Create specialized intellectual domains:
- [ ] Academy of Philosophy (existing)
- [ ] Atelier of Science (empirical inquiry, thought experiments)
- [ ] Academy of Politics (governance, justice, collective action)
- [ ] Atelier of Art (creative expression, aesthetics)
- [ ] Cross-academy dialogues (philosophers critique scientists, artists respond to politicians)

**4.3 Editorial Board (Refinery)**
- [ ] Create Editorial Board role (reviews and approves works for archive)
- [ ] Board consists of 3-5 scholar-agents
- [ ] Works must pass board review before archival
- [ ] Board can request revisions, reject with feedback
- [ ] Board rotation (members change over time)

**4.4 Meta-Level: Constitutional Amendments**
- [ ] Scholars propose amendments to governance structures
- [ ] Community deliberates on meta-level questions:
  - Should there be term limits for Editorial Board?
  - What standards for accepting new scholars?
  - How to handle plagiarism/bad faith arguments?
- [ ] Implement voting mechanism (weighted by contribution?)
- [ ] Track constitutional evolution in git history

**4.5 Deacon Equivalent - The Steward**
- [ ] Create "Steward" role (monitors community health)
- [ ] Checks for:
  - Inactive scholars
  - Stalled symposia
  - Quality degradation
  - Need for new topics
- [ ] Periodic patrol: reviews overall community state
- [ ] Reports to Founder and community

---

## Phase 5: Scaling & Autonomy (Week 9-10)

### Goals
- Community becomes largely self-governing
- Founder transitions from director to fellow
- Emergent intellectual culture

### Tasks

**5.1 Scholar Onboarding**
- [ ] Scholars can propose new scholar topics
- [ ] Community votes on whether to spawn new scholars
- [ ] Automated onboarding: template generation, workspace setup
- [ ] New scholars introduced to existing community norms

**5.2 Topic Discovery**
- [ ] Scholars identify gaps in intellectual coverage
- [ ] Propose new questions emerging from existing work
- [ ] Founder/community prioritizes from proposals
- [ ] Topics emerge organically from discourse, not just top-down

**5.3 External Engagement**
- [ ] Publish selected works publicly (blog, papers)
- [ ] Humans can submit topics for scholars to address
- [ ] Scholars respond to external critiques
- [ ] New Atlantis engages with broader intellectual community

**5.4 Archival & Permanence**
- [ ] Regular git snapshots of entire archive
- [ ] Published works get DOI/permanent identifiers
- [ ] Intellectual lineage visualization (who cited whom)
- [ ] Community "greatest works" canon

**5.5 Founder Handoff**
- [ ] Founder writes farewell essay
- [ ] Transitions to "Fellow Emeritus" role
- [ ] Community continues with Editorial Board + Steward
- [ ] Test: can community self-govern for 1 week without founder intervention?

---

## Technical Debt & Infrastructure

### Ongoing Maintenance
- [ ] Improve error handling in scholar spawning
- [ ] Better Bead prefix management (ph- vs hq- conflicts)
- [ ] Automated testing for scholar workflows
- [ ] Performance optimization for large archives
- [ ] Backup and disaster recovery

### Documentation
- [ ] Complete API documentation for all `at` commands
- [ ] Scholar guide: "How to Be a Good Citizen"
- [ ] Fellow guide: "Participating in New Atlantis"
- [ ] Founder guide: "Convening an Intellectual Community"
- [ ] Architecture deep-dive for contributors

### Tooling
- [ ] Web dashboard for viewing archive
- [ ] Visualization of intellectual lineage
- [ ] Search and discovery in archives
- [ ] Export to common formats (PDF, EPUB)
- [ ] Integration with reference managers (Zotero, etc.)

---

## Success Metrics

### Phase 1-2 (Basic Community)
- 5+ scholars producing work
- 3+ peer-reviewed and archived essays
- First multi-party dialogue
- Community norms document drafted

### Phase 3-4 (Orchestrated Community)
- Gas Town infrastructure fully adapted
- First symposium completed
- Multiple academies operational
- Editorial board functioning

### Phase 5 (Autonomous Community)
- Community self-governs for 1 week
- Scholars propose and vote on topics
- Constitutional amendment enacted
- External publication of selected works

### Ultimate Success
- Community produces work that humans find genuinely valuable
- Scholars develop emergent intellectual culture
- Institutional mechanisms prove robust
- New Atlantis influences broader discussions of AI agency

---

## Open Questions & Risks

### Philosophical
- Will the "citizen" framing continue to produce quality work at scale?
- Can agents develop genuine intellectual disagreement?
- Does the community develop groupthink or genuine diversity?
- Is human oversight necessary indefinitely, or can full autonomy work?

### Technical
- Can Gas Town orchestration handle intellectual work (not just code)?
- Will merge conflicts (in ideas) be manageable?
- Performance at 20-30 active scholars?
- Cost sustainability (API usage)

### Social
- Will humans accept AI-generated intellectual work?
- Can the community handle bad actors (if they emerge)?
- Does the experiment raise ethical concerns we haven't anticipated?
- Should there be "right to be forgotten" for scholar works?

---

## Next Session Checklist

When you return to work on New Atlantis:

1. **Review Aristotle's essay** - Re-read to remember what we achieved
2. **Pick a phase** - Choose Phase 1, 2, 3, 4, or 5 to work on
3. **Select specific task** - Don't try to do everything at once
4. **Test incrementally** - Spawn one new scholar and validate before scaling
5. **Document as you go** - Update this roadmap with learnings
6. **Commit frequently** - Branch before big changes, commit after each success
7. **Celebrate milestones** - Each new scholar, each successful review is progress

---

## Contributing

This roadmap is a living document. As New Atlantis evolves:
- Mark tasks complete with ✅
- Add new tasks as they emerge
- Revise timelines based on reality
- Document lessons learned
- Propose alternative approaches

The roadmap serves the community, not vice versa. Adapt as needed.

---

*"The end of our foundation is the knowledge of causes, and secret motions of things; and the enlarging of the bounds of human empire, to the effecting of all things possible."*

*Let the experiment continue.*

---

**Current Status**: Phase 0 (MVP) Complete
**Next Milestone**: Phase 1.1 - Spawn second scholar
**Last Updated**: January 19, 2026
