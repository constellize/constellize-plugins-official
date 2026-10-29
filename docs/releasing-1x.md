# Releasing a fix to the 1.x line

Readers follow the `v1` branch. The plugins here are generated from the
`prompt-factory` repo, so a fix starts there. Both repos have a `v1` branch; do the
steps in this order, because `drift.yml` checks out the exact prompt-factory commit
named in `GENERATED_FROM`, and that commit must already exist on GitHub.

Every step names the repo it runs in: **[prompt-factory]** means `cd` into the
`prompt-factory` checkout, **[marketplace]** means `cd` into this repo. Running a step in
the wrong one can succeed silently (step 6 would write a stray `GENERATED_FROM` into
prompt-factory and leave this repo's pointer stale), so check your directory first.

1. **[prompt-factory] Fix the prompt or persona** in `prompt-factory` (`content/prompts/` or
   `content/personas/`) and **bump that plugin's version** in
   `content/schemas/plugins.json` (e.g. `1.0.0` to `1.0.1`). CI fails any change
   under `plugins/<name>/` without a version bump. Commit on `main` first, then
   cherry-pick to `v1`.
2. **[prompt-factory] Push `v1`.** Do this before anything in this repo.
3. **[prompt-factory] Regenerate** with this repo checked out on `v1` at `../marketplace`
   and prompt-factory on `v1`: `npm run generate:marketplace`.
4. **[prompt-factory] Check**:
   `npm run check:drift -- --target marketplace --against ../marketplace` must be clean.
5. **[marketplace] Commit the regenerated files** (`plugins/...`). Name files; do not `git add -A`.
6. **[marketplace] Update `GENERATED_FROM` in its own, separate commit**. Run this from
   the marketplace root, so the `>` redirect writes into the marketplace's file while
   `git -C` reads prompt-factory's `v1`:
   `git -C ../prompt-factory rev-parse v1 > GENERATED_FROM`.
   It is separate because four files differ permanently between `main` and `v1`:
   `.claude-plugin/marketplace.json`, `GENERATED_FROM` (each line records its own
   prompt-factory commit), `README.md` and `docs/constellize-skills-infographic.html`
   (`v1` pins the install command to `#v1`; `main` follows the latest line). An edit
   to any of these inside a fix commit will conflict when cherry-picked between the
   lines, so keep such edits in their own commits.
7. **[marketplace] Push `v1`.**

Same fix on `main`? Repeat in this order. **[prompt-factory]** cherry-pick the fix commit
(and its version bump) onto prompt-factory `main`, and push prompt-factory `main` first,
because the marketplace's `main` CI checks out the commit its `GENERATED_FROM` names.
Then **[marketplace]** cherry-pick the regenerated-files commit (not the `GENERATED_FROM`
commit) onto this repo's `main`, make that line's own `GENERATED_FROM` commit with
`git -C ../prompt-factory rev-parse main > GENERATED_FROM`, and push `main`.

Adding a prompt (not just fixing one)? `website/src/data/prompts-manifest.json` in the
website repo is hand-maintained and has no regeneration path: its script,
`website/scripts/generate-prompts-manifest.mjs`, reads a path that does not resolve and
is not part of the pipeline. Add an entry to the manifest for the new prompt, or its
published `prompt.txt` will be unreachable from any page.
