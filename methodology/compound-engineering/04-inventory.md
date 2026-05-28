---
description: Operational reference for Compound Engineering adoption. Per-tier (solo / internal / public) invocation cheat sheets with three-column logic (typically invoke / consider / typically skip). Full per-skill inventory with adoption status (Adopt / Reference / Defer / Skip) and reasoning. Agent inventory by category. Common workflow lookups. Use this doc as the "which CE skill should I use right now?" reference.
type: inventory
status: active
date_created: 2026-05-24
date_updated: 2026-05-24
tags: [agentic-future, compound-engineering, inventory, cheat-sheet, per-tier]
ce_reference_version: v3.8.4
ce_reference_commit: 08bb5899036e9ca33585b38ce840e2b2bfaacac8
related: ["[[00-readme]]", "[[03-migration-plan]]", "[[01-overview]]"]
---

# Compound Engineering — Skill Inventory + Cheat Sheets

This is the operational reference for "which CE skill should I use right now?" — read after `03-migration-plan.md` (which is the action plan) and before `01-overview.md` (which is the deep CE reference).

The pin is **v3.8.4** / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`. The plugin ships **38 skills + 51 agents** at this pin. Adoption status here applies to this operator setup specifically.

---

## 1. Adoption-status legend

| Status | Meaning |
|---|---|
| **✓ Adopt** | Active use. Invoke as the workflow calls for. Phase A of migration plan covers initial adoption. |
| **◆ Reference** | Installed (because user-level install brings everything), but consulted as a reference rather than as a regular workflow step. |
| **◌ Defer** | Skip for now; documented trigger condition that would justify revisiting. Don't invoke. |
| **✗ Skip** | Wrong fit (wrong stack, wrong context, redundant with existing capability). Don't invoke. Documented reason. |

Per-tier cheat-sheet legend:

| Symbol | Meaning |
|---|---|
| **✅** | Typically invoke at this tier |
| **◐** | Consider — case-by-case judgment |
| **✗** | Typically skip at this tier |

---

## 2. Per-tier cheat sheets

Blast-radius framing: three tiers based on who's affected by a bug.

**Solo** — code only you run, only you see consequences. Personal CLIs, filesystem scripts, one-off analysis tools, experiments. Failure mode: I notice within minutes, fix it, no harm.

**Internal** — code used by a few people inside your business. Internal tools, shared scripts, low-traffic services. Failure mode: someone else is blocked or sees weirdness; reputational + small productivity hit.

**Public** — code with real users (production-facing products, anything billed, anything at scale). Failure mode: real users harmed, possible data loss, possible legal exposure.

The cheat sheets below tell you which CE skill to typically invoke / consider / skip at each tier. Tier is a project-level property; you can override per feature when a Solo project has one critical bit (e.g., auth flow) that deserves Internal-tier treatment.

### 2.0 CE Core Set vs Extended Set

CE ships 38 skills. For Mosaik's setup, **9 of them form the CE Core Set** — the skills that carry the compounding mechanism end-to-end (upstream grounding through artifact chain through learning capture). The Core Set is invoked across all three tiers (with tier-dependent defaults on the optional ones); the Extended Set is situational.

**CE Core Set (9 skills):**

| # | Skill | Role |
|---|---|---|
| 1 | **`/ce-strategy`** | Upstream anchor — creates / maintains `STRATEGY.md` (target problem / approach / persona / metrics / tracks). Automatically read by `/ce-ideate`, `/ce-brainstorm`, `/ce-plan` as grounding. Per-product, once per repo (rerun when major direction changes). |
| 2 | **`/ce-ideate`** (optional core) | Between-projects discovery — "what should I build next?" Situational: invoke when between projects; skip when the feature is known. Not invoked per feature. |
| 3 | **`/ce-brainstorm`** | Starts artifact chain — produces R-IDs (Requirements), A-IDs (Actors), F-IDs (Key Flows), AE-IDs (Acceptance Examples). |
| 4 | **`/ce-plan`** | Continues artifact chain — produces U-IDs (Implementation Units) traced back to R/AE-IDs. |
| 5 | **`/ce-work`** | Executes the plan, idempotency-checked. |
| 6 | **`/ce-debug`** | Investigation-first debugging — runs even at Solo via fast-path for trivial bugs; full framework for non-trivial. |
| 7 | **`/ce-code-review`** | Multi-persona structured review (Tier-2 quality discipline). |
| 8 | **`/ce-commit-push-pr`** | Shipping discipline — adaptive PR descriptions scaled to change complexity, body-file safety, logical commit splitting. PR description is one of the durable artifacts. |
| 9 | **`/ce-compound`** | Closes the loop — captures `docs/solutions/` entries that feed grep-first retrieval. Without this, the chain doesn't compound. |

**Extended Set** = everything else (e.g., `/ce-simplify-code`, `/ce-worktree`, `/ce-doc-review` as a standalone invocation, `/ce-compound-refresh`, `/ce-product-pulse`, `/ce-resolve-pr-feedback`, plus all the stack-specific / beta / deferred skills). Extended skills compose with the Core when warranted but aren't load-bearing for the basic compounding loop.

**Why this distinction matters:** the Core Set is the minimum coherent adoption. Invoking only `/ce-brainstorm` + `/ce-plan` without `/ce-compound` (or `/ce-compound` without the chain that produces what it consumes) is the **mechanism cherry-pick** anti-pattern called out in the methodology comparison in the share repo README § 9 — it breaks compounding. The Core is the integrated whole; Extended skills are situational additions around it. **Adopt the Core as a set or not at all**; pick from Extended as the work warrants.

`/ce-ideate` is "optional core" — situational by nature (not invoked per feature; invoked between projects). It's part of the Core conceptually because when you ARE discovering directions, ideate is what you use; CE doesn't have a deeper alternative. Solo can skip it entirely if scope is always known.

The per-tier cheat sheets below show **when** to reach for each Core skill, but the Core stays the spine across all tiers.

### 2.1 Core loop (per tier)

| Stage | Skill | Solo | Internal | Public |
|---|---|:---:|:---:|:---:|
| Strategy anchor (upstream) | `/ce-strategy` | ◐ | ✅ | ✅ |
| Discover directions (between projects) | `/ce-ideate` | ✗ | ◐ | ◐ |
| Define what to build | `/ce-brainstorm` | ◐ | ✅ | ✅ |
| Plan execution | `/ce-plan` | ◐ | ✅ | ✅ |
| Implement | `/ce-work` | ✅ | ✅ | ✅ |
| Capture learning | `/ce-compound` | ◐ | ✅ | ✅ |
| Outer loop (telemetry) | `/ce-product-pulse` | ✗ | ✗ | ◐ |
| Maintenance | `/ce-compound-refresh` | ✗ | ◐ | ✅ |

**Notes on the considers (◐):**

- **`/ce-strategy` at Solo (◐)**: invoke if the project is more than throwaway (intended for actual use by you over time); skip for personal experiments / one-off scripts. At Internal+ (✅): invoke at project start to create `STRATEGY.md` (becomes upstream grounding for downstream Core skills). Rerun when scope shifts materially. Once `STRATEGY.md` exists, you don't reinvoke per feature — it's a per-product anchor.
- **`/ce-ideate` at Internal / Public**: invoke when between projects ("what should we work on next?"); skip when you already know what you're building. Not invoked per feature.
- **`/ce-brainstorm` at Solo**: invoke for genuinely fuzzy ideas where you can't sketch the implementation; skip when scope is obvious. CE's Lightweight tier handles small brainstorms without overhead.
- **`/ce-plan` at Solo**: invoke when work spans multiple files / sessions; skip when truly trivial (`/ce-work` bare-prompt mode handles small scope with its own triage).
- **`/ce-compound` at Solo**: invoke ONLY when you learned something reusable. Skip for one-off mechanical fixes (typos, missing imports, etc.). CE's design says skip silently when there's no generalizable insight.
- **`/ce-product-pulse` at Public**: requires real telemetry (analytics + tracing + payments). Skip until that's wired up; invoke after.
- **`/ce-compound-refresh` at Internal**: run after a refactor / rename / migration that may have invalidated older `docs/solutions/` entries. Skip routine maintenance.

### 2.2 On-demand quality + debug (per tier)

| Skill | Solo | Internal | Public |
|---|:---:|:---:|:---:|
| `/ce-debug` (root-cause + fix) | ✅ | ✅ | ✅ |
| `/ce-code-review` (multi-persona) | ✗ | ◐ | ✅ |
| `/ce-doc-review` (plan/brainstorm review) | ✗ | ◐ | ✅ |
| `/ce-simplify-code` (pre-PR refinement) | ◐ | ✅ | ✅ |
| `/ce-optimize` (metric-driven experimentation) | ✗ | ✗ | ◐ |
| `codex-review` (existing — cross-model second opinion) | ◐ | ◐ | ✅ |

**Notes:**

- **`/ce-debug`** works at every tier because its Phase 0 trivial-bug fast-path handles small stuff without the full framework. Don't reach for it for typos; do reach for it when you've tried 2+ fixes and they didn't stick.
- **`/ce-code-review` at Solo**: skip. The harness's native `/review` (which `ce-code-review` quick-short-circuits to anyway) covers small changes. Don't invoke the multi-persona pipeline for a personal CLI tool.
- **`/ce-code-review` at Internal (◐)**: invoke for sensitive surfaces (auth, data, anything multi-user); skip for routine work; let `ce-code-review`'s diff-aware persona selection decide depth.
- **`/ce-doc-review` at Internal / Public**: CE auto-invokes this headless from `/ce-plan` Phase 5.3.8 anyway. The decision is whether to *also* run it interactively for explicit walkthrough.
- **`/ce-simplify-code` at Solo (◐)**: invoke when you added meaningful new code; skip for tiny diffs. CE's design says it has low yield on tiny diffs.
- **`/ce-optimize` at Public (◐)**: invoke only when you have a measurable optimization target with a working measurement harness. It's a specialized loop for clustering quality, search relevance, latency tuning, etc.
- **`codex-review` (existing skill, not CE)**: use at plan-review time for cross-model adversarial check; use at diff-review time for sanity check.

### 2.3 Git workflow (per tier)

| Skill | Solo | Internal | Public |
|---|:---:|:---:|:---:|
| `/ce-commit` (local commit only) | ◐ | ✅ | ✅ |
| `/ce-commit-push-pr` (full ship) | ◐ | ✅ | ✅ |
| `/ce-worktree` (isolated checkouts) | ✗ | ◐ | ✅ |
| `/ce-clean-gone-branches` (cleanup) | ◐ | ✅ | ✅ |

**Notes:**

- **`/ce-commit` at Solo (◐)**: invoke when you want convention-aware messages and `git add -A` safety; skip with plain `git commit -m` for trivial throwaway work.
- **`/ce-commit-push-pr` at Solo (◐)**: invoke if you push to GitHub for backup. Skip if no remote.
- **`/ce-worktree` at Internal (◐)**: invoke when running parallel feature work or reviewing a PR while continuing main-checkout work. Skip for single-track work.
- **`/ce-worktree` at Public**: useful for multi-feature parallel ship and for safe PR-review isolation. Recommended.

### 2.4 Research, context, collaboration (per tier)

| Skill | Solo | Internal | Public |
|---|:---:|:---:|:---:|
| `/ce-sessions` (cross-harness session search) | ✗ | ✗ | ✗ |
| `/ce-slack-research` (Slack search) | ✗ | ◐ | ◐ |
| `/ce-riffrec-feedback-analysis` (Every-specific recordings) | ✗ | ✗ | ✗ |
| `/ce-proof` (Every-specific HITL editor) | ✗ | ✗ | ✗ |

**Notes:**

- **`/ce-sessions`**: skip at all tiers. The existing `/recall` skill with sessions search across `personal` + `agent` + `sessions` QMD collections is superior for our use case (cross-machine, cross-vault). CE's `ce-sessions` is single-machine, single-harness.
- **`/ce-slack-research` at Internal / Public (◐)**: useful for company-internal context retrieval. But Slack MCP setup is a separate prerequisite; defer until that's configured.
- **`/ce-riffrec-*` and `/ce-proof`**: Every-Inc-specific tools (Proof = Every's collaborative editor; Riffrec = Kieran's recording tool). Skip permanently unless those products become relevant.

### 2.5 Frontend, mobile, framework-specific (per tier)

All of these are **✗ Skip** at all current tiers because your repos may be Python-primary. Adopt when the relevant stack comes in.

| Skill | Status |
|---|---|
| `/ce-frontend-design` (greenfield web UI design) | Skip — adopt when first web-UI repo |
| `ce-dhh-rails-style` (Ruby/Rails 37signals style) | Skip — Rails not in use |
| `ce-julik-frontend-races-reviewer` (JS/Stimulus race conditions) | Skip — not in use |
| `ce-swift-ios-reviewer` (Swift/iOS) | Skip — iOS not in use |
| `/ce-test-xcode` (iOS simulator testing) | Skip — iOS not in use |
| `/ce-test-browser` (browser test on PR-affected pages) | Skip — adopt per-repo if visual frontend testing needed |

### 2.6 Workflow utilities + plugin maintenance (per tier)

These activate when needed; no per-tier decision. Most don't require explicit adoption beyond installing CE.

| Skill | Status / Note |
|---|---|
| `/ce-setup` | Run once per new repo at adoption time. Re-run when something looks broken. |
| `/ce-update` | Run periodically to check for plugin updates. CE auto-suggests this. |
| `/ce-release-notes` | Reference — "what changed in recent CE releases?" Useful at re-evaluation time. |
| `/ce-report-bug` | Use when you hit a CE bug. Files a structured GitHub issue. |
| `/ce-resolve-pr-feedback` | Adopt at Internal / Public tier when collaborators leave PR review comments. Skip at Solo (no PR feedback). |
| `/ce-demo-reel` | Adopt per-repo if visual evidence in PRs is valuable (UI changes, CLI demos). Skip otherwise. |

### 2.7 Skill-builder reference (separate axis from tier)

These are tier-independent — they help when building your own custom skills (`recall`, a vault-write skill, `todos`, etc.).

| Skill | Status |
|---|---|
| `/ce-agent-native-architecture` | **◆ Reference**. Tutor/reference with 14 sub-references on building agent-native systems. Consult before building a new custom skill. |
| `/ce-agent-native-audit` | **◆ Reference**. Scored audit against 5 core principles. Run periodically against existing your custom skills to find improvement opportunities. |

### 2.8 Beta + experimental (per tier)

All of these are **◌ Defer** at all current tiers until stable / a concrete trigger fires.

| Skill | Status / Trigger to revisit |
|---|---|
| `/lfg` (full autonomous chain) | Defer until base CE loop has 3+ features successfully shipped. Then evaluate. |
| `/ce-polish-beta` (conversational UX polish) | Defer; experimental. Adopt if it becomes stable AND first UI-heavy repo lands. |
| `/ce-dogfood-beta` (browser QA of active branch) | Defer; experimental. Same triggers as ce-polish-beta. |
| `/ce-work-beta` (Codex delegation variant of `/ce-work`) | Defer. Mosaik's default runtime is Claude Code; no Codex delegation needed. |

### 2.9 Automation / specialized (per tier)

| Skill | Solo | Internal | Public |
|---|:---:|:---:|:---:|
| `/ce-gemini-imagegen` (Gemini Nano Banana image gen) | ◐ | ◐ | ◐ |

Adopt when image generation is needed in a workflow. Skip otherwise. Independent of tier.

---

## 3. Per-tier default workflows (assembled)

Putting the cheat sheets together — what the workflow looks like at each tier.

### 3.1 Solo workflow (just me, personal/throwaway)

```text
Bug fix:
 /ce-debug <description>
 → trivial-bug fast-path handles small stuff
 → full framework for non-trivial
 (optional) /ce-commit if pushing to GitHub for backup

Small feature / refactor:
 /ce-work <bare prompt>
 → ce-work has smart triage; if it picks "small/medium", builds a task list
 (optional) /ce-simplify-code if you added meaningful new code
 (optional) /ce-commit or /ce-commit-push-pr

Medium / fuzzy feature:
 /ce-brainstorm <feature> (Lightweight tier)
 (optional) /ce-plan (if scope warrants)
 /ce-work
 /ce-commit-push-pr
 (optional) /ce-compound (only if reusable insight)

Skip at Solo: /ce-ideate, /ce-strategy, /ce-product-pulse, /ce-code-review (use harness /review),
 /ce-doc-review, /ce-worktree, /ce-optimize, /ce-resolve-pr-feedback
```

### 3.2 Internal workflow (few users in company)

```text
Feature:
 /ce-brainstorm <feature> (Standard tier usually)
 /ce-plan <requirements doc>
 → auto-invokes /ce-doc-review headless at Phase 5.3.8
 /ce-work
 → during work, when context fills:
 @software-documenter capture learnings
 (writes docs/features/<feature>_wip.md)
 → resume after compaction via plan + commits + WIP
 /ce-simplify-code (before PR)
 /ce-commit-push-pr
 (when reviewers comment) /ce-resolve-pr-feedback
 (after merge) /ce-compound (with WIP as supplementary evidence — Shape A bridge)

Bug fix:
 /ce-debug <issue>
 → full framework
 → auto-handles fix + commit + PR if branch is skill-owned

Periodic:
 /ce-compound-refresh <scope> (after refactors that may stale older solutions)

Consider at Internal: /ce-ideate (between projects), /ce-strategy (if scope drifts),
 /ce-worktree (parallel feature work), /ce-code-review (sensitive surfaces),
 codex-review (plan-review cross-model check)
```

### 3.3 Public workflow (real users, paying or scale)

```text
At project start (or major direction shift):
 /ce-strategy
 → writes STRATEGY.md upstream anchor
 → downstream skills read it as grounding

Feature:
 (optional) /ce-ideate (when between directions)
 /ce-brainstorm <feature> (Deep or Deep-product tier)
 /ce-plan
 → auto-invokes /ce-doc-review headless
 → consider also: codex-review for cross-model plan check
 /ce-work
 → may use /ce-worktree for parallel units
 → @software-documenter capture learnings as needed
 /ce-simplify-code
 /ce-code-review (full multi-persona pass — Tier 2 escalation for sensitive surfaces)
 → consider also: codex-review for cross-model sanity check
 /ce-commit-push-pr
 (when reviewers comment) /ce-resolve-pr-feedback
 /ce-compound (with WIP as supplementary evidence)

Periodic:
 /ce-product-pulse 7d (weekly recap — requires telemetry configured)
 /ce-compound-refresh <scope> (post-refactor maintenance)

Bug fix:
 /ce-debug <issue> (full framework)
 /ce-compound if generalizable
```

---

## 4. Full skill inventory by category

All 38 skills listed with adoption status, what they do, and notes. The **CE Core Set** (9 skills — `/ce-strategy`, `/ce-ideate`, `/ce-brainstorm`, `/ce-plan`, `/ce-work`, `/ce-debug`, `/ce-code-review`, `/ce-commit-push-pr`, `/ce-compound`) is defined in § 2.0 above. **Adopt the Core as a set or not at all** — invoking any Core skill in isolation breaks the compounding loop (mechanism cherry-pick anti-pattern; see the methodology comparison in the share repo README § 9). `/ce-ideate` is marked "optional core" (situational; invoke between projects, not per feature). Extended-Set skills below are situational additions around the Core.

### 4.1 Core loop (artifact-chain subset)

> **Note:** this table lists the 5 skills that CE's plugin taxonomy calls "core loop" (the artifact-chain spine: brainstorm → plan → work → compound, plus ideate as the optional discovery upstream). The **full 9-skill CE Core Set** (per § 2.0 above) also includes `/ce-strategy` (listed in § 4.2 below), `/ce-debug` (§ 4.3), `/ce-code-review` (§ 4.3), and `/ce-commit-push-pr` (§ 4.5). All 9 carry the "✓ Adopt (core)" status; the per-category split here matches CE's own organizational scheme rather than the Core/Extended distinction. When in doubt, § 2.0 is authoritative for the Core Set definition.

| Skill | What it does | Status |
|---|---|---|
| `/ce-ideate` | Discover qualified directions across six conceptual frames with adversarial filtering — between projects, when figuring out what to build next | **✓ Adopt (optional core)** — situational; invoke between projects when discovering directions; skip when feature is known. Solo can skip entirely if scope is always known up front |
| `/ce-brainstorm` | Collaborative Q&A → right-sized requirements doc with stable IDs (R/A/F/AE) | **✓ Adopt** |
| `/ce-plan` | Guardrails plan with U-IDs traced to R/AE-IDs, multi-agent research, automatic confidence-check + deepening, auto-invokes `/ce-doc-review` headless | **✓ Adopt** |
| `/ce-work` | Execute against plan's guardrails with idempotency check, worktree isolation, test-first discipline per unit, smart triage for bare prompts | **✓ Adopt** |
| `/ce-compound` | Capture solved problem to `docs/solutions/<category>/<slug>.md`, bug-track vs knowledge-track classification, overlap detection, discoverability check | **✓ Adopt** |

### 4.2 Around the loop

| Skill | What it does | Status |
|---|---|---|
| `/ce-strategy` | Create or maintain `STRATEGY.md` at repo root (Rumelt-inspired interview, target problem / approach / persona / metrics / tracks). Automatically read by `/ce-ideate`, `/ce-brainstorm`, `/ce-plan` as upstream grounding when it exists | **✓ Adopt (core)** — STRATEGY.md is the per-product upstream anchor; replaces the role of informal `docs/vision.md` for CE-piloted repos. Once per repo at project start; rerun when scope shifts |
| `/ce-product-pulse` | Time-windowed single-page report on usage / performance / errors / followups; saves to `docs/pulse-reports/` | **◌ Defer**. Requires real telemetry (analytics + tracing + payments). Trigger: first repo with production users + telemetry. |
| `/ce-compound-refresh` | Maintain `docs/solutions/` with five outcomes (Keep / Update / Consolidate / Replace / Delete) | **✓ Adopt** — invoke after refactors that may stale older entries |

### 4.3 On-demand quality + debug

| Skill | What it does | Status |
|---|---|---|
| `/ce-debug` | Investigation-first debugging: causal chain gate, predictions for uncertain links, assumption audit, smart escalation | **✓ Adopt** |
| `/ce-code-review` | Multi-persona structured code review with tiered persona dispatch (6 always-on + diff-conditional), P0-P3 severity + autofix routing, four modes | **✓ Adopt** (escalation tier from harness-native `/review` short-circuit) |
| `/ce-doc-review` | Parallel persona review of requirements/plan docs (coherence, feasibility, product-lens, design-lens, security-lens, scope-guardian, adversarial), Decision Primer for round suppression | **✓ Adopt** — usually auto-invoked from `/ce-plan` |
| `/ce-simplify-code` | Three parallel reviewers (Reuse / Quality / Efficiency), apply fixes, verify behavior preservation | **✓ Adopt** |
| `/ce-optimize` | Metric-driven iterative optimization loops with parallel experiments, LLM-as-judge, persistence discipline | **◌ Defer** — specialized; trigger: actual optimization problem with measurable target |

### 4.4 Research & context

| Skill | What it does | Status |
|---|---|---|
| `/ce-sessions` | Cross-harness session history search (Claude Code, Codex, Cursor) | **✗ Skip** — `/recall` is superior (cross-vault, cross-machine) |
| `/ce-slack-research` | Slack search for organizational context | **◌ Defer** — useful for company-internal context retrieval; requires Slack MCP setup. Revisit when MCP is in place. |
| `/ce-riffrec-feedback-analysis` | Riffrec recording analysis (Every-specific tool) | **✗ Skip** — Every-Inc-specific |

### 4.5 Git workflow

| Skill | What it does | Status |
|---|---|---|
| `/ce-commit` | Single well-crafted commit, convention-aware, sensitive-file-safe, file-level logical splitting | **✓ Adopt** |
| `/ce-commit-push-pr` | Full ship flow with adaptive PR descriptions (scales with change complexity), body-file safety, branch-state decision tree | **✓ Adopt** |
| `/ce-clean-gone-branches` | Delete local branches whose remote is gone | **✓ Adopt** — periodic cleanup |
| `/ce-worktree` | Create `.worktrees/<branch>` with `.env` copying + branch-aware dev-tool trust + `.gitignore` management | **✓ Adopt** — for parallel work / PR review isolation |

### 4.6 Frontend, mobile, framework-specific

All **✗ Skip** for current stack (Python-primary). Adopt when the relevant stack appears.

| Skill | Trigger to revisit |
|---|---|
| `/ce-frontend-design` | First web-UI repo |
| `ce-dhh-rails-style` | First Rails repo |
| `ce-julik-frontend-races-reviewer` | First JS/Stimulus-heavy repo |
| `ce-swift-ios-reviewer` | First iOS repo |
| `/ce-test-xcode` | First iOS repo |
| `/ce-test-browser` | First repo needing browser test on PR-affected pages |

### 4.7 Workflow utilities + plugin maintenance

| Skill | Status / When |
|---|---|
| `/ce-setup` | **✓ Adopt** — run at repo adoption + when something looks broken |
| `/ce-update` | **✓ Adopt** — run periodically; CE may auto-suggest |
| `/ce-release-notes` | **◆ Reference** — useful at re-evaluation time (every 3 months) |
| `/ce-report-bug` | **◆ Reference** — use when hitting a CE bug |
| `/ce-resolve-pr-feedback` | **✓ Adopt** at Internal+ when collaborators leave PR comments; skip at Solo |
| `/ce-demo-reel` | **◌ Defer** — adopt per-repo when visual evidence in PRs is valuable |

### 4.8 Collaboration

| Skill | What it does | Status |
|---|---|---|
| `/ce-proof` | Run HITL review loops over markdown via Proof (proofeditor.ai) | **✗ Skip** — Every-Inc-specific tool |

### 4.9 Skill-builder reference

| Skill | What it does | Status |
|---|---|---|
| `/ce-agent-native-architecture` | Tutor/reference for building agent-native applications. 14 sub-references covering architecture patterns, MCP tool design, system prompt design, dynamic context injection, action parity discipline, self-modification, mobile patterns, testing, refactoring, checklists. | **◆ Reference** — consult when building new custom skills |
| `/ce-agent-native-audit` | Scored audit against five core principles (Parity / Granularity / Composability / Emergent Capability / Improvement Over Time) | **◆ Reference** — periodic audit of existing your custom skills |

### 4.10 Automation / specialized

| Skill | What it does | Status |
|---|---|---|
| `/ce-gemini-imagegen` | Generate/edit images using Gemini API (Nano Banana Pro) | **◌ Defer** — adopt when image generation is needed |

### 4.11 Beta / experimental

| Skill | What it does | Status |
|---|---|---|
| `/lfg` | Full autonomous chain (plan → work → review → resolve → test → commit → push → PR → CI watch → fix) | **◌ Defer** — adopt after base CE loop has 3+ features shipped successfully |
| `/ce-polish-beta` | Conversational UX polish: dev server + browser + iterate | **◌ Defer** — beta; adopt if stable and UI-heavy repo lands |
| `/ce-dogfood-beta` | Browser QA of active branch, exhaustive test matrix | **◌ Defer** — beta; same triggers as polish-beta |
| `/ce-work-beta` | `/ce-work` variant with Codex delegation for implementation | **✗ Skip** — Mosaik's default runtime is Claude Code; no Codex delegation needed |

---

## 5. Agent inventory by category

Agents are sub-agents dispatched BY skills — you typically don't invoke these directly. Listed here so a fresh agent reading the docs knows what's available and what each does.

### 5.1 Code review agents (always-on or diff-conditional)

| Agent | Focus |
|---|---|
| `ce-correctness-reviewer` | Logic errors, edge cases, state bugs, error propagation. **Always-on.** |
| `ce-testing-reviewer` | Coverage gaps, weak assertions, brittle tests. **Always-on.** |
| `ce-maintainability-reviewer` | Coupling, complexity, naming, dead code, abstraction debt. **Always-on.** |
| `ce-project-standards-reviewer` | CLAUDE.md/AGENTS.md compliance, frontmatter, naming, portability. **Always-on.** |
| `ce-agent-native-reviewer` | Features accessible to agents (action + context parity). **Always-on.** |
| `ce-learnings-researcher` | Search `docs/solutions/` for past learnings. **Always-on.** Grep-first frontmatter filter. |
| `ce-security-reviewer` | Auth, public endpoints, user input, permissions. Conditional. |
| `ce-security-sentinel` | Comprehensive security audit (OWASP top 10). Used by `/ce-compound` for security-issue track. |
| `ce-performance-reviewer` | Runtime performance with confidence calibration. Conditional. |
| `ce-performance-oracle` | Performance analysis + optimization. Used by `/ce-compound` for performance-issue track. |
| `ce-api-contract-reviewer` | Breaking API contract changes. Conditional. |
| `ce-data-integrity-guardian` | Database migrations, data integrity. Used by `/ce-compound` for database-issue track. |
| `ce-data-migration-reviewer` | Schema drift, migration safety, mapping verification. Conditional. |
| `ce-deployment-verification-agent` | Go/No-Go deployment checklists for risky data changes. Conditional. |
| `ce-reliability-reviewer` | Production reliability and failure modes. Conditional. |
| `ce-adversarial-reviewer` | Construct failure scenarios across component boundaries. Conditional. |
| `ce-previous-comments-reviewer` | PRs with existing review threads. Conditional. |
| `ce-pattern-recognition-specialist` | Code patterns and anti-patterns. |
| `ce-code-simplicity-reviewer` | YAGNI, minimalism — final simplicity pass. |
| `ce-julik-frontend-races-reviewer` | JS/Stimulus race conditions. Stack-conditional (skip for us). |
| `ce-swift-ios-reviewer` | Swift/iOS code review. Stack-conditional (skip for us). |

### 5.2 Document review agents

| Agent | Focus |
|---|---|
| `ce-coherence-reviewer` | Internal consistency, contradictions, terminology drift. **Always-on for doc-review.** |
| `ce-feasibility-reviewer` | Whether proposed approach survives contact with reality. **Always-on for doc-review.** |
| `ce-product-lens-reviewer` | Problem framing, scope decisions, goal misalignment. Conditional. |
| `ce-design-lens-reviewer` | Missing design decisions, interaction states, AI slop risk. Conditional. |
| `ce-security-lens-reviewer` | Plan-level security gaps (auth, data, APIs). Conditional. |
| `ce-scope-guardian-reviewer` | Unjustified complexity, scope creep, premature abstractions. Conditional. |
| `ce-adversarial-document-reviewer` | Challenge premises, surface unstated assumptions, stress-test decisions. Conditional. |

### 5.3 Research agents

| Agent | Focus |
|---|---|
| `ce-best-practices-researcher` | External best practices and examples |
| `ce-framework-docs-researcher` | Framework documentation and patterns |
| `ce-repo-research-analyst` | Repository structure and conventions |
| `ce-spec-flow-analyzer` | User flows and gaps in specifications |
| `ce-git-history-analyzer` | Git history and code evolution |
| `ce-issue-intelligence-analyst` | GitHub issues — recurring themes and pain patterns |
| `ce-web-researcher` | Iterative web research for external grounding |
| `ce-slack-researcher` | Slack search for organizational context |
| `ce-session-historian` | Prior sessions across Claude Code / Codex / Cursor |

### 5.4 Design agents

| Agent | Focus | For us |
|---|---|---|
| `ce-design-iterator` | Iteratively refine UI through systematic iterations | Skip — no UI work yet |
| `ce-figma-design-sync` | Synchronize web implementations with Figma | Skip |
| `ce-design-implementation-reviewer` | Verify UI matches Figma specs | Skip |

### 5.5 Workflow + docs agents

| Agent | Focus |
|---|---|
| `ce-pr-comment-resolver` | Address PR comments and implement fixes |
| `ce-ankane-readme-writer` | Create READMEs in Ankane-style for Ruby gems (specialized — skip for us) |

---

## 6. Common workflow lookups

"I want to do X — which CE skill?" — quick reference.

| If you want to... | Invoke |
|---|---|
| Explore "what should I even build" | `/ce-ideate` |
| Define a feature you have in mind | `/ce-brainstorm` |
| Plan implementation from a requirements doc or GitHub issue | `/ce-plan` |
| Implement against a plan | `/ce-work` (default reads latest plan) |
| Implement small thing without a plan | `/ce-work <bare prompt>` (triage handles complexity) |
| Capture WIP narrative before compaction | `@software-documenter capture learnings` (not CE — yours) |
| Investigate a bug | `/ce-debug` |
| Review a plan or requirements doc | `/ce-doc-review <path>` (or let `/ce-plan` auto-invoke) |
| Review code before PR | `/ce-code-review` (Tier 2 escalation) or harness `/review` (Tier 1 quick) |
| Refine recent code for reuse / quality / efficiency | `/ce-simplify-code` |
| Commit | `/ce-commit` (local) or `/ce-commit-push-pr` (full ship) |
| Open a worktree for parallel work | `/ce-worktree <branch>` |
| Document a solved problem for future reuse | `/ce-compound` |
| Refresh existing learnings against current code | `/ce-compound-refresh <scope>` |
| Resolve incoming PR review comments | `/ce-resolve-pr-feedback` |
| Get a Codex second opinion on a plan or diff | `/codex-review` (existing skill, not CE) |
| Set up CE in a new repo | `/ce-setup` |
| Check for CE plugin updates | `/ce-update` |
| Audit an user-level skill for agent-native principles | `/ce-agent-native-audit` |
| Build a new custom skill | Consult `/ce-agent-native-architecture` for relevant reference patterns |

---

## 6.5. When to actually run `/ce-compound` — explicit triggers

CE's design says "skip when not generalizable." That's right but vague. Be explicit:

**Run `/ce-compound` if ANY of these are true:**

- You learned a reusable implementation pattern (e.g., "how we handle rate limiting in this API client" — applies again next time)
- You discovered a bug class likely to recur (not the specific bug; the *class*)
- You rejected an approach that future agents may otherwise try again (saves their cycles re-testing it)
- You found a project-specific convention that should guide future work (naming, file layout, error-handling pattern, etc.)
- The fix involved a non-obvious causal chain that future debuggers should know about

**Skip `/ce-compound` if ALL of these are true:**

- The change was obvious and mechanical
- The only "lesson" is "read the error message"
- The issue is unlikely to recur because the cause was one-off (typo, environmental glitch, dependency version pin)
- No new pattern, convention, or surprising insight emerged

**When in doubt, skip.** `docs/solutions/` is poisoned by noise more than by silence — an entry that says nothing useful makes future grep-first retrieval *worse*, not better. `/ce-compound-refresh` exists partly to delete such entries; better not to create them.

This complements the Artifact Proportionality Rule in `03-migration-plan.md` § 2.5 — the proportionality rule says don't produce artifacts that don't earn their keep; this checklist gives a concrete decision procedure for the most common artifact (the solution doc).

---

## 7. Notes on what's "considered" vs strict tier rules

The cheat sheets above are defaults. CE itself is **content-aware** — most skills inspect what they're operating on and right-size their depth automatically:

- `/ce-brainstorm` classifies scope as Lightweight / Standard / Deep / Deep-product based on the opening prompt and tier-routes accordingly
- `/ce-plan` runs its confidence check + auto-deepening at the section level, not the whole-plan level — weak sections get deepened, sharp ones are left alone
- `/ce-code-review` selects reviewer personas based on actual diff content — small config change = 6 reviewers; Rails auth + migration change = 10
- `/ce-debug` Phase 0 trivial-bug fast-path bypasses the full framework for one-liner fixes
- `/ce-work` Phase 0 smart triage routes bare prompts to direct-implementation / task-list / planning-recommended based on inferred complexity

**Per-tier defaults are about which skills you typically reach for at all** — not about configuring those skills. Once you invoke a CE skill, it self-adjusts depth.

This complements the **Artifact Proportionality Rule** in `03-migration-plan.md` § 2.5 — that principle states durable artifacts per piece of work must scale with blast radius and future reuse. The per-tier cheat sheets above are the operational expression of that principle.

The override case: a Solo project that has one critical bit deserving Internal-tier-or-higher treatment for that bit only. For that bit specifically, invoke `/ce-code-review` even though the rest of the project doesn't get it. Per-feature override.

**Concrete triggers for Solo-tier `/ce-code-review` override** — invoke `/ce-code-review` even at Solo tier when the change touches any of these:

- **Auth / authentication / authorization** logic
- **Secret handling** (credentials, API keys, tokens, OAuth flows)
- **Filesystem deletion or move** logic (especially recursive deletes or path-manipulating code)
- **Irreversible data transforms** (migration scripts, batch updates that can't easily be undone)
- **Payment / billing / financial** calculations
- **Deployment scripts** that can damage production state
- Anything that could **destroy user data, lose expensive computation, or corrupt project state**

A Solo script can still nuke a directory. Blast Radius is about *typical* methodology intensity per project — not a license to skip review on dangerous bits within that project.

---

## 8. Pin + re-evaluation

- Plugin pin: **v3.8.4** / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`
- Next re-evaluation: **2026-08-24** (3-month cadence)

At re-evaluation, check this doc against current CE for:

- Any new skills added (`gh release list --repo EveryInc/compound-engineering-plugin --limit 10`)
- Any deferred skills where the trigger has fired
- Any skip rationale that no longer applies (e.g., a new repo brings a new stack)
- Any adopted skills that have changed materially upstream

Update this doc's adoption table + the cheat sheets if any changes warrant.

See `03-migration-plan.md` § 9 for the re-evaluation protocol.

---

*Last updated: 2026-05-24. Pinned CE version: v3.8.4 / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`.*
