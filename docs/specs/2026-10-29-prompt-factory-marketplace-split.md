# Design: The Split Between prompt-factory and the Marketplace

**Date**: 2026-10-29
**Status**: **Approved by Steve 2026-10-29.** Plan:
`marketplace/docs/plans/2026-10-29-prompt-factory-marketplace-split.md`. Nothing is built.
**Author**: Claude, from brainstorming sessions with Steve Atkinson on 2026-10-17, 10-24, 10-28 and 10-29
**Project**: 1 of 4 (then marketplace 2.0, then delivery, then Copernicus)
**Memory bank**: `memory-bank/systemPatterns.md` "Content Architecture",
`memory-bank/activeContext.md`

---

## 1. Intent and why

prompt-factory is supposed to be the single source of the Constellize prompt text. Since 2026-05-28
it has not been: the marketplace was hand-edited four times downstream of the generator, and the
generator can no longer be run without destroying those edits. The source stopped being the source,
quietly, and nobody found out for five months.

Two things now depend on fixing that.

**The book's prompts must stay amendable.** The book links to 66 prompt pages on constellize.com and
is printed. If a prompt turns out to be wrong, Steve needs to fix the words and have the fix reach
both the website and the marketplace plugins, without that fix dragging in unrelated changes.

**The method has to move forward at the same time.** Marketplace 2.0 adds a feature workflow, new
skills and the harness. That development cannot be blocked on the book's line, and must not leak into
it.

So this project establishes who owns what, makes the generator runnable again, and puts a guard in
place so the next hand edit is caught in minutes rather than months.

---

## 2. What Steve decided

Recorded as decided, with dates. Everything else in this document is a proposal.

| Date | Decision |
|---|---|
| 2026-10-24 | **prompt-factory owns the words; the marketplace owns the code.** Confirmed with "yes" |
| 2026-10-24 | **Today's marketplace is 1.x, the book version.** 1.x is kept and stays fixable; 2.0 is developed on `main` |
| 2026-10-24 | **The tag `book-v1`** marks the book version of the prompts: prompt-factory `3c18af9` |
| 2026-10-28 | **Book readers are pinned to 1.x**, not given the latest |
| 2026-10-28 | **Project order is 1, 2, 4, then 3** — this project first |
| 2026-10-29 | **This design lives in `marketplace/docs/specs/`** |
| 2026-10-29 | **Two marketplace names**: `constellize-plugins-v1` for the pinned reader line, `constellize-plugins-official` for main as it becomes 2.0 |
| 2026-10-29 | **The marketplace's version numbering jumps from 0.3.2 to 1.0.0**, and the reference card is regenerated |

Rejected along the way: putting the scripts in prompt-factory too. One place for everything, but
TypeScript with tests and a build would sit in a content repo, and every script change would become
edit there, regenerate, test here.

---

## 3. Goals

1. **The generator can be run again** without destroying anything in the marketplace.
2. **Every generated file is reproducible** from a prompt-factory commit, byte for byte.
3. **Hand edits to generated files are caught automatically**, not by an audit five months later.
4. **A prompt fix can ship to the 1.x line** — website text and marketplace plugins — without
   pulling in 2.0 work.
5. **1.x and 2.0 can both exist** and be installable, with book readers landing on 1.x.

## 4. Non-goals

- Changing any prompt's words. This project moves no content.
- Building the 2.0 feature workflow. That is project 2.
- Fixing the harness's own bugs (its assessor paths, the uncomputed dimensions, the missing tiers).
- Touching the course. That is project 4 in the new order.
- Adding tests to the harness, which has none.

## 5. Anti-goals

Things that would make this a failure even if the mechanics worked.

- **A generator nobody dares run.** If the drift guard is advisory, or regenerating still risks
  clobbering hand-written files, we are back where we started with extra ceremony.
- **A second source of truth.** If the fix is "remember not to edit those files", it will fail the
  same way it failed in May.
- **Breaking a published install command.** Readers following the website must land on something that
  exists. The tag comes before the text that points at it.
- **Making a prompt fix expensive.** If shipping a one-word correction to 1.x takes a day of branch
  surgery, Steve will stop doing it, and the book's promise goes with it.

---

## 6. Constraints

- **The workspace root is not a git repo.** Each folder is its own repository. There is no commit that
  spans them, so cross-repo consistency has to be enforced by a check, not by a merge.
- **The book is read-only to agents** and is already published at v0.6.2.
- **The generators write to relative sibling paths** (`../marketplace`, `../website`). Running them in
  the real workspace overwrites those repos in place. Any comparison must be done in scratch, with the
  recipe in `memory-bank/techContext.md` "Working Notes and Gotchas".
- **Claude Code detects plugin updates by version string**, not by git. Every fix on the 1.x line must
  bump `plugin.json`.
- **One marketplace per `name` per user**, and plugins with the same names conflict when two are
  enabled.
- **`prompt-factory/release-new-version.sh` pushes commits and tags for six repos without asking.**
  It last ran in March 2026. It must not be part of this workflow unless it is changed first.
- Solo maintainer. Anything that needs two people to stay in step will drift.

---

## 7. Current state, verified 2026-10-28/29

### What the generator actually does

`prompt-factory/build/generate-marketplace.ts` (run as `npm run generate:marketplace`) reads
`content/prompts/**` (73 prompts), `content/personas/**` and `content/schemas/plugins.json`
(**5 plugin definitions**), and writes into `../marketplace`:

- `plugins/<plugin.id>/skills/<short-name>/SKILL.md`
- `plugins/<plugin.id>/agents/<subcategory>.md`
- `plugins/<plugin.id>/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `README.md`

### Four hand edits stand between that output and the repo

| # | Commit | Date | What was changed by hand |
|---|---|---|---|
| 1 | `9a4e293` | 05-28 | Skill frontmatter rewritten into the agentskills.io format |
| 2 | `816d5e5` | 05-30 | Plugin directories renamed from colons to hyphens, so Claude Code would register them |
| 3 | `eb7d507` | 06-22 | Paths moved under `llm/`, by `marketplace/scripts/migrate-paths.sh` |
| 4 | — | — | **`README.md`**, whose generated install command names the wrong repository (see below) |

Edits 1–3 were already recorded. **Edit 4 is new in this design**: the generator's README template
tells readers to add `constellize/marketplace`, while the committed `README.md:16` says
`constellize/constellize-plugins-official`. The README is a generated file carrying a hand-fixed
install command — and it is one of the four places that must be pinned.

Applying `migrate-paths.sh` to the generator's output at `3c18af9` makes all 69 skill bodies match the
repo. The remaining differences are frontmatter and directory names.

**Verified 2026-10-29 by regenerating both generators in a scratch workspace:**

- **All 14 agents match byte for byte** across the five plugins. The one unverified part of the 1.x
  line is now green, and the old landing step "compare the agents" is done.
- **All 69 skill bodies match** after `migrate-paths.sh`, and **all 73 website `prompt.txt` files
  match with no transformation at all.**
- The marketplace generator is **deterministic**. The website generator is **not**:
  `build/generate-website.ts:66` stamps `created` with today's date.

### What re-running the generator today would destroy

This is the concrete harm, not a hypothetical:

1. **The harness would vanish from `marketplace.json`.** The generator builds that file from the
   5 plugin definitions; the committed file lists 6, including `constellize-harness`.
2. **Every plugin directory would be renamed back to colons**, un-registering all five plugins.
3. **The README's install command would revert** to a repository that does not exist.
4. **All skill frontmatter would revert** out of the agentskills format.
5. **Every path would revert** from `llm/` back to root-level.

### Repository state

- **prompt-factory**: clean, on `main` at `3c18af9` — *the same commit as `book-v1`*. Main has not
  moved past the book version, so 2.0 development has not started. The tag is annotated and **local
  only, not pushed**.
- **marketplace**: clean, on `main` at `e9528d0`. Tags stop at `v0.3.2` (2026-03-06); there is
  **no `v1.0.0`**. All six plugins read `version: 1.0.0` in `plugin.json`, and `marketplace.json`
  carries no `version` fields.
- **website**: 2 uncommitted changes, not from these sessions.

---

## 8. The design

### 8.1 Ownership boundary

| Owner | Files |
|---|---|
| **prompt-factory** | every prompt and persona; every `SKILL.md`; every `agents/*.md`; each plugin's `plugin.json`; the website's `prompt.txt` files and generated metadata |
| **marketplace** | `scripts/`, the whole of `plugins/constellize-harness/`, `docs/`, `README.md`, `.claude-plugin/marketplace.json`, `LICENSE` |

Two deliberate moves away from today's behaviour:

- **`marketplace.json` becomes hand-written.** It is the one file that has to name plugins the
  generator does not know about, starting with the harness. Making the generator own it is what would
  delete the harness, and teaching the generator about a hand-written plugin reintroduces the
  coupling this split exists to remove.
- **`README.md` becomes hand-written.** It carries the pinned install command, which belongs to the
  release, not to the content. The generator stops writing it.

A mixed skill — prompt plus script — has its `SKILL.md` generated and its scripts hand-written beside
it. Nothing in 1.x is mixed today.

### 8.2 Generator changes, on `main` only

`book-v1` must keep producing today's output, so all of this lands on `main` after the `v1` branch is
cut. The generator absorbs the three mechanical hand edits so its output *is* the repo:

1. **Hyphenated plugin directories.** Write `plugins/constellize-memory/`, not
   `plugins/constellize:memory/`. Derive the directory from the plugin id by replacing `:` with `-`.
2. **The committed skill frontmatter shape.** *(Corrected 2026-10-29 after review.)* All 74 committed
   `SKILL.md` files, the hand-written harness ones included, use a **bare short name** —
   `name: establish` — with `prompt-id`, `argument-hint` and `model` nested under `metadata:`. No
   committed name carries a colon or a plugin prefix. The generator must reproduce that shape. The
   earlier draft of this item said to emit `constellize-memory:establish`, which would have broken
   byte-identity by construction and renamed every skill on the line that is meant to be frozen for
   book readers. Same for `plugin.json`'s `name`: committed is `constellize-memory`, the generator
   emits `constellize:memory`.
3. **agentskills.io frontmatter**, as `9a4e293` wrote it by hand.
4. **`llm/` paths**, as `migrate-paths.sh` rewrites them. Fold the script's substitutions into the
   generator and retire the script, so there is one transformation rather than a pipeline.
5. **Stop writing `marketplace.json` and `README.md`.**
6. **Stop hardcoding `version: '1.0.0'`** in `plugin.json`. The version is a release fact, and the 1.x
   line needs to bump it on every fix. Read it from a per-plugin field in
   `content/schemas/plugins.json`.

### 8.3 Generator scope

The generator writes only the files in its column of 8.1 and never deletes a directory wholesale.
Specifically: it must not create, modify or remove anything under
`plugins/constellize-harness/`, `scripts/`, `docs/`, `README.md` or `.claude-plugin/`.

### 8.4 Drift guard

A check that regenerates into a scratch directory and fails on any difference in the generated files.

- It must **not** write into the real `../marketplace` or `../website`. Today's hardcoded relative
  paths make that the default, so the output directory becomes a parameter.
- It compares only the generated set, and ignores everything else.
- It runs in CI on both repositories, and is runnable locally with one command.
- A failure names the diverging files and says which repository to fix them in.

This is the piece that makes the split hold. Without it, 8.1 is a convention.

### 8.5 Version lines

```
prompt-factory   book-v1 (3c18af9) ── v1 ──── prompt fixes for the book's line
                 main ────────────────────── generator changes, then 2.0 content

marketplace      v1.0.0 ── v1 ─────────────── regenerated 1.x, plugin.json 1.0.x
                 main ────────────────────── 2.0
```

- Cut prompt-factory's `v1` from `book-v1`. Since `main` is at the same commit today, this is free —
  and it has to happen before the 8.2 generator changes land on `main`.
- **Tag the marketplace `v1.0.0` at the current `main` (`e9528d0`), then branch `v1` from the tag.**
  See 8.5.1: the anchor must be current `main`, not the `v0.3.2` tag.
- Fixes that matter for 2.0 are copied forward from `v1` to `main` deliberately. Nothing merges the
  other way.
- Every fix on the 1.x line bumps the plugin's `plugin.json` version, or installed copies never
  update.

### 8.5.1 Why `v1` branches from `main`, not from `v0.3.2`

Steve's instinct on 2026-10-29 was to keep `0.3.2` on the `v1` branch and let `main` go forward. The
second half is exactly this design. The anchor, though, is wrong, and it matters: **`v0.3.2` is not
the book's marketplace.**

Verified 2026-10-29 by inspecting the tag:

| | `v0.3.2` (`071cf7a`, 2026-02-16) | `main` (`e9528d0`) |
|---|---|---|
| Plugins | **13**: planning, architecture, quality, deployment, development, excellence, ai-workflow, memory-bank, operations, organization, learning, evolution, adoption | **6**: memory, design, craft, deliver, grow, harness |
| Marketplace `name` | `marketplace` | `constellize-plugins-official` |
| Skill text generated from | before the 2026-05-27 run | prompt-factory `3c18af9` = `book-v1` |
| Registers in Claude Code | no — this predates the hyphen rename | yes |

Seventeen commits separate them, and `plugins/constellize-memory/` was first added by `816d5e5`, the
hyphen rename. Pinning readers to `v0.3.2` would hand them 13 plugins whose names appear nowhere else
in the ecosystem, generated from prompt text that predates what the website serves and the book links
to, under a marketplace called `marketplace` — while the website's own page advertises six plugins and
tells them to run `/constellize-harness:orchestrate`.

**Current `main` is the book-matching state**: the five plugins were generated from `book-v1` on
2026-05-27, and the three later edits are mechanical. So `main` is where `v1` belongs.

**`v0.3.2` needs no branch to survive.** The tag already preserves that state permanently; a branch is
for work that continues, and no work will continue on the February layout. Nothing is lost by leaving
it as a tag.

Bumping the version line from 0.3.2 to 1.0.0 still holds either way, and all six plugins already read
`version: 1.0.0` in their `plugin.json`.

### 8.5.2 The two marketplace names

Decided 2026-10-29.

| Line | Repo ref | `name` in `marketplace.json` | Who lands here |
|---|---|---|---|
| 1.x | `constellize/constellize-plugins-official#v1.0.0` | `constellize-plugins-v1` | book readers |
| 2.0 | `constellize/constellize-plugins-official` (main) | `constellize-plugins-official` | everyone developing forward |

The **repository** is the same for both; only the `name` field inside `marketplace.json` differs by
branch. So the `v1` branch's first commit after branching changes that one field, and `main` keeps
today's value. Users can then add both without the one-marketplace-per-name limit biting, and plugin
references become `<plugin>@constellize-plugins-v1` on the pinned line.

This is the documented **release channels** pattern: two marketplaces whose entries point at
different refs, with different `name` values, because Claude Code identifies a marketplace by its
`name` and a user cannot register two of the same name. The docs also warn that a ref which moves
without a version change leaves users on their cached copy — the same point as 8.6.

**Carry a `renames` map.** The 1.x line's plugin names already changed twice: the 13-plugin February
layout became six in May, and the colon directories became hyphens. A top-level `renames` map in
`marketplace.json` migrates anyone still holding an old name instead of failing with
`Plugin "<name>" not found in marketplace`. Treat it as append-only history. This was not in the
earlier draft and is cheap to add while the branch is being cut.

**What two names do not solve**: both lines contain plugins called `constellize-memory`,
`constellize-craft` and so on, and same-named plugins conflict when enabled together. So a user may
*add* both marketplaces but cannot *enable* both lines' `constellize-memory` at once. That is
acceptable for the audiences as described — a reader follows the book on 1.x, a practitioner works on
2.0 — but it rules out installing 1.x and 2.0 side by side in one project, and it is worth saying so
on the website page rather than letting people discover it.

### 8.6 Pinning the published install command

Decided 2026-10-28. **The branch must exist before any of this text changes.**

**Pin the `v1` branch, not the `v1.0.0` tag** *(resolved 2026-10-29 against the Claude Code docs,
`plugins/host-marketplace`)*. The review caught the contradiction: a tag cannot both freeze readers
and deliver fixes, and 8.5 promised both. The docs settle it:

- `#<ref>` on the add command takes a **branch or a tag**, so `#v1` is valid.
- Background auto-update re-clones the marketplace when its check finds new commits, so a **branch
  ref does move** for readers.
- A reader gets a new copy of a plugin only when its computed version changes. So each 1.x fix must
  bump `plugin.json`, exactly as 8.5 says — and with a branch pin that bump now reaches people.
- Do **not** set `version` in both `plugin.json` and the marketplace entry. Claude Code silently
  prefers `plugin.json` and `claude plugin validate` reports the mismatch.

`v1.0.0` stays as an immutable marker of the shipped state. Readers follow `#v1`, which means a
prompt fix costs a regenerate and a version bump rather than re-pinning four published places and
re-rendering a PDF. Any already-printed reference card keeps working, because `#v1` does not go stale.

| Place | Change |
|---|---|
| `website/src/pages/resources/MarketplacePage.tsx:268` | append `#v1.0.0` |
| `marketplace/README.md:16` | append `#v1.0.0`, on the `v1` branch |
| `marketplace/docs/constellize-skills-infographic.html:497` | append `#v1.0.0` |
| `website/public/constellize-reference-card.pdf` | regenerate from the infographic |

The repository in that command does not change — only the ref is added. The page should also say
which marketplace name readers are adding (`constellize-plugins-v1`), since that is the name they will
see in `/plugin` and use to reference plugins.

**The book needs no change.** It names no repository and gives no install command; the harness appears
only as prose in `book/ch9.md:320` and `book/appA.md:46`. Verified by grepping all of `book/*.md`.

### 8.7 Versioned prompt text on the website

The website stores one copy of each prompt at `public/prompts/<id>/prompt.txt`, and the `/prompts/v1/`
in the book's URLs is a hard-coded label in `src/App.tsx`, not a version anyone released. A 1.x fix
and a 2.0 rewrite of the same prompt would collide.

Store prompt text by version — `public/prompts/v1/<id>/prompt.txt` — and have the detail page fetch
the version in its own route. The website generator gains the version as a parameter. This must land
before any v2 prompt page exists, and it is cheapest now, while only one version exists.

---

## 9. What is left to the builder

- How the agentskills frontmatter is expressed in the generator: a template, a serializer, or a
  transform over the existing builder.
- Where the per-plugin version lives in `content/schemas/plugins.json`, and whether `marketplace.json`
  should repeat it.
- The drift guard's mechanics: which CI, how scratch directories are made and cleaned, and the exact
  diff invocation. Note that `diff` is aliased to `git diff` in Steve's zsh; use `/usr/bin/diff`.
- Whether to retire `migrate-paths.sh` outright or keep it as a one-shot for old checkouts.
- The order of the first landing. The suggested sequence, because each step unblocks the next:
  1. cut prompt-factory `v1` from `book-v1`; tag marketplace `v1.0.0`; branch marketplace `v1`
  2. generator changes on prompt-factory `main`
  3. regenerate, and verify the output matches the marketplace byte for byte
  4. drift guard, in CI on both repos
  5. pin the four published places, and regenerate the reference card
  6. versioned prompt storage on the website
- Whether `release-new-version.sh` is fixed or retired. As written it pushes six repositories'
  commits and tags without confirmation, which is incompatible with two version lines.

---

### 8.8 Making the personas consistent (2026-10-29)

Four surfaces describe the same 14 personas, and they disagreed. Verified by counting each:

| Surface | Had | Source |
|---|---|---|
| prompt-factory `content/personas/` | 112 files in 14 subcategories | the source |
| marketplace `agents/*.md` | 14 | generated — was already correct |
| website `public/personas/**/Aggregate_Expert_Synthesis.md` | 12, now **14** | generated — fixed by regenerating |
| website personas page | 12, now **14** | hand-written `src/data/personas/metadata.ts` — fixed by hand |
| website `public/personas/` individual files | **117 unreachable files**, now **archived and removed** | an older generator |

- `metadata.ts` is what `PersonasPage` renders, through `index.ts`. Its `filePath` for each entry
  points only at that subcategory's aggregate, so the 121 individual persona files — `Alex.md`,
  `Devin.md`, `Nova.md` and the rest — **are not reachable from any page.** They are published but
  unlinked.
- `metadata.ts` also uses underscore ids (`devops_engineers`) while the dead generated file used
  hyphens (`devops-engineers`), so the generated file could never have been swapped in without
  changing every persona's id.
- **Done 2026-10-29 at Steve's instruction**: the 117 individual files were archived to
  `archives/website-personas-individual-archive-2026-10.tar.gz` (65 KB, with a manifest saying why and
  how to restore) and removed from the website. Each was verified byte-identical inside the archive
  before deletion, and the sources remain in `prompt-factory/content/personas/` regardless.
  `public/personas/` now holds exactly the 14 aggregates, and `npm run build` passes.
- **Structural fix for later**: `metadata.ts` is hand-written, duplicates what the generator knows,
  and drifted by two personas within one release. It belongs in the generator's column of 8.1, with
  the page's underscore ids preserved. Doing that is what stops this recurring.

## 9a. Calls settled after review (2026-10-29)

Each of these was a question the builder check raised, settled here rather than put to Steve.

| # | Question | Call |
|---|---|---|
| 1 | How does a 1.x prompt fix get regenerated, if the generator changes land on `main` only? | The 8.2 generator changes are **cherry-picked onto prompt-factory `v1` too**. The generator is code, not words; freezing it on `v1` would mean every 1.x fix reproduces the May 2026 damage. The `book-v1` **tag** is what preserves the historical output |
| 2 | Is the prefixed skill `name:` intended? | No. The generator reproduces the committed shape. 8.2 item 2 rewritten |
| 3 | `generated-metadata.json` is non-deterministic | The **guard excludes the `created` stamp** from comparison, and the generator keeps writing it. Dropping or re-sourcing the field would rewrite values already published |
| 5 | What is the "generated set", and what about files the generator no longer writes? | The guard compares against an **explicit manifest** of what the generator emits, and ignores repo-only files. The **121** orphaned files under `public/personas/` and `src/data/` are a **separate cleanup**, not drift — and two of them are the dead generated-metadata files, which could simply be deleted. Deletions on the 2.0 line go through `renames` and `forceRemoveDeletedPlugins` |
| 6 | Tag or branch pin? | **Branch.** Resolved against the docs; see 8.6 |
| 7 | What pins the cross-repo pair for the guard? | The marketplace records the prompt-factory commit it was generated from, and the guard compares against **that recorded commit**, not a moving tip — so CI is never red merely because a prompt fix landed first. Note: **no repository has any CI today**; there is no `.github/workflows` anywhere, so this is greenfield |
| 8 | Tag `v1.0.0` before or after regenerate-and-verify? | **After.** With call 2 in place regeneration should be byte-identical; tag the verified commit so `v1.0.0` is a state that reproduces |

## 10. Open questions for Steve

1. ~~Confirm `v1` branches from current `main`, not from `v0.3.2`.~~ **Confirmed by Steve
   2026-10-29.** See 8.5.1.
2. **Push `book-v1`?** It is annotated, local, and the anchor for everything above.
   `git -C prompt-factory push origin book-v1`.
3. ~~The website's generated files are stale — regenerate or treat as canon?~~ **Resolved
   2026-10-29: regenerated.** The review's framing was wrong, and it matters:
   **both generated metadata files are dead code.** Nothing in `website/src` imports
   `src/data/prompts/generated-metadata.json` or `src/data/personas/generated-metadata.ts` —
   `src/data/personas/index.ts` re-exports the hand-written `metadata.ts` and `loader.ts` instead.
   So the 584-line and 103-line diffs change nothing a reader can see, and the `useCase: ""` question
   never arises.

   Regenerated in scratch and diffed against the live site:
   - **All 73 `prompt.txt` files are byte-identical.** What readers actually fetch does not change.
   - The generator adds exactly **two** files:
     `public/personas/knowledge_management/knowledge_stewards/Aggregate_Expert_Synthesis.md` and
     `public/personas/adoption_learning/adoption_coaches/Aggregate_Expert_Synthesis.md`.
   - It writes none of **121 other files** under `public/personas/` and `src/data/` — the orphans from
     an older generator.

   Applied to the website working tree, uncommitted.

   **Generator bug found while applying it: the website generator's output does not compile.**
   The regenerated `generated-metadata.ts` declares `personasBasePath` and never uses it, so
   `tsc -b` fails with TS6133 — and `npm run build` is `tsc -b && vite build`, so **running the
   website generator today breaks the website build.** The committed copy does not declare it, which
   is why nobody hit this. Both dead metadata files are therefore **deleted** from the working tree,
   and the generator must stop emitting them: nothing imports either, and the only thing they
   contribute is an unbuildable file. Fold this into 8.2 as a website-generator change.

   The two new personas have also been added to the hand-written
   `src/data/personas/metadata.ts`, which is what the personas page actually renders, so the site now
   lists all 14. See §8.8.
4. **Does "use the v2 prompts" keep Option A?** The 2026-10-24 decision moves the course's
   specify/implement/verify chain into 2.0 as the feature workflow. Steve's 2026-10-28 remark — use
   the Constellize v1 or v2 prompts and agents, not the course's own skills — reads either as "yes,
   and the ported chain is part of v2" or as "use what the marketplace already has". This changes what
   2.0 contains, so it wants an answer before project 2 rather than before this one.

---

## 11. Evidence

- `prompt-factory/build/generate-marketplace.ts`, `build/generate-website.ts`,
  `build/lib/parser.ts:159`, `content/schemas/plugins.json`
- `marketplace/.claude-plugin/marketplace.json`, `marketplace/README.md:16`,
  `marketplace/scripts/migrate-paths.sh`, `marketplace/docs/constellize-skills-infographic.html:497`
- `website/src/pages/resources/MarketplacePage.tsx:268`, `website/src/App.tsx`,
  `website/public/constellize-reference-card.pdf`
- `book/ch9.md:320`, `book/appA.md:46`
- `memory-bank/systemPatterns.md` "Content Architecture" and "Content Generation Pipeline";
  `memory-bank/techContext.md` "Claude Code Plugin Versioning" and "Working Notes and Gotchas"
