# Releasing a fix to the 1.x line

Readers follow the `v1` branch. The plugins here are generated from the
`prompt-factory` repo, so a fix starts there. Both repos have a `v1` branch; do the
steps in this order, because `drift.yml` checks out the exact prompt-factory commit
named in `GENERATED_FROM`, and that commit must already exist on GitHub.

1. **Fix the prompt or persona** in `prompt-factory` (`content/prompts/` or
   `content/personas/`) and **bump that plugin's version** in
   `content/schemas/plugins.json` (e.g. `1.0.0` to `1.0.1`). CI fails any change
   under `plugins/<name>/` without a version bump. Commit on `main` first, then
   cherry-pick to `v1`.
2. **Push prompt-factory `v1`.** Do this before anything in this repo.
3. **Regenerate** with this repo checked out on `v1` at `../marketplace`, from
   prompt-factory on `v1`: `npm run generate:marketplace`.
4. **Check** (in prompt-factory):
   `npm run check:drift -- --target marketplace --against ../marketplace` must be clean.
5. **Commit the regenerated files** in this repo (`plugins/...`). Name files; do not `git add -A`.
6. **Update `GENERATED_FROM` in its own, separate commit**:
   `git -C ../prompt-factory rev-parse v1 > GENERATED_FROM`.
   It is separate because four files differ permanently between `main` and `v1`:
   `.claude-plugin/marketplace.json`, `GENERATED_FROM` (each line records its own
   prompt-factory commit), `README.md` and `docs/constellize-skills-infographic.html`
   (`v1` pins the install command to `#v1`; `main` follows the latest line). An edit
   to any of these inside a fix commit will conflict when cherry-picked between the
   lines, so keep such edits in their own commits.
7. **Push this repo's `v1`.**

Same fix on `main`? Cherry-pick the fix commits (not the `GENERATED_FROM` commit)
and make that line's own `GENERATED_FROM` commit.
