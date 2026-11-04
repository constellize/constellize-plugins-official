# Project 2: Marketplace 2.0 — the feature workflow

**Status**: design, awaiting approval
**Date**: 2026-11-03
**Sequence**: project 1 (done) → 1.5 (done) → **2** → 4 (delivery) → 3 (Copernicus)

> Written without a brainstorming interview. Steve chose on 2026-11-03 to have the design written
> from the memory bank rather than answer questions first, so **every decision below is the
> author's call unless it is marked as Steve's**. The calls are collected in §9 so they can be
> checked quickly rather than hunted for.
>
> A fresh engineer then read the draft as a builder would, with read access to the trees, and
> returned ten questions and four corrections. All of them are settled in this version — §13 lists
> what changed and why, including one claim of the author's own that was wrong. Nothing was left
> for a second round.
>
> Six recorded claims did not survive checking; they are in §11 with what replaced them.

---

## 1. Intent

Give the method a feature-sized workflow: **specify → implement → verify**, with state you can see.

The marketplace today can design a system and it can assess one, but it has no unit of work between
"here is the project" and "here is a skill that checks one quality dimension". The live course has
exactly that unit — three skills driving a feature through SPECIFIED → IMPLEMENTED → VERIFIED — and
it is the part of the course Steve wants to keep. The course's own copies die with crew (project 4).

**Steve, 2026-11-03: "lets bring the course skills in, but delegate the steps to the existing other
skills (eg craft) so they are skills that use other skills."** And: *"we should probably delegate
the harness orchestrate and the other task to the new skills that are coming in, as long as they
are functionally the same."*

So the shape is one path at three zoom levels:

```
constellize-harness:orchestrate / :plan        ← "what should I do next?"
        └── constellize-feature:specify / :implement / :verify   ← the unit of work, with state
                └── constellize-design / :craft / :deliver / :memory  ← the mechanical phases
                        └── agents (requirements-analysts, system-architects, qa-engineers)
                                                                ← the adversarial passes
```

**Why they exist at all is teaching and tracking, not encapsulation.** Steve, 2026-11-03: *"it's
very important that we can track workflow, encapsulation is important but not as much while we are
learning to trust AI agents."* The harness's existing "Add a new feature" route has no state at all
— it infers progress from which files happen to exist. The three skills write a status a human and
the assessor can both read, and `verify` writes evidence the assessor can check the status against.

After this project, 2.0 is the marketplace on `main` with a feature workflow, a coverage threshold
you can set, and a prompt library published at `/prompts/v2/`. Nothing else about 2.0 changes
(§7.4).

---

## 2. Goals

1. **Three skills — `specify`, `implement`, `verify` — in a new `constellize-feature` plugin**,
   authored in `prompt-factory` like every other generated skill, driving
   `llm/features/<name>/spec.md` through SPECIFIED → IMPLEMENTED → VERIFIED.
2. **Each skill delegates every phase that an existing skill or agent already performs.** The
   delegation map in §6 is normative: if a phase is not in that map, it is not in the skill. Where
   the marketplace has no equivalent, the skill carries it and §6 says so explicitly — there is
   exactly one such case (§6.3).
3. **`constellize-harness:plan` and `:orchestrate` route "Add a new feature" to the three** instead
   of to their current six-step list, which the three contain in full (§6.4).
4. **The coverage threshold is a parameter with the book's number as its default**, so the printed
   book stays true and the course's 100% becomes an opt-in — without editing
   `constellize-craft:test-coverage` (§7.5).
5. **A VERIFIED status is substantiated or the assessor says it is not.** `verify` records what it
   measured; `constellize-harness:assess` reports each feature's status and whether the evidence
   for it exists. This is the project's answer to the live course's central defect (§6.3, §6.6).
6. **The prompt library is published at `/prompts/v2/` as a complete snapshot of the 2.0 line**,
   with `/prompts/v1/` frozen and still serving the book's 66 deep links.
7. **Every file either generator emits stays byte-compared, on both website lines.** Stated this
   way deliberately: the website's index data lives in `src/` and is outside the guard by design
   (§7.2, §11.6).

## 3. Non-goals

- **The three course skills are not ported, they are rewritten.** The course versions hardcode
  Python (`uv run pytest --cov -v`, `uv sync && uv run crew`, `uv run ruff check .`), the
  underscore `llm/memory_bank/` layout, a single-file state artifact, and `/constellize:feature:*`
  command names. None of that survives.
- **`v1` is not touched**, in any repository. Project 1.5 decision 1 stands.
- **The book manuscript is not edited.** §7.3 resolves the unpinned install command without a
  words change.
- **No skill outside `constellize-feature` has its text edited.** Not `constellize-craft`, not
  `constellize-deliver`, not `constellize-design`. This is what keeps 2.0 additive (§7.3), and it
  is the constraint that shapes §6.3. The three jobs it defers are named in §12.
- **No course-night rewrites.** The memory bank deferred "the rewrite of the five course nights" to
  this brainstorm; it belongs to project 4 instead (§7.4).
- **No harness tests project, and no harness defect sweep.** One exception, scoped: the assessor
  functions this project changes get tests (decision 12).
- **No decision on the 97-line versus 1,052-line `establish` skill.** Still open, still its own
  work.
- **No generated prompts manifest.** Project 1 recommended it as its own small piece of work and
  that recommendation stands; this project adds three entries by hand (§7.2).
- **No new marketplace name, and no second repository.** §7.1.
- **Two features in flight is supported; two features being *implemented* concurrently in one
  working tree is not.** §6.6 explains which half of that is a design property and which is just
  git.

## 4. Anti-goals

This project has failed, even if it technically works, if any of these are true:

- **A statement in the printed book has become false.** Not "incomplete" — false. §7.3 and §5 set
  out what that forbids.
- **A `v1` reader's install, skills, or prompt pages changed in any way.**
- **A skill in the three duplicates a capability the marketplace already has.** If `specify` writes
  its own adversarial questions instead of calling `requirements-analysts`, the project has
  produced a fourth convention rather than removed one — the same failure 1.5 was about.
  **This forbids duplicating a capability. It does not forbid `verify` owning a verdict**: judging
  pass or fail is `verify`'s own job and no existing skill does it (§6.3). The distinction was
  muddled in the first draft and cost a wrong design; it is load-bearing.
- **The workflow is Python-shaped.** A user on Go, TypeScript or Rust must be able to run all three
  skills with no edits.
- **A feature can be marked VERIFIED with nothing recorded to back it.** A feature marked VERIFIED
  whose gates never ran is the exact defect the live course has (12–22% coverage, every spec
  VERIFIED) — and the course's text already forbids it in capitals, which is precisely why prose is
  not an answer here. The defence has to be machine-checkable (§6.6).
- **The harness and the three can both be invoked for the same job and give different answers.**
- **The feature workflow overwrites project-level design artifacts.** §6.6.

---

## 5. Constraints

**The printed book is fixed, and three of its sentences bind this design.** `book/ch9.md:324` and
`book/appA.md:48` both say *five* skills exist to drive the rest, and `book/appC.md:33` lists the
Harness plugin's skills as exactly `orchestrate`, `assess`, `plan`, `execute`, `init`. Putting the
three new skills into `constellize-harness` would make all three places false. This is why the
three go in a plugin of their own (decision 1) — not taste, evidence.

**`book/appC.md:11` prints an unpinned install command**, so a print reader lands on whatever the
repository's default branch serves. Steve decided on 2026-11-03 to leave the words alone at proof
stage. The design therefore has to make `main` safe for that reader rather than redirect them
(§7.3).

**No marketplace skill can invoke a skill or an agent today.** Across all 74 generated `SKILL.md`,
`allowed-tools` is only ever `Read, Glob, Grep`, `…, Bash`, or `…, Write, Bash`. The only
delegation that exists anywhere in the marketplace is **advisory prose**:
`constellize-harness:execute` prints `/<plugin>:<skill> <arguments>`, says "Press enter when done,
or 's' to skip", then checks that the expected artifact appeared. Its `spawn` mode is marked
"Phase 2 — not yet implemented". A design built on "delegates to" has to say what that means
mechanically, and §6.6 does.

**The content model passes `allowed-tools` through verbatim.** `generate-marketplace.ts:136` emits
whatever array the prompt's `skill['allowed-tools']` holds, so giving the three skills a different
tool set is frontmatter, not a generator change.

**Thirteen of the sixteen skills `verify` would delegate to emit no verdict.** Only
`constellize-craft:test-coverage` has `**Gate Status:** ✅ PASS / ❌ FAIL` and "FAIL the gate if
thresholds not met". The Gate 2, 3 and 4 skills carry their gate label only in their `description:`
frontmatter; their bodies are *constructive* — they build health checks, containers, rollback
procedures and documentation, with `allowed-tools: Read, Glob, Grep, Write, Bash`. §6.3 is built
around this rather than against it.

**The delegated design skills write to fixed project-level paths.** `gap-analysis` →
`llm/construction/requirements/gap-analysis.md`; `implementation-sketch` →
`llm/construction/design/implementation-sketches.md`, and it *reads* `gap-analysis.md`,
`constellation-map.md` and `scope-lock.md`; `constellation-map` →
`llm/construction/requirements/constellation-map.md`. Only `code-generation-plan` is per-target.
Those same files are what `tier1.ts` reads to compute construction progress. §6.6 settles it.

**Anything under `prompt-factory/content/literal/` is generated output.** Editing it is a release:
push the factory, bump the consumer's `GENERATED_FROM` to that commit, push the consumer. The
marketplace's `drift.yml` runs the guard from the commit `GENERATED_FROM` names, so a guard change
is not self-deploying.

**`GENERATED_FROM` keeps its invariant**: the commit whose generator produced this output, not the
tip.

**The website is generated from the `v1` line, not from `main`.** Website `GENERATED_FROM` is
`0d97085`, reachable from prompt-factory `v1` and **not** from `main`. So the website cannot be
repointed at `main` — that would regenerate the 73 prompt files the book's 66 `/prompts/v1/<id>`
links depend on, from 2.0 content. The website has to hold two lines at once (§7.2).

**The website prompt version is a whole-run parameter, and personas are not versioned at all.**
`generate-website.ts:109` is `generate(websiteDir, version = 'v1')`; prompts go to
`public/prompts/<version>/<id>/`, but personas go to `public/personas/<category>/<subcategory>/`
with no version in the path. So a second generator run for `v2` rewrites the *same* 14 persona
files. This is the sharpest trap in §7.2 and the design names it rather than leaving a builder to
discover it with a guard that can never go green.

**A Claude Code plugin cannot run `npm install`** and the harness runs on Node's built-in type
stripping (Node 22.18+ / 23.6+ / 24+). Any assessor change inherits that floor and must add no
dependency.

**Changing a marketplace's `name` for existing users is undocumented.** The `renames` map in
`marketplace.json` migrates *plugin* names, not the marketplace's own. This constrains §7.1.

---

## 6. The workflow

### 6.1 `constellize-feature:specify`

Produces `llm/features/<name>/spec.md` at status SPECIFIED. Never writes source or test files.

| Phase | Delegates to | Kept in the skill |
|---|---|---|
| Project and feature context | `constellize-harness:assess`, then read `llm/memory-bank/*` | — |
| What exists that can be reused, and what is missing | `constellize-design:gap-analysis`, feature-scoped, captured into the spec (§6.6) | — |
| Adversarial interview | the **`constellize-design:requirements-analysts` agent**, which already has an `ADVERSARIAL ANALYSIS MODE` — it generates the questions, the skill asks them (§6.5) | the protocol: one question at a time, wait, summarise, refuse vague answers, 2–5 questions, and the two always-asked questions (definition of done; how it will be verified) |
| Sample implementation | `constellize-design:implementation-sketch`, captured into the spec | — |
| Draft the spec | — | the feature-spec template (Problem / Goals / Non-Goals / Design / Edge cases / Given-When-Then acceptance criteria) |
| Dual-persona review | the **`constellize-design:system-architects`** agent (business value, risk, alternatives, maintenance) and the **`constellize-craft:qa-engineers`** agent (testability, edge cases, debuggability) | the protocol: alternate personas, one question per turn, never batched |
| Final spec, status SPECIFIED, record it | `constellize-memory:update` | the status write |

**Why the template is not delegated.** `constellize-design:specification` is a *product* spec —
`{{product_name}}`, FR-001/NFR-001, system constraints, 72 lines, no interview. It is not a feature
spec and cannot be made into one by parameterisation. The memory bank's rationale for bringing the
course skills in was that the marketplace has no equivalent; that one checked out (§11).

### 6.2 `constellize-feature:implement`

Reads a SPECIFIED spec, leaves it IMPLEMENTED. Refuses to start without one.

| Phase | Delegates to | Kept in the skill |
|---|---|---|
| Identify stars (reference implementations) | `constellize-design:constellation-map`, captured into the spec | — |
| Gap, then plan | `constellize-design:gap-analysis` → `:implementation-sketch` → `:code-generation-plan` | the plan-confirmation turn |
| Code and tests, test-first per unit | `constellize-craft:unit-tests`, `:integration-tests`, and `:contract-tests` when the feature crosses an API boundary | — |
| Adversarial test review | the **`constellize-craft:qa-engineers`** and **`constellize-design:system-architects`** agents | the protocol, and the rule that a revealed gap becomes a test before anything else |
| Coverage | `constellize-craft:test-coverage` at the threshold in force (§7.5) | — |
| Status IMPLEMENTED, record it | `constellize-memory:update` | the status write |

### 6.3 `constellize-feature:verify` — one gate, three reviews, and one thing nobody else does

This is the section the builder check changed most, and the reason is worth stating plainly: **the
marketplace's `Gate N` labels are a different taxonomy from the course's four gates, and the first
draft of this design claimed they lined up. They do not** (§13, finding A). What follows is built
on what the skills actually contain.

`verify` reads an IMPLEMENTED spec and leaves it VERIFIED, or leaves it IMPLEMENTED with the
failures named.

**One real gate.** `constellize-craft:test-coverage` is the only skill in the marketplace that
asserts a verdict. `verify` always delegates to it, and its PASS/FAIL is a gate in the strict sense:
a FAIL blocks VERIFIED, mechanically, with the numbers recorded (§6.6).

**Three reviews, not gates.** The marketplace's Gate 2–4 skills build things; they do not judge
them. So `verify` does not pretend to run them as gates. It runs the ones whose subject the feature
actually touched, takes their findings, and records them as findings:

| Review | When | Delegates to |
|---|---|---|
| Maintainability | always | `constellize-craft:architectural-consistency`, `:dependency-hygiene` |
| Operational surface | only when the feature introduced a dependency, a service call or a config value | `constellize-craft:application-health-validation`, `:infrastructure-health-checks`, `:operational-monitoring`, `:actionable-health-reporting` |
| Deployment surface | same condition | `constellize-deliver:externalize-config`, `:environment-independence`, and `:reliable-containers` / `:rollback-capability` only if the feature changed packaging or has a rollback story |

Steve's refinement, 2026-11-03 — always-on for test integrity and maintainability, conditional for
the operational and deployment surfaces — is preserved exactly; only the word "gate" changed for
three of the four. A flat "never the conditional ones" would skip exactly the features that change
the deployment surface.

**`constellize-craft:documentation-completeness` and `:team-comprehension` come out.** Both are
project-scope: whether a *codebase* is comprehensible to a team is not a property of one feature,
and running them per feature would produce the same findings every time.

**One thing the marketplace does not do at all, so `verify` does it.** The course's Gate 2 was a
*defensive-programming* review — every external input validated, no bare `except:`, no swallowed
exceptions, errors with actionable messages, graceful degradation instead of a traceback. The
marketplace's Gate 2 skills are about databases, caches, probes and monitoring: same label,
different subject. Checked across all 74 skills, the nearest thing is
`constellize-craft:ai-changes`, whose subject is validating *AI-generated changes* — line-by-line
comparison against the original, silently omitted code, memory-bank cross-validation. It mentions
input validation in a checklist; it is not a defensive-programming review.

So **`verify` carries the defensive-programming review itself.** That is the single exception to
goal 2, it is deliberate, and it does not breach anti-goal 3 — there is no existing capability to
duplicate. Dropping it instead would quietly throw away the substance of one of the four things the
course actually checked. Adding a `constellize-craft` skill for it would edit a plugin the book
names and break "additive", so it is named as follow-on work in §12 and the review moves out of
`verify` when that lands.

**No Python anywhere.** `verify` consumes coverage rather than producing it (Steve, 2026-11-03), so
the course's `uv run pytest --cov -v` goes; `uv sync && uv run crew` becomes the install-and-run
command the project declares; `uv run ruff check .` becomes the lint command the project declares.
Gates 5 (pre-commit / pre-merge / pre-deployment) and 6 (quality metrics, feedback loops,
continuous learning) are repository and team process rather than properties of one feature, and
`verify` does not touch them.

### 6.4 The harness route, and why nothing is lost

`constellize-harness:plan` and `:orchestrate` both carry an "Add a new feature" route today:

```
gap-analysis → implementation-sketch → code-generation-plan → unit-tests → integration-tests → memory:update
```

All six appear in §6.1–6.3. The three skills are a strict superset — they add the spec, the
adversarial passes, the reviews, the coverage gate and the status. So the route becomes:

```
constellize-feature:specify → :implement → :verify
```

in both skills, and the six-step list is deleted rather than kept beside it. Keeping both would be
the "two paths, different answers" anti-goal.

### 6.5 What "delegate to an agent" means, and the trap in it

**An agent produces the questions. The skill asks them.** A marketplace agent is a Claude Code
subagent: it runs, it reports back to whatever invoked it, and it has no channel to the human at
all. So an adversarial interview cannot be handed to `requirements-analysts` wholesale — a
subagent asked to interview the user will, at best, answer its own questions and hand back a
transcript of a conversation that never happened.

The split is therefore fixed, and it is not negotiable for the builder:

- The **agent** is invoked once per pass, with the context and the draft, and returns *questions
  and critique* — specific to this feature, not canned.
- The **skill** puts each question to the human, one per turn, waits, refuses vague answers,
  summarises, and decides whether the answer changes the spec.

This is what keeps Steve's reason for having these skills intact — *"the interview IS the value"* —
and it is the single easiest thing to get wrong while believing the design was followed. A build
that satisfies every other criterion and runs the interview inside a subagent has failed anti-goal
3 and should be rejected. It is also what the course itself does: its phases 7–8 say "Generate
questions… Ask each question to the user ONE AT A TIME."

One consequence to watch: `requirements-analysts` declares `maxTurns: 15` and `disallowedTools:
Write, Edit, Bash`. Under this split neither is a problem — the agent does one analysis pass and
never writes — but a builder who tries to push the whole interview into the agent will hit both and
may be tempted to raise the limit instead of correcting the shape.

### 6.6 Mechanics: how a delegating skill delegates, where artifacts go, and what makes a status honest

Three mechanisms, settled here because the first draft said "delegates to" sixteen times without
saying how.

**(a) In-session invocation, with advisory fallback.** The three declare the tool set they need —
skill invocation and subagent invocation — in `allowed-tools`, and call their phases in-session.
They are the first marketplace skills to do so, and that is a deliberate break with
`constellize-harness:execute`'s advisory-only precedent, for two reasons: §6.5 *requires* an agent's
output inside the session, which advisory cannot express at all (an agent is not a slash command);
and `execute`'s own `spawn` mode is marked "Phase 2 — not yet implemented", so advisory is a stopgap
there rather than a principle.

**When a tool or a target is unavailable, the skill falls back to advisory**: print the command,
wait, then verify what the step should have produced — exactly `execute`'s flow. One mechanism
covers three problems: harness tool-name drift (the subagent tool has been renamed before, and
pinning a name in generated frontmatter couples the marketplace to a harness version), a user who
installed `constellize-feature` without its siblings, and a user who simply prefers to drive it
step by step. The fallback also means the status file has to be resumable, which it is by
construction.

The exact tool names are the builder's (§10). **The requirement is that a missing tool or a missing
sibling plugin degrades to advisory with a message naming what is missing, and never fails
silently.**

**(b) The feature workflow does not write into `llm/construction/`.** The delegated design skills
each write to one fixed project-level path, and `tier1.ts` reads those same files to compute
project progress. Letting a feature-scoped run land there would overwrite the project's
`gap-analysis.md` with one feature's gaps, make two features clobber each other, and corrupt the
assessor's view of the project.

So: **the spec directory is the workflow's only output.** When a phase delegates to a design skill,
its result is captured into `llm/features/<name>/` — the spec's own Design Approach and Technical
Notes sections, or a sibling file in that directory — and `llm/construction/` is left exactly as it
was. Two features can be specified and verified side by side because their artifacts never share a
path. (Two features being *implemented* at once in one working tree is still two people editing the
same source files, which is git's problem, not this design's.)

The friction is real and worth naming: those skills' own text says "outputs to
`llm/construction/…`", so invoking them in capture mode is asking them to do something their prose
does not describe, and the prerequisites some of them read — `constellation-map.md`,
`scope-lock.md` — will not exist on a project that has only ever run the feature workflow. The three
must therefore supply the feature-scoped context inline and must not require those files or scaffold
them. **Giving the design skills an output-path argument is the structural fix and it is named as
follow-on work in §12**; it is out of scope here because editing `constellize-design` breaks
"additive".

**(c) A VERIFIED status carries its evidence, and the assessor checks it.** `verify` writes a
gate-results block into the spec recording, for the coverage gate: the threshold in force, the
measured numbers, the command or report it read them from, and when. For each review it ran: the
skill invoked and the findings. The assessor (decision 12) parses it and reports a feature as
`VERIFIED` only when the status says VERIFIED **and** the block names a coverage result; otherwise
it reports `VERIFIED (unsubstantiated)`.

This is the whole defence, and it is deliberately modest. It does not stop a determined fabrication.
It stops the failure that actually happened: the live course's `verify` says, in capitals, "NEVER
mark VERIFIED if any gate failed" and "100% means 100%", and the course shipped 12–22% coverage with
every spec VERIFIED. Prose had already failed. A status that must point at a number, checked by
something that is not the skill that wrote it, is the cheapest thing that would have caught it — and
it costs only extra fields in an assessor change already in scope.

---

## 7. The four scope items, resolved

### 7.1 2.0's marketplace name: no change

**`main` keeps `name: constellize-plugins-official`. There is no 2.0-specific marketplace name.**

Decision 12 (2026-10-28) already set this; this project confirms it rather than reopening it, and
records the reason, which was not written down before: **a marketplace's own `name` has no
documented migration path.** `renames` in `marketplace.json` migrates plugin names. Nothing
migrates the marketplace name, and a user who has added `constellize-plugins-official` would, on a
rename, be holding a registration for a name the repository no longer publishes. The upside of
symmetric `-v1`/`-v2` naming does not pay for an undocumented migration of every existing user.

So the two names mean what they already mean: `constellize-plugins-v1` is the frozen line,
`constellize-plugins-official` is the live one. A future 3.0 gets no new name either.

**Unchanged by this**: both lines contain `constellize-memory` and friends, so a user may add both
marketplaces but cannot enable both copies of a plugin. That was found on 2026-10-28 and is still
true; it is a Claude Code property, not something 2.0 can fix.

### 7.2 The website: `/prompts/v2/` as a frozen-plus-live pair

**Mostly already done, and the memory bank is out of date about it.** Website commits `eba3473` and
`cd4cc70` (2026-10-29, on `main`, pushed) moved prompt text to
`public/prompts/<version>/<id>/prompt.txt`, and `PromptDetailPage.tsx:29` already fetches by
version. 73 directories exist under `public/prompts/v1/`. `Immediate Next Steps` item 3 describes
the state before project 1.

What is actually left, and what this project decides:

1. **A version directory is a complete snapshot of one line.** Forced by the generator: `version`
   is a whole-run parameter (§5). `main`'s generator run emits `/prompts/v2/` containing *every*
   prompt on the 2.0 line — the 73 carried forward plus the 3 new ones — and `v1`'s generator keeps
   emitting `/prompts/v1/`. The 73 near-duplicate text files are the price of a frozen archive, and
   it is the right price: the book's 66 deep links can then never be disturbed by 2.0 content.
2. **The version must be passed explicitly, not defaulted.** `check-drift.ts:188` calls
   `gen.generate(scratch)` with one argument, so the website target needs a version parameter
   threaded through. `main`'s `DEFAULT_PROMPT_VERSION` also flips to `v2`, so that no path — CI,
   guard, or a bare `npm run generate:website` — can silently write v1 content from the 2.0 line.
   Belt and braces, because the failure mode is overwriting the book's pages.
3. **The v2 run must not touch personas.** Personas are written to
   `public/personas/<category>/<subcategory>/` with **no version in the path**, so a second,
   `main`-based run rewrites the same 14 aggregate files the v1 line owns. If `main`'s persona
   content ever differs from `v1`'s, the two guard runs demand different bytes for the same files
   and **the guard can never be green**. So the v2 run is prompts-only and personas stay owned by
   the v1 line. Mechanism is the builder's; the constraint is not.
4. **`/prompts/v1/` is a frozen archive; `/prompts/v2/` is the live library.** The index lists one
   line, not both. So `PromptsIndexPage.tsx:47`, which hardcodes `/prompts/v1/${prompt.id}`, points
   at the live line through a single named constant, so the next line costs one edit.
5. **The website records two source commits, and the guard runs once per line.** One stamp cannot
   express "v1 files came from the `v1` branch, v2 files came from `main`", and dropping v1 from
   the guard would give back coverage project 1 bought. **A note in a doc will not do it**: unlike
   the marketplace target, the website target has no `EXTRA`/`UNOWNED` walk —
   `check-drift.ts:198-203` adds only a `FORBIDDEN` check on `src/`, and the comparison loop at
   `:204` iterates the generated list, so a file the generator does not emit is never examined. A
   `main`-only run that emits just `/prompts/v2/` would leave all 73 v1 files outside the guard
   entirely, where a hand edit passes CI. The second run is the mechanism, not a formality.
   - **Accepted cost**: the v1-line run executes `check-drift.ts` *as of `0d97085`*, the pre-1.5
     guard, because the guard that runs is the one in the checked-out commit and acceptance 9
     forbids moving `v1` forward. That is tolerable — it is the guard that produced those files,
     byte-comparison is byte-comparison, and the hardening it lacks (`EXTRA`, `UNOWNED`) never
     applied to the website target in either version. Stated so it is not mistaken for an oversight.
6. **The three new prompts are added to `prompts-manifest.json` by hand**, which is where the
   index's titles, previews and categories live. The manifest already carries a `version` field per
   prompt. Generating it stays its own piece of work, as project 1 recommended. **It is outside the
   drift guard permanently and by design** — it lives in `src/`, which the website guard reports as
   `FORBIDDEN` for anything the generator writes — so it is covered by the website's own tests
   (`src/test/promptsIndex.test.tsx`, added in project 1), not by byte comparison.

**The real counts, since the first draft got them wrong** (§13, finding B): the generator emits
`prompt.txt` files and 14 persona aggregates, not pages — 73 + 14 = **87**, which is exactly the
figure project 1 recorded. The index renders **71** cards, not 73: the manifest's `totalPrompts` is
71 and it correctly omits `generate-prompt` and
`ch1-system-prompt-for-requirements-engineering-analysi`, both of which do have directories under
`public/prompts/v1/`. After 2.0 the v2 line adds 76 `prompt.txt` files and the index renders 74.

**The alternative, recorded because it is cheap and was rejected:** author the three skills in
`content/literal/` the way 1.5 decision 11 authors the harness's five, or set
`outputs.website.include: false`. Either publishes nothing and makes every item above unnecessary.
Rejected because 1.5 decision 4 is that new material publishes to `/prompts/v2/`, because the
prompt library is where a reader finds a skill, and because literal authoring exists for files the
content emitter *cannot* produce — not as a way to dodge the routing work. 1.5 §8b deferred the
website here on the grounds that this project owns both the material and the routing it needs.

**This is the most expensive call in the project and the cheapest one to overrule.** Publishing
costs roughly 76 new committed files, a second source stamp, a guard change, a website CI change
and the index constant; not publishing costs one line of frontmatter on each of the three prompts
and leaves §7.2 entirely out of 2.0. Nothing else in this design depends on it — the three skills,
the harness routing, the reviews and the assessor are all unaffected either way. If the website work
should wait, say so and items 1–6 come out as a unit.

### 7.3 The unpinned install command in `book/appC.md:11`: make `main` safe, do not redirect

**`main` stays the 2.0 line and the default branch, and 2.0 is constrained to keep every statement
in the printed appendix true.** Concretely, for as long as the book is in print:

- No skill named in `appC.md`'s table is removed or renamed.
- No plugin named in that table is removed or renamed.
- The Harness plugin keeps exactly its five skills (which is decision 1).
- No default is tightened past what the book prints — which is what §7.5 settles for coverage.
- **No skill outside `constellize-feature` has its text edited** (non-goal 3), which is what keeps
  the word "additive" honest.

2.0 as scoped is additive: one plugin, three skills, a routing change inside two existing harness
skills, a parameter with the printed default, and an assessor change. A print reader who types the
unpinned command gets a superset of what the appendix describes, and every sentence in it still
holds. The appendix becomes *incomplete* — it does not list `constellize-feature` — and that is
acceptable for a reference card to the line the book was written against.

**Generated surfaces that count plugins and skills are in scope.** `README.md` hardcodes "**74
Skills** across 6 plugins" and a per-plugin table; the infographic lists skill chips under six
plugin sections. Both are generated, drift-guarded files, so updating them is mechanical — but they
must be updated, and the **v2 reference-card PDF must be rebuilt** (`npm run build:card --line v2`)
because the infographic is its source. **The v1 card must not be rebuilt.** The PDFs are not
generated output and the guard does not cover them, so this is a release-time step in
`docs/releasing-1x.md`, not something CI will catch.

**The memory bank's claim that nothing can be done is false, and the escape hatch is worth
recording.** `activeContext.md` says *"No repository change can pin a reader who types what the
book says."* It can: `/plugin marketplace add owner/repo` with no ref resolves to the repository's
**default branch**, which is a GitHub setting. Making `v1` the default branch would land every
print reader on the pinned line with no manuscript change at all.

It is not recommended, for three reasons: it inverts every git convention in three repositories
whose CI, `GENERATED_FROM` plumbing and 1.5 generation story all target `main`; it silently moves
*existing* unpinned users backwards; and it would make the "latest" reference card and the
marketplace README's own quick start resolve to v1, so those would need rewriting anyway. But it is
the right lever if 2.0 ever has to break the appendix, and the condition is worth stating: **if a
2.0 change would make an appC statement false, flip the default branch rather than accept the
drift, and do it before the change ships.** The flip is cheapest now, while the two lines still
differ by four files.

**Published install commands, as they stand** (verified 2026-11-03):

| Place | Command | Resolves to |
|---|---|---|
| `book/appC.md:11` (print) | unpinned | default branch |
| `website/src/pages/resources/MarketplacePage.tsx:268` | `#v1` | the frozen line |
| `marketplace/README.md:16` (generated) | unpinned, with a note at `:20` to add `#v1` | default branch |
| infographic footer `:497` (generated) | unpinned | default branch |
| reference card, v1 PDF | `#v1` | the frozen line |
| reference card, v2 PDF | unpinned | default branch |

### 7.4 What else changes in 2.0: nothing

**2.0 is the feature workflow plus the plumbing the feature workflow forces, and nothing else.**
`activeContext.md` left this open. Closing it narrow, with the reasons:

| Candidate | Where it goes | Why |
|---|---|---|
| The 100% coverage gate | **in**, as a parameter | §7.5. It is the feature workflow's own setting |
| One memory-bank layout | **already answered** 2026-11-03: `memory-bank`, hyphenated. The course's `llm/memory_bank/` is converted on the way in | — |
| The five course-night rewrites | **project 4** | Project 4 replaces crew with Copernicus and rebuilds the course on marketplace skills (decisions 1, 2 and 10). Rewriting crew's nights here is work thrown away twice over: once when crew goes, once when the modules are rebuilt around Copernicus. The 12 curriculum files that name the three commands (5 module files plus `course/README.md`, both `slides.html`, `instructor-cheatsheet.html`, `INSTRUCTORS-GUIDE.md`, `night-2/5-behind-the-scenes.md`, `night-2/8-wrap-up.md`) are project 4's inventory, recorded here so project 4 does not have to find them again |
| `establish`: 97 lines versus 1,052 | **its own work** | Never decided, and it is a content question about an existing skill, not about the feature workflow |
| Harness defects (assessor paths, uncomputed dimensions, missing tiers) and harness tests | **its own work** | 1.5 decision 6. One scoped exception: decision 12 |
| A generated `prompts-manifest.json` | **its own work** | Project 1's recommendation stands |
| Verdict sections for the 15 Gate 2–4 skills | **its own work** (§12) | It would edit `constellize-craft` and `constellize-deliver`, bump two plugin versions and break "additive" |
| An output-path argument for the design skills | **its own work** (§12) | Same reason, for `constellize-design` |
| A defensive-programming skill in `constellize-craft` | **its own work** (§12) | Same reason. Until then `verify` carries that review (§6.3) |
| `constellize-harness:execute`'s lack of state | **in**, as a consequence | Goal 5 gives the assessor feature status and evidence; `execute` and `orchestrate` should use it rather than re-deriving progress |

### 7.5 Coverage: the book's number is the default, and `test-coverage` is not edited

Recorded on 2026-11-03 as *proposed, not confirmed*. Confirmed as designed:

- **Default**: ≥80% branch coverage overall, 100% of critical business logic, 100% of error paths,
  100% of constellation integration points. This is exactly what `constellize-craft:test-coverage`
  already says, and `test-coverage/SKILL.md:14` is the sentence `book/ch4.md:50` quotes verbatim.
- **Opt-in**: a project may declare a stricter threshold, including 100% everywhere.
- **`test-coverage` is not edited.** It hardcodes 80%/100% in about a dozen places, and editing it
  would break non-goal 3 and diverge the v2 text from the sentence the book quotes. So: with no
  declaration, `verify` delegates to it unchanged and takes its verdict. With a declaration,
  `verify` passes the threshold as an argument and judges the measured numbers against the declared
  one itself.
- **That judgement is `verify`'s to own**, not a reimplementation — see the sharpened anti-goal 3.
  `test-coverage` supplies the measurement; `verify` decides whether this feature passes. Without
  that split there is no way to honour a stricter threshold at all.
- **Where it is declared**: the builder's call (§10), but it is read, not hardcoded, and the three
  skills never carry a number of their own.

The decisive reason for the default is anti-goal 1: the book is printed and says 80%. A 2.0 default
of 100% would make a printed sentence false for anyone who installs from the unpinned command. The
course's 100% survives as the setting Copernicus turns on.

---

## 8. Acceptance

1. **The factory reproduces the marketplace byte-for-byte**, as it does today, with the new files
   included: **104 → 108** (three `skills/<name>/SKILL.md` plus
   `plugins/constellize-feature/.claude-plugin/plugin.json`; `marketplace.json`, `README.md`, the
   infographic and the card HTML change but are existing files). **The guard needs no change** —
   `GENERATED_OWNED` already starts with `'plugins'` and `findExtraFiles` walks recursively, so a
   new plugin directory is owned on arrival, and `ROOT_ALLOWED` is untouched.
2. **`npm run check:drift -- --target website` is clean for both lines**, each against its own
   recorded commit, with no file the generator emits left uncompared — and with the persona
   conflict in §7.2 item 3 demonstrably avoided, by showing a green run after deliberately changing
   a persona source file on `main`.
3. **The three skills run end-to-end on a non-Python project.** The proof is a feature taken from
   `specify` to VERIFIED in a TypeScript or Go repository with no skill edits. This is the test for
   the Python-shaped anti-goal, and no amount of reading the text substitutes for it.
4. **The same run works with the siblings uninstalled**, falling back to advisory with a message
   naming what is missing (§6.6a). This is the only test of the fallback that means anything.
5. **`verify` cannot write VERIFIED without a recorded coverage result.** Demonstrated two ways: a
   failing coverage gate leaves the status IMPLEMENTED with the failure named; and a spec whose
   status is hand-edited to VERIFIED with no gate-results block is reported by the assessor as
   `VERIFIED (unsubstantiated)`.
6. **A stricter declared threshold is enforced.** A project declaring 100% fails verification at
   85%, where the default would have passed it.
7. **`llm/construction/` is byte-identical before and after a full feature run** (§6.6b), and two
   features can be specified and verified without either one's artifacts appearing in the other's
   directory.
8. **`constellize-harness:assess` reports each feature's status**, demonstrated against a directory
   containing one feature at each of the three statuses, one unsubstantiated VERIFIED, and one
   malformed.
9. **`constellize-harness:plan` and `:orchestrate` route "Add a new feature" to the three**, and
   the six-step list no longer appears in either file.
10. **The book's 66 `/prompts/v1/<id>` links still resolve to byte-identical text.** Checked by
    diffing `public/prompts/v1/` against its pre-change state.
11. **The v2 reference card is rebuilt and the v1 card is not**, verified by comparing both PDFs'
    content against their pre-change state.
12. **The factory's test suite covers the assessor's feature parsing and evidence check**
    (decision 12).
13. **`v1` is untouched in all three repositories**, confirmed by comparing branch tips before and
    after: prompt-factory `69dffee`, marketplace `8f470b2`.

---

## 9. Decided

Steve's decisions are marked; the rest are the author's calls, made because the brainstorming
questions were declined. Decisions 16–25 were added after the builder check.

| # | Decision | Whose |
|---|---|---|
| 1 | **A new plugin, `constellize-feature`, holding `specify`, `implement`, `verify`.** Not `constellize-harness`: that would make `book/ch9.md:324`, `book/appA.md:48` and `book/appC.md:33` false. Not split across `design` and `craft`: the state needs one owner | author, on book evidence |
| 2 | Bring the three in as **delegating** skills | Steve, 2026-11-03 |
| 3 | **The harness delegates down to them**, and the six-step route is deleted, not kept beside them | Steve, 2026-11-03 |
| 4 | **Coverage is consumed, not produced** | Steve, 2026-11-03 |
| 5 | **Coverage is a parameter, defaulting to the book's number**, stricter opt-in | Steve proposed 2026-11-03; confirmed here |
| 6 | **Always-on: test integrity and maintainability. Conditional on the feature touching the surface: operational and deployment. Never: Gates 5 and 6** | Steve (which are always-on vs conditional), 2026-11-03; the rest author |
| 7 | **The adversarial passes delegate to agents.** The agent generates the questions; the skill asks the human — a subagent has no channel to the user, so an interview run inside one is a fiction (§6.5) | author |
| 8 | **The feature-spec template is not delegated.** `constellize-design:specification` is a product spec | author |
| 9 | **No new marketplace name**; a marketplace rename has no documented migration | author, confirming decision 12 |
| 10 | **A website prompt version directory is a complete snapshot of one line.** `/prompts/v1/` frozen, `/prompts/v2/` live; two source stamps, guard runs per line | author |
| 11 | **The three are authored as content prompts and publish to `/prompts/v2/`**, not as `content/literal/` files. The most expensive call here and the cheapest to overrule (§7.2) | author |
| 12 | **The assessor learns to read feature status and check its evidence**, and those functions get tests — the only harness work in this project | author |
| 13 | **`main` stays the default branch; 2.0 keeps every printed appendix statement true.** The default-branch flip is the recorded escape hatch | author |
| 14 | **The course-night rewrites move to project 4** | author |
| 15 | **Nothing else enters 2.0** (§7.4) | author |
| 16 | **In-session invocation via declared `allowed-tools`, with advisory fallback** when a tool or a sibling plugin is missing (§6.6a). The three are the first marketplace skills to invoke anything | author |
| 17 | **One gate, three reviews.** `test-coverage` is the only skill in the marketplace that asserts a verdict, so it is the only strict gate; the Gate 2–4 skills are constructive and their output is recorded as findings (§6.3) | author |
| 18 | **`verify` owns the verdict.** Anti-goal 3 forbids duplicating a capability, not owning a judgement. Without this a declared threshold cannot be honoured | author |
| 19 | **`verify` carries the defensive-programming review itself**, the single exception to goal 2, because the marketplace has no skill on that subject — `ai-changes` is about AI-generated changes, not defensive programming (§6.3) | author |
| 20 | **`documentation-completeness` and `team-comprehension` are dropped from verification** as project-scope, not feature-scope | author |
| 21 | **No skill outside `constellize-feature` is edited** (non-goal 3), which is what makes "additive" true and what defers three jobs to §12 | author |
| 22 | **The feature workflow writes only into `llm/features/<name>/` and never into `llm/construction/`** (§6.6b) | author |
| 23 | **State lives in `llm/features/<name>/spec.md`, a directory per feature**, not the course's single file. Both existing descriptions already assume directories — the generated `README.md:65` documents `features/   # per-feature documentation subsets`, and `tier1.ts` counts only entries where `statSync(full).isDirectory()` — so this is the smaller assessor change and the README needs no edit | author |
| 24 | **A VERIFIED status carries its evidence and the assessor cross-checks it** (§6.6c). Prose already failed in the live course | author |
| 25 | **The v2 generator run is prompts-only**; personas are unversioned and stay owned by the v1 line, or the guard can never be green (§7.2 item 3) | author |

---

## 10. Left to the builder

- **The exact tool names in `allowed-tools`** for skill and subagent invocation, since they are
  harness-version-dependent. The *requirement* is decision 16's fallback behaviour, not a name.
- **How a project declares its coverage threshold, its test command, its lint command and its
  install-and-run command.** All four must be read, not hardcoded, and must work on a project with
  no Constellize scaffolding yet. The memory bank and `llm/` are both plausible homes.
- **How `verify` decides a feature "touched the operational or deployment surface"** (decision 6's
  condition). The spec's own Technical Notes and Dependencies sections are the obvious input;
  reading the diff is another.
- **The gate-results block's format** — frontmatter, a table, or a sibling file in the feature
  directory. The constraint is that the assessor parses it without a dependency (§5) and that
  decision 24's cross-check is mechanical.
- **Whether the status itself is prose (`**Status:** SPECIFIED`) or frontmatter.** Frontmatter is
  easier to parse; either way the assessor and all three skills must agree.
- **The second website source stamp**: its name, whether the guard takes two `--against` paths or
  runs twice, and how `drift.yml` checks out two commits.
- **The three skills' `id`s, categories and chapter placement in `content/prompts/`**, which
  determine their website URLs and their position in the index. Pick against the traps in §14.
- **The order of the work.** The marketplace side and the website side are independent and each is
  independently verifiable. The assessor change should land before the harness routing that depends
  on it.
- **How the three behave when invoked out of order** — `implement` on a missing or VERIFIED spec,
  `verify` on a SPECIFIED one. The course versions stop and tell the user; keep that, and decide
  whether `specify` on an existing spec revises it or refuses.

---

## 11. Recorded claims that did not survive checking

Project 1.5's first key learning was that a recorded rationale can be false and must be checked
before it is relied on. Six were.

**11.1 "Project 2 owns the website prompt-version split; today `/prompts/v1/<id>` loads
`/prompts/<id>/prompt.txt`."** (`activeContext.md`, Immediate Next Steps 3.) **Already done.**
Website `eba3473` + `cd4cc70`, 2026-10-29, on `main` and pushed; `public/prompts/v1/` holds 73
directories; `PromptDetailPage.tsx:29` fetches by version. What remains is §7.2.

**11.2 "No repository change can pin a reader who types what the book says."** **False.** An
unpinned `/plugin marketplace add owner/repo` resolves to the repository's default branch, a GitHub
setting. Not recommended, and why, in §7.3 — but the option exists.

**11.3 "'Adversarial' appears nowhere in the marketplace."** **False, and it changed the design.**
`plugins/constellize-design/agents/requirements-analysts.md:204` is a full `ADVERSARIAL ANALYSIS
MODE`, and `constellize-craft/agents/qa-engineers.md` carries the quality voice. The adversarial
passes are delegated to agents rather than written into the three skills (decision 7).

**11.4 "The four gates exist as 16 craft/deliver skills labelled Gate 1–Gate 4."** **There are six
gates across 23 skills** — 5/5/5/5/4/3, with `constellize-craft:ai-assistance` labelled for Gates
1–5, which is why the totals overlap. More importantly, the labels are a *different taxonomy* from
the course's four gates; §6.3 and §13 finding A.

**11.5 1.5's evidence table, one row.** It records that the content model *"supports
prompt-without-skill but not skill-without-page"*. `generate-website.ts:39` skips the page when
`outputs.website.include === false`, so skill-without-page works. It does not change this design,
because decision 11 chooses to publish anyway, but it means the no-publish alternative in §7.2 is
genuinely available.

**11.6 "Website 87 files" was never explained, and the explanation matters.** 87 = 73 `prompt.txt`
+ 14 persona aggregates. Knowing that is what exposes decision 25: the personas are in that count
and they are not versioned.

Also: `book/appA.md`'s "Five skills" line is at **48**, not 46 as the memory bank says, and the
matching `ch9.md` line is **324**, not 321.

Two claims in the memory bank's "feature workflow, reshaped" paragraph did hold.
`constellize-design:specification` really is 72 lines with no interview, and the harness's "Add a
new feature" route really is those six steps in both `plan` and `orchestrate`.

---

## 12. Follow-on work this design deliberately defers

Named here so it is not rediscovered. Each one would edit a plugin the book names, so each breaks
"additive" and belongs after 2.0, not in it.

1. **Verdict sections for the 15 Gate 2–4 skills.** Until this lands, the four gates are one gate
   and three reviews (decision 17). This is the work that would make "four quality gates" literally
   true in the marketplace, and it bumps `constellize-craft` and `constellize-deliver`.
2. **An output-path argument for `constellize-design`'s artifact skills.** Until this lands, the
   feature workflow invokes them in capture mode, which their own text does not describe
   (§6.6b). This is also the structural fix for the assessor-path defect that §7.4 defers.
3. **A defensive-programming skill in `constellize-craft`** — input validation, no silent failures,
   actionable errors, graceful degradation. Until this lands, `verify` carries that review itself
   (decision 19), which is the design's only exception to goal 2.
4. **A generated `prompts-manifest.json`**, with `title`, `preview` and display `category` added to
   `content/prompts` frontmatter — project 1's recommendation, unchanged.

---

## 13. What the builder check changed

A fresh engineer planned from the draft with read access to the trees and returned ten questions and
four corrections. Every one is settled above; none went back to Steve, because he declined the
interview. The four that changed the design rather than just sharpening it:

**Finding A — the author's own error, and the biggest one.** The draft said "the course's four *are*
Gates 1–4. They line up." They do not. Course Gate 2 is a defensive-programming review; marketplace
Gate 2 is four skills that build database probes, startup validation and operational monitoring.
Same label, different subject. Course Gate 3 was a clean install-and-run; marketplace Gate 3 adds
containers and rollback. Course Gate 4 was lint plus patterns; marketplace Gate 4 adds
documentation and team comprehension. §6.3 was rewritten from the skills' actual contents, which is
where decisions 17, 19 and 20 come from. **This is exactly the failure mode 1.5's learning warns
about, committed by the author of the document that quotes it** — the labels were taken at face
value instead of read.

**The verdict problem.** Thirteen of the sixteen delegated skills emit no pass/fail at all; only
`test-coverage` does. The draft's acceptance criterion "make a gate fail" was only demonstrable on
one gate. Decisions 17 and 18 and the sharpened anti-goal 3 are the answer.

**The delegation mechanism.** The draft said "delegates to" sixteen times and never said how,
while the marketplace's only precedent is advisory prose and no skill may invoke anything.
Decision 16 and §6.6a.

**The clobbering.** Feature-scoped `gap-analysis` would have overwritten the project's
`llm/construction/requirements/gap-analysis.md` — and that file is what the assessor reads for
project progress. Decision 22 and §6.6b.

Three further corrections of fact: `GENERATED_OWNED` already covers a new plugin directory (fixed
before the check returned); the index renders 71 cards, not 73, and the generator emits files rather
than pages (§7.2); and the generated `README.md:65` does publish a layout for `features/`, which the
draft's "exists and is unused" evidence row missed because the README writes it without the `llm/`
prefix (decision 23).

---

## 14. Two traps for whoever picks the prompt ids

- **`deriveShortSkillName` would rename one of the three.** `generate-marketplace.ts` strips verb
  prefixes including `implement-` and `validate-`, so a prompt id of `implement-feature` generates a
  skill named `feature` — `constellize-feature:feature`. `specify-` is not in the list, so
  `specify-feature` survives intact, which makes the asymmetry easy to miss. Pick ids against that
  list, or add `specialCases` entries.
- **`generate-book.ts` hardcodes v1 in every URL it emits** (`url="{SITE_BASE}/prompts/v1/${prompt.id}"`),
  and `PromptFrontmatter.chapter` is required. So if the three new prompts carry
  `outputs.book.include: true`, `npm run generate:book` will write dead `/prompts/v1/<new-id>` links
  into `book/generated/`. They should not be book outputs. Relatedly,
  `validate-full-chain.ts` has been stale since the versioning commit: its `getWebsitePromptIds()`
  lists directories directly under `public/prompts`, so it now reports the website as holding one
  prompt called `v1`. Worth fixing while nearby, though it is not part of this project.

---

## 15. Evidence

Everything asserted above was checked on 2026-11-03 against the working trees at prompt-factory
`main` = `8d75f6c`, marketplace `main` = `272e7be`, website `main` = `11a16f1`.

| Claim | How it was checked |
|---|---|
| The book says "five" driving skills in three places | `book/ch9.md:324`, `book/appA.md:48`, and the Harness row of the `appC.md:33` table, which names exactly `orchestrate`, `assess`, `plan`, `execute`, `init` |
| The book names no plugin count and no skill count | `grep` for "six plugins", "5 plugins", "N skills" across `book/*.md` — no hits |
| `book/appC.md:11` is unpinned | read directly |
| No skill can invoke a skill or an agent | `grep -rh 'allowed-tools' plugins/*/skills/*/SKILL.md \| sort \| uniq -c`: 58 × `Read, Glob, Grep, Write, Bash`, 12 × `Read, Glob, Grep, Bash`, 4 × `Read, Glob, Grep`. No `Task`, `Agent` or `Skill` in any |
| The only delegation precedent is advisory | `constellize-harness/skills/execute/SKILL.md:21-26` presents the step and waits ("Press enter when done, or 's' to skip"), then verifies the expected artifact; spawn mode is declared at `:15` and `:54` as "Phase 2 — not yet implemented" |
| `allowed-tools` passes through the generator verbatim | `generate-marketplace.ts:136` emits `skill['allowed-tools'].join(', ')` |
| Only `test-coverage` asserts a verdict | `grep -c 'Gate Status\|FAIL the gate'`: `test-coverage` 8, and 0 for `architectural-consistency`, `application-health-validation`, `documentation-completeness`, `team-comprehension`, `dependency-hygiene`, `infrastructure-health-checks`, `externalize-config`, `environment-independence`, `reliable-containers`, `rollback-capability` |
| The Gate 2–4 skills are constructive | all carry `allowed-tools: Read, Glob, Grep, Write, Bash`; their descriptions are "Implement…", "Build…", "Achieve…", "Enable…" |
| Course Gate 2 is defensive programming | `curriculum/skills/course:feature:verify/SKILL.md` Gate 2: "Every external input is validated", "no bare `except:`", "Graceful degradation for bad input" |
| Nothing in the marketplace covers that subject | case-insensitive `grep` for input validation / silent failure across all 74 `SKILL.md` hits only `constellize-craft:ai-changes`, `:ai-assistance` and two memory skills; `ai-changes`'s own subject line is "Validate AI-generated changes… line-by-line comparison… silently omitted code" |
| There are six gates, not four | `grep -rl 'Gate [1-6]'`: 23 distinct skills, 5/5/5/5/4/3 by gate; `ai-assistance` matches Gates 1–5 |
| The design skills write to fixed project paths | `gap-analysis/SKILL.md:45` "outputs to `llm/construction/requirements/gap-analysis.md`"; `implementation-sketch/SKILL.md:48-52` reads `gap-analysis.md`, `constellation-map.md`, `scope-lock.md` and outputs to `llm/construction/design/implementation-sketches.md` |
| The assessor reads those same files | `scripts/tier1.ts` computes construction status from `llm/construction/` artifacts |
| `test-coverage` hardcodes the numbers and is what the book quotes | `SKILL.md:24-27`, `:197-199` "Accept <80% … (FAIL the gate)"; `SKILL.md:14` is the sentence quoted at `book/ch4.md:50` |
| A new plugin needs no guard change | `check-drift.ts:90`, `GENERATED_OWNED` begins `'plugins'`; `findExtraFiles` walks recursively |
| The website target has no `EXTRA` walk | `check-drift.ts:198-203` adds only `FORBIDDEN` on `src/`; the loop at `:204` iterates the generated list |
| `check-drift` passes no version | `check-drift.ts:188` is `gen.generate(scratch)` |
| The website is generated from the `v1` line | website `GENERATED_FROM` = `0d97085`; `git branch --contains` in prompt-factory lists `v1` and `origin/v1`, not `main` |
| The website version is a whole-run parameter | `generate-website.ts:109`; the per-prompt `version:` frontmatter is never read there |
| Both lines' generators already support it | the same signature at `git show v1:build/generate-website.ts:109` |
| Personas are not versioned | `generate-website.ts:86`, `path.join(websiteDir, 'public/personas', category, subcategory)` — no version segment |
| 87 = 73 + 14 | `ls public/prompts/v1 \| wc -l` = 73; `find public/personas -name 'Aggregate_Expert_Synthesis.md' \| wc -l` = 14 |
| The index renders 71, not 73 | `prompts-manifest.json` `totalPrompts` = 71 and 71 actual entries; the two v1 directories it omits are `generate-prompt` and `ch1-system-prompt-for-requirements-engineering-analysi` |
| The generated README publishes a `features/` layout and hardcodes counts | `content/literal/marketplace-root/README.md:65` `features/   # per-feature documentation subsets`; `:8` "**74 Skills** across 6 plugins" |
| The assessor counts only directories, and has no status field | `tier1.ts:133-152` pushes an entry only when `statSync(full).isDirectory()`; `types.ts:13` `FeaturesState` is `{count, entries}` |
| `llm/features/` exists and nothing writes to it | `constellize-harness:init` creates it; `grep -rl 'llm/features'` over `plugins/` hits only `init` and `tier1.ts` |
| `constellize-design:specification` is a product spec | 72 lines, `{{product_name}}`, FR-/NFR- numbering, no interview |
| `deriveShortSkillName` strips `implement-` | `generate-marketplace.ts:104-110`, `verbPrefixes` includes `'implement-'` and `'validate-'`; `'specify-'` is absent |
| `generate-book.ts` hardcodes v1 | `:63`, `url="{SITE_BASE}/prompts/v1/${prompt.id}"` |
| The three commands appear in 12 curriculum files | `grep -rln 'feature:specify\|feature:implement\|feature:verify'` over `curriculum/course/` and `curriculum/*.md` |
| The two marketplace names already differ by branch | `git show main:.claude-plugin/marketplace.json` → `constellize-plugins-official`; `git show v1:…` → `constellize-plugins-v1` |
| Published install commands | the table in §7.3, each read at the line given |

---

## 16. What this unblocks

Project 4 (Copernicus) was told to use marketplace prompts and agents rather than the course's own
skills (decision 10, 2026-10-28), and the question left open was whether "use v2 prompts" meant
porting the course's chain in or building the course on what the marketplace already had. This
design answers it: the chain comes in, rewritten and delegating, so project 4 rebuilds its modules
on `constellize-feature:specify|implement|verify` and ships no `course:*` skills at all. The 12
curriculum files in §7.4 are its inventory.

Project 3 (delivery) is untouched by this.
