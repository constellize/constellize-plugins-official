# Marketplace 2.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to
> implement this plan task-by-task — Steve chose that method on 2026-11-04, so it is settled, not a
> recommendation. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status**: **APPROVED by Steve, 2026-11-04.** The execution method is **subagent-driven**
(`superpowers:subagent-driven-development`), his choice too.

> **The approval record, and its evidence.** Steve approved this plan in his own words, in the
> session that wrote it, and chose the execution method in the same session. The turns are in that
> session's transcript,
> `~/.claude/projects/-Users-satkinson-Work-constellize/d67c3eab-2777-4f21-80ed-e269ff634116.jsonl`:
> **"Approve the plan"** at `2026-11-04T19:07:25Z`, **"Push them"** at `22:19:53Z`, and
> **"Subagent-driven"** at `22:21:00Z`. None of the three is the F1 answer, which reached that
> session separately and later, relayed from the design session.
>
> **Correction of commit `56a2e56`.** That commit set this line back to "AWAITING Steve's approval"
> on the grounds that no approval had been given and that his F1 answer — "narrow 13, keep card" —
> had been mistaken for one. That is wrong on the facts, and the three turns above are why: the
> approval is an earlier, separate turn of Steve's own, typed directly to the session that wrote the
> plan. The design session could not see it, because it only ever saw its own relay, and a relay
> carries a report rather than a conversation. Both commits are kept in history rather than rewritten
> out of it, which is this project's standard.
>
> The *standard* behind `56a2e56` was right, and it is the one this whole project exists to enforce:
> a status claim is worth no more than the evidence cited beside it, and a reviewer who cannot see
> the evidence is right to refuse the claim. An APPROVED status with nothing cited is the same defect
> as the course's VERIFIED specs at 12–22% coverage — which is what §6.6c's cross-check and finding
> F3's `required` flag exist to stop. So this line no longer asserts the status; it names where the
> evidence is and what it says, which is what `56a2e56` should have been able to check.

**Date**: 2026-11-04. All tree checks in this plan were made on 2026-11-04 against prompt-factory
`main` = `8d75f6c`, marketplace `main` = `1ada821`, website `main` = `11a16f1`, book
`round-9-typesetting` = `18c83e5`.

**Goal:** Give the marketplace a feature-sized workflow — `specify` → `implement` → `verify` in a
new `constellize-feature` plugin — and make the four quality gates able to fail, so a VERIFIED
status points at evidence the harness assessor can check.

**Architecture:** Everything ships through `prompt-factory`. The three new skills and
`constellize-craft:defensive-programming` are new prompts under `content/prompts/`; the 12 verdict
sections and the three output-path arguments are edits to existing prompts; the assessor and the
harness routing are edits to the literal tree at `content/literal/constellize-harness/`. The
marketplace is regenerated from the factory and byte-guarded, so no file is ever edited in the
marketplace repo itself. The work lands as **three independent releases** (A: gates can fail; B:
output paths; C: the feature plugin and the assessor), each self-contained and each green on its
own.

**Tech Stack:** Markdown prompts with YAML frontmatter (`content/prompts/`), TypeScript generators
run via `ts-node` (`build/`), TypeScript assessor run via Node's built-in type stripping
(`content/literal/constellize-harness/scripts/`, Node 22.18+ / 23.6+ / 24+, **no dependencies**),
jest + ts-jest (`build/__tests__/`), GitHub Actions drift and version-bump guards.

**Spec:** [`marketplace/docs/specs/2026-11-03-marketplace-2-0.md`](../specs/2026-11-03-marketplace-2-0.md)
— approved by Steve 2026-11-04, revision 3. The plan argues from the spec; read both. Section
references below (§5, §6.3, §9, §10…) are to that document.

---

## Global Constraints

Every task's requirements implicitly include this section.

- **The `book` repository is read-only.** Nothing under `book/` is edited — not the manuscript, not
  `book/generated/`. The three new prompts carry **no `outputs.book` block at all**; `include: false`
  is the wrong field (`generate-book.ts:35` tests `book.chapter && book.description`, §5a).
- **`v1` is frozen in both repos**: prompt-factory `69dffee`, marketplace `8f470b2`. No task touches
  either, and no task pushes a `v1` branch or any tag.
- **`course-infra` is not touched.** It has unpushed local commits and an untracked roster file and
  is unrelated to this work.
- **No file is edited in the `marketplace` repo except under `docs/`.** Everything else there is
  generated output; the source is `prompt-factory`.
- **A guard change is not self-deploying.** `drift.yml` checks out prompt-factory at the commit
  `GENERATED_FROM` names, so the release order is always: push prompt-factory → bump the
  marketplace's `GENERATED_FROM` to that commit → push the marketplace.
- **Four plugin version bumps are required and CI enforces them.**
  `.github/scripts/check-version-bump.sh` fails any plugin with a change under `plugins/<name>/**`
  other than its own `plugin.json` unless the version differs from base. Versions live in
  `content/schemas/plugins.json`, never in a literal file: `constellize-craft` `1.0.0` → `1.1.0`,
  `constellize-deliver` `1.0.0` → `1.1.0`, `constellize-design` `1.0.0` → `1.1.0`,
  `constellize-harness` `1.1.1` → `1.2.0`, `constellize-feature` new at `1.0.0`.
- **Every command in this plan runs from the `prompt-factory` repository root** unless the step
  says otherwise. That is where `package.json` lives — `marketplace` has none at all — so
  `npm run generate:marketplace`, `npm run check:drift` and `npm run build:card` only work there,
  and sibling repositories are reached as `../marketplace`, `../website`, `../book`.
- **No skill or plugin is renamed or removed**, and the Harness plugin keeps exactly its five skills
  (`orchestrate`, `assess`, `plan`, `execute`, `init`). This is what `book/appC.md:33`,
  `book/ch9.md:324` and `book/appA.md:48` bind (§5).
- **`constellize-craft:test-coverage` is not edited at all.** `book/ch4.md:50` quotes
  `test-coverage/SKILL.md:14` verbatim. Its thresholds, its line 14 and its existing verdict stay as
  they are.
- **The coverage default is the book's number**: ≥80% branch coverage overall, 100% of critical
  business logic, 100% of error paths, 100% of constellation integration points. A project may
  declare a **stricter** threshold only (see decision D2 and Review Focus 1).
- **No website file is changed**, with exactly one deliberate exception recorded in Finding F1: the
  v2 reference-card PDF. Nothing under `website/public/prompts/`, `website/public/personas/` or
  `website/src/` changes, and the website drift guard still passes against its unchanged
  `GENERATED_FROM` (`0d97085`).
- **No Python, and no language or tool named** in any new or edited skill body. Commands come from
  what the project declares (decision D2).
- **The assessor adds no dependency.** Node built-ins only; `JSON.parse` and `RegExp` are the whole
  parsing toolkit.
- **Drift count goes 104 → 109.** Five new generated files: three `constellize-feature` `SKILL.md`,
  `constellize-feature/.claude-plugin/plugin.json`, and
  `constellize-craft/skills/defensive-programming/SKILL.md`.

---

## Review Focus

Five failure modes the spec implies but names no test for. Each has its test added to the task that
owns the code, in that task's own step style.

1. **A project declares a coverage threshold *looser* than the book's default.** The spec only ever
   says "stricter opt-in" (§7.5) and never says what happens to a looser declaration. A project
   setting 50% would make `book/ch4.md:50` false for anyone on the unpinned install. Expected: the
   declaration is **refused**, the default applies, and `verify` says so. Test in Task C1.
2. **The gate-results block is present but malformed** — truncated, trailing comma, not a JSON
   object. Expected: the assessor reports that feature as `VERIFIED (unsubstantiated)` and keeps
   assessing the rest of the project; it never throws and never treats unparseable evidence as
   evidence. Test in Task C1.
3. **The status line is missing, duplicated, or inside a fenced code block.** The feature artifact is
   hand-editable prose and the spec template itself contains a fenced example carrying
   `**Status:** SPECIFIED`. Expected: the assessor reads the first status line that is not inside a
   fence, and reports `unknown` when there is none. Test in Task C1.
4. **`llm/features/` holds a `.md` that is not a feature** — a `README.md`, scratch notes, or a
   leftover directory from the pre-2.0 layout. Expected: an entry with no recognisable status is
   reported as `unknown` rather than silently counted as a feature, and a directory is still
   reported (so pre-2.0 projects do not lose their count). Test in Task C1.
5. **A feature name that is not a safe filename** — containing `/`, `..`, spaces, or differing from
   an existing feature only by case (macOS is case-insensitive, so `Login.md` and `login.md` are the
   same file). Expected: `specify` kebab-cases the name, refuses a name that still contains a path
   separator or `..`, and refuses to create a feature whose kebab-cased name case-insensitively
   matches an existing one. Test in Task C4.

---

## Decisions this plan settles

§10 of the spec leaves nine things to the builder. All nine are settled here. No §9 decision is
reopened.

| # | §10 item | Decision | Reason |
|---|---|---|---|
| D1 | The exact `allowed-tools` names for invocation | All three skills declare `Read, Glob, Grep, Write, Bash, Skill, Task, Agent`. Both `Task` and `Agent` are listed because the subagent tool's name is harness-version-dependent (this very workspace exposes it as `Agent`; the Claude Code CLI has long published `Task`). The **contract is the fallback**, not the names: a missing tool degrades to advisory. Task A0 verifies empirically that an unknown name in `allowed-tools` is inert rather than fatal, and if it is fatal the list narrows to `Skill, Task`. **A0 outcome, 2026-11-05: inert. The list stands.** Two scratch project skills were written under a `.claude/skills/` outside all five repos — one declaring `Read, Glob, Grep, Write, Bash, Skill, Task, Agent, ThisToolDoesNotExist`, one control declaring only names that exist — and a fresh `claude -p` (CLI 2.1.317) run from that directory listed **both** skills and invoked **both** with byte-identical results. An unknown name therefore neither unregisters a skill nor fails its invocation. Scratch skills deleted; nothing committed from A0 | §5: the generator passes `allowed-tools` through verbatim (`generate-marketplace.ts:136`), so this is frontmatter, not a generator change. §6.6a makes the fallback the requirement |
| D2 | How a project declares its coverage threshold, test, lint and install-and-run commands | One optional file, **`llm/constellize.json`**, with optional keys `coverageThreshold` (object), `testCommand`, `lintCommand`, `runCommand` (strings). Absent file, absent key and absent `llm/` are all valid: the default thresholds apply and `verify` asks the user for a command it needs and cannot find. `constellize-harness:init` gains one line creating it | JSON is the only format a dependency-free assessor can parse exactly (`JSON.parse`); YAML would need a dependency (§5) and a markdown table needs a hand-rolled parser. It is read, never hardcoded, and the three skills carry no number of their own. Creating it in `init` is the one small addition this plan makes beyond §10, flagged in Finding F4 |
| D3 | How `verify` decides a feature touched the operational or deployment surface | Three inputs in order: the artifact's **Technical Notes** and **Dependencies** sections, the IMPLEMENTED report's **Files created / Files modified** list, and the working-tree diff where one is available. Gates 2 and 3 run if **any** of: a new runtime dependency; a new configuration value or environment variable; a new outbound service, network or database call; a touched deployment artifact. **If the evidence is absent or ambiguous, both gates run.** The determination and its reason are recorded in the gate-results block | The spec names the first two inputs as obvious. Failing toward *more* checking is the only safe default, because the opposite lets a feature skip a gate silently — and §6.6c's cross-check cannot verify "a verdict for every required gate" unless the artifact records which gates were required (Finding F3) |
| D4 | The gate-results block's format | A fenced **```json** block under a fixed heading `## Gate Results`, schema in Task C1. The assessor extracts it with one anchored regex and reads it with `JSON.parse` | Exact, dependency-free, and mechanically cross-checkable (§6.6c). A markdown table would need a bespoke parser — more code and more ways to be wrong |
| D5 | Whether the status is prose or frontmatter | **Prose**, the course's own line `**Status:** SPECIFIED` (and `IMPLEMENTED` / `VERIFIED`), as the single canonical location, read by an anchored regex that skips fenced blocks | The course template already uses it and project 4 teaches that shape, so course and marketplace agree (§9b's own reasoning). Frontmatter would need a YAML parser in a dependency-free assessor. The machine-readable JSON is for *evidence*, not for the status: one fact, one home |
| D6 | The pass criteria inside each of the 12 verdict sections | Written out in full in Tasks A2, A3 and A4 — five or six requirements each, every one answerable for a single change and naming no language or tool | These are decisions the implementer cannot make alone, so they belong in the plan. Both of §10's rules are honoured; for `documentation-completeness` and `team-comprehension`, "answerable for a feature" is read as answerable **for the change under review**, which is what makes a project-scope skill able to return a verdict at all |
| D7 | The three skills' `id`s and categories | ids **`specify-feature`**, **`implement-feature`**, **`verify-feature`**, in a new unnumbered directory `content/prompts/feature/`, with `chapter: 0`, `category: ai-workflow`, and `specialCases` entries mapping them to `specify`, `implement`, `verify` | `chapter: 0` is the existing convention for a prompt with no book chapter (`content/prompts/meta/`'s three prompts all use it), and an unnumbered directory is that convention's existing home — a `10-` prefix would imply a chapter 10 that does not exist. `category` must come from `prompt.schema.json`'s enum, which has no "feature"; `ai-workflow` is the closest member, and the field is in any case read by nothing (verified: `frontmatter.category` is used only when a plugin selects by category, and every plugin selects by `include`). §9a fixes the name derivation |
| D8 | The order of the work | Three releases: **A** the 12 verdicts + `defensive-programming` (craft, deliver); **B** the output-path argument (design); **C** the `constellize-feature` plugin + the assessor + the harness routing (feature, harness). A and B are independent of each other; C depends on both. Inside C the assessor lands before the routing | Each release is independently green, independently useful and independently reviewable, and each bumps only the plugins it touches. One combined release would be a single commit changing 109 generated files — passable by CI, unreviewable by a person |
| D9 | Out-of-order invocation | `implement` with no artifact → refuse, name the artifact it looked for. `implement` on IMPLEMENTED or VERIFIED → refuse, name the status and the skill to run instead. `verify` with no artifact, or on SPECIFIED → refuse, name the status. `verify` on VERIFIED → **re-run** and rewrite the gate-results block. `specify` on an existing artifact → **revise it after confirmation**; if the status is IMPLEMENTED or VERIFIED, warn that revising the contract invalidates the recorded evidence and, on confirmation, reset the status to SPECIFIED and **delete the gate-results block** | Refusing is the course's behaviour and §10 says keep it. `verify` is the one exception: code changes after a pass, so re-verification must be allowed or the gates are single-use. Clearing the evidence on a spec revision closes a hole §6.6c would otherwise leave open — a VERIFIED status pointing at verdicts measured against a contract that has since changed is exactly the unsubstantiated status the project exists to prevent |

---

## Problems found in the design while planning

Recorded rather than designed around, per the spec's own standard. All four were checked against the
code, not the prose.

**F1 — acceptance 13 and acceptance 14 contradict each other, and the non-goal with them.**
Acceptance 14 requires the v2 reference card to be rebuilt. Acceptance 13 requires "**No website
file changed at all**, confirmed by a clean `git status` in `website`". But
`prompt-factory/scripts/build-reference-card.mjs:320` writes to `path.join(REPO_ROOT, '..', 'website', 'public')`
by default, and `public/constellize-reference-card-v2.pdf` **is tracked in the `website` repo**
(`git ls-files` in `website` lists `-v1.pdf`, `-v2.pdf` and an unversioned
`constellize-reference-card.pdf`). Satisfying 14 therefore breaks 13 as written, and breaks the §3
non-goal "No website files are touched" too. §7.3 already half-acknowledges this — it calls the card
rebuild "a release-time step … not something CI will catch" — but the acceptance criteria were not
narrowed to match.
**Steve's decision, 2026-11-04 — "narrow 13, keep card".** Acceptance 13 now reads *no generated
website content changes*: nothing under `public/prompts/`, `public/personas/` or `src/`, with the
website drift guard still green against `GENERATED_FROM` = `0d97085`. The rebuilt v2 PDF is a single
deliberate website commit, made and reviewed on its own (Task C8), with the v1 PDF and its
unversioned alias both proved byte-identical afterwards. The alternative he was offered and declined
was to drop the card rebuild from 2.0 and leave the printed-card-vs-marketplace drift to a later
release. This changes an acceptance criterion in a design Steve had already approved, so it is
recorded here as **his decision**, not as a reading taken by the plan's author; Task C8 stands as
written, and the narrowed acceptance 13 is what the release is judged against.

The design document was amended to match, as a separate commit on `marketplace` `main`: §3's
non-goal and §8's acceptance 13 now carry the narrowed wording and name it as Steve's 2026-11-04
decision. Before that amendment the spec on `main` (`1ada821`) still carried the un-narrowed
acceptance 13 and the flat non-goal "No website files are touched", which would have left the two
documents contradicting each other — the same way the design carried two wrong claims through a
revision each.

**F2 — the card command in §7.3 does not work, and the release doc's documented procedure
rebuilds the frozen v1 artifacts.** The card builder is
`prompt-factory/scripts/build-reference-card.mjs`, and `build:card` is defined in
`prompt-factory/package.json:23`; neither is in the `marketplace` repo, which has no `package.json`.
§7.3 gives `npm run build:card --line v2`. npm (11.19.1, verified by running it) consumes
`--line` as its own config and passes only `v2` to the script, whose `parseArgs` has
`default: throw new Error(\`Unknown argument: ${argv[i]}\`)` — so the command fails loudly. That is
the safe failure. The unsafe one is `marketplace/docs/releasing-1x.md:63`, which gives a bare
`npm run build:card` from the factory root. That doc is not wrong about the script — it says plainly
that the bare command writes all three PDFs — but the procedure it documents is unsafe for **this**
release, because with no `--line` `main()` maps over every entry in `LINES`
(`build-reference-card.mjs:321-325`, default out-dir `:324`) and the `v1` entry carries
`alsoWriteAs: 'constellize-reference-card.pdf'` (`:51-59`). A bare run therefore rewrites **two**
v1-pinned artifacts: `-v1.pdf` and the unversioned alias the printed book's readers follow. That
violates acceptance 14 and touches an artifact `v1` is frozen to protect. The correct invocation is
`npm run build:card -- --line v2 --out ../website/public/constellize-reference-card-v2.pdf`.
Task C8 uses it and narrows the release doc's procedure for the frozen-`v1` case.

**F3 — §6.6c's cross-check is unverifiable as specified.** The assessor is to report `VERIFIED` only
when the block "carries a verdict for every gate that was required to run". Nothing in the design
records *which* gates were required: that is `verify`'s own conditional judgement (decision 6), made
in-session and otherwise unwritten. As specified, a `verify` that skipped Gate 3 and recorded no
verdict for it is indistinguishable from one for which Gate 3 was correctly not required.
**Resolution:** D3 and D4 require the gate-results block to record the surface determination, its
reason, and a `required: true|false` flag per gate. The assessor then checks that every gate marked
required has a verdict, and that Gates 1 and 4 and `defensive-programming` are marked required
always. This is a mechanism the design implies but does not state; it is additive to every decision
in §9.

**F4 — §6.6b settles the output path and leaves the input paths.** Decision 29 gives `gap-analysis`,
`implementation-sketch` and `constellation-map` an optional **output** path. But
`implementation-sketch` *reads* `construction/requirements/gap-analysis.md`,
`constellation-map.md` and `scope-lock.md` at fixed paths (`implementation-sketch.md:99-101` in the
prompt source), and in a feature-scoped run `gap-analysis` has just written its output somewhere
else. Reading the project-level file would mean reading another feature's gaps — the very defect
decision 29 exists to prevent.
**Resolution:** the optional argument is a **markdown file path**, and the semantics cover both
directions (Task B1): the skill owns one named section inside that file, replaces it in place, and
resolves its prerequisites from sibling sections of the same file. Prerequisites stay optional — a
missing section is recorded, never scaffolded. Two smaller additions fall out of the same place:
`init` gaining `llm/constellize.json` (D2), and the fact that `rewriteLlmPaths` rewrites
`memory-bank/` and `construction/` but **not** `features/`, so every prompt must write
`llm/features/` in full or the generated skill will point at a bare `features/`.

**F5 — found during execution, 2026-11-05: `generate:website` writes the v1-pinned prompt text, so
`generate:all` dirties the `website` repo whenever a prompt body changes.** This plan's A5 Step 5,
B2 Step 2 and C8 Step 7 all expect `git status` in `website` to show nothing but the pre-existing
untracked `.mp4` after `npm run generate:all`. That expectation is wrong, and Task A5 proved it:
`generate:all` chains `generate:website`, and `generate-website.ts:20` hardcodes
`DEFAULT_PROMPT_VERSION = 'v1'`, writing every prompt's text to
`website/public/prompts/v1/<id>/prompt.txt`. Its own comment at `:19` says why the directory is
versioned — "The book links to /prompts/v1/<id>, so v1 must keep resolving" — but the version is
a constant, not a function of the content, so running the generator from `main` overwrites the
v1 line's published prompt text with 2.0 content. After Release A's twelve verdict sections, the
run left **12 modified files** under `public/prompts/v1/`, `16 0` each.

This is the same hazard class as §5a's `generate-book.ts`: an unguarded generator writing into a
sibling repository that this project is forbidden to change. Nothing was committed, and the twelve
files were restored (`git checkout -- public/prompts/v1`), leaving `website` at `11a16f1` =
`origin/main` with only the untracked `.mp4`.

**Resolution — the procedure, not the criterion.** Acceptance 13 as narrowed is unaffected and was
verified the way it is written: with the factory archived at the website's own unchanged
`GENERATED_FROM` (`0d97085`), `check-drift --target website --against ../website` reports
*"No drift: 87 generated website files match"*. The website's CI guard checks out prompt-factory at
that commit, so the committed website remains consistent with the line it is generated from. What
changes is the three steps' expectation: after `npm run generate:all`, the website check is

1. the only modified paths are under `public/prompts/v1/` — **nothing** under `public/personas/` and
   nothing under `src/`, either of which would be a real finding;
2. restore them (`git -C ../website checkout -- public/prompts/v1`);
3. confirm `git -C ../website status --short` shows only the untracked `.mp4`; and
4. confirm the drift guard above is still green against `0d97085`.

`website` is therefore a repo that `generate:all` dirties and that must be restored, exactly as
`marketplace` is in Tasks A1, C3, C4 and C6 — and unlike `book`, where a dirty tree is a stop
condition because its output genuinely does not change.

**F6 — found during execution, 2026-11-05: the assessor command in Task C2 Step 3 does not take a
positional root, so as written it assesses the wrong directory and reports success.** Task C2 Step 3
(this plan, line 1250) says to run `node content/literal/constellize-harness/scripts/assess.mjs
<scratch-root>`. The assessor does not parse a positional argument: `assess.ts:233-238` reads
`process.argv.slice(2)`, takes the root from `--root <path>` and otherwise falls back to
`process.cwd()`. A positional path is silently ignored, so the command as written assesses
`prompt-factory` itself — which has no `llm/features/` — and prints a perfectly well-formed report
about the wrong project. Nothing errors, which is what makes it worth recording: the step would
have been marked passed on output that never looked at the fixture.

**Resolution — the command, not the step.** The fixture and the expectation are right; only the
invocation is wrong. The correct form is

```
node content/literal/constellize-harness/scripts/assess.mjs --format json --root <scratch-root>
```

Task C2's implementer found this and used the correct form, so the step was verified against the
fixture it names. This is the only occurrence in the plan — checked across every task brief — so no
other step inherits it. Whoever re-runs C2 Step 3 should use the form above; a `--root`-less run
that reports no features is reporting on `prompt-factory`, not on the fixture.

**F7 — found during execution, 2026-11-05: Task C4's shared test table asserts against three prompts
when only one of them exists at that point, so the suite cannot be green when C4 commits.** C4 Step 1
opens the shared table with `const FEATURE_IDS = ['specify-feature', 'implement-feature',
'verify-feature']` and runs a seven-test `describe.each` over it, and C4 Step 2 states the expected
failure as "none of the three prompts exists". But C4 Step 3 creates only
`content/prompts/feature/specify-feature.md`. Tasks C5 and C6 create the other two. So as written,
the shared table leaves fourteen tests failing when C4 commits and seven still failing when C5
commits, going green only at C6 — while this plan's method requires each task to commit with a green
suite, and each task's review asserts one.

**Resolution — the seeding, not the table.** The shared table is the right design: these seven
properties are identical for all three prompts and should be asserted once. It is simply built up
across the three tasks rather than written whole in the first. `FEATURE_IDS` is seeded with
`['specify-feature']` in C4, and **C5 and C6 each append their own id** when they create their
prompt, so every task commits green and the table covers all three by the end of C6. C4 carries a
comment to that effect so the next implementer sees the intent. Nothing about the seven assertions
changes.

This is the same class as F6: a brief instruction that is wrong in a way that produces a confident
wrong result rather than an error — here, a task that looks complete while leaving a red suite that
the next two tasks would be expected to inherit and explain away.

**F8 — found during execution, 2026-11-05: Task C4's Interfaces paragraph puts the constellation map
in `specify`, where §6.1 does not have it and where it would duplicate a marketplace capability.**
C4's Interfaces paragraph says the artifact carries "`## Constellation Map`, `## Gap Analysis` and
`## Implementation Sketch` sections written by the delegated design skills". But §6.1's normative map
for `specify` has no constellation-map phase, and §6.2's map for `implement` opens with exactly that
phase: *"Identify stars (reference implementations) | `constellize-design:constellation-map`,
feature-scoped"*. The constellation map belongs to `implement`, which is also why B1 gave
`constellation-map` an `output_path` slot.

C4's implementer found the contradiction and resolved it by having the `specify` skill write the
section itself. That resolution is wrong three times over: it adds a row to a table the brief calls
normative; it duplicates a capability the marketplace already has, which is an anti-goal whose own
illustration is this shape ("if `specify` writes its own adversarial questions instead of calling
`requirements-analysts`, the project has produced a fourth convention"); and it puts two writers on
one section, since `implement` delegates `constellation-map` into the same artifact — the precise
collision §6.6b exists to prevent.

**Resolution — §6.1 stands; the Interfaces paragraph is wrong.** `specify` writes no
`## Constellation Map`. The artifact at SPECIFIED carries `## Gap Analysis` and
`## Implementation Sketch` only, and `implement` creates the constellation map. The concern that
`gap-analysis` needs the sibling section is already answered by the rule B1 put in that prompt and
which is verified present in `content/prompts/03-architecture/gap-analysis.md`: *"when that section
is absent it says so and proceeds with the context the caller supplied inline."* The absent-sibling
path is designed for exactly this moment, so `specify` supplies its feature-scoped context to
`gap-analysis` inline instead.

**Check C5 and C6 for the same wording.** The Interfaces paragraphs were written together and may
carry the same claim; C5's own map legitimately includes the constellation map, so the error does not
simply repeat.

**F9 — found during execution, 2026-11-05: Task C6 Steps 5 and 6 run the generator into the live
marketplace checkout and then reset that checkout's whole working tree.** Step 5 is
`npm run generate:marketplace && ls ../marketplace/plugins/constellize-feature/skills/`, and Step 6
restores it with `git -C ../marketplace checkout -- . && git -C ../marketplace clean -fd plugins`.

Three things are wrong with that pair. `git checkout -- .` is not scoped to what the generator
wrote: it discards every uncommitted change in that repository, so any work in progress there at
that moment is destroyed with no recovery. The checkout is shared and live, which means "the tree
was clean when I looked" is not a fact that survives the minutes between the look and the reset.
And a destructive restore is only needed because the check was aimed at the live tree in the first
place: `generate(outputDir)` is exported at `build/generate-marketplace.ts:377` and the module's
own entry point is gated behind `require.main === module` at `:426`, so the generator runs against
any directory given to it.

**Resolution — Steps 5 and 6 are replaced by one step that generates into a scratch directory.**
Call the exported `generate()` with a path under the session's scratch directory and list
`<scratch>/plugins/constellize-feature/skills/`. That verifies exactly what Step 5 set out to
verify, which is that `deriveShortSkillName` turns the three prompt ids into `specify`, `implement`
and `verify`, and it leaves no restore to perform: nothing is written outside the scratch
directory, and no sibling repository is touched. The release task is where generated output
legitimately lands in the marketplace tree, under that task's own commits.

**F10 — found during execution, 2026-11-05: Task C8 Step 5 proves the book is untouched by running
a writer into it.** The step is `npm run generate:all && git -C ../book status --short`, expecting
empty. `generate:all` is `generate:website && generate:marketplace && generate:book`, and
`generate:book` writes the ten tracked files under `book/generated/`. So the check establishes that
the book is unchanged by rewriting it and then looking for a diff: when the answer is the expected
one the write was redundant, and when it is not, the step has already modified ten tracked files in
a manuscript the publisher has signed off on with a typesetting round in flight. That is the one
unguarded writer into the manuscript, used here as an instrument.

The step does not need it. Its own second half is the stronger check and writes nothing into
`book/`: `git archive` the factory into a scratch sibling outside the five repos, run
`generate-book.ts` there, and `diff -rq` its output against the committed `book/generated/`. The
brief says so itself — *"the first check catches an accidental write; the second catches one made
silently before the check."* A check that catches the silent case catches the accidental one too,
because both are a difference between what the current factory generates and what the book has
committed, which is exactly what the `diff -rq` compares.

**Resolution — Step 5 keeps the scratch-sibling generation and the `diff -rq`, and drops the
`npm run generate:all`.** `git -C ../book status --short` is still run and still expected to be
empty, but as an observation of a checkout nothing has written to rather than as the readout of a
write. Acceptance 17 is met by the comparison, not by the rewrite.

**F11 — found during execution, 2026-11-05: `specify` and `implement` both delegate `gap-analysis`
into the same artifact, and nothing says what becomes of the first result.** §6.1 gives `specify` a
phase *"What exists that can be reused, and what is missing | `constellize-design:gap-analysis`,
feature-scoped, output path set to the feature's own artifact"*, and §6.2 gives `implement` a phase
*"Gap, then plan | `constellize-design:gap-analysis` → `:implementation-sketch` →
`:code-generation-plan`"*. Both write `## Gap Analysis` into `llm/features/<name>.md`. §6.6b
settles the collision between a feature-scoped run and the project-level path; it does not settle
this one, between two feature-scoped runs into the same section of the same file. The same holds
for `## Implementation Sketch`, which both phases also delegate.

C5's implementer found this and raised it rather than quietly picking a side, which is the correct
handling.

**Resolution — the later run replaces the section in place, and the prompt says so.** Three things
settle it. Preserving both results would require `implement` to intercept what the delegated skill
produced and rewrite its heading, which is exactly r2's capture mode — *"asking those skills to do
something their own prose does not describe"* — and r3 rejected it by name in §6.6b; reintroducing
it for a history record would undo that decision for a much smaller reason than the one it was made
for. The artifact is a living state document whose whole structure is a status moving
SPECIFIED → IMPLEMENTED → VERIFIED, not an audit log. And the design already has somewhere for
history: the final phase of both §6.1 and §6.2 delegates `constellize-memory:update`.

The implementation-time analysis is also the better of the two, because §6.2 runs it *after* the
constellation map that §6.1 had no access to — so what is replaced is a less-informed answer to the
same question. What the design does require is that the supersession be stated rather than silent,
and `content/prompts/feature/implement-feature.md:76` states it: *"it supersedes whatever the
specification phase recorded there."*

---

# Release A — the four gates become assertions

Plugins touched: `constellize-craft` (8 verdicts + 1 new skill), `constellize-deliver` (4 verdicts).
Independently useful: after A, every gate skill returns a verdict, so a gate can fail even though
nothing yet collects the verdicts.

### Task A0: Prove the invocation tool names before anything depends on them

**Files:**
- Create: `/private/tmp/.../probe/` (scratch only — nothing committed)
- Read: `plugins/constellize-craft/skills/test-coverage/SKILL.md` (the installed shape)

**Interfaces:**
- Produces: the confirmed `allowed-tools` list for D1, used verbatim by Tasks C4, C5 and C6.

- [ ] **Step 1: Write a scratch skill declaring an unknown tool**

Create a throwaway local skill whose frontmatter is
`allowed-tools: Read, Glob, Grep, Write, Bash, Skill, Task, Agent, ThisToolDoesNotExist` and whose
body is one line of prose.

- [ ] **Step 2: Invoke it and record what happens**

Expected: the skill loads and runs, and the unknown name is inert. If instead it errors, record the
error verbatim.

- [ ] **Step 3: Record the decision**

If unknown names are inert, D1's list stands as `Read, Glob, Grep, Write, Bash, Skill, Task, Agent`.
If they are fatal, narrow to `Read, Glob, Grep, Write, Bash, Skill, Task` and note that a harness
exposing the subagent tool as `Agent` falls back to advisory — which §6.6a already permits and
acceptance 8 already tests. Write the outcome into this plan's D1 row before continuing.

- [ ] **Step 4: Delete the scratch skill**

Nothing from this task is committed.

---

### Task A1: `constellize-craft:defensive-programming`, the new always-run Gate 2 skill

**Files:**
- Create: `prompt-factory/content/prompts/04-quality/implement-defensive-programming.md`
- Modify: `prompt-factory/content/schemas/plugins.json` (add `implement-defensive-programming` to
  `constellize:craft`'s `skills.include`; bump its `version` to `1.1.0`)
- Test: `prompt-factory/build/__tests__/feature-prompts.test.ts` (created here, extended by C4–C6)

**Interfaces:**
- Produces: skill `constellize-craft:defensive-programming`, generated at
  `plugins/constellize-craft/skills/defensive-programming/SKILL.md`. Called by
  `constellize-feature:verify` as Gate 2's always-run member (Task C6).
- Consumes: nothing.

The skill is the course's Gate 2 subject, made language-neutral. The course named `except:` because
crew is Python; this names no language.

- [ ] **Step 1: Write the failing test**

In `build/__tests__/feature-prompts.test.ts`:

```ts
import { loadPrompts, loadPluginsConfig, getPromptsForPlugin } from '../lib/parser';

const prompts = loadPrompts('content');
const config = loadPluginsConfig('content');
const byId = (id: string) => prompts.find(p => p.frontmatter.id === id);

describe('defensive-programming', () => {
  it('exists and is a member of constellize:craft', () => {
    expect(byId('implement-defensive-programming')).toBeDefined();
    const craft = getPromptsForPlugin(prompts, 'constellize:craft', config.plugins);
    expect(craft.map(p => p.frontmatter.id)).toContain('implement-defensive-programming');
  });

  it('carries no outputs.book block, so it can never become a book output', () => {
    expect(byId('implement-defensive-programming')!.frontmatter.outputs?.book).toBeUndefined();
  });

  it('names no language or tool', () => {
    const body = byId('implement-defensive-programming')!.content;
    for (const banned of [/\bexcept:/, /\bpytest\b/, /\bruff\b/, /\buv run\b/, /\bnpm\b/, /\bPython\b/i, /\btry\s*\{/]) {
      expect(body).not.toMatch(banned);
    }
  });

  it('asserts a verdict', () => {
    const body = byId('implement-defensive-programming')!.content;
    expect(body).toContain('**Gate Status:** ✅ PASS / ❌ FAIL');
    expect(body).toMatch(/FAIL the gate/);
  });
});
```

- [ ] **Step 2: Run it and watch it fail**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: FAIL — `byId('implement-defensive-programming')` is `undefined`.

- [ ] **Step 3: Write the prompt**

Create `content/prompts/04-quality/implement-defensive-programming.md`, following the shape every
quality prompt in that directory uses: frontmatter, then `<task>`, `<context>`, `<thinking>`,
`<output-format>`, `<instructions>`, `<examples>`.

Frontmatter, exactly:

```yaml
id: implement-defensive-programming
name: "Implement defensive programming: validate every input, surface every failure"
version: v1
chapter: 4
category: quality
subcategory: gate-2
skill:
  description: >
    Review and harden a change's defensive programming: every external input validated,
    no swallowed failures, actionable error messages, graceful degradation.
    After implementation, before verification (Gate 2: Health Check Completeness).
  argument-hint: "[component_name] [system_name]"
  allowed-tools: [Read, Glob, Grep, Write, Bash]
  model: sonnet
  context: inline
outputs:
  website:
    include: false
  marketplace:
    plugin: constellize:craft
```

No `outputs.book` block (Global Constraints; §5a). `outputs.website.include: false` keeps the
website out of 2.0 (decision 26) — supported at `generate-website.ts:39`. Note that
`outputs.marketplace.plugin` is **decorative**: membership comes from `plugins.json`'s
`skills.include` and nothing reads that field (verified — `content/prompts/meta/`'s three prompts
name a plugin `constellize-internal` that does not exist, and nothing breaks). Set it for
consistency; the `plugins.json` entry in Step 5 is what actually does the work.

The body's `<output-format>` ends with the verdict section, using the shared template from Task A2
Step 3 with gate `2`, name `Health Check Completeness`, and these requirements:

```
- [ ] Every external input the change accepts is validated before use
- [ ] No failure is swallowed: no empty catch-all handler, no ignored error return
- [ ] Every error a user can see names what failed and what to do next
- [ ] Bad input degrades gracefully: no crash, and no internal trace reaches the user
- [ ] Each validation and each error path has a test
- [ ] Defensive code that cannot be triggered is marked with a justification, not left unmarked
```

- [ ] **Step 4: Run the test for the three content assertions**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: the `outputs.book`, language and verdict tests PASS; the membership test still FAILs.

- [ ] **Step 5: Add it to `constellize:craft` and bump the plugin**

In `content/schemas/plugins.json`, append `"implement-defensive-programming"` to
`constellize:craft`'s `skills.include`, and change that plugin's `"version"` from `"1.0.0"` to
`"1.1.0"`.

- [ ] **Step 6: Run the full test file**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: PASS, 4 tests.

- [ ] **Step 7: Confirm the generator emits it and nothing else moved**

Run: `npm run generate:marketplace && git -C ../marketplace status --short`
Expected: exactly two paths — `plugins/constellize-craft/skills/defensive-programming/SKILL.md` as
untracked, and `plugins/constellize-craft/.claude-plugin/plugin.json` as modified.

- [ ] **Step 8: Restore the marketplace working tree**

Run: `git -C ../marketplace checkout -- . && git -C ../marketplace clean -fd plugins`
Expected: `git -C ../marketplace status --short` is empty. The marketplace is only ever written by
the release task.

- [ ] **Step 9: Commit (prompt-factory only)**

```bash
git -C prompt-factory add content/prompts/04-quality/implement-defensive-programming.md content/schemas/plugins.json build/__tests__/feature-prompts.test.ts
git -C prompt-factory commit -m "feat(craft): add defensive-programming, the always-run Gate 2 check"
```

---

### Task A2: Gate 2 verdict sections — the four operational craft skills

**Files:**
- Modify: `prompt-factory/content/prompts/*/implement-application-health-validation.md`
- Modify: `prompt-factory/content/prompts/*/implement-infrastructure-health-checks.md`
- Modify: `prompt-factory/content/prompts/*/implement-operational-monitoring.md`
- Modify: `prompt-factory/content/prompts/*/implement-actionable-health-reporting.md`
- Test: `prompt-factory/build/__tests__/gate-verdicts.test.ts` (created here)

**Interfaces:**
- Produces: a `## Gate 2: Health Check Completeness Status` section in each of the four generated
  `SKILL.md`, each ending `**Gate Status:** ✅ PASS / ❌ FAIL`. Read by `constellize-feature:verify`
  (Task C6).
- Consumes: nothing.

Every edit is **additive**. Nothing existing is removed or reworded — acceptance 4 checks this
mechanically. There are exactly two insertion points per file: immediately before
`</output-format>`, and immediately before `</instructions>`.

- [ ] **Step 1: Write the failing test**

In `build/__tests__/gate-verdicts.test.ts`:

```ts
import { loadPrompts } from '../lib/parser';

const GATES: Record<string, [number, string]> = {
  'implement-application-health-validation': [2, 'Health Check Completeness'],
  'implement-infrastructure-health-checks': [2, 'Health Check Completeness'],
  'implement-operational-monitoring': [2, 'Health Check Completeness'],
  'implement-actionable-health-reporting': [2, 'Health Check Completeness'],
  'externalize-configuration': [3, 'Deployment Readiness'],
  'achieve-environment-independence': [3, 'Deployment Readiness'],
  'build-reliable-containers': [3, 'Deployment Readiness'],
  'implement-rollback-capability': [3, 'Deployment Readiness'],
  'ensure-architectural-consistency': [4, 'Maintainability in Context'],
  'maintain-dependency-hygiene': [4, 'Maintainability in Context'],
  'achieve-documentation-completeness': [4, 'Maintainability in Context'],
  'ensure-team-comprehension': [4, 'Maintainability in Context'],
};

const prompts = loadPrompts('content');
const body = (id: string) => prompts.find(p => p.frontmatter.id === id)!.content;

describe.each(Object.entries(GATES))('%s', (id, [gate, name]) => {
  it('declares its gate heading', () => {
    expect(body(id)).toContain(`## Gate ${gate}: ${name} Status`);
  });
  it('asserts a verdict inside output-format', () => {
    const of = body(id).match(/<output-format>([\s\S]*?)<\/output-format>/)![1];
    expect(of).toContain('**Gate Status:** ✅ PASS / ❌ FAIL');
    expect(of).toContain('**Blockers:**');
  });
  it('instructs a FAIL', () => {
    const ins = body(id).match(/<instructions>([\s\S]*?)<\/instructions>/)![1];
    expect(ins).toMatch(/FAIL the gate/);
  });
  it('has at least four requirement checkboxes in its verdict section', () => {
    const section = body(id).split(`## Gate ${gate}: ${name} Status`)[1];
    expect((section.match(/^- \[ \] /gm) || []).length).toBeGreaterThanOrEqual(4);
  });
  it('names no language or tool in the verdict section', () => {
    const section = body(id).split(`## Gate ${gate}: ${name} Status`)[1].split('**Blockers:**')[0];
    for (const banned of [/\bpytest\b/, /\bruff\b/, /\buv\b/, /\bnpm\b/, /\bdocker\b/i, /\bkubectl\b/, /\bPython\b/i]) {
      expect(section).not.toMatch(banned);
    }
  });
});
```

This file covers all 12 skills, so Tasks A3 and A4 add no new test file — they make more of this one
pass.

- [ ] **Step 2: Run it and watch all 12 fail**

Run: `npx jest build/__tests__/gate-verdicts.test.ts`
Expected: FAIL — 12 describe blocks, every one missing its gate heading.

- [ ] **Step 3: Fix the verdict-section template, once**

This exact shape, copied from `test-coverage/SKILL.md:169-182`, is used by all 12 and by A1. Insert
it immediately before `</output-format>`:

```
## Gate <N>: <Gate Name> Status

### Requirements
<the skill's requirement checkboxes>

**Gate Status:** ✅ PASS / ❌ FAIL

**Blockers:** [List any failing requirements]
```

And insert these three lines immediately before `</instructions>`:

```
- FAIL the gate if any requirement above is unmet
- NEVER report PASS with an unmet requirement — "close enough" is a FAIL
- ALWAYS report the verdict, even when this skill was run outside a feature verification
```

`test-coverage` also carries its verdict inside its two worked examples. The 12 do not copy that:
`verify` reads the skill's **output**, which `<output-format>` governs, and editing an example is a
larger, riskier diff for no behavioural gain. Recorded so the omission is a decision, not an
oversight.

- [ ] **Step 4: Add the four Gate 2 verdict sections**

`implement-application-health-validation`:

```
- [ ] Every configuration value the change reads is validated at startup, with a named failure
- [ ] The environment the change requires is checked before first use, not on first request
- [ ] Each business rule the specification states has a validation with a distinct error
- [ ] A validation failure stops startup rather than degrading silently
- [ ] The validation reports what it checked and the outcome
```

`implement-infrastructure-health-checks`:

```
- [ ] Every external dependency the change introduced has a health check
- [ ] Each check has a bounded timeout and cannot hang its caller
- [ ] Each check distinguishes healthy from degraded from unavailable
- [ ] Checks are read-only and safe to call repeatedly
- [ ] Any dependency deliberately left without a check is listed with the reason
```

`implement-operational-monitoring`:

```
- [ ] Each operation the change adds emits a success or failure signal
- [ ] At least one signal expresses the change's business outcome, not only its mechanics
- [ ] Resource use the change introduces is observable
- [ ] Signals carry enough context to attribute a failure to this change
- [ ] No signal records a secret or personal data
```

`implement-actionable-health-reporting`:

```
- [ ] Every unhealthy state the change can reach names the component and the next action
- [ ] Each reported threshold states its value and its unit
- [ ] The report maps a failure to the dependency that caused it
- [ ] A reader who did not write the change can act on the report without reading the code
- [ ] Health output distinguishes healthy, degraded and unhealthy rather than a single boolean
```

- [ ] **Step 5: Run the test and confirm the four Gate 2 blocks pass**

Run: `npx jest build/__tests__/gate-verdicts.test.ts -t 'health'`
Expected: PASS for the four Gate 2 skills.

- [ ] **Step 6: Prove the diff is additive**

Run: `git -C prompt-factory diff --numstat content/prompts/`
Expected: every line is `<added> 0 <path>` — zero deletions in all four files. A non-zero deletion
count means something was removed or reworded, which acceptance 4 forbids.

- [ ] **Step 7: Commit**

```bash
git -C prompt-factory add content/prompts build/__tests__/gate-verdicts.test.ts
git -C prompt-factory commit -m "feat(craft): Gate 2 skills assert a verdict"
```

---

### Task A3: Gate 3 verdict sections — the four deliver skills

**Files:**
- Modify: `prompt-factory/content/prompts/*/externalize-configuration.md`
- Modify: `prompt-factory/content/prompts/*/achieve-environment-independence.md`
- Modify: `prompt-factory/content/prompts/*/build-reliable-containers.md`
- Modify: `prompt-factory/content/prompts/*/implement-rollback-capability.md`
- Modify: `prompt-factory/content/schemas/plugins.json` (`constellize:deliver` `1.0.0` → `1.1.0`)
- Test: `prompt-factory/build/__tests__/gate-verdicts.test.ts` (already written in A2)

**Interfaces:**
- Produces: a `## Gate 3: Deployment Readiness Status` section in each of the four generated
  `SKILL.md`. Read by `constellize-feature:verify` (Task C6) when the deployment surface was touched.
- Consumes: the template from Task A2 Step 3.

- [ ] **Step 1: Confirm the Gate 3 tests fail**

Run: `npx jest build/__tests__/gate-verdicts.test.ts -t 'config'`
Expected: FAIL — `externalize-configuration` has no gate heading.

- [ ] **Step 2: Add the four Gate 3 verdict sections**

`externalize-configuration`:

```
- [ ] No value the change added that differs between environments is hardcoded
- [ ] No secret appears in source, in a committed file, or in a log line
- [ ] Every new configuration value has a documented name, type and default, or is marked required
- [ ] A missing required value fails at startup, naming the value
- [ ] Defaults are safe for the least-privileged environment
```

`achieve-environment-independence`:

```
- [ ] The change assumes no absolute path, hostname or user account on the host
- [ ] A clean checkout installs and runs the change with no manual step in between
- [ ] Behaviour does not depend on state left by a previous run
- [ ] Every environment-specific value arrives as configuration
- [ ] The install-and-run command the project declares succeeds from a clean state
```

`build-reliable-containers`:

```
- [ ] If the change altered the runtime image, the image builds reproducibly from the committed definition
- [ ] The process exits non-zero on a fatal error and handles a termination signal
- [ ] The change needs no write access outside the paths it declares
- [ ] A readiness signal distinguishes started from able to serve
- [ ] If the change altered no image, that is stated with the reason
```

`implement-rollback-capability`:

```
- [ ] The change can be reverted without a manual data repair
- [ ] Any state migration the change introduced is reversible, or its forward-only nature is stated with the reason
- [ ] The previous version can still run against the state this version writes
- [ ] The rollback procedure is written down, naming the command and the check that it worked
- [ ] The rollback was exercised, not asserted
```

- [ ] **Step 3: Run the Gate 3 tests**

Run: `npx jest build/__tests__/gate-verdicts.test.ts -t 'Deployment'`
Expected: PASS for all four. (If the `-t` filter does not match the describe titles, run the whole
file and read the four Gate 3 blocks.)

- [ ] **Step 4: Bump `constellize:deliver`**

In `content/schemas/plugins.json`, change `constellize:deliver`'s `"version"` from `"1.0.0"` to
`"1.1.0"`.

- [ ] **Step 5: Prove the diff is additive**

Run: `git -C prompt-factory diff --numstat content/prompts/`
Expected: zero deletions in all four prompt files.

- [ ] **Step 6: Commit**

```bash
git -C prompt-factory add content/prompts content/schemas/plugins.json
git -C prompt-factory commit -m "feat(deliver): Gate 3 skills assert a verdict"
```

---

### Task A4: Gate 4 verdict sections — the four maintainability craft skills

**Files:**
- Modify: `prompt-factory/content/prompts/*/ensure-architectural-consistency.md`
- Modify: `prompt-factory/content/prompts/*/maintain-dependency-hygiene.md`
- Modify: `prompt-factory/content/prompts/*/achieve-documentation-completeness.md`
- Modify: `prompt-factory/content/prompts/*/ensure-team-comprehension.md`
- Test: `prompt-factory/build/__tests__/gate-verdicts.test.ts` (already written in A2)

**Interfaces:**
- Produces: a `## Gate 4: Maintainability in Context Status` section in each of the four generated
  `SKILL.md`. `architectural-consistency` and `dependency-hygiene` are read by
  `constellize-feature:verify` (Task C6); `documentation-completeness` and `team-comprehension` are
  **not called by `verify`** (decision 20) but gain verdicts so a project-level gate run can use them.
- Consumes: the template from Task A2 Step 3.

- [ ] **Step 1: Confirm the Gate 4 tests fail**

Run: `npx jest build/__tests__/gate-verdicts.test.ts`
Expected: the four Gate 4 describe blocks FAIL; A2's and A3's pass.

- [ ] **Step 2: Add the four Gate 4 verdict sections**

`ensure-architectural-consistency`:

```
- [ ] The change follows the patterns recorded in the memory bank, or records a deliberate departure with its reason
- [ ] Names and structure match the reference implementations the change was built from
- [ ] No new convention is introduced where an existing one covers the need
- [ ] Boundaries the project already draws are not crossed
- [ ] Any new abstraction has more than one call site, or a recorded reason for having one
```

`maintain-dependency-hygiene`:

```
- [ ] Every dependency the change added is justified in writing
- [ ] No added dependency duplicates a capability already present
- [ ] Each added dependency is pinned the way this project pins dependencies
- [ ] Each added dependency was checked for known vulnerabilities, and the check is named
- [ ] No dependency was added for something the platform's own library already does
```

`achieve-documentation-completeness` — scoped to the change, which is what lets a project-scope
skill return a verdict at all (D6):

```
- [ ] The change leaves no documented behaviour describing something that no longer exists
- [ ] Every entry point the change added is documented where this project documents entry points
- [ ] The decisions a future reader would otherwise have to infer are written down
- [ ] Setup or configuration the change introduced is documented with the rest of the project's setup
- [ ] The documentation is reachable from the project's existing index, not only from the change
```

`ensure-team-comprehension` — likewise scoped to the change:

```
- [ ] A second engineer can explain what the change does from the code and its written record alone
- [ ] No part of the change depends on knowledge held only by its author
- [ ] The change uses this project's own vocabulary for the concepts it touches
- [ ] The change's most surprising decision is recorded where a maintainer will meet it
- [ ] Comprehensibility feedback from review was addressed, not deferred
```

- [ ] **Step 3: Run the whole test file**

Run: `npx jest build/__tests__/gate-verdicts.test.ts`
Expected: PASS — 12 skills × 5 assertions.

- [ ] **Step 4: Prove the diff is additive, across all 12**

Run: `git -C prompt-factory diff --numstat HEAD~2 -- content/prompts/`
Expected: 12 files, zero deletions in each. This is acceptance 4 for Release A.

- [ ] **Step 5: Commit**

```bash
git -C prompt-factory add content/prompts
git -C prompt-factory commit -m "feat(craft): Gate 4 skills assert a verdict"
```

---

### Task A5: Release A — regenerate, bump counts, rebuild the card, ship

**Files:**
- Modify: `prompt-factory/content/literal/marketplace-root/README.md` (`:8` counts, per-plugin table)
- Modify: `prompt-factory/content/literal/marketplace-docs/constellize-skills-infographic.html`
  (craft `20 skills` → `21 skills`, a `defensive-programming` chip, the `74` stat → `75`)
- Modify: `marketplace/GENERATED_FROM`
- Modify: all regenerated files under `marketplace/plugins/`, `marketplace/README.md`,
  `marketplace/docs/constellize-skills-infographic.html`

**Interfaces:**
- Consumes: Tasks A1–A4.
- Produces: marketplace `main` with 105 generated files, `constellize-craft` at `1.1.0` and
  `constellize-deliver` at `1.1.0`.

Release A's counts are an intermediate state: 75 skills across 6 plugins. Release C takes them to
78 across 7. Updating them twice is correct — each release must leave the generated surfaces
truthful, because they are drift-guarded.

- [ ] **Step 1: Update the two count-bearing literal files**

`README.md:8` becomes `- **75 Skills** across 6 plugins`, and craft's row in the per-plugin table
gains one. In the infographic, the `<div class="number">74</div>` stat becomes `75`, craft's
`<div class="plugin-count">20 skills</div>` becomes `21 skills`, and a
`<div class="skill">defensive-programming</div>` chip joins craft's Gate 2 section.

- [ ] **Step 2: Confirm the card still fits one page**

Run: `npm run build:card -- --line v2 --out /tmp/card-probe-v2.pdf`
Expected: success. The builder asserts exactly one page (`prompt-factory/scripts/build-reference-card.mjs:338`,
`if (pages !== 1)`) against `@page { size: 816px 1230px }`, so a chip that overflows fails here
rather than shipping a two-page card. If it fails, tighten the infographic's craft section — do not
raise the page size, and do not remove a chip.

- [ ] **Step 3: Regenerate and read the diff**

Run: `npm run generate:marketplace && git -C ../marketplace status --short`
Expected: one untracked file (`plugins/constellize-craft/skills/defensive-programming/SKILL.md`) and
modifications to the 12 edited `SKILL.md`, both changed `plugin.json`s,
`.claude-plugin/marketplace.json` is **unchanged** (the catalog carries no version), `README.md` and
`docs/constellize-skills-infographic.html`.

- [ ] **Step 4: Confirm the book is untouched — the acceptance-17 check, run early**

Run: `npm run generate:all && git -C ../book status --short`
Expected: empty. `generate:all` chains `generate:website && generate:marketplace && generate:book`,
and `generate:book` is the one factory writer into the `book` repo
(`generate-book.ts` → `../book/generated/`, ten tracked files, no drift target, never run in CI).
If this prints anything at all, **stop** and revert the book repo before doing anything else.

- [ ] **Step 5: Confirm the website is untouched too**

Run: `git -C ../website status --short`
Expected: only the pre-existing untracked `public/The_Constellize_Method.mp4`. `generate:website`
ran in Step 4; `defensive-programming` carries `outputs.website.include: false`, so
`generate-website.ts:39` emits no page for it.

- [ ] **Step 6: Push prompt-factory first**

```bash
git -C prompt-factory push origin main
```

This has to precede the marketplace commit: `drift.yml` checks out
`constellize/prompt-factory` at the SHA in `GENERATED_FROM`, so that SHA must already be on GitHub.

- [ ] **Step 7: Commit the regenerated marketplace files, then `GENERATED_FROM` separately**

```bash
git -C marketplace add -A plugins README.md docs/constellize-skills-infographic.html
git -C marketplace commit -m "chore: regenerate — Gate 2-4 verdicts, defensive-programming"
git -C prompt-factory rev-parse main > marketplace/GENERATED_FROM
git -C marketplace commit -m "chore: point GENERATED_FROM at the verdicts release" GENERATED_FROM
```

Two commits, per `docs/releasing-1x.md:30`.

- [ ] **Step 8: Verify the drift guard locally before pushing**

Run: `npm run check:drift -- --target marketplace --against ../marketplace`
Expected: no drift. 105 generated files.

- [ ] **Step 9: Verify the version-bump guard locally**

Run: `cd marketplace && .github/scripts/check-version-bump.sh origin/main`
Expected: `OK: constellize-craft 1.0.0 -> 1.1.0`, `OK: constellize-deliver 1.0.0 -> 1.1.0`,
`OK: version-bump check passed`.

- [ ] **Step 10: Ask Steve, then push**

Push `marketplace` `main` only after Steve says so. Then confirm the drift workflow is green.

- [ ] **Step 11: Confirm `v1` is still frozen**

Run:
```bash
git -C prompt-factory rev-parse v1 origin/v1; git -C marketplace rev-parse v1 origin/v1
```
Expected: `69dffee…` four times for prompt-factory's pair and `8f470b2…` for the marketplace's.

---

# Release B — the three design skills take an output path

Plugin touched: `constellize-design`. Independently useful and behaviour-preserving: invoked without
the new argument, each skill writes exactly the path and bytes it writes today (acceptance 5).

### Task B1: An optional output path on `gap-analysis`, `implementation-sketch`, `constellation-map`

**Files:**
- Modify: `prompt-factory/content/prompts/03-architecture/gap-analysis.md`
- Modify: `prompt-factory/content/prompts/03-architecture/implementation-sketch.md`
- Modify: `prompt-factory/content/prompts/03-architecture/constellation-map.md`
- Modify: `prompt-factory/content/schemas/plugins.json` (`constellize:design` `1.0.0` → `1.1.0`)
- Test: `prompt-factory/build/__tests__/design-output-path.test.ts` (created here)

**Interfaces:**
- Produces: each of the three skills accepts a final optional argument `output_path`. Used by
  `constellize-feature:specify` and `:implement` (Tasks C4, C5), which pass
  `llm/features/<feature-name>.md`.
- Consumes: nothing.

The semantics are one rule, and they cover reading as well as writing — which is Finding F4:

> `output_path` is a markdown **file**. When it is given, the skill owns the one section in that file
> titled with its own artifact heading, replaces that section in place and leaves the rest of the
> file untouched; it resolves each prerequisite artifact from a sibling section of the same file, and
> when a prerequisite section is absent it says so and proceeds with the context the caller supplied
> inline. When `output_path` is absent, every path is exactly what it is today. **The skill never
> creates a project-level file it was not asked for**, and never scaffolds `llm/construction/`.

Section headings, fixed so the three feature skills and the three design skills agree:
`## Constellation Map`, `## Gap Analysis`, `## Implementation Sketch`.

Note while editing: paths in prompt source are written bare (`construction/requirements/…`) and
`rewriteLlmPaths` prefixes them with `llm/` at generation time. It rewrites `memory-bank/` and
`construction/` only — **not `features/`** — so the feature path must be written as
`llm/features/` in full wherever it appears.

- [ ] **Step 1: Write the failing test**

In `build/__tests__/design-output-path.test.ts`:

```ts
import { loadPrompts } from '../lib/parser';

const prompts = loadPrompts('content');
const get = (id: string) => prompts.find(p => p.frontmatter.id === id)!;

const SPECS: Array<[string, string, string]> = [
  ['constellation-map', 'construction/requirements/constellation-map.md', '## Constellation Map'],
  ['gap-analysis', 'construction/requirements/gap-analysis.md', '## Gap Analysis'],
  ['implementation-sketch', 'construction/design/implementation-sketches.md', '## Implementation Sketch'],
];

describe.each(SPECS)('%s', (id, defaultPath, heading) => {
  it('declares output_path as its last variable, mapped to an argument slot', () => {
    const vars = get(id).frontmatter.variables!;
    expect(vars[vars.length - 1].name).toBe('output_path');
    expect(vars[vars.length - 1]['maps-to']).toMatch(/^\$\d+$/);
  });
  it('mentions output_path in its argument hint', () => {
    expect(get(id).frontmatter.skill!['argument-hint']).toContain('output_path');
  });
  it('still names its default path, so an existing caller is unaffected', () => {
    expect(get(id).content).toContain(defaultPath);
  });
  it('names the section it owns and the rule that the rest of the file is untouched', () => {
    expect(get(id).content).toContain(heading);
    expect(get(id).content).toMatch(/leav\w* the rest of the file untouched/i);
  });
  it('never scaffolds a project-level file it was not asked for', () => {
    expect(get(id).content).toMatch(/never (create|scaffold)/i);
  });
});
```

- [ ] **Step 2: Run it and watch it fail**

Run: `npx jest build/__tests__/design-output-path.test.ts`
Expected: FAIL — `output_path` is not among any of the three skills' variables.

- [ ] **Step 3: Add the variable to each of the three prompts**

Append to each prompt's `variables:` list, taking the next free `maps-to` slot (`gap-analysis` and
`constellation-map` already use `$0`–`$1` and `$0`–`$2`; `implementation-sketch` uses `$0`):

```yaml
  - name: output_path
    description: >
      Optional. A markdown file to write this artifact into as a single owned section,
      instead of the default project-level path. Prerequisites are then read from
      sibling sections of the same file.
    example: "llm/features/rate-limiting.md"
    maps-to: "$N"
```

and extend `argument-hint` with ` [output_path]`.

- [ ] **Step 4: Add the output-path rule to each prompt's `<context>` block**

State the rule quoted above, verbatim in substance, next to the existing sentence that names the
default path. Do not delete or reword that sentence — acceptance 5 depends on the default surviving,
and acceptance 4's additive-diff discipline applies here too.

- [ ] **Step 5: Run the test**

Run: `npx jest build/__tests__/design-output-path.test.ts`
Expected: PASS — 3 skills × 5 assertions.

- [ ] **Step 6: Prove acceptance 5 — invoked without the argument, the bytes are unchanged**

The generated body changes (it now documents the argument), so the check is that the **default path
is still named and no path was replaced**:

Run:
```bash
git -C prompt-factory diff --numstat content/prompts/03-architecture/
grep -c "construction/requirements/gap-analysis.md" content/prompts/03-architecture/gap-analysis.md
```
Expected: zero deletions in all three files, and the default-path mentions still present at their
original count or higher.

- [ ] **Step 7: Bump `constellize:design`**

In `content/schemas/plugins.json`, change `constellize:design`'s `"version"` from `"1.0.0"` to
`"1.1.0"`.

- [ ] **Step 8: Commit**

```bash
git -C prompt-factory add content/prompts/03-architecture content/schemas/plugins.json build/__tests__/design-output-path.test.ts
git -C prompt-factory commit -m "feat(design): optional output path on the three artifact skills"
```

---

### Task B2: Release B — regenerate and ship

**Files:**
- Modify: `marketplace/GENERATED_FROM`, the three regenerated `SKILL.md`,
  `plugins/constellize-design/.claude-plugin/plugin.json`

**Interfaces:**
- Consumes: Task B1.
- Produces: marketplace `main` with `constellize-design` at `1.1.0`. No count changes — no skill was
  added.

- [ ] **Step 1: Regenerate and read the diff**

Run: `npm run generate:marketplace && git -C ../marketplace status --short`
Expected: exactly four modified files — the three design `SKILL.md` and
`constellize-design`'s `plugin.json`. `README.md` and the infographic are **unchanged**: no skill was
added, so no count moved.

- [ ] **Step 2: Confirm the book and website are untouched**

Run: `npm run generate:all && git -C ../book status --short && git -C ../website status --short`
Expected: `book` empty; `website` shows only the pre-existing untracked `.mp4`.

- [ ] **Step 3: Push prompt-factory, then commit and verify the marketplace**

```bash
git -C prompt-factory push origin main
git -C marketplace add -A plugins
git -C marketplace commit -m "chore: regenerate — design skills take an output path"
git -C prompt-factory rev-parse main > marketplace/GENERATED_FROM
git -C marketplace commit -m "chore: point GENERATED_FROM at the output-path release" GENERATED_FROM
npm run check:drift -- --target marketplace --against ../marketplace
cd marketplace && .github/scripts/check-version-bump.sh origin/main
```
Expected: no drift (105 files), and `OK: constellize-design 1.0.0 -> 1.1.0`.

- [ ] **Step 4: Ask Steve, then push, then re-verify `v1`**

Same as Task A5 Steps 10–11.

---

# Release C — the feature plugin, the assessor and the harness route

Plugins touched: `constellize-feature` (new), `constellize-harness` (bump). Depends on Releases A
and B: `verify` calls the 12 verdicts and `defensive-programming` (A), and `specify`/`implement`
pass the output path (B).

### Task C1: The assessor reads feature status and checks its evidence

**Files:**
- Modify: `prompt-factory/content/literal/constellize-harness/scripts/types.ts` (`FeaturesState`)
- Modify: `prompt-factory/content/literal/constellize-harness/scripts/tier1.ts:133-152`
  (`assessLlmArtifacts`'s features block)
- Create: `prompt-factory/build/__tests__/assessor-features.test.ts`

**Interfaces:**
- Produces:
  ```ts
  export type FeatureStatus =
    | "SPECIFIED" | "IMPLEMENTED" | "VERIFIED"
    | "VERIFIED (unsubstantiated)" | "unknown";

  export interface FeatureEntry {
    name: string;              // the artifact's basename without .md, or the directory name
    status: FeatureStatus;
    evidence: "complete" | "incomplete" | "malformed" | "absent";
    missingGates: number[];    // gates marked required with no verdict; [] otherwise
  }

  export interface FeaturesState {
    count: number;
    entries: string[];         // kept, and still the names — existing readers are unaffected
    features: FeatureEntry[];  // new
  }
  ```
  Consumed by `constellize-harness:assess`'s report (Task C2) and by `plan`/`orchestrate` (Task C7).
- Consumes: the gate-results schema written by `constellize-feature:verify` (Task C6).

The gate-results block, fixed here because the assessor and `verify` must agree (D4, and F3's
`required` flag):

````markdown
## Gate Results

```json
{
  "schema": 1,
  "feature": "rate-limiting",
  "verifiedAt": "2026-11-05T09:12:00Z",
  "threshold": { "source": "default", "branch": 80, "criticalLogic": 100, "errorPaths": 100, "integrationPoints": 100 },
  "surface": { "operational": true, "deployment": false, "reason": "adds a cache dependency; no deployment artifact changed" },
  "gates": [
    { "gate": 1, "name": "Test integrity", "required": true, "verdict": "PASS",
      "skill": "constellize-craft:test-coverage", "measured": "87% branch, 100% critical, 100% error paths",
      "threshold": "80/100/100/100", "source": "the project's declared test command", "at": "2026-11-05T09:06:00Z" },
    { "gate": 3, "name": "Deployment readiness", "required": false, "verdict": "SKIPPED",
      "skill": null, "measured": null, "threshold": null,
      "source": "surface determination", "at": "2026-11-05T09:11:00Z" }
  ]
}
```
````

`required` is `true` always for gate 1, gate 4, and gate 2's `defensive-programming` member, and
follows the surface determination for gate 2's four operational members and gate 3.

- [ ] **Step 1: Write the failing tests**

In `build/__tests__/assessor-features.test.ts`, importing from the literal tree (verified to work
under ts-jest: `import { assessLlmArtifacts } from '../../content/literal/constellize-harness/scripts/tier1';`).
Each test writes a scratch `llm/features/` into a temp directory and asserts on
`assessLlmArtifacts(root).features`.

```ts
it('reads each of the three statuses', () => { /* three artifacts → SPECIFIED, IMPLEMENTED, VERIFIED */ });
it('reports a VERIFIED artifact with a complete block as VERIFIED, evidence complete', () => {});
it('reports a VERIFIED artifact missing a required gate as "VERIFIED (unsubstantiated)"', () => {
  // gates: [{gate:1,required:true,verdict:'PASS'}] and no gate 4 → missingGates contains 4
});
it('reports a VERIFIED artifact with no gate-results block as "VERIFIED (unsubstantiated)", evidence absent', () => {});
// Review Focus 2
it('reports malformed JSON as "VERIFIED (unsubstantiated)", evidence malformed, and does not throw', () => {
  // '{ "schema": 1, "gates": [ ' — truncated
});
// Review Focus 3
it('ignores a status line inside a fenced code block and reads the real one', () => {
  // body: '**Status:** IMPLEMENTED' then a fence containing '**Status:** SPECIFIED'
});
it('reports status "unknown" when there is no status line outside a fence', () => {});
it('takes the first status line when an artifact carries two', () => {});
// Review Focus 4
it('reports a non-feature .md (a README with no status) as unknown rather than counting it silently', () => {});
it('still reports a pre-2.0 directory entry, so an existing project does not lose its count', () => {});
it('leaves entries[] as the names, unchanged in shape', () => {});
it('does not throw when llm/features/ is absent', () => {});
```

- [ ] **Step 2: Run them and watch them fail**

Run: `npx jest build/__tests__/assessor-features.test.ts`
Expected: FAIL — `features` is not a property of the returned object.

- [ ] **Step 3: Extend `FeaturesState` in `types.ts`**

Add `FeatureStatus`, `FeatureEntry` and the `features` property exactly as in the Interfaces block.
`count` and `entries` keep their meaning: `entries` is the list of names, so nothing reading it
today changes.

- [ ] **Step 4: Replace the features block in `tier1.ts:133-152`**

Glob `*.md` **and** keep the directory entries (§9b changes discovery from directories to files; a
pre-2.0 project with directories must not drop to a count of zero). For each `.md`:
read it, find the status with a regex anchored to the start of a line and applied only to the text
outside fenced blocks, extract the ```json block under `## Gate Results` with one match, and
`JSON.parse` it inside a `try`. Node built-ins only — no dependency (§5).

Two rules the tests pin: a `JSON.parse` failure yields `evidence: "malformed"` and never propagates;
and `status === "VERIFIED"` with `evidence !== "complete"` is reported as
`"VERIFIED (unsubstantiated)"`.

- [ ] **Step 5: Run the tests**

Run: `npx jest build/__tests__/assessor-features.test.ts`
Expected: PASS, 12 tests.

- [ ] **Step 6: Add the Review-Focus-1 threshold rule and its test**

A declared threshold looser than the default must be refused. The rule belongs to `verify` (Task C6)
but the *recorded* threshold is what the assessor sees, so pin it here too: add a test that a block
whose `threshold.source` is `"declared"` with `branch` below `80` is reported as
`"VERIFIED (unsubstantiated)"`, and implement that check alongside the missing-gate check.

Run: `npx jest build/__tests__/assessor-features.test.ts`
Expected: PASS, 13 tests.

- [ ] **Step 7: Confirm the test file is outside the literal tree**

Run: `ls prompt-factory/content/literal/constellize-harness/scripts/`
Expected: exactly `assess.mjs`, `assess.ts`, `types.ts`, `tier1.ts`, `tsconfig.json`. `copyLiteralTree`
copies **every** file under a literal source into the plugin, so a test file placed there would ship
to users and register as drift. Tests live in `build/__tests__/` only.

- [ ] **Step 8: Commit**

```bash
git -C prompt-factory add content/literal/constellize-harness/scripts build/__tests__/assessor-features.test.ts
git -C prompt-factory commit -m "feat(harness): the assessor reads feature status and checks its evidence"
```

---

### Task C2: `constellize-harness:assess` reports what the assessor now knows

**Files:**
- Modify: `prompt-factory/content/literal/constellize-harness/skills/assess/SKILL.md`
- Modify: `prompt-factory/content/literal/constellize-harness/scripts/assess.ts` (the report shape,
  if the profile is rendered there rather than in the skill)

**Interfaces:**
- Consumes: `FeaturesState.features` from Task C1.
- Produces: the feature table acceptance 11 checks.

- [ ] **Step 1: Read how `assess` renders the profile today**

Read `skills/assess/SKILL.md` and `scripts/assess.ts` and find where `features` reaches the user
(today: a count and a list of names).

- [ ] **Step 2: Add the per-feature report**

A feature's name, status and evidence, one row each, with `VERIFIED (unsubstantiated)` called out
and the missing gate numbers named. A malformed artifact is reported as malformed, not omitted.

- [ ] **Step 3: Verify against the acceptance-11 fixture**

Build a scratch project whose `llm/features/` holds one SPECIFIED, one IMPLEMENTED, one substantiated
VERIFIED, one unsubstantiated VERIFIED and one malformed file, run the assessor, and confirm all five
are reported correctly.

Run: `node content/literal/constellize-harness/scripts/assess.mjs <scratch-root>`
Expected: five features, each with the right status and evidence.

- [ ] **Step 4: Commit**

```bash
git -C prompt-factory add content/literal/constellize-harness
git -C prompt-factory commit -m "feat(harness): assess reports each feature's status and evidence"
```

---

### Task C3: The plugin, its name derivation, and `llm/constellize.json`

**Files:**
- Modify: `prompt-factory/build/generate-marketplace.ts` (export `deriveShortSkillName`; three
  `specialCases` entries)
- Modify: `prompt-factory/content/schemas/plugins.json` (new `constellize:feature` plugin;
  `constellize:harness` `1.1.1` → `1.2.0`)
- Modify: `prompt-factory/content/literal/constellize-harness/skills/init/SKILL.md` (one line for
  `llm/constellize.json`)
- Test: `prompt-factory/build/__tests__/skill-name-derivation.test.ts` (created here)

**Interfaces:**
- Produces: `export function deriveShortSkillName(promptId: string, pluginId: string): string`, and
  a `constellize:feature` plugin whose three prompts generate skills named `specify`, `implement`,
  `verify`. Consumed by Tasks C4–C6.
- Consumes: nothing.

Why `specialCases` and not a new prefix rule: `verbPrefixes` contains `implement-` but not
`specify-` or `verify-`, so `implement-feature` would generate `constellize-feature:feature` while
its two siblings would generate `specify-feature` and `verify-feature` — an asymmetry that is easy to
miss. `specialCases` is the established mechanism for an awkward id and already carries 22 entries
(§9a).

- [ ] **Step 1: Write the failing test**

```ts
import { deriveShortSkillName } from '../generate-marketplace';

describe('deriveShortSkillName for constellize:feature', () => {
  it.each([
    ['specify-feature', 'specify'],
    ['implement-feature', 'implement'],
    ['verify-feature', 'verify'],
  ])('%s -> %s', (id, short) => {
    expect(deriveShortSkillName(id, 'constellize:feature')).toBe(short);
  });

  it('is unchanged for the ids it already handled', () => {
    expect(deriveShortSkillName('validate-test-coverage', 'constellize:craft')).toBe('test-coverage');
    expect(deriveShortSkillName('externalize-configuration', 'constellize:deliver')).toBe('externalize-config');
    expect(deriveShortSkillName('recover-from-noise-accumulation', 'constellize:memory')).toBe('recover-noise');
  });
});
```

- [ ] **Step 2: Run it and watch it fail**

Run: `npx jest build/__tests__/skill-name-derivation.test.ts`
Expected: FAIL — `deriveShortSkillName` is not exported (`generate-marketplace.ts:55` declares it
without `export`).

- [ ] **Step 3: Export it and add the three `specialCases` entries**

Change `function deriveShortSkillName` to `export function deriveShortSkillName`, and add to
`specialCases`:

```ts
'specify-feature': 'specify',
'implement-feature': 'implement',
'verify-feature': 'verify',
```

- [ ] **Step 4: Run the test**

Run: `npx jest build/__tests__/skill-name-derivation.test.ts`
Expected: PASS, 4 tests — including the three regression cases.

- [ ] **Step 5: Add the plugin to `plugins.json`**

```json
{
  "id": "constellize:feature",
  "version": "1.0.0",
  "name": "Constellize Feature",
  "description": "The feature workflow: specify, implement and verify one feature with tracked state",
  "skills": { "include": ["specify-feature", "implement-feature", "verify-feature"] }
}
```

No `agents` block — the three delegate to `constellize-design`'s and `constellize-craft`'s existing
agents, they do not ship their own. In the same file, bump `constellize:harness` from `"1.1.1"` to
`"1.2.0"` for Tasks C1, C2 and C7.

- [ ] **Step 6: Add `llm/constellize.json` to `init`**

In `skills/init/SKILL.md`, after the `llm/features/` line, add one template-file line:
`` - `llm/constellize.json` — optional project settings: `coverageThreshold`, `testCommand`, `lintCommand`, `runCommand` ``,
and state that every key is optional and an absent file is valid. This is D2's discovery point and
the one addition this plan makes beyond §10's list (Finding F4).

- [ ] **Step 7: Confirm the generator produces a plugin with only a manifest, and no drift surprise**

Run: `npm run generate:marketplace && git -C ../marketplace status --short`
Expected: one new untracked file,
`plugins/constellize-feature/.claude-plugin/plugin.json`, plus the harness files from C1–C2 and
`.claude-plugin/marketplace.json` (the catalog gains the seventh entry). `skills/` is correctly
absent — `generatePlugin` creates it only when the plugin has prompts, and there are none yet.

- [ ] **Step 8: Restore the marketplace working tree**

Run: `git -C ../marketplace checkout -- . && git -C ../marketplace clean -fd plugins`
Expected: `git -C ../marketplace status --short` is empty.

- [ ] **Step 9: Commit**

```bash
git -C prompt-factory add build/generate-marketplace.ts content/schemas/plugins.json content/literal/constellize-harness build/__tests__/skill-name-derivation.test.ts
git -C prompt-factory commit -m "feat: add the constellize-feature plugin and its name derivation"
```

---

### Task C4: `constellize-feature:specify`

**Files:**
- Create: `prompt-factory/content/prompts/feature/specify-feature.md`
- Test: `prompt-factory/build/__tests__/feature-prompts.test.ts` (created in A1, extended here)

**Interfaces:**
- Produces: `llm/features/<feature-name>.md` at `**Status:** SPECIFIED`, carrying the feature-spec
  template's sections — Problem, Goals, Non-Goals, User Stories, Design Approach, Sample
  Implementation, Edge Cases & Error Handling, Acceptance Criteria (Given-When-Then), Technical
  Notes, Dependencies, Open Questions — plus `## Constellation Map`, `## Gap Analysis` and
  `## Implementation Sketch` sections written by the delegated design skills. Consumed by Task C5.
- Consumes: `deriveShortSkillName`'s `specialCases` (C3), the `output_path` argument (B1), and
  D1's `allowed-tools` list (A0).

Delegation map, normative — §6.1, and nothing outside it belongs in the skill:

| Phase | Delegates to | Kept in the skill |
|---|---|---|
| Project and feature context | `constellize-harness:assess`, then read `llm/memory-bank/*` | — |
| What exists and what is missing | `constellize-design:gap-analysis` with `output_path` = the feature artifact | — |
| Adversarial interview | the `constellize-design:requirements-analysts` **agent** | the protocol |
| Sample implementation | `constellize-design:implementation-sketch` with `output_path` | — |
| Draft the spec | — | the template |
| Dual-persona review | the `constellize-design:system-architects` and `constellize-craft:qa-engineers` **agents** | the protocol |
| Final spec, status, record it | `constellize-memory:update` | the status write |

**The split that is easiest to get wrong**: the agent produces questions and critique; the **skill**
puts each one to the human, one per turn, waits, refuses a vague answer, summarises, and decides
whether the answer changes the spec. An interview run inside a subagent is a transcript of a
conversation that never happened — a subagent has no channel to the user. A build that satisfies
every other criterion and interviews inside the agent has failed, and must be rejected (§6.5).
`requirements-analysts` declares `maxTurns: 15` and `disallowedTools: Write, Edit, Bash`; under this
split neither matters, and neither may be raised.

- [ ] **Step 1: Write the failing tests**

Extend `build/__tests__/feature-prompts.test.ts`:

```ts
const FEATURE_IDS = ['specify-feature', 'implement-feature', 'verify-feature'] as const;

describe.each(FEATURE_IDS)('%s', (id) => {
  it('exists and belongs to constellize:feature', () => { /* loadPrompts + getPromptsForPlugin */ });
  it('carries no outputs.book block', () => { /* acceptance 18 */ });
  it('publishes no website page', () => {
    expect(get(id).frontmatter.outputs!.website!.include).toBe(false);  // decision 26
  });
  it('declares the invocation tools', () => {
    const tools = get(id).frontmatter.skill!['allowed-tools']!;
    expect(tools).toEqual(expect.arrayContaining(['Read', 'Glob', 'Grep', 'Write', 'Bash', 'Skill']));
  });
  it('names llm/features/ in full, since rewriteLlmPaths does not prefix features/', () => {
    expect(get(id).content).toContain('llm/features/');
    expect(get(id).content).not.toMatch(/(^|[^/])\bfeatures\/<feature/m);
  });
  it('describes the advisory fallback and names what is missing', () => {
    expect(get(id).content).toMatch(/advisor/i);
  });
  it('is not Python-shaped', () => {
    for (const banned of [/\buv (run|sync)\b/, /\bpytest\b/, /\bruff\b/, /llm\/memory_bank\//, /\/constellize:feature:/]) {
      expect(get(id).content).not.toMatch(banned);
    }
  });
});

describe('specify-feature', () => {
  it('delegates every phase in the §6.1 map', () => {
    const b = get('specify-feature').content;
    for (const target of [
      'constellize-harness:assess', 'constellize-design:gap-analysis',
      'constellize-design:requirements-analysts', 'constellize-design:implementation-sketch',
      'constellize-design:system-architects', 'constellize-craft:qa-engineers',
      'constellize-memory:update',
    ]) expect(b).toContain(target);
  });
  it('keeps the interview with the skill, not the agent', () => {
    expect(get('specify-feature').content).toMatch(/one (question )?at a time/i);
    expect(get('specify-feature').content).toMatch(/never (run|conduct) the interview (inside|in) (a )?subagent/i);
  });
  it('always asks the two required questions', () => {
    const b = get('specify-feature').content;
    expect(b).toMatch(/definition of done/i);
    expect(b).toMatch(/how will this be verified/i);
  });
  it('writes the status as prose', () => {
    expect(get('specify-feature').content).toContain('**Status:** SPECIFIED');
  });
  // Review Focus 5
  it('refuses an unsafe feature name and a case-only collision', () => {
    const b = get('specify-feature').content;
    expect(b).toMatch(/kebab-case/i);
    expect(b).toMatch(/path separator|\.\./);
    expect(b).toMatch(/case-insensitiv/i);
  });
  // D9
  it('revises an existing artifact only after confirmation, and clears stale evidence', () => {
    const b = get('specify-feature').content;
    expect(b).toMatch(/## Gate Results/);
    expect(b).toMatch(/delete|remove/i);
  });
});
```

- [ ] **Step 2: Run them and watch them fail**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: FAIL — none of the three prompts exists.

- [ ] **Step 3: Write the prompt**

Create `content/prompts/feature/specify-feature.md`. Frontmatter per D7:

```yaml
id: specify-feature
name: "Specify a feature: interview, adversarial review, and a written contract"
version: v1
chapter: 0
category: ai-workflow
skill:
  description: >
    Build a feature specification through repository context, gap analysis, an adversarial
    interview, a sample implementation and a dual-persona review. Writes
    llm/features/<name>.md at status SPECIFIED. Does not implement.
  argument-hint: "[feature_request]"
  allowed-tools: [Read, Glob, Grep, Write, Bash, Skill, Task, Agent]
  model: sonnet
  context: inline
outputs:
  website:
    include: false
  marketplace:
    plugin: constellize:feature
```

No `outputs.book` block. `context: inline` is required, not cosmetic: `context: fork` would run the
skill in a subagent and destroy the interview.

The body rewrites the course's `course:feature:specify` — it is not ported. What survives: the phase
list, the interview protocol (one question at a time, no vague answers, summarise after each answer,
2–5 questions, the two always-asked questions), the dual-persona alternation, the specification
template, and the Hard Rules. What goes: `llm/memory_bank/` (underscore), every `uv`/`pytest`
command, and the `/constellize:feature:*` command names. What is new: the delegation map above, the
advisory fallback, the name-safety rules (Review Focus 5) and the D9 revision behaviour.

- [ ] **Step 4: Run the tests**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: PASS for `specify-feature`; `implement-feature` and `verify-feature` still FAIL.

- [ ] **Step 5: Confirm the generated skill is named `specify`**

Run: `npm run generate:marketplace && ls ../marketplace/plugins/constellize-feature/skills/`
Expected: `specify`. Not `specify-feature`.

- [ ] **Step 6: Restore the marketplace working tree**

Run: `git -C ../marketplace checkout -- . && git -C ../marketplace clean -fd plugins`

- [ ] **Step 7: Commit**

```bash
git -C prompt-factory add content/prompts/feature build/__tests__/feature-prompts.test.ts
git -C prompt-factory commit -m "feat(feature): add specify-feature"
```

---

### Task C5: `constellize-feature:implement`

**Files:**
- Create: `prompt-factory/content/prompts/feature/implement-feature.md`
- Test: `prompt-factory/build/__tests__/feature-prompts.test.ts` (extended)

**Interfaces:**
- Consumes: a `**Status:** SPECIFIED` artifact from Task C4; the `output_path` argument (B1).
- Produces: the same artifact at `**Status:** IMPLEMENTED`, with a `## Implementation Report` section
  carrying **Files created** and **Files modified** lists — which Task C6's surface determination
  (D3) reads. Consumed by Task C6.

Delegation map, normative — §6.2:

| Phase | Delegates to | Kept in the skill |
|---|---|---|
| Identify stars | `constellize-design:constellation-map` with `output_path` | — |
| Gap, then plan | `constellize-design:gap-analysis` → `:implementation-sketch` → `:code-generation-plan` | the plan-confirmation turn |
| Code and tests, test-first per unit | `constellize-craft:unit-tests`, `:integration-tests`, and `:contract-tests` when the feature crosses an API boundary | — |
| Adversarial test review | the `constellize-craft:qa-engineers` and `constellize-design:system-architects` **agents** | the protocol, and the rule that a revealed gap becomes a test first |
| Status IMPLEMENTED, record it | `constellize-memory:update` | the status write |

- [ ] **Step 1: Add the failing tests**

Extend the shared describe block (Task C4 Step 1 already covers all three ids), plus:

```ts
describe('implement-feature', () => {
  it('delegates every phase in the §6.2 map', () => { /* the seven targets above */ });
  it('records files created and modified, which verify reads for the surface determination', () => {
    const b = get('implement-feature').content;
    expect(b).toContain('## Implementation Report');
    expect(b).toMatch(/Files created/);
    expect(b).toMatch(/Files modified/);
  });
  it('refuses a missing, IMPLEMENTED or VERIFIED artifact and names the status', () => {
    const b = get('implement-feature').content;
    expect(b).toMatch(/SPECIFIED/);
    expect(b).toMatch(/refuse|stop/i);
  });
  it('carries no coverage number of its own', () => {
    expect(get('implement-feature').content).not.toMatch(/\b(80|100)\s?%/);
  });
});
```

The last one matters: goal 6 and §7.5 say the three skills never carry a number. The course's
`implement` targets "100% line coverage" in three places and all of it goes — the threshold comes
from `llm/constellize.json` or the default, via `test-coverage`.

- [ ] **Step 2: Run them and watch them fail**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: FAIL — `implement-feature` does not exist.

- [ ] **Step 3: Write the prompt**

Frontmatter as C4's, with `id: implement-feature` and
`description` naming "Reads a SPECIFIED spec, leaves it IMPLEMENTED". Body rewrites
`course:feature:implement`: the phase list, the star-gap-generate shape, the adversarial test review
protocol and the Hard Rules survive; `uv run pytest --cov -v`, `uv sync && uv run crew --help`,
`uv run ruff check .`, `# pragma: no cover` and `llm/memory_bank/` all go. Commands come from
`llm/constellize.json`'s `testCommand`, `lintCommand` and `runCommand`, or are asked for.
The coverage-pragma rule survives in language-neutral form: *untestable code is marked with a
justification in whatever form the language provides, and every mark is reported.*

- [ ] **Step 4: Run the tests**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: PASS for `specify-feature` and `implement-feature`.

- [ ] **Step 5: Commit**

```bash
git -C prompt-factory add content/prompts/feature build/__tests__/feature-prompts.test.ts
git -C prompt-factory commit -m "feat(feature): add implement-feature"
```

---

### Task C6: `constellize-feature:verify` — four gates, collected

**Files:**
- Create: `prompt-factory/content/prompts/feature/verify-feature.md`
- Test: `prompt-factory/build/__tests__/feature-prompts.test.ts` (extended)

**Interfaces:**
- Consumes: an IMPLEMENTED artifact from Task C5; the 12 verdict sections and
  `defensive-programming` from Release A; `constellize-craft:test-coverage`'s existing verdict;
  `llm/constellize.json` (D2).
- Produces: the artifact at `**Status:** VERIFIED` with the `## Gate Results` JSON block whose schema
  Task C1 fixes — or left at IMPLEMENTED with the failing gate named.

Gate map, normative — §6.3:

| Gate | When | Delegates to |
|---|---|---|
| 1 Test integrity | always | `constellize-craft:test-coverage` |
| 2 Health check completeness | `defensive-programming` **always**; the four operational skills conditionally | `constellize-craft:defensive-programming`, `:application-health-validation`, `:infrastructure-health-checks`, `:operational-monitoring`, `:actionable-health-reporting` |
| 3 Deployment readiness | conditional | `constellize-deliver:externalize-config`, `:environment-independence`, `:reliable-containers`, `:rollback-capability` |
| 4 Maintainability in context | always | `constellize-craft:architectural-consistency`, `:dependency-hygiene` |

`documentation-completeness` and `team-comprehension` have verdicts but `verify` does **not** call
them: whether a codebase is comprehensible to a team is not a property of one feature, and running
them per feature would return the same findings every time (decision 20).

`verify` owns the aggregate and nothing else. The one measurement it makes itself is comparing
measured coverage against a **declared** threshold stricter than the default — no skill can know a
per-project setting. That is not duplication; anti-goal 3 forbids duplicating a capability, not
owning a judgement.

- [ ] **Step 1: Add the failing tests**

```ts
describe('verify-feature', () => {
  it('delegates to every gate skill in the §6.3 map, and to no other', () => { /* 11 targets */ });
  it('does not call the two project-scope Gate 4 skills', () => {
    const b = get('verify-feature').content;
    expect(b).not.toMatch(/constellize-craft:documentation-completeness/);
    expect(b).not.toMatch(/constellize-craft:team-comprehension/);
  });
  it('runs Gates 1 and 4 and defensive-programming unconditionally', () => {});
  it('records the surface determination and its reason', () => {
    const b = get('verify-feature').content;
    expect(b).toMatch(/Technical Notes/);
    expect(b).toMatch(/Dependencies/);
    expect(b).toMatch(/"surface"/);
    expect(b).toMatch(/when (the )?evidence is (absent|ambiguous)/i);  // D3's fail-safe
  });
  it('emits the gate-results schema the assessor parses', () => {
    const b = get('verify-feature').content;
    for (const key of ['"schema": 1', '"gates"', '"required"', '"verdict"', '"measured"', '"threshold"', '"source"']) {
      expect(b).toContain(key);
    }
  });
  it('carries the default threshold and reads a declared one', () => {
    const b = get('verify-feature').content;
    expect(b).toContain('llm/constellize.json');
    expect(b).toMatch(/80/);  // the book's number, as the default it reports, not as its own rule
  });
  // Review Focus 1
  it('refuses a declared threshold looser than the default', () => {
    const b = get('verify-feature').content;
    expect(b).toMatch(/stricter/i);
    expect(b).toMatch(/refuse|reject|ignore/i);
  });
  it('cannot write VERIFIED without a verdict for every required gate', () => {
    expect(get('verify-feature').content).toMatch(/NEVER (write|mark) VERIFIED/i);
  });
  it('re-runs on a VERIFIED artifact and refuses a SPECIFIED one', () => {});
  it('produces no coverage itself', () => {
    expect(get('verify-feature').content).not.toMatch(/--cov|coverage run|nyc |go test -cover/);
  });
});
```

- [ ] **Step 2: Run them and watch them fail**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: FAIL — `verify-feature` does not exist.

- [ ] **Step 3: Write the prompt**

Frontmatter as C4's, `id: verify-feature`. The body replaces the course's four hardcoded Python
commands with: Gate 1 **consumes** `test-coverage`'s verdict (decision 4 — it never runs a coverage
command itself); Gate 2's defensive review delegates to `defensive-programming`; Gate 3's clean
install-and-run becomes the project's declared `runCommand`; Gate 4's lint becomes the declared
`lintCommand` plus `architectural-consistency` and `dependency-hygiene`.

Four behaviours the tests pin: the surface determination (D3) with its fail-safe and its recorded
reason; the `## Gate Results` block exactly as Task C1's schema; the threshold rule, including the
refusal of a looser declaration; and "NEVER write VERIFIED without a verdict for every required
gate" — which, unlike the course's capitalised prose, is now backed by the assessor's cross-check.

- [ ] **Step 4: Run the whole feature test file**

Run: `npx jest build/__tests__/feature-prompts.test.ts`
Expected: PASS — all three prompts plus `defensive-programming`.

- [ ] **Step 5: Confirm all three skills generate with the right names**

Run: `npm run generate:marketplace && ls ../marketplace/plugins/constellize-feature/skills/`
Expected: `implement`, `specify`, `verify`.

- [ ] **Step 6: Restore the marketplace working tree**

Run: `git -C ../marketplace checkout -- . && git -C ../marketplace clean -fd plugins`

- [ ] **Step 7: Commit**

```bash
git -C prompt-factory add content/prompts/feature build/__tests__/feature-prompts.test.ts
git -C prompt-factory commit -m "feat(feature): add verify-feature, collecting the four gates"
```

---

### Task C7: The harness routes "Add a new feature" to the three

**Files:**
- Modify: `prompt-factory/content/literal/constellize-harness/skills/plan/SKILL.md:48-54`
- Modify: `prompt-factory/content/literal/constellize-harness/skills/orchestrate/SKILL.md:79-85`
- Test: `prompt-factory/build/__tests__/harness-routing.test.ts` (created here)

**Interfaces:**
- Consumes: the three skills (C4–C6) and the assessor's feature status (C1), which is what lets
  `plan` route by status rather than by which artifacts happen to exist.
- Produces: acceptance 12.

The six-step list is **deleted**, not kept beside the new route. All six steps appear inside the
three, so nothing is lost; keeping both would be the "two paths, different answers" anti-goal.

- [ ] **Step 1: Write the failing test**

```ts
import { readFileSync } from 'fs';

/** The "Add a new feature" route only: from its header to the next route's header. */
function featureRoute(body: string): string {
  const after = body.split('"Add a new feature":')[1];
  expect(after).toBeDefined();
  return after.split('**Any situation')[0];
}

const CASES = ['plan', 'orchestrate'].map(name => [
  name,
  readFileSync(`content/literal/constellize-harness/skills/${name}/SKILL.md`, 'utf8'),
] as const);

describe.each(CASES)('%s', (_name, body) => {
  it('routes Add a new feature to the three, and to nothing else', () => {
    const route = featureRoute(body);
    for (const s of ['constellize-feature:specify', 'constellize-feature:implement', 'constellize-feature:verify']) {
      expect(route).toContain(s);
    }
  });
  it('no longer carries the six-step list', () => {
    const route = featureRoute(body);
    for (const gone of [
      'constellize-design:gap-analysis',
      'constellize-design:implementation-sketch',
      'constellize-design:code-generation-plan',
      'constellize-craft:unit-tests',
      'constellize-craft:integration-tests',
    ]) expect(route).not.toContain(gone);
  });
  it('still carries the other routes untouched', () => {
    expect(body).toContain('constellize-deliver:incident-investigation');
    expect(body).toContain('constellize-design:gap-analysis');  // elsewhere, just not in this route
  });
});
```

- [ ] **Step 2: Run it and watch it fail**

Run: `npx jest build/__tests__/harness-routing.test.ts`
Expected: FAIL — the route still lists `code-generation-plan`.

- [ ] **Step 3: Replace the route in both files**

```
**Any situation + "Add a new feature":**
1. constellize-feature:specify
2. constellize-feature:implement
3. constellize-feature:verify
```

And, since C1 gives the assessor a per-feature status, add one line: resume at the step the feature's
status implies rather than starting at `specify` — a SPECIFIED feature goes to `implement`, an
IMPLEMENTED one to `verify`, and a `VERIFIED (unsubstantiated)` one back to `verify`. That is goal 5
reaching `plan` and `orchestrate`, and it is why C1 lands first.

- [ ] **Step 4: Run the test**

Run: `npx jest build/__tests__/harness-routing.test.ts`
Expected: PASS, 6 tests.

- [ ] **Step 5: Confirm the Harness still has exactly five skills**

Run: `ls content/literal/constellize-harness/skills/`
Expected: `assess`, `execute`, `init`, `orchestrate`, `plan` — five. This is the constraint
`book/ch9.md:324`, `book/appA.md:48` and `book/appC.md:33` impose, and the whole reason
`constellize-feature` is a seventh plugin.

- [ ] **Step 6: Commit**

```bash
git -C prompt-factory add content/literal/constellize-harness build/__tests__/harness-routing.test.ts
git -C prompt-factory commit -m "feat(harness): route Add a new feature to constellize-feature"
```

---

### Task C8: Release C — counts, the seventh plugin, the card, and the one website commit

**Files:**
- Modify: `prompt-factory/content/literal/marketplace-root/README.md` (`:8` → 78 skills across 7
  plugins; a `constellize-feature` row; `:65`'s `features/` line reworded to a file per feature)
- Modify: `prompt-factory/content/literal/marketplace-docs/constellize-skills-infographic.html`
  (`6` → `7` plugins, `75` → `78` skills, a seventh plugin block with three chips)
- Modify: `marketplace/GENERATED_FROM`, all regenerated files
- Modify: `marketplace/docs/releasing-1x.md` (the card command, per Finding F2)
- Modify: `website/public/constellize-reference-card-v2.pdf` (the one deliberate website change,
  Finding F1)

**Interfaces:**
- Consumes: Tasks C1–C7.
- Produces: marketplace `main` with 109 generated files; `constellize-feature` at `1.0.0`,
  `constellize-harness` at `1.2.0`.

- [ ] **Step 1: Update the two count-bearing literal files**

`README.md:8` → `- **78 Skills** across 7 plugins`, plus a `constellize-feature` row in the
per-plugin table. `README.md:65` — currently `features/   # per-feature documentation subsets` —
becomes a file per feature, because §9b changed the layout and this file is being regenerated
anyway. In the infographic: the `6` plugins stat → `7`, the `75` skills stat → `78`, and a seventh
plugin block with `specify`, `implement`, `verify` chips.

- [ ] **Step 2: Confirm the card still fits one page — the real risk in this task**

Run: `npm run build:card -- --line v2 --out /tmp/card-probe-c.pdf`
Expected: success, one page. The plugin grid is `grid-template-columns: 1fr 1fr 1fr`, so a seventh
block starts a third row inside a fixed `@page { size: 816px 1230px }`. If the page count assertion
fails, tighten the infographic's layout — do not change the page size and do not drop a plugin.

- [ ] **Step 3: Regenerate and read the diff**

Run: `npm run generate:marketplace && git -C ../marketplace status --short`
Expected: four new untracked files under `plugins/constellize-feature/`, plus modifications to
`.claude-plugin/marketplace.json`, the harness's five files, `README.md` and the infographic.

- [ ] **Step 4: Count the generated files — acceptance 1**

Run: `npm run check:drift -- --target marketplace --against ../marketplace`
Expected: no drift, and the generated count is **109**. The guard itself needed no change:
`GENERATED_OWNED` begins `'plugins'` and `findExtraFiles` walks recursively, so a new plugin
directory is owned on arrival, and `ROOT_ALLOWED` is untouched.

- [ ] **Step 5: Confirm the book is untouched, both ways — acceptance 17**

Run: `npm run generate:all && git -C ../book status --short`
Expected: empty. Then the second, stronger check: `git archive main` the factory into a scratch
sibling outside all five repos, symlink `node_modules`, run `generate-book.ts` there, and
`diff -rq` its output against the committed `book/generated/`.
Expected: identical, 66 prompt-refs — the baseline measured on 2026-11-04. The first check catches an
accidental write; the second catches one made silently before the check.

- [ ] **Step 6: Confirm acceptance 18 by reading three files**

Run: `grep -A3 "^outputs:" content/prompts/feature/*.md`
Expected: a `website:` block with `include: false` and a `marketplace:` block in each, and **no
`book:` key anywhere**. This, not `include: false`, is what keeps them out of the book.

- [ ] **Step 7: Confirm no generated website content changed — acceptance 13, as narrowed by F1**

Run: `git -C ../website status --short`
Expected: only the pre-existing untracked `public/The_Constellize_Method.mp4`. Then run the website
drift guard against its own unchanged `GENERATED_FROM` (`0d97085`) and expect it green. The website
is generated from the `v1` line, which this project never touches.

- [ ] **Step 8: Push prompt-factory, then make the two marketplace commits**

```bash
git -C prompt-factory push origin main
git -C marketplace add -A plugins .claude-plugin README.md docs/constellize-skills-infographic.html
git -C marketplace commit -m "chore: regenerate — the constellize-feature plugin and the feature-aware assessor"
git -C prompt-factory rev-parse main > marketplace/GENERATED_FROM
git -C marketplace commit -m "chore: point GENERATED_FROM at the feature-workflow release" GENERATED_FROM
```

- [ ] **Step 9: Verify both guards locally — acceptance 2**

Run:
```bash
npm run check:drift -- --target marketplace --against ../marketplace
cd ../marketplace && .github/scripts/check-version-bump.sh origin/main
```
Expected: no drift; `OK: constellize-harness 1.1.1 -> 1.2.0`,
`OK: constellize-feature has no plugin.json at base (new plugin)`, `OK: version-bump check passed`.

- [ ] **Step 10: Correct the card command in the release doc — Finding F2**

In `marketplace/docs/releasing-1x.md`, replace the bare `npm run build:card` at `:63` with the
per-line form and say why. The doc is accurate for a 1.x release that changes both lines' card
content — it already states that the bare command writes all three PDFs — so this is not correcting
an error but narrowing the procedure: while `v1` is frozen, a bare run rewrites
`constellize-reference-card-v1.pdf` **and** the unversioned alias it is also written as, both of
which the printed book's readers follow. Record that, and that `npm run build:card --line v2`
without the `--` is swallowed by npm (Finding F2).

- [ ] **Step 11: Rebuild the v2 card, and only the v2 card — acceptance 14**

Run:
```bash
# from the prompt-factory root, as everywhere else in this plan
cp ../website/public/constellize-reference-card-v1.pdf /tmp/card-v1-before.pdf
cp ../website/public/constellize-reference-card.pdf /tmp/card-alias-before.pdf
npm run build:card -- --line v2 --out ../website/public/constellize-reference-card-v2.pdf
cmp /tmp/card-v1-before.pdf ../website/public/constellize-reference-card-v1.pdf
cmp /tmp/card-alias-before.pdf ../website/public/constellize-reference-card.pdf
git -C ../website status --short
```
Expected: both `cmp`s are silent, and `git -C ../website status --short` shows exactly one modified
file, `public/constellize-reference-card-v2.pdf`, plus the pre-existing untracked `.mp4`. The
unversioned `public/constellize-reference-card.pdf` is the `v1` entry's `alsoWriteAs` target
(`build-reference-card.mjs:51-59`), so it is written only when v1 is built; the second `cmp` is what
proves the per-line invocation did not touch it.

- [ ] **Step 12: Ask Steve before any push, then push the three repos in order**

Nothing in this step happens without Steve's go-ahead, and the website commit is the one he should
look at hardest (Finding F1). Order: prompt-factory `main` (already pushed in Step 8) → marketplace
`main` → website `main`, committing the card on its own:

```bash
git -C website add public/constellize-reference-card-v2.pdf
git -C website commit -m "chore: rebuild the v2 reference card for marketplace 2.0"
```

- [ ] **Step 13: Confirm `v1` is still frozen in both repos — acceptance 16**

Run:
```bash
git -C prompt-factory rev-parse v1 origin/v1; git -C marketplace rev-parse v1 origin/v1
```
Expected: prompt-factory `69dffee…` twice, marketplace `8f470b2…` twice.

---

### Task C9: End-to-end acceptance

**Files:**
- Create: a scratch TypeScript or Go project outside all five repos (nothing committed)

**Interfaces:**
- Consumes: the whole of Releases A, B and C, installed from the marketplace.
- Produces: the evidence for acceptances 3, 6, 7, 8, 9 and 10 — the six that no amount of reading the
  text can substitute for.

- [ ] **Step 1: Install the marketplace and take one feature to VERIFIED on a non-Python project — acceptance 7**

A TypeScript or Go repository, no Constellize scaffolding to begin with, no skill edits. Run
`constellize-harness:init`, then `specify` → `implement` → `verify`.
Expected: `llm/features/<name>.md` at `**Status:** VERIFIED` with a complete `## Gate Results` block.
`defensive-programming` is part of what this exercises.

- [ ] **Step 2: Make each gate fail, one at a time — acceptance 3**

Four features, each violating one gate: coverage below the threshold (Gate 1); an unvalidated
external input (Gate 2); a hardcoded environment-specific value (Gate 3); an unjustified new
dependency (Gate 4).
Expected: each is left at `**Status:** IMPLEMENTED` with that gate named. This is the test of goal 3
— a verdict section no caller reads would pass a reading of the text and fail here.

- [ ] **Step 3: Prove the project's design artifacts are untouched — acceptance 6**

Record `sha256` of every file under `llm/construction/` before a full feature run and compare after.
Expected: byte-identical. Then specify and verify a second feature and confirm neither feature's
artifact mentions the other.

- [ ] **Step 4: Run it again with the siblings uninstalled — acceptance 8**

Install `constellize-feature` alone, without `constellize-design`, `:craft`, `:deliver`,
`:memory` or `:harness`.
Expected: each phase falls back to advisory, printing the command and naming what is missing, then
verifying what the step should have produced. Nothing fails silently. The state file is resumable,
which is what makes this work.

- [ ] **Step 5: Prove the evidence check, both ways — acceptance 9**

A failing gate leaves the status IMPLEMENTED. Then hand-edit an artifact to `**Status:** VERIFIED`
with a gate-results block missing a required gate's verdict, and run `constellize-harness:assess`.
Expected: `VERIFIED (unsubstantiated)`, with the missing gate named.

- [ ] **Step 6: Prove a stricter declared threshold is enforced — acceptance 10**

Write `llm/constellize.json` with `{"coverageThreshold": {"branch": 100}}` on a feature measuring
85%.
Expected: verification fails where the default would have passed. Then set `{"branch": 50}` and
confirm the declaration is **refused** and the default 80 applies (Review Focus 1).

- [ ] **Step 7: Prove the assessor's own tests run in CI — acceptance 15**

Run: `npx jest`
Expected: all suites pass, including `assessor-features`, `gate-verdicts`, `feature-prompts`,
`design-output-path`, `skill-name-derivation` and `harness-routing`, alongside the two pre-existing
`check-drift` suites. The factory's CI runs `npm ci`, `check-determinism.sh` and `npx jest`, so these
now gate the factory.

- [ ] **Step 8: Record the results**

Write the outcome of each acceptance into the memory bank
(`memory-bank/activeContext.md` and `progress.md`) with
`constellize-memory:update`. Anything that did not pass is reported to Steve, not worked around.

---

## Self-review

**Spec coverage.** Goals 1–8: goal 1 → C3–C6; goal 2 → the normative delegation maps in C4, C5, C6;
goal 3 → A1–A4; goal 4 → C7; goal 5 → C1, C2, C6; goal 6 → C6 and D2; goal 7 → B1; goal 8 → A5, B2,
C8. Acceptance 1–18: 1 → C8 Step 4; 2 → C8 Step 9; 3 → C9 Step 2; 4 → A2 Step 6, A3 Step 5, A4
Step 4; 5 → B1 Step 6; 6 → C9 Step 3; 7 → C9 Step 1; 8 → C9 Step 4; 9 → C9 Step 5; 10 → C9 Step 6;
11 → C2 Step 3; 12 → C7; 13 → C8 Step 7, as narrowed by F1; 14 → C8 Step 11; 15 → C9 Step 7;
16 → A5 Step 11, C8 Step 13; 17 → A5 Step 4 and C8 Step 5; 18 → C8 Step 6. §10's nine items → D1–D9.
No §9 decision is reopened. **Two gaps found and closed**: F1's acceptance conflict, which needs
Steve's agreement, and F3's unverifiable cross-check, which D3 and D4 fix.

**Review Focus coverage.** 1 → C1 Step 6 and C6's test; 2, 3, 4 → C1 Step 1; 5 → C4 Step 1.

**Type consistency.** `FeaturesState`, `FeatureEntry` and `FeatureStatus` are defined once in C1 and
used by C2 and C7. `deriveShortSkillName` is exported in C3 and used nowhere else. The gate-results
schema is written once in C1 and referenced by C6. Section headings (`## Gate Results`,
`## Constellation Map`, `## Gap Analysis`, `## Implementation Sketch`, `## Implementation Report`)
are fixed in B1, C1 and C5 and used consistently. The status strings are `SPECIFIED`, `IMPLEMENTED`,
`VERIFIED` throughout, in the prose form `**Status:** X`.

**Proportion.** The plan is about 1.9× the 1,019-line spec, which is more than the writing-plans
skill likes and is worth justifying rather than hiding. Three things account for it, and none is a
transcript of the program: the 12 verdict checklists (~70 lines of requirement text that *is* the
deliverable, settling §10's hardest open item); the test assertions, which the skill asks for as
code; and the delegation maps restated inside Tasks C4–C6 rather than cross-referenced, because a
subagent executing one task sees only that task and the maps are normative — a phase not in the map
is not in the skill. The actual code in this project is four small things: `tier1.ts`'s features
block, `types.ts`'s three new types, `deriveShortSkillName`'s `export` keyword and three
`specialCases` lines. Each has a test written before it and is given as a signature, not a body.
Everything else the project ships is prose in a prompt, which is why so many verification steps are
greps and drift runs rather than unit tests.
