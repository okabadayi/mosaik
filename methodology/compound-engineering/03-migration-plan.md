---
description: Operational migration plan for adopting Compound Engineering as the software-development methodology for code repos inside the operator's setup. Phase A is install + first-feature dry-run; Phase B is integration enhancements (QMD cross-repo solutions, software-documenter scope reduction, ce-agent-native reference, optional Shape-B bridge). Pin compound-engineering-plugin v3.8.4 commit 08bb5899036e9ca33585b38ce840e2b2bfaacac8.
type: plan
status: active
date_created: 2026-05-24
date_updated: 2026-05-27
tags: [agentic-future, compound-engineering, migration, software-methodology]
ce_reference_version: v3.8.4
ce_reference_commit: 08bb5899036e9ca33585b38ce840e2b2bfaacac8
related: ["[[00-readme]]", "[[01-overview]]", "[[04-inventory]]"]
---

# Compound Engineering — Migration Plan

**Start here if you're a fresh agent / future-you adopting CE.** This doc is the action plan. See `01-overview.md` for what CE is structurally, the methodology comparison in the share repo README for how it relates to the existing methodology, `04-inventory.md` for per-skill adoption status and per-tier cheat sheets.

---

## 1. Position

This plan describes adopting Kieran Klaassen / Every's [Compound Engineering plugin](https://github.com/EveryInc/compound-engineering-plugin) (open-source, 17,000+ GitHub stars) as the software-development engine for the Mosaik framework.

**In scope:** code-repo work inside `~/repos/<project>/`. CE replaces / augments the per-repo software-development workflow.

**Out of scope:** everything outside `~/repos/`. The OS-level system continues unchanged:

- Life-domain folders (out of share repo scope)
- Agent vault (your knowledge vault)
- Personal vault (your knowledge vault)
- `/recall` skill and its existing collections (`personal`, `agent`, `sessions`)
- a todos skill (life-domain side; not in share repo scope)
- a life-domain capture agent (separate from this share repo)
- the repos-as-Obsidian-vault pattern

CE has no equivalent to most of these — it operates per-repo. The two systems compose at the `~/repos/<project>/` boundary; they don't compete.

The strategic decision behind this scoping is documented in the methodology comparison in the share repo README. The short version: CE is a more integrated, more battle-tested per-repo development workflow than the existing software-documenter; the existing system is broader (OS-level) than anything CE addresses. Adopt CE's loop inside repos; keep everything else.

---

## 2. Pin

| Field | Value |
|---|---|
| Plugin | https://github.com/EveryInc/compound-engineering-plugin |
| Version pinned at adoption | **v3.8.4** |
| Tag commit SHA | `08bb5899036e9ca33585b38ce840e2b2bfaacac8` |
| Released | 2026-05-21 |
| Adopted | 2026-05-24 |
| Next re-evaluation | **2026-08-24** (3-month cadence; see § 9) |

The pin matters: CE evolves quickly (153 releases since v1.0, 815 commits on main as of read time). When a re-evaluation reads "what changed in CE since we adopted," the pin is the baseline.

---

## 2.5. Artifact proportionality rule

**The number of durable artifacts per piece of work must scale with blast radius and future reuse. Small changes should not leave a seven-document trail.**

This is a load-bearing principle for using CE without ceremony creep. The CE + reduced-SD stack can produce up to nine artifacts per feature: brainstorm requirements doc, plan doc, WIP, PR description, solution doc, reference doc, user doc, README entry, CHANGELOG entry. That set is appropriate for a high-stakes public feature. It would be absurd for a Solo throwaway script.

The rule maps to the Blast Radius tiers in `04-inventory.md` § 2:

- **Solo** (just me, throwaway/personal): typically **0-2 durable artifacts** per piece of work. A commit alone is often the complete trail. `/ce-compound` only when there's a genuinely reusable insight; otherwise skip silently.
- **Internal** (few users in company): typically **3-5 durable artifacts** — brainstorm + plan + WIP (if multi-session) + PR description + maybe a `docs/solutions/` entry. Reference doc only when future cold-start understanding warrants it.
- **Public** (real users, scale): the **full chain when warranted** — brainstorm, plan, WIP, PR description, solution doc, reference doc, user doc, README/CHANGELOG updates. Not every feature; only when surface complexity warrants it.

When in doubt, fewer artifacts. CE's per-skill right-sizing (Lightweight tiers, trivial-bug fast-paths, adaptive PR descriptions, `/ce-compound`'s skip-if-not-generalizable rule) already trims depth within invocations. The proportionality rule trims the *set of skills you reach for at all*.

If a routine piece of work is producing seven-document trails, that's the warning sign: re-read this section, drop artifacts that aren't earning their keep.

---

## 3. Phase A — install + first-feature dry-run

### 3.0 Pre-flight checks

Four prerequisites must land before invoking any CE skill in a real repo:

**Prerequisite 1 — codex-review skill enrichments applied.** The `codex-review` skill at `~/.claude/skills/codex-review/SKILL.md` had six known failure modes documented in `capabilities/04-codex-capabilities.md` (broken stderr suppression, missing `--json`, foreground execution risk, no timeout wrapper, stale troubleshooting, stale version metadata). Phase A invokes Codex at plan-review and impl-review checkpoints; the skill needed to be fixed first.

- **Status:** ✓ **Applied 2026-05-24** — six runbook fixes + three Codex-review-suggested cleanups (governance language accuracy, CE-era workflow integration pointer, data-sanitization reminder for paste-content templates). Backup at `~/backups/pre-codex-skill-fixes-2026-05-24/SKILL.md.orig`.

**Prerequisite 2 — `software-documenter-ce` variant created (Option B; three-mode design).** SD's original at `~/.claude/agents/software-documenter.md` covers feature documentation autonomously via `feature complete` (archives WIP, writes reference doc, updates README/CLAUDE.md Components/ISSUES/CHANGELOG, updates agent vault entry — all in one shot). In CE-piloted repos, CE handles the git/PR layer (`/ce-work` + `/ce-commit-push-pr` + `/ce-compound`); the doc-layer parts need a different shape.

We keep the **original SD unchanged** (Option B) and create a **`software-documenter-ce` variant** at `~/.claude/agents/software-documenter-ce.md` with a three-mode design tailored to CE-piloted repos:

| Agent | Modes | Use when |
|---|---|---|
| `@software-documenter` (original, unchanged) | All current modes (`capture learnings` / `feature complete` / `ship it` / `update changelog` / `archive WIP` / `archive plan` / `create reference doc`) | Non-CE repos — full lifecycle behavior preserved. Also usable in CE repos for `update changelog` if the CE-piloted repo keeps a CHANGELOG.md in a non-standard format SD-CE doesn't handle. |
| `@software-documenter-ce` (new variant) | Three modes: **`capture status`** (during work — appends WIP entry), **`ship docs`** (at ship — smart per-surface sweep across README + AGENTS.md or CLAUDE.md Components (per shim detection) + ISSUES + CHANGELOG + user doc + agent vault entry; agent decides per surface based on repo state, proposes a checklist, user confirms), **`reference doc <instruction>`** (situational create or update of reference docs; user-directed for placement) | Repos that have run `/ce-setup` |

Per-repo invocation discipline: in a CE-piloted repo, invoke `@software-documenter-ce`. In a non-CE repo, invoke `@software-documenter`. The original stays exactly as it is, so reverting CE adoption is just "stop invoking the `-ce` variant." See `05-walkthrough.md` for when each `-ce` mode is invoked in the per-feature flow (Steps 3, 6, 7).

- **Status:** ✓ **Applied 2026-05-24** — `software-documenter-ce.md` created with three-mode design; original untouched. Both available concurrently.

Both prerequisites are reversible: the codex-review fixes are git-tracked + backed up; the `-ce` variant is a separate file that can be deleted to revert.

**Prerequisite 3 — `pre-ce-phase-a` git tag in each piloted repo.** Before invoking `/ce-strategy` or `/ce-setup` in any piloted repo, tag the current commit:

```bash
cd ~/repos/<project>/
git tag pre-ce-phase-a
git push origin pre-ce-phase-a # optional: push to GitHub for off-machine durability
```

Why: by the time the scorecard (§ 3.6.1) says "revert" (typically 3 features in), SD-CE's `ship docs` modifications to README / CHANGELOG / ISSUES / substantive-instruction-file Components are interleaved with regular implementation commits — manual untangling required without a tag. The tag provides a clean `git reset --hard pre-ce-phase-a` revert point. See `the propagation plan § 7.5.2 OPS` for full revert command + cleanup.

- **Status:** ⏳ **per-repo TODO** — apply in each repo at the moment it enters Phase A (before any CE skill runs in that repo). Not a one-time global action.

**Prerequisite 4 — Pre-`/ce-setup` audit for imported repos.** For repos imported into CE adoption (i.e., existing repos with pre-CE history, not fresh scaffolds), run a documentation audit BEFORE invoking `/ce-setup`. Goal: strip fictional/aspirational content polluting AGENTS.md / CLAUDE.md / README / CHANGELOG / ISSUES so CE skills don't inherit and propagate the fiction. Drives directly from the <pilot-repo> Phase A empirical finding (`the devil's-advocate review § 5 (2026-05-26 (late))` + `claude-md-post-ce-analysis-2026-05-26.md`) where the pre-CE Components table claimed `src/bot.py`, 7 skills, `data/<pilot-repo>.sqlite` — none existed.

**Audit scope (files):** `AGENTS.md` (if exists), `CLAUDE.md`, `README.md`, `CHANGELOG.md`, `ISSUES.md`, `docs/architecture.md`, `docs/vision.md`, `docs/operations.md`, any other `docs/*.md`.

**Audit checklist (5 checks):**

1. **Grep claims vs filesystem reality.** For each component / file reference in Components tables, Key Files tables, and `How to Run` blocks: does the path exist on disk? Are listed skills/agents/modules real?
2. **Command-validity check.** Do `How to Run` commands actually execute? Spot-check at least one per command block; full check at exit-code level is ideal.
3. **Git-proof Recent Updates.** Do Recent Updates entries in CHANGELOG map to commits / tags / merges? `git log --grep=<feature-slug>` should find them.
4. **Planned-vs-existing labeling.** Is aspirational content (planned features, future architecture) labeled "Future / Planned / Aspirational," or is it presented as current state? Mislabeled aspirations are the primary pollution vector.
5. **AGENTS.md / CLAUDE.md restructure rule.** If pre-existing CLAUDE.md has substantive cross-agent content (Tech Stack, Project Conventions, Components, dispatcher rules): MOVE that content to AGENTS.md (use `git mv` for history preservation when possible). Reduce CLAUDE.md to `@AGENTS.md` shim plus optional Claude-Code-specific additions. If a pre-existing AGENTS.md exists, audit it the same way as CLAUDE.md (grep claims, validate commands, etc.).

**Handling of deprecated files:**

- `docs/vision.md` — archive to `docs/archive/` once STRATEGY.md is established (Step 6 of the per-repo flow). Vision content informs `/ce-strategy` but doesn't substitute the interview.
- `docs/operations.md` — delete (deprecated per the doc-structure skill). Quick Start content moves into README; operational runbook content (if substantial enough to warrant) becomes a `docs/<feature>_reference.md` or a dedicated `docs/runbook.md`.

**Per-file actions during audit:**

- Strip fictional specifics; preserve intent + real conventions
- Move decision-rationale to CHANGELOG Decision Log (single source of truth — don't duplicate in `docs/architecture.md`)
- For pre-existing `.claude/rules/` files: audit for content; verify alignment with CE methodology (no contradictions with `/ce-work` autonomous execution semantics, pre-commit hooks, etc.)

**Sandbox validation caveat.** SD-CE behavioral changes (e.g., the `audit-docs` skill when it lands in Phase B; possible capture-issue mode pending § 9 #1 decision) should be tested in a throwaway repo before applying to a real imported repo. Don't validate behavioral skills on production project history.

**JIT handbook deferred until 3+ migrations surface patterns** (revised 2026-05-27 after first real import). Operational specifics for edge cases (pre-existing AGENTS.md handling, cross-agent vs Claude-Code-only content split, legacy decision-record formats like ADRs, CI/CD references to deprecated files, git history preservation specifics, project-scope skill/agent conflicts) were originally planned to land in a separate `compound engineering/importing-existing-repos-into-ce.md` drafted on first real import. **First real import happened (<pilot-repo>, 2026-05-27)** and produced only two mundane findings (git rename-detection threshold + Phase 2 fast-path for already-CE-bootstrapped repos), both of which fit inline in `10-migrate-existing-repo.md` better than in a separate doc. **Revised plan:** edge-case findings accumulate inline in 10-migrate until pattern density overflows operator clarity. The separate handbook becomes warranted at 3+ migrations with tactical findings that don't fit inline. This plan stays focused on methodology; 10-migrate carries empirical findings; the handbook is created when justified by accumulated material.

- **Status:** ⏳ **per-imported-repo TODO** — apply in each imported repo before `/ce-setup`. Not applicable to fresh scaffolds (those don't have pollution to strip; § 6.1 scaffolding flow covers them).

### 3.1 Install plugin (user-level)

User-level install. Single source of truth, all repos benefit, single upgrade path.

```text
# In Claude Code, from any directory:
/plugin marketplace add EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

After install, CE skills are available as `/ce-*` slash commands. CE prefixes everything with `ce-`, so there is **no naming conflict** with existing skills (`/recall`, `/todos`, `@software-documenter`, `the life-domain capture agent`, etc.).

**Do not** install for Codex or Gemini targets yet. Those are converter-backed installs (`bunx @every-env/compound-plugin install compound-engineering --to codex`) — only needed if you specifically want to run CE skills from a Codex or Gemini session. Defer until you have a concrete reason. The default Claude Code install supports the operator's model preferences (plan in Claude, implementation in Claude, primary review in Claude — see § 7 on model selection).

### 3.2 Run `/ce-setup` in the target repo

```bash
cd ~/repos/<project>/
claude
# then in Claude Code:
/ce-setup
```

`/ce-setup` diagnoses environment, installs any missing tools (`agent-browser`, `gh`, `jq`, `vhs`, `silicon`, `ffmpeg`, `ast-grep` — the skill checks each and offers to install). It also bootstraps `.compound-engineering/config.local.yaml` from a template, and offers to add `.compound-engineering/*.local.yaml` to `.gitignore`.

**Config decisions for our setup:**

- **Leave `work_delegate` unset** (do not enable Codex delegation for implementation; preserves Claude-only implementation per stated preference)
- **Leave `work_delegate_consent` unset** (same reason)
- **Leave `pulse_*` settings unset** — `ce-product-pulse` is deferred (see § 8 Skipped)

The bootstrapped `.compound-engineering/config.local.yaml` is gitignored. The committed `.compound-engineering/config.local.example.yaml` documents available settings.

### 3.3 Record the version pin in the code-wide CLAUDE.md

Add to `~/repos/CLAUDE.md` (existing Tier-2 file loaded by any Claude Code session inside `~/repos/`):

```markdown
## Compound Engineering — Adopted Version

Compound Engineering plugin (Kieran Klaassen / Every Inc) is installed user-level
in Claude Code. Adoption documentation lives at:

 <your-vault> Projects/Agentic Future/Implementation Research/compound engineering/

Start with `03-migration-plan.md`. Pin: v3.8.4 / commit 08bb5899036e9ca33585b38ce840e2b2bfaacac8.

Re-evaluate every 3 months — next review due 2026-08-24.
```

That's the only CLAUDE.md edit during Phase A. Do **not** propagate CE methodology into per-domain CLAUDE.mds (`~/<business>/CLAUDE.md`, `/CLAUDE.md`, etc.) — those continue unchanged. CE is scoped to `~/repos/`.

### 3.3.5 Set up product strategy (per-repo, recommended for Internal+ tier)

CE's `/ce-strategy` creates `STRATEGY.md` at the repo root — a Rumelt-inspired anchor document (target problem / approach / persona / key metrics / tracks). Downstream Core skills (`/ce-ideate`, `/ce-brainstorm`, `/ce-plan`) read it as upstream grounding when it exists. **Adopted as part of the CE Core Set per `04-inventory.md` § 2.0.**

For each CE-piloted repo at project start:

```bash
cd ~/repos/<project>/
claude
# then in Claude Code:
/ce-strategy
```

The skill runs a ~15-20 min structured interview with pushback rules (per `references/interview.md` in CE source) on weak answers. Output: `STRATEGY.md` at repo root.

**When to invoke vs skip:**

- **Invoke at project start** for any repo above throwaway scope (Internal+ tier per `04-inventory.md` § 2.1). The upstream grounding pays off across all subsequent brainstorms + plans.
- **Skip** for Solo throwaway scripts where scope is always obvious. (For imported repos with a pre-existing `docs/vision.md`, that content informs the `/ce-strategy` interview but `vision.md` itself is deprecated — archive to `docs/archive/` after STRATEGY.md exists.)
- **Rerun** when scope shifts materially (new target users, new approach, new metrics) — the skill detects existing `STRATEGY.md` and runs in update mode (Phase 2 of ce-strategy SKILL.md).

This is per-repo, not per-feature. Once `STRATEGY.md` exists, you don't reinvoke per feature — it's a durable anchor. Future-the operator (or future-Claude) walking into the repo cold reads `STRATEGY.md` to understand what the product is + why it exists.

The walkthrough at `05-walkthrough.md` Step 0 prompts for `/ce-strategy` invocation if `STRATEGY.md` is missing.

### 3.4 Pick one feature for the first run

Pick a real upcoming feature with care. Avoid:

- **Too small** — CE has loop overhead (brainstorm → plan → work → compound); a 10-line config change won't exercise the methodology
- **Too big** — first run should land cleanly; save the big strategic bet for after you trust the loop
- **Critical-path under deadline** — let yourself iterate without time pressure

If no upcoming feature fits the goldilocks zone, **pick a refactor or a non-urgent bug fix** that's been bugging you. CE has dedicated paths for both:
- Refactor → use `/ce-work` with a bare prompt or `/ce-brainstorm` if scope is fuzzy
- Bug fix → use `/ce-debug` (which handles trivial bugs with a fast-path and full investigation for non-trivial)

### 3.5 Run the loop

For a normal feature, the workflow:

```text
Step 1 — Brainstorm requirements:
 /ce-brainstorm <one-line feature description>
 
 Produces: docs/brainstorms/<feature>-requirements.md
 With: R-IDs (Requirements), A-IDs (Actors), F-IDs (Key Flows),
 AE-IDs (Acceptance Examples)
 
 CE's brainstorm runs Q&A one question at a time. It will tier-classify
 (Lightweight / Standard / Deep / Deep-product) and right-size accordingly.

Step 2 — Plan implementation:
 /ce-plan docs/brainstorms/<feature>-requirements.md
 
 Produces: docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md
 With: U-IDs (Implementation Units), each traced back to R-IDs/AE-IDs
 
 ce-plan dispatches up to 5 research subagents in parallel, runs a
 confidence check, auto-deepens weak sections, and invokes ce-doc-review
 at Phase 5.3.8 (headless) for plan-quality review.

Step 3 — Execute:
 /ce-work
 
 Reads the latest plan from docs/plans/. Executes against U-IDs with
 idempotency check (won't reimplement work already done). Runs tests
 continuously. Optionally uses worktree isolation for parallel units.
 
 DURING ce-work — when context starts feeling full or before walking
 away from a long session — invoke software-documenter-ce to capture
 the running narrative that CE doesn't capture (trials/errors,
 in-flight pivots, observations):
 
 @software-documenter-ce capture status
 
 Writes: docs/features/<feature>_wip.md (append-only progress log)
 
 This is the compaction-survival bridge. After compaction or in a fresh
 session, /ce-work resumes from the plan + commits + task list, and
 /ce-compound (Step 5) picks up the WIP file as supplementary evidence.
 See § 4 Shape A bridge below.

Step 4 — Ship:
 /ce-commit-push-pr
 
 Adaptive PR description (scales with change complexity: typo gets a
 one-liner; large refactor gets full structure). Body-file safety
 (no empty PR bodies from stdin pipes). Logical commit splitting at
 file level when distinct concerns are present.

Step 5 — Capture learning (when warranted):
 /ce-compound
 
 At Phase 0.5, this auto-scans auto-memory for relevant entries.
 Also pass the WIP file as supplementary context (see § 4 Shape A).
 
 Writes: docs/solutions/<category>/<slug>.md
 Skips silently when the fix is one-off mechanical (no generalizable
 insight). Classifies into bug-track or knowledge-track and uses the
 appropriate section structure.
```

For a bug fix (instead of a feature):

```text
/ce-debug <issue reference, error message, or description>
 → trivial-bug fast-path for typos / missing imports / obvious one-liners
 → full framework for non-trivial bugs (causal chain gate, predictions,
 assumption audit, smart escalation)
 → handles fix + test + PR in one workflow when the user picks
 "Fix it now"
 → optional /ce-compound capture if the bug is generalizable
```

### 3.6 Evaluation after first feature

Two complementary surfaces: a **narrative reflection** (the 5 questions below — for understanding what happened) and a **formal scorecard** (§ 3.6.1 — for keeping the pilot honest at decision points).

**Narrative questions — answer in a few sentences each:**

1. **Did the loop feel natural?** Some friction is expected for first run. Severe friction = something's miscalibrated (wrong tier classification, plan was too thin or too thick, etc.).
2. **Did the artifact chain trace work?** R-IDs in `_requirements.md` → U-IDs in `_plan.md` → U-IDs in commits → AE-IDs referenced in test scenarios. If the IDs are broken, the chain breaks.
3. **Did `/ce-compound` capture a real lesson, or was it ceremony?** CE's design says skip compound for one-off mechanical fixes. If you ran it and the output feels trivial, you should have skipped it.
4. **Did the SD WIP narrative survive compaction?** If you hit compaction mid-feature, did the WIP file carry context across? If not, what got lost?
5. **What did you want that CE didn't do?** Feeds the Phase B Shape-B planning (§ 6.4) and any deferred-skill adoption decisions.

Based on the narrative reflection + the scorecard below: continue adoption (proceed to Phase B), drop specific skills that didn't earn their keep (keep the rest), or revert per § 6.0 if fundamental rethinking is needed.

### 3.6.1 Pilot scorecard

> **Status: Approved 2026-05-25** by the operator. Shape locked (7 Y/N questions + tier-expectation artifact count + methodology overhead estimate + stop/continue criteria + feel-based reflection at checkpoints + structured-vs-feel reconciliation rule). Refine inline if the first scoring pass surfaces a gap.

The scorecard exists to keep the pilot from drifting into sunk-cost adoption. Fill it in after each CE-piloted feature. Evaluate at three checkpoints: **after 1 feature** (early-warning sanity), **after 3 features** (commit / partial-drop / revert decision), **after 1 month or 5 features (whichever comes first)** (sustained-use call).

**Measurement instrumentation for the "≥1 captured solution retrieved/used" continue criterion** (below): "retrieved/used" counts when EITHER (a) you observe the agent's grounding section in a later `/ce-plan` or `/ce-ideate` run cite or paraphrase a prior `docs/solutions/<category>/<slug>.md` entry — note the citation in the new feature's scorecard Q4 notes column with the source slug; OR (b) at a checkpoint, a manual `grep -r "docs/solutions" docs/` or `git log --diff-filter=M -- docs/solutions/` reveals that a prior solution doc was edited / extended / cross-referenced after a subsequent feature shipped (signal of retrieval-and-update via `/ce-compound-refresh` or manual edits). Either signal counts. **Soft fallback:** if neither observable signal fires after 1 month, weaken the criterion to "at least one solution doc is retrievable via Obsidian search and would have helped a feature in retrospect" (judgment call, not auditable).

**Per-feature scorecard (fill in for each CE-piloted feature):**

| # | Question | Y/N | Notes |
|---|---|---|---|
| 1 | Did `/ce-brainstorm` produce a requirements doc you'd refer back to (not ceremony)? | | |
| 2 | Did `/ce-plan`'s U-IDs survive into commit messages and trace cleanly? | | |
| 3 | Did `/ce-work` execute against the plan without you having to override or re-plan mid-flight? | | If overrides: how many, and why? |
| 4 | Did `/ce-compound` produce a `docs/solutions/` entry you'd want a future session to find? (Or did you correctly skip it because the work wasn't generalizable?) | | |
| 5 | Did SD's WIP narrative (via Shape A) get pasted into `/ce-compound` when the feature warranted it? | | (Signal for Shape B trigger — see § 4) |
| 6 | Total durable artifacts produced for this feature | | Compare to tier expectation per § 2.5 Artifact Proportionality Rule (Solo: 0-2; Internal: 3-5; Public: full chain when warranted) |
| 7 | Total wall-clock time spent on methodology overhead (estimate, in minutes) | | Excludes actual coding time; includes brainstorm / plan / artifact writing / review reading |

**Stop / re-evaluate criteria (any one fires → pause pilot, hold the next-feature decision):**

- 3 consecutive features where >2 scorecard questions are N
- Total methodology overhead exceeds 30% of total feature time (estimate)
- A specific CE skill produces more friction than value across 2+ features → drop that skill, continue with the rest (partial drop, not full revert)
- A captured `docs/solutions/` entry has never been retrieved by `/ce-plan`, `/ce-ideate`, or `/ce-debug` after 1 month of subsequent CE use (the compounding mechanism isn't firing — see § 9 re-evaluation)

**Continue criteria (all must hold after 3 features for confident sustained adoption):**

- Majority of scorecard Y/N questions are Y across the 3 features
- At least one captured `docs/solutions/` entry has been retrieved / used by `/ce-plan` or `/ce-ideate` in a subsequent feature
- Methodology overhead feels proportionate to the work (rough cap: Solo <15%, Internal <25%, Public <30%)
- The artifact count per feature is within tier-expected range (no ceremony creep — see § 2.5)

**Checkpoint reflection — feel-based questions (3-feature AND 1-month checkpoints):**

The Y/N scorecard above catches mechanical drift. These free-text questions catch "boxes are checked but it's not working for me." Answer in a few sentences each, at the 3-feature checkpoint AND again at the 1-month / 5-feature checkpoint:

1. **Effective + efficient shipping?** Do I feel like I'm effectively and efficiently shipping software using this methodology?
2. **Proper documentation?** Do I feel like the methodology is producing proper documentation — CE artifacts (plan + PR description + solution doc) + ship docs (README, AGENTS.md or CLAUDE.md Components per shim, ISSUES, CHANGELOG, user doc) + reference docs, all surviving in my Obsidian-vault-of-repos for future cold-context reading?
3. **Compared to my previous methodology?** Compared to my pre-CE methodology (`@software-documenter feature complete` doing the documentation autonomously in one shot), do I feel like this is working for me — better, worse, comparable, different-but-OK?
4. **Keep vs drop?** What changed in how I'm working that I'd want to keep? What would I drop?

Capture answers verbatim in `docs/ce-pilot-3feature-review.md` (at 3-feature checkpoint) and `docs/ce-pilot-1month-review.md` (at 1-month / 5-feature checkpoint). These files are for future-you to read at the 3-month re-evaluation per § 9.

**Reconciliation between structured criteria and feel-based reflection:**

| Y/N scorecard | Feel-based reflection | Read |
|---|---|---|
| Passing | Working | Confident sustained adoption — proceed to Phase B work |
| Passing | **Not working** | Gut-check wins — investigate the gap (something structured isn't catching). Pause to understand before continuing |
| **Failing** | Feels OK | Don't let optimism override the structured signal — partial-drop or revert per § 6.0 |
| **Failing** | Not working | Revert (no ambiguity) per § 6.0 |

The walkthrough at `05-walkthrough.md` Steps 9a (3-feature review) and 9b (1-month / 5-feature sustainability checkpoint) operationalizes both the structured criteria + feel-based reflection — the agent prompts these questions at the right moments.

**At the 1-month / 5-feature checkpoint, also evaluate:**

- Is `/ce-compound`'s grep-first retrieval starting to compound? Are old entries getting retrieved + acted on by current work? If no compounding signal after 5 features, the mechanism isn't firing for this use pattern.
- Phase B readiness: has B1 (QMD `code-solutions` collection) become useful enough to build? Trigger: cross-repo retrieval would have helped on N+ features.

The scorecard is the structured pass/fail surface; the narrative questions above capture the human read. Both are inputs to the keep / partial-drop / revert decision.

---

## 4. The Shape A bridge — software-documenter WIP → /ce-compound

CE doesn't capture mid-implementation narrative — the trials and errors, the in-flight pivots, the "I tried X, switched to Y because Z" running journal. CE assumes the plan is sharp enough that execution is mostly straight-line.

The operator's existing `software-documenter capture learnings` does capture this. Its output at `docs/features/<feature>_wip.md` is the **compaction-survival narrative**. We preserve this by routing the WIP content into CE's compounding pipeline.

**Shape A (passive bridge — adopted in Phase A):** at `/ce-compound` invocation time, pass the WIP file path as supplementary context. CE's `ce-compound` has Phase 0.5 "Auto Memory Scan" — it already incorporates supplementary evidence (auto-memory excerpts) into the Solution Extractor and Context Analyzer subagents. The WIP file fits the same pattern: supplementary evidence, tagged `(execution journal)` in the final solution doc.

**Implementation in Phase A — manual paste:**

When invoking `/ce-compound` at feature-complete time, paste relevant WIP content into the invocation context. Something like:

```text
/ce-compound

Supplementary context from execution journal at docs/features/<feature>_wip.md:

 [paste relevant excerpts — failed approaches, in-flight pivots, observations]

Use this as supplementary evidence in Phase 0.5, tagged as "execution journal"
in the Context Analyzer and Solution Extractor inputs.
```

This works without modifying CE. The Solution Extractor reads it as input and folds relevant parts into "What Didn't Work" (bug-track) or "Context" (knowledge-track).

**Implementation in Phase B — automatic:** modify `software-documenter` to make this seamless, or add a thin wrapper. Documented in § 6.2.

**Shape B (active bridge — deferred unless triggered):** a new SD verb `compound my wips` that scans WIPs across recent features and proposes batch transfers to CE artifacts. See § 6.4 for the triggers that would justify building this.

---

## 5. Codex review skill — fixes applied 2026-05-24, role unchanged

**Prerequisite status (per § 3.0):** the `codex-review` skill at `~/.claude/skills/codex-review/SKILL.md` had six known failure modes documented in `capabilities/04-codex-capabilities.md`. Those fixes were applied 2026-05-24 along with three Codex-review-suggested cleanups (honest governance language about ChatGPT Pro caps, CE-era workflow integration pointer, data-sanitization reminder before paste). Backup at `~/backups/pre-codex-skill-fixes-2026-05-24/SKILL.md.orig`. **Phase A invokes Codex via the updated skill; the prerequisite is satisfied.**

The skill's *role* is unchanged. It serves a different purpose from CE's `ce-code-review`:

| Skill | Role | Stage | Model |
|---|---|---|---|
| `codex-review` (existing) | Cross-model adversarial second opinion | Plan review pre-implementation, or sanity check on diff | Codex (OpenAI, different family from Claude) |
| `ce-code-review` (CE) | Structured multi-persona in-Claude review | Post-implementation diff review | Inherits parent session model (Claude Opus for us) |
| `ce-doc-review` (CE) | Persona review of brainstorm/plan docs | After brainstorm; after plan | Same as ce-code-review |

Recommended workflow: use `codex-review` at plan-review time (cross-model adversarial check on the plan). Use `ce-code-review` post-implementation (multi-persona structured review on the diff). They target different artifacts at different stages — no conflict.

Cross-tool dispatch from Claude Code is not possible for CE personas — `ce-code-review` doesn't have built-in delegation to Codex or Gemini. If you specifically want Gemini-flavored review, the path is: install CE for Gemini (`bunx @every-env/compound-plugin install compound-engineering --to gemini`) and run `/ce-code-review` from a Gemini session. This is a context-switch tax; defer unless Gemini-specific perspective is genuinely valuable.

For full details on model selection, see § 7 below.

---

## 6. Phase B — integration enhancements (deferred until Phase A evaluation)

Don't start Phase B until Phase A has 1-2 features successfully shipped through the loop. Phase B items are deliberate enhancements that connect CE more deeply with the existing OS-level system. They're documented here so the design intent isn't lost between sessions.

**Priority within Phase B:** B1 (QMD cross-repo solutions discovery) is the highest-leverage and lowest-cost. It can move as soon as one feature has shipped through CE and `docs/solutions/` has its first entry worth retrieving cross-repo — earlier than the others. B2 (SD scope reduction) depends on Phase A landing fully and CE's `ce-work` / `ce-commit-push-pr` / `ce-compound` proving themselves. B3 (skill-builder reference adoption) is zero-effort (the user-level plugin install brings those skills automatically) and can happen anytime — consult those references when building new your custom skills. B4 (Shape B bridge) is conditional on the documented triggers firing during Shape A use.

### 6.0 Reversibility — back up before Phase B edits

> **Complementary doc:** this section handles **live-artifact** revert (plugin uninstall, SD-CE variant file removal, codex-review skill restore, CE-created `docs/brainstorms/` / `docs/plans/` / `docs/solutions/` deletion). For **propagated-update** revert (restoring pre-CE state of the 17 existing Implementation Research docs touched by CE adoption), see [`the propagation plan § 6`](the propagation plan). Together they cover the full revert surface.

Phase B touches live files in the existing methodology:

- `~/.claude/agents/software-documenter.md` (scope reduction in B2)
- `~/.claude/skills/doc-structure/SKILL.md` (potential changes if SD's reduced scope affects the 4-type doc lifecycle)
- `~/.claude/skills/recall/SKILL.md` (potential updates for B1 if cross-repo solutions surface as a `SOLUTIONS` mode)
- `~/.config/qmd/index.yml` (B1 adds the `code-solutions` collection)

Before each Phase B edit, snapshot the affected files so a clean per-file revert is possible **without rolling back unrelated git history**.

Procedure:

```bash
# Before any Phase B edit:
BACKUP_DIR="$HOME/backups/pre-ce-phase-b-$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# Copy affected files (adjust per edit):
cp ~/.claude/agents/software-documenter.md "$BACKUP_DIR/"
cp ~/.claude/skills/doc-structure/SKILL.md "$BACKUP_DIR/"
cp ~/.config/qmd/index.yml "$BACKUP_DIR/"

# Now apply edits, test, then if revert needed for a specific file:
cp "$BACKUP_DIR/software-documenter.md" ~/.claude/agents/
```

Git history is the primary safety net (these files are tracked under your dotfiles repo). The per-edit snapshot is the secondary safety net for cherry-picked revert of one file without rolling back unrelated edits made in the same session.

**Phase A touches existing files in two distinct passes** — both with backup procedures:

1. **For imported repos (pre-existing):** Prerequisite 4 above mandates a Pre-`/ce-setup` audit of the 5 in-scope project-level docs (CLAUDE.md / README / CHANGELOG / ISSUES / docs/architecture.md, plus AGENTS.md if present, plus docs/vision.md and docs/operations.md for deprecation handling). The audit strips fictional content and restructures CLAUDE.md → AGENTS.md + shim where applicable. Backup before editing per Prereq 4's procedure. This is per-imported-repo and one-time.

2. **For all Phase A repos:** a single-line addition to `~/repos/CLAUDE.md` (the version pin) per § 3.3. That line can be reverted with a manual edit; no backup procedure needed for that specific edit.

**Full-rollback procedure** — if after 1-2 Phase A features CE doesn't justify the ceremony per the evaluation criteria in § 3.6:

```bash
# 1. Uninstall the plugin (in Claude Code):
# /plugin uninstall compound-engineering

# 2. Remove the version-pin line from ~/repos/CLAUDE.md (manual edit).

# 3. The four compound engineering/ docs can stay or be deleted —
# they're reference material, not active config. If staying,
# mark status as 'considered-not-adopted' in their frontmatter.

# 4. SD scope changes only apply in Phase B, so if you didn't reach
# Phase B, no SD revert is needed.
```

CE is genuinely uninstallable — Kieran designed the plugin as installable, not entangled. The OS-level system (life domains, vaults, /recall, todos, life-domain capture agent, multi-machine sync) is untouched by Phase A and is partially touched by Phase B's B1 (QMD config change) and B2 (SD reduction) only — both revertible via the snapshot procedure above.

### 6.1 B1 — QMD cross-repo solutions discovery

**Problem:** CE's `docs/solutions/` is per-repo. A `docs/solutions/<category>/rate-limiting-pattern.md` entry in repo A won't surface when working in repo B that hits the same need. CE's `ce-learnings-researcher` agent greps the current repo only.

**Fix:** index all repos' `docs/solutions/` paths as a fourth QMD collection.

Add to `~/.config/qmd/index.yml`:

```yaml
collections:
 code-solutions:
 paths:
 - ~/repos/*/docs/solutions/
 frontmatter_indexed:
 - tags
 - module
 - problem_type
 - title
 - category
```

Then re-index:
```bash
qmd update && qmd embed
```

Update `/recall` skill to include `code-solutions` in its default topic-search collection list (alongside `personal`, `agent`, `sessions`). Or expose as an explicit mode keyword: `/recall SOLUTIONS <topic>`.

After this:
- CE's per-repo `ce-learnings-researcher` continues to work as designed (greps the current repo's solutions)
- `/recall` provides the cross-repo retrieval layer for solutions
- Truly cross-life-domain learnings (e.g., cross-life-domain coordination patterns and reflections) continue to live in `<your-vault>` — that location is for **cross-life-domain knowledge ONLY**, never software-development learnings. Software-stack-wide conventions (e.g., "always use bun not npm" applies across multiple Python repos) live in `~/repos/CLAUDE.md` Tier-2 file, not agent vault. See the methodology comparison in the share repo README § 4.2 + § 6.3 for the full routing rules.

**Effort:** ~30 minutes. No CE fork required.

### 6.2 B2 — Software-documenter scope reduction

**Goal:** reduce software-documenter to the modes CE doesn't replace, retire the rest.

**Keep (reduced SD scope):**
- `@software-documenter capture learnings` / `save progress` — writes `docs/features/<feature>_wip.md`. The compaction-survival narrative. CE has no equivalent.
- `@software-documenter create reference doc` — writes `docs/<feature>_reference.md`. Cold-context kickstart material for future sessions / future contributors. CE doesn't produce this; closest is the PR description + the `docs/solutions/` entry, but neither is a self-contained per-feature reference doc.

 **When to create a reference doc:**
 - **Required when:** feature has multiple interacting components; feature has operational/debugging complexity; feature will be extended later; feature has both user-facing behavior and internal machinery; future agents will need a cold-start map of how this feature works
 - **Optional / skip when:** small isolated change; no new concept introduced; code is self-explanatory; CE artifacts (plan, PR description, solution doc) already capture enough for future cold-start

- `@software-documenter update changelog` — **kept as lightweight optional mode.** Revised position: PR descriptions cover per-feature narrative (review-time artifact); CHANGELOG.md covers chronological project memory and release history (release-time artifact). Different purposes. For long-running tools or repos that already maintain a CHANGELOG.md, keep both — the CHANGELOG gives scannable one-place project history that PR descriptions don't. For short-lived or throwaway repos, PR descriptions alone are sufficient. SD's `update changelog` mode stays available; the *requirement* to use it is what's gone.

**Retire:**
- `@software-documenter feature complete` / `ship it` — CE's `/ce-work` Phase 4 + `/ce-commit-push-pr` + `/ce-compound` covers this with more discipline (adaptive PR descriptions, operational validation, discoverability check, bug-track/knowledge-track classification, overlap detection)
- `@software-documenter archive WIP` — file lifecycle moves to CE; `/ce-work` handles its own artifact movement

**Edits required:**
- `~/.claude/agents/software-documenter.md` — remove feature-complete / update-changelog / archive-WIP verb routing from "Argument-Based Routing"; remove the lifecycle steps that depend on them
- Add explicit note in SD body: "this agent operates inside repos adopting Compound Engineering. Feature finalization is handled by `/ce-work` Phase 4 + `/ce-commit-push-pr` + `/ce-compound`. SD's role is WIP narrative capture and reference-doc generation only."
- Document the Shape A WIP → ce-compound bridge in SD's body

**Effort:** ~1-2 hours.

### 6.3 B3 — ce-agent-native-architecture as skill-builder reference

CE ships `ce-agent-native-architecture` — a tutor/reference skill with 14 reference files covering aspects of building agent-native applications (architecture patterns, MCP tool design, system prompt design, dynamic context injection, action parity discipline, self-modification, mobile patterns, testing, refactoring, checklists). It's structured as an intake: pick one of 14 dimensions and the relevant reference loads.

Relevant for the operator because the operator builds skills (`recall`, a vault-write skill, `todos`, a life-domain capture agent, etc.). The reference patterns apply to Claude Code skills, not just full agent-native apps.

Most-relevant subset for skill-building:
- `system-prompt-design.md` — features as prompts, judgment criteria
- `mcp-tool-design.md` — primitive tools, dynamic capability discovery, CRUD completeness
- `dynamic-context-injection.md` — runtime context injection
- `action-parity-discipline.md` — capability mapping
- `checklists.md` — architecture checklist, anti-patterns, success criteria

Companion skill: `ce-agent-native-audit` — runs scored audit against the five core principles (Parity, Granularity, Composability, Emergent Capability, Improvement Over Time). Useful for auditing existing your custom skills to find improvement opportunities.

**Adoption is zero-effort if CE is installed user-level** — both skills become available immediately. The question is when to consult them. Suggested triggers:
- Before building a new custom skill, run `/ce-agent-native-architecture` and pick the relevant reference
- Periodically (quarterly?) run `/ce-agent-native-audit` against an existing the operator skill to find improvement opportunities

### 6.4 B4 — Shape B bridge (deferred until triggers fire)

Shape B is an active bridge skill: `@software-documenter compound my wips` (or a new dedicated skill). It would:

1. Scan `docs/features/<feature>_wip.md` files for unprocessed content
2. Classify WIP content into transferable categories:
 - "What didn't work mid-implementation" → bug-track "What Didn't Work" input
 - Design rationale for in-flight pivots → knowledge-track "Context" + "Why This Matters"
 - Reusable patterns observed → knowledge-track "Guidance"
 - Compaction-survival narrative without generalizable insight → skip
3. Propose batch transfers (one approval per transfer)
4. Invoke `/ce-compound` per approved transfer with assembled context

**Triggers for considering building Shape B (any one is sufficient):**

- You find yourself wanting to batch-compound across multiple WIPs from a recent stretch of work
- Shape A's passive "WIP as supplementary evidence at `/ce-compound` time" is missing content that should compound (you keep manually copying WIP excerpts into separate `/ce-compound` runs)
- You want to compound WIP content mid-feature, before feature-complete
- You're shipping enough features that the SD-then-compound workflow benefits from automation

**If none of these triggers fire after 3+ months of CE use, don't build Shape B.** Sometimes simple wins.

---

## 7. Model selection — Claude / Codex / Gemini

### 7.0 Data handling when sending content to external models

A minimal data-handling rule applies to ANY content sent to a non-Claude model (Codex, Gemini, future ce-* skills calling external tools). One page; no heavy policy — just the floor:

- **No secrets in external prompts.** API keys, OAuth tokens, passwords, signing keys never get pasted into Codex / Gemini / external-tool prompts. If a code snippet contains hardcoded secrets, redact before pasting OR point the tool at a sanitized file on disk instead of pasting.
- **No customer PII.** User emails, names, personal addresses, payment data don't go into external tool prompts. Use synthetic equivalents or redact.
- **No internal hostnames or private IPs.** `192.168.x.x`, Tailscale `100.x.x.x`, `*.local` / `*.internal` domains stay local.
- **Prefer pointing at files over pasting content.** Codex with `--sandbox read-only` reads files directly from the filesystem; you don't ship file content over the network from your side. The `codex-review` skill body covers this pattern in detail (see `~/.claude/skills/codex-review/SKILL.md § Data Sanitization Before Pasting`).
- **When uncertain.** Write the content to a sanitized scratch file on disk, then point the tool at that file.

Scope: applies to Codex (via codex-review skill), Gemini (if/when adopted via `bunx @every-env/compound-plugin install compound-engineering --to gemini`), and any future CE or non-CE skill that talks to a non-Claude external service. Doesn't apply to Claude (same trust boundary as the rest of the system).

This rule is at the CE-plan level (not just inside individual skill bodies) so it travels with the methodology rather than being re-invented in each external-tool skill — see `codex-review-round2-2026-05-25.md` Q4 for the rationale (Codex pushback in Round 2; accepted).

### 7.1 What CE supports natively

Every CE persona reviewer has `model: inherit` in its frontmatter. **The persona uses whatever model the parent session is running.** So:

- Running `/ce-code-review` from a Claude Code session → all 6+ personas run on Claude (whichever Claude model the session uses, typically Opus 4.7)
- Running `/ce-code-review` from a Codex session (after `bunx @every-env/compound-plugin install compound-engineering --to codex`) → personas run on the active Codex model
- Running `/ce-code-review` from a Gemini session (similar install) → personas run on Gemini models

You cannot, from within Claude Code, dispatch CE's reviewer personas to Codex or Gemini. There is no cross-tool delegation in `ce-code-review`.

### 7.2 What CE does NOT support: cross-tool review dispatch from Claude

A few skills override the default model intentionally — but none for review:

- `ce-simplify-code` forces Sonnet (mid-tier) for its 3 reviewers regardless of parent model — pure cost optimization
- `ce-work-beta` has explicit Codex delegation for **implementation** (not review) via `work_delegate: codex` config

There is no `ce-code-review` equivalent that says "dispatch personas to Codex from a Claude session."

### 7.3 Practical setup matching the operator's preferences

Stated preferences: plan in Claude Opus, implementation in Claude (no Codex), primary review in Claude, occasional second opinion via Codex or Gemini.

| Task | Tool | Path | Config |
|---|---|---|---|
| Brainstorm | Claude | Default | None |
| Plan | Claude Opus | Default | None |
| Implementation | Claude | Default | Do NOT set `work_delegate: codex` |
| Primary code review | Claude | `/ce-code-review` from Claude Code | None |
| Cross-model second opinion (Codex) | Codex | `codex-review` skill ships content to Codex while you stay in Claude Code | Existing skill; no change |
| Gemini code review (rarely needed) | Gemini | Install CE for Gemini, switch to Gemini session for those reviews | Defer; only if specifically wanted |

**A fresh agent's answer to "how do I do code review with Codex?":**
- Use the existing `codex-review` skill from Claude Code (no context-switch; ships content to Codex; returns findings as a structured report). This is the practical answer for almost all cases.
- Alternative: install CE for Codex and run `/ce-code-review` from a Codex session. Higher overhead (separate context). Only worth it if you want Codex's full multi-persona pass on the diff specifically.

**A fresh agent's answer to "how do I do code review with Gemini?":**
- No `gemini-review` skill exists yet. The path is install CE for Gemini and run `/ce-code-review` from a Gemini session.
- Building a `gemini-review` skill analogous to `codex-review` is a deferred enhancement (no concrete trigger fired yet).

---

## 8. Skipped — what we deliberately don't adopt (and why)

| Skill | Reason |
|---|---|
| `/ce-product-pulse` | No production telemetry on any current repo. Adopt when first repo has real users + analytics (PostHog, Sentry, etc.) configured. |
| `/ce-sessions` | The existing `/recall` skill with sessions search across `personal` + `agent` + `sessions` collections is superior for our use case (cross-machine, cross-vault). CE's `ce-sessions` is single-machine, single-harness. |
| `/ce-optimize` | No measurement-driven optimization need has surfaced. Adopt when a specific optimization problem (clustering quality, search relevance, perf tuning) actually exists. |
| `/lfg` (full autonomous chain) | Defer until base loop has been battle-tested for 3+ features. The autonomous chain compounds errors if any step is miscalibrated. |
| `ce-frontend-design`, `ce-dhh-rails-style`, `ce-julik-frontend-races-reviewer`, `ce-swift-ios-reviewer` | Wrong stack — the operator's repos are primarily Python. Adopt when those frameworks come in. |
| `ce-test-xcode` | iOS only. Skip. |
| `ce-proof`, `ce-riffrec-feedback-analysis` | Every-Inc-specific tools (Proof = Every's collaborative editor; Riffrec = Kieran's recording tool). Skip. |
| `ce-polish-beta`, `ce-dogfood-beta`, `ce-work-beta` | Beta skills. Adopt when stable and a concrete need surfaces. |
| `ce-gemini-imagegen` | Image generation. Skip unless needed for a specific repo. |
| `ce-update`, `ce-release-notes`, `ce-report-bug` | Plugin maintenance skills — they activate when needed via the marketplace install. No separate adoption decision. |
| `ce-demo-reel`, `ce-test-browser` | Adopt per-repo if visual evidence or browser testing is required. Not blanket-adopted. |
| `ce-slack-research` | Useful for <business> life-domain work, but Slack MCP setup is a separate prerequisite. Defer. |

---

## 9. Re-evaluation cadence

**Every 3 months.** Next review: **2026-08-24**.

Add a recurring entry in `<your-vault> Todo/AI.md`:

```markdown
- [ ] Re-evaluate Compound Engineering adoption against upstream 📅 2026-08-24 🔁 every 3 months
```

### 9.1 What to do at each re-evaluation

1. **Check current CE version**:
 ```bash
 gh release list --repo EveryInc/compound-engineering-plugin --limit 10
 ```
2. **Read CHANGELOG entries since the pinned commit.** Look for: new skills, materially-changed skills, retired skills, breaking changes.
3. **For each new skill or material change**: relevant to our adoption? Worth adopting? Skipping with a reason? Update § 4-8 of this doc.
4. **Review Phase B status**: anything deferred that should now be Phase A? Anything skipped where a trigger has fired?
5. **Review § 8 Skipped list**: any triggers actually fired? (E.g., new repo has real users → adopt `ce-product-pulse`. New repo is Rails → adopt `ce-dhh-rails-style`.)
6. **Update version pin**: this doc's frontmatter `ce_reference_version` + `ce_reference_commit`, and the line in `~/repos/CLAUDE.md`.

### 9.2 Upgrade decision

Upgrading the plugin is its own decision. CE auto-updates if you run `/ce-update` (which it announces during `/ce-setup`). Recommended cadence:

- **Patch upgrades** (e.g., v3.8.4 → v3.8.5): adopt freely, low risk
- **Minor upgrades** (e.g., v3.8.x → v3.9.0): read the CHANGELOG; usually safe but check for new skills or changed contracts
- **Major upgrades** (e.g., v3.x → v4.0.0): treat as a re-adoption decision; read the migration notes, evaluate impact, possibly stay on the pinned version for a release cycle

---

## Appendix — Artifact map across both systems

With CE adopted inside repos and SD reduced to WIP + reference-doc + optional CHANGELOG roles, the full artifact landscape:

| Artifact | Owner | Purpose | Permanence | Location | When created |
|---|---|---|---|---|---|
| `STRATEGY.md` | CE (`/ce-strategy`) | Product anchor — target problem / approach / persona / metrics / tracks. Read by `/ce-ideate`, `/ce-brainstorm`, `/ce-plan` as upstream grounding | Permanent (rerun on material scope shifts) | Repo root | Once per repo at project start (per § 3.3.5 + `05-walkthrough.md` Step 0) |
| `docs/brainstorms/<feature>-requirements.md` | CE (`/ce-brainstorm`) | Right-sized requirements doc with R/A/F/AE-IDs | Semi-permanent; archived if scope changes radically | Per-repo `docs/brainstorms/` | At brainstorm time |
| `docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md` | CE (`/ce-plan`) | Implementation plan with U-IDs traced to R/AE-IDs | Semi-permanent | Per-repo `docs/plans/` | At plan time |
| `docs/features/<feature>_wip.md` | `@software-documenter-ce capture status` | Execution journal / compaction-survival narrative + Shape A input for `/ce-compound` | Transient → preserved as historical record (CE doesn't archive) | Per-repo `docs/features/` | During execution, append-only |
| PR description (in GitHub) | CE (`/ce-commit-push-pr`) | Adaptive ship narrative scaled to change complexity; includes Post-Deploy Monitoring & Validation section | Permanent on GitHub | GitHub PR body | At ship time |
| `docs/solutions/<category>/<slug>.md` | CE (`/ce-compound`) | Reusable lesson with bug/knowledge-track structure + frontmatter for grep-first retrieval | Permanent | Per-repo `docs/solutions/` | Post-ship, only when generalizable (see `04-inventory.md` § 6.5) |
| `README.md` (feature entry) | `@software-documenter-ce ship docs` | User-facing project overview — features / components index | Permanent | Repo root | At ship time, when feature is user-facing or adds a component |
| Substantive instruction file Components table (AGENTS.md primary; CLAUDE.md fallback) | `@software-documenter-ce ship docs` | Compact one-line-per-component table for session-start context. Stays in sync with README's components/features section. SD-CE detects target file by filesystem: AGENTS.md if present (CE-pilot `@AGENTS.md` shim pattern), else CLAUDE.md. | Permanent | Per-project AGENTS.md (CE-piloted) or CLAUDE.md (legacy) | At ship time, when a new component is added |
| `ISSUES.md` (move resolved entries) | `@software-documenter-ce ship docs` | Track resolved issues with resolution date + feature reference | Permanent (if project maintains ISSUES.md) | Repo root | At ship time, when feature resolves open issues |
| `CHANGELOG.md` (entry for the feature) | `@software-documenter-ce ship docs` (CE repos — handled intelligently per agent body: update if exists; create if warranted; skip if throwaway) OR `@software-documenter update changelog` (non-CE repos, or CE repos with non-standard CHANGELOG format) | Chronological project memory / release history (Current Focus / Recent Updates / Version History / Decision Log) | Permanent (when project keeps one) | Repo root | At ship time |
| `docs/<feature>.md` (user doc) | `@software-documenter-ce ship docs` | User-facing feature doc with usage guide | Permanent | Per-repo `docs/` | At ship time, when feature is user-facing AND needs end-user guidance |
| `docs/<feature>_reference.md` | `@software-documenter-ce reference doc <instruction>` (user-directed) | Cold-context kickstart material for feature internals. Can be new file OR new section in existing reference doc | Permanent | Per-repo `docs/` | Situational per `05-walkthrough.md` Step 7 |
| `docs/features/<feature>_scorecard.md` | the operator via `05-walkthrough.md` Step 8 (operator-captured; agent assists with formatting) | Per-feature pilot scorecard — 7 Y/N questions + tier-expectation artifact count + methodology overhead estimate. Source of truth for Phase A evaluation per § 3.6.1 stop / continue criteria | Permanent | Per-repo `docs/features/` | After every CE-piloted feature ships |
| `docs/ce-pilot-3feature-review.md` | the operator via `05-walkthrough.md` Step 9a (operator-captured) | 3-feature checkpoint review combining structured continue criteria + feel-based reflection (see § 3.6.1 reconciliation table). Decision artifact: continue / partial-drop / revert | Permanent | Per-repo `docs/` | Once per repo at 3-feature checkpoint |
| `docs/ce-pilot-1month-review.md` | the operator via `05-walkthrough.md` Step 9b (operator-captured) | 1-month or 5-feature sustainability checkpoint combining all per-feature scorecards + feel-based questions about effective shipping / proper documentation / methodology comparison. Read at 3-month re-evaluation per § 9 | Permanent | Per-repo `docs/` | Once per repo at 1-month / 5-feature checkpoint |
| `<your-vault>` | `@software-documenter-ce` (`capture status` updates Recent Activity; `ship docs` updates Recent Decisions on ship) for CE repos; original SD for non-CE repos | Thin cross-project status summary readable by `/recall` | Updates over time | Agent vault | At capture-status time + at ship-docs time |
| `<your-vault>` | life-domain capture agent | Cross-life-domain wisdom only — meetings, decisions, people patterns, life-domain conventions. **Software learnings never land here** — they route to per-repo `docs/solutions/` (CE) or repo `docs/` (non-CE). See the methodology comparison in the share repo README § 4.2 + § 6.3. | Permanent | Agent vault | When a session surfaces a cross-life-domain (non-software) insight |
| `code-solutions` QMD collection (Phase B B1, deferred) | QMD config | Indexes all repos' `docs/solutions/` for cross-repo `/recall` retrieval | Index, not artifact | QMD daemon | At `qmd embed` cadence |
| `docs/pulse-reports/YYYY-MM-DD_HH-MM.md` (deferred — § 8) | CE (`/ce-product-pulse`) | Time-windowed product telemetry report | Permanent timeline | Per-repo `docs/pulse-reports/` | Only when production telemetry exists |

**Use this table as the single reference for "which artifact belongs where".** When a session is producing multiple artifacts, check that each one has a clear owner and purpose. Duplication between artifacts (e.g., reference doc restating PR description content) is the warning sign of over-production — see § 2.5 (Artifact Proportionality Rule).

Not every artifact applies to every feature. Per-tier defaults in `04-inventory.md` § 2 spell out which artifacts to typically produce at Solo / Internal / Public tiers.

---

## 10. Where to look next

- **`04-inventory.md`** — per-skill adoption status (every CE skill with status: adopt / reference / defer / skip), plus per-tier (solo / internal / public) invocation cheat sheets
- **`01-overview.md`** — what CE is as a system (architecture, primitives, the compounding mechanism, the artifact chain with stable IDs, mode tokens, the persona-selection logic)
- **the methodology comparison in the share repo README** — how CE relates to the existing the operator methodology: overlaps, complementarities, novel ideas on each side, where the bridges sit (including the Shape A / Shape B detail)
- **`00-readme.md`** — folder index

For a fresh agent: typical reading order is `03 (here) → 04 → 01 → 02`.

---

*Last updated: 2026-05-27. Pinned CE version: v3.8.4 / commit `08bb5899036e9ca33585b38ce840e2b2bfaacac8`. Next re-evaluation: 2026-08-24.*
