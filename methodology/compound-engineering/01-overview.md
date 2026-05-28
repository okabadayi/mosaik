---
description: Compound Engineering as a system — deep reference. Architecture, primitives, the core loop, the artifact chain with stable IDs, the grep-first retrieval mechanism that makes compounding actually compound, phased workflows with mode tokens, the dual problem-type tracks, persona selection by diff content, right-sizing discipline, authoring rules. For when you want to understand how CE works, not just what to invoke.
type: reference
status: active
date_created: 2026-05-24
date_updated: 2026-05-24
tags: [agentic-future, compound-engineering, overview, architecture, deep-reference]
ce_reference_version: v3.8.4
ce_reference_commit: 08bb5899036e9ca33585b38ce840e2b2bfaacac8
related: ["[[00-readme]]", "[[03-migration-plan]]", "[[04-inventory]]"]
---

# Compound Engineering — System Reference

This is the **structural understanding** of how Compound Engineering works as a system. Read after `03-migration-plan.md` and `04-inventory.md` (which are operational) when you want to understand the design rationale and the mechanical guts.

Pin: **v3.8.4** / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`. Read from source files at `plugins/compound-engineering/skills/<name>/SKILL.md` and `plugins/compound-engineering/agents/ce-<name>.md`. Per Kieran (canonical guide): "Ideally we delete the whole thing someday because it's all built in. The point was always the philosophy, not the plugin."

---

## 1. Philosophy in one paragraph

**Each unit of engineering work should make subsequent units easier — not harder.** Traditional development accumulates technical debt: every feature adds complexity, every bug fix leaves local knowledge in someone's head, the codebase gets larger and the context gets harder to hold. Compound engineering inverts this: features teach the system new capabilities, bug fixes eliminate categories of future bugs, patterns become reusable tools. Over time the codebase becomes *easier* to work with, not harder. The mechanism that makes this work is not the philosophy — it's the **artifact chain plus the retrieval discipline** described in §§ 4-5 below.

Kieran's allocation rule: 80% in planning + review, 20% in execution. Sometimes stated as a broader 50/50: 50% feature work, 50% improving the system that builds features.

---

## 2. Architecture — skills, agents, slash commands

CE's plugin is built on three primitives, all in a single repository under `plugins/compound-engineering/`:

### 2.1 Skills

A **skill** is a directory at `plugins/compound-engineering/skills/<name>/` containing:

- `SKILL.md` — the runtime skill body. Cached at session start; loaded when the skill is invoked. YAML frontmatter at the top with `name`, `description`, optional `argument-hint`, optional `allowed-tools`, optional `disable-model-invocation`. The body is the actual orchestration logic — phased workflow, decision rules, output format.
- `references/<topic>.md` (optional) — **lazy-loaded** content. SKILL.md tells the agent "STOP. Read `references/<topic>.md`" at specific phase transitions. Keeps SKILL.md lean while putting deep mechanics where the workflow needs them.
- `scripts/<name>.{sh,py}` (optional) — executable helpers. Referenced via relative paths from the skill directory.
- `assets/` (optional) — supporting files (templates, examples).

The slash-command surface is the skill name: invoking `/ce-brainstorm` runs `plugins/compound-engineering/skills/ce-brainstorm/SKILL.md`. **There is no separate `commands/` folder** — commands were migrated to skills in v2.39.0.

Skill sizes range from 36 lines (`ce-slack-research`) to 898 lines (`ce-code-review`). Reference files often double or triple the total content (e.g., `ce-brainstorm` is 240 lines of SKILL.md + 5 references totaling ~58KB).

### 2.2 Agents

An **agent** is a single file at `plugins/compound-engineering/agents/ce-<name>.md`:

```yaml
---
name: ce-<role>-reviewer
description: When to use; what it does.
model: inherit # or specific model name; "inherit" means use parent session's model
tools: Read, Grep, Glob, Bash # capability list
---

[role prompt body — the agent's specialized instructions and output format]
```

Agents are dispatched **by skills**, not invoked directly by users. A skill might dispatch `ce-correctness-reviewer` + `ce-testing-reviewer` + `ce-security-reviewer` in parallel via the Agent/Task tool, then aggregate their structured findings.

Most CE agents are 60-300 lines. They're focused single-purpose role prompts with strict output formats. The agent body teaches the LLM the specialized lens (e.g., security review = OWASP top 10, input validation, SQL injection patterns, etc.) and constrains output shape (e.g., P0-P3 severity + structured finding fields).

CE ships 51 agents at v3.8.4. They cluster into: review (21), document review (7), research (9), design (3), workflow (2), docs (1). The bulk are reviewer personas dispatched by `/ce-code-review` and `/ce-doc-review`.

### 2.3 Slash commands

In CE post-v2.39.0, slash commands ARE skills. `/ce-brainstorm` invokes the `ce-brainstorm` skill. No separate command-level abstraction.

### 2.4 The plugin manifest

`plugins/compound-engineering/.claude-plugin/plugin.json`:

```json
{
 "name": "compound-engineering",
 "version": "3.8.4",
 "description": "AI-powered development tools for code review, research, design, and workflow automation.",
 ...
}
```

The parent repo also ships marketplace manifests at `.claude-plugin/marketplace.json` (Claude Code format), `.cursor-plugin/marketplace.json` (Cursor format), and `.codex-plugin/` for Codex format. All formats stay in parity via release automation.

### 2.5 Cross-platform

CE installs natively on Claude Code, Cursor, Copilot CLI / VS Code, Factory Droid, Qwen Code. For OpenCode, Pi, Gemini CLI, Kiro CLI — installed via `bunx @every-env/compound-plugin install compound-engineering --to <target>`, which converts the Claude Code-native format to the target's expected format.

Codex has its own native plugin install that handles skills, but still requires a Bun followup step for the custom agents (this is a current Codex limitation, expected to go away).

---

## 3. The core loop

The compound-engineering ideation chain:

```
 [/ce-ideate] (optional) "What's worth exploring?"
 │
 ▼
┌─→ /ce-brainstorm "What does this need to be?"
│ │
│ ▼
│ /ce-plan "What's needed to accomplish this?"
│ │
│ ▼
│ /ce-work "Build it."
│ │
│ ▼
└── /ce-compound "Capture what we learned."
```

`/ce-compound` is the closer that makes the loop **compound**: it writes learnings into `docs/solutions/`, which the next iteration's `/ce-brainstorm` and `/ce-plan` read as grounding. **That return arrow is the whole point.** Without it you've done traditional engineering with AI assistance.

**Around the loop:**

- `/ce-strategy` sits upstream — writes `STRATEGY.md` at repo root; downstream skills read it as grounding when present
- `/ce-product-pulse` closes the **outer** loop — time-windowed report on real user experience, follow-ups feed back into ideate/brainstorm
- `/ce-compound-refresh` maintains `docs/solutions/` over time (Keep / Update / Consolidate / Replace / Delete)

**On-demand (not part of the chain):**

- `/ce-debug` — investigation-first debugging
- `/ce-code-review` — multi-persona code review (Tier 2 escalation from harness-native `/review`)
- `/ce-doc-review` — multi-persona review of brainstorm/plan docs
- `/ce-simplify-code` — three parallel reviewers (Reuse/Quality/Efficiency)
- `/ce-optimize` — metric-driven experimentation loops

**Git workflow** (`/ce-commit`, `/ce-commit-push-pr`, `/ce-worktree`, `/ce-clean-gone-branches`), **research & context** (`/ce-sessions`, `/ce-slack-research`, etc.), **utilities** (`/ce-setup`, `/ce-update`, etc.), **frontend** (`/ce-frontend-design`), **specialized** (`/ce-gemini-imagegen`), **beta** (`/lfg`, `/ce-polish-beta`, `/ce-dogfood-beta`, `/ce-work-beta`).

---

## 4. The artifact chain with stable IDs

This is one of two things that makes CE actually compound. (The other is § 5 — grep-first retrieval.)

CE's artifact chain has **stable identifiers that flow forward through every stage**:

| Stage | Skill | Artifact | IDs introduced |
|---|---|---|---|
| Brainstorm | `/ce-brainstorm` | `docs/brainstorms/<feature>-requirements.md` | **R-IDs** (Requirements), **A-IDs** (Actors), **F-IDs** (Key Flows), **AE-IDs** (Acceptance Examples) |
| Plan | `/ce-plan` | `docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md` | **U-IDs** (Implementation Units) — each cites the R/AE-IDs it implements |
| Work | `/ce-work` | Commits, tasks, PR | U-IDs propagate into task prefixes, commit messages, PR descriptions |
| Compound | `/ce-compound` | `docs/solutions/<category>/<slug>.md` | New frontmatter — `tags`, `module`, `problem_type`, etc. |

**The stability rule:** never renumber. When a plan deepening splits unit `U3` into two concepts, the original concept keeps `U3`; the new one takes the next unused number; deletions leave gaps (gaps are fine, never backfilled).

Why this matters: `ce-work` blocks on dependencies by U-ID. If U-IDs were renumbered when a plan was edited, every blocker reference, every PR description that cites a unit, every downstream conversation would silently break. The stability rule prevents that class of bug.

Concrete example:

```markdown
# brainstorm output (docs/brainstorms/notification-mute-requirements.md)

## Requirements

- **R1.** Users can mute notifications for a defined duration
- **R2.** Mute state survives session restarts
- **R3.** Muted notifications still log; they just don't surface

## Acceptance Examples

- **AE1. Covers R1, R2.** Given a user has muted notifications for 24h,
 when they log out and log back in 6h later, then they remain muted.
- **AE2. Covers R3.** Given a user is muted, when a notification fires,
 then it appears in the notification log but not in the surface UI.
```

```markdown
# plan output (docs/plans/2026-05-24-001-feat-notification-mute-plan.md)

## Implementation Units

### U1. Add mute_until column to notification_subscriptions
**Covers:** R2

**Files affected:**
- `db/migrate/20260524_add_mute_until.rb`
- `app/models/notification_subscription.rb`

**Test scenarios:**
- Happy path: subscription with mute_until in future → muted
- Edge case: mute_until in past → not muted
- Covers AE1 — session restart preserves mute state

### U2. Add toggle endpoint
**Covers:** R1
[...]

### U3. Filter notifications on surface render
**Covers:** R3
[...]
```

```text
# commit messages
feat(notifications): U1 add mute_until column
feat(notifications): U2 add toggle endpoint
feat(notifications): U3 filter notifications on render
```

A reviewer or future-you reading the PR can trace any line of code back to a specific U-ID, which traces to an AE-ID + R-ID, which traces to a brainstorm decision. The artifact chain is the spine of the methodology.

---

## 5. The grep-first retrieval mechanism — THE compounding engine

`/ce-compound` writes learnings to `docs/solutions/<category>/<slug>.md`. **But writing the files is not the compounding mechanism.** The compounding mechanism is the **retrieval** that happens upstream: every downstream skill consults `docs/solutions/` via the `ce-learnings-researcher` agent before doing its work.

Without retrieval, `docs/solutions/` is dead files. With retrieval, captured learnings flow back into planning, ideation, debugging, code review — every cycle starts smarter.

### 5.1 How retrieval actually works

The `ce-learnings-researcher` agent (≈250 lines) implements a **grep-first frontmatter filter** strategy:

```text
Step 1: Extract keywords from the work context (module names, technical terms,
 concepts, decisions, approaches, domains)

Step 2: Probe discovered subdirectories of docs/solutions/ (don't assume a fixed
 list — directory names are per-repo conventions)

Step 3: Run multiple PARALLEL content-searches on frontmatter fields BEFORE
 reading any file body:
 title:.*(keyword1|keyword2)
 tags:.*(synonym1|synonym2)
 module:.*<module>
 problem_type:.*(architecture_pattern|design_pattern|...)
 Case-insensitive. Filter by file path returns only.

Step 4: Read frontmatter ONLY (first 30 lines) of candidate files

Step 5: Score against keywords (strong / moderate / weak match)

Step 6: Full read only of strong + moderate matches (cap at 5)

Step 7: Return distilled findings — actionable takeaways, not summaries
```

This pattern is critical because `docs/solutions/` can grow to hundreds of files in a mature codebase. Reading them all is intractable; grep-first filters down to a handful before any deep reading.

### 5.2 The dual problem-type tracks

Every `docs/solutions/` entry has a `problem_type` in its frontmatter that classifies it as **bug-track** or **knowledge-track**:

**Bug-track** (incident-level fixes — "X broke, here's why and how we fixed it"):
- `build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error`

**Knowledge-track** (durable guidance — "this is how we do X here, and why"):
- `architecture_pattern`, `design_pattern`, `tooling_decision`, `convention`, `workflow_issue`, `developer_experience`, `documentation_gap`, `best_practice` (fallback)

The track determines section structure in the solution doc:

| Bug-track sections | Knowledge-track sections |
|---|---|
| Problem | Context |
| Symptoms | Guidance |
| What Didn't Work | Why This Matters |
| Solution | When to Apply |
| Why This Works | Examples |
| Prevention | |

This matters because forcing bug-track structure onto a knowledge-track learning (or vice versa) produces docs that are structurally wrong for their content. The classification happens automatically in `ce-compound` via the Context Analyzer subagent, which reads `references/yaml-schema.md` for the classification rules.

### 5.3 Which skills consult docs/solutions/

- `/ce-plan` Phase 1 — dispatches `ce-learnings-researcher` for institutional memory during planning
- `/ce-ideate` — reads `docs/solutions/` as part of the grounding step (alongside codebase scan and external prior art)
- `/ce-debug` Phase 1.3 — "Check the project's observability tools for additional evidence" and learnings as part of investigation
- `/ce-code-review` — `ce-learnings-researcher` is one of the 6 always-on agents

### 5.4 Discoverability check

`/ce-compound`'s Phase 2.5 includes a "discoverability check" — verifies that the project's `AGENTS.md` or `CLAUDE.md` would lead a future agent to find `docs/solutions/`. If not, it proposes the smallest addition that surfaces the knowledge store, asks consent, applies the edit. This runs every time because **the knowledge store only compounds value when agents can find it.**

A typical addition is a single line in an existing directory listing:

```text
docs/solutions/ # documented solutions to past problems, organized by category with YAML frontmatter
```

---

## 6. Phased workflows with explicit gates

Every substantial CE skill is organized as a **sequence of phases** with explicit transition rules.

Example from `/ce-brainstorm`:

```text
Phase 0 — Resume, Assess, Route
 0.1 Resume existing work if applicable
 0.1b Classify task domain (software vs universal)
 0.2 Assess whether brainstorming is needed
 0.3 Assess scope (Lightweight / Standard / Deep / Deep-product)

Phase 1 — Understand the Idea
 1.1 Existing Context Scan (read CLAUDE.md, STRATEGY.md, similar features)
 1.2 Product Pressure Test — scan for gap lenses (Evidence, Specificity,
 Counterfactual, Attachment, Durability)
 1.3 Collaborative Dialogue (one question at a time discipline)

Phase 2 — Explore Approaches
 2-3 approaches with non-obvious angle, mechanism granularity not architecture

Phase 2.5 — Synthesis Summary
 STOP. Read references/synthesis-summary.md.
 Path A (announce-mode, no confirmation) vs Path B (full synthesis + confirmation)

Phase 3 — Capture Requirements
 Write docs/brainstorms/<feature>-requirements.md
 Read references/requirements-capture.md for template + completeness checks

Phase 4 — Handoff
 Read references/handoff.md for menu logic
```

A few patterns visible here:

1. **Explicit phase numbering** (0.1, 0.1b, 0.2, etc.) — readable and referenceable. References between skills cite specific phases (e.g., "ce-plan Phase 5.3.8 invokes ce-doc-review headless").
2. **"STOP. Read references/X" gates** — force on-demand loading of deep mechanics. Without the gate, the agent might improvise from memory.
3. **Conditional routing within phases** (Path A vs Path B based on tier + answers). Decision logic is in the skill body, not hardcoded.
4. **Tier-calibrated section inclusion** — Lightweight scope skips Phase 1.1 deep scan; Deep-product scope adds extra Phase 1.2 lenses. Right-sizing built in.

---

## 7. Mode tokens for skill chaining

Many CE skills accept argument tokens that change their behavior:

| Token | Effect | Used by |
|---|---|---|
| `mode:autofix` | Apply safe_auto fixes without prompting; return Residual Actionable Work summary | `ce-code-review`, `ce-doc-review`, `ce-compound-refresh` |
| `mode:report-only` | Strictly read-only; safe for concurrent use on shared checkout | `ce-code-review` |
| `mode:headless` | No interactive prompts; structured text output for programmatic callers | `ce-code-review`, `ce-doc-review`, `ce-compound` |
| `mode:pipeline` | Pipeline-orchestrated invocation (used by `/lfg`) | `ce-test-browser` |
| `base:<sha-or-ref>` | Skip scope detection; use this as diff base directly | `ce-code-review` |
| `plan:<path>` | Load this plan for requirements verification | `ce-code-review` |

This is how skills chain programmatically. `/lfg` orchestrates the full chain by calling:

```text
/ce-plan <prompt> (writes plan)
/ce-work (executes)
/ce-code-review mode:autofix plan:<path> (review + apply safe fixes, return residuals)
<parse residual handoff>
/ce-test-browser mode:pipeline
/ce-commit-push-pr
```

For manual use, you typically don't pass mode tokens — defaults are interactive.

---

## 8. Persona selection by diff content

`/ce-code-review` has 14+ reviewer personas. Not all of them run on every review.

**6 always-on reviewers** (every code review):
- `ce-correctness-reviewer` — logic, edge cases, state bugs
- `ce-testing-reviewer` — coverage gaps, weak assertions
- `ce-maintainability-reviewer` — coupling, complexity, dead code
- `ce-project-standards-reviewer` — CLAUDE.md/AGENTS.md compliance
- `ce-agent-native-reviewer` — features accessible to agents
- `ce-learnings-researcher` — searches `docs/solutions/` for related prior issues

**Cross-cutting conditional** (added when diff touches their concern):
- `ce-security-reviewer` — auth, public endpoints, user input, permissions
- `ce-performance-reviewer` — DB queries, data transforms, caching
- `ce-api-contract-reviewer` — routes, serializers, type signatures
- `ce-data-migration-reviewer` — migrations, schema changes
- `ce-reliability-reviewer` — error handling, retries, background jobs
- `ce-adversarial-reviewer` — diff >50 changed lines or touches sensitive surface
- `ce-previous-comments-reviewer` — PR has existing comments

**Stack-specific conditional** (selected per diff):
- `ce-julik-frontend-races-reviewer` — Stimulus/Turbo controllers
- `ce-swift-ios-reviewer` — Swift, SwiftUI, UIKit

**Migration-specific:** `ce-deployment-verification-agent` for risky data migrations.

A small config change triggers 6 reviewers. A Rails auth feature with migrations triggers 10. **Persona selection is agent judgment over the actual diff, not keyword matching.** Instruction-prose files (Markdown skills, JSON schemas) are product code but skip runtime-focused reviewers (adversarial, races) — those wouldn't apply.

`/ce-doc-review` has its own persona set (coherence + feasibility always-on; product-lens / design-lens / security-lens / scope-guardian / adversarial conditional), with the same diff-aware-then-content-aware selection logic.

---

## 9. The Decision Primer pattern

`/ce-doc-review` supports multi-round refinement on the same doc (apply some findings, leave the rest, run again). Without state between rounds, every round re-surfaces the same findings, including ones the user already rejected.

The **Decision Primer** carries forward what was applied vs rejected:

- **Applied findings** flow back so round-N+1 personas can verify the fix actually landed
- **Rejected findings** are suppressed via fingerprint + evidence-snippet overlap matching, so the same issue doesn't re-surface
- The evidence-snippet is the first ~120 chars of each finding's evidence, used as a more precise suppression key than title-only

This is a small mechanical detail but it's what makes iterative review actually iterate. The same pattern applies in `/ce-code-review`'s bounded re-review rounds and in `/ce-compound-refresh`'s round-to-round logic.

---

## 10. Right-sizing built into the skills

CE doesn't expect users to tell it "this is a small change, be lean" or "this is a big change, go deep." The skills detect context and adjust depth.

Mechanisms:

- **Scope tier classification** (`/ce-brainstorm` Phase 0.3): Lightweight / Standard / Deep / Deep-product. Determines which sections of the requirements doc are required, which gap lenses fire, etc.
- **Trivial-bug fast-path** (`/ce-debug` Phase 0): typo, missing import, obvious one-liner bypasses the full causal-chain-gate framework.
- **Bare-prompt triage** (`/ce-work` Phase 0): "trivial" goes straight to implementation; "small/medium" builds a task list; "large/sensitive" recommends `/ce-brainstorm` or `/ce-plan` first.
- **Quick-review short-circuit** (`/ce-code-review`): when the user asks for "quick" or "light" review, defers to the harness-native `/review` instead of dispatching the multi-agent pipeline.
- **Adaptive PR descriptions** (`/ce-commit-push-pr`): trivial fix → tight one-liner; large refactor → full structure with summary, motivation, decisions, test plan, evidence, operational notes.
- **Diff-aware persona selection** (`/ce-code-review`): small diff = fewer reviewers.
- **Persona-scope-by-doc-type** (`/ce-doc-review`): on a plan with `Origin:` set (premise already pressure-tested at brainstorm), the product/adversarial/scope-guardian personas suppress their premise-level techniques and run only implementation-level checks.
- **Lightweight mode** in many skills (`/ce-compound`, `/ce-doc-review`, etc.) — single-pass, no parallel subagents, faster + fewer tokens for simple cases.

**Implication:** you don't configure CE per-project tier (solo/internal/public). The skills self-adjust. Per-tier defaults in `04-inventory.md` are about *which skills you typically reach for*, not how those skills are configured once invoked.

---

## 11. The plugin's own discipline — eating their own dog food

CE uses CE to maintain CE. Two visible practices:

### 11.1 `docs/solutions/` in the plugin's own repo

The CE plugin repo has `docs/solutions/` populated with learnings about plugin development — patterns the team has captured while building the plugin:

- `pass-paths-not-content-to-subagents-2026-03-26.md` (architecture pattern)
- `git-workflow-skills-need-explicit-state-machines-2026-03-27.md`
- `confidence-anchored-scoring-2026-04-21.md` (skill design pattern)
- `discoverability-check-for-documented-solutions-2026-03-30.md`
- `safe-auto-rubric-calibration-2026-04-25.md`
- `script-first-skill-architecture.md`

These aren't documentation; they're institutional memory captured via `/ce-compound` during plugin development. The plugin team is using its own compounding mechanism on the plugin itself.

### 11.2 The AGENTS.md authoring rules

`plugins/compound-engineering/AGENTS.md` is **authoring** context (not runtime). It captures:

- Skill design principles ("calibrate prescription level to failure mode" — hard rules / strong guidance / trust)
- Cross-platform conventions (ASCII identifiers, `ce-` prefix required, markdown tables not box-drawing)
- File-reference rules within skills (no cross-skill imports; duplicate small reference files between skills rather than depend on shared)
- Platform-specific variable handling (`${CLAUDE_PLUGIN_ROOT}` etc. with fallback)
- Pre-commit checklists for skill changes
- Naming conventions
- Beta skill discipline (`-beta` suffix, `disable-model-invocation: true`)

These rules don't ship with installed plugins. They constrain how the plugin team builds and modifies skills, ensuring quality is baked in at authoring time rather than discovered at runtime.

The "Skill Design Principles" section is worth reading directly if you're building skills:

- **Hard rules** for deterministic safety
- **Strong guidance with examples** for judgment calls with a clear bias
- **Trust** for cases where prescription would harm (codebase exploration tactics, prose phrasing)

The principle: match prescription level to the failure mode. Over-prescribing produces rote output; under-prescribing produces inconsistency.

---

## 12. What CE explicitly does NOT do

Worth being precise about the boundaries:

- **No life-domain support.** CE assumes you're inside a code repo. No equivalent to broader OS-level life-domain folders.
- **No cross-machine sync.** CE is single-machine. Files in `docs/<feature>` are local; the team relies on git for cross-machine state.
- **No agent vault.** Cross-repo knowledge sits in `docs/solutions/` per-repo. No cross-repo aggregate knowledge store.
- **No life-domain capture agent equivalent.** CE doesn't capture meeting notes, people profiles, decisions, or any non-code learning.
- **No todo system.** No `0 Todo/` equivalent. CE's "todos" surface as `## Open Questions` sections inside brainstorms/plans and as `## Residual Review Findings` sections in PR descriptions.
- **No /recall equivalent for cross-vault topic search.** `/ce-sessions` searches session history across harnesses; that's it.
- **No multi-life-domain CLAUDE.md propagation.** CE's CLAUDE.md is a single per-repo file. broader OS-level systems may have multiple life-domain CLAUDE.mds + a neutral root.

These aren't limitations Kieran needs to address — they're the boundaries of his scope. CE is a **per-repo software-development methodology**. The broader OS-level system (the kind Mosaik wraps CE in) is **a knowledge fabric for cross-repo unified-business-view operations**. Different scopes, complementary.

The Mosaik fabric side also has things CE doesn't and doesn't need:

- The vault-of-repos Obsidian pattern (CE doesn't think about Obsidian visibility)
- The agent vault `learnings/` for cross-domain wisdom (CE compounds per-repo)
- The auto-mode permissions classifier integration (CE assumes Claude Code defaults)
- Multi-machine sync hooks (single-machine assumption)

---

## 13. Plugin version pin + evolution

**Pin:** v3.8.4 / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8` (released 2026-05-21).

**Recent evolution (v3.4 → v3.8 window):**

- v3.4.0 added `/ce-strategy` and `/ce-product-pulse` (PM-tier skills)
- v3.4.0 added `/ce-simplify-code`
- v3.5.0 added `/ce-riffrec-feedback-analysis`
- v3.6.0 added various refinements; `/ce-work-beta` adaptive effort for Codex delegation
- v3.7.0 `/lfg` got model invocation + CI autofix loop after PR; `/ce-ideate` got topic-surface decomposition
- v3.7.x `/ce-debug` tightened triage + hypothesis discipline
- v3.8.0 `/ce-compound` got `mode:headless`
- v3.8.x continued refinements across the board

The plugin is **actively evolving** — 153 releases since v1.0, last release 3 days before our adoption read. Adoption requires re-evaluation discipline (every 3 months per `03-migration-plan.md` § 9).

**Contribution model:** Kieran explicitly does not accept external PRs. He reviews submissions via AI agents and independently decides whether to address them. This is a deliberate choice (his time, his name, his risk). Implication for us: if we hit a bug, file via `/ce-report-bug` (which uses `gh issue create`). Don't expect upstream merges of our fixes.

---

## 14. Related upstream resources

- Plugin: https://github.com/EveryInc/compound-engineering-plugin
- Canonical guide: https://every.to/guides/compound-engineering
- Kieran's "Camp" walkthrough: https://every.to/source-code/compound-engineering-camp-every-step-from-scratch
- VelvetShark independent walkthrough (YouTube, 2026-01-23)
- The "Camp" article notes that Kieran uses different models for different steps: Haiku for brainstorming, Opus for planning, Codex for implementation, sometimes Gemini for code review. (Our adoption keeps Claude for all stages; see `03-migration-plan.md` § 7.)

---

## 15. Where to look next

- **`03-migration-plan.md`** — action plan: install + first-feature workflow + Phase B integrations
- **`04-inventory.md`** — per-skill adoption status + per-tier (solo/internal/public) invocation cheat sheets
- **`00-readme.md`** — folder index

---

*Last updated: 2026-05-24. Pinned CE version: v3.8.4 / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`.*
