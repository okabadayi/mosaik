---
description: Operator-facing walkthrough for CE-piloted features. Point your agent at this doc when starting a new CE-piloted feature; the agent reads it as a script, prompts at each ☆ checkpoint, walks the scorecard at end. Lighter alternative to a wizard skill — just a doc.
type: walkthrough
status: active
date_created: 2026-05-24
date_updated: 2026-05-27
tags: [agentic-future, compound-engineering, walkthrough, operator-facing]
related: ["[[00-readme]]", "[[03-migration-plan]]", "[[04-inventory]]"]
---

# CE Pilot — Operator Walkthrough

**For the agent reading this:** the operator is starting (or continuing) a CE-piloted feature in this repo. Your job is to walk him through this doc step by step. Do NOT dump the whole walkthrough at once. Go one step at a time. **☆ marks the prompts to ask him** — wait for his answer before proceeding. He's relying on you to prompt him at each ☆; if you skip a ☆, he will forget the step.

If this is the first feature in this repo (pre-flight not done), do Step 0 first. If subsequent features, skip Step 0 and start at Step 1.

This walkthrough operationalizes `03-migration-plan.md § 3.5` (Run the loop) and § 3.6 (Evaluation + Scorecard). Read those for full context; use this doc as the runtime script.

---

## Step 0 — Pre-flight (first time in this repo only)

Verify:

```bash
# CE plugin installed? (run in Claude Code; not bash)
# /plugin list → should show compound-engineering

# This repo bootstrapped?
ls -la .compound-engineering/ # should exist; if not, run /ce-setup

# Pin recorded in code-wide CLAUDE.md?
grep -q "Compound Engineering" ~/repos/CLAUDE.md && echo "OK" || echo "MISSING"

# software-documenter-ce variant exists?
ls -la ~/.claude/agents/software-documenter-ce.md && echo "OK" || echo "MISSING"

# codex-review skill has the 2026-05-24 fixes?
ls -la ~/.claude/skills/codex-review/SKILL.md && echo "OK (verify it matches your latest copy)" || echo "MISSING"

# STRATEGY.md exists in this repo? (CE's per-product anchor — read by /ce-ideate, /ce-brainstorm, /ce-plan as upstream grounding when present)
ls -la STRATEGY.md && echo "OK (will ground brainstorm + plan)" || echo "MISSING — see prompt below"

# pre-ce-phase-a git tag — MANDATORY revert point per 03-migration-plan § 3.0 Prereq 3
git tag -l pre-ce-phase-a | grep -q "pre-ce-phase-a" && echo "OK (revert point exists)" || echo "MISSING — see hard-blocker prompt below"
```

If any check (except STRATEGY.md and `pre-ce-phase-a` tag) fails, address per `03-migration-plan.md § 3.0 + § 3.1-3.3` before continuing.

**Hard blocker — `pre-ce-phase-a` git tag MUST exist before any CE skill runs in this repo.** Without it, Phase A revert (per `03-migration-plan.md § 6.0`) can't cleanly reset the repo because SD-CE `ship docs` will modify `README.md` / `AGENTS.md` or `CLAUDE.md` Components (per shim) / `ISSUES.md` / `CHANGELOG.md` in-place, interleaved with implementation commits. Manual untangling otherwise required.

☆ If `pre-ce-phase-a` tag is missing, tell the operator: **"`pre-ce-phase-a` tag missing in this repo. Run `git tag pre-ce-phase-a` (and optionally `git push origin pre-ce-phase-a` for off-machine durability) before any CE skill runs in this repo. Confirm when done."** Wait for confirmation; verify with `git tag -l pre-ce-phase-a`. **Do NOT proceed to Step 1 until the tag exists** — this is non-negotiable per `03-migration-plan.md § 3.0 Prereq 3`.

**If `STRATEGY.md` is missing**, this isn't a hard blocker for the first feature, but it weakens the artifact chain — downstream skills lose the upstream anchor.

☆ Ask the operator: **"This repo doesn't have a `STRATEGY.md`. CE's `/ce-ideate`, `/ce-brainstorm`, `/ce-plan` read it as grounding when it exists. Two options: (a) invoke `/ce-strategy` now to create one — recommended for Internal+ tier projects; ~15-20 min Rumelt-inspired interview; (b) defer strategy and proceed with the first feature (works, but loses grounding). Which?"**

- If (a): invoke `/ce-strategy` and walk through. Then proceed below.
- If (b): proceed below; note that brainstorm + plan won't auto-load STRATEGY.md.

☆ Ask the operator: **"Pre-flight done (including `pre-ce-phase-a` tag verified). What's the feature you're starting? Give me a one-line description."**

**Exploring rather than feature-naming?** If the user says something like "I don't know what to build next" or "what should we work on?", suggest invoking `/ce-ideate` first (optional core; between-projects discovery). After ideate produces candidate directions and the user picks one, return here with the feature description.

---

## Step 1 — Brainstorm requirements

Run: `/ce-brainstorm <one-line description from the operator>`

CE will ask questions one at a time, tier-classify (Lightweight / Standard / Deep / Deep-product), and produce:

- `docs/brainstorms/<feature>-requirements.md` with R-IDs (Requirements), A-IDs (Actors), F-IDs (Key Flows), AE-IDs (Acceptance Examples)

After the brainstorm completes:

☆ Ask the operator: **"Open the requirements doc at `docs/brainstorms/<feature>-requirements.md`. Does it match what you actually want? Anything missing or wrong? If something's off, run `/ce-brainstorm` again or edit the doc directly."**

---

## Step 2 — Plan implementation

Run: `/ce-plan docs/brainstorms/<feature>-requirements.md`

CE produces:

- `docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md` with U-IDs (Implementation Units), each traced back to R-IDs / AE-IDs
- Auto-invokes `/ce-doc-review` headless at Phase 5.3.8 for plan-quality review

After the plan completes:

☆ Ask the operator: **"Plan generated. Do you want a Codex second opinion on the plan? Recommended for Internal+ tier; optional for Solo. (Use the codex-review skill — Case 1 Plan Review.)"**

If yes: invoke Codex per `~/.claude/skills/codex-review/SKILL.md` Case 1. Apply approved findings to the plan before continuing.

---

## Step 3 — Execute the plan

Run: `/ce-work`

CE reads the latest plan, executes against U-IDs with idempotency check, runs tests continuously.

**During `/ce-work` execution**, periodically check in with the operator. Don't wait for him to remember — prompt him:

☆ Periodically ask (e.g., every ~30 min of work, or when context starts feeling full, or before a long pause):

> **"Context might be filling — want to invoke `@software-documenter-ce capture status` now? This writes `docs/features/<feature>_wip.md` with trials/errors, in-flight pivots, observations. CE doesn't capture this; it's your compaction-survival bridge AND the Shape A bridge input for `/ce-compound` later. Critical."**

If yes: invoke `@software-documenter-ce capture status`. Note the WIP file path for Step 5.

After `/ce-work` reports complete:

☆ Ask the operator: **"Implementation done. Want a `/ce-code-review` pass? Required for Internal+ tier touching sensitive surfaces (auth, secrets, data integrity, payments). Skip for Solo trivial changes."**

If yes: run `/ce-code-review`. CE's multi-persona pipeline produces findings; fold them back via another `/ce-work` pass if needed.

---

## Step 4 — Ship the feature

Run: `/ce-commit-push-pr`

CE creates the PR with adaptive description (scaled to change complexity).

---

## Step 5 — Compound the learning (if generalizable)

☆ Before invoking `/ce-compound`, ask the operator: **"Did this feature produce a generalizable insight worth capturing? Capture if: a reusable pattern emerged, a bug class likely to recur, a rejected approach future agents might try, a project-specific convention, or a non-obvious causal chain. SKIP if: only mechanical fixes / one-off bugs / no surprising insight. CE's design says skip silently in the skip case — `docs/solutions/` is poisoned by noise more than by silence."**

If skip: proceed to Step 6 directly.

If capture:

☆ Ask the operator: **"Do you have WIP content at `docs/features/<feature>_wip.md` from this feature? If yes, paste the relevant excerpts (failed approaches, in-flight pivots, observations) into the `/ce-compound` invocation context — they'll show up in 'What Didn't Work' (bug-track) or 'Context' (knowledge-track) of the resulting solution doc. This is the Shape A bridge."**

Then run: `/ce-compound` (with WIP excerpts pasted in if applicable).

After `/ce-compound` completes:

☆ Ask the operator: **"Open the generated `docs/solutions/<category>/<slug>.md`. Did your WIP content actually show up where you'd expect (What Didn't Work / Context sections)? If yes — Shape A worked. If no — that's the Shape A degradation signal; mark scorecard Q5 = N for this feature. If Q5 = N for 2+ features in a row, that's the trigger to build Shape B (per `03-migration-plan.md § 4`)."**

---

## Step 6 — Ship docs (mandatory after each ship)

Always invoke `@software-documenter-ce ship docs` after `/ce-commit-push-pr` returns. This is the single comprehensive ship-time documentation update — one invocation touches `README.md`, the substantive instruction file Components (AGENTS.md if present, else CLAUDE.md, per shim detection), `ISSUES.md`, `CHANGELOG.md`, `docs/<feature>.md` user doc (if applicable), and the agent vault project entry. The agent is smart about what's needed per surface — it proposes a checklist; the operator confirms or overrides.

☆ Tell the operator: **"PR is created. Invoking `@software-documenter-ce ship docs` now — it will propose a per-surface update checklist for you to confirm or override. CHANGELOG is included (the agent handles create-if-missing-and-warranted vs update-if-exists vs skip-if-throwaway based on repo context)."**

Invoke: `@software-documenter-ce ship docs`

The agent will:

1. Identify the feature from branch name + plan file + recent commits + WIP + brainstorm + the PR that was just created
2. Present a per-surface checklist: which of `README` / Components (AGENTS.md or CLAUDE.md per shim) / `ISSUES.md` / `CHANGELOG.md` / user doc / agent vault entry it proposes to update, with one-line reasons + which it proposes to skip
3. Wait for confirmation (or override — the operator can say "skip ISSUES.md, don't touch user doc")
4. Apply the confirmed updates; report what was written

☆ After the agent returns, ask the operator: **"Ship docs complete. Anything the agent skipped that you actually wanted updated? Anything it touched that you didn't want?"**

If anything's off: re-invoke `ship docs` with explicit instructions, or invoke the original `@software-documenter` for a specific single-surface mode (e.g., `@software-documenter update changelog` for a CHANGELOG-only correction in a non-standard format).

---

## Step 7 — Reference doc (situational)

Reference docs (`docs/<feature>_reference.md`) are NOT included in `ship docs` — they have semantic complexity that benefits from explicit direction. Sometimes a new sub-feature goes UNDER an existing reference doc as a subsection; sometimes it warrants its own new file. You're the best judge.

☆ Ask the operator: **"Does this feature warrant (a) a new reference doc, (b) updates to an existing reference doc, or (c) neither — CE's plan + PR description + (optional) solution doc already cover it for cold-start purposes? Pick one."**

**If (a) or (b):** invoke `@software-documenter-ce reference doc <your instruction>`. Examples:

- *"create reference doc for the search-deep-mode feature"*
- *"update search reference doc with a deep-search subsection"*
- *"update auth reference doc — token rotation now uses OAuth refresh flow"*
- *"create reference doc for the realtime translation module"*

The agent will:

1. Parse your instruction
2. Identify target (new file vs update existing — for "update," it scans `docs/*_reference.md` for the matching feature and proposes where to insert)
3. Show you the proposed action
4. Apply on confirmation

**If (c):** skip this step.

**Decision rule for "is a reference doc warranted?":**

- **Required when:** feature has multiple interacting components; operational or debugging complexity; will be extended later; future agents need a cold-start map; new user-facing surface with non-trivial mechanics
- **Skip when:** small isolated change; no new concept introduced; CE artifacts (plan + PR description + solution doc) already capture enough; self-explanatory code

---

## Step 8 — Scorecard (mandatory after each feature)

**This is the gate. Don't skip.** Walk through the per-feature scorecard from `03-migration-plan.md § 3.6.1`. The scorecard is what keeps the pilot from drifting into sunk-cost adoption.

Capture answers in `docs/features/<feature>_scorecard.md` (create if it doesn't exist; simple bullet format).

☆ Ask the operator each question one at a time, capture his answer + a short note:

1. **"Did `/ce-brainstorm` produce a requirements doc you'd refer back to, or did it feel like ceremony?"** (Y/N + 1-line why)
2. **"Did `/ce-plan`'s U-IDs survive into commit messages and trace cleanly?"** (Y/N)
3. **"Did `/ce-work` execute against the plan without you having to override or re-plan mid-flight?"** (Y/N + count of overrides if any)
4. **"Did `/ce-compound` produce a `docs/solutions/` entry you'd want a future session to find, OR did you correctly skip it because the work wasn't generalizable?"** (Y/N — either path counts as Y if the call was right)
5. **"Did SD's WIP narrative (via Shape A) get pasted into `/ce-compound` when the feature warranted it?"** (Y/N — this is the Shape B trigger if repeatedly N)
6. **"Total durable artifacts produced for this feature?"** (count — compare to tier expectation per § 2.5 Artifact Proportionality Rule: Solo 0-2, Internal 3-5, Public full chain when warranted)
7. **"Estimated wall-clock time spent on methodology overhead (brainstorm + plan + artifact writing + review reading — excluding actual coding)?"** (minutes)

After capturing answers, write the scorecard to `docs/features/<feature>_scorecard.md`:

```markdown
# Scorecard — <feature>

Captured YYYY-MM-DD.

- Q1 (brainstorm useful): Y/N — <why>
- Q2 (U-ID trace): Y/N
- Q3 (work without override): Y/N — <overrides>
- Q4 (compound or correct skip): Y/N — <which path>
- Q5 (Shape A worked): Y/N
- Q6 (artifacts produced): <count> (tier expectation: <range>)
- Q7 (methodology overhead): ~<N> minutes
```

☆ Tell the operator: **"Scorecard captured at `docs/features/<feature>_scorecard.md`. Feature complete. If this is your 3rd CE-piloted feature OR you've been using CE for ~1 month / shipped 5 features, also run Step 9 (checkpoint review)."**

---

## Step 9 — Checkpoint review (at feature 3, OR feature 5 / 1 month)

Count: how many CE-piloted features have shipped in this repo (incl. this one)?

- **If this is feature 3**: run the **3-feature commit / partial-drop / revert review** (continues below).
- **If this is feature 5 OR ~1 month since first CE feature**: run the **sustainability checkpoint** (continues further below).
- Otherwise: skip Step 9.

### 9a — 3-feature review

Read the scorecards from the last 3 features at `docs/features/<f>_scorecard.md`. Check the continue criteria from `03-migration-plan.md § 3.6.1`:

- Majority of Y/N questions Y across the 3 features?
- At least one captured `docs/solutions/` entry retrieved + used by `/ce-plan` or `/ce-ideate` in a subsequent feature?
- Methodology overhead felt proportionate? (Rough cap: Solo <15%, Internal <25%, Public <30%.)
- Artifact count per feature within tier-expected range (no ceremony creep)?

Also check stop criteria — if any fires, pause and ask the operator:

- 3 consecutive features with >2 N's?
- Methodology overhead >30%?
- A specific CE skill produced more friction than value across 2+ features?
- A captured `docs/solutions/` entry never retrieved after 1 month?

☆ If any continue criterion fails OR any stop criterion fires: ask the operator **"Continue criterion failed / stop criterion fired: <which>. Options: (a) continue + watch the gap; (b) drop the specific skill causing friction (partial drop, not full revert); (c) full revert per § 6.0. Which?"**

☆ If all continue criteria pass + no stop criterion fired: confirm with the operator **"3-feature continue criteria all pass. Phase A pilot is on track. Want to start Phase B work next? (Options in § 6.1-6.4 of migration plan.)"**

### 9b — Sustainability checkpoint (1 month / 5 features)

☆ Ask the operator the feel-based questions (free-text answers; no Y/N):

1. **"Do you feel like you're effectively and efficiently shipping software?"** (compared to your pre-CE baseline)
2. **"Do you feel like proper documentation is being produced?"**
3. **"Compared to your previous methodology, is this working for you?"**
4. **"What changed in how you're working that you'd want to keep? What would you drop?"**

Capture answers verbatim in `docs/ce-pilot-1month-review.md` (file is for future-you to read at the 3-month re-evaluation per `03-migration-plan.md § 9`).

☆ Synthesize for the operator: **"Read your answers back to me. Based on these + the per-feature scorecards across all features shipped: is the pilot working? Pick: (a) continue + commit to ongoing CE adoption (consider Phase B work); (b) drop specific pieces that aren't working (partial); (c) full revert per § 6.0."**

**Reconciliation rule** between gut-check and structured scorecard:

- Gut-check **Y** AND scorecard **Y** → confident sustained adoption
- Gut-check **N** AND scorecard **Y** → gut-check wins; investigate the gap (something the scorecard isn't catching)
- Gut-check **Y** AND scorecard **N** → don't let optimism override structured signal; partial-drop or revert
- Gut-check **N** AND scorecard **N** → revert (no ambiguity)

---

## Reference pointers

- `03-migration-plan.md` — full migration plan (this walkthrough is the runtime script for § 3.5 + § 3.6)
- `03-migration-plan.md § 6.0` — full Phase A revert procedure
- `04-inventory.md` — per-skill cheat sheets (Solo / Internal / Public tiers + CE Core Set definition § 2.0)
- `01-overview.md` — what CE is structurally (deep reference)
- `~/.claude/agents/software-documenter-ce.md` — the SD-CE variant invoked in Step 3 (`capture status`), Step 6 (`ship docs`), and Step 7 (`reference doc <instruction>`). Three modes total — picker surfaces them when you `@-invoke` the agent without arguments
- `~/.claude/skills/codex-review/SKILL.md` — Codex second-opinion skill (invoked at Step 2 plan review if requested)

---

*Created 2026-05-24. Operator walkthrough; agent script. Update if Step 6 scorecard shape changes per `next-steps-2026-05-24.md` § 5.*
