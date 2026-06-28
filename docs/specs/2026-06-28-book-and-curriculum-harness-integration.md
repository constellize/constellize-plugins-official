# Book & Curriculum Harness Integration Spec

## Overview

Update the Constellize book and curriculum to use the real `constellize-harness` plugin as the primary workflow, while preserving plan-prompt-proceed as a prominent teaching concept — it's the pattern the harness automates, not a pattern the harness replaces.

## Guiding Principle

**Plan-prompt-proceed is the method. The harness is the automation of that method.**

The harness encodes plan-prompt-proceed:
- **Plan** = `assess` + `plan` (understand the situation, decide what to do)
- **Prompt** = skill execution (each skill is a structured prompt with context)
- **Proceed** = `execute` (review results, iterate, move forward)

The book teaches the *why* of plan-prompt-proceed. The harness shows the *how*. Students should understand both — the method first, then the tooling that embodies it.

---

## Part 1: Book Updates

### Introduction

**Current**: Describes Constellize as "prompts, agent patterns, memory structures, workflow practices." Discusses AI tools (Copilot, Cursor, Cline, Claude Code).

**Changes**:
- After the Claude Code paragraph (line ~63-67), add a new paragraph introducing the harness as the methodology made executable:

  > Constellize takes this further with an orchestration layer. The `constellize-harness` plugin for Claude Code embodies the plan-prompt-proceed pattern: it assesses your project state, proposes a plan of structured prompts to run, and guides you through executing them. Type `/constellize-harness:orchestrate` and the methodology activates — whether you're starting fresh, resuming mid-build, or onboarding to an unfamiliar codebase.

- Update the "What is Constellize" bullet list to add:

  > - **An orchestration harness** — A Claude Code plugin that automates the plan-prompt-proceed cycle, assessing project state and guiding you through the right prompts at the right time

**Priority**: Critical | **Scope**: Minor edit

### Ch1: The Intent-Implementation Gap

**Current**: Introduces the 5-step method and plan-prompt-proceed implicitly through the CodePromptu walkthrough.

**Changes**:
- After the 5 steps section (line ~100), add a callout box showing the mapping:

  ```
  ::: info
  **The Harness Encodes These Steps**

  The constellize-harness plugin automates the plan-prompt-proceed pattern
  across all five steps:

  - **Plan**: The harness assesses your project and proposes a sequence of skills
  - **Prompt**: Each skill is a structured prompt shaped by your project's context
  - **Proceed**: You review results, the harness verifies artifacts, and you move forward

  Run `/constellize-harness:orchestrate` to see this in action.
  :::
  ```

- Update prompt references to note marketplace availability: "Also available as `/constellize-design:vision-statement` in the Claude Code marketplace"

**Priority**: Important | **Scope**: New callout + minor edits to promptrefs

### Ch5: Designing for Memory and Change

**Current**: Describes `memory-bank/` and `construction/` as top-level project directories.

**Changes**:
- Update all directory examples from `memory-bank/` → `llm/memory-bank/` and `construction/` → `llm/construction/`
- Update the "Construction Zone" section (line ~66-79) to reflect the `llm/` consolidation:

  > All LLM-generated artifacts live under a single `llm/` directory. This consolidation makes project state assessment deterministic — the harness scans `llm/` to understand where you are without spending tokens.

- Add after the "Establish Memory Bank" promptref:

  > The harness automates this setup. Running `/constellize-harness:init` scaffolds the entire `llm/` directory structure and pre-populates `techContext.md` from your codebase. Running `/constellize-harness:orchestrate` on a project without `llm/` will suggest this as the first step.

- Update the directory structure diagram to show:
  ```
  project-root/
    llm/
      memory-bank/
        projectbrief.md
        productContext.md
        systemPatterns.md
        techContext.md
        activeContext.md
        progress.md
      construction/
        design/
        requirements/
        archive/
      features/
  ```

**Priority**: Critical | **Scope**: Moderate — path updates + 2 new paragraphs

### Ch9: Cultivating Adoption

**Current**: Introduces plan-prompt-proceed as a teaching pattern. Shows manual memory bank onboarding.

**Changes**:
- Keep plan-prompt-proceed prominent as the foundational pattern. Add that the harness *is* plan-prompt-proceed automated:

  > The harness doesn't replace plan-prompt-proceed — it encodes it. When you run `/constellize-harness:orchestrate`, you're executing the same cycle: the harness plans (assesses and proposes), prompts (runs structured skills), and proceeds (verifies and moves forward). Understanding the pattern means you can work effectively with or without the harness.

- Update "Introducing the Memory Bank to Your Team" to lead with orchestrate:

  > New team members can run `/constellize-harness:orchestrate` on their first day. The harness detects a mature codebase with no personal context and guides them through establishing a memory bank, reading existing documentation, and getting oriented — the same plan-prompt-proceed cycle, automated for onboarding.

- Update the prompt reference for "Onboard Team" to note it's available as `/constellize-grow:onboard-team`

**Priority**: Important | **Scope**: Moderate — reframe opening, add harness as entry point

### Ch2-4, Ch6-8

**Changes**: Update `memory-bank/` → `llm/memory-bank/` and `construction/` → `llm/construction/` path references where they appear. Add marketplace skill references to promptref blocks. No structural changes needed — these chapters are about methodology concepts that are timeless.

**Priority**: Nice-to-have | **Scope**: Minor path find-and-replace

### Prompt References (all chapters)

**Current**: Point to `{SITE_BASE}/prompts/v1/...`

**Change**: Add a line to each promptref block noting marketplace availability:

```
::: {.promptref title="Generate Vision Statement" url="{SITE_BASE}/prompts/v1/vision-statement"}
...existing content...

*Available as `/constellize-design:vision-statement` in the Claude Code marketplace.*
:::
```

**Priority**: Important (batched) | **Scope**: Minor per-block edit

---

## Part 2: Curriculum Updates

### Plugin Strategy

- **Primary**: Students install real `constellize-plugins-official` marketplace (`/plugin marketplace add constellize/constellize-plugins-official`)
- **Secondary**: `constellize-course:` skills remain as locally bundled alternatives, introduced in Module 5 as "behind the scenes" — showing students what the harness is doing under the hood
- **Rename**: Current local skills from `constellize:memory:establish` etc. to `constellize-course:establish` etc.

### Module-by-Module Changes

**Module 1: Establish Knowledge**

Current: Students manually run `/constellize:memory:establish`

New flow:
1. Students install marketplace: `/plugin marketplace add constellize/constellize-plugins-official`
2. Install plugins via `/plugin`
3. Run `/constellize-harness:orchestrate`
4. Harness detects brownfield (starter project has code but no `llm/`), proposes: init → establish → assess
5. Students approve and execute via advisory mode
6. Teaching point: "This is plan-prompt-proceed — the harness planned, each skill is a prompt, you reviewed and proceeded"

**Module 2: Specify Task List (Add Task feature)**

Current: Students manually run `/constellize:feature:specify`

New flow:
1. Run `/constellize-harness:orchestrate`
2. Harness detects mid-build with memory bank complete, asks intent
3. Student selects "Add a new feature"
4. Harness proposes: gap-analysis → implementation-sketch → code-generation-plan → unit-tests → integration-tests → update
5. Students approve, harness walks them through each step
6. Use `@system-architects` agent for architecture questions during design steps
7. Teaching point: "Notice the plan-prompt-proceed cycle at two levels — the harness plans the sequence, each skill plans the specific work"

**Module 3: Implement Task List**

Current: Students manually run `/constellize:feature:implement`

New flow:
1. Continue from Module 2's plan — harness moves to implementation steps
2. Use `@software-engineers` agent for code generation
3. Use `@qa-engineers` agent for test review
4. Harness verifies artifacts after each step

**Module 4: Specify Delete + Mark Complete**

Current: Students repeat the cycle manually

New flow:
1. Run `/constellize-harness:orchestrate` again for the next feature
2. Harness detects mid-build, shows progress, proposes next feature cycle
3. Students see the pattern solidify — orchestrate handles the routing
4. Introduce the idea: "You're learning the method by doing it. The harness ensures you don't skip steps."

**Module 5: Behind the Scenes**

Current: Opens the hood on skills/agents/prompts

New flow — THIS IS THE KEY MODULE for understanding:
1. Show students the `constellize-course:` local skills as alternative implementations
2. Demonstrate: "What orchestrate just did for you was run these individual skills in sequence"
3. Show a skill SKILL.md file — it's just a markdown prompt with frontmatter
4. Show the TypeScript assessor — deterministic state detection, no tokens spent
5. Run `/constellize-harness:assess` standalone to see the raw profile
6. Run `/constellize-harness:plan` standalone to see how routing works
7. Teaching point: "Plan-prompt-proceed is the pattern. The harness encodes it. The skills are the prompts. You can always run them manually — the harness just remembers the sequence for you."
8. Show that `constellize-course:specify` and `constellize-design:gap-analysis` achieve similar outcomes — one is course-scoped, the other is the real methodology

**Module 6: Specify Crew Agents**

Current: Students create spec for AI-powered task breakdown

New flow:
1. Run `/constellize-harness:orchestrate`, select "Add a new feature"
2. Use `@system-architects` agent to discuss the crew agents architecture
3. Use `@data-specialists` agent for the AI/LLM integration design
4. Harness guides through design skills

**Module 7: Implement Crew Agents**

Current: Code generation from spec

New flow:
1. Continue from Module 6's plan
2. Use `@software-engineers` agent for implementation
3. Use `@security-engineers` agent to review API key handling
4. Harness tracks progress through craft skills (tests, coverage)

**Module 8: Wrap-Up + Student Feature**

Current: Students add their own feature end-to-end

New flow:
1. Students run `/constellize-harness:orchestrate` independently for a feature of their choice
2. No instructor guidance on which skills to run — the harness handles it
3. Students should recognize plan-prompt-proceed at work
4. Debrief: "You just used the full Constellize methodology. The harness guided you, but you understood each step because of Modules 1-7."

### Instructor Guide Updates

- Update timing to account for plugin installation (5 min at start of Module 1)
- Add troubleshooting section for plugin issues
- Update all skill references from `constellize:*` to marketplace versions
- Add talking points for plan-prompt-proceed mapping at each module
- Add agent usage examples for each module

### Files to Modify

```
curriculum/
  course/
    night-1/
      1-establish-knowledge.md      # orchestrate + plugin install
      2-specify-task-list.md        # orchestrate for feature work
      3-implement-task-list.md      # continue plan + agents
      4-specify-delete-task.md      # repeat cycle via orchestrate
      README.md                     # update overview
    night-2/
      5-behind-the-scenes.md        # introduce constellize-course:, show internals
      6-specify-crew-agents.md      # orchestrate + agents
      7-implement-crew-agents.md    # continue + agents
      8-wrap-up.md                  # independent orchestrate
      slides.html                   # update screenshots/commands
    README.md                       # update course overview
  skills/                           # rename to constellize-course: prefix
  INSTRUCTORS-GUIDE.md              # update with new flow + agent usage
```

### Skill Renaming

Current local skills → renamed:
```
course:memory:establish     → constellize-course:establish
course:memory:update        → constellize-course:update
course:memory:recover       → constellize-course:recover
course:memory:revise        → constellize-course:revise
course:feature:specify      → constellize-course:specify
course:feature:implement    → constellize-course:implement
course:feature:verify       → constellize-course:verify
design:tui-designer         → constellize-course:tui-designer
design:tui-reviewer         → constellize-course:tui-reviewer
```

These become the "behind the scenes" alternatives shown in Module 5, not the primary workflow.

---

## Implementation Order

1. **Rename curriculum local skills** to `constellize-course:` prefix
2. **Update Module 1** — plugin install + first orchestrate
3. **Update Modules 2-4** — orchestrate-driven feature cycles with agents
4. **Update Module 5** — behind the scenes with local skills as alternatives
5. **Update Modules 6-8** — orchestrate + agents for advanced features
6. **Update Instructor Guide** — new flow, timing, troubleshooting
7. **Update book Introduction** — add harness paragraph
8. **Update book Ch1** — add plan-prompt-proceed/harness callout
9. **Update book Ch5** — `llm/` directory structure + init
10. **Update book Ch9** — orchestrate as onboarding entry point
11. **Batch update** — all path references and promptref marketplace notes across remaining chapters

---

## Key Message Throughout

> **Plan-prompt-proceed is how you think. The harness is how you execute.**
> Understanding the pattern means you can work with any AI tool. The harness just makes it effortless with Claude Code.
