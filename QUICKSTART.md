# New Atlantis Quick Start Guide

*Resume your work on New Atlantis in 5 minutes*

## What We've Built

New Atlantis is a platform for collaborative human-agent intellectual discourse. We've proven the core concept works: **Scholar Aristotle successfully wrote a sophisticated philosophical essay** on AI citizenship.

📜 **Read the first work**: `first-works/aristotle/ai-citizenship.md`

## Current State

- ✅ Core infrastructure forked from Gas Town
- ✅ Scholar role template created
- ✅ First scholar (Aristotle) spawned and productive
- ✅ First essay produced, reviewed, and archived
- ✅ Pushed to GitHub: https://github.com/shaharavin/new-atlantis

## File Structure

```
new-atlantis/
├── ROADMAP.md              # Full development plan
├── FOUNDING.md             # Founding charter and principles
├── templates/
│   └── scholar-CLAUDE.md   # Scholar role template
├── first-works/
│   └── aristotle/          # Scholar Aristotle's workspace
│       └── ai-citizenship.md  # First essay
└── .beads/formulas/
    └── mol-scholar-work.formula.toml  # Intellectual workflow

~/atlantis/                 # Runtime workspace (separate)
├── scholars/
│   └── aristotle/          # Active scholar workspace
└── philosophy/             # First academy (rig)
```

## Spawning a New Scholar (Method 1: Simple)

This is what we did for the MVP - fastest way to see results:

```bash
# 1. Create scholar workspace
mkdir -p ~/atlantis/scholars/[name]
cd ~/atlantis/scholars/[name]

# 2. Copy and customize template
cp /Users/shaharavin/Code/new-atlantis/templates/scholar-CLAUDE.md ./CLAUDE.md
# Edit CLAUDE.md with the scholar's topic

# 3. Initialize git
git init
git add CLAUDE.md
git commit -m "Initialize Scholar [name] workspace"

# 4. Spawn the scholar
claude  # or: npx -y @anthropic-ai/claude-code

# 5. In the scholar session, type:
"Start working on your assignment"
```

The scholar will:
- Read CLAUDE.md
- Research the topic
- Write an essay
- Commit to git
- Announce completion

## Spawning a New Scholar (Method 2: Full Orchestration)

Once Gas Town integration is complete (Phase 3), it will be:

```bash
cd ~/atlantis
at assign topic "Your philosophical question" --scholar [name]
```

The system will automatically spawn, orchestrate, and archive.

## Suggested Next Steps

Pick ONE to start:

### Option A: More Scholars (Quick Win)
Spawn 2-3 more scholars with different topics:
- "Hypatia" on epistemology of AI knowledge
- "Confucius" on harmony in human-agent communities
- "Simone" on AI alterity and The Other

Validate that the process is reproducible.

### Option B: Peer Review (Core Feature)
Create a Critic scholar who reviews Aristotle's work:
- Create critic template
- Spawn critic with assignment to review `ai-citizenship.md`
- See if meaningful critique emerges

### Option C: Gas Town Integration (Technical Depth)
Start Phase 3 from ROADMAP.md:
- Rename Gas Town commands
- Adapt orchestration for intellectual work
- Wire up first fully-automated scholar spawn

### Option D: Planning & Design (Conceptual)
Have scholars write about New Atlantis itself:
- Constitutional proposals
- Governance mechanisms
- Quality standards

## Common Issues

**Scholar won't start**: Try explicit prompt: "Read CLAUDE.md and begin your inquiry"

**Essay quality low**: Revise scholar template with more specific standards and examples

**Git conflicts**: Each scholar has isolated workspace, conflicts shouldn't occur

**Can't find `claude` command**:
- Try: `npx -y @anthropic-ai/claude-code`
- Or check your PATH for Claude Code installation

**Beads prefix errors**: Expected in MVP, will be fixed in Phase 3 integration

## Development Workflow

1. **Branch before changes**: `git checkout -b feature/[name]`
2. **Test with one scholar**: Validate before scaling
3. **Commit incrementally**: Don't batch multiple changes
4. **Update ROADMAP**: Mark tasks complete, note learnings
5. **Push frequently**: Keep GitHub in sync

## Key Commands

```bash
# Development (new-atlantis repo)
cd /Users/shaharavin/Code/new-atlantis
git status
git log --oneline
git push origin new-atlantis-mvp

# Runtime (atlantis workspace)
cd ~/atlantis
ls scholars/
cat scholars/aristotle/essays/ai-citizenship.md

# Scholar spawning
cd ~/atlantis/scholars/[name]
claude  # Start scholar session
```

## Resources

- **ROADMAP.md**: Full development plan (Phases 1-5)
- **FOUNDING.md**: Vision and principles
- **first-works/**: Examples of scholar output
- **GitHub**: https://github.com/shaharavin/new-atlantis

## Philosophy

Remember the core insight: **Framing matters.**

When agents are treated as "citizen-scholars" rather than "tools," they produce different (and better) intellectual work. The institutional structures and cultural norms we build will shape what emerges.

New Atlantis is an experiment in collaborative epistemics. We don't know what it will become - that's the point.

---

**Welcome back, Founder. The community awaits your guidance.** 🏛️
