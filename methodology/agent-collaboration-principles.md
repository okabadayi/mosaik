---
description: The substantive collaboration discipline that turns a structural AGENTS.md into a load-bearing instruction file. The Three Golden Rules (universal) + Code Discipline (software-specific). Mosaik prescribes that every per-solution repo's AGENTS.md include a `## Collaboration Discipline` section grounded in these principles — either inline (full text) or by reference (link to this doc).
type: reference
status: active
date_created: 2026-05-29
date_updated: 2026-05-29
tags: [mosaik, agents-md, collaboration, agent-discipline]
related: ["[[compound-engineering/08-doc-lifecycle-reference]]"]
---

# Agent Collaboration Principles

The substantive discipline that turns a structural AGENTS.md into a load-bearing instruction file. Mosaik's [Per-doc Lifecycle Matrix](../skills/doc-structure/SKILL.md) prescribes WHERE collaboration rules go (substantive AGENTS.md); this doc prescribes WHAT those rules are.

The principles below are universal — they apply whether the project is CE-piloted or not, whether the work is feature delivery or bug fix or doc revision. Per-repo AGENTS.md can add project-specific items, but the core stays consistent.

---

## The Three Golden Rules

1. **NO AUTONOMOUS IMPLEMENTATION** — Discuss + propose first; never implement without explicit confirmation.
   State assumptions explicitly. If multiple interpretations exist, present them — don't pick silently. If something is unclear, stop and name what's confusing.
   When the user is mid-conversation, propose-and-wait still wins. When in doubt, propose.
2. **STRICT TASK FOCUS** — Implement ONLY what is explicitly requested. No scope creep, no unrequested "improvements."
3. **PRESERVE EXISTING WORK** — Never modify unrelated code, comments, or documentation unless specifically required. **Every change should trace directly to the user's request.** Match existing style, even if you'd do it differently.

### Quick Reference

- **DON'T**: Start coding immediately, refactor unrelated code, remove comments, add unrequested features, pick silently between interpretations, hide confusion
- **DO**: Ask questions first, propose solutions, await confirmation, focus only on the task, state assumptions explicitly, stop and name what's unclear

---

## Code Discipline (software-specific additions)

In addition to the Three Golden Rules above, software repos should encode:

- **Simplicity check before declaring done.** Would a senior engineer say this is overcomplicated? If 200 lines could be 50, rewrite. No speculative abstractions; no error handling for scenarios that can't happen.
- **Verifiable success criteria.** Before non-trivial implementation, state what "done" looks like as observable behavior or test outcome. Tests-first when the change is testable.

These apply regardless of stack or CE adoption status. They're not in the universal Three Golden Rules section because the phrasing is software-specific (a senior engineer reading 200 lines, observable test outcomes); the spirit applies more broadly but the concrete tests fit code work specifically.

---

## How to wire these into a repo cluster (the recommended pattern)

Mosaik prescribes a **two-tier AGENTS.md+shim pattern** that puts the universal rules ONCE at a parent tier and lets each per-repo `AGENTS.md` add only project-specific items.

### The tier layout

```
~/repos/                          ← parent tier (or wherever your repo cluster sits)
├── AGENTS.md                     ← substantive — Three Golden Rules + Code Discipline + cluster-wide conventions
├── CLAUDE.md                     ← shim — `@AGENTS.md` (one line)
├── <business>-ai/                ← meta-repo tier
│   ├── AGENTS.md                 ← substantive — meta-repo-specific (Tech Stack, Conventions w/ meta-repo additions, Dispatcher)
│   ├── CLAUDE.md                 ← shim — `@AGENTS.md`
│   └── ...
├── <business>-solution-a/        ← per-solution tier
│   ├── AGENTS.md                 ← substantive — solution-specific
│   ├── CLAUDE.md                 ← shim — `@AGENTS.md`
│   └── ...
└── <business>-solution-b/
    ├── AGENTS.md
    ├── CLAUDE.md
    └── ...
```

**Why AGENTS.md+shim at every tier:**
- Claude Code's `CLAUDE.md` cascading load picks up the parent tier shim → which resolves the parent `AGENTS.md` content → which cascades to every per-repo session.
- Cross-harness tools (OpenAI Codex CLI, Cursor, etc.) read `AGENTS.md` directly at any tier — so the same parent rules are visible to those agents without translation.
- Consistency: one pattern at all tiers makes the methodology easier to teach and apply.

### What goes where

**Parent tier `AGENTS.md`** (universal scope):
- The Three Golden Rules (above)
- Quick Reference (DO/DON'T)
- Code Discipline (Simplicity check + Verifiable success criteria)
- Any cluster-wide conventions that apply to every repo (e.g., "all repos in this cluster use AGENTS.md+shim", "all repos follow the 4-type doc system")

**Per-repo `AGENTS.md`** (project-specific scope):
- Project description
- Tech Stack
- Project Conventions (project-specific additions only — universal rules cascade from the parent)
- Operational Dispatcher (project-specific scenarios)
- Components & Architecture (populates via SD-CE `ship docs` as features ship)
- Current State pointer

The per-repo `AGENTS.md` does NOT repeat the Three Golden Rules — they come from the parent tier automatically.

### Working example

See [`example-architecture/`](../example-architecture/) in this repo — `example-architecture/AGENTS.md` holds the universal rules; `example-architecture/<repo>/AGENTS.md` holds project-specific content only. The cascade works the same way it would in your real `~/repos/` setup.

---

## Why these matter

Structural conventions (Tech Stack, Components table, Operational Dispatcher) tell the agent WHERE things go. Collaboration discipline tells it HOW to work.

Without the discipline, the agent's default mode is "ship something fast" — which is exactly the failure mode CE's per-feature discipline and Mosaik's cross-solution coordination exist to prevent. An agent shipping fast without these rules will: pick silently between interpretations rather than asking; introduce abstractions for hypothetical futures; touch unrelated code to "improve" it; declare "done" before the success criteria are visible; ship something the user didn't ask for.

The Three Golden Rules are the **propose-and-wait** discipline. They turn the agent from an autonomous executor into a collaborator that operates inside the operator's intent. CE's artifact chain (R-IDs → A-IDs → AE-IDs → U-IDs) is a downstream enforcement mechanism for the same idea: every implementation unit traces back to an explicit requirement the operator approved.

Mosaik prescribes both the substrate (AGENTS.md + the shim pattern + the Per-doc Lifecycle Matrix) and the content (these principles) because the substrate without the content gets you a structurally correct AGENTS.md that doesn't actually keep the agent on-task.

---

## See also

- [`skills/doc-structure/SKILL.md`](../skills/doc-structure/SKILL.md) — Per-doc Lifecycle Matrix (the structural conventions these principles fill in)
- [`compound-engineering/08-doc-lifecycle-reference.md`](compound-engineering/08-doc-lifecycle-reference.md) — Reader-shaped doc-lifecycle reference for CE-piloted repos
- [Mosaik TECHNICAL.md](../TECHNICAL.md) — overall framework articulation
