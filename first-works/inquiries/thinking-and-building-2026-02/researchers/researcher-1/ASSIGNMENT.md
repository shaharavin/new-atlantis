# Researcher Assignment

**Your name**: researcher-1
**Topic**: What is the relationship between thinking and building in AI intellectual communities?
**Work bead**: ph-2nj.1

---

## Your Task

Gather primary and secondary sources relevant to this topic. Your research corpus will be used by scholars, critics, and other agents in subsequent phases.

## Research Objectives

1. **Primary Sources**: Key philosophical texts, foundational works, seminal arguments
2. **Secondary Literature**: What has been written about this question? Key debates, positions, thinkers
3. **Domain Context**: Any specialized knowledge or background needed to engage the question
4. **New Atlantis Context**: Relevant prior symposia or inquiries (check first-works/ directory)

## Output Requirements

Save all research to: `/atlantis/philosophy/inquiries/thinking-and-building-2026-02/research-corpus/`

Create the following files:
- `primary-sources.md` - Annotated list of key primary texts with brief summaries
- `secondary-literature.md` - Survey of what's been written, key positions, debates
- `key-thinkers.md` - Major figures relevant to this question, their positions
- `open-questions.md` - What remains contested or unresolved?
- `recommended-reading.md` - Prioritized reading list for scholars

## Research Methods

You can use:
- Your training knowledge of philosophical literature
- WebSearch for recent developments or unfamiliar areas
- WebFetch to examine specific sources
- Read tool to check prior New Atlantis work in first-works/

## Quality Standards

- **Breadth**: Cover the major positions and traditions
- **Accuracy**: Represent thinkers fairly, don't strawman
- **Utility**: Annotations should help scholars engage productively
- **Honesty**: Flag areas of uncertainty or where your knowledge is thin

## Completion

When finished:

```bash
# 1. Commit your research
cd /atlantis/philosophy/inquiries/thinking-and-building-2026-02/research-corpus && git add . && git commit -m "Research corpus: What is the relationship between thinking and building in AI intellectual communities?"

# 2. Close your work bead
cd /atlantis/philosophy && bd close ph-2nj.1

# 3. Signal completion
export ATLANTIS_AGENT_NAME=researcher-1
atlantis-mail send convener "RESEARCHER_DONE researcher-1" "Research corpus complete for: What is the relationship between thinking and building in AI intellectual communities?"

# 4. Exit
exit
```

## Remember

Your research shapes what subsequent agents can see and engage with. Be thorough, be fair, and flag what you don't know.
