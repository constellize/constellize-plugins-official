# prompt-factory / Marketplace Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make prompt-factory the reproducible source of every generated file in the marketplace and the website, with two version lines so book readers stay on 1.x while `main` becomes 2.0.

**Architecture:** The generators in `prompt-factory/build/` absorb the four hand edits that were applied downstream in May and June 2026, so their output *is* the committed repo. A drift guard regenerates into a temp directory and fails on any difference; it runs in each consuming repo's CI against the prompt-factory commit that repo records. The marketplace gains a `v1` branch, named `constellize-plugins-v1`, that the website's install command pins.

**Tech Stack:** TypeScript run via `npx ts-node` (no build step for the generators), Node 16+, GitHub Actions, React/Vite for the website.

**Spec:** `marketplace/docs/specs/2026-10-29-prompt-factory-marketplace-split.md` (approved 2026-10-29)

## Global Constraints

- **Repos are separate.** The workspace root is not a git repo. `prompt-factory` and `constellize-plugins-official` are **public**; `website` is **private**. No commit spans them.
- **`book-v1` (prompt-factory `3c18af9`) must keep producing today's output.** All generator changes land on `main` and are cherry-picked to `v1`; the tag itself is never rebuilt.
- **Never run a generator with its default output path in the real workspace.** `MARKETPLACE_DIR = '../marketplace'` and `WEBSITE_DIR = '../website'` overwrite the sibling repos in place.
- **`diff` is aliased to `git diff` in the user's zsh.** Use `/usr/bin/diff`.
- **The website is generated from prompt-factory `v1`, not `main`** (Steve, 2026-10-29). It serves the
  book version at `/prompts/v1/`, so it is a 1.x consumer like marketplace `v1`. When 2.0 exists the
  generator will run from both lines into separate version directories — which is why Task 8 adds a
  version parameter rather than hardcoding `v1`. Generating both is not in this plan.
- **Marketplace `main` is `e9528d0`; the `v1` line branches from it**, never from `v0.3.2` (a 13-plugin February layout).
- **Every fix on the 1.x line bumps `plugin.json` `version`.** Never set `version` in both `plugin.json` and the `marketplace.json` entry.
- **Do not commit or push anything** unless the executing human asks. The website has uncommitted work from 2026-10-29 (see Task 6).

## Review Focus

Five things the spec implies that no task's happy path exercises. Each has a test in the task that owns the code.

1. **A generator run must not delete `marketplace.json` or the hand-written harness.** This is the exact May 2026 failure: the generator builds `marketplace.json` from five plugin definitions while the committed file lists six. Test in Task 3.
2. **The website generator's output must compile.** It currently emits a `generated-metadata.ts` declaring an unused `personasBasePath`, which fails `tsc -b`, and `npm run build` is `tsc -b && vite build`. Test in Task 4.
3. **The drift guard must refuse to write outside a temp directory.** A guard that regenerates into `../marketplace` destroys the thing it is checking. Test in Task 2.
4. **A user who installed the 13-plugin February marketplace must migrate, not break.** Without a `renames` map they get `Plugin "<name>" not found in marketplace`. Test in Task 1.
5. **A 1.x fix with no version bump reaches nobody.** Readers stay on their cached copy until the computed version changes. Test in Task 5, exercised against a real prompt edit in Task 6.

---

## File Structure

**prompt-factory** (all on `main`, then cherry-picked to `v1`)
- Modify `build/generate-marketplace.ts` — output dir parameter; hyphenated plugin dirs; committed frontmatter shape; `llm/` path rewriting; stop writing `marketplace.json` and `README.md`; version from config.
- Modify `build/generate-website.ts` — output dir parameter; stop writing the two dead metadata files; versioned prompt path.
- Modify `content/schemas/plugins.json` — add a `version` field per plugin.
- Create `build/check-drift.ts` — the drift guard.
- Create `build/lib/paths.ts` — the `llm/` path rewriting, ported from `marketplace/scripts/migrate-paths.sh`.
- Create `.github/workflows/generators.yml` — determinism check.

**marketplace**
- Create `GENERATED_FROM` — the prompt-factory commit its generated files came from, on `main` and on `v1`.
- Create `.github/workflows/drift.yml`.
- Modify `.claude-plugin/marketplace.json` — `renames` map on both lines; `name` on `v1` only.
- Modify `README.md` — pinned install command, on `v1`.
- Modify `docs/constellize-skills-infographic.html` — pinned install command.
- Delete `scripts/migrate-paths.sh` — folded into the generator.

**website**
- Create `GENERATED_FROM`, `.github/workflows/drift.yml`.
- Modify `src/App.tsx:41`, `src/pages/prompts/PromptDetailPage.tsx:14,29` — version from the route.

**Out of scope** (recorded in the spec, not this plan): generating `website/src/data/personas/metadata.ts` (spec §8.8); the stale path in `website/scripts/generate-prompts-manifest.mjs`; `release-new-version.sh`; the harness's own defects.

---

### Task 1: Cut the version lines

**Files:**
- Modify: `marketplace/.claude-plugin/marketplace.json`
- Test: `marketplace` — `claude plugin validate .`

**Interfaces:**
- Consumes: nothing.
- Produces: prompt-factory branch `v1` at `3c18af9`; marketplace branch `v1` at `e9528d0`; marketplace `name` on `v1` is `constellize-plugins-v1`, on `main` stays `constellize-plugins-official`.

- [ ] **Step 1: Cut prompt-factory `v1` from `book-v1`, before any generator change**

```bash
git -C prompt-factory branch v1 book-v1
git -C prompt-factory log -1 --format=%H v1   # must print 3c18af9...
```

- [ ] **Step 2: Cut marketplace `v1` from `main`**

```bash
git -C marketplace branch v1 main
git -C marketplace log -1 --format=%H v1      # must print e9528d0...
```

- [ ] **Step 3: Write the failing validation test — add the `renames` map to `marketplace.json` on `main`**

Add a top-level `renames` key mapping every February plugin name to its successor, or to `null` where there is none. Thirteen entries, append-only from here:

| Former name | Maps to |
|---|---|
| `constellize-planning`, `constellize-architecture` | `constellize-design` |
| `constellize-quality`, `constellize-development`, `constellize-excellence` | `constellize-craft` |
| `constellize-deployment`, `constellize-operations` | `constellize-deliver` |
| `constellize-memory-bank` | `constellize-memory` |
| `constellize-learning`, `constellize-evolution`, `constellize-adoption`, `constellize-organization` | `constellize-grow` |
| `constellize-ai-workflow` | `null` |

- [ ] **Step 4: Run the validator to verify the map resolves**

Run: `cd marketplace && claude plugin validate .`
Expected: PASS. A bad map reports `renames.<name>: chain does not resolve`.

- [ ] **Step 5: Cherry-pick the `renames` map to `v1`, and set `v1`'s marketplace name**

On `v1` only, set `.name` to `constellize-plugins-v1`. Re-run `claude plugin validate .` on the branch; expected PASS.

- [ ] **Step 6: Commit on each branch**

```bash
git -C marketplace add .claude-plugin/marketplace.json
git -C marketplace commit -m "feat: add renames map for the February plugin layout"
```

---

### Task 2: The drift guard, failing

**Files:**
- Create: `prompt-factory/build/check-drift.ts`
- Modify: `prompt-factory/build/generate-marketplace.ts`, `prompt-factory/build/generate-website.ts` (output dir parameter only)
- Modify: `prompt-factory/package.json` (scripts)

**Interfaces:**
- Consumes: Task 1's branches.
- Produces: `npm run check:drift -- --target <marketplace|website> --against <path>`, exit 0 when every generated file matches, exit 1 with a per-file list otherwise. Both generators export `generate(outputDir: string): void` and keep their existing CLI behaviour when run directly.

- [ ] **Step 1: Make the output directory a parameter**

In each generator, replace the module-level `MARKETPLACE_DIR` / `WEBSITE_DIR` constant with an argument to an exported `generate(outputDir: string): void`, defaulting to the current relative path when invoked as a CLI so `npm run generate:marketplace` is unchanged.

- [ ] **Step 2: Write the failing test — the guard refuses a non-temp output directory**

`check-drift.ts` resolves its scratch directory from `os.tmpdir()` and throws if the resolved path is not inside it. Assert by invocation:

```bash
npx ts-node build/check-drift.ts --target marketplace --against ../marketplace --scratch ../marketplace
```
Expected: exits non-zero with a message naming the refused path, and `git -C ../marketplace status --short` is empty afterwards.

- [ ] **Step 3: Implement `check-drift.ts`**

It regenerates into a fresh `os.tmpdir()` directory, walks the generated set (every file the generator wrote, recorded as it writes), and compares each against `--against`. Files present in `--against` but not generated are **ignored** — they are not drift. Report each differing path and whether it differs in content or is missing.

- [ ] **Step 4: Add the npm scripts**

`"check:drift": "npx ts-node build/check-drift.ts"`.

- [ ] **Step 5: Run the guard against the real marketplace to verify it fails**

Run: `cd prompt-factory && npm run check:drift -- --target marketplace --against ../marketplace`
Expected: FAIL, listing every `SKILL.md` (frontmatter shape and `llm/` paths) and every plugin directory (colon vs hyphen names).

- [ ] **Step 6: Commit**

```bash
git -C prompt-factory add build/check-drift.ts build/generate-marketplace.ts build/generate-website.ts package.json
git -C prompt-factory commit -m "feat: add drift guard and parameterise generator output paths"
```

---

### Task 3: Make the marketplace generator reproduce the repo

**Files:**
- Modify: `prompt-factory/build/generate-marketplace.ts`
- Create: `prompt-factory/build/lib/paths.ts`
- Modify: `prompt-factory/content/schemas/plugins.json`
- Delete: `marketplace/scripts/migrate-paths.sh`

**Interfaces:**
- Consumes: `generate(outputDir)` and the guard from Task 2.
- Produces: `rewriteLlmPaths(body: string): string` in `build/lib/paths.ts`. Generated tree: `plugins/<hyphenated-id>/skills/<short-name>/SKILL.md`, `plugins/<hyphenated-id>/agents/<subcategory>.md`, `plugins/<hyphenated-id>/.claude-plugin/plugin.json`. Nothing else.

- [ ] **Step 1: Write the failing test — `marketplace.json`, `README.md` and the harness survive a run**

Add to `check-drift.ts` a `--target marketplace` assertion that the generated set contains no path matching `.claude-plugin/marketplace.json`, `README.md`, or `plugins/constellize-harness/**`. Run the guard; expected FAIL, because the generator writes all three today.

- [ ] **Step 2: Stop writing `marketplace.json` and `README.md`**

Delete `generateMarketplaceJson`, `generateReadme` and their call sites in `main()`. Re-run the Step 1 assertion; expected PASS.

- [ ] **Step 3: Hyphenate the plugin directory and `plugin.json` name**

Derive both from the plugin id with `:` replaced by `-`, so `constellize:memory` writes `plugins/constellize-memory/` with `"name": "constellize-memory"`.

- [ ] **Step 4: Emit the committed frontmatter shape**

`SKILL.md` frontmatter is, in this order: `name` (the bare short name, no plugin prefix), `description`, `allowed-tools` (comma-separated, omitted when empty), then a `metadata:` block nesting `prompt-id`, `argument-hint` and `model`. `context`, `user-invocable` and `disable-model-invocation` stay flat where present. Reference: `marketplace/plugins/constellize-memory/skills/establish/SKILL.md:1-9`.

- [ ] **Step 5: Read the plugin version from config**

Add `"version": "1.0.0"` to each of the five entries in `content/schemas/plugins.json`, and have `generatePluginJson` read it instead of hardcoding.

- [ ] **Step 6: Implement `rewriteLlmPaths` and apply it to every skill body**

Port the five substitutions from `marketplace/scripts/migrate-paths.sh`, in its order, including its placeholder guards against double-prefixing: `operations-memory-bank/` → `llm/operations-memory-bank/`, bare `memory-bank/` → `llm/memory-bank/`, and `construction/` → `llm/construction/` only when preceded by a backtick, space, slash, double quote, or start of line. Leave `name:` and `description:` lines untouched.

- [ ] **Step 7: Run the guard to verify the whole marketplace matches**

Run: `cd prompt-factory && npm run check:drift -- --target marketplace --against ../marketplace`
Expected: PASS, all 69 skills, 14 agents and 5 `plugin.json` files identical.

- [ ] **Step 8: Delete the superseded script and commit**

```bash
git -C marketplace rm scripts/migrate-paths.sh
git -C prompt-factory add build/ content/schemas/plugins.json
git -C prompt-factory commit -m "feat: generator reproduces the committed marketplace exactly"
```

---

### Task 4: Make the website generator reproduce the repo

**Files:**
- Modify: `prompt-factory/build/generate-website.ts`

**Interfaces:**
- Consumes: Task 2's `generate(outputDir)`.
- Produces: generated set = `public/prompts/<id>/prompt.txt` (73) and `public/personas/<category>/<subcategory>/Aggregate_Expert_Synthesis.md` (14). Nothing under `src/`.

- [ ] **Step 1: Write the failing test — the generated set contains no `src/` file, and the output compiles**

Add a `--target website` assertion that no generated path starts with `src/`, plus a step that copies the generated output over a clean website checkout and runs `tsc -b`. Run the guard; expected FAIL on the two `src/data/**/generated-metadata.*` paths.

- [ ] **Step 2: Stop writing both metadata files**

Remove the prompts-metadata and personas-metadata blocks from `main()` (`build/generate-website.ts:213-222`) and the `created: new Date()...` stamp at `:66`. Nothing imports either file; `src/data/personas/index.ts` re-exports the hand-written `metadata.ts`.

- [ ] **Step 3: Run the guard and the website build to verify both pass**

Run: `cd prompt-factory && npm run check:drift -- --target website --against ../website`
Expected: PASS — 73 prompt files and 14 persona aggregates identical.
Run: `cd website && npm run build`
Expected: PASS.

- [ ] **Step 4: Confirm determinism**

Run the generator into two temp directories and compare.
Run: `/usr/bin/diff -r "$A" "$B"`
Expected: no output. The date stamp was the only clock dependence.

- [ ] **Step 5: Commit**

```bash
git -C prompt-factory add build/generate-website.ts
git -C prompt-factory commit -m "fix: stop generating the unused website metadata files"
```

---

### Task 5: Record the source commit and wire CI

**Files:**
- Create: `marketplace/GENERATED_FROM`
- Create: `marketplace/.github/workflows/drift.yml`, `prompt-factory/.github/workflows/generators.yml`

**Interfaces:**
- Consumes: `npm run check:drift` from Tasks 2–4.
- Produces: the recorded-commit convention — a consuming repo records the prompt-factory commit its
  generated files came from, as a single 40-character SHA on one line in `GENERATED_FROM` at its root.
  The marketplace's records `main`. **The website's is written in Task 8**, because the website tracks
  prompt-factory `v1`, which does not carry the new generators until Task 6. Creating its workflow
  here would leave CI red until then.

- [ ] **Step 1: Write the failing test — a version bump is required alongside a skill change**

Add to the marketplace workflow a step that fails when the diff touches `plugins/*/skills/**` without touching that plugin's `plugin.json`. Verify by making a throwaway skill edit on a scratch branch and running the step's script locally; expected FAIL.

- [ ] **Step 2: Record the source commit in the marketplace**

```bash
git -C prompt-factory rev-parse main > marketplace/GENERATED_FROM
```

- [ ] **Step 3: Add the marketplace drift workflow**

It checks out itself plus `constellize/prompt-factory` at the SHA in its own `GENERATED_FROM` — public,
so no token — then runs `npm run check:drift --target marketplace --against <self checkout>`. The
guard compares against a recorded commit, not a moving tip, so a prompt change landing first never
turns a consumer red. The website's equivalent is Task 8 Step 6.

- [ ] **Step 4: Add the prompt-factory determinism workflow**

Runs both generators twice into temp directories and fails on any difference between the two runs. This is the check that would have caught the unused-declaration bug from Task 4.

- [ ] **Step 5: Verify each workflow's commands pass locally**

Run each workflow's script body by hand from a clean checkout.
Expected: both exit 0, and the version-bump step from Step 1 now passes on a real commit that bumps alongside a skill change.

- [ ] **Step 6: Commit in prompt-factory and the marketplace**

---

### Task 6: Regenerate the 1.x line and prove a prompt fix ships

**Files:**
- Modify: prompt-factory branch `v1` (cherry-pick from `main`)
- Create: `marketplace/GENERATED_FROM` on `v1`

**Interfaces:**
- Consumes: the generator commits from Tasks 2–4, and the recorded-commit convention from Task 5.
- Produces: prompt-factory `v1` carrying the new generators; marketplace `v1` verified byte-identical
  and recording its source commit. This is what makes goal 4 — "a prompt fix can ship to the 1.x line"
  — true rather than promised.

- [ ] **Step 1: Cherry-pick the generator commits onto prompt-factory `v1`**

The commits from Task 2 Step 6, Task 3 Step 8 and Task 4 Step 5, in that order. Content is untouched:
`v1` still carries `book-v1`'s prompts and personas.

```bash
git -C prompt-factory checkout v1
git -C prompt-factory cherry-pick <task2-sha> <task3-sha> <task4-sha>
```

- [ ] **Step 2: Verify only the generator moved**

Run: `git -C prompt-factory diff book-v1..v1 --stat -- content/prompts content/personas`
Expected: no output. Only `build/` and `content/schemas/plugins.json` differ from the tag.

- [ ] **Step 3: Run the guard on the `v1` pair**

```bash
git -C marketplace checkout v1
cd prompt-factory && npm run check:drift -- --target marketplace --against ../marketplace
```
Expected: PASS. `v1` and `main` hold the same content, so the output matches here exactly as it did in
Task 3.

- [ ] **Step 4: Write the failing test — a one-word prompt fix reaches a reader**

On `v1`, change one word in a single prompt body under `content/prompts/`, regenerate, and assert:
exactly one `SKILL.md` differs, and the drift guard reports that one file. Then run the version-bump
check from Task 5 Step 1 against the staged change.
Expected: the bump check FAILS, because the skill changed and `plugin.json` did not — which is the
whole point of the branch pin.

- [ ] **Step 5: Bump the version and confirm the check passes**

Bump that plugin's `version` to `1.0.1` in `content/schemas/plugins.json` on `v1`, regenerate, and
re-run the bump check.
Expected: PASS. Then revert the throwaway prompt edit and the bump — this step proves the workflow,
it does not ship a change.

```bash
git -C prompt-factory checkout -- content/
```

- [ ] **Step 6: Record the source commit on marketplace `v1`**

```bash
git -C prompt-factory rev-parse v1 > marketplace/GENERATED_FROM
```

- [ ] **Step 7: Commit on both `v1` branches**

```bash
git -C marketplace add GENERATED_FROM
git -C marketplace commit -m "chore: record the prompt-factory commit the 1.x plugins came from"
```

---

### Task 7: Tag `v1.0.0` and pin the published install command

**Files:**
- Modify: `marketplace/README.md:16` (on `v1`), `marketplace/docs/constellize-skills-infographic.html:497`
- Modify: `website/public/constellize-reference-card.pdf` (regenerate)
- Already done, uncommitted: `website/src/pages/resources/MarketplacePage.tsx:268`

**Interfaces:**
- Consumes: a verified, regenerated marketplace `v1` from Task 6.
- Produces: tag `v1.0.0`; every published install command reads `constellize/constellize-plugins-official#v1`.

- [ ] **Step 1: Tag `v1.0.0` on the verified `v1` tip**

Tag only after Task 3's guard passes, so the tag names a state that reproduces.

```bash
git -C marketplace tag -a v1.0.0 v1 -m "The book version of the Constellize plugins"
```

- [ ] **Step 2: Append the ref to the two remaining text places**

`#v1` — the **branch**, not the tag, so fixes reach readers while the pin keeps them off 2.0.

- [ ] **Step 3: Regenerate the reference card PDF**

There is no build script: open `marketplace/docs/constellize-skills-infographic.html` in a browser and print to PDF at `website/public/constellize-reference-card.pdf`.

- [ ] **Step 4: Verify every published copy carries the ref**

Run: `pdftotext website/public/constellize-reference-card.pdf - | grep -c '#v1'`
Expected: at least 1. Then grep the three text files for `constellize-plugins-official#v1`; expected 3 hits, 0 unpinned.

- [ ] **Step 5: Commit, and do not push the website until `v1` exists on the remote**

The website's install command points at a branch; pushing the site before the branch is pushed sends readers to a ref that does not resolve.

---

### Task 8: Store website prompt text by version

**Files:**
- Modify: `prompt-factory/build/generate-website.ts` (on `main`, then cherry-picked to `v1`)
- Modify: `website/src/App.tsx:41`, `website/src/pages/prompts/PromptDetailPage.tsx:14,29`
- Create: `website/GENERATED_FROM`, `website/.github/workflows/drift.yml`

**Interfaces:**
- Consumes: Task 4's website generated set, and the regenerated 1.x line from Task 6.
- Produces: `public/prompts/v1/<id>/prompt.txt`; route `/prompts/:version/:id`; the detail page
  fetches `/prompts/${version}/${id}/prompt.txt`; `website/GENERATED_FROM` holding prompt-factory
  `v1`'s tip.

- [ ] **Step 1: Write the failing test — the detail page resolves a version from the route**

Assert that `/prompts/v1/business-problem` renders the prompt body after the move, and that the fetched URL contains `/prompts/v1/`. Run it; expected FAIL, since the route hardcodes `v1` and the fetch omits it.

- [ ] **Step 2: Emit prompts under a version directory**

Add a version parameter to the website generator, defaulting to `v1`, and write `public/prompts/<version>/<id>/prompt.txt`.

- [ ] **Step 3: Read the version from the route**

Change the route to `/prompts/:version/:id`, take `version` from `useParams`, and use it in the fetch. The book's 66 existing `/prompts/v1/<id>` URLs keep resolving.

- [ ] **Step 4: Run the test, the guard and the build**

Expected: the test passes; `npm run check:drift -- --target website --against ../website` passes; `npm run build` passes.

- [ ] **Step 5: Verify a book link end to end**

Start the dev server and load `/prompts/v1/business-problem`.
Expected: the prompt body renders, and the network tab shows `/prompts/v1/business-problem/prompt.txt` returning 200.

- [ ] **Step 6: Cherry-pick to `v1`, record the source commit, and add the website workflow**

The website is generated from prompt-factory `v1`, so the version-directory change has to reach `v1`
before the website's recorded commit can point there.

```bash
git -C prompt-factory checkout v1 && git -C prompt-factory cherry-pick <step-2-sha>
git -C prompt-factory rev-parse v1 > website/GENERATED_FROM
```

Then add `website/.github/workflows/drift.yml`, the same shape as the marketplace's from Task 5
Step 3, checking out `constellize/prompt-factory` at the SHA in `website/GENERATED_FROM`.

- [ ] **Step 7: Verify the guard passes against the `v1` generator**

Run the guard with prompt-factory on `v1`.
Expected: PASS — the website's generated files reproduce from `v1`, which is what its `GENERATED_FROM`
now claims.

- [ ] **Step 8: Commit in both repos**

Fold the website's uncommitted 2026-10-29 work — the `#v1` pin in `MarketplacePage.tsx`, the two
persona additions to `metadata.ts`, and the 119 deletions — into this task's commits.

---

## Self-Review

**Spec coverage.** 8.1 ownership → Tasks 3, 4 (what the generator stops writing). 8.2 generator changes → Task 3, with items 2 and 6 corrected per 9a. 8.3 generator scope → Task 3 Step 1. 8.4 drift guard → Tasks 2, 5. 8.5 version lines → Task 1. 8.5.1 anchor → Task 1 Step 2. 8.5.2 two names and `renames` → Task 1 Steps 3–5. 8.6 pinning → Task 7. 8.7 versioned prompts → Task 8. 8.8 personas → explicitly out of scope, as the spec says. 9a calls 1 (cherry-pick to `v1`) → Tasks 6 and 8 Step 6, 3 (determinism) → Task 4 Step 4, 7 (recorded commit) → Tasks 5, 6 and 8, 8 (tag after verify) → Task 7 Step 1.

**Every spec requirement now has a task.** The earlier draft left §9a call 1 to "the first fix"; Steve asked for it in this pass, so Task 6 does it and proves the fix workflow end to end with a throwaway edit it then reverts.

**Type consistency.** `generate(outputDir: string)` is used identically in Tasks 2, 3, 4 and 8. `rewriteLlmPaths(body: string)` is defined in Task 3 and used nowhere else. `--target`, `--against` and `--scratch` keep the same meaning in Tasks 2–6. The version-bump check is defined in Task 5 Step 1 and reused in Task 6 Steps 4–5.

**Review Focus coverage.** Items 1–5 have tests in Tasks 3, 4, 2, 1 and 5 respectively; item 5 is additionally exercised against a real edit in Task 6.

**Proportion.** Eight tasks, no function bodies, one algorithm described in prose (the path rewriting) because the shell script's ordering is load-bearing and does not follow from the signature.
