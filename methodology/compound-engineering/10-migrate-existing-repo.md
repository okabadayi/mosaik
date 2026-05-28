---
description: Operator walkthrough for migrating a pre-CE repo into CE adoption. Agent-guided three-phase flow — Phase 1 agent automates pre-CE cleanup with ☆ confirmation gates (audit + CLAUDE.md → AGENTS.md restructure + rules split + deprecated file handling + revert tag); Phase 2 you invoke /ce-setup + /ce-strategy with agent waiting + verifying; Phase 3 hands off to 05-walkthrough.md for the first feature. Anti-bypass guardrails baked in (per the <pilot-repo> mechanical-mv failure pattern). For fresh repos, see 09-fresh-repo-scaffolding.md instead.
type: reference
status: active
date_created: 2026-05-26
date_updated: 2026-05-27
tags: [agentic-future, compound-engineering, migration, existing-repo, operator-guide, walkthrough]
related: ["[[00-readme]]", "[[03-migration-plan]]", "[[05-walkthrough]]", "[[08-doc-lifecycle-reference]]", "[[09-fresh-repo-scaffolding]]"]
---

# Migrate an Existing Repo into CE

Agent-guided walkthrough for bringing a pre-CE repo (e.g., meeting-translator) into CE adoption. Three phases — Phase 1 the agent automates with ☆ confirmation gates; Phase 2 you invoke CE bootstrap commands; Phase 3 hands off to [`05-walkthrough.md`](05-walkthrough.md) for the first feature.

For **fresh repos** (brand-new, no pre-CE history), use [`09-fresh-repo-scaffolding.md`](09-fresh-repo-scaffolding.md) instead.

## Pre-flight (agent reads these before touching anything)

1. The repo's current `CLAUDE.md`, `AGENTS.md` (if exists), `README.md`, `CHANGELOG.md`, `ISSUES.md`, `docs/architecture.md`, `docs/vision.md`, `docs/operations.md`, any other `docs/*.md`
2. [`08-doc-lifecycle-reference.md`](08-doc-lifecycle-reference.md) — methodology grounding (Per-doc Lifecycle Matrix, AGENTS.md primary + CLAUDE.md shim rationale)
3. [`03-migration-plan.md § 3.0 Prerequisite 4`](03-migration-plan.md) — the 5-check audit definition (this walkthrough's Phase 1.2 distills it into an operator-facing flow)
4. This doc's § "Anti-patterns" — load-bearing context for why the agent must halt before Phase 2 and never reach for mechanical bypasses

---

## Phase 1 — Pre-CE cleanup (agent automates, you confirm at ☆ gates)

The agent does mechanical work directly; you approve at the gates.

### Step 1.1 — Read repo state

Agent reads:
- `CLAUDE.md` + `AGENTS.md` (if exists)
- `README.md`, `CHANGELOG.md`, `ISSUES.md`
- `docs/architecture.md`, `docs/vision.md`, `docs/operations.md`, any other `docs/*.md`
- `.claude/rules/*` if exists

Reports back: state summary — which files exist, approximate sizes, what each contains.

### Step 1.2 — Run the 5-check audit

For each project-level doc (per `03-migration-plan.md § 3.0 Prereq 4`):

1. **Grep claims vs filesystem reality.** Components tables, Key Files tables, `How to Run` blocks — does each path exist on disk? Are listed skills/agents real?
2. **Command-validity check.** Do `How to Run` commands actually execute? Spot-check at least one per block.
3. **Git-proof Recent Updates.** Do CHANGELOG Recent Updates entries map to commits/tags? `git log --grep=<feature-slug>` should find them.
4. **Planned-vs-existing labeling.** Is aspirational content labeled "Future / Planned / Aspirational," or presented as current state? Mislabeled aspirations are the primary pollution vector.
5. **AGENTS.md / CLAUDE.md restructure assessment.** If pre-existing CLAUDE.md has substantive cross-agent content (Tech Stack, Project Conventions, Components, dispatcher rules) — flag for restructure to AGENTS.md.

Output: drift report with categorized findings.

### ☆ Step 1.3 — Approval gate: strip list + restructure plan

Agent presents to the operator:

- **Confirmed fictional content** (path doesn't exist / command doesn't run / Recent Updates entry not in git log) → proposed for strip
- **Ambiguous content** (aspirational but not clearly labeled; preserved intent unclear) → proposed for your judgment
- **Restructure plan** — does CLAUDE.md need to become AGENTS.md + shim? Y/N + which content moves where
- **Deprecated file plan** — archive `docs/vision.md` (yes/no — only after STRATEGY.md is established in Phase 2); delete `docs/operations.md` (yes/no — substantive runbook content moves to `docs/<feature>_reference.md` or `docs/runbook.md` first)

The operator approves / modifies / rejects each item before agent proceeds.

### Step 1.4 — Restructure CLAUDE.md → AGENTS.md + shim (if approved)

```bash
git mv CLAUDE.md AGENTS.md # preserve git history
```

> **Note on rename detection (empirical, <pilot-repo> 2026-05-27).** Git's rename detection has a similarity threshold; if the content delta exceeds it (e.g., when restructuring also adds new sections at the same commit), `git status` may classify the result as "create AGENTS.md" + "delete CLAUDE.md" rather than "rename." History is still preserved — use `git log --follow AGENTS.md` to trace it. The pre-Phase-A tag is the clean revert anchor either way.

Agent rewrites AGENTS.md per `02A § 5 Step 2` rules:

- **REMOVE**: Three Golden Rules (now in root `~/CLAUDE.md`)
- **REMOVE**: current-work-status (loaded via `/recall` from CHANGELOG)
- **REMOVE**: `/onboard`, `/deepdive` refs (replaced by `/recall`)
- **REMOVE**: doc-micro / doc-macro refs (replaced by software-documenter-ce)
- **STRIP**: fictional content per Step 1.3 approval
- **KEEP**: project overview, tech stack, real components, project conventions, dispatcher rules
- **ADD**: canonical new-issue-capture bullet in Operational Dispatcher (per the AGENTS.md+shim methodology): *"When a bug surfaces mid-work, adding a one-line entry to `ISSUES.md` Open Issues with date + brief is the lightweight capture path; SD-CE moves it to Resolved at ship time."* — (interim default while a `scaffold-ce-repo` skill is deferred)

Create new `CLAUDE.md` as shim:

```markdown
@AGENTS.md

## Claude Code

[OPTIONAL — Claude-Code-specific instructions only if needed. Most repos won't need anything here.]
```

Verify shim resolves: `cat CLAUDE.md` should show `@AGENTS.md` on line 1.

### Step 1.5 — Split development guidelines → `.claude/rules/`

If old CLAUDE.md (or `GUIDELINES.md`, or `DEVELOPMENT_GUIDELINES.md`) had development guidelines and `.claude/rules/` doesn't already exist:

```bash
mkdir -p .claude/rules
```

Extract content into:
- Code quality standards → `.claude/rules/code-quality.md`
- AI collaboration workflow → `.claude/rules/collaboration.md`
- Pre-commit checklist → `.claude/rules/pre-commit.md`

Add YAML frontmatter with `description:` to each.

If `.claude/rules/` already exists, audit content for alignment with CE methodology — no contradictions with `/ce-work` autonomous execution semantics, pre-commit hooks, etc.

### Step 1.6 — Handle deprecated files (initial pass)

- **`docs/operations.md`** (if exists): delete now. Move substantial runbook content (if any) to `docs/runbook.md` first; minor Quick Start content moves to README.
- **`docs/vision.md`** (if exists): **leave it for now.** Vision content will inform the `/ce-strategy` interview in Phase 2. After STRATEGY.md exists, archive vision.md per Step 2.3.

### Step 1.7 — Verify docs/ structure + CHANGELOG sections

- Ensure `docs/features/` and `docs/archive/` exist; create if missing
- Ensure `CHANGELOG.md` has sections: Current Focus / Roadmap / Recent Updates / Version History / Decision Log (add empty headers if missing)
- Ensure `ISSUES.md` has sections: Open Issues / Resolved Issues (add empty headers if missing)

### Step 1.8 — Tag revert anchor + commit

```bash
git add -A
git commit -m "Migrate to AGENTS.md + CLAUDE.md shim; rules split; pre-CE audit cleanup"
git tag pre-ce-phase-a
git push
git push --tags
```

The `pre-ce-phase-a` tag is the clean revert point if CE introduction needs to be undone later. **Don't skip this.**

---

## 🛑 HANDOFF — agent halts here

**The agent stops. The operator takes over for Phase 2.**

The agent must NOT:

- Manually create `STRATEGY.md`
- Manually create `.compound-engineering/`
- `git mv docs/vision.md STRATEGY.md` or any analogous mechanical shortcut
- Invoke `/ce-setup` or `/ce-strategy` itself

These are CE-skill territory. Mechanical bypasses are the documented failure pattern from <pilot-repo> — see § "Anti-patterns" below.

---

## Phase 2 — CE bootstrap (you invoke, agent waits + verifies)

### Pre-check — already CE-bootstrapped? (fast-path)

**If `.compound-engineering/` and `STRATEGY.md` already exist + valid, Phase 2 is N/A** — skip to Phase 3 with a verification checklist.

This applies to repos that ran `/ce-setup` + `/ce-strategy` in an earlier block but hadn't yet migrated to AGENTS.md + shim. **Empirical case:** <pilot-repo> (2026-05-27). Block B (2026-05-25) did `/ce-setup` + `/ce-strategy`; AGENTS.md+shim migration didn't happen until 2026-05-27 — Phase 2 of this walkthrough was entirely N/A at migration time.

**Verification checklist (when fast-pathing):**

- [ ] `.compound-engineering/` directory exists
- [ ] `.compound-engineering/config.local.yaml` exists (with `work_delegate*` + `pulse_*` unset per `03-migration-plan.md § 3.2`)
- [ ] `.gitignore` includes `.compound-engineering/*.local.yaml`
- [ ] `STRATEGY.md` at repo root with all 5 sections (Target Problem / Approach / Persona / Key Metrics / Tracks)
- [ ] CE skills (`/ce-brainstorm`, `/ce-plan`, etc.) work from the repo cwd

If all ✓: skip directly to **Phase 3**. If any ✗: fall through to Steps 2.1 / 2.2 below to repair the gap.

### ☆ Step 2.1 — Run `/ce-setup` (if not already done — see fast-path above)

In Claude Code (cwd = the migrated repo):

```
/ce-setup
```

Bootstraps `.compound-engineering/`, diagnoses environment, installs missing tools (`agent-browser`, `gh`, `jq`, `vhs`, `silicon`, `ffmpeg`, `ast-grep`). Config decisions (per `03-migration-plan.md § 3.2`):

- Leave `work_delegate` unset (Claude-only implementation)
- Leave `work_delegate_consent` unset
- Leave `pulse_*` settings unset

Tell the agent when complete. The agent verifies:

- `.compound-engineering/` directory exists
- `.compound-engineering/config.local.yaml` exists
- `.gitignore` includes `.compound-engineering/*.local.yaml`

### ☆ Step 2.2 — Run `/ce-strategy`

```
/ce-strategy
```

15-20 min interactive interview with pushback on weak answers. Be ready to answer:

- Target problem
- Approach
- Persona
- Key metrics
- Tracks (current focus areas)

If `docs/vision.md` existed, its content informs the interview but doesn't substitute it — the interview is structured to extract what `STRATEGY.md` needs.

Output: `STRATEGY.md` at repo root.

Tell the agent when complete. The agent reads STRATEGY.md and confirms structure matches expectations (target problem / approach / persona / metrics / tracks all present).

### Step 2.3 — Archive `docs/vision.md` (if it existed)

Now that STRATEGY.md exists, archive the legacy vision content:

```bash
mkdir -p docs/archive
git mv docs/vision.md docs/archive/vision.md
git commit -m "Archive vision.md — superseded by STRATEGY.md"
git push
```

Vision content informed the `/ce-strategy` interview; the file itself is deprecated.

---

## Phase 3 — First feature (hands off to 05-walkthrough.md)

The migration is complete. From here, every feature ships via the per-feature walkthrough.

### ☆ Step 3.1 — Pick the first feature

The operator decides what to work on first.

### ☆ Step 3.2 — Follow `05-walkthrough.md` from Step 0

Switch to [`05-walkthrough.md`](05-walkthrough.md). The agent guides you through:

- Step 0 — verify STRATEGY.md exists (already done in Phase 2 above; 05's Step 0 is defensive)
- Step 1 — `/ce-brainstorm` → requirements with R/A/F/AE-IDs
- Step 2 — `/ce-plan` → implementation plan with U-IDs traced
- Step 3 — `/ce-work` → autonomous execution
- Step 4 — code review
- Step 5 — `/ce-commit-push-pr`
- Step 6 — `/ce-compound` (Discoverability Check fires; AGENTS.md gets `docs/solutions/` awareness)
- Step 7 — `@software-documenter-ce ship docs` (populates AGENTS.md Components, README, CHANGELOG, ISSUES from real shipped work)
- Step 8 — scorecard
- Step 9 — debrief

Subsequent features iterate through 05.

---

## Anti-patterns (what the agent must NEVER do)

From the <pilot-repo> 2026-05-25 bypass-failure narrative (archived at `archive/next-steps-2026-05-24.md`):

- ❌ **Do NOT** `git mv docs/vision.md STRATEGY.md`. STRATEGY.md is produced by the `/ce-strategy` interview, not file renaming.
- ❌ **Do NOT** manually create or edit STRATEGY.md. Only `/ce-strategy` writes it.
- ❌ **Do NOT** manually create `.compound-engineering/`. Only `/ce-setup` bootstraps it.
- ❌ **Do NOT** invoke `/ce-setup` or `/ce-strategy` on behalf of the operator — those are user-invoked. The agent prompts and waits.
- ❌ **Do NOT** advance to Phase 2 without the operator's explicit go-ahead after the Phase 1 ☆ 1.3 approval gate.
- ❌ **Do NOT** pre-populate AGENTS.md Components & Architecture from a requirements brief or mental model — only document what's verifiably on disk (per Step 1.2 audit, confirmed at Step 1.3 gate).
- ❌ **Do NOT** delete `docs/vision.md` content blindly — preserve in `docs/archive/` after STRATEGY.md exists (Step 2.3).
- ❌ **Do NOT** continue past a ☆ gate without explicit operator approval.

**Self-check rule:** if the agent finds itself doing mechanical file ops to "complete" a CE-skill outcome, that's the bypass pattern. Halt and re-read this section.

An early pilot did `git mv vision.md → STRATEGY.md` + manual edits instead of invoking `/ce-strategy`. The operator caught it mid-brainstorm. Recovery required `git reset --hard pre-ce-phase-a` + `rm -rf .compound-engineering/`. The `pre-ce-phase-a` tag in Step 1.8 is the explicit revert anchor for that failure class.

---

## Edge cases — captured inline until pattern density warrants a separate handbook

The original plan (per `03-migration-plan.md § 3.0 Prereq 4`) was to draft a separate JIT handbook (`importing-existing-repos-into-ce.md`) on first real import. **Revised 2026-05-27:** the first real import (<pilot-repo>) produced only two empirical findings, both of which fit better inline in this walkthrough than in a separate doc:

1. **Git rename detection threshold** — captured inline at Step 1.4 above.
2. **Phase 2 fast-path for already-CE-bootstrapped repos** — captured inline at Phase 2 pre-check above.

**Revised policy:** edge-case findings from real migrations land inline in this doc until pattern density warrants extraction. The `importing-existing-repos-into-ce.md` JIT handbook becomes warranted when 3+ real migrations have surfaced tactical edge cases that don't fit inline (e.g., legacy ADR decision-record formats, project-scope skill/agent conflicts, cross-agent vs Claude-Code-only content split distinctions, CI/CD references to deprecated files).

If you're running a migration and hit a weird situation not covered above, propose its addition to this doc OR — if the volume of such findings starts overflowing the walkthrough's operator clarity — that's the signal to extract the JIT handbook. Codex Round 2 (2026-05-27) endorsed this revision: with one mundane real-use validation in hand, a separate handbook would be 80% placeholders.

---

## Cross-references

- [[09-fresh-repo-scaffolding]] — parallel doc for fresh repos
- [[05-walkthrough]] — per-feature operator walkthrough (Phase 3 hands off here)
- [[03-migration-plan]] § 3.0 Prereq 4 — the 5-check audit definition + deprecated file handling
- [[03-migration-plan]] § 3.2-3.3.5 — `/ce-setup` config decisions + version pin + `/ce-strategy` invocation rationale
- [[08-doc-lifecycle-reference]] — methodology grounding (Per-doc Lifecycle Matrix, AGENTS.md primary)
- `archive/next-steps-2026-05-24.md` § "First Block B bypass failure" — bypass-pattern source narrative
- `compound engineering/importing-existing-repos-into-ce.md` (TO BE DRAFTED on first real import) — JIT edge-case handbook

---

*Created 2026-05-26. Operator walkthrough for migrating pre-CE repos into CE. Agent-guided three-phase flow with explicit 🛑 halt + ☆ handoff markers. Anti-bypass guardrails baked in (from <pilot-repo> 2026-05-25 incident). Edge cases captured in JIT handbook as they surface during real migrations.*
