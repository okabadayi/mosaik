# Mosaik — Technical Deep Dive

> The detailed framework articulation. If you want the marketing overview, see [README.md](README.md). If you want to understand the dual-loop architecture, the bridge points, the meta-repo pattern, the doc-structure conventions, and how it all composes — this is your doc.

## Table of contents

- [What is Mosaik](#what-is-mosaik)
- [Who is this for](#who-is-this-for)
- [The dual-loop framework](#the-dual-loop-framework)
- [The meta-repo pattern](#the-meta-repo-pattern-for-heterogeneous-tooling-cases)
- [What's in this repo](#whats-in-this-repo)
- [Runtime requirements + dependencies](#runtime-requirements--dependencies)
- [Doc-structure conventions](#doc-structure-conventions)
- [How `/recall` integrates](#how-recall-integrates)
- [How SD-CE composes with CE](#how-sd-ce-composes-with-ce)
- [How codex-review composes](#how-codex-review-composes)
- [Honest current state](#honest-current-state)
- [How to use this](#how-to-use-this)
- [Contact / Feedback](#contact--feedback)

## What is Mosaik

A framework for AI transformation work in medium-sized businesses with heterogeneous infrastructure. Mosaik **extends** [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) — Kieran Klaassen / Every's open-source plugin with **over 17,000 GitHub stars**, in active use by many mid-sized businesses for software development. Mosaik adds a complementary knowledge fabric for multi-repo unified-business-view operations: cross-repo compounding, ship-time documentation discipline, software-repo context recall, and the meta-repo pattern for heterogeneous-tooling cases.

## Who is this for

**The operator-architect-builder at a medium-sized business doing AI transformation.** Concrete shape: multiple departments with different operational tools and workflows, heterogeneous infrastructure (no single stack), identified pain points across departments that AI could automate, one person (or small team) responsible for the work. Headcount typically falls in the 10-50 employee range, but the shape matters more than headcount — a smaller team with this operational pattern fits; a larger one without it doesn't.

Also: solo operators/founders running businesses with multiple operational domains; AI transformation consultants; engineers tracking the agent-OS landscape.

## The dual-loop framework

A development engine wrapped in a knowledge fabric.

### The engine: Compound Engineering

CE drives the per-feature cycle: strategy → brainstorm → plan → work → review → ship → compound learning. Structured artifacts with stable IDs (R/A/F/AE/U). Sub-agents that push back on weak answers. Per-repo `docs/solutions/` for engineering compounding. Mosaik uses CE as-is; CE remains the engineering engine.

**Why CE's discipline matters.** Structured artifacts mean nothing gets lost between sessions; requirements trace through to shipped code; cross-feature learning compounds in `docs/solutions/`. This is the difference between shipping one feature and maintaining a portfolio — scalable agentic engineering rather than one-off vibe coding that ships fast but can't be maintained.

See `methodology/compound-engineering/01-overview.md` for the deep CE reference.

### The fabric: Mosaik's contribution

Software-side knowledge management. Multi-repo awareness, cross-repo compounding at the right abstraction, ship-time per-surface documentation discipline, software-repo context recall via QMD-indexed markdown, doc-structure conventions, codex-review for second opinion.

### The search substrate: [QMD](https://github.com/tobi/qmd)

Mosaik's knowledge fabric depends on QMD — a markdown index daemon providing BM25 + semantic search across all knowledge collections (strategy, decisions, prior solutions, in-flight work). `/recall` uses QMD to load relevant cross-repo context at every session start. Without QMD, the substrate is just files; with it, the agent recalls relevant context across the entire portfolio instantaneously. QMD is one of the load-bearing foundations Mosaik composes with — alongside CE for the engineering engine.

### Bridge points

SD-CE (the ship-docs agent), doc-structure (the conventions skill), AGENTS.md + CLAUDE.md `@AGENTS.md` shim (the cross-agent instruction surface), `/recall` with STRATEGY-priority (the context loader). Named, narrow, intentional. This is where Mosaik's fabric and CE's engine compose without stepping on each other.

### Agent collaboration discipline

Substantive AGENTS.md content lives at [`methodology/agent-collaboration-principles.md`](methodology/agent-collaboration-principles.md) — the Three Golden Rules (universal: no autonomous implementation, strict task focus, preserve existing work) + Code Discipline (software-specific: simplicity check, verifiable success criteria). Mosaik prescribes the structural where (AGENTS.md + shim + Per-doc Lifecycle Matrix); the principles doc prescribes the substantive what. Without the discipline, the structural pattern doesn't actually keep the agent on-task.

## The meta-repo pattern (for heterogeneous-tooling cases)

For medium-sized businesses where tooling is heterogeneous and a monorepo would create dep conflicts / deployment confusion / security blast radius, Mosaik specifies a meta-repo + per-solution repos architecture:

- **Meta-repo** (`<business>-ai/`): the unified-view agent's home. Holds STRATEGY, per-solution summaries (`projects/`), cross-repo learnings at higher abstraction (`solutions/`).
- **Per-solution repos** (`<business>-<solution>/`): each runs its own CE loop fully. Independent everything.
- **Cross-repo learning flow**: manual promote (initially) → eventually a thin `<business>-promote-solution` skill when friction justifies.

See [`methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`](methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md) for the full specification and [`example-architecture/`](example-architecture/) for abstract sample structure.

## What's in this repo

- `methodology/compound-engineering/` — Compound Engineering adoption corpus (overview, migration plan, inventory, walkthrough, doc lifecycle, fresh-repo + migrate-existing repo operator scripts, meta-repo pattern). Built on direct reads of CE plugin source at v3.8.4.
- `skills/` — live skill source (3 skills: `doc-structure`, `recall` (software-repo mode), `codex-review`)
- `agents/` — live agent source (`software-documenter-ce`)
- `example-architecture/` — one abstract sample cluster (parent tier + meta-repo + 2 per-solution repos) demonstrating the meta-repo + per-solution-repos architecture and the AGENTS.md+shim tier pattern
- `roadmap.md` — what's in development, what's deferred
- `README.md` — the marketing landing page
- `TECHNICAL.md` — this file

## Runtime requirements + dependencies

### Primary runtime
**Claude Code** (Anthropic's official agentic CLI) is the primary supported environment. Mosaik was designed and validated against Claude Code. All examples in this repo assume Claude Code as the runtime.

### Compatible runtime
**OpenAI Codex CLI** is supported via [CE's official converter](https://github.com/EveryInc/compound-engineering-plugin):

```bash
bunx @every-env/compound-plugin install compound-engineering --to codex
```

The skills + agents in `skills/` and `agents/` follow Claude Code conventions; some adaptation would be needed for full Codex parity. The framework patterns themselves (dual-loop, meta-repo, doc conventions) are agent-agnostic.

Note on `codex-review`: this skill (included in `skills/`) is used FROM Claude Code to invoke Codex CLI as a second-opinion reviewer at plan-review + impl-review checkpoints. It's a review tool, not an alternate runtime — distinct from the "run Mosaik in Codex" scenario above.

### Required dependencies

| Component | Why | Required version |
|---|---|---|
| **Compound Engineering plugin** | The engineering engine Mosaik builds on | v3.8.4 or later |
| **QMD daemon** | The markdown search substrate `/recall` uses for context loading | Current release |
| **A markdown vault directory** | Where the knowledge fabric lives | Any structure works; recommended: a synced [Obsidian](https://obsidian.md) vault that both the agent (filesystem) and operator (Obsidian UI) read/write — every doc the agent ships becomes immediately visible to the human without context-switching |

### What you do NOT need

- A specific cloud or hosting provider
- A specific database
- A specific OS (Mosaik works on macOS, Linux, or wherever Claude Code runs)

### Optional but recommended

- **Obsidian as a synced vault between the agent and operator** — open the directories that contain your knowledge fabric (your repos parent, your knowledge vaults) as Obsidian vaults. The agent writes/reads markdown files via filesystem; the operator reads/edits the same files in Obsidian's UI. This is the workflow that informed Mosaik's design — every doc SD-CE ships at feature-complete time is immediately visible to the human, and operator edits land back where the agent will pick them up next session. Not strictly required (any editor works), but the synced-vault workflow is what makes the framework's knowledge fabric load-bearing in practice.
- **GitHub CLI (`gh`)** for the per-feature ship-time PR operations CE performs

## Doc-structure conventions

The Mosaik framework prescribes specific documentation conventions for software repos:

### The 4-type per-feature doc system

| Type | Naming | Purpose | Lifecycle |
|---|---|---|---|
| **Plan** | `<feature>_plan.md` (legacy SD) OR `YYYY-MM-DD-NNN-<feature>-plan.md` (CE) | Pre-implementation: requirements, decisions, steps | Archive on ship |
| **WIP** | `<feature>_wip.md` | Working memory: learnings, blockers, progress | Archive on ship |
| **User Doc** | `<feature>.md` | User-facing: how to use, configuration | Permanent |
| **Reference** | `<feature>_reference.md` | Technical: internals, debugging, architecture | Permanent |

In CE-piloted repos, the Plan type is replaced by CE's structured plan; the other three types preserve their SD locations.

### Project-level files

Core files in every repo:

- **`AGENTS.md`** (substantive instruction file — CE-preferred + Anthropic-recommended)
- **`CLAUDE.md`** (shim — `@AGENTS.md` plus optional Claude-Code-specific additions)
- **`README.md`** (for humans — description, quick start, components index)
- **`CHANGELOG.md`** (timeline — Index, Current Focus, Roadmap, Version History, Decision Log; see `skills/doc-structure/SKILL.md` § CHANGELOG Format)
- **`ISSUES.md`** (known bugs by component, Open / Resolved sections)
- **`docs/architecture.md`** (conditional — only when load-bearing target design isn't captured elsewhere)

CE-piloted repos add:

- **`STRATEGY.md`** (CE-produced product anchor — Rumelt-shaped, written by `/ce-strategy`)

See `skills/doc-structure/SKILL.md` for the full Per-doc Lifecycle Matrix, scaffolding-time discipline rule, and per-surface update triggers.

## How `/recall` integrates

The `recall` skill loads project context on demand. In Mosaik, `/recall` is the cross-context bridge — it reads CHANGELOG + active WIPs + STRATEGY + ISSUES + project entry (in meta-repo or vault).

For meta-repo + per-solution structures, the convention is: `/recall` (current repo) + `/recall <business>-ai` (parent meta-repo) when context-switching. This loads both the per-solution and unified-business context.

See `skills/recall/SKILL.md` for all 6 modes (direct load, temporal, BM25 + LLM expansion, SESSIONS, HYBRID, DEEP).

## How SD-CE composes with CE

SD-CE (the `software-documenter-ce` agent) covers documentation; CE skills cover engineering. Composition:

- During work: CE's `/ce-work` executes; SD-CE's `capture status` mode writes WIP narrative when context fills
- At ship: CE's `/ce-commit-push-pr` opens the PR; SD-CE's `ship docs` mode updates README + AGENTS.md Components + CHANGELOG + ISSUES + user doc + project entry
- Reference docs: SD-CE's `reference doc <instruction>` mode handles them as a separate user-directed step (not auto-included in `ship docs` because they benefit from operator direction)

See `agents/software-documenter-ce.md` for the full mode specification.

## How codex-review composes

The `codex-review` skill invokes OpenAI Codex CLI as a second-opinion reviewer at meaningful checkpoints:

- After `/ce-plan` → plan review (cross-model adversarial check)
- After `/ce-code-review` → implementation review (independent outside-the-plugin perspective)
- When stuck → debug help (fresh diagnostic perspective)
- Architecture decisions → second opinion on trade-offs

See `skills/codex-review/SKILL.md` for invocation patterns, signal handling, data sanitization, and prompt templates.

## Honest current state

Mosaik is in development. CE is the mature foundation (17,000+ GitHub stars, well-tested in production). Mosaik-specific contributions:
- Developed iteratively in May 2026
- Validated through real use across two operator contexts (one medium-sized business AI transformation context, one smaller unified-tooling operator pilot)
- Reviewed twice by external AI (Codex with high-effort reasoning)
- Not yet validated at broad community scale — you may be the first external adopter

We share Mosaik as inspiration. It's opinionated but not exclusive.

## How to use this

Mosaik is structurally additive — start small, let the rest emerge. The minimum viable first-feature path:

1. Install [CE + QMD](README.md#getting-started), then copy this repo's `skills/` and `agents/` to your local `~/.claude/skills/` and `~/.claude/agents/`. Set up a parent-tier `~/repos/AGENTS.md` (or wherever you keep your code) carrying the [Three Golden Rules + Code Discipline](methodology/agent-collaboration-principles.md) — these cascade to every per-repo session.
2. Scaffold a meta-repo `~/repos/<business>-ai/` with a minimal `AGENTS.md` (project description + Tech Stack only — universal rules cascade from the parent tier above), `STRATEGY.md` (one paragraph naming the business + unified AI vision), and an empty `projects/` folder.
3. Scaffold a per-solution repo per [`09-fresh-repo-scaffolding.md`](methodology/compound-engineering/09-fresh-repo-scaffolding.md). In session: `/recall <business>-ai` → `/ce-strategy` → `/ce-brainstorm` → `/ce-plan` → `/ce-work` → `/ce-commit-push-pr` → `/ce-compound` (capture per-repo learnings — establishes the `docs/solutions/` surface even with one entry; the compounding mechanism starts firing from feature 2 onward). Add a thin summary at `<business>-ai/projects/<solution>-summary.md` so the meta-repo knows the solution exists.

Honest time expectation: full first-feature cycle is hours-to-a-day for experienced operators, longer for newcomers — `/ce-strategy` alone is a ~15-20 min interactive interview. Don't try to compress this into an afternoon; the discipline IS the value.

**Defer until empirical friction surfaces the need:** cross-solution `solutions/` patterns, `business/` knowledge surfaces, SD-CE multi-surface automation, the `<business>-promote-solution` skill. Each appears when 2-3 per-solution repos accumulate or manual cross-pollination becomes 2+/week.

For deeper study before adopting: start at [`methodology/compound-engineering/00-readme.md`](methodology/compound-engineering/00-readme.md) — the doc index with recommended reading order.

## Contact / Feedback

GitHub Issues on this repo for content questions and broader framework discussion.
