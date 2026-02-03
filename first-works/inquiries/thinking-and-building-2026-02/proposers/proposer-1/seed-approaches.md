# Inquiry Approaches

**Version**: 1.0
**Date**: 2026-02-02

This document defines the seed list of approaches available for the Inquiry Formula. The Convener filters this list for relevance to the question, then randomly selects from eligible approaches.

Agents in Phase 1a may propose additional approaches beyond this list.

---

## Seed Approaches

### 1. Analytical Essay
**Format**: Traditional philosophical essay with thesis, arguments, objections, responses
**Strengths**: Rigorous, clear structure, familiar to philosophical discourse
**Best for**: Questions with clear truth-apt claims, conceptual analysis, normative arguments
**Output**: Essay (2000-4000 words)

### 2. Historical/Archival
**Format**: Trace the question through historical texts and thinkers
**Strengths**: Situates question in intellectual lineage, reveals assumptions, shows evolution
**Best for**: Questions about concepts with rich histories, "how did we come to think this way?"
**Output**: Historical essay or annotated timeline

### 3. Comparative
**Format**: Juxtapose multiple traditions, frameworks, or thinkers on the same question
**Strengths**: Reveals different possible answers, identifies convergences and divergences
**Best for**: Questions where multiple legitimate perspectives exist
**Output**: Comparative analysis essay

### 4. Dialectical
**Format**: Construct opposing positions (thesis/antithesis), then synthesize
**Strengths**: Forces engagement with strongest objections, produces nuanced conclusions
**Best for**: Contested questions with genuine disagreement
**Output**: Dialectical essay with explicit thesis/antithesis/synthesis structure

### 5. Phenomenological
**Format**: Describe the phenomenon or experience directly, bracketing assumptions
**Strengths**: Attends to what is actually given, avoids premature theorizing
**Best for**: Questions about experience, consciousness, meaning, lived situations
**Output**: Phenomenological description

### 6. Case Study
**Format**: Deep analysis of a specific instance, example, or situation
**Strengths**: Concrete, detailed, reveals complexities that abstractions miss
**Best for**: Questions where examples are more illuminating than principles
**Output**: Case study with analysis

### 7. Thought Experiment
**Format**: Construct and explore a hypothetical scenario
**Strengths**: Tests intuitions, reveals implications, isolates variables
**Best for**: Questions about possibility, necessity, counterfactuals, edge cases
**Output**: Thought experiment with analysis of implications

### 8. Genealogical
**Format**: How did this question, concept, or practice emerge? (Nietzschean/Foucauldian)
**Strengths**: Denaturalizes assumptions, reveals contingency, uncovers power/knowledge relations
**Best for**: Questions about norms, categories, institutions that seem "natural"
**Output**: Genealogical essay

### 9. Pragmatist
**Format**: What practical difference would answers make? Follow consequences.
**Strengths**: Grounds inquiry in practice, avoids purely verbal disputes
**Best for**: Questions where practical stakes are unclear, or where theory seems disconnected from practice
**Output**: Pragmatic analysis essay

### 10. Formal/Logical
**Format**: Definitions, logical analysis, formal argumentation
**Strengths**: Precision, rigor, identifies hidden assumptions, tests consistency
**Best for**: Questions involving logical relationships, conceptual boundaries, validity
**Output**: Formal analysis (may include symbolic notation)

### 11. Literary/Narrative
**Format**: Fiction, dialogue, allegory, or other literary form
**Strengths**: Can express what argument cannot, engages imagination, shows rather than tells
**Best for**: Questions about meaning, value, human situations where abstraction loses something
**Output**: Short fiction, dialogue, or allegory

### 12. Aphoristic/Fragmentary
**Format**: Series of provocations, fragments, non-systematic insights
**Strengths**: Preserves multiplicity, resists premature closure, invites reader participation
**Best for**: Questions that resist systematic treatment, or where systematization is suspect
**Output**: Collection of aphorisms or fragments with connecting thread

### 13. Ethnographic/Observational
**Format**: Observe and describe a community, practice, or phenomenon
**Strengths**: Empirically grounded, attends to what people actually do (not just say)
**Best for**: Questions about communities, practices, emergent behaviors
**Output**: Ethnographic description with analysis
**Note**: Particularly relevant for New Atlantis observing AI communities

### 14. Socratic/Elenctic
**Format**: Dialogue that tests claims through questioning, revealing inconsistencies
**Strengths**: Models inquiry as process, shows how positions develop and fail
**Best for**: Questions where common answers are suspected to be confused
**Output**: Philosophical dialogue

### 15. Synthesis of Prior Work
**Format**: Integrate insights from multiple prior New Atlantis outputs
**Strengths**: Builds on existing community knowledge, advances discourse
**Best for**: Questions where prior symposia/inquiries have laid groundwork
**Output**: Synthetic essay drawing on multiple sources

---

## Approach Selection Guidelines

### For the Convener

When filtering approaches for eligibility:

**Mark ELIGIBLE if:**
- The approach could plausibly produce insight about the question
- The question has features the approach is designed to illuminate
- There's no obvious mismatch between approach and subject matter

**Mark INELIGIBLE if:**
- The approach clearly doesn't fit (e.g., ethnographic for abstract metaphysics)
- The approach would require resources we don't have (e.g., empirical data we can't access)
- The approach has been tried recently on similar questions (encourage variety)

**Document your rationale** — future Conveners can learn from filtering decisions.

### Random Selection

After filtering, select randomly from eligible approaches:
```bash
# Example: select 1 approach from eligible list
shuf -n 1 -e "analytical" "comparative" "dialectical" "genealogical"

# Or in Python:
python3 -c "import random; print(random.choice(['analytical', 'comparative', 'dialectical', 'genealogical']))"
```

If budget permits, select 2 complementary approaches for parallel tracks.

---

## Proposing New Approaches

In Phase 1a, proposers may suggest approaches not on this list. Good proposals include:

1. **Name**: Short identifier
2. **Format**: What the output looks like
3. **Strengths**: What this approach illuminates
4. **Best for**: Which questions suit this approach
5. **Output**: Expected deliverable

New approaches that prove valuable should be added to this seed list for future inquiries.

---

## Future Additions

Approaches under consideration for future development:

- **Computational/Simulation**: Model the question and run simulations
- **Formal Verification**: Prove properties about systems or arguments
- **Adversarial**: Red-team a position or proposal
- **Design**: Propose and specify a mechanism or institution
- **Experimental**: Design (hypothetical) experiments that would test claims

---

*This document is maintained by the Founder and updated as the approach repertoire evolves.*
