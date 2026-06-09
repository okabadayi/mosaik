---
name: doc-structure
description: >
  Documentation system for software projects. Defines the 4-type per-feature
  doc system (Plan, WIP, User Doc, Reference), the Per-doc Lifecycle Matrix
  for project-level docs (AGENTS.md primary + CLAUDE.md @AGENTS.md shim,
  README, CHANGELOG, ISSUES, docs/architecture.md), per-repo structure,
  naming conventions, frontmatter schema, CHANGELOG/README/ISSUES formats,
  scaffolding-time discipline, and CE-features-leveraged pointers. Used by
  the software-documenter-ce agent, and user-invocable when checking conventions.
user-invocable: true
---

# Documentation Structure

Single source of truth for documentation conventions across all software projects following the Mosaik framework. Projects live at `~/repos/<project>/`; each carries its own docs. This skill is the canonical blueprint — used by the software-documenter-ce agent and available on demand.

This skill is for **software repos only** in the Mosaik framework scope.

## 4-Type Documentation System

| Type | Naming | Purpose | Location | Lifecycle |
|------|--------|---------|----------|-----------|
| **Plan** | `<feature>_plan.md` | Pre-implementation: requirements, decisions, steps | `docs/features/` | Created → Implemented → Archive |
| **WIP** | `<feature>_wip.md` | Working memory: learnings, blockers, progress | `docs/features/` | Created → Feature complete → Archive |
| **User Doc** | `<feature>.md` | User-facing: how to use, configuration | `docs/` | Permanent |
| **Reference** | `<feature>_reference.md` | Technical: internals, debugging, architecture | `docs/` | Permanent |

### Lifecycle Flow

```
Planning       → docs/features/<feature>_plan.md
Implementation → docs/features/<feature>_wip.md
Completion     → Archive plan + WIP to docs/archive/
               → Create docs/<feature>_reference.md
               → Create docs/<feature>.md (if user-facing)
```

### Why Plans Matter

Plans capture **why** — the decisions, alternatives rejected, success criteria, and context. Without plans, future sessions lose the reasoning behind implementations. Create them for anything non-trivial; skip only for bug fixes and minor tweaks.

## CE-Piloted Repos — Additional Artifact Types

Repos that have run `/ce-setup` (Compound Engineering pilot — see `methodology/compound-engineering/03-migration-plan.md`) accumulate artifacts beyond the original 4-type system above. The 4-type system itself is mostly preserved — only Plan changes shape. Then CE adds new artifact types on top.

**4-type system in CE-piloted repos — what changes, what stays:**

| 4-type | Non-CE repo path | CE-piloted repo path | Written by |
|---|---|---|---|
| **Plan** | `docs/features/<feature>_plan.md` (SD prose) | `docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md` — **REPLACED.** CE-structured with U-IDs traced to R/AE-IDs from `docs/brainstorms/<feature>-requirements.md`. Different folder, different naming, different schema | CE `/ce-plan` |
| **WIP** | `docs/features/<feature>_wip.md` | `docs/features/<feature>_wip.md` — **same location** | SD-CE `capture status` |
| **User Doc** | `docs/<feature>.md` | `docs/<feature>.md` — **same location** | SD-CE `ship docs` (only when user-facing) |
| **Reference** | `docs/<feature>_reference.md` | `docs/<feature>_reference.md` — **same location** | SD-CE `reference doc <instruction>` |

**Why this matters:** three of the four types preserve their location and naming in CE-piloted repos — only the invocation path changes. The Plan type is the only structural change: CE replaces SD's prose-style plan with its date-numbered structured plan with stable IDs. SD's `docs/features/<feature>_plan.md` is NOT written by SD-CE in CE-piloted repos; any pre-existing file at that path from before CE adoption stays as historical record but isn't updated.

**CE-added artifact types (on top of the 4-type system):**

| Type | Naming | Purpose | Location | Owner |
|---|---|---|---|---|
| **Product anchor** | `STRATEGY.md` | Target problem / approach / persona / metrics / tracks (Rumelt-inspired). Read by `/ce-ideate`, `/ce-brainstorm`, `/ce-plan` as upstream grounding | Repo root | CE (`/ce-strategy`) |
| **Brainstorm requirements** | `<feature>-requirements.md` | Requirements with R-IDs (Requirements), A-IDs (Actors), F-IDs (Key Flows), AE-IDs (Acceptance Examples) | `docs/brainstorms/` | CE (`/ce-brainstorm`) |
| **CE plan** | `YYYY-MM-DD-NNN-<feature>-plan.md` | Implementation plan with U-IDs (Implementation Units) traced to R/AE-IDs. Distinct from SD's `<feature>_plan.md` naming | `docs/plans/` | CE (`/ce-plan`) |
| **Reusable solution** | `<slug>.md` | Bug-track or knowledge-track lesson with grep-first frontmatter (`tags`, `module`, `problem_type`) | `docs/solutions/<category>/` | CE (`/ce-compound`) |
| **Per-feature scorecard** | `<feature>_scorecard.md` | Pilot evaluation per-feature (7 Y/N questions + tier expectation count + overhead estimate) | `docs/features/` | Operator via walkthrough Step 8 |

**ID conventions**: never renumber. R-IDs flow into A/F/AE-IDs; AE-IDs flow into U-IDs; U-IDs propagate into task prefixes, commit messages, PR descriptions. See `methodology/compound-engineering/01-overview.md` § "stable IDs" for the full chain.

**Artifact proportionality**: number of durable artifacts must scale with blast radius (Solo 0-2 / Internal 3-5 / Public full chain when warranted). See `methodology/compound-engineering/03-migration-plan.md § 2.5` for the proportionality rule. The CE Core Set is 9 skills (see `methodology/compound-engineering/04-inventory.md § 2.0`); the doc-structure conventions in this skill cover repo-file outputs of those skills.

**SD variant in CE-piloted repos**: use `@software-documenter-ce` (three modes: `capture status` / `ship docs` / `reference doc <instruction>`). It writes to the original 4-type doc surfaces (WIP, user doc, reference doc) AND maintains README + substantive-instruction-file Components + ISSUES.md + CHANGELOG via the `ship docs` mode. CE skills handle the CE-added artifacts (STRATEGY.md, brainstorms/, plans/, solutions/, scorecards).

## Per-doc Lifecycle Matrix (Project-Level Docs)

Distinct from the per-feature 4-type system above: this matrix covers the **project-level docs** that live at the repo root (or `docs/` for architecture). The 4-type system (Plan / WIP / User Doc / Reference) is per-feature; this matrix is per-project. They coexist.

Six project-level files are in scope (plus AGENTS.md as the primary, per the CE-preferred + Anthropic-recommended shim pattern):

| File | Creator at scaffolding | Scaffolding-time content rules | Live update trigger | Staleness prevention |
|---|---|---|---|---|
| `AGENTS.md` (substantive instruction file) | Operator manual (initial) — a dedicated scaffolding skill is a deferred follow-up | Title + project description + Tech Stack + Project Conventions (project-specific only; universal rules cascade from parent-tier `AGENTS.md` — see [`methodology/agent-collaboration-principles.md`](../../methodology/agent-collaboration-principles.md)) + Operational Dispatcher (universal scenarios) + Current State pointer. **EMPTY at scaffolding:** Components & Architecture, Key Files. | Components & Architecture → SD-CE `ship docs` at feature ship. Tech Stack / Conventions / Dispatcher → manual (rare). CE `/ce-compound` Discoverability Check auto-maintains the `docs/solutions/` surface inside AGENTS.md/CLAUDE.md | At scorecard checkpoints + after CE plugin upgrades, invoke an `audit-docs` skill (deferred) to grep claims vs filesystem |
| `CLAUDE.md` (shim) | Operator manual | `@AGENTS.md` on line 1. Optional Claude-Code-specific sections below (rare). | Rarely touched; only if Claude-Code-specific overrides emerge | Trivial — usually just the shim line; verify `@AGENTS.md` resolves |
| `README.md` | Operator manual or scaffolding skill | Title + 1-line description + project status line ("v0 — no features shipped yet") + section headers for Components / Features (EMPTY) | SD-CE `ship docs` at feature ship | `audit-docs`: features in README should appear in git log; components should exist in filesystem |
| `CHANGELOG.md` | Operator manual or scaffolding skill | Section headers (Current Focus / Roadmap / Recent Updates / Version History / Decision Log) all empty. Current Focus = "no features shipped yet." | SD-CE `ship docs` covers ALL 4 sections at feature ship (Current Focus, Recent Updates, Version History detailed entry, Decision Log for architectural decisions — judgment call) | `audit-docs`: Recent Updates entries should map to git tags / merges |
| `ISSUES.md` | Operator manual or scaffolding skill | **Index at top** + per-component sections + `## Resolved Issues`. Use cross-platform anchor syntax `[text](#heading-slug)`. See § ISSUES.md for the full canonical structure. | SD-CE `ship docs` moves resolved entries Open → Resolved with date + feature reference; flags heavy entries for promotion to `docs/reference/<topic>.md` | `audit-docs`: Resolved entries should have feature/commit refs; Index entries resolve |
| `docs/architecture.md` (conditional) | NOT created by default. Allowed at scaffolding only if load-bearing target design / hypotheses aren't captured by STRATEGY.md + CHANGELOG Decision Log + per-feature plans. Mark as "target design — reconcile at first ship." | If created: target-design + ASCII diagrams + cross-cutting runtime synthesis. DO NOT duplicate Decision Log rationale — point at CHANGELOG Decision Log for the "why." | Manual when runtime model materially shifts; reconcile against Decision Log at each feature ship | Review at scorecard checkpoints — verify no divergence vs Decision Log + STRATEGY.md tracks |

**Scaffolding-time discipline rule.** At repo creation, project-level docs have section headers + intent only; Components / features / Recent Updates / Key Files sections start EMPTY. SD-CE populates as features ship. Pre-CE Claude scaffolding agents tend to project from requirements briefs into fictional Components tables — verified empirically in pilot use. Resist this; empty section headers are correct.

**AGENTS.md primary + CLAUDE.md shim — why, and at every tier.** CE skills (`ce-brainstorm`, `ce-plan`, `ce-work`) explicitly prefer AGENTS.md with CLAUDE.md as compatibility fallback. Anthropic's `memory.md` docs recommend the same pattern: `CLAUDE.md` starts with `@AGENTS.md`, optionally followed by Claude-Code-specific additions. Forward-compatible with Codex, Cursor, OpenAI agents (all read AGENTS.md). Substantive content lives in AGENTS.md; CLAUDE.md is the auto-load bridge. **Apply the same pattern at every tier with substantive content** — including the parent tier above a repo cluster (`~/repos/AGENTS.md` + `~/repos/CLAUDE.md` shim) where universal collaboration rules live once and cascade to every per-repo session. See [`methodology/agent-collaboration-principles.md`](../../methodology/agent-collaboration-principles.md) § "How to wire these into a repo cluster" for the tier layout.

**Operational Dispatcher pattern (in AGENTS.md).** Scenario-based discovery hints for ad-hoc work outside CE skill invocations — e.g., "ISSUES.md and `docs/solutions/` are useful starting points when debugging"; "`docs/reference/<portal>.md` captures the working knowledge for portal X." **Tone is descriptive, not imperative** — `ce-project-standards-reviewer` reads AGENTS.md as enforceable project rules; phrasing matters. Use descriptive statements ("X is useful when Y"), NOT directives ("check X when Y"). The `docs/solutions/` slot is auto-maintained by CE's `/ce-compound` Discoverability Check post-feature-1; manual dispatcher rules cover other routing.

**CE-leveraged features that obviate custom glue:**

- `/ce-compound` Discoverability Check — every compound fire, inspects AGENTS.md/CLAUDE.md and assesses agent's ability to discover `docs/solutions/`; drafts minimal addition if missing
- `/ce-compound-refresh` — refreshes stale solution docs (Keep / Update / Consolidate / Replace / Delete outcomes; headless mode)
- `/ce-strategy` update mode — detects existing STRATEGY.md and runs in update mode for scope-shift rerun
- `ce-project-standards-reviewer` — auto-invoked during `/ce-code-review`; audits diffs against AGENTS.md/CLAUDE.md project standards (frontmatter rules, naming, tool-selection, protected artifacts). A deferred `audit-docs` skill would be strictly claims-vs-filesystem-reality and does NOT overlap with standards-reviewer.

## Per-Project Repo Structure

Every software project follows this layout:

```
~/repos/<project>/
├── AGENTS.md                 # Substantive instruction file (CE-preferred + Anthropic-recommended)
├── CLAUDE.md                 # Shim — `@AGENTS.md` plus optional Claude-Code-specific additions
├── README.md                 # For humans: description, quick start, features index
├── CHANGELOG.md              # Timeline, current focus, decisions
├── ISSUES.md                 # Known bugs by component
├── STRATEGY.md               # Product anchor (CE-piloted repos only; `/ce-strategy` output)
├── .claude/
│   └── rules/                # Project-specific rules
│       ├── code-quality.md
│       ├── collaboration.md
│       └── pre-commit.md
├── docs/
│   ├── architecture.md       # System architecture (optional — conditional creation)
│   ├── infrastructure.md     # Deployment/ops (optional, for deployed projects)
│   ├── <feature>_reference.md    # Permanent reference docs
│   ├── <feature>.md          # Permanent user docs
│   ├── features/             # Active development
│   │   ├── <feature>_plan.md
│   │   └── <feature>_wip.md
│   └── archive/              # Completed plans and WIPs
│       ├── <feature>_plan.md
│       └── <feature>_wip.md
└── src/                      # Source code (project-dependent)
```

`docs/vision.md` and `docs/operations.md` were previously listed here as optional. Both are **deprecated**. Vision content is covered by STRATEGY.md (CE-piloted repos) or README + CHANGELOG Roadmap; operations content is README `Quick Start` at solo/small-team scale and dedicated DevOps configs at large scale.

## Naming Conventions

- Feature names are **kebab-case**: `voice-cloning`, `srt-exports`, `qmd-hybrid-search`.
- Feature docs use suffix patterns: `_plan.md`, `_wip.md`, `_reference.md`. User docs have no suffix.
- Archive retains the original filename; only the location changes (add `> **ARCHIVED** — YYYY-MM-DD` header on move).
- CHANGELOG decision-log entries use `YYYY-MM-DD:` date prefix.
- One feature per plan/WIP. Don't combine unrelated work.

## Frontmatter (for repo docs)

Every plan, WIP, reference, and user doc starts with YAML frontmatter. The `description` field is the headline — 1-2 sentences so any reader (or agent) knows what the file is about without reading the body.

```yaml
---
description: <1-2 sentences>
type: plan | wip | reference | user-doc
status: draft | active | superseded | archived
date_created: YYYY-MM-DD
date_updated: YYYY-MM-DD
tags: []
---
```

**Optional fields:**
- `priority: critical | important | nice-to-know` — for load-bearing decisions or critical-path features
- `confidence: high | medium | low` — for claims that may need verification
- `supersedes: <path>` — when a new doc replaces an older one

## When to Create Each Type

| Type | Create when | Skip when |
|------|-------------|-----------|
| Plan | Non-trivial new work (tools, integrations, multi-step features) | Bug fixes, minor tweaks, config changes |
| WIP | Multi-session work, significant trial-and-error | Simple work completable in one session |
| Reference | Always — when a feature completes | Never skip |
| User Doc | Feature has a human user needing guidance | Internal tooling with no user interface |

## CHANGELOG Format

Each project has its own `CHANGELOG.md` with these sections:

```markdown
# Changelog

## Current Focus
> What's being worked on RIGHT NOW
- **Feature Name** — brief status

## Roadmap
> Future work, not yet started

## Recent Updates
### Month Year
- **Feature** — description (DD.MM.YYYY)

## Version History
### Feature Name (DD.MM.YYYY)
**One-line summary**
- Motivation, key components, documentation links

## Decision Log
### YYYY-MM-DD: Decision Title
- **Context**: What prompted this decision
- **Decision**: What was decided
- **Why**: Rationale
- **Alternatives rejected**: What else was considered
```

**Current Focus is the index.** SD-CE reads this first to find active work. Keep it current.

## README.md (Human-Facing)

README is the user-facing project overview. NOT loaded by Claude at startup — Claude reads it on demand.

**README must contain:**
- **Index at top** — section anchors for the major content blocks (Quick Start / Features / Configuration / Project structure / etc.) using cross-platform anchor syntax: `[text](#heading-slug)` (works in both Obsidian and GitHub).
- Project description (what it is, who it's for)
- Quick start (prerequisites, installation, basic usage)
- **Features/components index** — one paragraph per feature/tool with: what it does, basic usage command, link to full docs
- Configuration overview
- Project structure
- Pointer to CHANGELOG and ISSUES

**README updates at ship time:**
- **In CE-piloted repos:** `@software-documenter-ce ship docs` handles README updates as part of the per-surface sweep
- Add/update the feature's entry in the components index. One-liner description + usage example + link to `docs/<feature>.md`. Keep README under ~200 lines — if it grows, move detail to `docs/`.

**Relationship to the substantive instruction file:** AGENTS.md has a compact Components table for agents; README has detailed paragraphs for humans. Both should list the same components — if one gets updated, the other should too.

## ISSUES.md

Tracks known bugs organized by component. Simple format:

```markdown
# Known Issues

## Index

| Status | Component | Issue |
|---|---|---|
| 🔴 Open | [Audio quality](#audio-quality) | brief description |
| 🟡 Mode-specific | [Pipeline](#pipeline) | brief (mode/version qualifier) |
| 🟢 Resolved v0.3 | [UX](#ux) | brief description |

## Audio quality

### Issue: brief title
- **Impact:** how it affects users
- **Workaround:** any (or — if none)
- **Status:** Open / Investigating / Fixed in <version>
- **tracker:** gh#N (when work has started) or — (not yet committed to work)
- **reference:** docs/reference/<topic>.md (if promoted)

## Resolved Issues

### Issue: brief title (resolved <version>, YYYY-MM-DD)
- **Reference:** docs/reference/<topic>.md (or other resolution artifact)
- **Resolution:** commit/PR reference
```

### Cross-platform anchor syntax (works in BOTH Obsidian and GitHub)

Use `[text](#heading-slug)` for within-document links. Slug rules: lowercase, spaces → hyphens, strip most punctuation. This is GitHub's auto-anchor convention; Obsidian renders it correctly too.

**Examples** (heading → slug):
- `## Audio quality` → `#audio-quality`
- `## Pipeline reliability` → `#pipeline-reliability`
- `## Listener / UX` → `#listener--ux` (the `/` and adjacent space produce a double-hyphen; verify with GitHub preview if unsure)

**Legacy-heading caveat.** If existing files use prefixed headings like `## Component: Audio quality`, the GitHub anchor includes the prefix (→ `#component-audio-quality`). When normalizing: either rename headings to drop the prefix (cleaner anchors), or keep the legacy slug literally in Index links — pick one per file.

### Lightweight vs reference doc — when to promote

ISSUES.md entries stay **lightweight**: title + 3-5 bullets max. When an entry grows past ~5 lines of body OR accumulates external citations / multi-paragraph workarounds / version-behavior matrices, **promote the analysis to `docs/reference/<topic>.md`** and reduce the ISSUES.md entry to a one-liner pointing at it via the `reference:` field.

### GitHub issues vs ISSUES.md

- **ISSUES.md** — lightweight capture; everything starts here. Cheap to file (one-line entry + date).
- **GitHub issue** — created ONLY when starting work on the item. Filed via `gh issue create`; linked from ISSUES.md as `tracker: gh#N`. PR closes it via `Closes #N` in the commit message.

This matches CE's stance: `ce-issue-intelligence-analyst` reads GitHub issues for theme analysis when invoked, but normal CE feature work doesn't require them for routine bug capture.

### Multi-version / multi-mode status (when applicable)

Projects with multiple versions or modes use per-mode/per-version Status:

`Status: Open in v0.1 mixed; resolved v0.2.1 per-speaker; v0.3 reopened with new symptoms — see [reference doc](docs/reference/<topic>.md)`

The Index table can have separate columns per version/mode if it makes the at-a-glance signal clearer.

**ISSUES.md maintenance at ship time:** in CE-piloted repos, `@software-documenter-ce ship docs` triages at every ship — moves resolved Open entries to `## Resolved Issues` with date + reference; flags heavy entries for promotion to `docs/reference/<topic>.md`.

## Substantive Instruction File Maintenance (Per-Repo)

Each repo's substantive instruction file contains a **Components & Architecture** table summarizing what exists in the project. **Target detection:** if `AGENTS.md` exists at the repo root (the CE-pilot `@AGENTS.md` shim pattern), the Components table lives in AGENTS.md; otherwise it lives in CLAUDE.md. SD-CE keeps this in sync:

- When a new user-facing component ships, add a row.
- When a component is removed, remove the row.
- Keep it short — one line per component. Point to `docs/` for details.
- The same components listed here should appear in README (as paragraphs) and in the project's feature docs.

## Project-Level Reference Docs (Optional)

Beyond per-feature docs, projects may have project-level references. These describe the project as a whole, not a specific feature:

| Doc | Purpose | When to create |
|-----|---------|----------------|
| `docs/architecture.md` | System design, components, deployment, pipeline | Conditional — allowed at scaffolding only if load-bearing target design isn't covered by STRATEGY.md + Decision Log + per-feature plans |
| `docs/infrastructure.md` | Server config, deployment details, backup strategy | When project is deployed to a server |

**Deprecated.** `docs/vision.md` is superseded by STRATEGY.md (CE-piloted repos) and README + CHANGELOG Roadmap (non-CE repos). `docs/operations.md` is superseded by README `Quick Start` at solo/small-team scale and dedicated DevOps configs at larger scale. Don't create either in new repos; archive existing instances to `docs/archive/` once STRATEGY.md is established.

**Optional.** Small projects don't need these. Only create when complexity warrants it. Keep each focused — if `architecture.md` grows past ~200 lines, split into focused docs.

**SD-CE checks these at ship time** (`@software-documenter-ce ship docs`): does the completed feature affect architecture or infrastructure? If yes, update the relevant doc.

## Project Entry (Meta-Repo Aware)

Every software project has a thin summary for cross-project awareness. SD-CE writes this; `/recall` reads it.

- **Standalone repos** (no parent meta-repo): summary lives in your cross-project knowledge vault. Format follows the same thin-summary convention (~40 lines max).
- **Per-solution repos in a meta-repo structure**: summary lives in the parent meta-repo's `projects/<solution>-summary.md`. See `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`.

The thin-summary contents: overview paragraph, current status (2-3 sentences), recent decisions (dated one-liners — POINTERS to decisions; full rationale stays in CHANGELOG Decision Log), key links pointing back to the repo. Never exceeds ~40 lines. Full docs stay in the repo.

## Templates

Templates are in separate files within this skill directory. Read on demand when creating a new doc:

- `templates/plan.md`
- `templates/wip.md`
- `templates/reference.md`
- `templates/user-doc.md`

## Rules

1. **Archive, don't delete.** Completed plans and WIPs go to `docs/archive/` with an archive header.
2. **Plan is strongly encouraged.** Skip only for trivial changes. Plans capture the "why."
3. **WIP is optional.** Only create for multi-session work or significant trial-and-error.
4. **Reference is mandatory.** Every completed feature gets one.
5. **User Doc is situational.** Create when there's a human who needs usage guidance.
6. **CHANGELOG is the index.** Current Focus = active work.
7. **Decision Log captures WHY.** Not just what was decided, but why and what was rejected.
8. **One feature per plan/WIP.** Don't combine unrelated work.
9. **README and the substantive instruction file (AGENTS.md or CLAUDE.md) stay in sync.** Both list the same components, in different formats for different audiences. The 4-type system (Plan / WIP / User Doc / Reference) above is **per-feature** — distinct from the project-level docs (AGENTS.md, CLAUDE.md, README, CHANGELOG, ISSUES, docs/architecture.md) covered by the Per-doc Lifecycle Matrix.
10. **Frontmatter is required.** Every doc starts with the schema above.
