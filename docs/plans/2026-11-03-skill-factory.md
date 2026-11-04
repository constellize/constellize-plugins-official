# Skill Factory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `prompt-factory` the single source for everything in marketplace `main` except prose under `docs/` and `GENERATED_FROM`.

**Architecture:** Two moves, in order. First, a standalone change in the marketplace deletes the harness's vendored `tsx` so the tree the generator must reproduce has no un-reproducible files in it; that tree is the **baseline**. Then the factory's `generate-marketplace.ts` grows a verbatim literal-source copier and three small emitters, and each new file set is proved correct by regenerating and comparing byte-for-byte against the baseline before the next set starts. The `FORBIDDEN` list in `check-drift.ts` shrinks one entry per task and is empty at the end.

**Tech Stack:** TypeScript on Node 26 (`ts-node`), Jest in `prompt-factory`; Markdown and JSON as generator output; GitHub Actions.

**Spec:** `docs/specs/2026-11-03-skill-factory.md` (approved 2026-11-03)

## Repositories

Two checkouts, siblings under `/Users/satkinson/Work/constellize/`:

- **`marketplace/`** — branch `main`. Task 1 only, plus `GENERATED_FROM` and `docs/releasing-1x.md` in task 9. Everything else here is *output*, never edited by hand after task 1.
- **`prompt-factory/`** — branch `main`. Tasks 2–8.

`v1` is not touched in either repo, by any task.

## Global Constraints

- **The harness must run with zero dependencies.** No `package.json`, no `node_modules`, no `npx`. (Spec decision 9.)
- **Node floor: 22.18+, 23.6+, or 24 and later** — unflagged TypeScript type stripping. Exact text to use in messages and docs: `Node 22.18+ (or 23.6+/24+)`.
- **Generated files must match the baseline byte-for-byte**, trailing bytes included. See "Trailing-byte facts" below; this is the single most likely way a task fails.
- **`v1` is frozen.** No task changes any file on branch `v1`, in either repo. `v1` keeps its vendored `tsx` and its hand-written harness.
- **The generator writes only into its output directory.** `check-drift.ts` refuses a scratch directory outside `os.tmpdir()`; do not weaken that.
- **`GENERATED_FROM` names the prompt-factory commit whose generator produced the output — not the tip.** Only task 9 touches it.
- **Prose is not generated.** `docs/specs/`, `docs/plans/`, `docs/releasing-1x.md` stay hand-written in the marketplace. `docs/constellize-skills-infographic.html` is generated.
- **Author identity in output is `Constellize`**, with no `url`. The factory's current `plugins.json` says `Steve Atkinson` + `https://constellize.com`; that is the file that is wrong (spec §8a).

## Trailing-byte facts (verified 2026-11-03)

`JSON.stringify(x, null, 2)` and the current `generateSkillMd` emit **no trailing newline**. Committed hand-written files **do** have one. Measured last byte of each:

| File | Last byte | Who must produce it |
|---|---|---|
| `plugins/constellize-memory/.claude-plugin/plugin.json` | `7d` (`}`) | generator, today |
| `plugins/constellize-memory/skills/establish/SKILL.md` | `3e` (`>`) | generator, today |
| `plugins/constellize-harness/.claude-plugin/plugin.json` | `0a` | **normalised to no-newline in task 1** |
| `plugins/constellize-harness/skills/*/SKILL.md` | `0a` | verbatim copy (task 3) |
| `plugins/constellize-harness/scripts/*.ts` | `0a` | verbatim copy (task 3) |
| `.claude-plugin/marketplace.json` | `0a` | emitter must append `\n` (task 4) |
| `README.md` | `0a` | verbatim copy (task 5) |
| `docs/constellize-skills-infographic.html` | `0a` | verbatim copy (task 6) |

**Verbatim copy means `fs.copyFileSync` or a `Buffer` round-trip — never `readFileSync(p, 'utf-8')` followed by a string write**, which is what would quietly normalise a trailing byte or a CRLF.

## Review Focus

Five things the spec requires that no task's main-line tests would otherwise exercise. Each has a test in the task named.

1. **The harness on Node below the floor** prints a one-line message naming the required version, not a syntax error or a module-resolution stack trace. (Task 2.)
2. **A literal source file whose last byte is not `\n`, or which contains CRLF,** is copied unchanged. A string round-trip breaks this silently and the drift guard would then fail on a file nobody edited. (Task 3.)
3. **A `literal` source directory named in `plugins.json` that does not exist** fails loudly at config load, rather than emitting a plugin with an empty `skills/`. The existing `getPromptsForPlugin` returns `[]` for a plugin with no `skills` block, so a typo'd path produces a valid-looking empty plugin today. (Task 3.)
4. **A hand-added file under `plugins/constellize-harness/scripts/` or `.github/`** is reported as `EXTRA` drift. The current `EXTRA` walk only covers `skills/`, `agents/` and `.claude-plugin/`, so these directories are unguarded the moment they become generated output. (Task 8.)
5. **A `renames` entry dropped from `plugins.json`** fails the build. The map is how anyone still on `constellize-planning` or the 12 other old names reaches the right plugin; losing an entry silently strands them, and nothing in the catalog would look wrong. (Task 4.)

---

## Task 1: Step 0 — remove `tsx` from the harness

Marketplace repo, branch `main`. A deliberate change to shipped files, committed on its own. The tree it leaves is the baseline every later task compares against.

**Files:**
- Modify: `plugins/constellize-harness/scripts/assess.ts:8,9`
- Modify: `plugins/constellize-harness/scripts/tier1.ts:15`
- Modify: `plugins/constellize-harness/skills/assess/SKILL.md:16`, `skills/plan/SKILL.md:16`, `skills/init/SKILL.md:16`, `skills/orchestrate/SKILL.md:18`
- Modify: `plugins/constellize-harness/.claude-plugin/plugin.json`
- Delete: `plugins/constellize-harness/scripts/package.json`, `scripts/package-lock.json`, and all 63 tracked files under `scripts/node_modules/`

`skills/execute/SKILL.md` does **not** invoke the assessor and does not change. Four skills, not five.

- [ ] **Step 1: Rewrite the three relative import specifiers from `.js` to `.ts`**

```
assess.ts:8   } from "./tier1.js";   ->   } from "./tier1.ts";
assess.ts:9   import type { AssessmentProfile, Recommendation } from "./types.js";
                                     ->   ... from "./types.ts";
tier1.ts:15   } from "./types.js";   ->   } from "./types.ts";
```

`scripts/tsconfig.json` already sets `"moduleResolution": "bundler"`, which permits `.ts` specifiers. Do not change it.

- [ ] **Step 2: Verify the assessor runs with no dependencies**

Temporarily move the vendored tree aside so nothing can resolve from it, then run from a directory that is not the plugin:

Run: `mv plugins/constellize-harness/scripts/node_modules /tmp/nm-holdback && cd /Users/satkinson/Work/constellize && node marketplace/plugins/constellize-harness/scripts/assess.ts --format json | head -5`
Expected: JSON output beginning `{` and `"dimensions"`. No `ERR_MODULE_NOT_FOUND`, no `Cannot find package 'tsx'`.

- [ ] **Step 3: Delete the vendored tree and its manifests**

```bash
git rm -r --quiet plugins/constellize-harness/scripts/node_modules
git rm --quiet plugins/constellize-harness/scripts/package.json plugins/constellize-harness/scripts/package-lock.json
rm -rf /tmp/nm-holdback
```

- [ ] **Step 4: Change the four invocations from `npx tsx` to `node`**

Each of the four lines becomes:

```
node <skill-dir>/../../scripts/assess.mjs --format json
```

Note `.mjs`, not `.ts` — task 2 adds that preflight wrapper. The command is wrong until task 2 lands, which is why the two tasks ship together as one commit at step 7.

- [ ] **Step 5: Add the Node requirement to the four skills**

Immediately below each changed command line, one line of prose: `Requires Node 22.18+ (or 23.6+/24+).`

- [ ] **Step 6: Normalise `plugins/constellize-harness/.claude-plugin/plugin.json` and bump its version**

Strip the trailing newline (last byte becomes `7d`), so `generatePluginJson` can own this file in task 3 without a special case. Set `"version"` to `1.1.0`. Leave `name`, `description` and `author` exactly as they are — task 4 reproduces the description from this string.

Run: `tail -c 1 plugins/constellize-harness/.claude-plugin/plugin.json | od -An -tx1`
Expected: ` 7d`

- [ ] **Step 7: Commit (after task 2's wrapper exists)**

```bash
git add -A plugins/constellize-harness
git commit -m "harness: drop tsx, run on plain node"
```

- [ ] **Step 8: Verify the version-bump guard is satisfied**

Run: `.github/scripts/check-version-bump.sh HEAD~1`
Expected: `OK: constellize-harness 1.0.0 -> 1.1.0` then `OK: version-bump check passed`

---

## Task 2: Node-floor preflight wrapper

Marketplace repo. `assess.ts` cannot report an old Node itself — on a Node without type stripping it fails at parse. The check has to live in a plain `.mjs` file that any Node can load. This is the spec's §8 "how the harness detects an unsupported Node", decided here.

**Files:**
- Create: `plugins/constellize-harness/scripts/assess.mjs`

**Interfaces:**
- Consumes: nothing.
- Produces: `scripts/assess.mjs`, invoked as `node .../assess.mjs [args]`. It forwards `process.argv.slice(2)` unchanged to `assess.ts` and exits with its status. Task 3 copies it verbatim; task 1 step 4 points the four skills at it.

**Test seam.** The version it checks comes from `process.env.CONSTELLIZE_NODE_VERSION ?? process.versions.node`. `process.versions` is read-only, so without this the unsupported branch could not be exercised on a machine that only has a supported Node — and an untested error path is exactly the one that ships broken. The variable is a test seam, not a supported way to run the harness; say so in a comment on the line.

- [ ] **Step 1: Write `assess.mjs`**

Plain ES module, no dependencies, no TypeScript. Behaviour:

1. Read the version from the seam above and parse into `[major, minor]`.
2. Unsupported: write to `stderr` exactly
   `constellize-harness needs Node 22.18+ (or 23.6+/24+) to run the assessor; this is Node <version>.`
   and `process.exit(1)`.
3. Supported: `await import('./assess.ts')`.

The comparison is the one thing worth writing out, because an off-by-one on the boundary releases is the whole point of the file:

```js
const version = process.env.CONSTELLIZE_NODE_VERSION ?? process.versions.node; // seam: tests only
const [major, minor] = version.split('.').map(Number);
const ok = major > 23 || (major === 23 && minor >= 6) || (major === 22 && minor >= 18);
```

- [ ] **Step 2: Verify the supported path**

Run: `cd /Users/satkinson/Work/constellize && node marketplace/plugins/constellize-harness/scripts/assess.mjs --format json | head -3`
Expected: JSON output, identical first lines to running `assess.ts` directly.

- [ ] **Step 3: Verify the boundary versions through the seam**

Run, from `/Users/satkinson/Work/constellize`:

```bash
for v in 20.19.0 22.17.0 22.18.0 23.5.0 23.6.0 24.0.0 26.8.2; do
  printf '%-9s ' "$v"
  CONSTELLIZE_NODE_VERSION=$v node marketplace/plugins/constellize-harness/scripts/assess.mjs \
    --format json >/dev/null 2>/tmp/err; echo "exit=$? $(head -c 80 /tmp/err)"
done
```

Expected: `20.19.0`, `22.17.0` and `23.5.0` give `exit=1` and the message naming `Node 22.18+ (or 23.6+/24+)`; `22.18.0`, `23.6.0`, `24.0.0` and `26.8.2` give `exit=0` and no stderr. The three failing versions are the ones immediately below each boundary, which is where an off-by-one would hide.

- [ ] **Step 4: Commit — this is task 1's step 7**

Tasks 1 and 2 land as one commit. Neither is shippable alone: task 1 points the skills at a file task 2 creates.

---

## Task 3: Literal source in the factory, and the harness plugin generated

Factory repo. The generator gains the ability to copy a tree of files verbatim into a plugin, and the harness becomes the first user of it. After this task the whole `plugins/` tree is generated.

**Files:**
- Create: `content/literal/constellize-harness/` — a verbatim copy of the baseline's `plugins/constellize-harness/skills/` and `scripts/`. **Ten files**: five `SKILL.md` (`assess`, `execute`, `init`, `orchestrate`, `plan`), and `scripts/assess.mjs`, `assess.ts`, `tier1.ts`, `types.ts`, `tsconfig.json`. Not `package.json` or `package-lock.json` — task 1 deleted them.
- Modify: `build/lib/types.ts` — `PluginDefinition`
- Modify: `build/lib/parser.ts` — `validatePluginsConfig`
- Modify: `build/generate-marketplace.ts` — `generatePlugin`, and the header comment that currently says the harness is deliberately not generated
- Modify: `content/schemas/plugins.json` — append the harness entry
- Modify: `build/check-drift.ts` — drop `plugins/constellize-harness/.*` from `forbidden`
- Test: `build/lib/__tests__/literal.test.ts`

**Interfaces:**
- Consumes: the baseline tree from tasks 1–2.
- Produces: `PluginDefinition.literal?: { source: string }`, where `source` is a directory name under `content/literal/`. `copyLiteralTree(sourceDir: string, destDir: string): string[]` in `build/generate-marketplace.ts`, returning the relative paths it wrote, sorted. `destDir`, not `pluginDir`: tasks 5–7 pass the output root and subdirectories of it, not a plugin directory.

- [ ] **Step 1: Write the failing tests**

```ts
// build/lib/__tests__/literal.test.ts
describe('copyLiteralTree', () => {
  it('copies a file with no trailing newline unchanged', ...);
  it('copies a file containing CRLF unchanged', ...);          // Review Focus 2
  it('copies nested directories and returns sorted relative paths', ...);
});

describe('validatePluginsConfig', () => {
  it('rejects a literal.source directory that does not exist', ...); // Review Focus 3
  it('rejects a plugin with neither skills, agents nor literal', ...);
});
```

Each copy test writes a fixture into a `fs.mkdtempSync` directory, copies it, and asserts with `Buffer.equals` on the raw bytes — not on strings.

- [ ] **Step 2: Run them to verify they fail**

Run: `npx jest build/lib/__tests__/literal.test.ts`
Expected: FAIL — `copyLiteralTree is not a function`.

- [ ] **Step 3: Add `literal` to `PluginDefinition` and validate it**

`literal?: { source: string }` in `build/lib/types.ts`. In `validatePluginsConfig`, for each plugin: if `literal` is present, `literal.source` must be a non-empty string naming an existing directory under `<contentDir>/literal/`, reported in the same all-errors-at-once style as the existing checks. A plugin with none of `skills`, `agents` or `literal` is an error.

- [ ] **Step 4: Implement `copyLiteralTree(sourceDir, pluginDir)` in `build/generate-marketplace.ts`**

Recursive walk; `fs.mkdirSync(..., { recursive: true })` then `fs.copyFileSync` per file. Byte copy, never a string round-trip; `copyFileSync` also carries the mode, which task 7 depends on. Call it from `generatePlugin` when `plugin.literal` is set, after the existing skills/agents loops so a literal tree cannot be clobbered by them.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `npx jest build/lib/__tests__/literal.test.ts`
Expected: PASS

- [ ] **Step 6: Copy the baseline harness tree into `content/literal/constellize-harness/`**

```bash
cd /Users/satkinson/Work/constellize
rsync -a --delete \
  marketplace/plugins/constellize-harness/skills \
  marketplace/plugins/constellize-harness/scripts \
  prompt-factory/content/literal/constellize-harness/
```

- [ ] **Step 7: Append the harness to `content/schemas/plugins.json`**

Last in the `plugins` array, so the generated catalog order in task 4 matches the committed one. `version` must be `1.1.0` to match task 1 step 6. `description` must be the exact string `Project orchestration: assess state, plan next steps, execute constellize skills`.

```json
{
  "id": "constellize:harness",
  "version": "1.1.0",
  "name": "Constellize Harness",
  "description": "Project orchestration: assess state, plan next steps, execute constellize skills",
  "literal": { "source": "constellize-harness" }
}
```

- [ ] **Step 8: Drop the harness from `forbidden` in `check-drift.ts`**

The regex becomes `/^(\.claude-plugin\/marketplace\.json|README\.md)$/`.

- [ ] **Step 9: Verify the generator reproduces the baseline harness byte-for-byte**

Run: `cd /Users/satkinson/Work/constellize/prompt-factory && npm run check:drift -- --target marketplace --against ../marketplace`
Expected: `No drift: 99 generated marketplace files match ...`. The baseline today is **88**; this task adds the harness's ten literal files plus its generated `plugin.json`. If the count is 99 but it reports `CONTENT plugins/constellize-harness/...`, the cause is almost certainly a trailing byte — `cmp` the file against the kept scratch directory the tool names in its output.

- [ ] **Step 10: Verify determinism**

Run: `.github/scripts/check-determinism.sh`
Expected: `OK: marketplace generator is deterministic (99 files)` and the same for website.

- [ ] **Step 11: Commit**

```bash
git add build content
git commit -m "feat: generate the harness plugin from literal source"
```

---

## Task 4: Generate `marketplace.json`

Factory repo. The catalog stops being hand-written. This is the task that fixes the identity discrepancy, and the one where a mistake reaches every installer.

**Files:**
- Modify: `content/schemas/plugins.json` — the `marketplace` block, plus a new `renames` block
- Modify: `build/generate-marketplace.ts` — new `generateMarketplaceJson`
- Modify: `build/check-drift.ts` — drop `marketplace.json` from `forbidden`
- Modify: `.github/workflows/drift.yml` in the **marketplace** repo is *not* touched here; see task 7
- Test: `build/lib/__tests__/marketplace-json.test.ts`

**Interfaces:**
- Consumes: `PluginsConfig` from task 3, with `marketplace` and `renames`.
- Produces: `generateMarketplaceJson(config: PluginsConfig): string` — the complete file contents **including the trailing newline**. Returns a string, so the test can assert on exact bytes without touching the filesystem.

- [ ] **Step 1: Write the failing tests**

```ts
describe('generateMarketplaceJson', () => {
  it('emits owner name "Constellize" and no url', ...);
  it('ends with exactly one newline', ...);
  it('lists plugins in plugins.json order, harness last', ...);
  it('gives each entry name, source "./plugins/<name>" and description, and nothing else', ...);
  it('carries all 13 renames, including the null-valued constellize-ai-workflow', ...); // Review Focus 5
  it('omits $schema', ...);
});
```

The renames test asserts the full expected map as a literal, so dropping an entry fails here rather than stranding an installer.

- [ ] **Step 2: Run them to verify they fail**

Run: `npx jest build/lib/__tests__/marketplace-json.test.ts`
Expected: FAIL — `generateMarketplaceJson is not a function`.

- [ ] **Step 3: Correct the `marketplace` block and add `renames` to `plugins.json`**

`owner` becomes `{ "name": "Constellize" }` — the `url` is removed. `name` and `description` already match the committed catalog and do not change. Add a `renames` object holding the 13 entries exactly as the committed `.claude-plugin/marketplace.json` has them, `"constellize-ai-workflow": null` included.

- [ ] **Step 4: Implement `generateMarketplaceJson(config)` and write it from `generate()`**

Shape: `{ name, owner, description, plugins: [...], renames }`, in that key order. Each plugin entry is `{ name: hyphenatePluginId(p.id), source: './plugins/' + hyphenatePluginId(p.id), description: p.description }` — no `version` key; the committed catalog has none. Serialise with `JSON.stringify(x, null, 2) + '\n'`.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `npx jest build/lib/__tests__/marketplace-json.test.ts`
Expected: PASS

- [ ] **Step 6: Drop `marketplace.json` from `forbidden`**

The regex becomes `/^README\.md$/`.

- [ ] **Step 7: Verify byte-for-byte and determinism**

Run: `npm run check:drift -- --target marketplace --against ../marketplace && .github/scripts/check-determinism.sh`
Expected: `No drift: 100 generated marketplace files match ...`, then both generators deterministic.

- [ ] **Step 8: Commit**

```bash
git add build content
git commit -m "feat: generate .claude-plugin/marketplace.json"
```

---

## Task 5: Generate `README.md`

Factory repo. 74 lines of prose that an installer reads, so it is output, not a design document. It carries `main`'s install command; `v1`'s differs and stays hand-written on that branch (spec §8a — the generator has no line parameter).

**Files:**
- Create: `content/literal/marketplace-root/README.md` — verbatim copy of the baseline `marketplace/README.md`
- Modify: `build/generate-marketplace.ts` — emit it from `generate()` via `copyLiteralTree`
- Modify: `build/check-drift.ts` — delete the `forbidden` block entirely
- Test: covered by the drift run; no new unit test (the file is a byte copy, and `copyLiteralTree` is already tested in task 3)

- [ ] **Step 1: Copy the README into the factory**

```bash
cp /Users/satkinson/Work/constellize/marketplace/README.md \
   /Users/satkinson/Work/constellize/prompt-factory/content/literal/marketplace-root/README.md
```

- [ ] **Step 2: Emit it from `generate()`**

`copyLiteralTree(path.join(contentDir, 'literal', 'marketplace-root'), outputDir)` — the output root, not a plugin directory. Goal 2 is reached here, so also delete the `if (target === 'marketplace')` forbidden block in `check-drift.ts` and the comment above it.

- [ ] **Step 3: Verify byte-for-byte**

Run: `npm run check:drift -- --target marketplace --against ../marketplace`
Expected: `No drift: 101 generated marketplace files match ...`, with `README.md` in the set. Confirm the last byte survived: `tail -c 1` on the generated copy gives `0a`.

- [ ] **Step 4: Commit**

```bash
git add build content
git commit -m "feat: generate README.md; delete the marketplace FORBIDDEN list"
```

---

## Task 6: Move the infographic and the card builder

Factory repo plus two deletions in the marketplace. The infographic becomes generated output; the card builder moves and is **not** emitted.

**Author's call, stated for the record:** the card builder lives only in the factory. The spec says it "moves into the factory" and that it reads the factory's source copy of the infographic; emitting a second copy into the marketplace would leave two places to run it, and its PDFs go to `website/public/`, not to the marketplace. So `marketplace/scripts/` is deleted outright.

**Files:**
- Create: `content/literal/marketplace-docs/constellize-skills-infographic.html` — verbatim copy
- Create: `scripts/build-reference-card.mjs` in the factory root — moved from the marketplace
- Modify: that script's `SOURCE_HTML` constant
- Modify: `build/generate-marketplace.ts` — emit the infographic into `docs/`
- Delete (marketplace): `scripts/build-reference-card.mjs` — the only file in that directory, so `marketplace/scripts/` goes with it
- Unchanged (marketplace): `docs/constellize-skills-infographic.html` stays committed. It becomes generated output rather than leaving the repo.

- [ ] **Step 1: Copy the infographic into the factory and emit it**

```bash
cp /Users/satkinson/Work/constellize/marketplace/docs/constellize-skills-infographic.html \
   /Users/satkinson/Work/constellize/prompt-factory/content/literal/marketplace-docs/
```

Emit with `copyLiteralTree(.../literal/marketplace-docs, path.join(outputDir, 'docs'))`.

- [ ] **Step 2: Move the card builder and repoint its source**

```bash
git -C /Users/satkinson/Work/constellize/marketplace rm --quiet scripts/build-reference-card.mjs
```

In the factory's copy, `SOURCE_HTML` becomes
`path.join(REPO_ROOT, 'content', 'literal', 'marketplace-docs', 'constellize-skills-infographic.html')`.
`REPO_ROOT` is now the factory root, so the default output path `path.join(REPO_ROOT, '..', 'website', 'public')` still resolves correctly — the factory is a sibling of `website/`. Leave the `LINES` map, the `UNPINNED`/`PINNED` constants and all three assertions untouched.

- [ ] **Step 3: Verify the card still builds, both lines**

Run: `cd /Users/satkinson/Work/constellize/prompt-factory && node scripts/build-reference-card.mjs`
Expected: both PDFs written to `../website/public/`, the v1 alias written, and the script's own assertions pass — one page each, expected page box, and the footer carrying the expected install command.

- [ ] **Step 4: Verify the PDFs match what shipped, by content rather than by bytes**

Headless Chrome stamps a creation date into every PDF, so `git status` will always show both files modified and byte-equality is the wrong test — this is why §8a keeps the PDFs out of the drift guard. Check the three things that would actually regress:

```bash
cd /Users/satkinson/Work/constellize/website/public
for f in constellize-reference-card-v1.pdf constellize-reference-card-v2.pdf; do
  echo "--- $f"; grep -ac '/Type */Page[^s]' "$f"; strings "$f" | grep -c 'MediaBox'
done
git diff --stat constellize-reference-card-v1.pdf
```

Expected: one page each; the page box present; and `git diff --stat` showing a small delta consistent with a timestamp, not a wholesale rewrite. The builder's own assertions in step 3 are the real check — they already verify the page count, the page box and that the footer carries the expected install command.

Then confirm the v1 card is still the pinned one and v2 still unpinned:

Run: `for l in v1 v2; do echo -n "$l: "; strings constellize-reference-card-$l.pdf | grep -o 'constellize-plugins-official#\?v\?1\?' | head -1; done`
Expected: `v1:` shows the `#v1` suffix, `v2:` shows the bare repository name. If both look alike, the per-line injection broke — the failure that shipped a card with no install command at all once before.

- [ ] **Step 5: Verify drift**

Run: `npm run check:drift -- --target marketplace --against ../marketplace`
Expected: `No drift: 102 generated marketplace files match ...`, with `docs/constellize-skills-infographic.html` in the set.

- [ ] **Step 6: Commit (both repos)**

```bash
# factory
git add build content scripts
git commit -m "feat: generate the infographic; move the card builder into the factory"
# marketplace
git commit -am "chore: the card builder now lives in prompt-factory"
```

---

## Task 7: Generate the marketplace's two CI files

Factory repo. `.github/workflows/drift.yml` and `.github/scripts/check-version-bump.sh` become generated output.

**Constraint worth re-reading before starting:** GitHub Actions reads a workflow from the pushed branch's own commit. So this generates `main`'s workflow only; `v1` keeps its hand-written copy and the two must not be assumed to match. And the drift guard becomes generated output that checks generated output — a broken generated workflow disables the check that would have caught it, so the factory's tests are what protect this file.

**Files:**
- Create: `content/literal/marketplace-github/workflows/drift.yml`, `content/literal/marketplace-github/scripts/check-version-bump.sh` — verbatim copies
- Modify: `build/generate-marketplace.ts` — emit into `.github/`
- Test: `build/lib/__tests__/github-literal.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
describe('generated .github', () => {
  it('emits drift.yml and check-version-bump.sh', ...);
  it('preserves the shell script executable bit', ...);
});
```

The executable bit is the trap here: `fs.copyFileSync` preserves mode, but a `writeFileSync` fallback would not, and a non-executable `check-version-bump.sh` makes the workflow's last step fail with `Permission denied` in CI rather than anywhere a test would see it.

- [ ] **Step 2: Run it to verify it fails**

Run: `npx jest build/lib/__tests__/github-literal.test.ts`
Expected: FAIL — no `.github` in the generated output.

- [ ] **Step 3: Copy both files in and emit them**

```bash
mkdir -p /Users/satkinson/Work/constellize/prompt-factory/content/literal/marketplace-github/{workflows,scripts}
cp /Users/satkinson/Work/constellize/marketplace/.github/workflows/drift.yml \
   /Users/satkinson/Work/constellize/prompt-factory/content/literal/marketplace-github/workflows/
cp /Users/satkinson/Work/constellize/marketplace/.github/scripts/check-version-bump.sh \
   /Users/satkinson/Work/constellize/prompt-factory/content/literal/marketplace-github/scripts/
```

Emit with `copyLiteralTree(.../literal/marketplace-github, path.join(outputDir, '.github'))`.

- [ ] **Step 4: Run the test to verify it passes**

Run: `npx jest build/lib/__tests__/github-literal.test.ts`
Expected: PASS

- [ ] **Step 5: Verify drift and determinism**

Run: `npm run check:drift -- --target marketplace --against ../marketplace && .github/scripts/check-determinism.sh`
Expected: `No drift: 104 generated marketplace files match ...`; both generators deterministic.

- [ ] **Step 6: Commit**

```bash
git add build content
git commit -m "feat: generate the marketplace's drift workflow and version-bump script"
```

---

## Task 8: Widen the `EXTRA` guard to the whole generated-owned set

Factory repo. `FORBIDDEN` is gone; without this task `EXTRA` still only watches three directories per plugin, so goal 2 would be hollow everywhere else.

**Files:**
- Modify: `build/check-drift.ts` — the `EXTRA` block
- Test: `build/__tests__/check-drift-extra.test.ts`

**Interfaces:**
- Produces: a module-level constant `GENERATED_OWNED` listing the paths the marketplace generator owns completely, so a later reader can see the boundary in one place:
  `['plugins', '.claude-plugin', '.github', 'docs/constellize-skills-infographic.html', 'README.md']`.

- [ ] **Step 1: Write the failing tests**

```ts
describe('EXTRA drift', () => {
  it('flags a hand-added file under plugins/<id>/scripts/', ...);        // Review Focus 4
  it('flags a hand-added file under .github/', ...);                     // Review Focus 4
  it('does not flag docs/specs/, docs/plans/ or GENERATED_FROM', ...);
  it('does not flag docs/releasing-1x.md', ...);
});
```

Each test builds a fake `--against` tree in a temp directory alongside a fake generated set and asserts on the problem list.

- [ ] **Step 2: Run them to verify they fail**

Run: `npx jest build/__tests__/check-drift-extra.test.ts`
Expected: FAIL — the `plugins/<id>/scripts/` and `.github/` cases report no problem.

- [ ] **Step 3: Replace the per-plugin `EXTRA` walk with a `GENERATED_OWNED` walk**

For each entry in `GENERATED_OWNED` that exists under `--against`: walk it, and report `EXTRA` for any file the generator did not produce. Directory entries walk recursively; the two file entries are compared directly. Drop the `['skills','agents','.claude-plugin']` sub-directory list and the plugin-id derivation it needed — `plugins` as a whole is now owned, which is strictly stronger.

Keep the existing behaviour that anything *outside* `GENERATED_OWNED` is ignored: that is what lets `docs/specs/`, `docs/plans/`, `docs/releasing-1x.md` and `GENERATED_FROM` stay hand-written.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `npx jest build/__tests__/check-drift-extra.test.ts`
Expected: PASS

- [ ] **Step 5: Verify the real repository is clean under the stronger guard**

Run: `npm run check:drift -- --target marketplace --against ../marketplace`
Expected: `No drift`. An `EXTRA` here names a real file in the marketplace that nothing generates — resolve it by bringing the file into the factory or by adding it to the ignored set, deliberately, not by narrowing `GENERATED_OWNED` to make the message go away.

- [ ] **Step 6: Run the whole factory suite**

Run: `npx jest`
Expected: PASS, all suites.

- [ ] **Step 7: Commit**

```bash
git add build
git commit -m "feat: EXTRA drift covers every generated-owned path"
```

---

## Task 9: Release

Both repos. Nothing here changes behaviour; it makes the new guarantee the one CI enforces.

**Files:**
- Modify (marketplace): `GENERATED_FROM`, `docs/releasing-1x.md`
- Modify (factory): `package.json` version

- [ ] **Step 1: Push the factory first**

The invariant requires the commit named by `GENERATED_FROM` to be reachable before anything names it.

```bash
cd /Users/satkinson/Work/constellize/prompt-factory
npm version minor --no-git-tag-version
git commit -am "chore: 0.4.0"
git push
git rev-parse HEAD
```

Expected: push succeeds and `git rev-parse HEAD` prints the SHA to use in step 2.

- [ ] **Step 2: Write that SHA into `GENERATED_FROM`, then prove it is reachable**

```bash
cd /Users/satkinson/Work/constellize
git -C prompt-factory rev-parse HEAD > marketplace/GENERATED_FROM
git -C prompt-factory fetch origin
git -C prompt-factory merge-base --is-ancestor \
  "$(tr -d '[:space:]' < marketplace/GENERATED_FROM)" origin/main && echo REACHABLE
```

Expected: `REACHABLE`, and `GENERATED_FROM` holds a 40-character SHA with a trailing newline (the existing file has one). A failure here means CI would check out a commit that is not on the remote, and the drift job would fail on every push from then on — the exact trap the invariant exists to prevent.

- [ ] **Step 3: Update `docs/releasing-1x.md`**

The release runbook is hand-written prose and the factory does not own it. Change the "If the card changed" section to say the builder now runs from `prompt-factory`, with the new command, and add a line that `main`'s `.github/` and `README.md` are generated so a fix to either is a factory change.

- [ ] **Step 4: Push the marketplace and read the CI step output**

Run: `cd /Users/satkinson/Work/constellize/marketplace && git push`
Then read the drift workflow run's **step output**, not its conclusion: the "Generated files match the recorded commit" step must print `No drift: 104 generated marketplace files match` — 104, up from the 88 this project started with — and the version-bump step must print `OK`.
Expected: both green, with those strings present. A green run whose drift step printed nothing is a no-op, not a pass.

- [ ] **Step 5: Confirm `v1` is untouched in both repos**

Run: `for r in prompt-factory marketplace; do git -C /Users/satkinson/Work/constellize/$r log --oneline origin/v1 -1; done`
Expected: the same two commits as before this project started.

---

## Verification summary

| Spec requirement | Task |
|---|---|
| Goal 1 — factory owns everything but prose and `GENERATED_FROM` | 3, 4, 5, 6, 7 |
| Goal 2 — `FORBIDDEN` deleted | 5 (deleted), 8 (`EXTRA` made to carry the weight) |
| Goal 3 — line differences become inputs | 4 (catalog), 5 (README) — **only half satisfied, see below** |
| Goal 4 — harness ships with no dependencies | 1 |
| Goal 5 — harness becomes testable | 3 (its source now sits in a repo with Jest and CI; no tests written, per decision 6) |
| Decision 9 — `tsx` removed | 1, 2 |
| Decision 11 — harness `SKILL.md` as literal source | 3 |
| §8a — committed `marketplace.json` canonical, factory schema corrected | 4 |
| §8a — card builder relocated, not drift-covered | 6 |
| §8a — `EXTRA` must cover `scripts/` | 8 |
| §8b — no website files touched | every task; none lists a `website/` file except the card PDFs, which are not website source |
| Anti-goal 5 — harness no longer Apple-Silicon-only | 1 |

## Known tension in the spec, carried deliberately

**Goal 3 is only half reachable, and the plan does not pretend otherwise.** It asks that the files
differing by hand between `main` and `v1` "become generator inputs rather than a divergence a human
has to remember." But decision 1 freezes `v1` and §8a settles that the generator emits `main`'s
values only. So after this project the `main` side of each of those files is generated and the `v1`
side is still hand-written: a fix that must apply to both is still two edits, and a human still has
to remember the second. What the project does deliver is that **nobody has to remember the
divergence while working on `main`** — which is where all new work happens — and the drift guard
makes a mistake on that side impossible rather than merely unlikely.

Closing the other half would mean un-freezing `v1`, which the spec rules out in decision 1 and in
the `v1` constraint. Raise it as its own piece of work if the two-edit cost ever bites; do not
quietly widen this project's scope to fix it.
