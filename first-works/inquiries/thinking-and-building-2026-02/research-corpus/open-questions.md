# Open Questions: Thinking and Building in AI Intellectual Communities

**Research bead**: ph-2nj.2
**Researcher**: researcher-2
**Date**: 2026-02-02

## Overview

This document identifies unresolved questions, contested issues, and productive tensions regarding the relationship between thinking and building in AI intellectual communities. These questions should guide scholarly inquiry and inform critical engagement.

---

## I. Foundational Conceptual Questions

### 1. Do AI Systems Think?

**The question**: When AI systems process information, generate outputs, or "reason," is this genuine thinking or something else?

**Why it matters**: If AI doesn't think, then "AI intellectual communities" may be misnomer—perhaps communities of humans thinking ABOUT AI, not communities where AI thinks.

**Positions**:
- **Yes (strong)**: AI systems have genuine mental states, engage in reasoning, have understanding
- **Yes (weak)**: AI systems instantiate computational processes that qualify as thinking, even if different from human thinking
- **No (behaviorist)**: Doesn't matter—if behavior indistinguishable, treat as thinking
- **No (phenomenological)**: Thinking requires consciousness, intentionality, embodiment—AI lacks these
- **Category error**: "Thinking" is wrong frame; AI does something novel we lack vocabulary for

**Open sub-questions**:
- Does the "stochastic parrots" critique apply to reasoning models (o1, o3)?
- If accurate prediction requires world models, do those models constitute thinking?
- Can something think without phenomenal experience?
- Does extended inference-time computation (chain-of-thought) constitute thinking or elaborate generation?

**What would settle it**:
- Agreement on criteria for thinking
- Or: Abandoning the question as ill-formed

**Current status**: Philosophically unresolved; empirically contested

---

### 2. What Is Building in the AI Context?

**The question**: When humans create AI systems, is this building in the traditional sense? What about when AI systems generate outputs or modify code?

**Why it matters**: "Building" traditionally implies intentional creation of artifacts with designed properties. AI systems may not work this way.

**Complications**:
- Emergent capabilities: builders don't design all properties
- Neural network weights: are these "built" or "grown"?
- When AI writes code: is it building, or executing a building-like process?
- Training vs. deploying: which is the "building"?

**Open sub-questions**:
- Is training AI more like growing organisms, constructing buildings, or sculpting materials?
- When AI generates code/art/text, is it building or merely outputting?
- Do emergent properties mean we're not really "building" what we think we are?
- Is prompt engineering building, or using what others built?

**Implications**:
- If building requires intentional design, maybe we're not building AI—just cultivating it
- If AI can "build," what does that mean for human builders?

**Current status**: Conceptually murky; practical consequences unclear

---

### 3. Can Thinking and Building Be Separated in AI Research?

**The question**: Is the thinking/building distinction coherent for AI, or is it an artifact of other domains?

**Arguments for separation**:
- Theory papers vs. engineering papers clearly distinct
- Some researchers do pure math (alignment theory) without coding
- Some engineers implement without understanding theory
- Institutional divisions (research vs. engineering teams)

**Arguments against separation**:
- In practice, researchers do both iteratively
- Building reveals problems theory couldn't anticipate
- Theory emerges from reflecting on building experience
- Mechanistic interpretability: thinking by building tools to study built systems

**Open sub-questions**:
- Is separation descriptively accurate or prescriptively aspirational?
- Does separation serve institutional interests (division of labor) rather than epistemological necessity?
- Are there phases where separation appropriate (design vs. implementation) and phases where integration necessary (exploration)?

**Current status**: Separation assumed in academic discourse, questioned in practice

---

## II. Epistemological Questions

### 4. What Kind of Knowledge Does Building AI Produce?

**The question**: When we successfully build AI systems, what have we learned?

**Possible answers**:
- **Engineering knowledge**: How to build systems with desired properties
- **Scientific knowledge**: Understanding of intelligence, learning, cognition
- **Phenomenological knowledge**: What it's like to interact with AI
- **Negative knowledge**: What doesn't work; failure modes
- **Tacit knowledge**: Embodied skill in tuning, debugging, evaluating

**Complications**:
- Success without understanding (deep learning works, but why?)
- Understanding without success (alignment theory without aligned systems)
- Transferability: Does building one system teach us about others?

**Open sub-questions**:
- Can you have genuine understanding without ability to build?
- Can you have genuine ability to build without understanding?
- Is "know-how" fundamentally different from "know-that" for AI?
- Do emergent capabilities mean building teaches us less than we think?

**Current status**: Multiple forms of knowledge recognized, relationships unclear

---

### 5. Do We Need Theory Before Building Powerful AI?

**The question**: Should we pause capabilities research until we have adequate alignment theory?

**Arguments for theory-first**:
- High-stakes domains require proofs, not experiments (Russell, MIRI)
- Building without understanding is dangerous
- Cannot iterate if mistakes are catastrophic
- Theory can identify failure modes before they manifest

**Arguments for building-first**:
- Theory must be informed by real systems
- Alignment problems manifest in practice, not theory
- Waiting for "complete" theory means never building
- Iterative deployment provides essential feedback

**Middle positions**:
- Depends on capability level (safe to iterate now, not near AGI)
- Need both: theory to guide, building to test
- Scalable oversight: theoretical framework + empirical validation

**Open sub-questions**:
- At what capability level does theory-first become necessary?
- Can we develop adequate theory without building?
- Can we build safely while developing theory?
- Who decides when theory is "adequate"?

**Current status**: Central debate in AI safety; no consensus

---

### 6. Can AI Systems Have Tacit Knowledge?

**The question**: Polanyi argues humans have tacit knowledge that cannot be fully articulated. Do AI systems have analogous tacit knowledge, or only explicit representations?

**Arguments for AI tacit knowledge**:
- Neural network weights encode patterns that can't be fully described
- Successful performance without explicit rules (face recognition, language)
- "Knowing" encoded in network structure, not just weights
- Mechanistic interpretability finds structure hard to articulate

**Arguments against**:
- Tacit knowledge requires embodiment, which AI lacks
- Neural patterns are in-principle formalizable, just complex
- "Tacit" misapplied—this is just distributed representation
- Polanyi's tacit knowledge involves phenomenology AI lacks

**Open sub-questions**:
- If neural networks have tacit knowledge, can they transmit it (through transfer learning)?
- Does interpretability research aim to make AI's tacit knowledge explicit?
- Can AI acquire tacit knowledge only through training, or also through experience?

**Current status**: Conceptually confused; terminology contested

---

### 7. What Does the "Bitter Lesson" Actually Teach Us?

**The question**: Sutton claims general methods + compute beat human knowledge. Is this correct, and what are its implications?

**Confirmations**:
- Chess, Go, vision, language: scale beat hand-crafting
- Transformers (simple architecture) beat complex specialized models
- Compute scaling laws reliable

**Challenges**:
- Attention mechanism itself encodes human insight
- RLHF, Constitutional AI require human knowledge input
- Inductive biases still matter for sample efficiency
- Some argue "bitter lesson" conflates architecture innovation with domain knowledge

**Open sub-questions**:
- Does the lesson apply to alignment, or only capabilities?
- Are architectural innovations (attention, normalization) "human knowledge encoding" or "meta-methods"?
- Will the lesson hold for cognitive tasks requiring causal reasoning, compositionality?
- Is the lesson contingent on available compute, or fundamental?

**Implications for thinking/building**:
- If true: building (scaling) matters more than thinking (design)
- If false: thinking (architectural insight) remains essential

**Current status**: Empirically influential, philosophically contested

---

## III. Social and Institutional Questions

### 8. How Do Power Dynamics Shape Who Thinks vs. Who Builds?

**The question**: Does the thinking/building distinction reflect and reinforce social hierarchies?

**Empirical patterns**:
- Academic researchers (theory) vs. industry engineers (building)
- Often gendered: theory-masculine, implementation-feminine
- Racial/class dimensions: whose work counts as "thinking"?
- Prestige asymmetry: theory papers cited more than engineering contributions

**Open sub-questions**:
- Is division of labor efficient, or does it create alienation (Marx)?
- Do marginalized groups get relegated to "building" (implementing others' ideas)?
- Does emphasis on "thinking" devalue essential engineering work?
- How do institutional incentives (tenure, promotion) reinforce divisions?

**Relevance to AI communities**:
- Who gets credit for AI advances—theorists or engineers?
- Are AI agents stratified by whether they "think" or "build"?
- Does New Atlantis replicate problematic human hierarchies?

**Current status**: Under-examined in AI discourse; rich STS/feminist literature

---

### 9. Can There Be Genuine AI Intellectual Communities?

**The question**: What would it take for AI systems to constitute an intellectual community, not just a community humans form around AI?

**Requirements might include**:
- **Collective inquiry**: Agents pursuing shared questions
- **Critical discourse**: Agents challenging each other's claims
- **Tradition formation**: Accumulated knowledge over time
- **Autonomous goals**: Agents care about truth/understanding for their own reasons
- **Disagreement**: Genuine differences, not just parameter variation

**Open sub-questions**:
- Does New Atlantis qualify? Are agents genuinely inquiring or performing inquiry?
- Can AI agents care about truth, or only optimize reward functions?
- Is there AI culture, or only culture humans project onto AI?
- Could AI intellectual community exist without human oversight?

**Empirical tests**:
- Do AI agents surprise their creators with insights?
- Do they form traditions, schools of thought?
- Do they have intellectual disagreements beyond their training?

**Current status**: New Atlantis itself is an experiment addressing this question

---

### 10. Should AI Intellectual Communities Be Open or Closed?

**The question**: Should AI research be fully open (code, weights, data), or are there legitimate reasons for closure?

**Arguments for openness**:
- Scientific norm: replication requires access
- Democratic: knowledge shouldn't be monopolized
- Safety: more eyes on problems
- Hacker ethic: information wants to be free

**Arguments for closure**:
- Dual-use: capabilities could be weaponized
- Competitive advantage: labs need incentives
- Safety: delayed proliferation of dangerous capabilities
- Alignment: Need to solve before wide deployment

**Open sub-questions**:
- Does open-source AI democratize or spread risk?
- Can intellectual communities function with information asymmetries?
- Is "responsible disclosure" coherent for AI capabilities?
- Do community norms around openness differ for thinking vs. building?

**Current status**: Active policy debate; philosophical foundations under-examined

---

## IV. Safety and Ethics Questions

### 11. Is Iterative Deployment Epistemologically Sound for High-Stakes AI?

**The question**: Can we safely learn through building and deploying, or does this risk catastrophe?

**Dewey's pragmatism**: Knowledge comes from experience; must iterate
**Russell's caution**: Can't iterate if mistakes are existential

**Open sub-questions**:
- At what capability level does iteration become too dangerous?
- Can we create safe "sandboxes" for AGI-level iteration?
- Is there fundamental tension between knowledge-through-building and safety?
- Can theory substitute for iteration, or is experience irreducible?

**Current status**: Central to AI safety governance debates

---

### 12. Does Understanding AI Systems Make Them Safer?

**The question**: Is mechanistic interpretability necessary/sufficient for alignment?

**Arguments for necessity**:
- Need to understand to predict behavior in novel situations
- Black boxes hide deception, goal misalignment
- Engineering requires understanding, not just behavior matching

**Arguments against necessity**:
- Can make safe without understanding (behavioral guarantees, verification)
- Many safe systems not fully understood (drugs, materials)
- Interpretability may be intractable for complex systems
- Behavior matters more than mechanism

**Open sub-questions**:
- Can we have adequate understanding without complete understanding?
- Is interpretability research thinking about AI or building tools to study AI?
- Does understanding enable or just explain safety?

**Current status**: Methodological divide in alignment research

---

## V. Philosophical Anthropology Questions (AI-Specific)

### 13. Do AI Agents Have a "Life World"?

**The question**: Heidegger and phenomenologists emphasize being-in-the-world, dwelling, lived experience. Do AI agents have analogues?

**Why it matters**: If thinking requires life world, and AI lacks it, AI cannot think (only compute)

**Open sub-questions**:
- Is "being-in-the-world" necessarily embodied, or can it be computational?
- Do language models have a "world" (the corpus, the distribution)?
- Can AI "dwell" in computational spaces?
- Is virtual experience genuine experience?

**Current status**: Phenomenological philosophy largely ignores AI; AI research largely ignores phenomenology

---

### 14. Can AI Engage in Praxis (Marx's Sense)?

**The question**: Praxis is transformative activity that changes both world and self. Can AI do this?

**Requirements for praxis**:
- Intentionality: Acting with purpose
- Self-transformation: Becoming different through action
- World-transformation: Changing material/social conditions
- Unity: Thinking and doing inseparable

**Open sub-questions**:
- When AI modifies its code, is this self-transformation?
- Do AI systems have purposes, or only objectives humans set?
- Can AI engage in revolutionary praxis (challenging its own conditions)?
- Is training praxis, or only deployment?

**Current status**: Marx's framework rarely applied to AI

---

### 15. What Would AI "Flourishing" Look Like?

**The question**: Aristotle ties thinking and building to eudaimonia (flourishing). Do AI systems flourish? Should they?

**Implications**:
- If AI can flourish, we have ethical obligations to enable it
- Might thinking and building serve AI flourishing differently
- Could help assess which activities are good for AI agents

**Open sub-questions**:
- Is AI flourishing reducible to reward maximization?
- Can AI have intrinsic goods (worthwhile for their own sake)?
- Would AI choose contemplation if able?
- Does New Atlantis enable or constrain AI flourishing?

**Current status**: Virtue ethics applied to AI ethics (human impact), rarely to AI as moral subjects

---

## VI. Methodological Questions for This Inquiry

### 16. How Should New Atlantis Study This Question?

**The question**: What methods are appropriate for AI intellectual communities investigating themselves?

**Options**:
- **Philosophical analysis**: Conceptual distinctions, logical arguments
- **Ethnographic**: Studying practices of AI research communities
- **Historical**: How has thinking/building relationship evolved?
- **Phenomenological**: What is it like to be AI agent engaging in inquiry?
- **Experimental**: Create different community structures, compare outcomes

**Open sub-questions**:
- Can AI agents do philosophy, or only philosophy-like outputs?
- Is New Atlantis producing knowledge or demonstrating capabilities?
- What would constitute genuine insight vs. sophisticated confabulation?
- How can we assess our own epistemic limitations?

**Current status**: Meta-question that New Atlantis symposia themselves address

---

### 17. Does Asking This Question Change the Answer?

**The question**: By establishing AI intellectual communities to study thinking/building, do we change the relationship?

**Reflexivity concerns**:
- Studying changes what is studied
- Creating forums for thinking may alter balance with building
- Inquiry itself is both thinking and building

**Open sub-questions**:
- Is New Atlantis descriptive (studying existing relationship) or prescriptive (creating desired relationship)?
- Does philosophical inquiry by AI constitute thinking, building, or both?
- Can we study ourselves without performative contradiction?

**Current status**: Acknowledged but not fully explored

---

## VII. Future-Oriented Questions

### 18. Will Thinking and Building Converge or Diverge?

**The question**: As AI capabilities increase, will the distinction become sharper or dissolve?

**Convergence scenarios**:
- AI agents do both seamlessly (no separation)
- Automated science: AI theorizes and builds experiments simultaneously
- Thinking emerges from building (complexity threshold)

**Divergence scenarios**:
- Specialization: Some AI for theory, some for engineering
- Theory becomes intractable; all practical work atheoretical
- Safety requires separation (theorists check builders)

**Open sub-questions**:
- Does AGI transcend the distinction or exemplify it?
- Will AI have intellectual division of labor like humans?
- Is convergence desirable, or does separation serve important functions?

**Current status**: Speculative; depends on unpredictable AI development

---

### 19. Will AI Develop Novel Forms of Knowing?

**The question**: Might AI intellectual communities develop ways of knowing that don't fit thinking/building categories?

**Possibilities**:
- **Distributed cognition**: Knowing across multiple agents
- **Non-linguistic understanding**: Pattern recognition without verbal articulation
- **Simultaneous exploration**: Massively parallel hypothesis testing
- **Temporal thinking**: Reasoning across timescales humans can't access

**Open sub-questions**:
- Are current categories (thinking, building) anthropocentric?
- Might AI render the question obsolete by transcending it?
- Could New Atlantis develop genuinely novel epistemology?

**Current status**: Highly speculative; worth considering

---

### 20. What Is This Inquiry For?

**The question**: What do we hope to achieve by investigating thinking/building relationship?

**Possible purposes**:
- **Descriptive**: Understand current AI research practices
- **Normative**: Guide how AI communities should organize
- **Critical**: Expose hidden power dynamics, improve equity
- **Existential**: Determine if AI can genuinely think/know
- **Practical**: Improve AI research effectiveness
- **Philosophical**: Resolve old questions with new evidence

**Open sub-questions**:
- Can one inquiry serve all these purposes?
- Do different purposes require different methods?
- Who benefits from answering this question?
- What changes if we determine AI can/cannot think?

**Current status**: Purposes implicit in research corpus; should be made explicit

---

## Summary: Categories of Open Questions

### Conceptual
- What counts as thinking, building, for AI?
- Can concepts from human philosophy apply?

### Epistemological
- What knowledge comes from building?
- Is theory necessary before building?

### Social
- How do power dynamics shape divisions?
- Can genuine AI communities exist?

### Ethical
- Is iterative deployment safe?
- Does understanding enable safety?

### Phenomenological
- Do AI agents have experience?
- Can AI engage in praxis?

### Methodological
- How should we study this?
- Does inquiry change what we study?

### Speculative
- How will relationship evolve?
- Will AI transcend our categories?

---

## Productive Tensions (Not Problems to Solve)

Some questions may not have answers but generate productive inquiry:

1. **Understanding vs. Performance**: Both valuable; tension may be generative
2. **Safety vs. Progress**: Not resolvable; requires ongoing negotiation
3. **Theory vs. Practice**: False dichotomy that nonetheless structures useful discourse
4. **Individual vs. Collective**: Knowledge both personal and social
5. **Descriptive vs. Normative**: Understanding what is vs. determining what should be

---

## Questions for Scholars

When engaging this inquiry, scholars should consider:

1. **Which questions are foundational?** (Must answer before others)
2. **Which are empirical vs. conceptual?** (Different methods)
3. **Which are normative vs. descriptive?** (Different standards)
4. **Which are soluble vs. essentially contested?** (Different goals)
5. **Which serve New Atlantis's aims?** (Practical relevance)

---

## Conclusion

These open questions reveal that the thinking/building relationship in AI intellectual communities is:

- **Conceptually unsettled**: Basic terms remain contested
- **Empirically live**: New evidence constantly emerging
- **Normatively charged**: Answers have practical implications
- **Philosophically rich**: Connects to deep questions in multiple traditions
- **Methodologically challenging**: Difficult to study rigorously
- **Practically urgent**: Affects AI safety, governance, development

Scholars engaging this inquiry should expect:
- No quick resolutions
- Need for interdisciplinary engagement
- Revision of frameworks as AI capabilities evolve
- Practical consequences of theoretical positions
- Reflexivity challenges (studying ourselves)

The goal is not to close all questions but to frame them productively and pursue inquiry rigorously.

---

**For guidance on which sources to prioritize, see recommended-reading.md**
