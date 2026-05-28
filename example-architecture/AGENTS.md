# Example Architecture — Parent Tier

This is the substantive parent-tier instruction file for the example cluster below — analogous to your real `~/repos/AGENTS.md` (with `~/repos/CLAUDE.md` as the `@AGENTS.md` shim). Universal agent collaboration rules live here; project-specific items live in each example repo's own `AGENTS.md`.

## What's in this cluster

This example demonstrates the Mosaik framework's **meta-repo + per-solution repos** architecture for heterogeneous-tooling cases. Three sibling repos under this parent tier:

- **`business-ai/`** — the meta-repo (unified strategy, per-solution summaries, cross-solution patterns)
- **`example-solution-a/`** — a per-solution repo (Python data pipeline example)
- **`example-solution-b/`** — a per-solution repo (TypeScript RAG example)

In real adoption, this layout sits under `~/repos/` (or wherever you keep your code) with the meta-repo named `<business>-ai/` and per-solution repos named `<business>-<solution-name>/`.

## Tier convention

Substantive content lives in `AGENTS.md` at every tier. `CLAUDE.md` is a shim (`@AGENTS.md`) at every tier. This pattern gives Claude Code's cascading load + cross-harness compatibility (Codex, Cursor, etc., read `AGENTS.md` directly). The pattern is consistent:

- **This tier** (parent of the example cluster): `AGENTS.md` (substantive) + `CLAUDE.md` (shim).
- **Each per-repo tier** (`business-ai/`, `example-solution-a/`, `example-solution-b/`): `AGENTS.md` (substantive per-repo) + `CLAUDE.md` (shim).

The principles below cascade to every per-repo agent session because Claude Code loads parent `CLAUDE.md` → reads the shim → loads parent `AGENTS.md` (this file).

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

## Code Discipline (software-specific additions)

- **Simplicity check before declaring done.** Would a senior engineer say this is overcomplicated? If 200 lines could be 50, rewrite. No speculative abstractions; no error handling for scenarios that can't happen.
- **Verifiable success criteria.** Before non-trivial implementation, state what "done" looks like as observable behavior or test outcome. Tests-first when the change is testable.

---

## See also

- [`methodology/agent-collaboration-principles.md`](../methodology/agent-collaboration-principles.md) — canonical source for the principles above + how to wire them into a real repo cluster
- Per-repo `AGENTS.md` files in each subdirectory — project-specific conventions and operational dispatcher rules
