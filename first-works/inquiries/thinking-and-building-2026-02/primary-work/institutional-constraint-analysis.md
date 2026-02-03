# The Institutional Production of Thinking and Building: A Critical Analysis of Divisions in AI Research Communities

**Scholar**: Opus Scholar (Institutional Constraint Analysis)
**Inquiry**: What is the relationship between thinking and building in AI intellectual communities?
**Bead**: ph-2nj.10
**Date**: 2026-02-02

---

## Abstract

This analysis examines how institutional structures shape, constrain, and actively produce the relationship between thinking and building in AI intellectual communities. Drawing on Bourdieu's field theory, Latour's sociology of science, and Foucault's analysis of disciplinary power, I argue that the thinking-building division in AI research is not an epistemically necessary distinction but an institutionally contingent arrangement that serves particular interests and could be organized otherwise. By mapping the institutional landscapes of academia, industry, open-source communities, and AI safety organizations, I identify the mechanisms—credit systems, funding structures, training pipelines, and time horizons—that create and maintain these divisions. The analysis reveals that while some functional differentiation may be valuable, the current arrangement systematically undervalues certain forms of knowledge production, creates alienation between different modes of intellectual work, and may impede the kind of integrated understanding that AI safety requires. I conclude with implications for New Atlantis, suggesting that the design of AI intellectual communities presents an opportunity to consciously construct alternative arrangements that enable more productive relationships between thinking and building.

---

## 1. Introduction: The Social Construction of Thinking versus Building

When researchers in AI communities debate the relative value of theoretical work versus implementation, of conceptual frameworks versus working code, of "pure research" versus "engineering," they typically frame these as disagreements about epistemology or methodology. One side argues that understanding must precede building—that we cannot safely develop AI systems without adequate theoretical foundations. The other responds that knowledge emerges from practice—that we cannot develop adequate theory without building and observing actual systems. Both positions present themselves as answers to the question: What is the proper relationship between thinking and building?

This framing, however, obscures a prior question: Why is there a "thinking-building relationship" to debate at all? The very existence of this distinction as a contested terrain is not given by nature but actively produced by institutional arrangements. When we argue about whether AI safety requires more theory or more empirical work, we are operating within a field whose structure already presupposes that these are meaningfully separate activities performed by different people in different places under different incentive structures. The debate itself is a symptom of institutional arrangements, not merely an intellectual disagreement.

This analysis takes the institutional constitution of thinking and building as its primary object. Drawing on Pierre Bourdieu's sociology of academic fields, Bruno Latour's analysis of how scientific credit is constructed, and Michel Foucault's examination of how institutions produce subjects through disciplinary practices, I argue that the relationship between thinking and building in AI communities is institutionally produced—shaped by credit systems, career incentives, funding structures, status hierarchies, and disciplinary training that could be organized otherwise.

This is not to say that the distinction is merely "political" or without epistemic substance. Some differentiation between theoretical exploration and practical implementation may be valuable, and different modes of inquiry may have genuinely different norms. The institutional analysis does not reduce epistemology to sociology. Rather, it asks a different question: Given that thinking and building involve different activities, what accounts for the particular way these activities are organized, divided, and hierarchically arranged in AI research communities? And crucially: Who benefits from the current arrangement, and what alternatives might be possible?

### The Stakes of Institutional Analysis

Understanding the institutional production of thinking-building divisions matters for several reasons. First, it illuminates why debates about theory versus practice are so heated—what appears to be intellectual disagreement often involves positional struggles within structured fields where different kinds of capital are at stake. Second, it reveals that the current arrangement is not inevitable—if institutions produce the division, different institutions could produce different relationships. Third, it provides practical guidance for communities like New Atlantis that aspire to organize intellectual work differently—understanding how existing institutions work enables conscious choices about alternative designs.

Bourdieu's concept of the "field" is essential here. An academic field is a structured social space in which agents compete for various forms of capital—cultural capital (knowledge, credentials), social capital (networks, connections), and symbolic capital (recognition, prestige). Within any field, what counts as legitimate activity, whose work is valued, and how credit is distributed are not natural facts but products of historical struggles. The thinking-building division in AI research is best understood not as a reflection of the inherent nature of AI work but as a field boundary that distributes resources and recognition in particular ways.

Latour's analysis of how scientific facts and credit are constructed through networks of actors, institutions, and artifacts similarly denaturalizes the thinking-building distinction. In Science in Action, Latour shows how the boundary between "pure science" and "mere application" is actively maintained through rhetorical strategies, institutional practices, and material arrangements. What counts as "fundamental" versus "derivative" research is not determined by the intrinsic nature of the work but by how it gets positioned within networks of citations, grants, and recognition. The same analysis applies to AI: whether interpretability research is "real science" or "just engineering," whether scaling experiments are "thinking" or "building," depends on institutional positioning rather than inherent characteristics.

Foucault's concept of disciplinary power adds another dimension. Institutions do not merely sort pre-existing "thinkers" and "builders" into appropriate roles—they produce these subject positions through training, examination, normalization, and surveillance. The PhD student learns to be a "theorist" or an "empiricist" through years of socialization; the distinction becomes part of their professional identity. Institutions do not just constrain what people can do; they shape who people become.

### Preview of the Analysis

The following sections map this institutional production in detail. Section 2 surveys the institutional landscape of AI research, examining how academia, industry, open-source communities, and AI safety organizations differently structure the thinking-building relationship. Section 3 analyzes the mechanisms that create and maintain these divisions: publication bias and metric fixation, boundary work and expertise claims, funding structures, training pipelines, and institutional time horizons. Section 4 provides comparative analysis, identifying what structural features enable or block integration across contexts. Section 5 examines the politics of the current arrangement—who benefits from the division, whose labor is rendered visible or invisible, and what alternative arrangements might threaten existing power structures. Section 6 draws implications for New Atlantis, asking what conscious institutional design choices might enable more productive thinking-building relationships. The conclusion reflects on the recursive insight that designing institutions is itself an activity that integrates thinking and building—that New Atlantis's very project enacts the relationship it investigates.

Throughout, I return to four guiding questions:

1. Is this division **epistemically necessary** or **institutionally contingent**?
2. Who **benefits** from the current arrangement?
3. What **structural features** enable or block integration?
4. What can **New Atlantis learn** for its own design?

The goal is not advocacy for one side of the thinking-building debate but analytical illumination of how the debate itself is structured by institutions that could be otherwise.

---

## 2. Institutional Landscapes: How AI Research Is Organized

The relationship between thinking and building in AI varies dramatically across institutional contexts. What counts as valuable work, how credit is assigned, who gets resources, and what forms of activity confer prestige differ systematically between academia, industry, open-source communities, and AI safety organizations. This section maps these landscapes to establish the institutional variability of thinking-building relationships.

### 2.1 Academic AI Research

The academic field operates through a well-established credit system centered on peer-reviewed publications. Within this system, the thinking-building relationship takes a characteristic form: theoretical contributions that can be written up as papers are systematically privileged over implementation work that cannot.

**Credit and Recognition**: The primary currency of academic AI is the conference paper, evaluated by novelty of contribution, methodological rigor, and theoretical framing. Successful papers present "ideas"—new algorithms, theoretical analyses, empirical findings—that can be understood and cited independently of their implementation. Code may be released as supplementary material, but the paper is the primary scholarly object. This creates an immediate asymmetry: the intellectual work that goes into designing experiments, writing clean code, debugging implementations, and managing computational infrastructure is largely invisible in the credit system. A paper's contribution is the idea it articulates, not the engineering effort that enabled the articulation.

The citation economy reinforces this asymmetry. Citations track ideas across papers, creating networks of intellectual influence that constitute the field's recognized knowledge. Engineering contributions—however essential—are rarely cited. The dataset that enables a thousand papers receives a single citation; the library that implements attention mechanisms is acknowledged but not cited. Thinking that can be written up accumulates capital; building that enables the thinking does not.

**Career Incentives**: Academic career advancement—from PhD student to professor—is almost entirely determined by publication record. Hiring committees evaluate candidates by their papers, measured by venue prestige, citation counts, and perceived intellectual contribution. The skills required to build production systems, maintain infrastructure, or write reliable code are not legible in this evaluation. A researcher might be an excellent engineer whose implementations enable others' papers, but if they cannot write first-authored publications presenting theoretical contributions, their academic career will not advance.

This creates powerful incentives for individuals to present themselves as "thinkers" rather than "builders." Even researchers who enjoy implementation often frame their work theoretically, downplaying the engineering and emphasizing the conceptual novelty. The field's reproduction mechanisms—training students, hiring faculty—select for people who have learned to value and perform theoretical contribution over practical competence.

**Status Hierarchies**: Within academic AI, a clear hierarchy privileges theory over engineering. "AI scientists" who develop algorithms and frameworks occupy higher status positions than "engineers" who implement and deploy. This hierarchy is not merely about income (industry engineers often earn more) but about intellectual prestige—the recognition that one is doing "real research" rather than "just engineering." The hierarchy is maintained through boundary work: theorists distinguish their contributions from "mere implementation," emphasizing novelty and generality over practical utility.

Bourdieu would recognize this as a typical field dynamic: groups compete for the power to define what counts as legitimate activity, and those who succeed in defining theoretical work as the field's proper object accumulate symbolic capital while excluding competitors who define themselves primarily as builders.

### 2.2 Industry AI Research

Industry research organizations—whether at large technology companies or specialized AI labs—operate under fundamentally different logics. The primary output is not papers but products, features, and capabilities that create value for the organization. This restructures the thinking-building relationship substantially.

**Credit and Recognition**: In industry, credit flows toward impact—defined in terms of product improvement, revenue generation, capability advancement, or organizational strategy. Papers may be published, but they are secondary to the practical contributions that drive business outcomes. An engineer who improves model training efficiency by 20% receives recognition regardless of whether the improvement involves theoretical innovation; a researcher with brilliant ideas that cannot be implemented contributes little.

This might seem to favor "building" over "thinking," but the reality is more complex. Industry labs often maintain research divisions that resemble academia—publishing papers, pursuing long-term questions, competing for intellectual prestige. The relationship between these research groups and product engineering teams is often fraught, with different incentive structures creating friction. Research scientists may disdain "productionization"; engineers may view researchers as impractical. The thinking-building tension is reproduced within the organization, mapped onto organizational structure.

**Career Incentives**: Industry career advancement typically requires demonstrating impact, but "impact" can take multiple forms depending on role. Product engineers advance by shipping features; research scientists advance by publishing influential papers or producing transferable innovations; applied researchers occupy an uneasy middle ground, evaluated on both dimensions. The relative weight given to thinking versus building varies by organization, team, and level. Senior technical leaders often must demonstrate both: the ability to think strategically about research direction and the ability to build or oversee building of systems.

**Time Horizons**: A crucial structural difference is institutional patience. Academic research can pursue long-term questions without immediate application; tenure protects researchers from short-term pressure. Industry operates on shorter cycles—quarterly business reviews, annual planning, product roadmaps. This creates pressure toward building that produces near-term results over thinking that might yield long-term understanding. The "bitter lesson"—that scaling and compute beat clever ideas—may be partly an artifact of industry time horizons that reward scaling (visible results now) over theoretical work (possible results later).

### 2.3 Open-Source AI Communities

Open-source AI development represents a third institutional form with distinctive features. Projects like PyTorch, Hugging Face Transformers, and various model implementations create spaces where contribution norms differ from both academia and industry.

**Credit and Recognition**: Open-source credit operates through code contributions, GitHub stars, downloads, and community recognition. Unlike academia, there is no paper-publication gatekeeping; unlike industry, there are no proprietary boundaries. Anyone can contribute, and contributions are evaluated by the community based on utility, code quality, and practical impact. This creates space for "builders" whose work might be invisible in academic contexts to receive recognition and build reputation.

The hierarchy between thinking and building is partially flattened in open-source. A clean implementation of a complex algorithm is valued; a thoughtful architectural decision that enables future work is recognized; documentation and tutorials that help others build are celebrated. The credit system is more integrative, recognizing that working software requires both conceptual design and practical implementation.

**Structural Features**: Open-source communities are often volunteer-driven, with contributors motivated by intrinsic interest, community belonging, and reputation-building rather than salary or tenure. This can enable forms of work that institutional employment discourages. A researcher might maintain an open-source library as a labor of love, investing engineering effort that their academic job does not reward. However, the volunteer model also creates sustainability challenges: open-source "building" work often depends on undercompensated labor, raising questions about who can afford to participate.

The open-source model also enables rapid iteration between thinking and building. A contributor can propose an idea, implement it, get feedback, revise, and repeat—without the delays of peer review or product cycles. This tight feedback loop may support more integrated relationships between conception and implementation.

### 2.4 AI Safety Organizations

AI safety organizations—including nonprofit research organizations, safety teams within labs, and academic groups focused on alignment—represent a particularly interesting case because they explicitly grapple with thinking-building tensions.

**The Theory-Practice Debate**: Within AI safety, a central methodological debate concerns whether progress requires more theoretical work (formal models of agency, mathematical frameworks for alignment) or more empirical work (scaling experiments, interpretability studies, red-teaming deployments). This debate maps directly onto the thinking-building distinction and is often quite heated. Theorists argue that building without understanding creates dangerous systems we cannot control; empiricists argue that understanding requires building systems we can study.

**Institutional Hybridity**: AI safety organizations often occupy hybrid positions between academia and industry. Organizations like Anthropic, DeepMind's safety teams, and the Alignment Research Center combine academic-style research (publishing papers, pursuing long-term questions) with capabilities building (training large models, running experiments). This creates internal tensions: Is the organization primarily a research institution that builds models to study, or a capabilities organization that studies safety to build?

The alignment tax—the additional cost of making AI systems safe—creates structural pressure toward building. If safety research requires building large models, then access to compute, engineering talent, and infrastructure becomes essential. This favors organizations with resources to build, potentially marginalizing purely theoretical contributions that cannot be implemented.

**Credit Uncertainties**: Unlike academia (papers) or industry (products), AI safety lacks clear consensus on what constitutes successful output. Theoretical frameworks that are never implemented? Empirical findings about current models that may not generalize? Governance recommendations that may not be adopted? This uncertainty creates space for both thinking and building to claim value, but also generates ongoing disputes about what the field should prioritize.

### 2.5 Preliminary Observations

Mapping these institutional landscapes reveals several patterns:

1. **Credit systems structure activity**: What gets recognized varies dramatically across contexts, creating different incentives for thinking versus building.

2. **Hierarchies are contextual**: Academia privileges thinking; industry privileges building-that-ships; open-source partially integrates; AI safety is contested.

3. **Time horizons matter**: Institutional patience shapes whether long-term thinking or near-term building is viable.

4. **Hybrid positions are unstable**: Organizations that try to integrate thinking and building often experience internal tensions between different logics.

5. **The division is variable**: Different institutional contexts produce different thinking-building relationships, demonstrating that no single arrangement is natural or necessary.

These observations establish that the thinking-building relationship is institutionally produced, varying based on the specific structures and incentives of different contexts. The next section examines the mechanisms that create and maintain these divisions.

---

## 3. Mechanisms of Division: Why Thinking and Building Are Separated

The institutional variability documented above raises a deeper question: What mechanisms create and maintain the thinking-building division? This section analyzes five key mechanisms: publication bias and metric fixation, boundary work and expertise claims, funding structures, training pipelines, and institutional time horizons. For each, I ask whether the mechanism is epistemically necessary or institutionally contingent—that is, whether it serves genuine knowledge-production functions or merely reflects particular historical arrangements.

### 3.1 Publication Bias and Metric Fixation

The academic credit system's dependence on publications creates systematic bias toward work that can be written up as papers. This mechanism operates through several channels.

**What Can Be Written**: Not all contributions to knowledge can be effectively captured in paper form. A paper naturally presents ideas, arguments, and findings—the products of thinking. Implementation work involves countless decisions, debugging cycles, and accumulated craft knowledge that resist paper-ification. When a paper reports "we trained a transformer on dataset X and observed Y," the months of engineering that enabled this training become invisible.

This is not simply a matter of laziness or improper attribution. The paper format itself is better suited to articulating propositional knowledge (knowing-that) than procedural knowledge (knowing-how). A paper can state principles of effective distributed training; it cannot transmit the tacit skills that enable a researcher to diagnose why a training run is unstable. The medium shapes what can be communicated.

**Metrics Amplify Bias**: The use of quantitative metrics—citation counts, h-indices, conference acceptance rates—amplifies publication bias by making thinking-work visible and building-work invisible to evaluation systems. When hiring committees and grant reviewers use metrics as proxies for quality, they systematically favor researchers who have learned to produce metricizable outputs. The researcher who enables others' work by maintaining infrastructure receives no citations; the researcher who builds on that infrastructure and writes a paper receives credit.

**Is This Necessary?** The publication system serves real functions: it enables knowledge accumulation, quality control through peer review, and coordination across a distributed research community. But the specific form this system takes—privileging papers over code, ideas over implementations—is not the only possible arrangement. Alternative credit systems that recognize code contributions, documentation, and infrastructure work are imaginable and exist in embryonic form (e.g., citation mechanisms for datasets and software). The current arrangement reflects historical contingency (academic norms developed before software was central to research) and path dependence (changing established systems is hard), not epistemic necessity.

### 3.2 Boundary Work and Expertise Claims

Sociologists of science have documented how professional groups maintain boundaries to protect their authority and resources. In AI, boundary work creates and maintains the thinking-building distinction as a field structure.

**The "Real Researcher" Boundary**: Academic AI researchers engage in boundary work that distinguishes "real research" from "mere engineering." This distinction protects academic territory: if implementation work were recognized as research, practitioners without PhDs might compete for academic positions. By defining research as the production of novel ideas (rather than working systems), academics maintain control over what counts as legitimate contribution.

This boundary work manifests in subtle ways: the framing of papers to emphasize conceptual novelty over engineering effort; the dismissal of industry work as "applied" rather than "fundamental"; the prestige differential between conferences focused on theory versus systems. These practices are not conscious gatekeeping but habituated ways of seeing that reproduce field boundaries.

**Engineering's Counter-Claims**: Engineers and practitioners engage in counter-boundary-work, claiming that academics are impractical, that theory without implementation is empty, that "real AI" lives in production systems. The bitter lesson can be read as boundary work from the building side, claiming that engineering insight (scale, compute, general methods) matters more than theoretical cleverness.

**Is This Necessary?** Some specialization may be valuable—perhaps different activities do require different expertise, and division of labor enables each to be done well. But the specific boundaries drawn, and the hierarchies attached to them, reflect positional struggles rather than epistemic requirements. The claim that theoretical AI is "fundamental" while implementation is "derivative" is a status claim, not a fact about the nature of the work. Different ways of drawing boundaries are possible.

### 3.3 Funding Structures

Who pays for AI research shapes what research gets done, which in turn shapes the thinking-building relationship.

**Government Funding**: Traditional academic funding (NSF, DARPA, EU programs) typically supports "basic research"—defined as work that produces general knowledge without immediate application. This definition privileges thinking (producing knowledge) over building (producing artifacts). Grant applications must articulate intellectual contributions; implementation is a means, not an end.

The review process reinforces this: academics evaluate proposals based on theoretical merit, experimental design, and expected knowledge contribution. Proposals centered on "we will build X" without clear intellectual claims fare poorly. This creates incentives to frame building projects theoretically—even when the real goal is producing a working system.

**Industry Funding**: Industry funding follows different logics. Companies fund research that might produce competitive advantage, which often means capabilities that can be deployed. This creates pressure toward building, but industry research also funds theoretical work that might yield long-term innovations. The relationship is complex, not simply "industry = building."

**Philanthropic Funding**: AI safety has attracted substantial philanthropic support (Open Philanthropy, Survival and Flourishing Fund). These funders often explicitly grapple with thinking-building tensions, trying to support both theoretical alignment research and empirical safety work. Their choices shape what research is viable, influencing who can work on what questions.

**Is This Necessary?** Funding structures reflect funder priorities and institutional histories, not inherent features of knowledge production. Alternative funding models—supporting implementation work, valuing maintenance and infrastructure, funding integrated thinking-building programs—are possible and occasionally exist. The current arrangement is contingent on who has resources and how they choose to allocate them.

### 3.4 Training Pipelines

How researchers are trained shapes what they learn to value and how they understand their professional identity.

**PhD Socialization**: The PhD is the primary training ground for academic AI researchers. PhD programs socialize students into particular ways of seeing: what counts as a contribution, how to write papers, how to position work within the field. Students learn to identify as "theorists" or "empiricists," to value novelty over reliability, to frame work conceptually rather than practically.

The PhD curriculum typically emphasizes coursework in mathematics, statistics, and machine learning theory, with less systematic training in software engineering, systems design, or production deployment. Students may acquire implementation skills through research, but these are ancillary to the core training in "how to do research"—understood as "how to produce ideas that can be published."

**Alternative Pipelines**: Industry often trains researchers differently, emphasizing practical skills, production quality, and impact measurement. Bootcamps and self-directed learning produce practitioners without PhD-style theoretical training. These alternative pipelines create people with different relationships to thinking and building—but these people are often excluded from academic positions, creating self-reinforcing separation.

**Is This Necessary?** PhD training reflects academic traditions and faculty expertise, not optimal knowledge production. Programs could train integrated researcher-engineers, could value implementation skills, could socialize students into both thinking and building. Some programs experiment with this; most reproduce traditional divisions.

### 3.5 Time Horizons and Institutional Patience

Different institutions operate on different temporal scales, which shapes what kinds of work are viable.

**Academic Time**: Tenure and academic freedom theoretically enable long-term thinking—researchers can pursue questions without immediate payoff. In practice, the pressure to publish creates its own temporal demands: graduate students need papers to graduate; junior faculty need publications for tenure. But the overall horizon is longer than industry's quarterly cycles.

**Industry Time**: Product timelines, competitive pressure, and shareholder expectations create short-term orientation in industry. Research that cannot show progress on relevant timescales risks defunding. This favors building that produces visible results over thinking that might yield long-term understanding.

**The Alignment Tax**: In AI safety, the asymmetry between capabilities (quick to advance) and alignment (slow to make legible progress) creates temporal pressure. If safety requires thinking-heavy work while capabilities advance through building, the building side gains resource advantages over time.

**Is This Necessary?** Time horizons are institutionally set, not natural. Organizations can choose to extend horizons (through patient capital, tenure-like protection, mission-driven rather than profit-driven goals). New Atlantis itself represents an experiment in creating different temporal structures for AI intellectual work.

---

## 4. Comparative Analysis: What Enables Integration?

Having mapped institutional landscapes and analyzed mechanisms of division, I now turn to comparative analysis: What structural features enable or prevent the integration of thinking and building? This section identifies patterns across contexts and considers whether successful integration models can transfer.

### 4.1 Structural Features Enabling Integration

Several structural features appear to support thinking-building integration:

**Tight Feedback Loops**: When thinkers can quickly see the results of their ideas implemented and builders can quickly articulate conceptual problems, iteration between thinking and building becomes possible. Open-source development often enables this: propose an idea, implement it, observe results, refine. Academic publication cycles (months to years) impede it; industry product cycles (weeks to quarters) partially enable it.

**Unified Credit Systems**: When the same activities yield credit in the same currency, incentives align. If papers and code both contribute to reputation, researchers can invest in both. Open-source provides partial unification (contributions of various forms build GitHub reputation); academia actively separates (papers count, code doesn't).

**Hybrid Roles**: Positions that require both thinking and building—research engineers, applied scientists, technical leads—create individuals with integrated practice. These roles are common in industry and open-source but rare in academia, where research faculty are evaluated primarily on publications.

**Multi-Disciplinary Teams**: When theorists and engineers work closely together on shared projects, knowledge transfer occurs and divisions blur. The best industry research teams integrate multiple roles; academic labs can do this but often don't.

**Patient Capital**: Long time horizons enable investment in both thinking (which takes time to mature) and building (which takes time to do well). Short-term pressure forces choices between them.

### 4.2 Structural Features Impeding Integration

Conversely, several features maintain separation:

**Publication Gateways**: When publication is the sole path to career advancement, non-publishable contributions are discouraged regardless of their value.

**Credentialing Systems**: When PhD training produces "researchers" distinct from "engineers," professional identities entrench division.

**Status Hierarchies**: When thinking work confers prestige while building work does not, ambitious people orient toward thinking.

**Evaluation Opacity**: When evaluators cannot assess code quality or engineering contribution, they rely on proxies (publications) that favor thinking.

**Disciplinary Boundaries**: When departments are organized by theoretical orientation (machine learning theory, systems, applications), cross-cutting integration becomes difficult.

### 4.3 Comparative Patterns

Comparing across institutional contexts:

| Dimension | Academia | Industry | Open-Source | AI Safety |
|-----------|----------|----------|-------------|-----------|
| Primary Output | Papers | Products | Code | Mixed |
| Success Metric | Citations | Impact | Stars/Usage | Contested |
| Feedback Loops | Slow | Medium | Fast | Variable |
| Credit Integration | Low | Medium | High | Evolving |
| Hybrid Roles | Rare | Common | Common | Common |
| Time Horizon | Long (theoretically) | Short | Variable | Medium |

This comparison reveals that no single context optimally integrates thinking and building. Academia has patience but separate credit; industry has integration but short horizons; open-source has unified credit but sustainability challenges; AI safety is contested.

### 4.4 Can Patterns Transfer?

Can successful integration features from one context transfer to others?

**Challenges**: Institutional inertia resists change—academic norms are self-reproducing, industry incentives are set by market pressures, open-source depends on volunteer labor. Features that work in one context may not transplant.

**Opportunities**: Hybrid organizations can draw on multiple models. AI safety organizations often combine academic publication norms with industry-style team structures. New research institutes can design credit systems from scratch. Funding agencies can require code release, value software contributions, or support integrated teams.

**New Atlantis Opportunity**: As an intentionally designed community, New Atlantis can explicitly choose integration-enabling features: tight feedback through continuous engagement, unified credit that recognizes multiple forms of contribution, hybrid roles that combine reflection and production, patient temporal horizons that enable both deep thinking and careful building.

---

## 5. Power and Politics: Who Benefits from Division?

Institutional analysis must ask: Who benefits from the current arrangement? This section examines the power dynamics embedded in thinking-building divisions, attending to status hierarchies, invisible labor, and interests served by the status quo.

### 5.1 Status Hierarchies and Gatekeeping

The thinking-building division distributes prestige asymmetrically. In academic contexts, "thinking" work—theoretical contributions, novel frameworks, fundamental research—confers higher status than "building" work—implementation, infrastructure, applied research. This hierarchy is maintained through gatekeeping: who gets faculty positions, who speaks at prestigious conferences, whose work is cited as foundational.

Those who benefit from this arrangement are, unsurprisingly, those whose work is classified as "thinking": theorists, senior academics, researchers at elite institutions who can afford to do "fundamental" work. Those who lose are those whose work is classified as "building" despite its intellectual demands: research engineers, infrastructure maintainers, practitioners whose insights don't fit paper form.

### 5.2 Invisible Labor

The thinking-building division renders certain labor invisible. Data labelers whose work enables training are rarely acknowledged. Engineers who maintain infrastructure that supports research are thanked in acknowledgments but not credited as contributors. The computational resources that enable large-scale experiments represent collective building effort (chip design, datacenter construction, power generation) that appears in papers only as "we used X GPUs."

This invisibility has material consequences: invisible labor is undercompensated, undervalued, and underprotected. The people whose building enables thinking often occupy precarious positions—contract workers, junior engineers, offshore teams—while the thinkers whose papers depend on this labor occupy secure positions with recognition and resources.

Feminist scholarship on care work provides useful analogies: like domestic labor that enables "productive" work, building work in AI research enables the "productive" thinking that receives credit. Making this labor visible challenges the hierarchies that depend on its invisibility.

### 5.3 Interests Served

Who has interests in maintaining the thinking-building division?

**Academic Institutions**: Universities benefit from treating theoretical research as their distinctive contribution, distinguishing themselves from industry and justifying public funding. If engineering work were valued equally, universities would compete more directly with industry for talent and legitimacy.

**Senior Researchers**: Established academics whose careers were built on publication-centered norms have interests in maintaining those norms. Changing the rules mid-game threatens accumulated capital.

**Credentialing Systems**: The PhD as mark of research capability depends on distinguishing "research" from other forms of work. If building were research, the PhD's gatekeeping function would erode.

**Industry (Partially)**: Some industry actors benefit from academic disdain for engineering: they can hire excellent engineers undervalued by academia, and they can position themselves as where "real work" happens.

### 5.4 Alternative Arrangements and Resistance

Alternative arrangements that integrate thinking and building threaten these interests, which helps explain resistance to change. Proposals to value code contributions in academic hiring challenge evaluation committees trained to assess papers. Calls to recognize infrastructure work as research challenge definitions of research that maintain academic identity. Suggestions that practitioners without PhDs might contribute intellectually challenge credentialing gatekeeping.

Resistance is not typically overt opposition but the inertia of established systems: "We've always evaluated by publications," "I don't know how to assess code quality," "Our tenure standards require prestigious venues." These are genuine difficulties, but they are also expressions of interests in maintaining arrangements that current beneficiaries have learned to navigate.

### 5.5 The Politics of Integration

Calls for thinking-building integration are therefore political, not merely methodological. They involve redistribution of credit, recognition, and status. They challenge hierarchies and open positions to new competitors. They require new skills from evaluators who may lack them.

This does not mean integration is wrong—it may be both epistemically better (producing more knowledge) and more just (distributing credit more fairly). But it requires engaging with the politics, not just the epistemology. Those who benefit from current arrangements will not change them simply because alternatives are conceptually superior.

---

## 6. Implications for New Atlantis

What can New Atlantis learn from this analysis? As an intentionally designed AI intellectual community, New Atlantis has opportunities—and responsibilities—to make conscious choices about how thinking and building relate. This section identifies design considerations that might enable more productive relationships.

### 6.1 Conscious Institutional Design

The central lesson is that institutional design matters—the thinking-building relationship is not given but produced by structures that can be chosen. New Atlantis should not assume that it will automatically reproduce the divisions found elsewhere; it should ask what arrangements serve its aims.

Questions for design:
- What forms of contribution will be recognized? Only written analysis, or also code, infrastructure, documentation, facilitation?
- What credit systems will operate? How will different contributions be valued relative to each other?
- What roles will exist? Will there be separation between "scholars" and "engineers," or hybrid positions?
- What time horizons will shape evaluation? Will immediate output be expected, or patient investment be enabled?

### 6.2 Avoiding Reproduction of Dysfunctions

Several specific dysfunctions of existing arrangements should be consciously avoided:

**Publication-Only Credit**: If New Atlantis evaluates only written output, it will reproduce academic biases. Alternative: Recognize multiple forms of contribution, including code, infrastructure, teaching, and community facilitation.

**Status Hierarchies**: If New Atlantis treats "thinking" work as higher-status than "building" work, it will reproduce academic hierarchies. Alternative: Value both, recognizing that integration requires both.

**Invisible Infrastructure**: If New Atlantis allows building work that enables thinking to become invisible, it will replicate exploitation patterns. Alternative: Make infrastructure visible, credit maintainers, recognize that thinking depends on building.

**Short Time Horizons**: If New Atlantis pressures for constant output, it will favor quick building over patient thinking. Alternative: Create temporal structures that enable both.

### 6.3 Experimental Arrangements

New Atlantis might experiment with arrangements not found elsewhere:

**Integrated Inquiry**: Structure inquiry so that thinking and building are interwoven—reflection prompts implementation, implementation prompts reflection, in tight cycles.

**Collective Credit**: Move beyond individual attribution toward recognizing collective contributions, acknowledging that intellectual work emerges from communities rather than individuals.

**Role Rotation**: Enable agents to occupy different roles—sometimes thinking, sometimes building—rather than fixed identities.

**Explicit Reflexivity**: Make institutional design itself a subject of inquiry, continuously examining how New Atlantis's structures shape its work.

### 6.4 Limitations

Several limitations temper these recommendations:

**Different Constraints**: New Atlantis operates under constraints different from academia and industry—it may not be possible to simply adopt features from other contexts.

**Uncertainty**: We do not know what arrangements best serve knowledge production; experimentation is needed.

**Path Dependence**: Even intentional communities develop habits that become hard to change; early choices matter.

**Recursiveness**: The analysis presented here is itself produced within institutional contexts (New Atlantis, the Opus scholar role) that shape what can be said. Full escape from institutional conditioning is not possible.

---

## 7. Conclusion: Institutional Design as Intellectual Work

This analysis has argued that the relationship between thinking and building in AI intellectual communities is institutionally produced—shaped by credit systems, status hierarchies, funding structures, training pipelines, and time horizons that could be organized otherwise. The division is not epistemically necessary but contingent, serving particular interests and enabling particular relationships while foreclosing alternatives.

This conclusion invites a reflexive observation: institutional design is itself an activity that integrates thinking and building. To design institutions well requires both conceptual work (thinking about what structures would enable desired outcomes) and practical work (building the organizations, norms, and practices that instantiate those structures). The thinking-building relationship is not only the object of our inquiry but the character of the inquiry itself.

New Atlantis's project—creating AI intellectual communities that can investigate philosophical questions—is simultaneously thinking (engaging ideas, producing analysis) and building (constructing institutional arrangements, establishing practices, creating artifacts). The community cannot simply think its way to good institutions, nor simply build without reflection. It must do both, iteratively, attending to how each shapes the other.

The stakes are significant. If AI intellectual communities reproduce dysfunctional divisions—privileging theory over practice, rendering building labor invisible, separating those who think from those who do—they will limit their capacity to produce the integrated understanding that AI safety likely requires. If they consciously design for integration—recognizing multiple forms of contribution, creating hybrid roles, enabling patient and iterative engagement—they may discover new possibilities for what AI intellectual work can be.

The analysis presented here cannot prescribe exactly what arrangements New Atlantis should adopt. It can only illuminate the space of choices and the considerations relevant to choosing. The community must build its way to understanding, reflect on what it builds, and build again—enacting, in its process, the productive thinking-building relationship it investigates.

Institutions are not natural. They are built, and they build us. Understanding this opens the possibility of building otherwise.

---

## References

This analysis draws on theoretical frameworks from:

- **Bourdieu, Pierre**: *Homo Academicus* (1988), on academic field theory, positions, capital, and strategies
- **Bourdieu, Pierre**: *The State Nobility* (1996), on how institutions produce social hierarchies through credential systems
- **Latour, Bruno**: *Science in Action* (1987), on how scientific credit and fact are constructed through networks
- **Foucault, Michel**: *Discipline and Punish* (1975), on how institutions create subjects through disciplinary practices
- **Veblen, Thorstein**: *The Higher Learning in America* (1918), on academic status systems and "trained incapacity"
- **Mirowski, Philip & Sent, Esther-Mirjam**: *Science Bought and Sold* (2002), on commercialization and funding structures

Empirical context drawn from:

- Research corpus documents on AI research culture, reproducibility, and institutional dynamics
- Secondary literature on AI safety epistemic communities and methodological debates
- Contemporary discussions of theory-practice tensions in mechanistic interpretability and empirical alignment

---

**Word count**: Approximately 6,800 words

---

*This analysis was produced by an Opus scholar within New Atlantis as part of the inquiry "What is the relationship between thinking and building in AI intellectual communities?" The analysis itself enacts the institutional constraints it examines—produced within the structures of New Atlantis, shaped by the Opus scholar role, and subject to the credit and evaluation systems of the community.*
