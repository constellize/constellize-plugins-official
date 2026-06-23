# constellize-harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the constellize-harness plugin with deterministic project state assessment, and migrate all existing skills to the `llm/` directory layout.

**Architecture:** A new plugin with 4 skills (init, assess, plan, orchestrate) backed by a TypeScript assessor script that scans the filesystem and git state. All 69 existing skills are updated to reference `llm/memory-bank/` and `llm/construction/` instead of top-level paths.

**Tech Stack:** TypeScript (assessor script via `npx tsx`), Markdown (SKILL.md files), Git CLI

---

### Task 1: Migrate existing skill path references to `llm/` layout

**Files:**
- Modify: All 28 SKILL.md files containing `construction/` or `memory-bank/` path references (listed below)

The path migration has two replacements, applied in this order to avoid double-prefixing:

1. `construction/` → `llm/construction/` (but NOT `operations-memory-bank/` or references already under `llm/`)
2. `memory-bank/` → `llm/memory-bank/` (but NOT `operations-memory-bank/`)

**Important edge cases:**
- `operations-memory-bank/` is a separate concept in the deliver plugin — this should become `llm/operations-memory-bank/`, NOT `llm/memory-bank/operations-...`
- Some files reference `memory-bank/` in prose descriptions, not just paths — update those too
- The skill `operational-memory-bank` references both `memory-bank/` and `operations-memory-bank/` as directory names — both need the `llm/` prefix

**Affected files (14 with `construction/`):**
- `plugins/constellize-design/skills/implementation-sketch/SKILL.md` (24 occurrences)
- `plugins/constellize-design/skills/lock-constellation/SKILL.md` (11)
- `plugins/constellize-design/skills/constellation-map/SKILL.md` (2)
- `plugins/constellize-design/skills/code-generation-plan/SKILL.md` (10)
- `plugins/constellize-design/skills/gap-analysis/SKILL.md` (3)
- `plugins/constellize-craft/skills/test-coverage/SKILL.md` (4)
- `plugins/constellize-craft/skills/integration-tests/SKILL.md` (5)
- `plugins/constellize-craft/skills/unit-tests/SKILL.md` (5)
- `plugins/constellize-craft/skills/application-health-validation/SKILL.md` (5)
- `plugins/constellize-craft/skills/architectural-consistency/SKILL.md` (2)
- `plugins/constellize-craft/skills/operational-monitoring/SKILL.md` (4)
- `plugins/constellize-craft/skills/infrastructure-health-checks/SKILL.md` (6)
- `plugins/constellize-craft/skills/contract-tests/SKILL.md` (5)
- `plugins/constellize-memory/skills/branch/SKILL.md` (10)

**Affected files (28 with `memory-bank/`):**
- All 11 constellize-memory skills
- 7 constellize-deliver skills
- 6 constellize-grow skills
- 4 constellize-craft skills

- [ ] **Step 1: Create a migration script**

Create a shell script at `scripts/migrate-paths.sh`:

```bash
#!/bin/bash
# Migrate SKILL.md path references to llm/ layout
# Run from marketplace root

set -euo pipefail

PLUGINS_DIR="plugins"

echo "=== Migrating construction/ → llm/construction/ ==="

find "$PLUGINS_DIR" -name "SKILL.md" -exec grep -l 'construction/' {} \; | while read -r file; do
  # Replace construction/ with llm/construction/ but not if already prefixed
  # Use word boundary: backtick or space or start-of-line before construction/
  sed -i '' \
    -e 's|`construction/|`llm/construction/|g' \
    -e 's| construction/| llm/construction/|g' \
    -e 's|"construction/|"llm/construction/|g' \
    -e 's|^construction/|llm/construction/|g' \
    -e 's|- construction/|- llm/construction/|g' \
    "$file"
  echo "  Updated: $file"
done

echo ""
echo "=== Migrating memory-bank/ → llm/memory-bank/ ==="

find "$PLUGINS_DIR" -name "SKILL.md" -exec grep -l 'memory-bank/' {} \; | while read -r file; do
  # Replace memory-bank/ but NOT operations-memory-bank/
  # First, protect operations-memory-bank by using a placeholder
  sed -i '' \
    -e 's|operations-memory-bank/|__OPS_MB_PLACEHOLDER__|g' \
    -e 's|`memory-bank/|`llm/memory-bank/|g' \
    -e 's| memory-bank/| llm/memory-bank/|g' \
    -e 's|"memory-bank/|"llm/memory-bank/|g' \
    -e 's|^memory-bank/|llm/memory-bank/|g' \
    -e 's|- memory-bank/|- llm/memory-bank/|g' \
    -e 's|__OPS_MB_PLACEHOLDER__|llm/operations-memory-bank/|g' \
    "$file"
  echo "  Updated: $file"
done

echo ""
echo "=== Verification ==="
echo "Remaining bare construction/ references (should be 0 path refs):"
grep -rn 'construction/' "$PLUGINS_DIR" --include="SKILL.md" | grep -v 'llm/construction/' | grep -v 'name:' | grep -v 'description:' | head -20 || echo "  None found"

echo ""
echo "Remaining bare memory-bank/ references (should be 0 path refs):"
grep -rn 'memory-bank/' "$PLUGINS_DIR" --include="SKILL.md" | grep -v 'llm/memory-bank/' | grep -v 'llm/operations-memory-bank/' | grep -v 'name:' | grep -v 'description:' | grep -v 'prompt-id:' | head -20 || echo "  None found"
```

- [ ] **Step 2: Run the migration script**

```bash
cd /Users/satkinson/Work/constellize/marketplace
chmod +x scripts/migrate-paths.sh
bash scripts/migrate-paths.sh
```

Expected: All path references updated, verification shows 0 remaining bare references.

- [ ] **Step 3: Manual review of edge cases**

Manually inspect these files which have the most complex references:

```bash
# Check operational-memory-bank skill (heaviest memory-bank usage)
grep -n 'memory-bank\|operations-memory-bank' plugins/constellize-deliver/skills/operational-memory-bank/SKILL.md | head -20

# Check cross-reference skill (heaviest overall)
grep -n 'memory-bank' plugins/constellize-deliver/skills/cross-reference/SKILL.md | head -20

# Check branch skill (references both construction/ and memory-bank/)
grep -n 'construction\|memory-bank' plugins/constellize-memory/skills/branch/SKILL.md | head -20
```

Fix any remaining issues manually.

- [ ] **Step 4: Commit the migration**

```bash
git add plugins/
git commit -m "Migrate all skill path references to llm/ directory layout

All 69 skills now reference llm/memory-bank/ and llm/construction/
instead of top-level paths. Part of constellize-harness implementation."
```

---

### Task 2: Create constellize-harness plugin scaffold

**Files:**
- Create: `plugins/constellize-harness/.claude-plugin/plugin.json`
- Create: `plugins/constellize-harness/scripts/package.json`
- Create: `plugins/constellize-harness/scripts/tsconfig.json`

- [ ] **Step 1: Create plugin.json**

```bash
mkdir -p plugins/constellize-harness/.claude-plugin
```

Write `plugins/constellize-harness/.claude-plugin/plugin.json`:

```json
{
  "name": "constellize-harness",
  "version": "1.0.0",
  "description": "Project orchestration: assess state, plan next steps, execute constellize skills",
  "author": {
    "name": "Constellize"
  }
}
```

- [ ] **Step 2: Create scripts package.json**

```bash
mkdir -p plugins/constellize-harness/scripts
```

Write `plugins/constellize-harness/scripts/package.json`:

```json
{
  "name": "constellize-harness-scripts",
  "private": true,
  "type": "module",
  "dependencies": {
    "tsx": "^4.0.0"
  }
}
```

- [ ] **Step 3: Create tsconfig.json**

Write `plugins/constellize-harness/scripts/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "./dist",
    "rootDir": ".",
    "declaration": false,
    "skipLibCheck": true
  },
  "include": ["*.ts"]
}
```

- [ ] **Step 4: Add to marketplace.json**

Modify `.claude-plugin/marketplace.json` to add the harness plugin entry:

```json
{
  "name": "constellize-harness",
  "source": "./plugins/constellize-harness",
  "description": "Project orchestration: assess state, plan next steps, execute constellize skills"
}
```

- [ ] **Step 5: Commit scaffold**

```bash
git add plugins/constellize-harness/ .claude-plugin/marketplace.json
git commit -m "Add constellize-harness plugin scaffold"
```

---

### Task 3: Build the TypeScript assessor — Tier 1

**Files:**
- Create: `plugins/constellize-harness/scripts/assess.ts`
- Create: `plugins/constellize-harness/scripts/types.ts`
- Create: `plugins/constellize-harness/scripts/tier1.ts`

This task builds the Tier 1 assessor: fast filesystem + git scans that always run.

- [ ] **Step 1: Define types**

Write `plugins/constellize-harness/scripts/types.ts`:

```typescript
export interface MemoryBankState {
  status: "absent" | "partial" | "complete";
  present: string[];
  missing: string[];
}

export interface ConstructionState {
  status: "absent" | "in-progress" | "complete";
  completedArtifacts: string[];
  missingArtifacts: string[];
}

export interface FeaturesState {
  count: number;
  entries: string[];
}

export interface LlmArtifacts {
  memoryBank: MemoryBankState;
  construction: ConstructionState;
  features: FeaturesState;
}

export interface CodebaseState {
  hasSource: boolean;
  languages: string[];
  hasTests: boolean;
  hasCiCd: boolean;
  packageManager: string | null;
}

export interface GitTopology {
  branch: string;
  isDefault: boolean;
  commitsAhead: number;
  commitsBehind: number;
  branchAgeDays: number;
  llmDiffFromMain: boolean;
  uncommittedChanges: number;
}

export type ProjectType = "application" | "library" | "monorepo" | "unknown";

export interface TemporalState {
  lastCommit: string | null;
  lastLlmUpdate: string | null;
  staleDays: number;
}

export interface Recommendation {
  action: string;
  skill?: string;
  reason: string;
}

export interface AssessmentProfile {
  dimensions: {
    llmArtifacts: LlmArtifacts;
    codebase: CodebaseState;
    gitTopology: GitTopology;
    projectType: ProjectType;
    temporal: TemporalState;
  };
  flags: string[];
  situation: string;
  recommendations: Recommendation[];
}
```

- [ ] **Step 2: Build Tier 1 assessor functions**

Write `plugins/constellize-harness/scripts/tier1.ts`:

```typescript
import { execSync } from "child_process";
import { existsSync, readdirSync, statSync } from "fs";
import { join } from "path";
import type {
  LlmArtifacts,
  CodebaseState,
  GitTopology,
  ProjectType,
  TemporalState,
} from "./types.js";

const MEMORY_BANK_FILES = [
  "projectbrief.md",
  "productContext.md",
  "systemPatterns.md",
  "techContext.md",
  "activeContext.md",
  "progress.md",
];

const DESIGN_ARTIFACTS = [
  "business-problem.md",
  "vision-statement.md",
  "ecosystem-map.md",
  "raci-matrix.md",
  "constellation-map.md",
  "gap-analysis.md",
  "lock-constellation.md",
  "implementation-sketch.md",
  "code-generation-plan.md",
];

function git(cmd: string): string {
  try {
    return execSync(`git ${cmd}`, { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
  } catch {
    return "";
  }
}

function dirExists(path: string): boolean {
  return existsSync(path) && statSync(path).isDirectory();
}

function fileExists(path: string): boolean {
  return existsSync(path) && statSync(path).isFile();
}

export function assessLlmArtifacts(root: string): LlmArtifacts {
  const llmDir = join(root, "llm");
  const mbDir = join(llmDir, "memory-bank");
  const constDir = join(llmDir, "construction", "design");
  const featDir = join(llmDir, "features");

  // Memory bank
  const mbPresent = MEMORY_BANK_FILES.filter((f) => fileExists(join(mbDir, f)));
  const mbMissing = MEMORY_BANK_FILES.filter((f) => !fileExists(join(mbDir, f)));
  const mbStatus = !dirExists(mbDir)
    ? "absent" as const
    : mbMissing.length === 0
      ? "complete" as const
      : "partial" as const;

  // Construction
  const constPresent = DESIGN_ARTIFACTS.filter((f) => {
    // Support wildcard names like code-generation-plan-*.md
    if (!dirExists(constDir)) return false;
    const base = f.replace(".md", "");
    return readdirSync(constDir).some((file) => file.startsWith(base) && file.endsWith(".md"));
  });
  const constMissing = DESIGN_ARTIFACTS.filter((f) => !constPresent.includes(f));
  const constStatus = !dirExists(constDir)
    ? "absent" as const
    : constMissing.length === 0
      ? "complete" as const
      : "in-progress" as const;

  // Features
  let featureEntries: string[] = [];
  if (dirExists(featDir)) {
    featureEntries = readdirSync(featDir).filter((f) =>
      dirExists(join(featDir, f))
    );
  }

  return {
    memoryBank: { status: mbStatus, present: mbPresent, missing: mbMissing },
    construction: { status: constStatus, completedArtifacts: constPresent, missingArtifacts: constMissing },
    features: { count: featureEntries.length, entries: featureEntries },
  };
}

export function assessCodebase(root: string): CodebaseState {
  const sourceDirs = ["src", "lib", "app", "cmd", "pkg", "internal"];
  const hasSource = sourceDirs.some((d) => dirExists(join(root, d)))
    || existsSync(join(root, "main.ts"))
    || existsSync(join(root, "main.py"))
    || existsSync(join(root, "main.go"));

  const languages: string[] = [];
  if (existsSync(join(root, "package.json")) || existsSync(join(root, "tsconfig.json"))) languages.push("typescript");
  if (existsSync(join(root, "pyproject.toml")) || existsSync(join(root, "setup.py")) || existsSync(join(root, "requirements.txt"))) languages.push("python");
  if (existsSync(join(root, "go.mod"))) languages.push("go");
  if (existsSync(join(root, "Cargo.toml"))) languages.push("rust");
  if (existsSync(join(root, "pom.xml")) || existsSync(join(root, "build.gradle"))) languages.push("java");

  const testDirs = ["test", "tests", "__tests__", "spec", "test_"];
  const hasTests = testDirs.some((d) => dirExists(join(root, d)))
    || dirExists(join(root, "src", "__tests__"));

  const ciPaths = [
    join(root, ".github", "workflows"),
    join(root, ".gitlab-ci.yml"),
    join(root, "Jenkinsfile"),
    join(root, ".circleci"),
  ];
  const hasCiCd = ciPaths.some((p) => existsSync(p));

  let packageManager: string | null = null;
  if (existsSync(join(root, "pnpm-lock.yaml"))) packageManager = "pnpm";
  else if (existsSync(join(root, "yarn.lock"))) packageManager = "yarn";
  else if (existsSync(join(root, "package-lock.json"))) packageManager = "npm";
  else if (existsSync(join(root, "Pipfile.lock"))) packageManager = "pipenv";
  else if (existsSync(join(root, "poetry.lock"))) packageManager = "poetry";
  else if (existsSync(join(root, "go.sum"))) packageManager = "go";
  else if (existsSync(join(root, "Cargo.lock"))) packageManager = "cargo";

  return { hasSource, languages, hasTests, hasCiCd, packageManager };
}

export function assessGitTopology(root: string): GitTopology {
  const branch = git("branch --show-current") || "unknown";

  const defaultBranch = git("rev-parse --verify main 2>/dev/null") ? "main"
    : git("rev-parse --verify master 2>/dev/null") ? "master"
    : "main";

  const isDefault = branch === defaultBranch;

  let commitsAhead = 0;
  let commitsBehind = 0;
  if (!isDefault && branch !== "unknown") {
    const ahead = git(`rev-list --count ${defaultBranch}..HEAD`);
    const behind = git(`rev-list --count HEAD..${defaultBranch}`);
    commitsAhead = parseInt(ahead, 10) || 0;
    commitsBehind = parseInt(behind, 10) || 0;
  }

  let branchAgeDays = 0;
  if (!isDefault && branch !== "unknown") {
    const firstCommitDate = git(`log ${defaultBranch}..HEAD --reverse --format=%aI | head -1`);
    if (firstCommitDate) {
      const age = Date.now() - new Date(firstCommitDate).getTime();
      branchAgeDays = Math.floor(age / (1000 * 60 * 60 * 24));
    }
  }

  const llmDiff = git(`diff --name-only ${defaultBranch} -- llm/`);
  const llmDiffFromMain = llmDiff.length > 0;

  const statusOutput = git("status --porcelain");
  const uncommittedChanges = statusOutput ? statusOutput.split("\n").filter((l) => l.trim()).length : 0;

  return { branch, isDefault, commitsAhead, commitsBehind, branchAgeDays, llmDiffFromMain, uncommittedChanges };
}

export function assessProjectType(root: string): ProjectType {
  // Monorepo detection
  if (existsSync(join(root, "pnpm-workspace.yaml"))
    || existsSync(join(root, "lerna.json"))
    || existsSync(join(root, "nx.json"))
    || existsSync(join(root, "turbo.json"))) {
    return "monorepo";
  }

  // Check package.json for workspaces
  if (existsSync(join(root, "package.json"))) {
    try {
      const pkg = JSON.parse(require("fs").readFileSync(join(root, "package.json"), "utf-8"));
      if (pkg.workspaces) return "monorepo";

      // Library detection
      if (pkg.main || pkg.module || pkg.exports || pkg.types) return "library";
    } catch { /* ignore parse errors */ }
  }

  // Cargo workspace
  if (existsSync(join(root, "Cargo.toml"))) {
    try {
      const cargo = require("fs").readFileSync(join(root, "Cargo.toml"), "utf-8");
      if (cargo.includes("[workspace]")) return "monorepo";
    } catch { /* ignore */ }
  }

  // Go workspace
  if (existsSync(join(root, "go.work"))) return "monorepo";

  // If we have source, it's an application by default
  const codebase = assessCodebase(root);
  if (codebase.hasSource) return "application";

  return "unknown";
}

export function assessTemporal(root: string): TemporalState {
  const lastCommitStr = git("log -1 --format=%aI");
  const lastCommit = lastCommitStr || null;

  // Find most recently modified file under llm/
  let lastLlmUpdate: string | null = null;
  const llmDir = join(root, "llm");
  if (dirExists(llmDir)) {
    const llmLastMod = git(`log -1 --format=%aI -- llm/`);
    lastLlmUpdate = llmLastMod || null;
  }

  let staleDays = 0;
  if (lastCommit && lastLlmUpdate) {
    const diff = new Date(lastCommit).getTime() - new Date(lastLlmUpdate).getTime();
    staleDays = Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
  }

  return { lastCommit, lastLlmUpdate, staleDays };
}
```

- [ ] **Step 3: Build the main assessor entry point**

Write `plugins/constellize-harness/scripts/assess.ts`:

```typescript
import { assessLlmArtifacts, assessCodebase, assessGitTopology, assessProjectType, assessTemporal } from "./tier1.js";
import type { AssessmentProfile, Recommendation } from "./types.js";

function deriveFlags(profile: Omit<AssessmentProfile, "flags" | "situation" | "recommendations">): string[] {
  const flags: string[] = [];
  const { llmArtifacts, codebase, gitTopology, temporal } = profile.dimensions;

  if (!codebase.hasSource && llmArtifacts.memoryBank.status === "absent") flags.push("greenfield");
  if (codebase.hasSource && llmArtifacts.memoryBank.status === "absent") flags.push("brownfield");
  if (llmArtifacts.construction.status === "in-progress") flags.push("mid-build");
  if (llmArtifacts.memoryBank.status === "partial") flags.push("partial-memory");
  if (!codebase.hasCiCd && codebase.hasSource) flags.push("no-ci");
  if (gitTopology.commitsBehind > 0) flags.push("behind-main");
  if (gitTopology.commitsAhead > 20) flags.push("long-branch");
  if (gitTopology.uncommittedChanges > 0) flags.push("dirty-tree");
  if (temporal.staleDays > 30) flags.push("stale-docs");
  if (temporal.staleDays > 90) flags.push("abandoned-docs");
  if (temporal.lastCommit === null) flags.push("no-git-history");

  return flags;
}

function deriveSituation(flags: string[]): string {
  if (flags.includes("greenfield")) return "greenfield";
  if (flags.includes("brownfield") && !flags.includes("mid-build")) return "brownfield-no-context";
  if (flags.includes("mid-build")) return "mid-build";
  if (flags.includes("stale-docs") || flags.includes("abandoned-docs")) return "stale-docs";
  return "feature-work";
}

function deriveRecommendations(
  profile: Omit<AssessmentProfile, "recommendations">,
): Recommendation[] {
  const recs: Recommendation[] = [];
  const { llmArtifacts, gitTopology } = profile.dimensions;

  if (profile.situation === "greenfield") {
    recs.push({ action: "init", skill: "constellize-harness:init", reason: "No llm/ directory — scaffold project structure" });
  }

  if (profile.situation === "brownfield-no-context") {
    recs.push({ action: "init", skill: "constellize-harness:init", reason: "Codebase exists but no llm/ context — establish memory bank" });
  }

  if (profile.situation === "mid-build" && llmArtifacts.construction.missingArtifacts.length > 0) {
    const next = llmArtifacts.construction.missingArtifacts[0];
    const skillName = next.replace(".md", "");
    recs.push({ action: "resume-construction", skill: `constellize-design:${skillName}`, reason: `Next missing design artifact: ${next}` });
  }

  if (profile.situation === "stale-docs") {
    recs.push({ action: "recover", skill: "constellize-memory:recover-staleness", reason: "Documentation has drifted from codebase" });
  }

  if (profile.flags.includes("partial-memory")) {
    const missing = llmArtifacts.memoryBank.missing;
    recs.push({ action: "complete-memory", skill: "constellize-memory:update", reason: `Memory bank incomplete — missing: ${missing.join(", ")}` });
  }

  if (gitTopology.commitsBehind > 0) {
    recs.push({ action: "rebase", reason: `${gitTopology.commitsBehind} commits behind ${gitTopology.isDefault ? "remote" : "main"} — consider rebasing` });
  }

  if (gitTopology.uncommittedChanges > 0) {
    recs.push({ action: "commit-or-stash", reason: `${gitTopology.uncommittedChanges} uncommitted changes` });
  }

  return recs;
}

function main() {
  const args = process.argv.slice(2);
  const root = process.cwd();
  const format = args.includes("--format") ? args[args.indexOf("--format") + 1] : "json";

  const dimensions = {
    llmArtifacts: assessLlmArtifacts(root),
    codebase: assessCodebase(root),
    gitTopology: assessGitTopology(root),
    projectType: assessProjectType(root),
    temporal: assessTemporal(root),
  };

  const flags = deriveFlags({ dimensions });
  const situation = deriveSituation(flags);
  const profileWithoutRecs = { dimensions, flags, situation };
  const recommendations = deriveRecommendations(profileWithoutRecs);

  const profile: AssessmentProfile = { ...profileWithoutRecs, recommendations };

  if (format === "json") {
    console.log(JSON.stringify(profile, null, 2));
  }
}

main();
```

- [ ] **Step 4: Install dependencies and verify the script runs**

```bash
cd plugins/constellize-harness/scripts
npm install
cd /Users/satkinson/Work/constellize/marketplace
npx tsx plugins/constellize-harness/scripts/assess.ts --format json
```

Expected: JSON output with the assessment profile for the marketplace repo itself.

- [ ] **Step 5: Commit assessor**

```bash
git add plugins/constellize-harness/scripts/
git commit -m "Add constellize-harness TypeScript assessor (Tier 1)"
```

---

### Task 4: Create the `init` skill

**Files:**
- Create: `plugins/constellize-harness/skills/init/SKILL.md`

- [ ] **Step 1: Write the init skill**

Write `plugins/constellize-harness/skills/init/SKILL.md`:

```markdown
---
name: init
description: Scaffold the llm/ directory structure for a project. Use when starting a new project or adding constellize to an existing codebase.
allowed-tools: Read, Glob, Grep, Write, Bash
metadata:
  model: sonnet
---

<task>
Scaffold the llm/ directory structure for this project.

First, run the assessor to understand the current state:

Run: `npx tsx <plugin-dir>/scripts/assess.ts --format json`

Then create any missing directories and template files under `llm/`:

1. **Create directory structure** (skip any that already exist):
   - `llm/memory-bank/`
   - `llm/construction/design/`
   - `llm/construction/requirements/`
   - `llm/construction/archive/`
   - `llm/features/`

2. **Create memory bank template files** (skip any that already exist):
   - `llm/memory-bank/projectbrief.md` — project objectives, requirements, scope
   - `llm/memory-bank/productContext.md` — why this project exists, user needs, success metrics
   - `llm/memory-bank/systemPatterns.md` — architecture, design patterns, technical decisions
   - `llm/memory-bank/techContext.md` — technologies, setup, constraints, dependencies
   - `llm/memory-bank/activeContext.md` — current focus, recent changes, next steps
   - `llm/memory-bank/progress.md` — completed work, known issues, timeline

3. **Pre-populate techContext.md** using assessment data:
   - Detected languages
   - Package manager
   - Project type (application/library/monorepo)
   - CI/CD presence

4. **Report what was created** — list new directories and files, note any that were skipped because they already existed.

This skill is idempotent — safe to run multiple times. It fills gaps without overwriting existing content.
</task>
```

- [ ] **Step 2: Commit**

```bash
git add plugins/constellize-harness/skills/init/
git commit -m "Add constellize-harness:init skill"
```

---

### Task 5: Create the `assess` skill

**Files:**
- Create: `plugins/constellize-harness/skills/assess/SKILL.md`

- [ ] **Step 1: Write the assess skill**

Write `plugins/constellize-harness/skills/assess/SKILL.md`:

```markdown
---
name: assess
description: Evaluate project state and present findings. Use when starting work on any project, resuming after a break, or getting oriented in an unfamiliar codebase.
allowed-tools: Read, Glob, Grep, Bash
metadata:
  argument-hint: "[--deep]"
  model: sonnet
---

<task>
Assess the current project state and present a readable profile.

Run the assessor script:

```
npx tsx <plugin-dir>/scripts/assess.ts --format json
```

Parse the JSON output and render a human-readable summary following this format:

```
Project: <name> (<project-type>)
Branch: <branch> (<ahead> ahead, <behind> behind <default-branch>)

  Memory Bank:    <progress-bar>  <present>/<total> files <details>
  Construction:   <progress-bar>  <present>/<total> artifacts <next-step>
  Codebase:       <progress-bar>  <summary>
  Freshness:      <progress-bar>  <summary>

  Flags: <comma-separated flags>
```

Progress bars use filled (█) and empty (░) blocks, 10 characters wide.

After presenting the summary, ask the user:

"What are you trying to do?"

Offer options based on the flags and situation detected:

- If greenfield or brownfield: "(A) Start building from scratch"
- If mid-build: "(A) Continue building where I left off"
- If stale-docs: "(A) Refresh documentation to match current state"
- Always include: "(B) Add a new feature"
- Always include: "(C) Fix a bug or respond to an incident"
- Always include: "(D) Get oriented — I'm new to this project"
- Always include: "(E) Something else"

Do NOT take any action beyond presenting the assessment and asking the question. This skill is purely diagnostic.
</task>
```

- [ ] **Step 2: Commit**

```bash
git add plugins/constellize-harness/skills/assess/
git commit -m "Add constellize-harness:assess skill"
```

---

### Task 6: Create the `plan` skill

**Files:**
- Create: `plugins/constellize-harness/skills/plan/SKILL.md`

- [ ] **Step 1: Write the plan skill**

Write `plugins/constellize-harness/skills/plan/SKILL.md`:

```markdown
---
name: plan
description: Propose a sequence of constellize skills based on project assessment and user intent. Use after running assess to get an actionable plan.
allowed-tools: Read, Glob, Grep, Bash
metadata:
  argument-hint: "[intent]"
  model: sonnet
---

<task>
Given the project assessment and the user's stated intent, propose an ordered sequence of constellize skills to execute.

First, run the assessor if no recent assessment is available:

```
npx tsx <plugin-dir>/scripts/assess.ts --format json
```

Then map the situation + intent to a skill sequence using this routing table:

**Greenfield + "Start building":**
1. constellize-harness:init
2. constellize-memory:establish
3. constellize-design:business-problem
4. constellize-design:vision-statement
5. constellize-design:ecosystem-map
6. constellize-design:constellation-map
7. constellize-design:gap-analysis
8. constellize-design:lock-constellation
9. constellize-design:implementation-sketch
10. constellize-design:code-generation-plan

**Brownfield + "Start building" or "Get oriented":**
1. constellize-harness:init
2. constellize-memory:establish (pre-populate from codebase scan)
3. constellize-harness:assess --deep

**Stale docs + "Refresh documentation":**
1. constellize-memory:triage-salvageable-knowledge
2. constellize-memory:recover-staleness
3. constellize-memory:update

**Mid-build + "Continue building":**
Resume at the next missing construction artifact. Filter out completed steps based on artifact presence in `llm/construction/design/`.

**Any situation + "Add a new feature":**
1. constellize-design:gap-analysis (feature-scoped)
2. constellize-design:implementation-sketch
3. constellize-design:code-generation-plan
4. constellize-craft:unit-tests
5. constellize-craft:integration-tests
6. constellize-memory:update

**Any situation + "Fix a bug or incident":**
1. constellize-deliver:incident-investigation
2. (user fixes the issue)
3. constellize-deliver:incident-postmortem
4. constellize-memory:update

**Any situation + "Get oriented":**
1. constellize-grow:first-week
2. constellize-harness:assess
3. constellize-memory:update

**Maintenance (stable codebase, complete docs):**
1. constellize-grow:health-assessment
2. constellize-craft:dependency-hygiene
3. constellize-grow:grow-organically

Present the plan in this format:

```
Based on: <situation>, <intent>

Proposed plan:
  1. <plugin>:<skill>  — <one-line reason>
  2. <plugin>:<skill>  — <one-line reason>
  ...

Approve this plan? (y/edit/n)
```

If the user says "edit", let them remove, reorder, or add steps. If "y", output the finalized plan as a numbered list that the orchestrate skill can consume.
</task>
```

- [ ] **Step 2: Commit**

```bash
git add plugins/constellize-harness/skills/plan/
git commit -m "Add constellize-harness:plan skill"
```

---

### Task 7: Create the `orchestrate` skill

**Files:**
- Create: `plugins/constellize-harness/skills/orchestrate/SKILL.md`

- [ ] **Step 1: Write the orchestrate skill**

Write `plugins/constellize-harness/skills/orchestrate/SKILL.md`:

```markdown
---
name: orchestrate
description: Execute an approved plan of constellize skills. Use after plan to run skills in sequence with progress tracking.
allowed-tools: Read, Glob, Grep, Write, Bash
metadata:
  argument-hint: "[advisory|spawn]"
  model: sonnet
---

<task>
Execute the approved plan from the plan skill.

The user specifies the mode:
- **advisory** (default): Present each step as a command to run manually
- **spawn**: Execute each step via `claude -p` (Phase 2 — not yet implemented)

**Advisory mode flow:**

For each step in the plan:

1. Present the step:
```
Step <n> of <total>: <skill description>
  /<plugin>:<skill> <arguments>

Press enter when done, or 's' to skip.
```

2. Wait for the user to confirm completion or skip.

3. After the step completes, verify the expected artifact was produced:
   - For design skills: check that the corresponding file exists in `llm/construction/design/`
   - For memory skills: check that memory bank files were updated
   - For craft skills: check that test files exist

4. Update `llm/memory-bank/activeContext.md` with progress after each completed step.

5. Move to the next step.

**On completion:**
- Run `constellize-memory:update` to capture the session
- Present a summary of what was accomplished:
```
Orchestration complete: <completed>/<total> steps

Completed:
  ✓ Step 1: <skill>
  ✓ Step 2: <skill>
  ⊘ Step 3: <skill> (skipped)

Next steps: <recommendations based on current state>
```

**Spawn mode (Phase 2):**
When implemented, each step will execute via:
```bash
claude -p "/<plugin>:<skill> <args>" \
  --allowed-tools "Read,Glob,Grep,Write,Bash" \
  --max-budget-usd 1.00
```

For now, if spawn mode is requested, inform the user it is not yet available and offer advisory mode instead.
</task>
```

- [ ] **Step 2: Commit**

```bash
git add plugins/constellize-harness/skills/orchestrate/
git commit -m "Add constellize-harness:orchestrate skill"
```

---

### Task 8: Update marketplace.json and push

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Add harness to marketplace**

Read the current `.claude-plugin/marketplace.json` and add the harness plugin entry to the plugins array:

```json
{
  "name": "constellize-harness",
  "source": "./plugins/constellize-harness",
  "description": "Project orchestration: assess state, plan next steps, execute constellize skills"
}
```

- [ ] **Step 2: Final commit and push**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Add constellize-harness to marketplace"
git push origin main
```

- [ ] **Step 3: Verify plugin loads**

In Claude Code:
```
/plugin marketplace remove constellize-plugins-official
/plugin marketplace add constellize/constellize-plugins-official
/plugin
/reload-plugins
/skills
```

Expected: `constellize-harness:init`, `constellize-harness:assess`, `constellize-harness:plan`, `constellize-harness:orchestrate` appear in the skills list alongside the existing 69 skills.
