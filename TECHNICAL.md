# Mosaik — Technical Deep Dive

> The detailed framework articulation. If you want the marketing overview, see [README.md](README.md). If you want to understand the dual-loop architecture, the bridge points, the meta-repo pattern, the doc-structure conventions, and how it all composes — this is your doc.

## What is Mosaik

A framework for AI transformation work in medium-sized businesses with heterogeneous infrastructure. Mosaik **extends** [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) — Kieran Klaassen / Every's open-source plugin with **over 17,000 GitHub stars**, in active use by many mid-sized businesses for software development. Mosaik adds a complementary knowledge fabric for multi-repo unified-business-view operations: cross-repo compounding, ship-time documentation discipline, software-repo context recall, and the meta-repo pattern for heterogeneous-tooling cases.

## Who is this for

**The operator-architect-builder at a medium-sized business doing AI transformation.** Concrete shape: 10-50 employees, multiple departments with different operational tools and workflows, heterogeneous infrastructure (no single stack), identified pain points across departments that AI could automate, one person (or small team) responsible for the work.

Also: solo operators/founders running businesses with multiple operational domains; AI transformation consultants; engineers tracking the agent-OS landscape.

## The dual-loop methodology

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

## The meta-repo pattern (for heterogeneous-tooling cases)

For medium-sized businesses where tooling is heterogeneous and a monorepo would create dep conflicts / deployment confusion / security blast radius, Mosaik specifies a meta-repo + per-solution repos architecture:

- **Meta-repo** (`<business>-ai/`): the unified-view agent's home. Holds STRATEGY, per-solution summaries (`projects/`), cross-repo learnings at higher abstraction (`solutions/`).
- **Per-solution repos** (`<business>-<solution>/`): each runs its own CE loop fully. Independent everything.
- **Cross-repo learning flow**: manual promote (initially) → eventually a thin `<business>-promote-solution` skill when friction justifies.

See [`methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`](methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md) for the full specification and [`examples/`](examples/) for abstract sample structure.

## What's in this repo

- `methodology/compound-engineering/` — Compound Engineering adoption corpus (overview, migration plan, inventory, walkthrough, doc lifecycle, fresh-repo + migrate-existing repo operator scripts, meta-repo pattern). Built on direct reads of CE plugin source at v3.8.4.
- `skills/` — live skill source (3 skills: `doc-structure`, `recall` (software-repo mode), `codex-review`)
- `agents/` — live agent source (`software-documenter-ce`)
- `examples/` — abstract sample structure (meta-repo + per-solution repos with placeholder content)
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

The skills + agents in `skills/` and `agents/` follow Claude Code conventions; some adaptation would be needed for full Codex parity. The methodology patterns themselves (dual-loop, meta-repo, doc conventions) are agent-agnostic.

Note on `codex-review`: this skill (included in `skills/`) is used FROM Claude Code to invoke Codex CLI as a second-opinion reviewer at plan-review + impl-review checkpoints. It's a review tool, not an alternate runtime — distinct from the "run Mosaik in Codex" scenario above.

### Required dependencies

| Component | Why | Required version |
|---|---|---|
| **Compound Engineering plugin** | The engineering engine Mosaik builds on | v3.8.4 or later |
| **QMD daemon** | The markdown search substrate `/recall` uses for context loading | Current release |
| **A markdown vault directory** | Where the knowledge fabric lives | Any structure; Obsidian-compatible recommended |

### What you do NOT need

- A specific cloud or hosting provider
- A specific database
- **Multiple machines** — Mosaik works on a single machine. Multi-machine sync (e.g., laptop + remote server with shared knowledge fabric) is an operator-specific operational concern, not part of the framework. Adopters who care about cross-machine sync should solve it independently of Mosaik.
- A specific OS (Mosaik works on macOS, Linux, or wherever Claude Code runs)

### Optional but recommended

- **Obsidian** for human-friendly browsing of the knowledge fabric (not required; markdown vault works in any editor)
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

### The 6 project-level files

- **`AGENTS.md`** (substantive instruction file — CE-preferred + Anthropic-recommended)
- **`CLAUDE.md`** (shim — `@AGENTS.md` plus optional Claude-Code-specific additions)
- **`README.md`** (for humans — description, quick start, components index)
- **`CHANGELOG.md`** (timeline — Current Focus, Recent Updates, Version History, Decision Log)
- **`ISSUES.md`** (known bugs by component, Open / Resolved sections)
- **`STRATEGY.md`** (CE-produced product anchor — Rumelt-shaped)

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

1. **Read the methodology docs** in order: `methodology/compound-engineering/00-readme.md` (start), then `08-doc-lifecycle-reference.md` (overview), then `09-fresh-repo-scaffolding.md` (new repo) or `10-migrate-existing-repo.md` (existing repo), then `11-meta-repo-pattern-for-heterogeneous-businesses.md` (multi-repo case for medium-sized businesses), then `05-walkthrough.md` (per-feature operator script).
2. **Install Compound Engineering** (v3.8.4 minimum) from the [CE plugin repo](https://github.com/EveryInc/compound-engineering-plugin). CE is the foundation Mosaik builds on.
3. **Set up the skills + agents** by copying from this repo to your local Claude Code setup (`~/.claude/skills/` and `~/.claude/agents/`).
4. **Set up QMD** for the `/recall` skill to work. See [QMD on GitHub](https://github.com/tobi/qmd).
5. **Try it on a real solution.** Pick something small. Run through the operator scripts.
6. **Adapt to your context.** The framework is opinionated but not exclusive.

## Acknowledgements

- **Compound Engineering** by Kieran Klaassen / Every — the open-source engineering engine Mosaik builds on
- **Anthropic** for Claude Code + the AGENTS.md+shim cross-agent compatibility pattern
- The community of operator-architect-builders who've shared their AI transformation experiences

## Contact / Feedback

GitHub Issues on this repo for content questions and broader framework discussion.
