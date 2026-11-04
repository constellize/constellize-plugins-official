# Project 2: Marketplace 2.0 — the feature workflow

**Status**: **APPROVED by Steve, 2026-11-04** (revision 3). The next step is the plan, in
`marketplace/docs/plans/`; nothing is built before that plan is approved in its turn.
**Date**: 2026-11-03; revision 3 landed 2026-11-04. All tree checks were made on 2026-11-03 against
the commits named in §15, which is also what §5a's book baseline was measured at.
**Sequence**: project 1 (done) → 1.5 (done) → **2** → 4 (delivery) → 3 (Copernicus)

> Written without a brainstorming interview. Steve chose on 2026-11-03 to have the design written
> from the memory bank rather than answer questions first, so **every decision below is the
> author's call unless it is marked as Steve's**. The calls are collected in §9 so they can be
> checked quickly rather than hunted for.
>
> **Revision history, because two passes changed the design materially:**
> - **r1** — written from the memory bank.
> - **r2** — a fresh engineer read r1 as a builder and returned ten questions and four corrections.
>   All settled; §13.1. The largest was the author's own error about the gate taxonomy.
> - **r3** — Steve asked for changes in four places: drop the website work, reopen the plugin
>   placement, **make the four gates real**, and reopen the state layout. §13.2. The gates decision
>   cascaded: it removed a constraint r2 had invented, which in turn fixed the artifact-clobbering
>   properly and dissolved the design's only exception to its own delegation goal.
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

**And 2.0 makes the four quality gates real.** They have never been real: of the 17 skills carrying
a `Gate N` label, exactly one asserts a verdict. The rest build things. So the method's headline
promise — four gates every piece of generated code passes — has been a label, not a mechanism.
Fixing that is the second half of this project and the reason it reaches into `constellize-craft`
and `constellize-deliver`.

After this project, 2.0 is the marketplace on `main` with a feature workflow, four gates that can
actually fail, and a coverage threshold you can set. The website is untouched (§7.2).

---

## 2. Goals

1. **Three skills — `specify`, `implement`, `verify` — in a new `constellize-feature` plugin**,
   authored in `prompt-factory` like every other generated skill, driving
   `llm/features/<name>.md` through SPECIFIED → IMPLEMENTED → VERIFIED.
2. **Each skill delegates every phase that an existing skill or agent already performs.** The
   delegation map in §6 is normative: if a phase is not in that map, it is not in the skill. After
   r3 there are **no exceptions** — every phase has a home outside the three.
3. **The four quality gates become assertions.** Each of the 12 gate-checking skills in Gates 2–4 gains a verdict
   section in the shape `constellize-craft:test-coverage` already has, and the course's
   defensive-programming checks — which no marketplace skill covers — become a new
   `constellize-craft` skill. A gate can then fail, which is the precondition for goal 5.
4. **`constellize-harness:plan` and `:orchestrate` route "Add a new feature" to the three** instead
   of to their current six-step list, which the three contain in full (§6.4).
5. **A VERIFIED status is substantiated or the assessor says it is not.** `verify` records what each
   gate measured; `constellize-harness:assess` reports each feature's status and whether the
   evidence for it exists. This is the project's answer to the live course's central defect (§6.6c).
6. **The coverage threshold is a parameter with the book's number as its default**, so the printed
   book stays true and the course's 100% becomes an opt-in — without editing the sentence the book
   quotes (§7.5).
7. **The feature workflow writes only into its own artifact**, never into the project-level design
   files the assessor reads (§6.6b).
8. **Everything stays byte-guarded.** The marketplace drift guard covers the new and edited files,
   and `GENERATED_FROM` keeps its invariant.

## 3. Non-goals

- **The three course skills are not ported, they are rewritten.** The course versions hardcode
  Python (`uv run pytest --cov -v`, `uv sync && uv run crew`, `uv run ruff check .`), the
  underscore `llm/memory_bank/` layout, and `/constellize:feature:*` command names. None of that
  survives.
- **`v1` is not touched**, in any repository. Project 1.5 decision 1 stands.
- **Nothing in the `book` repository is written to — not the manuscript, and not
  `book/generated/`.** §5a sets out the one mechanism by which this project could touch the book,
  why nothing would catch it, and what stops it. §7.3 resolves the unpinned install command without
  a words change.
- **No website files are touched** (§7.2, reversed in r3). The `/prompts/v2/` work leaves 2.0
  entirely and moves to the generated-manifest piece of work, where it belongs.
- **No skill is removed or renamed, and no plugin is removed or renamed.** This is the constraint
  the printed appendix actually imposes, and it is what "additive" means here. **Editing a skill's
  body is allowed** — r2 wrongly forbade it, which cost a worse design (§13.2).
- **No course-night rewrites.** The memory bank deferred "the rewrite of the five course nights" to
  this brainstorm; it belongs to project 4 instead (§7.4).
- **No harness defect sweep, and no general harness-testing project.** Two scoped exceptions: the
  assessor functions this project changes get tests, and `plan`/`orchestrate` get their routing
  edit.
- **No decision on the 97-line versus 1,052-line `establish` skill.** Still open, still its own
  work.
- **Gates 5 and 6 are not touched.** Pre-commit/pre-merge/pre-deployment and the
  continuous-improvement skills are repository and team process, not properties of one feature.
- **No new marketplace name, and no second repository.** §7.1.

## 4. Anti-goals

This project has failed, even if it technically works, if any of these are true:

- **A statement in the printed book has become false.** Not "incomplete" — false. §5 and §7.3 set
  out what that forbids, and what it does not.
- **A `v1` reader's install, skills, or prompt pages changed in any way.**
- **A skill in the three duplicates a capability the marketplace already has.** If `specify` writes
  its own adversarial questions instead of calling `requirements-analysts`, the project has
  produced a fourth convention rather than removed one — the same failure 1.5 was about.
  **This forbids duplicating a capability. It does not forbid `verify` owning the aggregate
  judgement**, which is its own job and no existing skill's. The distinction was muddled in r1 and
  cost a wrong design; it is load-bearing.
- **A gate still cannot fail.** If the 12 skills come out of this with a verdict section that no
  caller reads, or with wording that always passes, goal 3 is cosmetic and goal 5 rests on nothing.
- **The workflow is Python-shaped.** A user on Go, TypeScript or Rust must be able to run all three
  skills with no edits.
- **A feature can be marked VERIFIED with nothing recorded to back it.** This is the exact defect
  the live course has — 12–22% coverage, every spec VERIFIED — and the course's own text already
  forbids it in capitals, which is precisely why prose is not an answer (§6.6c).
- **The harness and the three can both be invoked for the same job and give different answers.**
- **The feature workflow overwrites project-level design artifacts.**

---

## 5. Constraints

**The printed book is fixed, and three of its sentences bind this design.** `book/ch9.md:324` and
`book/appA.md:48` both say *five* skills exist to drive the rest, and `book/appC.md:33` lists the
Harness plugin's skills as exactly `orchestrate`, `assess`, `plan`, `execute`, `init`. Putting the
three new skills into `constellize-harness` would make all three places false. This is why the
three go in a plugin of their own (decision 1) — not taste, evidence.

**What the book does *not* constrain.** `appC.md`'s table lists plugin and skill *names*. It
reproduces no skill body, quotes no gate definition, and states no plugin or skill count (grepped:
no "six plugins", no "N skills"). So editing a skill's body leaves every printed sentence true;
only a rename, a removal, or a loosened printed number would not. r2 imposed "no skill outside
`constellize-feature` is edited" as if the book required it. It does not, and that invented
constraint is what forced r2's worse answers to the gates and to artifact clobbering (§13.2). The
one printed number that *is* binding is the coverage threshold at `book/ch4.md:50` (§7.5).

**`book/appC.md:11` prints an unpinned install command**, so a print reader lands on whatever the
repository's default branch serves. Steve decided on 2026-11-03 to leave the words alone at proof
stage. The design therefore has to make `main` safe for that reader rather than redirect them
(§7.3).

**No marketplace skill can invoke a skill or an agent today.** Across all 74 generated `SKILL.md`,
`allowed-tools` is only ever `Read, Glob, Grep`, `…, Bash`, or `…, Write, Bash`. The only
delegation that exists anywhere in the marketplace is **advisory prose**:
`constellize-harness:execute` presents `/<plugin>:<skill> <arguments>`, says "Press enter when done,
or 's' to skip", then checks that the expected artifact appeared. Its `spawn` mode is marked
"Phase 2 — not yet implemented". A design built on "delegates to" has to say what that means
mechanically, and §6.6a does.

**The content model passes `allowed-tools` through verbatim.** `generate-marketplace.ts:136` emits
whatever array the prompt's `skill['allowed-tools']` holds, so giving the three skills a different
tool set is frontmatter, not a generator change.

**Only one of the 19 gate-labelled skills asserts anything.** `constellize-craft:test-coverage` has
`**Gate Status:** ✅ PASS / ❌ FAIL` and "FAIL the gate if thresholds not met". The other 18 carry
their gate label only in their `description:` frontmatter; their bodies are *constructive*, with
`allowed-tools: Read, Glob, Grep, Write, Bash`, and they build health checks, containers, rollback
procedures and documentation. Goal 3 exists because of this.

**The marketplace's `Gate N` labels are a different taxonomy from the course's four gates.** Course
Gate 2 is a defensive-programming review — every external input validated, no bare `except:`, no
swallowed exceptions, graceful degradation. Marketplace Gate 2 is four skills about databases,
caches, probes and monitoring. Same label, different subject; and nothing across the 74 skills
covers the course's subject (the nearest, `constellize-craft:ai-changes`, is about validating
AI-generated changes). §6.3 reconciles the two rather than pretending they align, which r1 did.

**Every plugin whose files change needs a version bump, and CI enforces it.**
`.github/scripts/check-version-bump.sh` fails for any plugin with a change under
`plugins/<name>/**` other than its own `plugin.json` unless that `plugin.json`'s `version` differs
from the base. A new plugin with no `plugin.json` at base passes. So this project bumps
`constellize-craft`, `constellize-deliver`, `constellize-design` and `constellize-harness`, and
`constellize-feature` arrives new.

**The delegated design skills write to fixed project-level paths.** `gap-analysis` →
`llm/construction/requirements/gap-analysis.md`; `implementation-sketch` →
`llm/construction/design/implementation-sketches.md`, and it *reads* `gap-analysis.md`,
`constellation-map.md` and `scope-lock.md`; `constellation-map` →
`llm/construction/requirements/constellation-map.md`. Only `code-generation-plan` is per-target.
Those same files are what `tier1.ts` reads to compute project progress. §6.6b settles it.

**Anything under `prompt-factory/content/literal/` is generated output.** Editing it is a release:
push the factory, bump the consumer's `GENERATED_FROM` to that commit, push the consumer. The
marketplace's `drift.yml` runs the guard from the commit `GENERATED_FROM` names, so a guard change
is not self-deploying.

**`GENERATED_FROM` keeps its invariant**: the commit whose generator produced this output, not the
tip.

**The website is generated from the `v1` line, not from `main`.** Website `GENERATED_FROM` is
`0d97085`, reachable from prompt-factory `v1` and **not** from `main`. This is why the website work
is a project of its own rather than a step in this one (§7.2).

**A Claude Code plugin cannot run `npm install`** and the harness runs on Node's built-in type
stripping (Node 22.18+ / 23.6+ / 24+). Any assessor change inherits that floor and must add no
dependency.

**Changing a marketplace's `name` for existing users is undocumented.** The `renames` map in
`marketplace.json` migrates *plugin* names, not the marketplace's own. This constrains §7.1.

---

## 5a. The book: the one way this project could touch it, and what stops it

The manuscript is read-only to this work and the publisher has signed off; `book` is currently on
`round-9-typesetting` with a round in flight. The non-goal is easy to state. What matters is that
there **is** a live mechanism by which an implementer could write into the book repository without
meaning to, and **nothing would catch it**. All of the following was verified on 2026-11-03.

**The mechanism.** `prompt-factory/build/generate-book.ts` writes
`../book/generated/{ch1..ch9,}-prompt-refs.md` — ten files, all **tracked** in the book repository.
It is reachable two ways: `npm run generate:book`, and `npm run generate:all`, which chains
`generate:website && generate:marketplace && generate:book`. An implementer adding three content
prompts will reasonably run `generate:all`.

**Nothing guards it.** `check-drift.ts` declares `type Target = 'marketplace' | 'website'` and
refuses anything else, so there is no book target and no byte comparison. The factory's CI runs
`npm ci`, `check-determinism.sh` and `npx jest` — and `check-determinism.sh` loops
`for target in marketplace website`, writing to temp directories. **So the book generator never runs
in CI, and no guard would notice if a local run changed `book/generated/`.** The absence of CI is
what makes the absence of a guard matter.

**What stops it, and it is already load-bearing for 7 existing prompts.** `generate-book.ts:35`
emits a prompt only `if (book && book.chapter && book.description)`. So **a prompt is a book output
only when its `outputs.book` carries both `chapter` and `description`.** All 73 prompts have an
`outputs.book` block, and only 66 are emitted: `business-problem`,
`ch1-system-prompt-for-requirements-engineering-analysi`, `ecosystem-map`, `specification`,
`book-editor-constellize`, `book-review` and `generate-prompt` are excluded by exactly that test.
`business-problem` even carries `include: true` and `format: callout` and is still excluded — so
**`outputs.book.include` is a dead field for the book generator**, which r2's §14 named as the thing
to avoid setting. It is not; `chapter` and `description` are.

**The rule for this project**, therefore: the three new prompts carry **no `outputs.book` block at
all**. Then `generate:book` is a provable no-op and `generate:all` is safe to run.

**And it is a no-op today, which gives the test its baseline.** Regenerating from `main` into a
scratch sibling (`git archive` into a temp tree, symlink `node_modules`, run the generator, then
`diff -rq`) produced output **byte-identical** to the committed `book/generated/`. So the book is in
sync with the factory right now, and any diff after this project is this project's doing.
Acceptance 17 is that comparison.

Two other factory files reference `../book` and neither writes to it: `validate-book-refs.ts` only
reads `ch*.md`, and `migrate-book-refs.ts` reads the book's chapters but writes into
`content/prompts/` — its one `writeFileSync` takes a path from the prompts walk, not the book walk.

---

## 6. The workflow

### 6.1 `constellize-feature:specify`

Produces `llm/features/<name>.md` at status SPECIFIED. Never writes source or test files.

| Phase | Delegates to | Kept in the skill |
|---|---|---|
| Project and feature context | `constellize-harness:assess`, then read `llm/memory-bank/*` | — |
| What exists that can be reused, and what is missing | `constellize-design:gap-analysis`, feature-scoped, output path set to the feature's own artifact (§6.6b) | — |
| Adversarial interview | the **`constellize-design:requirements-analysts` agent**, which already has an `ADVERSARIAL ANALYSIS MODE` — it generates the questions, the skill asks them (§6.5) | the protocol: one question at a time, wait, summarise, refuse vague answers, 2–5 questions, and the two always-asked questions (definition of done; how it will be verified) |
| Sample implementation | `constellize-design:implementation-sketch` | — |
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
| Identify stars (reference implementations) | `constellize-design:constellation-map`, feature-scoped | — |
| Gap, then plan | `constellize-design:gap-analysis` → `:implementation-sketch` → `:code-generation-plan` | the plan-confirmation turn |
| Code and tests, test-first per unit | `constellize-craft:unit-tests`, `:integration-tests`, and `:contract-tests` when the feature crosses an API boundary | — |
| Adversarial test review | the **`constellize-craft:qa-engineers`** and **`constellize-design:system-architects`** agents | the protocol, and the rule that a revealed gap becomes a test before anything else |
| Status IMPLEMENTED, record it | `constellize-memory:update` | the status write |

### 6.3 `constellize-feature:verify` — four gates, made real

This is the section both revisions changed most. r1 claimed the course's four gates were the
marketplace's Gates 1–4; they are a different taxonomy (§5). r2 therefore shipped one gate and
three advisory reviews, because an invented constraint forbade editing the skills. **r3 removes that
constraint and fixes the gates instead**, which is what Steve asked for and the better answer.

`verify` reads an IMPLEMENTED spec and leaves it VERIFIED, or leaves it IMPLEMENTED with the
failing gate named.

| Gate | When | Delegates to | What changes in 2.0 |
|---|---|---|---|
| **1 Test integrity** | always | `constellize-craft:test-coverage` | nothing — it is already a gate |
| **4 Maintainability in context** | always | `constellize-craft:architectural-consistency`, `:dependency-hygiene` | both gain a verdict section |
| **2 Health check completeness** | conditional | `constellize-craft:application-health-validation`, `:infrastructure-health-checks`, `:operational-monitoring`, `:actionable-health-reporting`, **and the new `:defensive-programming`** | four gain a verdict section; one is new |
| **3 Deployment readiness** | conditional | `constellize-deliver:externalize-config`, `:environment-independence`, `:reliable-containers`, `:rollback-capability` | all four gain a verdict section |

**The conditional ones**, per Steve's refinement of 2026-11-03: Gates 1 and 4 always; Gates 2 and 3
only when the implementation introduced a dependency, a service call or a config value. A flat
"never 2 and 3" would skip exactly the features that change the deployment surface. Within Gate 2,
`:defensive-programming` is **always** run, because every feature takes input — only the four
operational skills are conditional.

**The verdict section is one shape, copied from the one skill that has it.** Each of the 12 gains:
the gate it belongs to, explicit pass criteria, an explicit list of what fails it, and a
`**Gate Status:** ✅ PASS / ❌ FAIL` line. `test-coverage` is the template, down to its "Accept
<80% branch coverage (FAIL the gate)" phrasing. **No skill's constructive content is rewritten** —
each keeps everything it does today and gains an assertion at the end. That is what keeps this a
large but mechanical change rather than 12 rewrites.

**Exactly which 12, and why not 17.** Seventeen distinct skills carry a Gate 1–4 label. Five are
left alone, each for a reason:

- `constellize-craft:test-coverage` **already has** the verdict this project is copying.
- `:unit-tests`, `:integration-tests`, `:contract-tests` are Gate 1's constructive half — they
  write tests. Gate 1's verdict is `test-coverage`'s, and giving three more skills a competing
  Gate 1 verdict would mean four answers to one question.
- `:ai-assistance` is labelled for Gates 1–5 at once and its description ends "(Best Practices)",
  not "(Gate N: …)". It is guidance on using AI in quality work, not a check on a feature. It keeps
  its labels and gains nothing. **This is why the per-gate counts are 5/5/5/5 but the distinct
  total is 17 rather than 20** — it is in four of the four sets.

The 12 are therefore: `craft:actionable-health-reporting`, `:application-health-validation`,
`:infrastructure-health-checks`, `:operational-monitoring` (Gate 2);
`deliver:externalize-config`, `:environment-independence`, `:reliable-containers`,
`:rollback-capability` (Gate 3); `craft:architectural-consistency`, `:dependency-hygiene`,
`:documentation-completeness`, `:team-comprehension` (Gate 4). Eight in `constellize-craft`, four in
`constellize-deliver`.

**`constellize-craft:defensive-programming` is new**, and it is the course's Gate 2 brought across:
every external input validated, no swallowed exceptions or bare catch-alls, errors with actionable
messages, graceful degradation instead of a stack trace to the user. It exists because nothing in
the 74 skills covers that subject and the alternative — `verify` carrying the review itself, which
is what r2 did — was the design's only exception to its own delegation goal. It is language-neutral
by construction: the course's version named `except:` because crew is Python.

**`constellize-craft:documentation-completeness` and `:team-comprehension` stay out of
verification.** Both are project-scope — whether a *codebase* is comprehensible to a team is not a
property of one feature, and running them per feature would produce the same findings every time.
They keep their Gate 4 label and get a verdict section anyway, so that a project-level gate run can
use them; `verify` does not call them.

**`verify` owns only the aggregate.** Each gate now returns its own verdict, so `verify` collects
them, writes the evidence (§6.6c), and decides VERIFIED or not. The one judgement it makes itself is
comparing measured coverage against a *declared* threshold stricter than the default (§7.5) — which
is not duplication, because no skill can know a per-project setting.

**No Python anywhere.** `verify` consumes coverage rather than producing it (Steve, 2026-11-03), so
the course's `uv run pytest --cov -v` goes; `uv sync && uv run crew` becomes the install-and-run
command the project declares; `uv run ruff check .` becomes the lint command the project declares.

### 6.4 The harness route, and why nothing is lost

`constellize-harness:plan` and `:orchestrate` both carry an "Add a new feature" route today:

```
gap-analysis → implementation-sketch → code-generation-plan → unit-tests → integration-tests → memory:update
```

All six appear in §6.1–6.3. The three skills are a strict superset — they add the spec, the
adversarial passes, four gates that can fail, and the status. So the route becomes:

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

This keeps Steve's reason for having these skills intact — *"the interview IS the value"* — and it
is the single easiest thing to get wrong while believing the design was followed. A build that
satisfies every other criterion and runs the interview inside a subagent has failed anti-goal 3 and
should be rejected. It is also what the course itself does: its phases 7–8 say "Generate questions…
Ask each question to the user ONE AT A TIME."

One consequence to watch: `requirements-analysts` declares `maxTurns: 15` and `disallowedTools:
Write, Edit, Bash`. Under this split neither is a problem — the agent does one analysis pass and
never writes — but a builder who tries to push the whole interview into the agent will hit both and
may be tempted to raise the limit instead of correcting the shape.

### 6.6 Mechanics: invocation, artifact paths, and what makes a status honest

Three mechanisms, settled here because r1 said "delegates to" sixteen times without saying how.

**(a) In-session invocation, with advisory fallback.** The three declare the tool set they need —
skill invocation and subagent invocation — in `allowed-tools`, and call their phases in-session.
They are the first marketplace skills to do so, and that is a deliberate break with
`constellize-harness:execute`'s advisory-only precedent, for two reasons: §6.5 *requires* an agent's
output inside the session, which advisory cannot express at all (an agent is not a slash command);
and `execute`'s own `spawn` mode is marked "Phase 2 — not yet implemented", so advisory is a stopgap
there rather than a principle.

**When a tool or a target is unavailable, the skill falls back to advisory**: print the command,
wait, then verify what the step should have produced — exactly `execute`'s flow. One mechanism
covers three problems: harness tool-name drift (pinning a tool name in generated frontmatter couples
the marketplace to a harness version), a user who installed `constellize-feature` without its
siblings, and a user who prefers to drive it step by step. The fallback also means the state file has
to be resumable, which it is by construction.

The exact tool names are the builder's (§10). **The requirement is that a missing tool or a missing
sibling plugin degrades to advisory with a message naming what is missing, and never fails
silently.**

**(b) The artifact skills gain an output path, and the feature workflow uses it.** The delegated
design skills each write to one fixed project-level path, and `tier1.ts` reads those same files to
compute project progress. A feature-scoped run landing there would overwrite the project's
`gap-analysis.md` with one feature's gaps, make two features clobber each other, and corrupt the
assessor's view of the project.

r2 solved this by having the three capture the output instead — asking those skills to do something
their own prose does not describe. **r3 fixes it properly**, now that editing them is allowed:
`gap-analysis`, `implementation-sketch` and `constellation-map` take an **optional output path**,
defaulting to exactly today's path so every existing caller is unaffected, and the feature workflow
passes the feature's own artifact. `code-generation-plan` already does this.

Two features can then be specified and verified side by side, because their artifacts never share a
path. (Two features being *implemented* at once in one working tree is still two people editing the
same source files, which is git's problem, not this design's.) The prerequisites some of those
skills read — `constellation-map.md`, `scope-lock.md` — must remain optional: the three supply the
feature-scoped context inline and must not require or scaffold project-level files.

This is also the structural fix for the assessor-path defect that §7.4 otherwise defers.

**(c) A VERIFIED status carries its evidence, and the assessor checks it.** `verify` writes a
gate-results block into `llm/features/<name>.md` recording, per gate: the verdict, what it measured
or inspected, the threshold in force where there is one, the command or report it read, and when.
The assessor (decision 12) parses it and reports a feature as `VERIFIED` only when the status says
VERIFIED **and** the block carries a verdict for every gate that was required to run; otherwise it
reports `VERIFIED (unsubstantiated)`.

This is the whole defence, and it is deliberately modest. It does not stop a determined
fabrication. It stops the failure that actually happened: the live course's `verify` says, in
capitals, "NEVER mark VERIFIED if any gate failed" and "100% means 100%", and the course shipped
12–22% coverage with every spec VERIFIED. Prose had already failed. A status that must point at a
verdict per gate, checked by something that is not the skill that wrote it, is the cheapest thing
that would have caught it — and goal 3 is what makes those verdicts exist to point at.

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

### 7.2 The website: out of 2.0 (Steve's call, r3)

**2.0 touches no website files.** The three new prompts carry `outputs.website.include: false`, so
the generator emits no page for them — supported at `generate-website.ts:39`, and the only reason
that is possible is the correction in §11.5.

**What that means and what it costs.** A reader finds the three skills through the marketplace, the
README and the reference card, not through the website's prompt library. The library stays exactly
what it is today: the book's line, at `/prompts/v1/`, generated from prompt-factory `v1`. 1.5
decision 4 — "new material publishes to `/prompts/v2/` only" — is **deferred, not reversed**: it
still describes where new material goes when the website next moves, which is now a different piece
of work.

**The state of that work, recorded so it is not rediscovered a third time.** The memory bank assigns
it to project 2 and describes a pre-project-1 world. Checked 2026-11-03:

- The version split is **already done**: website `eba3473` + `cd4cc70`, 2026-10-29, on `main` and
  pushed. 73 directories under `public/prompts/v1/`; `PromptDetailPage.tsx:29` fetches by version.
- What remains for whoever picks it up: `PromptsIndexPage.tsx:47` hardcodes
  `/prompts/v1/${prompt.id}` and should read a single named constant; the version is a whole-run
  parameter (`generate-website.ts:109`) and `check-drift.ts:188` passes none, so a v2 run needs the
  argument threaded through; the website would need a **second source stamp**, because one stamp
  cannot say "v1 files came from `v1`, v2 files came from `main`" and the website target has no
  `EXTRA` walk (`check-drift.ts:198-204`) so an unguarded line is silently unguarded; and the v2
  run must be **prompts-only**, because personas are written with no version in the path
  (`generate-website.ts:86`) and a second run would demand different bytes for the same 14 files,
  leaving the guard unable to go green.
- **Where it goes**: with the generated `prompts-manifest.json` work (§12). They are the same piece
  — the manifest is the only index of the library, it is hand-maintained, it carries the per-prompt
  `version` field the index would need, and it lives in `src/`, which the website guard reports as
  `FORBIDDEN` for generator output. Routing a new line without generating the manifest means adding
  entries by hand for every prompt on that line.

**Corrected counts, since r1 got them wrong** (§13.1): the generator emits `prompt.txt` files and 14
persona aggregates, not pages — 73 + 14 = **87**, exactly the figure project 1 recorded. The index
renders **71** cards: the manifest's `totalPrompts` is 71 and it correctly omits `generate-prompt`
and `ch1-system-prompt-for-requirements-engineering-analysi`, both of which do have directories
under `public/prompts/v1/`.

### 7.3 The unpinned install command in `book/appC.md:11`: make `main` safe, do not redirect

**`main` stays the 2.0 line and the default branch, and 2.0 is constrained to keep every statement
in the printed appendix true.** Concretely, for as long as the book is in print:

- No skill named in `appC.md`'s table is removed or renamed.
- No plugin named in that table is removed or renamed.
- The Harness plugin keeps exactly its five skills (which is decision 1).
- No printed number is loosened — which is what §7.5 settles for coverage.

**Editing a skill body does not breach any of those**, which is the §5 correction that let r3 fix
the gates. A print reader who types the unpinned command gets the same plugins and the same skill
names the appendix lists, plus one plugin and one skill it does not, with the gates behaving as the
book says they should. The appendix becomes *incomplete*; no sentence in it becomes false. That is
acceptable for a reference card to the line the book was written against — and it is arguably
better than today, since `book/ch4.md`'s gate promises currently describe a mechanism that does not
exist.

**Generated surfaces that count plugins and skills are in scope.** `README.md:8` hardcodes "**74
Skills** across 6 plugins" and a per-plugin table; the infographic lists skill chips under six
plugin sections. Both are generated, drift-guarded files, so updating them is mechanical — the new
totals are **78 skills across 7 plugins** — but they must be updated, and the **v2 reference-card
PDF must be rebuilt** (`npm run build:card --line v2`) because the infographic is its source. **The
v1 card must not be rebuilt.** The PDFs are not generated output and the guard does not cover them,
so this is a release-time step in `docs/releasing-1x.md`, not something CI will catch.

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
drift, and do it before the change ships.**

**Published install commands, as they stand** (verified 2026-11-03):

| Place | Command | Resolves to |
|---|---|---|
| `book/appC.md:11` (print) | unpinned | default branch |
| `website/src/pages/resources/MarketplacePage.tsx:268` | `#v1` | the frozen line |
| `marketplace/README.md:16` (generated) | unpinned, with a note at `:20` to add `#v1` | default branch |
| infographic footer `:497` (generated) | unpinned | default branch |
| reference card, v1 PDF | `#v1` | the frozen line |
| reference card, v2 PDF | unpinned | default branch |

### 7.4 What else changes in 2.0

**2.0 is the feature workflow, the four gates made real, and the plumbing those force.** Nothing
else. `activeContext.md` left this open; closing it, with the reasons:

| Candidate | Where it goes | Why |
|---|---|---|
| The four gates made assertions | **in** (r3) | Goal 3. Without it `verify` has one gate and goal 5 rests on nothing |
| A defensive-programming skill in `constellize-craft` | **in** (r3) | Otherwise `verify` carries that review itself, the design's only exception to its own delegation goal |
| An output-path argument for the design artifact skills | **in** (r3) | It is the correct fix for feature-scoped artifacts, available once editing those skills is allowed (§6.6b) |
| The 100% coverage gate | **in**, as a parameter | §7.5 |
| One memory-bank layout | **already answered** 2026-11-03: `memory-bank`, hyphenated. The course's `llm/memory_bank/` is converted on the way in | — |
| The website / `/prompts/v2/` work | **out** (r3), to the generated-manifest piece | §7.2 |
| The five course-night rewrites | **project 4** | Project 4 replaces crew with Copernicus and rebuilds the course on marketplace skills (decisions 1, 2 and 10). Rewriting crew's nights here is work thrown away twice. The 12 curriculum files that name the three commands (5 module files plus `course/README.md`, both `slides.html`, `instructor-cheatsheet.html`, `INSTRUCTORS-GUIDE.md`, `night-2/5-behind-the-scenes.md`, `night-2/8-wrap-up.md`) are project 4's inventory, recorded here so project 4 does not have to find them again |
| `establish`: 97 lines versus 1,052 | **its own work** | Never decided, and it is a content question about an existing skill |
| Harness defects beyond the assessor, and harness tests generally | **its own work** | 1.5 decision 6. Two scoped exceptions: the assessor change with its tests, and the `plan`/`orchestrate` routing edit |
| Verdict sections for the Gate 5 and 6 skills | **out** | Not feature-scoped, and not needed for goal 3 |
| `constellize-harness:execute`'s lack of state | **in**, as a consequence | Goal 5 gives the assessor feature status and evidence; `execute` and `orchestrate` should use it rather than re-deriving progress |

### 7.5 Coverage: the book's number is the default, and the quoted sentence is not touched

Recorded on 2026-11-03 as *proposed, not confirmed*. Confirmed as designed:

- **Default**: ≥80% branch coverage overall, 100% of critical business logic, 100% of error paths,
  100% of constellation integration points. This is exactly what `constellize-craft:test-coverage`
  already says, and `test-coverage/SKILL.md:14` is the sentence `book/ch4.md:50` quotes verbatim.
- **Opt-in**: a project may declare a stricter threshold, including 100% everywhere.
- **`test-coverage`'s thresholds and its line 14 are not changed.** Editing *that* text would make
  a printed quotation wrong, which §5 does forbid. The skill keeps its numbers and its verdict, and
  is the only one of the 19 that needs no verdict work at all.
- **How a stricter threshold is honoured**: with no declaration, `verify` takes `test-coverage`'s
  verdict unchanged. With a declaration, `verify` passes the threshold and judges the measured
  numbers against the declared one itself. That judgement is `verify`'s to own — no skill can know
  a per-project setting — and it is the one place the aggregate owner makes a measurement call.
- **Where it is declared**: the builder's call (§10), but it is read, not hardcoded, and the three
  skills never carry a number of their own.

The decisive reason for the default is anti-goal 1: the book is printed and says 80%. A 2.0 default
of 100% would make a printed sentence false for anyone who installs from the unpinned command. The
course's 100% survives as the setting Copernicus turns on.

---

## 8. Acceptance

1. **The factory reproduces the marketplace byte-for-byte**, as it does today, with the new files
   included: **104 → 109** (three `constellize-feature` `SKILL.md` + its `plugin.json`, and the new
   `constellize-craft:defensive-programming` `SKILL.md`; `marketplace.json`, `README.md`, the
   infographic, the card HTML and **17 edited `SKILL.md`** change but are existing files — 12
   verdict sections, 3 design skills gaining an output path, and `plan` + `orchestrate` rerouted).
   **The guard
   needs no change** — `GENERATED_OWNED` already starts with `'plugins'` and `findExtraFiles` walks
   recursively, so a new plugin directory is owned on arrival, and `ROOT_ALLOWED` is untouched.
2. **`check-version-bump.sh` passes against a real base**, with `constellize-craft`,
   `constellize-deliver`, `constellize-design` and `constellize-harness` all bumped and
   `constellize-feature` new.
3. **Every gate can fail, demonstrated one gate at a time.** For each of the four, a feature that
   violates it is left IMPLEMENTED with that gate named. This is the test of goal 3, and the
   "gate still cannot fail" anti-goal is exactly what it rules out. A verdict section no caller
   reads would pass a reading of the text and fail this.
4. **No existing skill lost any constructive content.** For each of the 12 skills that gain a verdict, the diff
   is additive: a verdict section appended, nothing removed or reworded. Checkable mechanically.
5. **Every existing caller of the three artifact skills is unaffected** by the new output-path
   argument: invoked without it, each writes exactly the path and bytes it writes today.
6. **`llm/construction/` is byte-identical before and after a full feature run** (§6.6b), and two
   features can be specified and verified without either one's artifacts appearing in the other's.
7. **The three skills run end-to-end on a non-Python project.** A feature taken from `specify` to
   VERIFIED in a TypeScript or Go repository with no skill edits. This is the test for the
   Python-shaped anti-goal, and no amount of reading the text substitutes for it. The new
   `defensive-programming` skill is part of what this exercises.
8. **The same run works with the siblings uninstalled**, falling back to advisory with a message
   naming what is missing (§6.6a).
9. **`verify` cannot write VERIFIED without a verdict for every required gate.** Demonstrated two
   ways: a failing gate leaves the status IMPLEMENTED; and a spec whose status is hand-edited to
   VERIFIED with an incomplete gate-results block is reported by the assessor as
   `VERIFIED (unsubstantiated)`.
10. **A stricter declared threshold is enforced.** A project declaring 100% fails verification at
    85%, where the default would have passed it.
11. **`constellize-harness:assess` reports each feature's status**, demonstrated against a directory
    containing one feature at each of the three statuses, one unsubstantiated VERIFIED, and one
    malformed file.
12. **`constellize-harness:plan` and `:orchestrate` route "Add a new feature" to the three**, and
    the six-step list no longer appears in either file.
13. **No website file changed at all**, confirmed by a clean `git status` in `website` and by the
    website drift guard still passing against its unchanged `GENERATED_FROM`.
14. **The v2 reference card is rebuilt and the v1 card is not**, verified by comparing both PDFs'
    content against their pre-change state.
15. **The factory's test suite covers the assessor's feature parsing and evidence check.**
16. **`v1` is untouched in all three repositories**: prompt-factory `69dffee`, marketplace
    `8f470b2`.
17. **The `book` repository is untouched, checked two ways** (§5a). `git status` in `book` is clean
    after running `npm run generate:all` in the factory — not `generate:marketplace` alone, because
    `generate:all` is the command that reaches the book generator and so is the one that proves the
    point. And `generate-book.ts`'s output, regenerated into a scratch sibling, is byte-identical to
    the committed `book/generated/`, as it is today. Both must hold; the first catches an
    accidental write, the second catches a *silent* one made before the check.
18. **The three new prompts have no `outputs.book` block**, so they can never become book outputs.
    Checkable by reading three files, and the reason it is the right test rather than
    `include: false` is in §5a.

---

## 9. Decided

Steve's decisions are marked; the rest are the author's calls, made because the brainstorming
questions were declined. 16–25 were added in r2; 26–30 in r3, where Steve's four changes are
recorded as his.

| # | Decision | Whose |
|---|---|---|
| 1 | **A new plugin, `constellize-feature`, holding `specify`, `implement`, `verify`.** Reopened in r3 and re-affirmed; alternatives and the naming mechanism in §9a | author, on book evidence |
| 2 | Bring the three in as **delegating** skills | Steve, 2026-11-03 |
| 3 | **The harness delegates down to them**, and the six-step route is deleted, not kept beside them | Steve, 2026-11-03 |
| 4 | **Coverage is consumed, not produced** | Steve, 2026-11-03 |
| 5 | **Coverage is a parameter, defaulting to the book's number**, stricter opt-in | Steve proposed 2026-11-03; confirmed here |
| 6 | **Gates 1 and 4 always; Gates 2 and 3 conditional on the feature touching that surface; Gates 5 and 6 never.** `defensive-programming` is the exception inside Gate 2 and always runs | Steve (always vs conditional), 2026-11-03; the rest author |
| 7 | **The adversarial passes delegate to agents.** The agent generates the questions; the skill asks the human — a subagent has no channel to the user (§6.5) | author |
| 8 | **The feature-spec template is not delegated.** `constellize-design:specification` is a product spec | author |
| 9 | **No new marketplace name**; a marketplace rename has no documented migration | author, confirming decision 12 |
| 10 | ~~Two website lines, guard per line~~ — **superseded by decision 26** | — |
| 11 | ~~The three publish to `/prompts/v2/`~~ — **reversed by decision 26** | — |
| 12 | **The assessor learns to read feature status and check its evidence**, and those functions get tests | author |
| 13 | **`main` stays the default branch; 2.0 keeps every printed appendix statement true.** The default-branch flip is the recorded escape hatch | author |
| 14 | **The course-night rewrites move to project 4** | author |
| 15 | **Nothing else enters 2.0** (§7.4) | author |
| 16 | **In-session invocation via declared `allowed-tools`, with advisory fallback** when a tool or a sibling plugin is missing (§6.6a) | author |
| 17 | ~~One gate, three reviews~~ — **reversed by decision 27** | — |
| 18 | **`verify` owns the aggregate judgement**, and the threshold comparison when one is declared. Anti-goal 3 forbids duplicating a capability, not owning a judgement | author, narrowed in r3 |
| 19 | ~~`verify` carries the defensive-programming review itself~~ — **reversed by decision 28** | — |
| 20 | **`documentation-completeness` and `team-comprehension` are not called by `verify`** as project-scope, not feature-scope. They still gain verdict sections | author |
| 21 | ~~No skill outside `constellize-feature` is edited~~ — **withdrawn in r3; it was never a book constraint** (§5, §13.2) | — |
| 22 | **The feature workflow never writes into `llm/construction/`.** Mechanism changed by decision 29 | author |
| 23 | **State lives in `llm/features/<name>.md`, one file per feature** — reopened in r3 and **flipped back** to Steve's recorded shape; §9b | author |
| 24 | **A VERIFIED status carries its evidence and the assessor cross-checks it** (§6.6c) | author |
| 25 | ~~The v2 generator run is prompts-only~~ — **moot under decision 26**, but recorded in §7.2 for whoever does that work | — |
| 26 | **The website is out of 2.0.** The three carry `outputs.website.include: false`; the `/prompts/v2/` work moves to the generated-manifest piece (§7.2) | **Steve, r3** |
| 27 | **The four gates are made real inside 2.0**: a verdict section on each of the 12 gate-checking skills in Gates 2–4, in `test-coverage`'s shape, appended without rewriting anything (§6.3) | **Steve, r3** |
| 28 | **`constellize-craft:defensive-programming` is a new skill**, carrying the course's Gate 2 subject, which nothing in the marketplace covers. Consequence of 27; the alternative is 19, which 27 makes unnecessary | author, following Steve's r3 change |
| 29 | **`gap-analysis`, `implementation-sketch` and `constellation-map` take an optional output path**, defaulting to today's path. Consequence of 21's withdrawal; replaces r2's capture mode (§6.6b) | author, following Steve's r3 change |
| 30 | **Four plugin version bumps** — craft, deliver, design, harness — enforced by `check-version-bump.sh` | author |

### 9a. The plugin, reopened (decision 1)

Steve asked for this to be reopened in r3. Re-derived, and it stands:

**Placement is forced.** `constellize-harness` is ruled out by three printed sentences (§5). Splitting
`specify` into `constellize-design` and `implement`/`verify` into `constellize-craft` is ruled out
because the state transition needs one owner and a two-plugin workflow cannot refuse to run out of
order. Putting all three in `constellize-craft` is ruled out because `specify` is not craft —
`appC.md` describes that plugin as "Code quality, testing, health checks, and continuous
improvement". So: a seventh plugin.

**The name.** `constellize-feature` reads correctly in use (`constellize-feature:specify`) and names
the unit of work the way the method does. The alternatives considered were `constellize-build` (the
method has no "build" concept, and it collides with CI vocabulary) and `constellize-flow` (names the
mechanism rather than the subject). If the name should be different it is a one-line change in
`content/schemas/plugins.json` plus the generated surfaces, and nothing in the design depends on it.

**One mechanical trap, settled here rather than left to the builder.**
`deriveShortSkillName` strips verb prefixes including `implement-` and `validate-`, so a prompt id
of `implement-feature` would generate a skill named `feature` — `constellize-feature:feature`.
`specify-` is not in that list, which makes the asymmetry easy to miss. So the three prompt ids get
**`specialCases` entries** in `generate-marketplace.ts` mapping them to `specify`, `implement` and
`verify`, exactly as the 20 existing entries do for other awkward ids. That is the established
mechanism, not a workaround.

### 9b. The state layout, reopened (decision 23)

Steve asked for this to be reopened in r3. **Flipped back to one file per feature**,
`llm/features/<name>.md` — which is the shape the memory bank records as the agreed one, and which
r2 overrode.

r2 chose a directory per feature on two grounds: the generated `README.md:65` documents
`features/   # per-feature documentation subsets`, and `tier1.ts` counts only entries where
`statSync(full).isDirectory()`. Both are weaker than they looked. The second is an argument for not
changing code that decision 12 is changing anyway. The first is a line in a generated file, and this
project is already regenerating that file for the plugin and skill counts (§7.3) — so the wording
costs nothing to correct.

Against that, one file is better on three counts: the assessor's evidence check (decision 24) parses
one artifact rather than walking a directory for it; project 4 teaches this shape, so course and
marketplace agree; and it is what Steve already decided. The gate-results block is a section in that
file, not a sibling.

So the assessor's feature discovery changes from counting directories to globbing `*.md`, and
`README.md:65` is reworded. Both are in scope.

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
- **The gate-results block's format** — frontmatter or a table. The constraints are that the
  assessor parses it without a dependency (§5) and that decision 24's cross-check is mechanical.
- **Whether the status itself is prose (`**Status:** SPECIFIED`) or frontmatter.** Frontmatter is
  easier to parse; either way the assessor and all three skills must agree.
- **The exact pass criteria inside each of the 12 new verdict sections.** The shape is fixed by
  `test-coverage` and acceptance 4 forbids changing the surrounding content, but what specifically
  fails `:rollback-capability` for one feature is a judgement per skill. Two rules: it must be
  answerable for a feature rather than for a whole project, and it must not name a language or a
  tool.
- **The three skills' `id`s and categories in `content/prompts/`.** They publish no page
  (decision 26) but they still need ids, and §9a fixes how the names are derived.
- **The order of the work.** The gate verdicts, the new craft skill, the output-path argument and
  the three feature skills are four independent pieces; the assessor change should land before the
  harness routing that depends on it.
- **How the three behave when invoked out of order** — `implement` on a missing or VERIFIED spec,
  `verify` on a SPECIFIED one. The course versions stop and tell the user; keep that, and decide
  whether `specify` on an existing spec revises it or refuses.

---

## 11. Recorded claims that did not survive checking

Project 1.5's first key learning was that a recorded rationale can be false and must be checked
before it is relied on. Six were.

**11.1 "Project 2 owns the website prompt-version split; today `/prompts/v1/<id>` loads
`/prompts/<id>/prompt.txt`."** (`activeContext.md`, Immediate Next Steps 3.) **Already done.**
Website `eba3473` + `cd4cc70`, 2026-10-29, on `main` and pushed. The remainder is inventoried in
§7.2 and no longer belongs to this project.

**11.2 "No repository change can pin a reader who types what the book says."** **False.** An
unpinned `/plugin marketplace add owner/repo` resolves to the repository's default branch, a GitHub
setting. Not recommended, and why, in §7.3 — but the option exists.

**11.3 "'Adversarial' appears nowhere in the marketplace."** **False, and it changed the design.**
`plugins/constellize-design/agents/requirements-analysts.md:204` is a full `ADVERSARIAL ANALYSIS
MODE`, and `constellize-craft/agents/qa-engineers.md` carries the quality voice. The adversarial
passes are delegated to agents rather than written into the three skills (decision 7).

**11.4 "The four gates exist as 16 craft/deliver skills labelled Gate 1–Gate 4."** **There are six
gates across 23 labelled skills** — 5/5/5/5/4/3, with `constellize-craft:ai-assistance` labelled
for Gates 1–5, which is why the totals overlap. Seventeen of those 23 are the Gate 1–4 set. More
importantly, the labels are a *different taxonomy* from the course's four gates; §5, §6.3, §13.1.

**11.5 1.5's evidence table, one row.** It records that the content model *"supports
prompt-without-skill but not skill-without-page"*. `generate-website.ts:39` skips the page when
`outputs.website.include === false`, so skill-without-page works. **In r3 this became
load-bearing**: decision 26 is only possible because of it.

**11.6 "Website 87 files" was never explained, and the explanation matters.** 87 = 73 `prompt.txt`
+ 14 persona aggregates. Knowing that is what exposed the persona trap recorded in §7.2 for
whoever does the website work.

Also: `book/appA.md`'s "Five skills" line is at **48**, not 46 as the memory bank says, and the
matching `ch9.md` line is **324**, not 321.

Two claims in the memory bank's "feature workflow, reshaped" paragraph did hold.
`constellize-design:specification` really is 72 lines with no interview, and the harness's "Add a
new feature" route really is those six steps in both `plan` and `orchestrate`.

---

## 12. Follow-on work this design deliberately defers

Named here so it is not rediscovered. r3 moved three items *into* scope and one out, so this list is
shorter than r2's and has one addition.

1. **The website: `/prompts/v2/` routing, bundled with a generated `prompts-manifest.json`** —
   `title`, `preview` and display `category` added to `content/prompts` frontmatter, the manifest
   generated and brought under a guard, the index link read from a constant, a second source stamp,
   and the prompts-only constraint in §7.2. This absorbs project 1's recommendation and 1.5's
   decision 4, and it is the one piece r3 moved out of 2.0.
2. **Verdict sections for the Gate 5 and 6 skills**, if a project-level gate run is ever wanted.
   Not needed for a feature.
3. **The remaining harness defects** — assessor paths beyond features, uncomputed dimensions,
   missing tiers — and a general harness test suite. 2.0 tests only what it changes.
4. **The 97-line versus 1,052-line `establish` skill.** Still undecided.

---

## 13. What the two revisions changed

### 13.1 r2 — the builder check

A fresh engineer planned from r1 with read access to the trees and returned ten questions and four
corrections. Every one was settled; none went back to Steve, because he had declined the interview.
The four that changed the design:

**Finding A — the author's own error, and the biggest one.** r1 said "the course's four *are* Gates
1–4. They line up." They do not. Course Gate 2 is a defensive-programming review; marketplace Gate 2
is four skills that build database probes, startup validation and operational monitoring. Same
label, different subject. Course Gate 3 was a clean install-and-run; marketplace Gate 3 adds
containers and rollback. Course Gate 4 was lint plus patterns; marketplace Gate 4 adds documentation
and team comprehension. **This is exactly the failure mode 1.5's learning warns about, committed by
the author of the document that quotes it** — the labels were taken at face value instead of read.

**The verdict problem.** Sixteen of the seventeen Gate 1–4 skills emit no pass/fail at all. r1's
acceptance criterion "make a gate fail" was demonstrable on one gate only.

**The delegation mechanism.** r1 said "delegates to" sixteen times and never said how, while the
marketplace's only precedent is advisory prose and no skill may invoke anything. Decision 16.

**The clobbering.** Feature-scoped `gap-analysis` would have overwritten the project's
`llm/construction/requirements/gap-analysis.md` — the file the assessor reads for project progress.
Decision 22.

Three further corrections of fact: `GENERATED_OWNED` already covers a new plugin directory; the
index renders 71 cards, not 73, and the generator emits files rather than pages; and the generated
`README.md:65` does publish a layout for `features/`, which r1's "exists and is unused" evidence row
missed because the README writes it without the `llm/` prefix.

### 13.2 r3 — Steve's four changes, and the constraint that turned out to be invented

Steve asked for changes in four places. Two were direct instructions; two were "look at this again".

**"Make four gates real" was the one that cascaded**, because r2 had answered the verdict problem by
*accepting* it — one gate, three advisory reviews — on the strength of a non-goal r2 had written
itself: "no skill outside `constellize-feature` has its text edited". r2 justified that as what kept
2.0 "additive" for the printed appendix. Re-derived in r3: **the appendix lists plugin and skill
names, reproduces no skill body, and states no counts.** Editing a body breaks nothing in print. The
only printed text a skill body can falsify is the coverage sentence `book/ch4.md:50` quotes from
`test-coverage:14`, and that skill is the one that needs no change.

So the constraint was invented, and removing it improved three things at once: the four gates become
assertions (decision 27); the course's defensive-programming subject gets a proper home instead of
being carried inside `verify` (decision 28, dissolving r2's only exception to its own delegation
goal); and the artifact clobbering is fixed with an output-path argument rather than asking skills to
behave unlike their own documentation (decision 29).

**"Drop the website work"** — decision 26. Possible only because of correction 11.5. §7.2 now
inventories what remains and names its new owner rather than deleting the knowledge.

**"Plugin name/placement"** — re-derived in §9a. Placement is forced by the book; the name stands,
with the alternatives recorded and the `deriveShortSkillName` trap settled by `specialCases` rather
than left to the builder.

**"Feature state layout"** — flipped back to one file per feature in §9b, restoring the shape the
memory bank records as agreed. r2's directory argument rested on not changing code this project
changes anyway, and on a line in a generated file this project regenerates anyway.

---

## 14. Traps for whoever writes the prompts

**`generate-book.ts` hardcodes v1 in every URL it emits** (`:63`,
`url="{SITE_BASE}/prompts/v1/${prompt.id}"`). So a new prompt that became a book output would put a
dead `/prompts/v1/<new-id>` link into `book/generated/` — doubly dead under decision 26, since the
three publish no website page either. §5a is why that cannot happen and acceptance 18 is the check.

**Corrected from r2**, which said "if the three new prompts carry `outputs.book.include: true`".
That is the wrong field: `generate-book.ts:35` tests `book.chapter && book.description` and ignores
`include` entirely. `business-problem` carries `include: true` and is one of the 7 prompts excluded
from the book. Naming the wrong field would have had a builder set `include: false` and believe the
risk was handled.

Relatedly, `validate-full-chain.ts` has been stale since the versioning commit: its
`getWebsitePromptIds()` lists directories directly under `public/prompts`, so it now reports the
website as holding one prompt called `v1`. Worth fixing while nearby; not part of this project.

(The `deriveShortSkillName` trap that was here in r2 is now settled in §9a.)

---

## 15. Evidence

Everything asserted above was checked on 2026-11-03 against the working trees at prompt-factory
`main` = `8d75f6c`, marketplace `main` = `272e7be`, website `main` = `11a16f1`.

| Claim | How it was checked |
|---|---|
| The book says "five" driving skills in three places | `book/ch9.md:324`, `book/appA.md:48`, and the Harness row of the `appC.md:33` table, which names exactly `orchestrate`, `assess`, `plan`, `execute`, `init` |
| The book names no plugin count and no skill count | `grep` for "six plugins", "5 plugins", "N skills" across `book/*.md` — no hits. This is what makes editing skill bodies safe (§5) |
| `appC.md` quotes no skill body | read in full; it is a plugin/skill name table plus prose about the harness |
| The book's coverage sentence is `test-coverage`'s | `book/ch4.md:50` quotes "…minimum thresholds: 80% branch coverage overall, 100% coverage of critical business logic, 100% of error paths…"; `test-coverage/SKILL.md:14` is that sentence |
| `book/appC.md:11` is unpinned | read directly |
| No skill can invoke a skill or an agent | `grep -rh 'allowed-tools' plugins/*/skills/*/SKILL.md \| sort \| uniq -c`: 58 × `Read, Glob, Grep, Write, Bash`, 12 × `Read, Glob, Grep, Bash`, 4 × `Read, Glob, Grep`. No `Task`, `Agent` or `Skill` in any |
| The only delegation precedent is advisory | `constellize-harness/skills/execute/SKILL.md:21-26` presents the step and waits ("Press enter when done, or 's' to skip"), then verifies the artifact; spawn mode at `:15` and `:54` is "Phase 2 — not yet implemented" |
| `allowed-tools` passes through the generator verbatim | `generate-marketplace.ts:136` emits `skill['allowed-tools'].join(', ')` |
| Only `test-coverage` asserts a verdict | `grep -c 'Gate Status\|FAIL the gate'`: `test-coverage` 8 (`:180`, `:197-199`, `:212`, `:363`, `:476`), and 0 for `architectural-consistency`, `application-health-validation`, `documentation-completeness`, `team-comprehension`, `dependency-hygiene`, `infrastructure-health-checks`, `externalize-config`, `environment-independence`, `reliable-containers`, `rollback-capability` |
| The Gate 2–4 skills are constructive | all carry `allowed-tools: Read, Glob, Grep, Write, Bash`; their descriptions begin "Implement…", "Build…", "Achieve…", "Enable…" |
| Course Gate 2 is defensive programming | `curriculum/skills/course:feature:verify/SKILL.md` Gate 2: "Every external input is validated", "no bare `except:`", "Graceful degradation for bad input" |
| Nothing in the marketplace covers that subject | case-insensitive `grep` for input validation / silent failure across all 74 `SKILL.md` hits only `constellize-craft:ai-changes`, `:ai-assistance` and two memory skills; `ai-changes`'s own subject is "Validate AI-generated changes… line-by-line comparison… silently omitted code" — a different review |
| There are six gates across 23 skills | `grep -rl 'Gate [1-6]'`: 23 distinct skills, 5/5/5/5/4/3 by gate; `ai-assistance` matches Gates 1–5 |
| Gates 1–4 are 17 distinct skills, and Gates 2–4 are 13 | computed by unioning the per-gate sets: 5+5+5+5 = 20 labels over 17 skills, because `ai-assistance` is in all four. Gates 2–4 union to 13, minus `ai-assistance` leaves the **12** that gain verdicts (8 craft, 4 deliver) |
| `ai-assistance` is not a gate check | its `description` ends "(Best Practices)" where every other gate-labelled skill's ends "(Gate N: …)"; its subject is "Leverage AI assistance to accelerate quality engineering" |
| 74 skills, 14 agents, 6 plugins | `find plugins -name SKILL.md \| wc -l` = 74 (craft 20, deliver 12, design 10, grow 16, harness 5, memory 11); `find plugins -path '*/agents/*.md' \| wc -l` = 14. `README.md:8` says "**74 Skills** across 6 plugins" |
| A changed plugin must be version-bumped | `.github/scripts/check-version-bump.sh`: fails for any plugin with a change under `plugins/<name>/**` other than its own `plugin.json` unless the version differs from base; a new `plugin.json` absent at base passes |
| The design skills write to fixed project paths | `gap-analysis/SKILL.md:45` "outputs to `llm/construction/requirements/gap-analysis.md`"; `implementation-sketch/SKILL.md:48-52` reads `gap-analysis.md`, `constellation-map.md`, `scope-lock.md` and outputs to `llm/construction/design/implementation-sketches.md` |
| The assessor reads those same files | `scripts/tier1.ts` computes construction status from `llm/construction/` artifacts |
| A new plugin needs no guard change | `check-drift.ts:90`, `GENERATED_OWNED` begins `'plugins'`; `findExtraFiles` walks recursively |
| The website target has no `EXTRA` walk | `check-drift.ts:198-203` adds only `FORBIDDEN` on `src/`; the loop at `:204` iterates the generated list, so a file the generator does not emit is never examined |
| `check-drift` passes no version | `check-drift.ts:188` is `gen.generate(scratch)` |
| A prompt can generate a skill with no website page | `generate-website.ts:39` returns early when `outputs.website.include === false`. Decision 26 rests on this |
| The website is generated from the `v1` line | website `GENERATED_FROM` = `0d97085`; `git branch --contains` in prompt-factory lists `v1` and `origin/v1`, not `main` |
| The website version is a whole-run parameter | `generate-website.ts:109`; the per-prompt `version:` frontmatter is never read there |
| Personas are not versioned | `generate-website.ts:86`, `path.join(websiteDir, 'public/personas', category, subcategory)` — no version segment |
| 87 = 73 + 14 | `ls public/prompts/v1 \| wc -l` = 73; `find public/personas -name 'Aggregate_Expert_Synthesis.md' \| wc -l` = 14 |
| The index renders 71, not 73 | `prompts-manifest.json` `totalPrompts` = 71 with 71 actual entries; the two v1 directories it omits are `generate-prompt` and `ch1-system-prompt-for-requirements-engineering-analysi` |
| The website split already landed | website `git log`: `eba3473` "Store website prompt text by version" and `cd4cc70`, both 2026-10-29, both on `main`; `PromptDetailPage.tsx:29` fetches `/prompts/${version}/${id}/prompt.txt` |
| The generated README publishes a `features/` layout and hardcodes counts | `content/literal/marketplace-root/README.md:65` `features/   # per-feature documentation subsets`; `:8` the skill and plugin counts |
| The assessor counts only directories, and has no status field | `tier1.ts:133-152` pushes an entry only when `statSync(full).isDirectory()`; `types.ts:13` `FeaturesState` is `{count, entries}` |
| `llm/features/` exists and nothing writes to it | `constellize-harness:init` creates it; `grep -rl 'llm/features'` over `plugins/` hits only `init` and `tier1.ts` |
| `constellize-design:specification` is a product spec | 72 lines, `{{product_name}}`, FR-/NFR- numbering, no interview |
| `deriveShortSkillName` strips `implement-` | `generate-marketplace.ts:104-105`, `verbPrefixes` includes `'implement-'` and `'validate-'`; `'specify-'` is absent. `specialCases` at `:57-80` is the existing mechanism for awkward ids |
| `generate-book.ts` hardcodes v1 | `:63`, `url="{SITE_BASE}/prompts/v1/${prompt.id}"` |
| The three commands appear in 12 curriculum files | `grep -rln 'feature:specify\|feature:implement\|feature:verify'` over `curriculum/course/` and `curriculum/*.md` |
| The two marketplace names already differ by branch | `git show main:.claude-plugin/marketplace.json` → `constellize-plugins-official`; `git show v1:…` → `constellize-plugins-v1` |
| Published install commands | the table in §7.3, each read at the line given |
| `generate-book.ts` writes into the book repo, and `generate:all` reaches it | `:7` and `:16` (`BOOK_DIR = '../book'`), `:130`/`:140` write `../book/generated/`; `package.json` `generate:all` = `generate:website && generate:marketplace && generate:book` |
| Those ten files are tracked in `book` | `git -C book ls-files generated/` lists `ch1..ch9-prompt-refs.md` and `prompt-refs.md` |
| No drift target and no CI covers the book | `check-drift.ts:24` `type Target = 'marketplace' \| 'website'`, and `:159` refuses anything else; `generators.yml` runs only `npm ci`, `check-determinism.sh`, `npx jest`; `check-determinism.sh:10` loops `for target in marketplace website` |
| The book is in sync with the factory today | `git archive main` into a scratch sibling, symlinked `node_modules`, ran `generate-book.ts`, `diff -rq` against `book/generated/` → identical, 66 prompt-refs |
| Book output needs `chapter` and `description`, not `include` | `generate-book.ts:35` `if (book && book.chapter && book.description)`. Loaded all 73 prompts: 73 have `outputs.book`, 66 emit, and the 7 excluded are `business-problem`, `ch1-system-prompt-for-requirements-engineering-analysi`, `ecosystem-map`, `specification`, `book-editor-constellize`, `book-review`, `generate-prompt`. `business-problem`'s block is `include: true` + `format: callout` with no chapter |
| The book repo is clean and nothing in this session touched it | `git -C book status --short` empty, `git -C book diff --stat HEAD` empty, on `round-9-typesetting` level with `origin` |
| The other two book-aware factory files do not write to it | `validate-book-refs.ts` only reads `ch*.md`; `migrate-book-refs.ts:173`'s `writeFileSync` takes its path from the `content/prompts` walk at `:99-108`, not the `BOOK_DIR` walk at `:42-43` |

---

## 16. What this unblocks

Project 4 (Copernicus) was told to use marketplace prompts and agents rather than the course's own
skills (decision 10, 2026-10-28), and the question left open was whether "use v2 prompts" meant
porting the course's chain in or building the course on what the marketplace already had. This
design answers it: the chain comes in, rewritten and delegating, so project 4 rebuilds its modules
on `constellize-feature:specify|implement|verify` and ships no `course:*` skills at all. The 12
curriculum files in §7.4 are its inventory, and decision 23 means the course teaches the same state
artifact the marketplace writes.

It also hands project 4 something the live course never had: gates that can fail. The course's
claimed 100% coverage gate measured 12–22% with every spec VERIFIED. Under goal 3 and decision 24,
that combination is no longer reachable without someone editing the evidence by hand.

Project 3 (delivery) is untouched by this.
