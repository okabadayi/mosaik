---
description: Operator step-by-step for spinning up a brand-new CE-piloted repo today. Covers local + GitHub setup, the 5 guaranteed files (AGENTS.md primary + CLAUDE.md shim + README + CHANGELOG + ISSUES), language scaffolding, .claude/rules/, initial commit + pre-ce-phase-a revert anchor, CE bootstrap (/ce-setup + /ce-strategy), first feature chain. Manual step 2 today (Claude-assisted); future scaffold-ce-repo skill will automate. For migrated/imported repos, see 03-migration-plan.md § 3.0 Prereq 4.
type: reference
status: active
date_created: 2026-05-26
date_updated: 2026-05-27
tags: [agentic-future, compound-engineering, scaffolding, fresh-repo, operator-guide]
related: ["[[00-readme]]", "[[03-migration-plan]]", "[[05-walkthrough]]", "[[08-doc-lifecycle-reference]]"]
---

# Scaffold a New CE-Piloted Repo

Operator script for fresh CE-piloted repos. Pair with [`08-doc-lifecycle-reference.md`](08-doc-lifecycle-reference.md) (methodology) and [`05-walkthrough.md`](05-walkthrough.md) (per-feature flow after first commit).

For **existing/imported** repos (pre-CE codebase you're bringing into CE), see [`03-migration-plan.md § 3.0 Prereq 4`](03-migration-plan.md) instead — that flow audits and restructures rather than scaffolds.

## Prerequisites

- CE plugin installed in Claude Code (verify: `claude plugin list | grep compound-engineering`)
- GitHub CLI auth working (`gh auth status`)
- Project name chosen (kebab-case)

## The 7-step process

### Step 1 — Local + GitHub setup

```bash
mkdir ~/repos/<name> && cd ~/repos/<name>
git init -b main
gh repo create <name> --private --source=. --remote=origin
```

### Step 2 — Scaffold the 5 guaranteed files

**Today** (until a `scaffold-ce-repo` skill is built — deferred): either delegate to the agent or copy templates manually.

**Option A — delegate to Claude in this cwd:**

> "Scaffold a new CE-piloted repo following Mosaik's AGENTS.md+shim methodology (see `skills/doc-structure/SKILL.md` and `TECHNICAL.md`) and the Per-doc Lifecycle Matrix in `08-doc-lifecycle-reference.md`. Empty section headers only — no fabricated Components. The project is `<name>`, a `<one-line description>`."

**Option B — copy templates manually from `skills/doc-structure/SKILL.md` (Mosaik's doc-structure skill — has canonical AGENTS.md + CHANGELOG + README + ISSUES templates).**

Either way, the 5 files at the end of this step:

| File | Content rules |
|---|---|
| **`AGENTS.md`** (substantive) | Title + 1-line description + Tech Stack + Project Conventions + Operational Dispatcher (universal scenarios only — **must include the canonical new-issue-capture bullet per the AGENTS.md+shim methodology**: "When a bug surfaces mid-work, adding a one-line entry to `ISSUES.md` Open Issues with date + brief is the lightweight capture path; SD-CE moves it to Resolved at ship time.") + Current State pointer. **EMPTY:** Components & Architecture, Key Files. |
| **`CLAUDE.md`** (shim) | `@AGENTS.md` on line 1. Optional CC-specific section below only if there's behavior that doesn't apply to other agents (rare). |
| **`README.md`** | Title + 1-line description + status line ("v0 — no features shipped yet") + EMPTY Components / Features headers |
| **`CHANGELOG.md`** | EMPTY Current Focus / Roadmap / Recent Updates / Version History / Decision Log headers. Current Focus = "no features shipped yet." |
| **`ISSUES.md`** | EMPTY Open Issues / Resolved Issues headers |

**`docs/architecture.md` is CONDITIONAL** — create only if there's load-bearing target design not captured by STRATEGY.md + Decision Log + per-feature plans. Mark as "target design — reconcile at first ship."

### Step 3 — Language scaffolding

Whatever the stack is. Examples:

```bash
uv init # Python (preferred)
pnpm init # Node
cargo init # Rust
```

Add language-specific files: `pyproject.toml`, `package.json`, `Cargo.toml`, `.gitignore` (language template).

### Step 4 — Project-specific rules

```bash
mkdir -p .claude/rules
```

Populate `collaboration.md`, `code-quality.md`, `pre-commit.md` adapted to the project. Use `~/repos/CLAUDE.md` defaults or copy from <pilot-repo> as a reference. Keep rules narrow to the project; universal rules already load from `~/.claude/rules/`.

### Step 5 — Initial commit + revert anchor

```bash
git add -A
git commit -m "Initial commit: <name> scaffolding (pre-CE)"
git push -u origin main
git tag pre-ce-phase-a
git push --tags
```

The `pre-ce-phase-a` tag is your revert point if you ever want to undo CE introduction. Don't skip it.

### Step 6 — CE bootstrap

In Claude Code (cwd = the new repo):

```
/ce-setup # bootstraps .compound-engineering/
/ce-strategy # interactive interview → produces STRATEGY.md (Rumelt-shaped)
```

`/ce-strategy` runs an interview — be ready to answer target problem / approach / persona / metrics / tracks. Output is `STRATEGY.md` at the repo root, read by `/ce-brainstorm`, `/ce-plan`, and `/ce-work` as upstream grounding.

### Step 7 — First feature

The CE skill chain. You invoke each in sequence; CE drives the work.

```
/ce-brainstorm # → docs/brainstorms/<feature>-requirements.md (R/A/F/AE-IDs)
/ce-plan # → docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md (U-IDs traced)
/ce-work # autonomous execution; pauses for scorecard
```

Mid-flight (optional, when work spans multiple sessions or has significant trial-and-error):

```
@software-documenter-ce capture status # WIP update at docs/features/<feature>_wip.md
```

At ship:

```
/ce-commit-push-pr # commits + pushes + opens PR
/ce-compound # learning capture; auto-triggers Discoverability Check
@software-documenter-ce ship docs # populates AGENTS.md Components, README, CHANGELOG, ISSUES
```

For the full per-feature operator walkthrough (10 steps with prompts), see [`05-walkthrough.md`](05-walkthrough.md).

## Key disciplines

### Empty section headers are correct

At scaffolding, AGENTS.md / README / CHANGELOG / ISSUES have **section headers + intent only**. Components / Features / Recent Updates / Key Files start EMPTY. SD-CE populates them as features ship.

This is the rule the methodology exists to enforce. Pre-CE Claude scaffolding agents tend to project from a requirements brief into fictional Components tables — verified empirically in <pilot-repo> (cleanup stripped CLAUDE.md from 105 → 47 lines after a fictional table claimed `src/bot.py`, 7 skills, `data/<pilot-repo>.sqlite` existed when none did). Resist the temptation; empty is correct.

### Operational Dispatcher tone

Descriptive, not imperative. ✅ *"ISSUES.md is useful when debugging."* ❌ *"Check ISSUES.md when debugging."*

`ce-project-standards-reviewer` reads AGENTS.md as enforceable project rules; imperative phrasing turns informational hints into enforced standards. The Dispatcher section is for routing, not compliance.

### Don't pre-create solution docs

`docs/solutions/` is auto-populated by `/ce-compound` post-feature-1. Don't seed it manually with anticipated learnings. The Discoverability Check fires after the first compound — that's when AGENTS.md gets the `docs/solutions/` awareness pointer.

### Don't create `docs/vision.md` or `docs/operations.md`

Both deprecated as of 2026-05-27. Vision content is covered by STRATEGY.md (CE-piloted repos) + README + CHANGELOG Roadmap. Operations content is README `Quick Start` at solo scale; dedicated DevOps configs at large scale. Neither file belongs in new CE-piloted repos.

## What happens at first SD-CE ship docs

After feature 1 ships and you invoke `@software-documenter-ce ship docs`, SD-CE:

1. Detects `AGENTS.md` exists at repo root → targets AGENTS.md (not CLAUDE.md) for the Components table.
2. Adds a row to AGENTS.md `Components & Architecture`.
3. Updates README components paragraph + features index.
4. Updates CHANGELOG Current Focus (mark complete) + Recent Updates entry + Version History detailed entry + Decision Log (if architectural decisions surfaced — judgment call).
5. Moves any newly resolved ISSUES.md entries Open → Resolved with date + feature reference.
6. If `/ce-compound` fired earlier and the Discoverability Check ran, AGENTS.md now contains a one-line `docs/solutions/` awareness pointer.

Net: AGENTS.md grows organically with shipped reality from feature 1 onward. Empty scaffolding fills in via real work, not optimistic projection.

## Reference cardinality

The reference numbers you'll see in CE output:
- **R-IDs** — Requirements (from `/ce-brainstorm`)
- **A-IDs** — Actors
- **F-IDs** — Key Flows
- **AE-IDs** — Acceptance Examples
- **U-IDs** — Implementation Units (from `/ce-plan`)

R → A/F/AE → U. U-IDs propagate into task prefixes, commit messages, PR descriptions. Never renumber — see [`01-overview.md § stable IDs`](01-overview.md).

## Anti-patterns (don't do these)

- ❌ Don't write CLAUDE.md with substantive content alongside an AGENTS.md shim — the shim direction reverses. CLAUDE.md is the shim; AGENTS.md is substantive.
- ❌ Don't skip the `pre-ce-phase-a` tag. It's your only clean revert anchor.
- ❌ Don't run `/ce-setup` before initial commit. CE wants a clean repo with the 5 files committed first.
- ❌ Don't run `/ce-brainstorm` before `/ce-strategy`. STRATEGY.md is upstream grounding for brainstorm.
- ❌ Don't run `@software-documenter-ce ship docs` mid-feature. It's for ship-time (after `/ce-commit-push-pr` + `/ce-compound`). Use `capture status` mid-feature.
- ❌ Don't pre-populate Components & Architecture in AGENTS.md from a mental model. SD-CE does this from shipped reality.

## Cross-references

- [[08-doc-lifecycle-reference]] — Per-doc Lifecycle Matrix + AGENTS.md primary rationale + scenario summaries
- [[03-migration-plan]] § 3.0 Prereq 4 — parallel flow for imported/migrated repos
- [[05-walkthrough]] — per-feature operator walkthrough (the Step 7 chain expanded with prompts at each checkpoint)
- [[04-inventory]] — which CE skill when (cheat sheet)
- [[01-overview]] — deep CE reference (architecture, primitives, stable IDs)
- the methodology spec for fresh repo flow (this guide is the practitioner-script distillation)

---

*Created 2026-05-26. Operator script for fresh CE-piloted repos. Manual Step 2 today (agent-assisted from templates); will be automated when a `scaffold-ce-repo` skill is built (deferred). For migrated/imported repos, use [`03-migration-plan.md § 3.0 Prereq 4`](03-migration-plan.md) instead.*
