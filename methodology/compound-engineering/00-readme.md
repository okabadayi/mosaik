---
description: Index for the Compound Engineering adoption folder. Start with 03-migration-plan.md if adopting CE; 04-inventory.md for "which skill when"; 01-overview.md for deep CE reference. Pairs with Mosaik's TECHNICAL.md for the higher-level dual-loop framing.
type: index
date_created: 2026-05-24
date_updated: 2026-05-28
tags: [agentic-future, compound-engineering, index]
---

# Compound Engineering — folder index

Working reference for adopting Kieran Klaassen / Every's [Compound Engineering plugin](https://github.com/EveryInc/compound-engineering-plugin) (open-source, 17,000+ GitHub stars, in active use by many mid-sized businesses for software development) as the software-development methodology inside a "one Claude, one brain" operator setup.

## For a fresh agent (or operator revisiting)

If asked **"how do I start using Compound Engineering?"**
→ Read `03-migration-plan.md` first. Action plan with install steps and first-feature workflow.

If asked **"which CE skill should I use for X?"**
→ Read `04-inventory.md`. Per-skill adoption status + per-tier (solo/internal/public) cheat sheets.

If asked **"what is Compound Engineering, structurally?"**
→ Read `01-overview.md`. Deep reference. Architecture, primitives, the compounding mechanism.

If asked **"how does CE relate to Mosaik's fabric layer?"**
→ Read Mosaik's `TECHNICAL.md` § The dual-loop framework. Engine + fabric framing; bridge points.

If asked **"how does documentation work in a CE-piloted repo?"** OR **"what's the doc lifecycle in this framework?"**
→ Read `08-doc-lifecycle-reference.md`. Per-doc Lifecycle Matrix (6 project-level files), AGENTS.md primary + CLAUDE.md `@AGENTS.md` shim pattern, scaffolding-time discipline, two scenarios (fresh + migrated), CE features leveraged, source-of-truth map.

If asked **"how do I scaffold a new CE-piloted repo from scratch?"** OR **"what's the process right now for starting a new repo?"**
→ Read `09-fresh-repo-scaffolding.md`. Operator step-by-step: local + GitHub setup, the 5 guaranteed files (AGENTS.md primary + CLAUDE.md shim + README + CHANGELOG + ISSUES), language scaffolding, `.claude/rules/`, initial commit + `pre-ce-phase-a` revert anchor, `/ce-setup` + `/ce-strategy` bootstrap, first feature chain.

If asked **"how do I migrate an existing repo into CE?"** OR **"what's the process for bringing a pre-CE repo into CE adoption?"**
→ Read `10-migrate-existing-repo.md`. Agent-guided three-phase walkthrough: Phase 1 = pre-CE cleanup (5-check audit + CLAUDE.md → AGENTS.md restructure + rules split + deprecated file handling + revert tag, agent automates with ☆ confirmation gates); Phase 2 = you invoke `/ce-setup` + `/ce-strategy`; Phase 3 = hands off to `05-walkthrough.md` for the first feature. Anti-bypass guardrails baked in.

If asked **"how do I structure AI transformation work across multiple solutions for one business?"** OR **"what's the meta-repo pattern for medium-sized businesses with heterogeneous infrastructure?"**
→ Read `11-meta-repo-pattern-for-heterogeneous-businesses.md`. When tooling is heterogeneous and a monorepo creates dep conflicts / deployment confusion / security blast radius, the meta-repo + per-solution repos pattern provides cross-business unified-view + per-solution engineering discipline + cross-repo learning at the right abstraction layer. This is the Mosaik meta-repo pattern in operator-script form.

If asked **"how do I ship a feature in a CE-piloted repo?"** OR running through the per-feature walkthrough as a CE-piloted-feature agent
→ Read `05-walkthrough.md`. Per-feature operator script with ☆ prompts at each checkpoint (brainstorm → plan → work → code-review → commit-push-pr → compound → ship docs → scorecard → debrief). **Repeated for every feature** — 09 and 10 hand off here after their one-time repo-onboarding work completes.

**Layering of 05 / 09 / 10 / 11:**
- **09-fresh-repo-scaffolding** = one-time per repo, fresh-start path (mkdir through first feature)
- **10-migrate-existing-repo** = one-time per repo, pre-CE-import path (audit + restructure through first feature)
- **11-meta-repo-pattern-for-heterogeneous-businesses** = scaling pattern: when multiple per-solution repos exist for one business and tooling is heterogeneous; meta-repo coordinates them
- **05-walkthrough** = per-feature, steady-state daily-driver (used every feature, in any CE-piloted repo, after onboarding)

A pointed-at-this-folder agent should read in this typical order: `03 → 04 → 01 → 02 → 08 → 09 or 10 → 05 → 11 (if multi-solution business)`. Action-first; reference second; doc-lifecycle once methodology grounded; one-time onboarding (09 fresh / 10 migrated) at repo start; per-feature walkthrough (05) thereafter; scaling pattern (11) when business has multiple heterogeneous solutions.

## Pin

- Plugin: https://github.com/EveryInc/compound-engineering-plugin
- **Current pin: v3.16.0** — commit `3157993648fc5822e120b6beb542ada15ebdc656` (released 2026-06-30)
- Adopted at: **v3.8.4** — commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8` (released 2026-05-21), kept here as adoption history
- **v3.16.0 restructure note:** skills relocated to top-level `skills/`, and the standalone `agents/ce-*.md` were removed (agentless surface reduction) — their personas now live under `skills/<skill>/references/{agents,personas}/`.

Re-evaluate every 3 months.

## Sources of truth for these docs

These docs are built on **direct reads of CE plugin source files**, not summaries (v3.16.0 layout; pre-3.16.0 these were under `plugins/compound-engineering/`):

- `skills/<name>/SKILL.md` — runtime skill files (authoritative)
- `skills/<name>/references/*.md` — lazy-loaded skill content (incl. `references/agents/` + `references/personas/` — the former standalone sub-agents)
- `.claude-plugin/` manifests — plugin/marketplace manifests + plugin authoring rules
- Top-level `README.md`, `AGENTS.md`, `CHANGELOG.md`

User-facing docs at `docs/skills/<name>.md` were used for orientation only — they are summaries of the runtime, not the runtime itself. **When in doubt, the SKILL.md in source is the authority.**

A reproducible read can be done by:
```bash
git clone --depth 1 https://github.com/EveryInc/compound-engineering-plugin /tmp/ce-plugin
# read /tmp/ce-plugin/skills/<name>/SKILL.md   # v3.16.0 layout (pre-3.16.0: plugins/compound-engineering/skills/<name>/SKILL.md)
```

## Position relative to other methodology docs

This folder is a working reference for CE adoption inside `~/repos/<project>/` scope. It pairs with the broader methodology articulation in this repo (see `methodology/` and `README.md` / `TECHNICAL.md`). Those documents describe the OS-level system (knowledge fabric, multi-repo coordination, /recall, etc.). This folder describes the per-repo development methodology adopted within that system.

---

*Compound Engineering plugin v3.8.4; pin updated to v3.16.0.*
