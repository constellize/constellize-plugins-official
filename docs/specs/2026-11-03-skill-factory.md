# Project 1.5: the skill factory

**Status**: design, awaiting approval
**Date**: 2026-11-03
**Sequence**: project 1 (done) → **1.5** → 2 (feature workflow) → 4 (delivery) → 3 (Copernicus)

---

## 1. Intent

Make `prompt-factory` the single source for everything in marketplace `main`.

Today the marketplace is two repositories wearing one coat. 69 skills and 14 agents are generated
from `prompt-factory`. Beside them, hand-written and outside the pipeline, sit the
`constellize-harness` plugin (five `SKILL.md`, 393 lines, plus 740 lines of TypeScript),
`.claude-plugin/marketplace.json`, `README.md`, and `docs/constellize-skills-infographic.html`.

Project 1 did not integrate that set; it fenced it off. `build/check-drift.ts` carries explicit
`FORBIDDEN` assertions that the generator must never write `marketplace.json`, `README.md` or
anything under `plugins/constellize-harness/`. The fence works, but it means two conventions for
authoring the same repository, and a contributor has to know which half they are in.

**Steve, 2026-11-03: "lets make everything come from the prompt factory, the harness' five, and
these 3. having 2 conventions sucks."**

After this project, everything a reader installs from marketplace `main` is build output. Two
things stay authored in place, deliberately: prose under `docs/`, and `GENERATED_FROM`, which names
the commit that generated everything beside it. That is the whole exception list (goal 1).

### Why the harness was excluded, and why that reason does not hold

Decision 5 (2026-10-24) put code in the marketplace because "code with tests and a build belongs
where it runs. The harness assessor runs straight from the plugin."

Checked on 2026-11-03: `plugins/constellize-harness/scripts/package.json` declares one dependency
(`tsx`) and **no scripts at all**. There is no build. There are no test files anywhere under
`scripts/`. The rejected alternative was rejected for a cost that does not exist.

It is worse than neutral. The harness has no CI, and its missing tests are already a recorded
defect. The Node toolchain and the CI live in `prompt-factory`. Moving the code there is the
precondition for ever testing it.

---

## 2. Goals

1. **Everything in marketplace `main` is generated from `prompt-factory`, with one stateable
   exception: human-authored prose and the provenance stamp.** Concretely, the generator owns the
   69 skills and 14 agents it already owns, plus the five harness `SKILL.md`, the harness
   TypeScript, `marketplace.json`, `README.md`, the card HTML, the card builder,
   `.github/workflows/drift.yml`, `.github/scripts/check-version-bump.sh` and
   `docs/constellize-skills-infographic.html`. It does not own **prose** under `docs/`
   (`docs/specs/`, `docs/plans/`, `docs/releasing-1x.md`) or `GENERATED_FROM`. A contributor needs
   one rule, not a file list: **if it is not prose and not `GENERATED_FROM`, edit it in the
   factory.** (Corrected 2026-11-03 after approval: the first draft said the factory does not own
   `docs/` while goal 1 also claimed the infographic, which lives there. The infographic is a
   generated asset, not prose.)
2. The `FORBIDDEN` list in `check-drift.ts` is deleted for the `main` target, because nothing is
   left for it to protect.
3. The files that currently differ by hand between `main` and `v1` become generator inputs rather
   than a divergence a human has to remember.
4. **The harness ships with no dependencies.** The 63 committed `node_modules` files are deleted
   rather than made reproducible. See decision 9.
5. The harness becomes testable. This project does not test it.

## 3. Non-goals

- **`v1` is not touched.** It keeps the structure project 1 gave it, including its hand-written
  harness, its vendored `tsx`, and its own generator.
- **No repository rename.** `prompt-factory` keeps its name; only its remit widens.
- **No tests for the harness.** Deferred to its own piece of work, by Steve's decision.
- **No change to what any shipped plugin produces.**
- **No website files are touched, in `src/` or anywhere else.** Decided 2026-11-03: see §8b.
- **Prose under `docs/` stays hand-written in the marketplace** — `docs/specs/`, `docs/plans/` and
  `docs/releasing-1x.md`. Design documents are about the marketplace and are authored in
  conversation; generating them would be nonsense. `docs/constellize-skills-infographic.html` is
  not prose and is generated.
- **The feature workflow is project 2**, not this.

## 4. Anti-goals

This project has failed, even if it technically works, if any of these are true:

- What a `v1` reader installs has changed in any way.
- A plugin on `main` produces different results after the migration than before it. (The harness's
  *invocation* does change — see decision 9 — so this is about output, not command line.)
- The generated output differs from what is committed at the step-0 baseline, in authored source.
- A contributor still has to know which half of the marketplace they are editing.
- The harness still installs only on Apple Silicon.

---

## 5. Constraints

**A Claude Code plugin cannot run `npm install`.** It must arrive complete. This is why the harness
vendored `tsx` and `esbuild` in the first place. Decision 9 satisfies this constraint by removing
the dependency rather than by shipping it: a plugin with nothing to resolve cannot fail to resolve
it. Any *other* scheme that emits only source and expects the user's machine to resolve
dependencies is still wrong.

**The harness then requires Node with unflagged TypeScript type stripping** — Node 22.18+, 23.6+,
or 24 and later. This is a new, real requirement on the user's machine, and it replaces the old
unstated one (`npx` plus network plus npm registry access, which `npx tsx` needed on every run).
The harness skills must state it, and should fail with a clear message rather than a module
resolution stack trace.

**`v1`'s generator stays as it is.** Steve, 2026-11-03: "as long as v1 has its own generator, we
can still fix specific to v1 while main has v2 and no easy way to cherry pick back to v1." This is
accepted deliberately and in both directions: `v1` remains independently fixable, and generator
improvements made on `main` do not flow back to it. Content fixes still cherry-pick cleanly,
because content files keep their shape; generator changes do not.

**GitHub Actions reads workflows from the pushed branch's own commit.** So generating
`.github/workflows/drift.yml` means generating it for `main` only; `v1` keeps its hand-written copy,
and the two must not be assumed to match. It also means the drift guard becomes generated output
that checks generated output. That is acceptable — it is checked like anything else — but a broken
generated workflow disables the check that would have caught it, so the generator's own test suite,
not the marketplace's CI, is what protects that file.

**`GENERATED_FROM` keeps its invariant**: the commit whose generator produced this output, not the
tip. It cannot be generated, because it names the commit that generated everything beside it.

---

## 6. Acceptance

**Step 0 lands first, and separately: remove `tsx`.** Three relative import specifiers in
`scripts/*.ts` change from `.js` to `.ts`, the five harness `SKILL.md` change `npx tsx …` to
`node …`, and `package.json`, `package-lock.json` and all 63 `node_modules` files are deleted. This
is a deliberate change to shipped files, so it cannot sit inside a byte-for-byte migration. It ships
as its own commit with its own harness version bump, and the tree it leaves is the **baseline**.

**The migration is then correct when the factory reproduces the step-0 baseline byte-for-byte.**
The five harness `SKILL.md`, the TypeScript sources, `marketplace.json`, `README.md`, the card HTML,
the card builder and the two `.github` files must come out of the generator identical to what
step 0 committed. The existing drift guard is the proof; this is the same technique project 1 used,
and it is why `FORBIDDEN` may be deleted only once the generator demonstrably produces what it used
to protect.

**No exceptions.** Project 1's vendored-tree carve-out is gone with the vendored tree. Byte-equality
now covers every file the generator owns.

---

## 7. Decided

Taken in conversation on 2026-11-03, recorded as decided rather than left open:

| # | Decision |
|---|---|
| 1 | Only `main` becomes fully generated; `v1` is frozen as project 1 built it |
| 2 | No repository rename |
| 3 | **Superseded by decision 9.** There is no vendoring step, because there are no vendored dependencies |
| 4 | Harness TypeScript is held as **real source** in the factory and emitted by the generator — it is not templated or generated from content |
| 5 | **Narrowed.** New material will publish to `/prompts/v2/` only, but not in this project — 1.5 publishes nothing to the website (§8b) |
| 6 | The harness gets no tests in this project |
| 7 | `marketplace.json`, `README.md` and the card HTML are generated for `main` only, from one source (see §8a) |
| 8 | The reference card builder (`scripts/build-reference-card.mjs`, written 2026-11-03) and the infographic HTML move into the factory with everything else |
| 9 | **`tsx` is removed from the harness rather than vendored for more platforms.** Verified 2026-11-03: `assess.ts` runs under plain Node 26 with zero dependencies, producing full JSON output, after changing three relative import specifiers from `.js` to `.ts`. This deletes 63 tracked files, the Apple-Silicon-only limitation, the `npm ci`-cannot-reproduce-darwin problem in CI, and the forced harness version bump on every re-vendor |
| 10 | **The factory owns everything on `main` except `docs/` and `GENERATED_FROM`** (goal 1) |
| 11 | **The five harness `SKILL.md` are held as literal source and copied**, exactly as decision 4 treats the TypeScript. They are not pushed through the content model. This follows from §8b: with no `v2` pages in scope they need no `prompt-id` frontmatter, and the current emitter cannot reproduce frontmatter-less files anyway |

Decision 4 is the author's call, stated for the record: generating TypeScript from a content
template would be absurd for 740 lines of real code. The factory stores it as source; the generator
copies it. "Comes from the factory" means authored there, not synthesised there. Decision 11 applies
the same reasoning to the five harness skill bodies.

---

## 8. Left to the builder

- **How the generator expresses the `main`/`v1` differences** in `marketplace.json` and `README.md`.
  The four files that differ between the lines are enumerated in `docs/releasing-1x.md`.
- **Where the harness source lives in the factory** — alongside content, or in a sibling tree that
  the generator copies from. Decisions 4 and 11 fix *that* it is literal source, not *where*.
- **The order of the migration after step 0.** The acceptance criterion makes each piece
  independently verifiable, so it can be done one file set at a time rather than in one commit.
- **Whether `check-drift.ts` keeps a narrowed assertion** (for example, that the generator never
  writes outside the plugin tree) once the current `FORBIDDEN` entries go. See the `EXTRA` note in
  §8a.
- **How the harness detects an unsupported Node** and what it says.

---

## 8a. Settled after the builder check (2026-11-03)

A reviewer planned from this document and returned seven questions. Three went back to Steve
(§8b). These four are the author's calls, recorded so the builder does not re-open them.

**Vendoring — overtaken by decision 9.** The reviewer found that vendoring could not sit inside
`generate()`: `check-determinism.sh` runs `generate()` twice and compares, the marketplace drift job
compares every generated file byte-for-byte on `ubuntu-latest`, and a Linux `npm ci` can never
reproduce a tree installed on darwin. That finding is what prompted testing the harness without
`tsx` at all, which worked. **Decision 9 removes the problem rather than working around it**, so
there is no vendoring step, no vendored-path exemption weakening goal 2, and no re-vendor version
bump. Recorded here because the reasoning is what justifies decision 9.

**"Generated per line" is `main` only.** Decision 7 overstated it. `v1` is frozen and keeps its own
generator and its own hand-written copies, so nothing on that line would ever consume a generated
variant. `main`'s generator emits `main`'s values and no others. The only genuine per-line consumer
is the reference-card builder, which already injects the install command per line and keeps doing
so. The generator does not grow a line parameter.

**The card builder is relocated, not wired into generation.** Its output is a PDF produced by
driving headless Chrome: not byte-reproducible, and no CI runner here has Chrome. It moves into the
factory and stays a release-time script, run by hand as `docs/releasing-1x.md` describes. The PDFs
are not generated output and the drift guard does not cover them. It reads the factory's source
copy of the infographic, not the generated one.

**The committed `marketplace.json` values are canonical.** The reviewer found the factory's
`content/schemas/plugins.json` disagrees with what ships: owner `"Steve Atkinson"` with
`url: https://constellize.com` in the factory, versus `"Constellize"` with no url in the committed
catalog. Byte-for-byte acceptance settles it — the committed values win and **the factory schema is
corrected to match**, not the other way round. The committed catalog also carries a 13-entry
`renames` map (including `"constellize-ai-workflow": null`) that has no home in the factory schema;
it becomes factory-authored and is append-only, because it is the migration path for anyone still
on an old plugin name.

**One gap the reviewer flagged, not a question.** `check-drift.ts`'s `EXTRA` rule only walks
`skills/`, `agents/` and `.claude-plugin/`. A hand-added file under
`plugins/constellize-harness/scripts/` goes undetected today. Once the harness is generated, that
directory is generated output, so the `EXTRA` walk must cover it or goal 2 is hollow there.

---

## 8b. Steve's answers (2026-11-03)

**Scope: prose and the stamp stay; everything else moves.** `.github/` and the card script come
into the factory along with the five generated sets. `docs/` and `GENERATED_FROM` stay
marketplace-authored. Written up as goal 1 and decision 10, as a rule rather than a file list,
because anti-goal 4 is about what a contributor has to remember.

**Vendoring: drop `tsx`.** Chosen over vendoring four platforms or documenting the Mac-only limit.
Decision 9, with the verification. The consequences are a new Node floor (§5) and a step-0 commit
that is a deliberate change rather than part of the byte-for-byte migration (§6).

**Website: defer to project 2.** 1.5 touches no website files. The reviewer found that nothing can
link a `/prompts/v2/` page today — `PromptsIndexPage.tsx:47` hardcodes `/prompts/v1/${prompt.id}`
and the only index is the hand-maintained manifest inside `src/`, which the non-goals put off
limits — so generating `v2` pages in 1.5 would ship exactly the unreachable pages that argument
rejected. The deciding point: **there is no new material to publish until project 2 writes it.**
Project 2 owns both the material and the routing work it needs.

---

## 9. Evidence

Everything asserted above was checked on 2026-11-03 against the working trees.

| Claim | How it was checked |
|---|---|
| Harness is 393 lines of words + 740 of TypeScript | `wc -l` over `skills/*/SKILL.md` and `scripts/*.ts` |
| Harness has no tests and no build | `package.json` has one dependency and no `scripts`; no `*.test.ts` or `*.spec.ts` under `scripts/` |
| `node_modules` is committed, with a native binary | `git ls-files \| grep -c node_modules` = **63**; the only `@esbuild` package is `darwin-arm64`, so the plugin installs on Apple Silicon only |
| The harness runs with no dependencies at all | copied `scripts/*.ts` to a scratch dir, rewrote 3 relative import specifiers from `.js` to `.ts`, ran `node assess.ts --format json` on Node 26.8.2 from the repo root: full JSON output, no `tsx`, no `node_modules` (decision 9) |
| `tsx` is the only reason for the vendored tree | `package.json` declares `tsx` alone; `grep -rn tsx` finds it referenced only by the five `SKILL.md` as `npx tsx …/assess.ts` |
| The content model is 1:1 with the website | 73 content prompts produce 73 website pages; `generate-website.ts` contains no filter, skip or exclude |
| It supports prompt-without-skill but not skill-without-page | 73 prompts yield 69 generated skills; the other 4 are excluded via `plugins.json` |
| The drift guard fences off the hand-written set | `FORBIDDEN` assertions in `build/check-drift.ts` for `marketplace.json`, `README.md`, `plugins/constellize-harness/**` |

---

## 10. What this unblocks

Project 2 specifies a feature workflow of three skills that delegate to existing ones. That design
is much simpler to write once there is one place to author a skill and one guard that covers every
skill in the marketplace. 1.5 is sequenced first for that reason, not because the feature workflow
depends on it functionally.
