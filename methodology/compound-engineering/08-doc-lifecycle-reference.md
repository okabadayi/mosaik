---
description: Canonical reader-facing reference for how documentation flows through the CE × Mosaik (the per-feature engine + complementary knowledge fabric). Per-doc Lifecycle Matrix + AGENTS.md primary + CLAUDE.md @AGENTS.md shim pattern + two scenarios (fresh + migrated) + CE features leveraged + source-of-truth map. Read this if you want "how does documentation work in this framework".
type: reference
status: active
date_created: 2026-05-26
date_updated: 2026-05-27
tags: [agentic-future, compound-engineering, documentation-lifecycle, agents-md-shim, reference]
related: ["[[00-readme]]", "[[03-migration-plan]]"]
---

# Doc-Lifecycle Reference — CE × Mosaik

## Purpose

Reader's entry point for documentation lifecycle in CE-piloted repos. Captures the **post-Phase-A steady-state methodology** for project-level documentation: which files exist, who owns each at scaffolding, who updates each at feature ship, and how staleness is prevented.

This is the canonical doc-lifecycle reference for CE-piloted repos in the Mosaik framework.

## The picture — a CE-piloted repo's documentation surface

```
~/repos/<project>/
├── AGENTS.md # Substantive instruction file (PRIMARY)
├── CLAUDE.md # Shim → `@AGENTS.md` + optional CC-specific
├── STRATEGY.md # Product anchor (CE-produced)
├── README.md # Human-facing project overview
├── CHANGELOG.md # Timeline + Current Focus + Decision Log
├── ISSUES.md # Known bugs + Resolved
├── docs/
│ ├── architecture.md # Conditional (target design)
│ ├── brainstorms/ # CE `/ce-brainstorm` output (R/A/F/AE-IDs)
│ ├── plans/ # CE `/ce-plan` output (U-IDs)
│ ├── features/ # Per-feature WIP, scorecards
│ ├── solutions/ # CE `/ce-compound` learning capture
│ └── archive/ # Completed plans + WIPs
└── .claude/rules/ # Project-specific rules
```

**Ownership at a glance:**

| Surface | Created by | Updated by |
|---|---|---|
| AGENTS.md | operator-managed (scaffolding skill deferred) | SD-CE `ship docs` (Components/Key Files); CE `/ce-compound` Discoverability Check (`docs/solutions/` slot); manual (Tech Stack, Conventions, Dispatcher — rare) |
| CLAUDE.md (shim) | operator-managed | Rarely touched |
| STRATEGY.md | CE `/ce-strategy` | CE `/ce-strategy` update mode on scope shift |
| README.md | operator-managed or scaffolding skill | SD-CE `ship docs` |
| CHANGELOG.md | operator-managed or scaffolding skill | SD-CE `ship docs` (Current Focus, Version History, Decision Log — per the doc-structure CHANGELOG convention) |
| ISSUES.md | operator-managed or scaffolding skill | SD-CE `ship docs` (Open → Resolved); new-issue capture = manual rule in AGENTS.md (interim default) |
| `docs/architecture.md` | operator-created (only if load-bearing target design not covered elsewhere) | Manual when runtime model shifts |
| `docs/brainstorms/*` | CE `/ce-brainstorm` | CE; archive to `docs/archive/` at scorecard time |
| `docs/plans/*` | CE `/ce-plan` | CE; archive to `docs/archive/` at scorecard time |
| `docs/features/*_wip.md` | SD-CE `capture status` | SD-CE; archive on feature ship |
| `docs/features/*_scorecard.md` | operator via walkthrough Step 8 | operator |
| `docs/solutions/*` | CE `/ce-compound` | CE `/ce-compound-refresh` |

## AGENTS.md primary + CLAUDE.md `@AGENTS.md` shim

### The pattern

`AGENTS.md` holds the **substantive** project-instruction content. `CLAUDE.md` is a thin **shim** that auto-loads AGENTS.md via Claude Code's `@`-import syntax:

```markdown
@AGENTS.md

## Claude Code

[OPTIONAL: Claude-Code-specific additions, e.g., plan-mode hints. Most CE-piloted
repos won't need anything here — the shim line alone is sufficient. Add only if
there's CC-only behavior that doesn't apply to other agents.]
```

`AGENTS.md` template skeleton:

```markdown
# <Project>
<one-line project description>

## Tech Stack
[chosen stack: language, package manager, runtime]

## Project Conventions
[rules — universal, agent-agnostic]

## Components & Architecture
[EMPTY at scaffolding — SD-CE populates at feature ship]

## Operational Dispatcher
> Informational, not enforced. Use descriptive statements ("X is useful when Y"),
> NOT directives ("check X when Y"). `ce-project-standards-reviewer` enforces
> AGENTS.md as project rules; phrasing matters.

[scenario-based discovery hints for ad-hoc work outside CE skills]

## Current State
**Compound Engineering — Phase A piloted.** See `CHANGELOG.md` Current Focus.

[Optional sections — Key Files, How to Run — populated as features ship]
```

### Why this pattern

- **CE prefers AGENTS.md.** `ce-brainstorm`, `ce-plan`, `ce-work` skills all read AGENTS.md first; CLAUDE.md only as compatibility fallback.
- **Anthropic recommends the shim.** From Claude Code's `memory.md § AGENTS.md`: *"If your repository already uses AGENTS.md for other coding agents, create a CLAUDE.md that imports it so both tools read the same instructions without duplicating them."* The `@`-import syntax supports up to 5-hop recursion.
- **Cross-agent forward-compatibility.** Codex, Cursor, OpenAI agents all read AGENTS.md. Substantive content there is portable across agents.

## Per-doc Lifecycle Matrix

Six project-level files in scope. Per row: creator at scaffolding, scaffolding-time content rules, live update trigger, staleness prevention.

| File | Creator at scaffolding | Scaffolding-time content rules | Live update trigger | Staleness prevention |
|---|---|---|---|---|
| **`AGENTS.md`** | operator-written (scaffolding skill is deferred follow-up) | Title + project description + Tech Stack + Project Conventions + Operational Dispatcher (universal scenarios) + Current State pointer. **EMPTY:** Components & Architecture, Key Files. | Components & Architecture → SD-CE `ship docs` at feature ship. Tech Stack / Conventions / Dispatcher → manual (rare). CE `/ce-compound` Discoverability Check auto-maintains the `docs/solutions/` slot. | `audit-docs` skill (Phase B) at scorecard checkpoints + after CE plugin upgrades — greps claims vs filesystem |
| **`CLAUDE.md` (shim)** | operator-managed | `@AGENTS.md` on line 1. Optional Claude-Code-specific sections below if needed (rare). | Rarely touched | Trivial — verify `@AGENTS.md` resolves |
| **`README.md`** | operator-managed or scaffolding skill | Title + 1-line description + project status line ("v0 — no features shipped yet") + section headers for Components / Features (EMPTY) | SD-CE `ship docs` at feature ship | `audit-docs`: features in README should appear in git log; components should exist in filesystem |
| **`CHANGELOG.md`** | operator-managed or scaffolding skill | **Index at top** (anchor links to Current Focus / Roadmap / Version History / Decision Log; cross-platform `[text](#heading-slug)` syntax) + section headers all empty. Current Focus = "no features shipped yet." Per the convention codified in `skills/doc-structure/SKILL.md § CHANGELOG Format` (Index + drop Recent Updates + ISO dates + latest-version-first + Keep a Changelog change-type grouping + Decision Log promotion threshold). | SD-CE `ship docs` updates Current Focus, prepends to Version History (latest-version-first, ISO dates, change-type grouped), appends to Decision Log **as dated stubs** with any substantial detail relocated to `docs/reference/<topic>.md` (`docs/solutions/` stays CE-owned — `/ce-compound` only). | `audit-docs`: Version History entries map to git tags / merges; Decision Log stubs carrying un-homed detail should be flagged |
| **`ISSUES.md`** | operator-managed or scaffolding skill | **Index at top** (anchor links per-component, `[text](#heading-slug)` cross-platform syntax) + per-component sections + `## Resolved Issues`. Per the convention codified in `doc-structure` skill § ISSUES.md (lightweight capture + reference-doc promotion + GH-issues for committed work). | SD-CE `ship docs` moves resolved entries to `## Resolved Issues` with date + feature reference; flags heavy entries for promotion to `docs/reference/<topic>.md`. New-issue capture: manual rule in AGENTS.md Operational Dispatcher (interim default; revisit if frictional after 3+ features). | `audit-docs`: Resolved entries should have feature/commit refs; Index entries resolve |
| **`docs/architecture.md`** (conditional) | NOT created by default. Allowed at scaffolding only if load-bearing target design isn't covered by STRATEGY.md + CHANGELOG Decision Log + per-feature plans. Mark as "target design — reconcile at first ship." | If created: target-design + ASCII diagrams + cross-cutting runtime synthesis. DO NOT duplicate Decision Log rationale. | Manual when runtime model shifts; reconcile against Decision Log at each feature ship | Review at scorecard checkpoints — verify no divergence vs Decision Log + STRATEGY.md tracks |

### Scaffolding-time discipline rule

At repo creation, project-level docs have **section headers + intent only**. Components / Features / Version History / Key Files sections start **EMPTY**. SD-CE populates as features ship.

This rule exists because pre-CE Claude scaffolding agents tend to project from requirements briefs into fictional Components tables — verified empirically in an early CE pilot (cleanup stripped CLAUDE.md from ~105 lines to ~47 lines after a fictional table claimed source files, skills, and a sqlite database all existed when none did). Resist the temptation; empty section headers are correct.

## Two scenarios

### Fresh repo scaffolding

Order of operations for a brand-new CE-piloted repo:

1. `mkdir ~/repos/<name> && cd ~/repos/<name>`
2. `git init` + remote setup
3. Deliberate scaffolding of the 5 guaranteed files + 1 conditional (AGENTS.md substantive, CLAUDE.md shim, README, CHANGELOG, ISSUES; architecture.md conditional). Empty section headers per matrix.
4. Language scaffolding (`pyproject.toml` etc.) as needed
5. `.claude/rules/` populated with project-specific rules
6. Initial commit + `git tag pre-ce-phase-a`
7. `/ce-setup` — bootstraps `.compound-engineering/`
8. `/ce-strategy` — produces `STRATEGY.md`
9. First feature: `/ce-brainstorm` → `/ce-plan` → `/ce-work` (with SD-CE `capture status` for WIP) → `/ce-commit-push-pr` → `/ce-compound` (auto-triggers Discoverability Check) → SD-CE `ship docs`

Net: AGENTS.md / README / CHANGELOG / ISSUES grow organically with shipped reality from feature 1 onward.

> Per-template content rules live in `skills/doc-structure/SKILL.md` (the canonical doc-structure skill); the AGENTS.md+shim methodology and full Per-doc Lifecycle Matrix are also covered there + in Mosaik's `TECHNICAL.md`.

### Migrated repo (importing pre-CE)

Order of operations when bringing an existing repo into CE adoption:

1. `cd ~/repos/<imported-name>`
2. **Pre-`/ce-setup` audit** — see [`03-migration-plan.md § 3.0 Prereq 4`](03-migration-plan.md). Five checks: grep claims vs filesystem; command-validity (`How to Run` commands run?); git-proof Version History (or pre-convention `Recent Updates`); planned-vs-existing labeling; AGENTS.md/CLAUDE.md restructure (substantive CLAUDE.md → AGENTS.md + shim).
3. Audit `.claude/rules/` for content; verify alignment with CE methodology
4. `git tag pre-ce-phase-a` (revert point)
5. `/ce-setup` — bootstraps CE infrastructure
6. `/ce-strategy` — produces `STRATEGY.md`
7. First feature flow (same as fresh § above step 9)

Restructure rule for migration: if pre-existing CLAUDE.md has substantive cross-agent content, **MOVE** it to AGENTS.md (use `git mv` for history preservation when possible); reduce CLAUDE.md to `@AGENTS.md` shim + Claude-Code-specific only. Archive `docs/vision.md` to `docs/archive/` once STRATEGY.md established. Delete `docs/operations.md` (deprecated).

> Full detail: [`03-migration-plan.md § 3.0`](03-migration-plan.md).

## CE features leveraged

Four CE-native features close lifecycle gaps natively; no custom operator-side glue needed:

| CE feature | What it does | What it replaces |
|---|---|---|
| `/ce-compound` **Discoverability Check** | Every compound fire, inspects substantive instruction file (AGENTS.md / CLAUDE.md), assesses agent's ability to discover `docs/solutions/` + structure + when-to-search; drafts minimal addition if missing | Manual rule to update AGENTS.md when `docs/solutions/` grows |
| `/ce-compound-refresh` | Refreshes stale learning docs under `docs/solutions/`. Five outcomes (Keep / Update / Consolidate / Replace / Delete). Headless mode. | Custom solution-doc staleness audit |
| `/ce-strategy` update mode | Detects existing `STRATEGY.md` and runs in update mode for scope-shift rerun | Custom STRATEGY.md refresh trigger |
| `ce-project-standards-reviewer` (auto-invoked during `/ce-code-review`) | Audits diffs against project standards in AGENTS.md / CLAUDE.md (frontmatter rules, naming, tool-selection, protected artifacts) | Manual standards enforcement |

`audit-docs` (Phase B, deferred standalone skill) is strictly **claims-vs-filesystem-reality** and does NOT overlap with `ce-project-standards-reviewer`'s scope (project rules). The two are complementary: standards-reviewer enforces written rules; audit-docs verifies factual claims.

## Audit cadence

`audit-docs` skill (Phase B) is **operator-triggered at known checkpoints**, not a recurring cron:

- **Scorecard-checkpoint invocation** — at walkthrough Step 8 after a feature ships, optionally include a doc audit
- **Post-CE-plugin-upgrade invocation** — after `/ce-update-plugin` or any CE version bump
- **At imported-repo `/ce-setup` time** — runs BEFORE `/ce-setup` to clean pollution before CE adoption begins

No recurring schedule. The operator chooses when based on context.

## Source-of-truth map

When in doubt about authoritative behavior, read the live runtime files (not the design docs):

| Surface | Live runtime (authoritative) | Design / blueprint |
|---|---|---|
| Doc-structure conventions | [`skills/doc-structure/SKILL.md`](../../skills/doc-structure/SKILL.md) | The doc-structure skill is the canonical source of truth. |
| SD-CE agent body (`ship docs`, `capture status`, `reference doc`) | [`agents/software-documenter-ce.md`](../../agents/software-documenter-ce.md) | The live agent definition is the canonical source. |
| CE skills (brainstorm, plan, work, compound, strategy, refresh) | CE plugin source at [github.com/EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | [`01-overview.md`](01-overview.md), [`04-inventory.md`](04-inventory.md) |
| Anthropic shim pattern | Claude Code `memory.md § AGENTS.md` (official docs) | — |

CE plugin version pinned at adoption: **v3.8.4** (commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`, released 2026-05-21). When CE upgrades, re-verify the SKILL.md paths above against the new version.

## CE-piloted repos status

| Repo | Status | Notes |
|---|---|---|
Pilot validation (one pilot, 2026-05-27): the migrate-existing-repo walkthrough was executed end-to-end on a real pre-CE repo — Phase 1 cleanup ran cleanly with the AGENTS.md+shim restructure. Future CE-piloted repos follow [`09-fresh-repo-scaffolding.md`](09-fresh-repo-scaffolding.md) (fresh) or [`10-migrate-existing-repo.md`](10-migrate-existing-repo.md) (imported); both produce the AGENTS.md+shim pattern from the start.

## Cross-references

- [[00-readme]] — folder index
- [[03-migration-plan]] § 3.0 — Prereq 4 audit for imported repos

---

*Reader-shaped reference for "how documentation works in CE-piloted repos" inside the Mosaik framework.*
