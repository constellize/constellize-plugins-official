# constellize-harness Plugin Design

## Overview

A new Claude Code plugin (`constellize-harness`) that orchestrates the existing constellize skill ecosystem. It deterministically assesses project state using a TypeScript assessor script, then recommends and optionally executes sequences of constellize skills based on where the project is in the SDLC lifecycle.

## Goals

1. Zero-token state assessment — a TypeScript script scans the filesystem and git state to produce a project profile, no LLM calls needed for the deterministic parts.
2. Two interaction modes — **advisory** (tells the user what to run) and **spawn** (executes skills via `claude -p`).
3. Any starting point — works for greenfield, brownfield, abandoned, mid-build, incident response, onboarding, and maintenance scenarios.
4. Unified artifact layout — all LLM-generated artifacts live under `llm/`, making state assessment a directory scan.

## Directory Structure

All LLM artifacts are consolidated under `llm/` at the project root:

```
project-root/
  llm/
    memory-bank/                    # persistent project knowledge
      projectbrief.md
      productContext.md
      systemPatterns.md
      techContext.md
      activeContext.md
      progress.md
    construction/                   # temporary, project-wide working area
      design/
        business-problem.md
        vision-statement.md
        ecosystem-map.md
        raci-matrix.md
        constellation-map.md
        gap-analysis.md
        lock-constellation.md
        implementation-sketch.md
        code-generation-plan.md
      requirements/
        specification.md
      archive/                      # compressed/completed artifacts
    features/                       # per-feature subset of relevant docs
      feature-name/
        design.md
        tests.md
        status.md
```

### Directory lifecycle

- `memory-bank/` is persistent — stewarded across the life of the project.
- `construction/` is a working area. As work completes, relevant details are compressed in-place and older material moves to `construction/archive/`.
- `features/` contains curated subsets of design/test artifacts scoped to a specific feature.

## Migration: Existing Skill Path References

All 69 existing skills currently reference `construction/design/`, `construction/requirements/`, and `memory-bank/` as top-level paths. These must be updated to `llm/construction/design/`, `llm/construction/requirements/`, and `llm/memory-bank/` respectively.

This is a mechanical find-and-replace across all SKILL.md files, performed as part of the harness implementation. No symlinks or backwards-compatibility shims.

## State Assessment: Multi-Dimensional Model

The assessor produces a **profile**, not a single phase label. It evaluates the project across multiple dimensions, organized into tiers by cost.

### Tier 1 — Always run (<2 seconds, filesystem + git only)

| Dimension | What It Detects | Method |
|-----------|----------------|--------|
| **LLM Artifacts** | Memory bank, construction, features state | File presence scan under `llm/` |
| **Codebase Maturity** | Source, tests, CI, package manager | File/directory pattern matching |
| **Git Topology** | Branch, ahead/behind main, uncommitted changes, branch age | Git commands |
| **Project Type** | Application vs library vs monorepo | Package config inspection |
| **Temporal State** | Activity recency, staleness | Git last-commit dates, file modification times |

### Tier 2 — Run on `assess` (<10 seconds)

| Dimension | What It Detects | Method |
|-----------|----------------|--------|
| **Documentation Quality** | Drift between docs and code | Cross-reference memory bank entries against filesystem |
| **Transition State** | Mid-refactor, migration, deprecated markers | Dual patterns, migration files, TODO density |
| **Tech Debt Markers** | TODO/FIXME counts, file size outliers | Grep + stat |
| **Build Viability** | Version requirements vs EOL, missing env templates | Parse runtime configs |

### Tier 3 — Run on `assess --deep` (<30 seconds, may shell out)

| Dimension | What It Detects | Method |
|-----------|----------------|--------|
| **Dependency Health** | Vulnerabilities, outdated packages | `npm audit` / equivalent |
| **Secret Posture** | Leaked keys, gitignore coverage | Pattern scan |
| **Team Distribution** | Bus factor, author concentration | Git log analysis |
| **Test Quality** | Skip counts, test-to-source ratio, coverage config | File analysis |

### Assessor Output Format

```json
{
  "dimensions": {
    "llmArtifacts": {
      "memoryBank": {
        "status": "partial",
        "present": ["projectbrief.md", "productContext.md", "activeContext.md"],
        "missing": ["systemPatterns.md", "techContext.md", "progress.md"]
      },
      "construction": {
        "status": "in-progress",
        "completedArtifacts": ["business-problem.md", "vision-statement.md", "ecosystem-map.md", "constellation-map.md"],
        "missingArtifacts": ["gap-analysis.md", "lock-constellation.md", "implementation-sketch.md", "code-generation-plan.md"]
      },
      "features": { "count": 0, "entries": [] }
    },
    "codebase": {
      "hasSource": true,
      "languages": ["typescript"],
      "hasTests": true,
      "hasCiCd": false,
      "packageManager": "npm"
    },
    "gitTopology": {
      "branch": "feature/billing-v2",
      "isDefault": false,
      "commitsAhead": 14,
      "commitsBehind": 3,
      "branchAgeDays": 8,
      "llmDiffFromMain": false,
      "uncommittedChanges": 2
    },
    "projectType": "application",
    "temporal": {
      "lastCommit": "2026-06-20T14:30:00Z",
      "lastLlmUpdate": "2026-06-18T09:00:00Z",
      "staleDays": 2
    }
  },
  "flags": ["mid-build", "no-ci", "behind-main"],
  "situation": "mid-build",
  "recommendations": [
    {
      "action": "resume-construction",
      "skill": "constellize-design:gap-analysis",
      "reason": "Next missing design artifact"
    },
    {
      "action": "rebase",
      "reason": "3 commits behind main — consider rebasing before continuing"
    }
  ]
}
```

## Plugin Structure

```
plugins/constellize-harness/
  .claude-plugin/
    plugin.json
  scripts/
    assess.ts                    # TypeScript assessor — the deterministic engine
    assess-utils.ts              # Shared detection utilities
    package.json                 # Dependencies (minimized — no heavy frameworks)
  skills/
    init/SKILL.md                # Scaffold llm/ directory
    assess/SKILL.md              # Run assessor, present findings, ask intent
    plan/SKILL.md                # Propose skill sequence from assessment + intent
    orchestrate/SKILL.md         # Execute approved plan (advisory or spawn)
```

### Script Execution

Skills invoke the assessor via Bash:
```bash
npx tsx scripts/assess.ts --tier 1,2 --format json
```

The script reads the current working directory, runs the requested tiers, and outputs JSON to stdout. The skill prompt parses the JSON and renders the human-readable summary.

## Skills

### `init`

**Purpose:** Scaffold the `llm/` directory structure for a project.

**Behavior:**
- Creates `llm/memory-bank/` with template files
- Creates `llm/construction/design/`, `llm/construction/requirements/`, `llm/construction/archive/`
- Creates `llm/features/`
- Runs Tier 1 assessment to pre-populate `techContext.md` with detected languages, package manager, project type
- Idempotent — fills in missing pieces without overwriting existing files
- Advisory mode: prints what it would create
- Spawn mode: creates the structure

### `assess`

**Purpose:** Evaluate project state and present a readable profile.

**Behavior:**
- Runs the TypeScript assessor script (Tier 1+2 by default, `--deep` for Tier 3)
- Renders the profile as a human-readable summary with progress bars and flags
- Ends with a clarifying question: "What are you trying to do?" with options derived from the profile
- No side effects — purely diagnostic

**Example output:**
```
Project: my-app (TypeScript application)
Branch: feature/billing (14 ahead, 3 behind main)

  Memory Bank:    ██████░░░░  3/6 files
  Construction:   ████░░░░░░  4/10 design artifacts (next: gap-analysis)
  Codebase:       ████████░░  Source + tests, no CI
  Freshness:      ████████░░  Last commit 2 days ago, docs current

  Flags: mid-build, no-ci, behind-main

What are you trying to do?
  (A) Continue building where I left off
  (B) Add a new feature
  (C) Fix a bug or respond to an incident
  (D) Get oriented — I'm new to this project
  (E) Something else
```

### `plan`

**Purpose:** Propose a sequence of constellize skills based on assessment + intent.

**Behavior:**
- Takes the assessment profile and user intent
- Looks up the matching situation in the routing table
- Filters out already-completed steps based on artifact presence
- Presents the plan for user approval or modification
- User can remove, reorder, or add steps

**Example output:**
```
Based on: mid-build, construction at gap-analysis stage

Proposed plan:
  1. constellize-design:gap-analysis         — identify remaining gaps
  2. constellize-design:lock-constellation    — lock scope
  3. constellize-design:implementation-sketch — sketch approach per gap
  4. constellize-design:code-generation-plan  — create implementation plan
  5. constellize-memory:update               — capture progress

Approve this plan? (y/edit/n)
```

### `orchestrate`

**Purpose:** Execute an approved plan in advisory or spawn mode.

**Behavior:**
- Takes the approved plan from `plan`
- **Advisory mode:** prints each step as a command for the user to run manually
- **Spawn mode:** executes each step via `claude -p` with appropriate arguments, waits for completion, proceeds to next step
- After each step, updates `llm/construction/` state and `llm/memory-bank/activeContext.md`
- If a step fails or produces unexpected results, pauses and asks the user how to proceed
- On completion, runs a final `constellize-memory:update` to capture the session

## Routing Table

The `plan` skill uses this table to map situations to skill sequences. This table lives as data in the assessor script, not in skill prompts.

| Situation | Skill Sequence |
|-----------|---------------|
| **Greenfield, no llm/** | `init` → `establish` → `business-problem` → `vision-statement` → `ecosystem-map` → `constellation-map` → `gap-analysis` → `lock-constellation` → `implementation-sketch` → `code-generation-plan` |
| **Brownfield, no context** | `init` → `establish` (pre-populated from scan) → `assess --deep` |
| **Stale docs** | `triage-salvageable-knowledge` or `recover-staleness` → `update` |
| **Mid-build** | Resume at next missing construction artifact in design sequence |
| **Feature work** | `gap-analysis` (feature-scoped) → `implementation-sketch` → `code-generation-plan` → `unit-tests` → `integration-tests` |
| **Incident/hotfix** | `incident-investigation` → fix → `incident-postmortem` → `update` |
| **New to codebase** | `first-week` → `assess` → guided orientation |
| **Maintenance** | `health-assessment` → `dependency-hygiene` → `grow-organically` |

This table will be extended as we discover additional patterns.

## Execution Model

### Advisory Mode
The default. Each step is presented as a command the user can copy-paste:
```
Step 1 of 5: Run gap analysis
  /constellize-design:gap-analysis my-app my-system

Press enter when done, or 's' to skip.
```

### Spawn Mode
Activated with a flag. Each step is executed via:
```bash
claude -p "/constellize-design:gap-analysis my-app my-system" \
  --allowedTools "Read,Glob,Grep,Write,Bash" \
  --max-budget-usd 1.00
```

The harness monitors completion, checks that expected artifacts were produced, then proceeds.

## Implementation Scope

### Phase 1 (this spec)
1. Create `constellize-harness` plugin with `init`, `assess`, `plan`, `orchestrate` skills
2. Build the TypeScript assessor script (Tier 1 + Tier 2)
3. Update all 69 existing skill path references from `construction/` and `memory-bank/` to `llm/construction/` and `llm/memory-bank/`
4. Implement advisory mode for orchestrate

### Phase 2 (future)
1. Spawn mode execution via `claude -p`
2. Tier 3 deep assessment
3. Feature-scoped workflows (per-feature construction artifacts)
4. Routing table expansion based on real usage patterns
