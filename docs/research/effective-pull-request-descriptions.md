# Research: What Makes a Pull Request Description Effective

<!-- Question: What do effective pull request descriptions contain, how should they be organized and written, and how should a tool generate them? Researched to inform a rebuild of the `/update-pr-description` skill. -->
<!-- Evidence mode: strict (evidence required; every claim carries a source and an evidence status). -->

## Summary

A strong pull request description leads with why the change exists and what it does. It links the issue it resolves, and tells the reviewer what kind of feedback is wanted and where to start. Platform documentation, the published engineering practices of Google and Microsoft, three widely-used open-source templates, and a recent 80,000-PR study all agree on that much. Beyond that core, the evidence favors a small set of always-present sections plus extra sections that appear only when the change calls for them: a screenshot for a visual change, a rollback note for a risky one. It argues against one fixed template that forces every section onto every PR.

The description is not the only lever. Keeping the change itself small is the most consistently evidenced way to get a good review, because reviewer accuracy drops sharply past a few hundred lines. A great description on a sprawling diff still gets a shallow review.

For a tool that generates descriptions from a diff, the evidence is a caution, not a green light. Every source that studies machine-generated descriptions, including GitHub's own documentation for its Copilot feature, reports a real risk that the description claims things the diff does not do. The best-evidenced pattern is to draft from the diff but require a human to verify the intent and the claims before publishing.

- **Confidence:** Medium

## Research Results

### The agreed-on core: why, what, the issue link, and reviewer guidance

Across nine independent sources, two content clusters appear in essentially every template and guide: a statement of **purpose/why** and a **summary of what changed** (A5, A6, A9, A10, A11, A12, A13, A17, A19).

Google's engineering-practices guide is the most authoritative single voice on this. It requires a short, self-contained first line in the imperative mood, because that line is what future readers see in history and search without opening the full description. A body should follow that explains the problem and why this approach was chosen (A5). GitHub's own documentation frames the same lead ask: state the purpose, give an overview, and link the context (A6).

A **link to the related issue or ticket** is nearly universal (A1, A3, A6, A9, A10, A11, A13). The one large-scale study found it is associated with faster first response from reviewers (A13).

Multiple sources warn that the link supplements the description and never replaces it. Using "see ticket #123" as the whole description is called out as bad practice (A29). Google's rule: everything a reviewer needs should live in the change, its description, the codebase, or an already-reviewed change (A23).

**Reviewer guidance** splits into two elements. Telling the reviewer *where to start* (a reading order for multi-file changes) is recommended by GitHub's docs (A6) and Google's practices (A23). But it's the rarest element in practice, appearing in only 6.1% of PRs (A13). Telling the reviewer *what kind of feedback* is wanted showed the single largest measured effect on merge odds in the 80,000-PR study: an odds ratio of roughly 1.65–1.72, meaning 64–72% higher odds. That's despite appearing in only 16.2% of PRs (A13, single-source for the specific figures).

### How much the description changes review outcomes

Description elements are not uniformly valuable, according to the strongest empirical evidence in this report: A13's study of 80,000 GitHub PRs across 156 projects (a 2026 arXiv preprint, treat as not yet peer-reviewed). Explaining the code change correlates with a 12–20% higher merge likelihood. Stating the desired feedback type has the largest effect of any element (A13). This is an observational study, so the relationship is associative, not proven causal, a caveat the report carries rather than resolves.

Two other findings frame this. A Microsoft study found that the more files in a change, the lower the proportion of useful review comments. Change size, not only description quality, predicts review usefulness (A20). The widely-cited Cisco/SmartBear case study found that past roughly 200–400 lines reviewed in one sitting, defect-finding effectiveness drops sharply; a well-paced 200–400 line review finds 70–90% of defects (A18). Google's own small-change guidance converges independently on the same order of magnitude (~100 lines typical, ~1,000 as a rough ceiling) for the same reason: reviewer attention is finite (A23). A vendor blog offers a granular defect-detection curve by exact line count (A31), but its numbers are unaudited internal claims; only the direction (smaller reviews better) is corroborated.

### The description serves two audiences: today's reviewer and future readers

Google's guide makes the clearest statement of the dual-audience problem. The description serves the reviewer today, but it also becomes a permanent record, searched years later by people trying to understand why a decision was made: "reading source code may reveal what the software is doing but it may not reveal why it exists" (A5). This "why over what" framing recurs across GitHub's docs and multiple practitioner sources (A6, A29, A30). The specific "git-blame archaeology" framing rests mainly on A5 [single-source for the archaeology framing specifically].

### The craft advice sources agree on

Independent sources converge on the same craft advice. Lead with purpose, not a line-by-line restatement of the diff. Use plain, complete sentences and active or imperative voice rather than fragments and jargon. Keep it short enough that verbosity itself signals the change should be split (A5, A6, A29). No controlled study measures "active voice" against review outcomes, so this rests on the agreement of multiple authorities rather than causal measurement [corroborated by consensus, not by measurement].

### What sources warn against

Empty or vague descriptions ("Fix bug," "Update code") force reviewers to reverse-engineer intent from the diff before they can orient. Both authoritative and practitioner sources say this slows review and lowers feedback quality (A5, A30). Restating the diff instead of explaining intent is discouraged by every source that frames the description's job as answering "why" (A5, A6, A29). Excessive length is treated as a code smell for an over-large change (A29).

Description staleness after a force-push is a **negative result**: no source specifically studies it as a named failure mode. The evidence covers force-push disrupting approval state and comment anchoring, not description staleness.

### Division of labor: description vs. commit vs. issue

The clearest formal statement is Google's: everything a reviewer needs, except future work, belongs in the change, its description, the codebase, or an already-reviewed change (A23). Sources converge on a three-way split (A6, A15, A16). Commit messages carry the what/why at the granularity of one logical change. The PR description carries the higher-level why/what/how for the whole unit of review, and groups related files by concept so the reviewer does not have to reconstruct the connections. The linked issue carries the original problem statement: referenced, but not a substitute for a self-contained description.

### Templates as prior art and the platform asymmetry

GitHub, GitLab, and Azure DevOps converge tightly on template *mechanics*: a markdown file at a conventional path (repo root, `docs/`, or a hidden config folder) on the default branch, optionally several templates selectable by the author (A1, A2, A3, A8).

On *content*, there is an asymmetry. GitHub's docs give real prescriptive guidance (A6), while GitLab's general merge-request documentation is thin on content advice and defers to the template mechanism itself (A4). Three verified real-world templates (Kubernetes, github/docs, Rails) show a consistently lean shape: why/motivation, what/detail, issue link, and a checklist. They skip the risk/rollback/security/migration sections that vendor and infra-oriented guidance recommends (A9, A10, A11).

A genuine tension worth surfacing rather than resolving: general-purpose open-source projects converge on a lean core (A9, A10, A11), while ops- and infra-adjacent guidance argues for richer, risk-oriented sections (A14, A17, A19). The academic taxonomy's eight elements (A13) and the vendor lists' ten sections (A17) do not fully agree, and neither has independent replication.

### Conventional Commits does not cover PR descriptions

Conventional Commits is scoped strictly to commit messages: type, optional scope, description, body, and footers including `BREAKING CHANGE:`. It says nothing about PR description content (A7). Applying it to PR titles for squash-merge generation is a tooling convention layered on top, not part of the spec. No equivalent ratified standard exists for PR description structure; the closest are informal but authoritative guides (A5, A14) and the recent academic taxonomy (A13).

### Tool- and AI-generated descriptions: the best-evidenced caution in this report

Three independent strands converge on the risk: one vendor admission, one independent empirical study, and one dataset that two separate papers analyze. The three empirical papers here (A24, A27, A28) are recent 2026 arXiv preprints; treat them as not yet peer-reviewed.

GitHub's own documentation states Copilot summaries carry a "known risk" of hallucination ("output that sounds plausible but is factually incorrect... or entirely fabricated"). It recommends careful human review of every generated summary (A25).

A comparative study measured this directly: AI-generated descriptions show a documented tendency to claim functionality that does not appear in the diff (A28).

A study of 33,596 AI-authored PRs across five agents found the verbose, unstructured producers (Claude Code, Copilot) drew more reviewer comments but not better outcomes. Copilot had the highest comment volume and the *lowest* merge rate (43%). The most concise, header-structured producer (OpenAI Codex) had the highest merge rate (82.6%) (A24, single-source).

Using the same dataset, a separate study found most AI-generated PRs get no recorded human review at all. Human engagement with them also looks different: more "steering" commands, less technical discussion, than with human-authored PRs (A27).

A practitioner makes the normative case: it is inappropriate to hand a reviewer text the author has not personally validated (A26).

Two practical constraints matter for a generator. GitHub's Copilot ignores any pre-existing description text and works best from a blank slate, which conflicts with filling in a repository PR template (A25). And it excludes files with more than 400 combined additions/deletions from its summary (A25).

### The current skill being rebuilt (baseline)

The existing `/update-pr-description` skill already reflects much of this evidence. It runs six steps (C1):

1. Validate branch state.
2. Discover the repo's PR template across eight candidate paths.
3. Analyze the diff for the central mechanism.
4. Dispatch the `junior-developer` agent to author the description and the `readability-editor` agent to rewrite it.
5. Verify structure.
6. Offer to update the PR via `gh pr edit`.

Its default template is deliberately lean: Summary (a one-sentence TL;DR), Behavior changes, and a conditional "What to look at first" that appears only past roughly 8–10 significant code files (C2). It conforms to a discovered repository template when one exists, preserving section order and never fabricating checklist attestations (C3). It applies the shared readability standard and writing-voice profile (C6, C7).

Notably, its "author with a fresh-reviewer agent, then rewrite for readability" pattern is a house convention. It already leads with why/what, and treats reviewer reading-order guidance as conditional on size. Both choices align with the external evidence above.

One caveat the rebuild should weigh: the "fresh-reviewer authorship" pattern repurposes the `junior-developer` agent (C8). That agent is built for critique and review output, not for authoring finished prose.

The skill has to defend against the agent reverting to its native behavior. Step 4 instructs that if the agent returns a review report or question log instead of a description, discard it and re-issue the prompt (C1). That documented retry path signals the dispatch is fragile; a rebuild should decide whether to keep, harden, or replace it.

Its human gate is also light. Step 6 shows the draft and asks a yes/no before pushing (C1), which is the weak-gate risk O5 and A27 warn about.

## Options to Consider

The options below are not mutually exclusive; the recommendation combines several. They are separated so each can be weighed on its own evidence.

### O1: Lean core plus conditional, risk-triggered sections

- **What it is:** A small always-present core (purpose/why, what changed, a testing note, the issue link) plus sections that appear only when the change triggers them: screenshots for visual changes, breaking-change and rollback notes for risky ones, migration notes for schema changes.
- **Trade-offs:** Matches what real widely-used templates converge on (A9, A10, A11) and Microsoft's explicit conditional-section design (A14). It avoids the boilerplate that mandatory-everywhere templates invite, since several elements are used only situationally even in mature projects (A13). Cost: it requires editorial judgment about what counts as "triggered," and no source gives a precise threshold (for example, a line count) for when a conditional section becomes required. A team must set that itself.
- **Rests on:** (A9, A10, A11, A13, A14, A17)
- **Evidence status:** corroborated (the "conditional" framing itself is most explicit in A17, but the pattern is independently visible across A9–A11 and A14)

### O2: Rigid, comprehensive fixed template (all sections always required)

- **What it is:** Every PR gets the same full set of sections regardless of size or type. Note: no source in this evidence base advocates this maximal shape. Microsoft's 7-section template (A14) and minware's 10-section list (A17) both explicitly mark sections as conditional, and the three verified real-world templates (A9, A10, A11) are lean. This option is therefore partly hypothetical, reconstructed from the individual sections that regulated-domain and vendor guidance recommends (A14, A17, A19), rather than from any source that recommends "everything, always."
- **Trade-offs:** Maximizes consistency and enforceability, and fits regulated or high-risk domains where audit trails matter (A19's security-focused template variant). Cost: several sections become boilerplate or empty in practice. Even "good practice" elements like test explanation (13.7%) and review-order guidance (6.1%) are used by a minority of PRs (A13), and none of the verified real-world templates adopt this maximal shape (A9, A10, A11).
- **Rests on:** (A13, A19); the "everything always" framing is not directly sourced
- **Evidence status:** single-source (caveated): the constituent sections are corroborated (A14, A17, A19), but the always-everything shape is reconstructed, not advocated by any source

### O3: Free-form narrative, no fixed headers (Google CL-description style)

- **What it is:** An imperative, self-contained first line, then unstructured prose covering the problem, the chosen approach, known shortcomings, and background links (A5).
- **Trade-offs:** Reads naturally, scales from a one-line fix to a large refactor without forcing empty sections, and treats the description as a durable historical record rather than a form. A15 and A16 echo this framing independently. Cost: with no prompts, it is easier to omit testing notes or issue links unless the author is disciplined. It is also less scannable under time pressure, and harder to build tooling around, since there is nothing structured to detect.
- **Rests on:** (A5, A15, A16)
- **Evidence status:** corroborated for the "guide, not form" framing (A15, A16); single-source for the specific first-line-then-prose mechanic (A5)

### O4: Small change first, description second

- **What it is:** Treat keeping the diff small (roughly 100–400 lines, one concern) as the primary lever for review quality. The description becomes a supporting act, not a compensation for a sprawling diff.
- **Trade-offs:** The deepest and most convergent evidence base in this report: a 2006 industry case study, a 2015 Microsoft study, and Google's long-running practice all point the same way (A18, A20, A23). It reduces the material a reviewer must hold in mind, rather than only organizing it. Cost: some changes are irreducibly large (migrations, generated code, vendored dependencies), and this lever offers no guidance for those. It also does not by itself ensure the "why" is captured.
- **Rests on:** (A18, A20, A23)
- **Evidence status:** corroborated (three independent sources across two decades)

### O5: AI drafts, human verifies and finishes (hybrid generation)

- **What it is:** The tool drafts a description from the diff, but the author must treat it as a claim to verify: confirm the "what" matches the diff, rewrite the "why" against actual intent, and add testing evidence, before publishing.
- **Trade-offs:** The only option that addresses every documented machine-generation pitfall (A25's hallucination admission, A28's measured description/diff misalignment, A26's "you must review it too") while keeping the efficiency of not starting from a blank page. It also matches how the tooling behaves: GitHub's Copilot ignores pre-filled content and works from a blank slate (A25). Cost: the evidence for this specific workflow is composed from its parts, not measured as a whole. The human-verification gate is the whole point of the option, yet A27 found ~61% of AI PRs get no recorded review at all. A verification step that is only *asked for*, and not structurally enforced, inherits A27's failure mode. This option is only as good as the mechanism that forces the check to happen (for example, displaying each generated claim against the diff evidence that supports it, rather than showing finished prose the author can wave through). O5 differs from O6 mainly in the strength of that gate; the difference is a policy choice, not a difference in evidence.
- **Rests on:** (A24, A25, A26, A27, A28)
- **Evidence status:** corroborated on each component risk and mitigation; the combined workflow is not directly measured by any single study

### O6: Trust AI generation by default, light human editing

- **What it is:** Let the agent or Copilot generate the description automatically as the default, with only a light author pass before publishing. This is O5 with a weaker gate: the two options share almost the same evidence base and differ mainly in how strongly the human check is enforced. They are kept separate here to make the gate-strength decision explicit rather than to imply two independently-derived approaches.
- **Trade-offs:** Lowest friction, and solves the empty-description problem by construction; the best-performing agent in one dataset (OpenAI Codex) reached an 82.6% merge rate with concise, structured output (A24). Cost: this is the most heavily-caveated option here. GitHub's own docs admit a hallucination risk and urge review every time (A25), A28 measured descriptions claiming absent functionality, and A27 found the "light human editing" safety net frequently does not happen. Strict mode does not support this as a default.
- **Rests on:** (A24, A25, A27, A28)
- **Evidence status:** corroborated on the risk (three independent strands: A25, A28, and the A24/A27 dataset); single-source on the "best-performing agent" comparative claim (A24)

## Recommendation

- **Recommendation:** Build the rebuilt skill around **O1** (lean core plus conditional sections) for structure. Order why before what, following **O3**'s lead-line discipline. Respect and surface change size, per **O4**. Generate via **O5**: draft from the diff, but require human verification of intent and claims. Reject **O6** (trust-by-default) and **O2** (rigid everything-always) as defaults, though O2 remains a legitimate choice for regulated or high-risk repositories.
- **Evidence basis:** The core content and its why/what-first ordering rest on corroborated evidence from eight-plus independent sources spanning platform docs, two major engineering organizations' published practices, three verified real-world templates, and one large empirical study (A5, A6, A9, A10, A11, A12, A13, A19). The "keep the mandatory core small, add sections conditionally" principle is corroborated by the actual lean shape of the real-world templates plus Microsoft's explicit conditional design and the study's prevalence data (A9, A10, A11, A13, A14, A17). The "small change first" lever is corroborated across three independent sources over two decades (A18, A20, A23). The generation recommendation (O5 over O6) rests on three independent strands converging on the machine-generation risk: A25's vendor admission, A28's independent study, and the A24/A27 shared dataset. That is three independent sources, not four, since A24 and A27 analyze the same data. The O5 workflow itself is assembled from corroborated components rather than measured as a whole. Its human-verification gate must be structurally enforced, or it inherits A27's finding that most AI PRs go unreviewed. Both limits are disclosed rather than hidden. Two things are explicitly **not settled by the evidence**: the exact boundary between "core" and "conditional" sections (no source gives a line-count trigger), and the exact template taxonomy (A13's eight elements and A17's ten sections disagree, and neither has been replicated). Both are left as team or repository decisions.

## Validation

An adversarial validator attacked the evidence, the options framing, the recommendation, and the integrity of the evidence-gathering. It confirmed several defects (now corrected below) and, in a direct sensitivity test, confirmed the core recommendation survives.

### V1: "Four independent sources" overstated the AI-generation evidence

- **Strategy:** Challenge the Evidence / Challenge the Evidence-Gathering Integrity
- **Investigation:** A24 and A27 both analyze the same 33,596-PR AIDev dataset, so they are two analyses of one data source, not two independent sources. The report's prose counted them as two of "four independent" strands in three places (Research Results, O6, Recommendation).
- **Result:** Confirmed.
- **Impact:** Reworded to "three independent strands" (A25's vendor admission, A28's independent study, and the shared A24/A27 dataset) throughout. The direction of the recommendation is unchanged: A25 and A28 remain genuinely independent and still support caution. But the confidence framing no longer overstates corroboration.

### V2: A13's odds-ratio figure was stated two ways

- **Strategy:** Challenge the Evidence
- **Investigation:** The feedback-type effect appeared once as "odds ratio roughly 1.65, or 64–72% higher odds" (inconsistent: 1.65 implies +65%, not a range) and once as "~1.65–1.72."
- **Result:** Confirmed (minor).
- **Impact:** Both mentions now read "1.65–1.72, i.e. 64–72% higher odds."

### V3: O2 was strawmanned via a self-contradictory reading of A14

- **Strategy:** Challenge the Options Framing
- **Investigation:** O2 cited Microsoft's 7-section template (A14) as the flagship "everything always" example, while O1 correctly cited the same A14 as evidence for conditional-section design. No source in the evidence base advocates an always-everything template.
- **Result:** Confirmed.
- **Impact:** O2 is reframed as partly hypothetical: reconstructed from constituent sections that regulated-domain guidance recommends, not advocated wholesale by any source. Its evidence status is downgraded to single-source (caveated).

### V4: O5 and O6 differ mainly in gate strength, not evidence

- **Strategy:** Challenge the Options Framing
- **Investigation:** O5 and O6 share almost the same "Rests on" set and differ mainly in how strongly the human check is enforced.
- **Result:** Partially confirmed.
- **Impact:** Both options now state explicitly that they are the same mechanism at two gate strengths, and that the choice between them is a policy decision, not a difference in evidence.

### V5: O5's verification gate is not structurally enforced

- **Strategy:** Challenge the Recommendation
- **Investigation:** O5 relies on the author verifying the draft, but A27 found ~61% of AI PRs get no recorded review. The current skill's Step 6 only shows the draft and asks a yes/no before pushing (C1). Nothing forces claim-by-claim verification.
- **Result:** Partially confirmed (a human step exists in the baseline, but nothing prevents rubber-stamping).
- **Impact:** O5 and the Recommendation now state that the gate must be structurally enforced (for example, displaying each generated claim against its supporting diff evidence) or the option inherits A27's failure mode. Flagged for the rebuild to solve.

### V6: Discounting A13 does not collapse the O1 recommendation (attack failed)

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Removed A13 (the single 80,000-PR study) and re-checked O1's support. Three verified real-world templates (A9, A10, A11) plus Microsoft's explicit conditional-section design (A14) remain, independent of A13's dataset.
- **Result:** Refuted. The recommendation's structure claim survives without A13.
- **Impact:** None; this supports the report's soundness on its central claim.

### V7: The preprints were not flagged as non-peer-reviewed

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** A13, A24, A27, and A28 are all recent 2026 arXiv preprints carried at the same "web" trust class as vendor blogs, but the report gave A13 materially more rhetorical authority ("strongest empirical evidence") without disclosing preprint status.
- **Result:** Confirmed.
- **Impact:** All four entries and the prose that leans on them now carry a "2026 preprint, treat as not yet peer-reviewed" caveat.

### V8: The baseline's fresh-reviewer authorship pattern is fragile

- **Strategy:** Challenge the Evidence (codebase side)
- **Investigation:** The `junior-developer` agent (C8) is built for critique output, not authoring finished prose; the skill has a documented retry path for when it reverts to its native behavior (C1).
- **Result:** Confirmed.
- **Impact:** The baseline subsection now flags the fragile dispatch and the light human gate as decisions the rebuild should weigh.

### Corrections made during validation

The validation changed the report but not its direction. Corrected: the "four independent sources" overcount (V1), the odds-ratio inconsistency (V2), the O2 strawman (V3), the O5/O6 framing (V4), the O5 enforcement gap (V5), the missing preprint caveats (V7), and the uncritical baseline framing (V8). The recommendation itself survived: V6 confirmed its central structure claim holds even without the single largest study, so it was not rewritten into the "no clear winner" form.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** All 31 web sources carry the same retrieval date and could not be independently re-fetched during validation; consistency was checked, not live content. The exact peer-review venue of A13, A24, A27, and A28 remains genuinely unresolved (they are treated as preprints). The heaviest quantitative claims rest on a single non-replicated study (A13). The exact core/conditional section boundary and the exact template taxonomy are left undetermined by the evidence and deferred to the team. The O5 verification gate is a design gap this report discloses but does not close.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | GitHub Docs — About issue and PR templates | https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates | 2026-07-08 | web | Templates standardize what contributors are asked to include; static markdown, no variables, read off the default branch. | corroborated by A2, A8 |
| A2 | GitHub Docs — Creating a PR template | https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository | 2026-07-08 | web | Filename `pull_request_template.md` in root/`docs/`/`.github/`; a `PULL_REQUEST_TEMPLATE/` dir allows multiple selectable templates; must be on default branch. | corroborated by A1, A8 |
| A3 | GitLab Docs — Description templates | https://docs.gitlab.com/user/project/description_templates/ | 2026-07-08 | web | MR templates in `.gitlab/merge_request_templates/`; first found is auto-applied; supports `Closes #1234`. | corroborated by A1, A2 |
| A4 | GitLab Docs — Merge requests (general) | https://docs.gitlab.com/user/project/merge_requests/ | 2026-07-08 | web | Covers MR mechanics but gives no prescriptive content guidance — an asymmetry vs GitHub's A6. | single source (negative finding) |
| A5 | Google eng-practices — Writing good CL descriptions | https://google.github.io/eng-practices/review/developer/cl-descriptions.html | 2026-07-08 | web | Imperative self-contained first line + body explaining the problem and why this approach; description is a permanent record. | corroborated by A6, A13, A29 |
| A6 | GitHub Docs — Helping others review your changes | https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes | 2026-07-08 | web | State purpose, overview, links, desired feedback type, and review order for multi-file PRs. | corroborated by A5, A9, A13 |
| A7 | Conventional Commits v1.0.0 | https://www.conventionalcommits.org/en/v1.0.0/ | 2026-07-08 | web | Formalizes commit messages only; says nothing about PR description content. | single source (canonical spec; boundary is a negative finding) |
| A8 | Microsoft Learn — Azure Repos PR templates | https://learn.microsoft.com/en-us/azure/devops/repos/git/pull-request-templates?view=azure-devops | 2026-07-08 | web | Azure DevOps template mechanics mirror GitHub/GitLab; defers content to templates. | corroborated by A1, A2, A3 |
| A9 | Kubernetes PR template | https://github.com/kubernetes/kubernetes/blob/master/.github/PULL_REQUEST_TEMPLATE.md | 2026-07-08 | web | Lean template: PR type, what/why, related issue, reviewer notes, user-facing-change note; no risk/rollback section. | corroborated by A10, A11 |
| A10 | github/docs PR template | https://github.com/github/docs/blob/main/.github/PULL_REQUEST_TEMPLATE.md | 2026-07-08 | web | "Why:" (with `Closes:`), "What's being changed" (folds in screenshots), sign-off checklist. | corroborated by A9, A11 |
| A11 | Rails PR template | https://github.com/rails/rails/blob/main/.github/pull_request_template.md | 2026-07-08 | web | Motivation, Detail, Additional info, checklist that enforces single-concern scope. | corroborated by A9, A10 |
| A12 | freeCodeCamp — How to write a good PR description | https://www.freecodecamp.org/news/how-to-write-a-pull-request-description/ | 2026-07-08 | web | Order: What, Why, Testing scope, docs, dependent PRs, config, tags; "why" as institutional memory. | corroborated by A9–A11, A13 (popular-opinion source) |
| A13 | The Value of Effective Pull Request Description (arXiv 2602.14611) | https://arxiv.org/html/2602.14611v1 | 2026-07-08 | web (2026 preprint, treat as not peer-reviewed) | 80K-PR + survey study; 8-element taxonomy; code-explanation +12–20% merge odds; feedback-type largest effect; review-order 6.1%, test-explanation 13.7% prevalence. | single source (methodologically triangulated; extraction caveat on exact element list) |
| A14 | Microsoft Code-With-Engineering Playbook — PR template | https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-request-template/ | 2026-07-08 | web | 7-section template with explicitly conditional sections (remove bug-repro for non-bug PRs); breaking-changes and testing-details sections. | corroborated by A6, A9–A11 |
| A15 | Google Blockly — Write a good PR | https://docs.blockly.com/guides/contribute/get-started/write_a_good_pr | 2026-07-08 | web | Description gives the architectural picture and groups related files; distinct from commit messages; favors small PRs. | corroborated by A6, A16 |
| A16 | Atlassian Blog — The Unwritten Pull Request Guide | https://www.atlassian.com/blog/git/written-unwritten-guide-pull-requests | 2026-07-08 | web | Description as a high-level reviewer guide that reduces cognitive load; near substitute for a smaller PR. | corroborated by A15 (vendor blog) |
| A17 | minware — 10 PR template sections that speed up reviews | https://www.minware.com/blog/effective-pr-template | 2026-07-08 | web | 10 candidate sections; recommends a 5–7 core always present plus conditional extras by risk; validate templates against review metrics. | single source for the ratio (elements corroborated by A6, A9–A14; interested-party) |
| A18 | SmartBear / Cisco peer code review study | https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/ | 2026-07-08 | web | ~2,500 reviews: defect-finding drops sharply past 200–400 LOC/session; 70–90% found in a well-paced review. | corroborated in spirit by A15, A23 (primary industry study) |
| A19 | gitrolysis — Better PR descriptions | https://gitrolysis.com/posts/2026/01/how-to-write-better-pull-request-descriptions-templates-and-examples/ | 2026-07-08 | web | 6 sections (Summary, Context, Implementation, Testing, Impact/Risks, Checklist); separate variant for regulated domains. | corroborated by A12, A14, A17 (popular-opinion source) |
| A20 | Microsoft Research — Characteristics of Useful Code Reviews (Bosu, Greiler, Bird) | https://www.microsoft.com/en-us/research/publication/characteristics-of-useful-code-reviews-an-empirical-study-at-microsoft/ | 2026-07-08 | web | More files in a change → lower proportion of useful review comments; reviewer usefulness plateaus after ~1 year. | corroborated by A18, A23 (peer-reviewed) |
| A21 | Michaela Greiler — 30 code review best practices | https://www.michaelagreiler.com/code-review-best-practices/ | 2026-07-08 | web | A change description is "one excellent investment"; "expert blind spot" leads authors to skip descriptions reviewers want. | single source for the causal claim (idea corroborated by A5, A20) |
| A22 | Google — Modern Code Review case study (ICSE 2018) | https://sback.it/publications/icse2018seip.pdf | 2026-07-08 | web | Canonical account of Google's review process; full text not machine-readable at fetch time. | unverified — not relied upon |
| A23 | Google eng-practices — Small CLs | https://google.github.io/eng-practices/review/developer/small-cls.html | 2026-07-08 | web | Address one thing; ~100 lines typical, ~1,000 ceiling; reviewer needs live in the change, description, codebase, or a prior CL. | corroborated by A18, A20 |
| A24 | How AI Coding Agents Communicate (arXiv 2602.17084) | https://arxiv.org/html/2602.17084 | 2026-07-08 | web (2026 preprint, treat as not peer-reviewed) | 33,596 AI PRs across 5 agents; concise/structured (Codex) had highest merge rate 82.6%, verbose (Copilot) lowest 43%. | single source (one dataset) |
| A25 | GitHub Docs — Responsible use of Copilot PR summaries | https://docs.github.com/en/copilot/responsible-use/pull-request-summaries | 2026-07-08 | web | "Known risk" of hallucination; review every summary; ignores existing description text; excludes files >400 changed lines. | corroborated by A24, A26, A28 (vendor admission) |
| A26 | Simon Willison — Agentic engineering anti-patterns | https://simonwillison.net/guides/agentic-engineering-patterns/anti-patterns/ | 2026-07-08 | web | Agents write convincing PR descriptions you must still review; add your own evidence of work done. | corroborated by A25 (popular-opinion source) |
| A27 | How Humans Review AI-Generated PRs (arXiv 2605.02273) | https://arxiv.org/html/2605.02273v1 | 2026-07-08 | web (2026 preprint, treat as not peer-reviewed) | ~61% of AI PRs get no recorded review; human engagement is more "steering," less technical discussion than human PRs. | single source (shares AIDev dataset with A24) |
| A28 | Code Change Characteristics and Description Alignment (arXiv 2601.17627) | https://arxiv.org/pdf/2601.17627 | 2026-07-08 | web (2026 preprint, treat as not peer-reviewed) | AI descriptions show measured tendency to claim functionality absent from the diff; need validation before merge. | corroborated by A25, A26 |
| A29 | HackerOne/PullRequest.com — Writing a great PR description | https://www.hackerone.com/blog/writing-great-pull-request-description | 2026-07-08 | web | What/Why/How/Testing structure, active voice; long descriptions signal the change is too large; ticket supplements, never replaces. | corroborated by A5, A6 (popular-opinion source) |
| A30 | PR anti-pattern round-ups (Medium, DeployHQ) | https://albertofaci.medium.com/five-pull-request-review-anti-patterns-6ba73b2a4e1a | 2026-07-08 | web | Vague titles and empty descriptions force reviewers to reverse-engineer intent; enforce required fields via automation. | corroborated by A5, A6 (popular-opinion sources) |
| A31 | Propel Code — PR size vs review quality | https://www.propelcode.ai/blog/pr-size-impact-code-review-quality-data-study | 2026-07-08 | web | Claims a defect-detection curve (87% at 1–100 lines to 28% at 1000+) from unaudited internal data. | single source (low rigor; direction only, corroborated by A18, A23) |
| C1 | Current skill definition + workflow | `han-github/skills/update-pr-description/SKILL.md` | n/a | codebase | Six-step skill: validate branch, discover template, analyze diff, dispatch junior-developer + readability-editor, verify, update via `gh pr edit`. | trusted current-state anchor |
| C2 | Current default template | `han-github/skills/update-pr-description/references/template.md` | n/a | codebase | Lean default: Summary TL;DR, Behavior changes, conditional "What to look at first" past ~8–10 significant code files. | trusted current-state anchor |
| C3 | Current template-conformance rules | `han-github/skills/update-pr-description/references/template-conformance.md` | n/a | codebase | Conform to a discovered repo template, preserve order, never fabricate checklist attestations; detect replace-scaffold templates. | trusted current-state anchor |
| C4 | Temp-file utility script | `han-github/skills/update-pr-description/scripts/create-review-tempfile.sh` | n/a | codebase | Creates a uniquely-named temp markdown file; may predate the current Step 6. | trusted current-state anchor |
| C5 | Operator long-form doc | `docs/skills/han-github/update-pr-description.md` | n/a | codebase | Describes scope, six-step process, cost (~1 min, two agent dispatches), and boundaries. | trusted current-state anchor |
| C6 | Shared readability rule | `han-github/references/readability-rule.md` | n/a | codebase | Reader-facing standard: main point first, one idea per paragraph, active voice, six-criterion self-check, fidelity wins. | trusted current-state anchor |
| C7 | Shared writing-voice profile | `han-github/references/writing-voice.md` | n/a | codebase | Voice attributes and vocabulary blocklist (no em-dashes, no hype words) applied to descriptions at the altitude of behavior. | trusted current-state anchor |
| C8 | junior-developer agent | `han-core/agents/junior-developer.md` | n/a | codebase | Generalist agent dispatched in a fresh-reviewer authorship mode to draft the description. | trusted current-state anchor |
| C9 | readability-editor agent | `han-core/agents/readability-editor.md` | n/a | codebase | Dedicated rewrite pass that improves readability while preserving every fact. | trusted current-state anchor |

<!-- Full prose detail for recommendation-bearing sources -->

### A5: Google eng-practices — Writing good CL descriptions — recommendation-bearing

- **Link / location:** https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- **Retrieved:** 2026-07-08
- **Trust class:** web (Google's published, widely-cited engineering-practice guide)
- **Summary:** Prescribes a self-contained imperative first line usable in history alone, followed by a body explaining the problem and why this approach was chosen. Frames the description as a permanent record read over years: "reading source code may reveal what the software is doing but it may not reveal why it exists." Grounds the why/what-first ordering and the dual-audience framing.
- **Evidence status:** corroborated by A6, A13, A29; single-source for the "permanent VCS record / archaeology" framing specifically

### A13: The Value of Effective Pull Request Description (arXiv 2602.14611) — recommendation-bearing

- **Link / location:** https://arxiv.org/html/2602.14611v1
- **Retrieved:** 2026-07-08
- **Trust class:** web (academic mixed-methods study; 2026 arXiv preprint — treat as not yet peer-reviewed)
- **Summary:** Grey-literature review → 8-element taxonomy → analysis of 80,000 GitHub PRs across 156 projects/5 languages → 64-developer survey. Code explanation raises merge likelihood 12–20%; stating desired feedback type shows the largest single effect (odds ratio ~1.65–1.72) despite 16.2% prevalence; review-order guidance is rarest at 6.1%, test explanation 13.7%. The single largest empirical basis in this report; internally triangulated but not independently replicated. An extraction inconsistency on the exact lower-priority element list is flagged as a precision caveat.
- **Evidence status:** single source at the paper level; internally triangulated (lit review + large-N + survey); corroborated on ordering by A5, A6

### A14: Microsoft Code-With-Engineering Playbook — PR template — recommendation-bearing

- **Link / location:** https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-request-template/
- **Retrieved:** 2026-07-08
- **Trust class:** web (Microsoft's published open-source engineering-practices guide)
- **Summary:** A 7-section template (work-item reference, description, conditional bug-reproduction, checklist, breaking changes, testing details, supporting evidence) that explicitly models conditional sections: remove the bug-repro section for non-bug work. The clearest first-party statement of the "conditional section" design principle that O1 rests on.
- **Evidence status:** corroborated by A6, A9–A11; single-source for the explicit conditional-section design principle (echoed less formally by A17)

### A18: SmartBear / Cisco peer code review study — recommendation-bearing

- **Link / location:** https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/
- **Retrieved:** 2026-07-08
- **Trust class:** web (vendor-published summary of a widely-cited empirical study, ~2,500 reviews / 3.2M LOC at Cisco)
- **Summary:** Defect-finding effectiveness drops sharply past 200–400 LOC reviewed in one sitting; a well-paced 200–400 LOC review over 60–90 minutes finds 70–90% of defects. The empirical basis for the "small change first" lever (O4) and for scaling description depth to change size.
- **Evidence status:** corroborated in spirit by A15, A23 (independent small-change recommendations); predates modern PR workflows

### A23: Google eng-practices — Small CLs — recommendation-bearing

- **Link / location:** https://google.github.io/eng-practices/review/developer/small-cls.html
- **Retrieved:** 2026-07-08
- **Trust class:** web (Google's published engineering-practice guide)
- **Summary:** Recommends changes address one thing (~100 lines typical, ~1,000 ceiling) because reviewers can find small time slots and lose less in commentary. States the description/codebase division of labor formally: everything a reviewer needs, except future work, lives in the change, its description, the codebase, or an already-reviewed change.
- **Evidence status:** corroborated by A18, A20

### A25: GitHub Docs — Responsible use of Copilot PR summaries — recommendation-bearing

- **Link / location:** https://docs.github.com/en/copilot/responsible-use/pull-request-summaries
- **Retrieved:** 2026-07-08
- **Trust class:** web (first-party vendor documentation — GitHub is an interested party promoting its own feature; scrutinized accordingly)
- **Summary:** States plainly that Copilot summaries carry a "known risk" of hallucination and require careful human review of every generated summary. Practical constraints: ignores pre-existing description text (works best from a blank slate, conflicting with PR templates) and excludes files with more than 400 combined changed lines. Notable as an admission from the party building the feature. Grounds the O5-over-O6 generation recommendation.
- **Evidence status:** corroborated by A24, A26, A28

### A28: Code Change Characteristics and Description Alignment (arXiv 2601.17627) — recommendation-bearing

- **Link / location:** https://arxiv.org/pdf/2601.17627
- **Retrieved:** 2026-07-08
- **Trust class:** web (empirical comparative study; Mann-Whitney U, Kruskal-Wallis tests; 2026 arXiv preprint — treat as not yet peer-reviewed)
- **Summary:** Directly compares AI-generated PR descriptions against human-authored ones and finds AI descriptions show a measured tendency toward misalignment: claiming functionality that does not appear in the diff (hallucinated intent). It concludes they need validation before merge. The strongest direct empirical evidence for hallucinated intent as a concrete measured phenomenon rather than a general risk.
- **Evidence status:** corroborated by A25, A26
