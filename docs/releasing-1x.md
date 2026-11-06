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
   and prompt-factory on `v1`: `npm run generate:marketplace`. Run `git branch --show-current`
   in **both** checkouts first. The generator no longer refuses to write the files that differ
   between the lines, so `main`'s generator run against a `v1` checkout overwrites the three
   files that are both generated and divergent: the catalog, `README.md` and the infographic.
   (`GENERATED_FROM` also differs between the lines but is not generated, so it survives.) It
   is recoverable with `git checkout` in the marketplace, but check before you run it, not
   after.
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

### If `.github/` or `README.md` changed

On `main` both are generated: the workflow and the version-bump script come from
prompt-factory's `content/literal/marketplace-github/`, and `README.md` from
`content/literal/marketplace-root/`. So a fix to either is a **factory** change, made there
and regenerated here. Editing them in this repo on `main` does not survive: the next
`npm run generate:marketplace` overwrites the file, and the drift job fails in the meantime.

On `v1` both are still hand-written, so the same fix on that line is an edit in this repo.
(`.github/` happens to be byte-identical on the two branches today; `README.md` is not,
because each line carries its own install command.)

### If the card changed

The reference cards are built by `prompt-factory`, from its copy of the infographic
(`content/literal/marketplace-docs/`; `docs/constellize-skills-infographic.html` here is
generated from it), and the install command is injected per line. So a change to the
card's content is made in `prompt-factory`, the marketplace is regenerated, and the cards
are rebuilt from the factory root:

```
npm run build:card -- --line v2
```

A bare `npm run build:card` rebuilds every line and writes `constellize-reference-card-v1.pdf`,
`-v2.pdf` and the unversioned alias into `../website/public/`. That is correct for a 1.x
release that changes the card content of both lines. While `v1` is frozen, though, a bare
run rewrites the `v1` PDF and the unversioned alias, and the printed book's readers follow
both, so rebuild only the line you changed. Keep the `--`: `npm run build:card --line v2`
without it is swallowed by npm, the flag never reaches the script, and it behaves as the
bare command. Pass `--out <path>` to write somewhere other than `../website/public/`, for
example to probe the page count first. Then commit the rebuilt PDF in the **website** repo. The script drives Chrome
over the DevTools protocol and needs no dependencies; set `CHROME_PATH` if Chrome is
somewhere unusual. It fails rather than shipping a bad card if the footer's install command
is missing or falls outside the page, which is how the card previously shipped with the
command clipped off entirely.

The copy of the HTML on `v1` is standalone documentation for that line and keeps its own
`#v1` footer; it is not what the cards are built from.

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
