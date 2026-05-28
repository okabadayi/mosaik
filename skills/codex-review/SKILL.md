---
name: codex-review
description: Invoke Codex as a second-opinion reviewer for plans, implementations, bugs, and architecture decisions. Integrates with the doc-structure methodology.
---

# Codex Review — Second-Opinion Skill

Use OpenAI Codex CLI as a reviewer and second opinion alongside Claude Code. Codex reviews; it never implements. Claude Code assembles context, invokes Codex, digests the response, and presents findings.

> **Philosophy**: Codex is a tool, not an agent. Keep invocations purposeful — don't call Codex for trivial tasks. ChatGPT Pro has usage caps; the Troubleshooting section covers the swap-account procedure when 429s hit.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [When to Invoke Codex](#when-to-invoke-codex)
3. [When NOT to Invoke Codex](#when-not-to-invoke-codex)
4. [Invocation Patterns](#invocation-patterns)
   - [Standard Invocation (via Bash)](#standard-invocation-via-bash)
   - [Signal Handling & Session Safety](#signal-handling--session-safety)
   - [Data Sanitization Before Pasting](#data-sanitization-before-pasting)
   - [Context Loading — Two-Phase Pattern](#context-loading--two-phase-pattern)
5. [Use Cases & Prompt Templates](#use-cases--prompt-templates)
6. [Output Handling](#output-handling)
7. [Session Management](#session-management)
8. [Integration with Development Methodology](#integration-with-development-methodology)
9. [Governance](#governance)
10. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)
11. [Troubleshooting](#troubleshooting)
12. [See Also](#see-also)

---

## Quick Reference

| Item | Value |
|------|-------|
| CLI | `codex` (v0.98.0+ — older versions have known hangs without modern fixes; check `codex --version`) |
| Model | `gpt-5.3-codex` |
| Reasoning effort | `high` (default for review work; `medium` for routine; `low` is rarely useful) |
| Auth | ChatGPT Pro (device-auth via `codex login --device-auth`, stored in `~/.codex/auth.json`) |
| MCP server | Registered as `codex` in Claude Code (`codex mcp-server`) |
| Sandbox | Always `--sandbox read-only` |
| Output format | Always `--json` (structured, has `reasoning_tokens` + `completion_tokens` for completion detection) |
| Output capture | Always `> /tmp/codex-<slug>.out 2>&1 &` (stderr merged, NOT suppressed; backgrounded so Esc on the parent doesn't kill the run) |
| Timeout | Always wrap with a Monitor or `pgrep` watch (see "Invocation Patterns" §). No bare `codex exec` without one. |

### Key Command

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<prompt>" > /tmp/codex-<slug>.out 2>&1 &
```

Always pair with a `pgrep`-based watch loop — see [Signal Handling & Session Safety](#signal-handling--session-safety). Never invoke bare `codex exec` without backgrounding and output capture.

---

## When to Invoke Codex

Invoke Codex when a second perspective adds real value:

- **Plan review** — After creating a feature plan, before implementation begins
- **Implementation review** — At meaningful checkpoints or before shipping (SD's "feature complete" or CE's `/ce-commit-push-pr` + `/ce-compound`)
- **Stuck / debugging** — When blocked on a problem and need a fresh diagnostic perspective
- **Architecture decision** — Facing a non-trivial design choice with multiple valid approaches
- **the user explicitly asks** — "Get Codex's opinion on this"

**Rule of thumb**: If you'd want a senior colleague to glance at something before proceeding, invoke Codex.

## When NOT to Invoke Codex

- Trivial changes (typo fixes, single-line edits, config tweaks)
- Tasks you're highly confident about
- Quick research tasks (use web search instead)
- When the user indicates Pro subscription usage is running low
- Rapid iteration cycles where feedback latency would slow things down

---

## Invocation Patterns

### Standard Invocation (via Bash)

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "YOUR PROMPT HERE" > /tmp/codex-<slug>.out 2>&1 &
```

- `--sandbox read-only` — Codex can read files but never modify anything
- `-m gpt-5.3-codex` — Explicit model selection
- `-c model_reasoning_effort="high"` — High thinking mode for thorough analysis
- `--json` — Structured output with `reasoning_tokens` + `completion_tokens` (parseable completion detection)
- `> /tmp/codex-<slug>.out 2>&1` — Stdout AND stderr captured to a file. Stderr is NOT suppressed; after v0.98.0 it carries completion signals and exec-server stream-closure markers (per OpenAI #18946, #19130)
- Trailing `&` — Background the process so the parent shell returns immediately. Critical: if the user presses Esc on the parent terminal during a long review, the SIGINT does NOT kill Codex

### Signal Handling & Session Safety

`codex exec` in the foreground from the host harness's Bash tool inherits parent-shell signals. If the user presses Esc during a long review, the SIGINT propagates and kills both Codex AND can confuse the host harness session.

**Mitigation: always background with `&` and a captured output file.**

```bash
codex exec ... > /tmp/codex-<slug>.out 2>&1 &
echo "codex pid=$! ; output at /tmp/codex-<slug>.out"
```

Then watch with a `pgrep`-based loop (or the Monitor tool) that polls `pgrep -f "codex exec --sandbox"` and emits progress lines. When the process exits, the watch reports the final byte count, and Claude Code reads the result file.

**Progress-reporting loop pattern:**

```bash
START=$(date +%s); while pgrep -f "codex exec --sandbox read-only" >/dev/null 2>&1; do
  sleep 300
  ELAPSED=$(($(date +%s) - START))
  SIZE=$(wc -c < /tmp/codex-<slug>.out 2>/dev/null || echo 0)
  echo "[$(date +%H:%M:%S)] codex still running, elapsed=${ELAPSED}s, output_bytes=${SIZE}"
done
echo "[$(date +%H:%M:%S)] CODEX_EXITED, final output_bytes=$(wc -c < /tmp/codex-<slug>.out)"
```

### Data Sanitization Before Pasting

For prompts where you **point Codex at files** (Plan Review, Implementation Review), no sanitization needed — Codex reads files directly under `--sandbox read-only` and you don't ship file content over the network from this side.

For prompts where you **paste content** (Bug Debugging, Architecture Decision, Planned Code Review — anything where the code or context isn't yet on disk), scan the pasted content for:

- Hardcoded API keys, tokens, passwords
- Customer/user PII
- Internal hostnames / private IPs that shouldn't leave the org
- Anything matching `~/.config/`, `.env*`, `~/.ssh/` patterns

Redact before pasting. If unsure, write the content to a temp file on disk first, sanitize it, then point Codex at the file instead of pasting.

### Context Loading — Two-Phase Pattern

Codex has **read access to the entire filesystem** via `--sandbox read-only`. Use this. Don't paste file contents into the prompt — point Codex at the files and let it read them.

**Phase 1 — Onboard (always do this first)**

Every Codex invocation starts with project-level context. Tell Codex to read:

- `CLAUDE.md` — Environment overview, services, development philosophy
- `CHANGELOG.md` — Current focus, recent work, decision log
- `docs/vision.md` — Long-term direction (skim)

This gives Codex the same high-level understanding that `/recall` gives Claude Code at session start.

**Phase 2 — Feature Deepdive**

Then point Codex at the specific feature context:

- The plan document: `docs/features/<feature>_plan.md`
- The WIP document: `docs/features/<feature>_wip.md` (if it exists)
- Relevant implementation files: list specific paths
- Related dependencies: files the implementation interacts with

This mirrors the feature-focused part of `/recall` — Codex sees the plan, the implementation, and the surrounding code that's interrelated.

**When to paste instead of point:**

Only paste content that **doesn't exist on disk yet** — planned code that hasn't been written, draft approaches, proposed changes. Everything else, point Codex at the file.

### MCP Tool (Alternative)

Codex is also registered as an MCP server. Claude Code can call it as a tool directly. Use whichever method is more convenient for the situation.

---

## Use Cases & Prompt Templates

### Case 1: Plan Review

**When**: After plan creation, before implementation starts.

```
You are a senior architect reviewing a software implementation plan created by another AI (Claude Code) and a product manager.

ONBOARD — Read these files first to understand the project:
- CLAUDE.md (environment overview, services, development philosophy)
- CHANGELOG.md (current focus, recent work, decisions)
- docs/vision.md (long-term direction — skim)

FEATURE CONTEXT — Then read these for the specific feature:
- docs/features/<feature>_plan.md (the plan you're reviewing)
- docs/features/<feature>_wip.md (if it exists — working notes)
- [list any other relevant reference docs]

REVIEW INSTRUCTIONS:
- Analyze this plan for weaknesses, gaps, and risks that could cause problems during implementation or down the road.
- Focus on high-impact, low-effort improvements. Go for the low-hanging fruits.
- If you see a major weakness that will be a real headache later, warn us clearly.
- Do NOT be a perfectionist. Perfection is the enemy of great.
- Do NOT list every possible edge case. Only flag issues that matter in practice.
- If the plan looks solid and well-thought-out, say so: "Looks good — no major issues found."
- List at most 3-5 prioritized suggestions with clear rationale.
- For each suggestion, indicate: [HIGH IMPACT] or [NICE TO HAVE]
```

**Run with:**

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-plan-review.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

### Case 2: Implementation Review

**When**: At implementation checkpoints or before ship (SD's `feature complete` or CE's `/ce-commit-push-pr`).

```
You are a senior code reviewer examining an implementation created by another AI (Claude Code).

ONBOARD — Read these files first to understand the project:
- CLAUDE.md (environment overview, services, development philosophy)
- CHANGELOG.md (current focus, recent work, decisions)

PLAN — Read the plan this implementation is based on:
- docs/features/<feature>_plan.md

IMPLEMENTATION — Read these files (the code under review):
- <path/to/file1>
- <path/to/file2>
- <path/to/file3>
[list all relevant implementation files AND their dependencies/related files]

REVIEW INSTRUCTIONS:
- Check if the implementation correctly follows the plan.
- Look for bugs, architectural issues, security concerns, and missed requirements.
- Pay attention to how the files interact with each other — check the connections.
- Focus on issues that would cause real problems — not style or minor improvements.
- If the implementation is solid, say: "Implementation looks correct and aligned with the plan."
- List at most 3-5 findings, prioritized by impact.
- For each finding: [BUG], [ARCHITECTURE], [SECURITY], or [IMPROVEMENT]
```

**Run with:**

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-impl-review.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

### Case 3: Bug / Stuck Debugging

**When**: Blocked on a problem and need a fresh perspective. This is the one case where pasting context is appropriate — error messages and attempted approaches don't live on disk.

```
We are stuck on a problem and need a fresh perspective.

ONBOARD — Read these files first:
- CLAUDE.md
- CHANGELOG.md

RELEVANT CODE — Read these files:
- <path/to/file1>
- <path/to/file2>
[list the files involved in the bug]

THE PROBLEM:
[Paste: error messages, unexpected behavior — this doesn't exist on disk]

WHAT WE TRIED:
[Paste: approaches attempted and why they didn't work]

Give us your diagnostic opinion. What's the most likely root cause? What would you try next?
```

**Run with** (sanitize the pasted error messages / context per [Data Sanitization Before Pasting](#data-sanitization-before-pasting) first):

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-debug.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

### Case 4: Architecture Decision

**When**: Facing a design choice with multiple valid approaches.

```
We're facing an architecture decision and want a second opinion.

ONBOARD — Read these files first:
- CLAUDE.md
- CHANGELOG.md
- docs/vision.md

RELEVANT CONTEXT — Read these files to understand the current state:
- <path/to/relevant/files>
[list files that show the current architecture and constraints]

THE DECISION:
[Paste: the options being considered with trade-offs — this is the part that's in-progress thinking, not yet on disk]

Which option do you recommend and why? Are there options we haven't considered? Keep your analysis focused on practical trade-offs, not theoretical purity.
```

**Run with** (sanitize the pasted options/context per [Data Sanitization Before Pasting](#data-sanitization-before-pasting) first):

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-arch.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

### Case 5: Planned Code Review (Pre-Implementation)

**When**: You want Codex to review code that hasn't been written to disk yet — a draft implementation, a proposed approach, or code you're about to write.

```
You are a senior code reviewer. We're about to implement the following code.

ONBOARD — Read these files first:
- CLAUDE.md
- docs/features/<feature>_plan.md

EXISTING CODE — Read these files to understand what already exists:
- <path/to/existing/files>
[list files the new code will interact with]

PROPOSED CODE:
[Paste: the code that doesn't exist on disk yet]

REVIEW INSTRUCTIONS:
- Does this proposed code fit well with the existing codebase?
- Any bugs, architectural issues, or security concerns?
- Focus on high-impact issues. If it looks solid, say so.
- List at most 3-5 findings, prioritized by impact.
```

**Run with** (sanitize the pasted proposed code per [Data Sanitization Before Pasting](#data-sanitization-before-pasting) first):

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-pre-impl-review.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

### Follow-up Round

**When**: Iterating after initial review. Use for rounds 2-3.

```
We reviewed your suggestions and implemented some of them.

READ THE UPDATED FILES:
- <path/to/updated/files>
[point to the files that changed since last review]

CHANGES MADE:
[Brief summary of what was changed based on feedback]

NOT IMPLEMENTED (and why):
[Suggestions we decided to skip, with reasoning]

Please re-review the updated files. Does everything look good now? Any remaining concerns?
Keep your response focused — we've already addressed the major points.
```

**Run with:**

```bash
codex exec --sandbox read-only -m gpt-5.3-codex -c model_reasoning_effort="high" --json "<the prompt above>" > /tmp/codex-followup.out 2>&1 &
```

Then watch per [Signal Handling & Session Safety](#signal-handling--session-safety).

---

## Output Handling

How to handle Codex's response depends on the engagement mode:

### Involved Work (the user is active in the conversation)

When the user is engaged — planning, reviewing, making decisions:

1. **Digest** Codex's response (don't dump raw output)
2. **Categorize** each finding:
   - **Implement now** — High-impact, low-effort, clearly correct
   - **Note for later** — Valid but not blocking; add to WIP or backlog
   - **Disagree** — Present Codex's point and your counterargument
3. **Present** the categorized summary with your own reasoning
4. the user acts as mediator and decides

**Example presentation:**

> **Codex Review Summary** (Plan: Feature X)
>
> **Implement now:**
> - [HIGH IMPACT] Add input validation for the webhook endpoint — Codex is right, we missed this. Low effort to add.
>
> **Note for later:**
> - [NICE TO HAVE] Consider rate limiting on the API — valid concern but not needed for v1.
>
> **Disagree:**
> - Codex suggested switching from polling to WebSockets — we intentionally chose polling for simplicity per the plan rationale.
>
> Overall: Plan is solid. One concrete improvement to make before we start.

### Session Handoff (the user wants to talk to Codex directly)

When the user sees a finding and says "I want to dig into this with Codex directly":

1. Tell the user the session is resumable and give the command:
   ```bash
   # Resume the most recent Codex session interactively
   codex resume --last

   # Or resume a specific session by name
   codex resume <session-name>
   ```
2. the user opens a separate terminal and runs the command
3. He's now in an interactive Codex session with full context from the review
4. He can ask follow-ups, challenge findings, explore alternatives — directly with Codex
5. When done, he can share what he learned and we continue

**Finding the session name**: Sessions are stored in `~/.codex/sessions/YYYY/MM/DD/`. The most recent one is what `--last` picks up. For a specific session, use the filename without `.jsonl`.

**Why this matters**: Sometimes it's more efficient to talk to the reviewer directly than to relay through Claude Code. This is the mediator choosing to go deeper.

### Autonomous Work (Claude Code working independently)

When working on debugging, small fixes, or tasks where the user isn't actively engaged:

- Use Codex's input silently to solve the problem
- Don't present the review to the user — just incorporate useful insights
- Mention it briefly if Codex helped with something non-obvious: "Used Codex for a second opinion on the root cause"

### Learning Loop

When Codex catches something Claude missed:
- Consider whether the pattern should be noted in your project docs
- If it's a recurring blind spot, add a note so future sessions benefit

---

## Session Management

### How Sessions Work

- `codex exec` calls are **stateless** — each invocation is independent
- For multi-round reviews, include accumulated context in each prompt (prior feedback + changes made)
- Interactive sessions (`codex` without `exec`) support `resume --last`, but we primarily use `exec` for automation

### Multi-Round Pattern

For iterative reviews (the typical 2-3 round pattern):

1. **Round 1**: Full context + plan/implementation + review prompt
2. **Round 2**: Previous feedback summary + changes made + what was skipped + follow-up prompt
3. **Round 3** (if needed): Remaining concerns only — keep it focused

Include enough context in each round for Codex to understand the state without needing session memory.

---

## Integration with Development Methodology

Codex review integrates with whichever per-repo methodology is in use. Two patterns; pick the one matching the repo's setup and don't mix within a single feature.

### In CE-piloted repos (the default Mosaik pattern)

```
/recall → Planning → [CODEX: Plan Review] → Implementation → [CODEX: Impl Review] → @software-documenter-ce save progress → @software-documenter-ce feature complete
                                        ^                                       ^
                                   After plan created                   Before feature complete
                                   Before implementation                Or at meaningful checkpoints

                       [CODEX: Debug Help] ← Ad-hoc, when stuck during implementation
```

Codex remains a sidecar reviewer at the same checkpoints CE produces:

### CE-piloted repos: per-CE-stage checkpoint mapping

The CE flow runs: `/ce-strategy` (once per repo, optional) → `/ce-ideate` (between projects, optional) → `/ce-brainstorm` → `/ce-plan` (auto-invokes `/ce-doc-review` headless at Phase 5.3.8 for plan-quality review) → `/ce-work` → `/ce-code-review` → `/ce-commit-push-pr` → `/ce-compound`. Codex remains a sidecar reviewer (CE skills don't natively call Codex). Invoke at the same checkpoint shapes SD has, mapped to CE artifacts:

**Touchpoints (CE):**

- **After `/ce-plan`** → Invoke Codex for plan review against the requirements (R-IDs) + actors (A-IDs) + flows (F-IDs) + acceptance examples (AE-IDs) + implementation units (U-IDs) the plan produced. Equivalent to SD's "after plan creation."
- **After `/ce-code-review`** → Invoke Codex for implementation review. CE's `/ce-code-review` runs several built-in personas (security, correctness, etc.); Codex adds an independent outside-the-plugin perspective. Findings get folded back via another `/ce-work` pass.
- **After `/ce-doc-review`** → If the feature has user-facing or reference docs, invoke Codex on the docs as well.
- **When stuck** → Use `/ce-debug` first; escalate to direct Codex invocation if `/ce-debug` doesn't unblock.

In CE-piloted repos, Codex findings get appended to the relevant CE artifact (the plan doc, the code-review report, the doc-review report) rather than a SD-style WIP file.

---

## Governance

### Light-Touch Rules

1. **Codex is a tool, not an agent** — No turn budgets, no per-feature invocation caps. Invoke when a second opinion adds real value.
2. **Cost awareness** — ChatGPT Pro DOES have usage caps and 429s happen in practice. Don't invoke for trivial tasks. If the user mentions usage is getting high, reduce invocations. When 429s land, swap accounts per [Troubleshooting → Usage Limit Reached](#usage-limit-reached-http-429).
3. **Read-only always** — `--sandbox read-only` on every invocation. Codex reviews, it never implements.
4. **Disagreement protocol** — When Codex and Claude Code disagree, present both perspectives to the user with reasoning. Never silently override or silently accept.
5. **No perfectionism** — Every prompt template includes anti-perfectionism directives. If Codex returns perfectionist feedback despite this, filter it in the digest.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | What to Do Instead |
|---|---|---|
| Invoking Codex on every small change | Cost explosion, context pollution, slows iteration | Reserve for meaningful checkpoints |
| Dumping raw Codex output to the user | Overwhelming, unfiltered, no Claude perspective | Digest and categorize first |
| Accepting all Codex suggestions | Codex doesn't have full context; some suggestions may conflict with decisions already made | Evaluate each suggestion against the plan rationale |
| Ignoring all Codex suggestions | Defeats the purpose of a second opinion | Consider each one fairly, explain disagreements |
| Pasting file contents instead of pointing to files | Unnecessary, error-prone, may miss updates | Point Codex at file paths — it has read access |
| Skipping the onboard phase | Codex reviews without project context — myopic feedback | Always start with CLAUDE.md + CHANGELOG.md + vision.md |
| Using Codex for tasks Claude is already confident about | Waste of Pro subscription usage | Trust your own judgment on straightforward work |
| Running Codex without anti-perfectionism prompting | Returns exhaustive, low-signal feedback | Always include the anti-perfectionism directive |

---

## Troubleshooting

### Codex hangs (Working… forever, no output)

**Root causes** (per OpenAI issues #7187, #7156, #4337):

1. MCP server misconfiguration — check `~/.codex/config.toml` for plugin/MCP settings that might stall on init
2. Long shell startup (`.bashrc` / `.zshrc` hangs) — Codex inherits the shell environment
3. API timeout (rare) — Codex waits indefinitely on OpenAI's response
4. Backgrounded process orphaned but not exited — check `pgrep -f "codex exec"` for stuck PIDs

**Fix procedure:**

```bash
# 1. Kill any hung codex processes
pkill -f "codex exec --sandbox" || true

# 2. Verify Codex itself works (bypass Claude Code)
codex exec --json "Say 'test'" > /tmp/codex-smoke.out 2>&1 &
sleep 30
cat /tmp/codex-smoke.out
# If empty after 30s: Codex install or auth is broken; reinstall

# 3. Reinstall if needed
npm install -g @openai/codex@latest
codex --version  # must be v0.98.0+

# 4. Re-authenticate
codex logout
codex login --device-auth
codex login status  # should show "Logged in using ChatGPT"
```

### Esc accidentally killed CC session along with Codex

You ran Codex in the foreground without `&`. Always background. See [Signal Handling & Session Safety](#signal-handling--session-safety).

### Output file empty even after process exited

Check `/tmp/codex-<slug>.out` actually exists. If you forgot the `> /tmp/...` redirect, output went to /dev/null because the wrapper backgrounded the call. Re-run with the redirect.

### Usage Limit Reached (HTTP 429)

When Codex returns `usage_limit_reached` or `429 Too Many Requests`:

1. **Don't give up** — the operator may have multiple OpenAI accounts
2. **Suggest swapping**: "Codex hit the usage limit on this account. Want to swap to another OpenAI account?"
3. **Swap procedure**:
   ```bash
   codex logout
   codex login --device-auth
   ```
   This gives a one-time code + URL. operator opens `https://auth.openai.com/codex/device` in their browser, signs into the other account, enters the code. Done.
4. **Verify**: `codex login status` — should show "Logged in using ChatGPT"
5. **Retry** the original Codex invocation

**Important**: Always use `--device-auth` (not bare `codex login`). Bare login starts a localhost callback server that doesn't work on headless setups.

---

## See Also

- [Doc-Structure Skill](../doc-structure/SKILL.md) — Documentation methodology this skill integrates with
- **OpenAI's `codex@openai-codex` plugin** (installed 2026-05-25) — complementary surface for cases this skill doesn't cover:
  - `/codex:adversarial-review` — steerable pressure-test review (challenge assumptions, race conditions, rollback). Use for ship-readiness when constructive review (this skill) is the wrong shape.
  - `/codex:rescue` — delegate a task for Codex to **actually fix** (not just review). This skill explicitly forbids implementation; rescue is the opposite. Use when you want Codex to investigate AND patch.
  - `/codex:review`, `/codex:status`, `/codex:result`, `/codex:cancel` — quick ad-hoc reviews + async job UI. Use when you don't need this skill's project-context templates and digest discipline.

---

*Last updated: 2026-05-25*
*Reviewed against: OpenAI Codex CLI v0.98.0+, [changelog](https://developers.openai.com/codex/changelog)*
*Known OpenAI issues monitored: [#7187](https://github.com/openai/codex/issues/7187) (CLI hangs), [#4337](https://github.com/openai/codex/issues/4337) (shell-wrapped process hangs), [#4775](https://github.com/openai/codex/issues/4775) (default timeout missing), [#18946](https://github.com/openai/codex/issues/18946) + [#19130](https://github.com/openai/codex/issues/19130) (exec-server output/stream fixes)*
