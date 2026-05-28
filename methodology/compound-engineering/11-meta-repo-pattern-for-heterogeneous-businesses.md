---
description: The meta-repo + per-solution repos architectural pattern for medium-sized businesses with heterogeneous infrastructure doing AI transformation work. When tooling is heterogeneous and a monorepo creates dep conflicts, deployment confusion, or security blast radius, this pattern provides cross-business unified-view + per-solution engineering discipline + cross-repo learning at the right abstraction layer. Sibling to 09-fresh-repo-scaffolding and 10-migrate-existing-repo as a CE-extension operator doc.
type: reference
status: active
date_created: 2026-05-28
date_updated: 2026-05-28
tags: [agentic-future, compound-engineering, meta-repo, multi-repo, heterogeneous-businesses, mosaik, ai-transformation]
related: ["[[00-readme]]", "[[09-fresh-repo-scaffolding]]", "[[10-migrate-existing-repo]]", "[[08-doc-lifecycle-reference]]"]
---

# Meta-Repo Pattern for Heterogeneous Businesses

The structural answer for the medium-sized business case that doesn't fit a monorepo. Built on [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)'s (Kieran Klaassen / Every's open-source plugin with 17,000+ GitHub stars, in active use by many mid-sized businesses for software development) per-repo loop; extends it across multiple per-solution repos coordinated by one meta-repo.

For the simpler unified-tooling case (one stack, one substrate), use the monorepo pattern (per [`09-fresh-repo-scaffolding.md`](09-fresh-repo-scaffolding.md)).

---

## 1. When to use this pattern

Diagnostic — use the meta-repo + per-solution repos pattern when **ALL** of these hold:

1. **Multiple operational solutions exist or will exist for ONE business** (5+ identifiable per-stakeholder pain points; not a single-feature product).
2. **Tooling/infrastructure is heterogeneous** — different stacks per solution, different deployment targets, different dependencies, different security boundaries. The "everything could be Python" framing is true at the language layer but irrelevant at the architecture layer.
3. **Solutions share strategic context** — one business vision, one set of stakeholders, one operational model. They're not independent products.
4. **Cross-solution learning will produce value** — patterns recur (interview cadence, portal automation, AI-handoff conventions, etc.); capturing them once and reusing across solutions compounds.
5. **A monorepo would create concrete pain** — dep conflicts (e.g., Python 3.11 needed by solution A vs 3.12 by B), deployment confusion (different CI/CD per solution), security blast radius (one vulnerability touches all), mental clutter (solution C's work loads A and B's deps).

If ANY of these don't hold, reconsider:
- (1) doesn't hold → maybe just one repo (CE's standard case)
- (2) doesn't hold → use the monorepo pattern (uniform tooling fits monorepo cleanly)
- (3) doesn't hold → solutions are actually separate businesses; each gets its own meta-repo
- (4) doesn't hold → multi-repo without meta-repo might be enough (no cross-pollination need)
- (5) doesn't hold → monorepo's coordination benefits outweigh the heterogeneity concerns

---

## 2. The architecture

```
~/repos/<business>-ai/                ← META-REPO (cross-business unified surface)
  ├── AGENTS.md                       describes purpose: cross-business cataloging + hub
  ├── STRATEGY.md                     unified AI transformation vision (Rumelt-shaped, CE-produced via /ce-strategy when ready)
  ├── projects/                       per-solution thin summaries
  │   ├── solution-a-summary.md       ~40 lines: overview, status, recent decisions, links
  │   ├── solution-b-summary.md
  │   └── ...
  ├── solutions/                      cross-repo learnings at higher abstraction
  │   ├── stakeholder-discovery-patterns.md
  │   ├── portal-automation-patterns.md
  │   ├── ai-handoff-patterns.md
  │   └── ...
  └── (optional) docs/                if architecture/runbook content emerges later

~/repos/<business>-<solution-a>/      ← per-solution repo, own CE loop
  ├── AGENTS.md (substantive)
  ├── CLAUDE.md (@AGENTS.md shim)
  ├── STRATEGY.md                     solution-specific; references meta-repo's STRATEGY
  ├── README.md
  ├── CHANGELOG.md
  ├── ISSUES.md
  ├── .compound-engineering/          per-solution CE config
  ├── .claude/rules/                  per-solution rules
  ├── docs/
  │   ├── brainstorms/                CE brainstorm outputs (R/A/F/AE-IDs)
  │   ├── plans/                      CE plan outputs (U-IDs)
  │   ├── solutions/                  CE compound outputs (per-repo)
  │   └── features/                   WIP docs + scorecards
  └── src/                            actual implementation

~/repos/<business>-<solution-b>/      ← independent per-solution repo
  └── (same structure as solution-a)

~/repos/<business>-...                ← etc.
```

The meta-repo is **just another `~/repos/<name>/`**. The methodology applies to it identically. It's not a new architectural layer; it's a repo whose content happens to be cross-repo business knowledge.

---

## 3. What the meta-repo IS

The **unified-view agent's "home"**. Holds the strategic and organizational substrate that lets one agent operate across all per-solution repos with cross-context awareness.

### The four meta-repo surfaces

- **`AGENTS.md`** (substantive) — describes the meta-repo's role + business context + cross-cutting conventions. NOT a per-solution AGENTS.md; it's the business-level instruction file. Includes the Operational Dispatcher with the canonical new-issue-capture bullet.

- **`STRATEGY.md`** (CE-produced, eventually) — the unified AI transformation vision. Rumelt-shaped: Target Problem / Approach / Persona / Key Metrics / Tracks / Milestones / Not Working On. Per-solution repo STRATEGYs inherit/reference this one. Initially can be a placeholder (see § 6); becomes formal via `/ce-strategy` when the unified vision is ready to anchor.

- **`projects/<solution>-summary.md`** — thin (~40 lines) per-solution summary. Overview paragraph, current status (2-3 sentences), last 3-5 decisions (dated one-liners — POINTERS to decisions; full rationale stays in per-solution repo's CHANGELOG Decision Log), links back to per-solution repo + CHANGELOG + active WIPs. Written by SD-CE at ship-docs time when a parent meta-repo is detected (the meta-repo-aware target detection in SD-CE's "Project Entry Updates" section); falls back to agent vault for standalone repos without a meta-repo parent. This is the Mosaik convention: **software cross-solution tracking lives in the meta-repo, not the agent vault**.

- **`solutions/<pattern>.md`** — cross-repo learnings at deliberately higher abstraction than CE's per-repo `docs/solutions/`. Patterns like "stakeholder discovery cadence," "portal automation playbook structure," "AI-handoff pre-confirm conventions." Written manually for now; eventually by a thin `<business>-promote-solution` skill (deferred — see § 5).

### What the meta-repo does NOT contain

- **Executable code** — meta-repo is strategic + organizational substrate, not a runtime. Each per-solution repo has its own runtime.
- **Per-solution implementation details** — those live in per-solution repos' `src/` + `docs/`.
- **Customer-specific data** — sensitive data lives in per-solution repos with appropriate security.

---

## 4. What the per-solution repos ARE

Each per-solution repo runs its **own CE loop fully**. They're the heavier cousins of single-repo skills (`.claude/skills/<name>/SKILL.md` markdown playbooks). Skills work for uniform-tooling unified-agent operators (one repo, shared substrate). Repos are required for heterogeneous-tooling operators (multiple stacks, deployment targets, security boundaries).

### Standard per-solution repo structure

Follows `09-fresh-repo-scaffolding.md` per repo:
- Own `AGENTS.md` (substantive) + `CLAUDE.md` (`@AGENTS.md` shim)
- Own `STRATEGY.md` — solution-specific; **references the meta-repo's STRATEGY** explicitly (cross-link in frontmatter or opening paragraph)
- Own `README.md`, `CHANGELOG.md`, `ISSUES.md`
- Own `.compound-engineering/` per-solution CE config
- Own `.claude/rules/` per-solution rules
- Own `docs/brainstorms/`, `docs/plans/`, `docs/solutions/`, `docs/features/`
- Own `src/` for actual implementation

### What's per-solution vs cross-solution

- Per-solution: implementation, tests, per-feature CE artifacts (brainstorms, plans), per-feature WIP docs + scorecards, per-repo `docs/solutions/` (CE compound outputs at the repo's technical level)
- Cross-solution (meta-repo): unified strategy, per-solution summaries, cross-cutting patterns at higher abstraction

### Independence

Each per-solution repo has **independent everything**:
- Independent dependency graph
- Independent deployment pipeline
- Independent security boundary
- Independent test suite
- Independent versioning
- Independent CI/CD

This is the core reason for multi-repo over monorepo when tooling is heterogeneous.

---

## 5. Cross-repo learning workflow

### Manual promote habit (initial)

After `/ce-compound` writes a solution in a per-solution repo (e.g., `~/repos/<business>-<solution-a>/docs/solutions/<category>/<slug>.md`):

1. Operator reads the new solution
2. Asks: "is this pattern cross-business-applicable?" (likely if it's about workflow, methodology, stakeholder dynamics, AI-handoff approach, etc.; less likely if purely technical to that solution's stack)
3. If yes: copy or symlink the solution to `~/repos/<business>-ai/solutions/` with cross-reference to source repo. Often at higher abstraction (re-write the section headers to be cross-business, strip technology-specific specifics).
4. If no: leave it in the per-solution repo only.

Manual habit. Zero tooling overhead. Lightweight.

### Trigger for tooling: thin `<business>-promote-solution` skill

When you have **3+ per-solution repos** AND finds themselves doing manual cross-pollination **2+ times per week**, build the thin skill:

- **Skill name**: `<business>-promote-solution`
- **Location**: `~/.claude/skills/<business>-promote-solution/SKILL.md` (user-level) OR per-meta-repo (`.claude/skills/promote-solution/SKILL.md`)
- **What it does**: takes the path to a freshly-compounded solution in a per-solution repo; copies/symlinks it to the meta-repo's `solutions/` with proper cross-references; re-frames at higher abstraction if applicable

**This is NOT a new agent.** It's a one-step helper that automates the manual habit. Build empirically when friction justifies, not speculatively.

### Inspiration for the skill: CE's compound

When you eventually build it, read `~/.claude/plugins/cache/compound-engineering-plugin/compound-engineering/3.8.4/skills/ce-compound/SKILL.md` for:
- Frontmatter conventions (`module`, `problem_type`, `tags`)
- The Discoverability Check pattern (auto-updates AGENTS.md when `solutions/` grows)
- The five outcomes (Keep / Update / Consolidate / Replace / Delete) from `ce-compound-refresh`

Borrow the SHAPE; adapt the SCOPE (higher abstraction, cross-repo). CE's open-source code is the methodology textbook for the specialization.

---

## 6. Why CE's compound doesn't work at cross-stack scope (and why this is fine)

### The categorization assumption

CE's `/ce-compound` writes solutions to `docs/solutions/<category>/<slug>.md` with grep-first frontmatter:
- `module` (e.g., `auth`, `payments`, `database`)
- `problem_type` (e.g., `race-condition`, `n+1`, `schema-migration`)
- `tags`

These assume a **coherent technical context** — one repo, one stack, one architectural pattern. The discoverability mechanism relies on greppable categorization.

### What goes wrong at cross-stack scope

A customer-service workaround pattern and a compliance rules-engine pattern don't share `module` slugs. Their `problem_type` rarely overlaps. The frontmatter signal isn't there for cross-repo grouping.

Even if you forced everything into one mega-repo, CE's compound would produce **category mush** — patterns from radically different stacks shoved into the same `solutions/` directory with frontmatter that doesn't help discoverability.

### What works instead

**Cross-stack compounding happens at a HIGHER abstraction layer.** Not "customer-service workarounds" but "stakeholder discovery patterns." Not "compliance rules-engine patterns" but "AI-handoff pre-confirm conventions." Not "ETL specifics" but "data pipeline observability patterns."

These higher-abstraction patterns live in the **meta-repo's `solutions/`**, written manually at the right scope. You're trading "automatic-but-wrong-shape" for "manual-and-right-shape." Worth the trade.

### The honest framing

Going multi-repo loses CE's automatic compounding across repos. **But CE's compounding wouldn't have produced useful output at cross-stack scope anyway.** You're not losing what you thought you were losing. You're choosing the right substrate for the right abstraction level.

---

## 7. Setup procedure for the meta-repo

### Lightweight initial setup (when no per-solution repos exist yet)

```bash
# 1. Create the directory + git init
mkdir -p ~/repos/<business>-ai
cd ~/repos/<business>-ai
git init -b main

# 2. Minimal README placeholder
cat > README.md <<'EOF'
# <business>-ai

Meta-repo for cross-cutting <business> AI transformation work. Holds the unified strategy, per-solution summaries, and cross-repo learnings as they accumulate. Per-solution repos live as siblings (`~/repos/<business>-<solution-name>/`).

Built on the Mosaik framework — Compound Engineering as the per-feature engine plus a knowledge fabric for unified-business-view operations.

## Current state

Empty placeholder. STRATEGY.md, AGENTS.md, and per-solution summaries arrive as solutions get built.
EOF

# 3. Initial commit
git add -A
git commit -m "Initial: empty meta-repo shell"

# 4. Remote setup (when ready)
# gh repo create <business>-ai --private --source=. --remote=origin
# git push -u origin main
```

This is ~5 minutes. Gives you the structural home from day 1.

### Deliberate NOT done yet

- **`/ce-setup`** — defer until first per-solution repo is ready and unified strategy needs to be formal
- **`/ce-strategy`** — defer until ready to anchor unified vision (~15-20 min interactive interview)
- **AGENTS.md substantive** — defer until per-solution repos exist to reference

These come at the **graduation moment** (see § 8).

---

## 8. When to introduce STRATEGY.md, AGENTS.md, and /ce-setup in the meta-repo

The meta-repo graduates from "lightweight shell" to "formal CE-piloted repo" when:

- **First 1-2 per-solution repos exist** AND have shipped a feature
- **Unified strategy across them is needed** (e.g., when starting a 3rd solution that should inherit from a coherent business vision)
- **Cross-solution patterns have started to surface** (e.g., 2+ per-solution `docs/solutions/` have similar entries worth promoting)

At that point:

1. **Run `/ce-setup` in the meta-repo**:
   ```bash
   cd ~/repos/<business>-ai
   claude
   # in Claude Code:
   /ce-setup
   ```
   This produces `.compound-engineering/config.local.yaml` (gitignored) + `.compound-engineering/config.local.example.yaml` (committed).

2. **Run `/ce-strategy`** to produce the unified `STRATEGY.md`:
   ```
   /ce-strategy
   ```
   ~15-20 min interactive interview. Output: `STRATEGY.md` at meta-repo root anchoring the unified AI transformation vision (Target Problem / Approach / Persona / Key Metrics / Tracks / Milestones / Not Working On).

3. **Write substantive AGENTS.md** following the template in `skills/doc-structure/SKILL.md` and Mosaik's `TECHNICAL.md`. Include:
   - Title + 1-line description (meta-repo's role: cross-business cataloging hub)
   - Tech Stack (Documentation: markdown; Knowledge fabric: QMD; Methodology: Mosaik)
   - Project Conventions (per-solution repos live as siblings; this meta-repo is substrate not runtime; etc.)
   - Operational Dispatcher (canonical bullet + project-specific scenarios)
   - Components & Architecture (EMPTY at scaffolding — populates as solutions ship)
   - Current State (pointer to `CHANGELOG.md` Current Focus)

4. **Update per-solution repo STRATEGYs** to reference the meta-repo's STRATEGY. Add cross-link.

5. **Tag `pre-ce-phase-a`** on the meta-repo (revert anchor):
   ```bash
   git tag pre-ce-phase-a
   git push origin pre-ce-phase-a
   ```

After this graduation, the meta-repo IS a CE-piloted repo with its own (rare) `/ce-brainstorm` / `/ce-plan` cycles — but those are for cross-business work (e.g., unified-vision evolution, cross-solution architecture decisions), not for shipping per-solution features.

---

## 9. Setup procedure for per-solution repos

Follow [`09-fresh-repo-scaffolding.md`](09-fresh-repo-scaffolding.md) per repo, with **one addition**: cross-reference the meta-repo in the per-solution STRATEGY.md.

### Cross-reference convention

In the per-solution repo's `STRATEGY.md`, after the standard sections, add:

```markdown
## Relationship to <business>-ai meta-repo

This solution is part of the `<business>-ai` AI transformation portfolio. The unified strategy lives at `~/repos/<business>-ai/STRATEGY.md`. This solution's strategy inherits the target problem framing + persona understanding from there; the Approach / Tracks / Metrics here are solution-specific.

Cross-cutting patterns that emerge from this solution may be promoted to `~/repos/<business>-ai/solutions/` (see § cross-repo learning workflow in the Mosaik framework).
```

### Per-solution summary in meta-repo

After the first feature ships in the per-solution repo:

1. SD-CE's `ship docs` mode writes (or operator manually writes) a thin summary at `~/repos/<business>-ai/projects/<solution-name>-summary.md`:
   ```markdown
   ---
   type: project
   status: active
   project: <solution-name>
   repo: ~/repos/<business>-<solution-name>
   ---

   # <solution-name>

   ## Overview
   [1-2 sentences about what this solution does]

   ## Current status
   [2-3 sentences about what's shipped vs in-progress]

   ## Recent decisions
   - [Decision 1 (DD.MM.YYYY)]
   - [Decision 2 (DD.MM.YYYY)]

   ## Key links
   - [Repo](~/repos/<business>-<solution-name>)
   - [CHANGELOG](~/repos/<business>-<solution-name>/CHANGELOG.md)
   - [Active plan](~/repos/<business>-<solution-name>/docs/plans/...)
   ```

2. Updated thereafter at each significant ship.

---

## 10. Cross-repo `/recall` behavior

In a per-solution repo, `/recall` (Mode 1 Code Repo) reads the standard sources (CHANGELOG, active WIPs, STRATEGY, ISSUES, agent vault project entry).

**Mosaik's extension** (recommended for Mosaik adopters using the meta-repo pattern): also read the meta-repo's STRATEGY + relevant per-solution summary + relevant cross-solution patterns when in a per-solution repo. This can be:

- **Manual habit**: operator runs `/recall <business>-ai` after `/recall` in the per-solution repo to load meta-repo context
- **Customized recall**: a thin custom `recall` extension that knows about the meta-repo + per-solution relationship (deferred; build when manual habit becomes friction)

The cleanest current path: **train yourself to invoke both `/recall` and `/recall <business>-ai` when context-switching to a per-solution repo**. The meta-repo's content load takes seconds and provides whole-business grounding.

---

## 11. Examples (abstract)

### Example: `acme-ai` meta-repo (generic placeholder, not real)

```
~/repos/acme-ai/
├── AGENTS.md                           ← meta-repo purpose: Acme cross-business AI transformation hub
├── STRATEGY.md                         ← unified Acme AI vision: target problem (manual ops across 30 employees), approach (per-stakeholder solutions coordinated by unified-agent context), persona (Acme operator-architect), metrics, tracks
├── projects/
│   ├── customer-data-pipeline-summary.md
│   ├── internal-knowledge-base-summary.md
│   └── content-generation-pipeline-summary.md
└── solutions/
    ├── stakeholder-discovery-cadence.md      ← cross-cutting: how to do interviews well
    ├── portal-automation-recon-methodology.md ← cross-cutting: recon → playbook → supervised → autonomous
    └── ai-handoff-pre-confirm-conventions.md  ← cross-cutting: when to require operator confirmation
```

### Per-solution repos (siblings)

```
~/repos/acme-customer-data-pipeline/    ← Python + SQLite + Airflow per-solution
~/repos/acme-internal-knowledge-base/   ← TypeScript + Next.js + Pinecone per-solution
~/repos/acme-content-generation-pipeline/ ← Python + LangChain + S3 per-solution
```

Different stacks, different deployments, different security boundaries. Coordinated through `acme-ai` meta-repo's strategic + organizational substrate.

---

## 12. What this pattern does NOT do

For clarity:

- **Does NOT replace per-solution repos with meta-repo content.** Each solution still has its own repo with its own CE loop.
- **Does NOT auto-coordinate deployment across repos.** Each solution deploys independently.
- **Does NOT enforce cross-repo dependencies.** Solutions can reference patterns from the meta-repo; they don't directly depend on each other.
- **Does NOT require the meta-repo for any per-solution work.** A per-solution repo's CE loop works fully on its own; the meta-repo just provides cross-context.
- **Does NOT scale to enterprise contexts.** At 50+ solutions, you need platform engineering, not just a meta-repo pattern.

---

## 13. Cross-references

- [[00-readme]] — folder index
- [[03-migration-plan]] — Phase A / Phase B / artifacts (meta-repo pattern is Phase A application at scale)
- [[04-inventory]] — per-CE-skill cheat sheets
- [[05-walkthrough]] — per-feature operator script (applies to per-solution repos)
- [[08-doc-lifecycle-reference]] — Per-doc Lifecycle Matrix (applies to both meta-repo and per-solution repos)
- [[09-fresh-repo-scaffolding]] — per-solution repo setup procedure
- [[10-migrate-existing-repo]] — for bringing existing per-solution repos into the pattern

---

*Applies CE's per-repo discipline at scale through the meta-repo + per-solution repos pattern. The structural answer for medium-sized businesses where heterogeneous tooling makes monorepo the wrong fit.*
