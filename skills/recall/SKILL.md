---
name: recall
description: >
  Load project context on demand. Use when: "recall", "what are we working on",
  "load context", "prime context", "catch me up", "what did I do yesterday",
  "last week", "remember when", "what was I doing". Modes: temporal (YESTERDAY,
  TODAY, LAST WEEK), direct load (project name), topic search (default),
  SESSIONS (session history only), HYBRID (explicit), DEEP (explicit, GPU-only).
argument-hint: "[YESTERDAY|TODAY|LAST WEEK|ProjectName|topic query|SESSIONS query|HYBRID query|DEEP query]"
user-invocable: true
---

# /recall — Context Loader

Load project context from the current repo, your knowledge vaults, and session history.

This is the Mosaik methodology's **software-repo context loader**. It depends on [QMD](https://github.com/tobi/qmd) — a local markdown search daemon — for vault and session indexing. Set up QMD first (see Mosaik's TECHNICAL.md § Runtime requirements + dependencies).

## Mode Detection Cascade

Examine `$ARGUMENTS` and apply the FIRST matching rule:

1. **No arguments** → Direct load from CWD (detect project from current directory)
2. **Date keyword** (YESTERDAY, TODAY, LAST WEEK, THIS WEEK, YYYY-MM-DD, "N days ago") → Temporal mode (Mode 2)
3. **Known name** (matches a project in your project registry, or a known vault entry exists) → Direct load by name (Mode 1)
4. **SESSIONS keyword** (first word is SESSIONS, case-insensitive) → Topic search scoped to the `sessions` collection only (useful when you know the info lives in past conversations, not documented knowledge)
5. **HYBRID keyword** (first word is HYBRID, case-insensitive) → Hybrid search with remaining words as query (searches all configured collections)
6. **DEEP keyword** (first word is DEEP, case-insensitive) → Deep search with remaining words as query, GPU-only (searches all configured collections; needs reranker for reasonable latency)
7. **Anything else** → BM25 + LLM expansion across all configured collections (default topic mode, Mode 3)

Mode keywords are case-insensitive. UPPERCASE in documentation is for visual clarity.

## QMD MCP tools

QMD's MCP surface is **4 tools**: `query`, `get`, `multi_get`, `status`. The `query` tool accepts a `searches: [{type, query}]` array (`lex`, `vec`, `hyde`) and a `rerank: false` flag. `intent` is a first-class parameter on `query` — pass it whenever the bare query terms could plausibly mean different things (it disambiguates and improves snippet quality without changing what's searched).

Quick reference:

| Search type | Sub-query shape | When to use |
|---|---|---|
| Lex (BM25) | `{type: "lex", query: "<keywords>"}` | Exact keyword matches; fastest |
| Vec (semantic) | `{type: "vec", query: "<meaning>"}` | Synonyms, paraphrases |
| Hyde (hypothetical) | `{type: "hyde", query: "<answer-shaped passage>"}` | Abstract/fuzzy queries; build the expected answer and search for similar passages |

Compose for power: `searches: [{type: "lex", query: "..."}, {type: "vec", query: "..."}]` runs both in parallel and merges. Add `rerank: true` for ML reranking (GPU recommended).

**Construction strategy (first-sub-query 2× weighting, when to combine lex/vec/hyde, concrete examples) lives in the `mcp__qmd__query` tool description itself.** Read that description inline whenever you're about to call the tool — it's authoritative and survives upstream tweaks.

**Hyde footgun (filed upstream as `tobi/qmd` #618):** when constructing a hyde sub-query, strip hyphens from the passage. `validateSemanticQuery()` parses any `-term` token as exclusion operator and aborts the entire structured query. So write `auto archive` not `auto-archive`. Affects both hyde and vec sub-queries; lex queries can use leading `-` for negation as designed.

## Collection Availability

If a QMD collection referenced in a search step is not configured, skip it with a one-line note in the output (e.g., `sessions collection not configured — searched other collections only`). Never fail the whole `/recall` on a missing collection. Check `mcp__qmd__status` if unsure which collections exist.

**QMD daemon down.** If QMD MCP returns a connection error, fall back gracefully:
- Mode 1 (direct load) still works — reads repo files directly.
- Mode 2 (temporal) still works — reads `~/.claude/projects/*/*.jsonl` directly.
- Modes 3/4/5/6 (topic/SESSIONS/HYBRID/DEEP) require QMD. If unavailable, tell the user: *"QMD daemon is down; topic/hybrid/deep search unavailable. Use `/recall` (direct load) or `/recall YESTERDAY` (temporal) instead."*

## Mode 1: Direct Load (no args, or known name)

When invoked with no arguments, detect the project from CWD:
- Primary: `git rev-parse --show-toplevel` → extract directory name as slug
- Fallback: match CWD against your project registry paths
- Warn if CWD is outside any registered repo

When invoked with a known name, look up the path from your project registry.

### Code Repo Loading

Load context (mirrors the per-feature checkpoint loading pattern):

1. **Read `CHANGELOG.md`** — focus on "Current Focus" section. Extract the active feature name and normalize to file slug (lowercase, hyphens).

2. **Load active feature docs** — using the feature slug from Current Focus:
   - `docs/features/<feature>_plan.md` (if exists — implementation plan)
   - `docs/features/<feature>_wip.md` (if exists — working memory)
   - `docs/<feature>_reference.md` (if exists — technical reference)
   - `docs/<feature>/` (if exists — major-feature folder with spec, roadmap)

   **CE-piloted repos additionally have:**
   - `docs/brainstorms/<feature>-requirements.md` (CE brainstorm output with R/A/F/AE-IDs)
   - `docs/plans/YYYY-MM-DD-NNN-<feature>-plan.md` (CE plan output with U-IDs — different naming from SD's `<feature>_plan.md`)
   - `docs/features/<feature>_scorecard.md` (CE pilot scorecard if scorecard ran)

   **Slug extraction fallback.** If Current Focus is prose, lists multiple features, or no clean slug can be extracted: list the top 2-3 most recently modified `docs/features/*_wip.md` files (by mtime), show their headers, and ask the user which to load. Don't fail silently — a missing WIP for an extracted-but-wrong slug is a worse outcome than a short clarifying question.

3. **Read upstream anchor** — whichever exists at repo root, in priority order:
   - `STRATEGY.md` (CE-piloted repos — product anchor: target problem / approach / persona / metrics / tracks. Authoritative when present.)
   - `docs/vision.md` (legacy — may exist in non-CE repos or pre-CE-adoption repos)
   - If both exist, prefer `STRATEGY.md` (CE-adopted repos treat it as source of truth; `docs/vision.md` becomes informal historical anchor).
4. **Read `ISSUES.md`** if it exists.
5. **Read project entry** if it exists — search your configured vaults (`mcp__qmd__query` with searches `[{type: "lex", query: "<project> project summary"}]`).
6. **Synthesize "One Thing"** (see below).

**Meta-repo extension** (if using the Mosaik meta-repo + per-solution repos pattern from `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`): when in a per-solution repo, also load the parent meta-repo's STRATEGY + relevant per-solution summary + relevant cross-solution patterns. Manual invocation pattern: `/recall <business>-ai` after `/recall` in the per-solution repo. Provides whole-business grounding.

## Mode 2: Temporal (date-based)

Scan Claude Code session JSONL files for the given date range.

1. **Find the session files.** Claude Code stores one JSONL per session directly under the per-workspace project directory. Correct glob:
   ```
   ~/.claude/projects/*/*.jsonl
   ```
   (Per-session subdirs may also exist alongside the JSONLs but the JSONLs themselves are the canonical event log.)

2. **Use event timestamps from within each file**, NOT filesystem `mtime`. `mtime` is unreliable because git sync and file copies reset `mtime` to sync-time, not conversation time. Read events until you have what you need:
   - The very first event is typically `file-history-snapshot` (internal bookkeeping) — it has a `timestamp` but is not a user message. Scan past it.
   - The first event with `type: "user"` (or `message.role === "user"`) gives the session start time in real-world terms, and is usable for the session title (first user prompt, truncated).
   - A cheap metadata peek of the first ~64KB is usually enough to find both.

3. For matching files, scan for the first user message to derive a session title. Count total user messages. Extract the first event timestamp.

4. Present a table:

   | # | Time | Messages | Title (first user message, truncated) |
   |---|------|----------|---------------------------------------|

5. Ask if the user wants to expand any specific session.

6. Synthesize "One Thing" from the sessions found.

**Optimization note:** For large directories, use filesystem `mtime` as a cheap pre-filter (skip files clearly way outside the window), then confirm with actual event timestamps. Never rely on `mtime` alone.

## Mode 3: BM25 + LLM Expansion (default topic mode)

The user's query vocabulary often differs from the stored text. Compensate by generating keyword variants.

1. **Generate 3-4 keyword variants** of the user's query. Think about:
   - Synonyms (e.g., "disk cleanup" → "free space", "storage bloat")
   - Technical equivalents (e.g., "voice cloning" → "TTS", "speech synthesis")
   - Related concepts (e.g., "deploy" → "CI/CD", "production", "release")

2. **Run all variants in parallel** across your configured collections:
   ```
   mcp__qmd__query(searches: [{type: "lex", query: "variant 1"}], collections: ["<your-collections>"], rerank: false, intent: "<background context>")
   mcp__qmd__query(searches: [{type: "lex", query: "variant 2"}], collections: ["<your-collections>"], rerank: false, intent: "<background context>")
   ```
   Use `minScore: 0.3` to filter noise. **Include the `sessions` collection by default** if configured — "that conversation about X" lives in session history, not vault docs. Explicit `/recall SESSIONS <query>` limits to sessions only.

3. **Deduplicate** results by document path, keeping the highest score.

4. **Cap at top 5** after dedup, then read all 5 in a single `mcp__qmd__multi_get` call (batch — one round-trip, faster than per-doc `get`). Never read more than 5 docs from a default topic search — tighter cap beats broader reads for noise.

5. **Present findings** with document paths and key excerpts.

6. **Synthesize "One Thing"**.

## Mode 4: SESSIONS (session-history only)

For queries like "that conversation about X", "when did we discuss Y" — when you know the info is in past sessions, not documented knowledge.

1. Strip the `SESSIONS` keyword from the query.
2. Run search scoped to the `sessions` collection only:
   ```
   mcp__qmd__query(searches: [{type: "lex", query: "<remaining query>"}], collections: ["sessions"], rerank: false, intent: "<background context>")
   ```
   If quality is poor, fall back to lex+vec sub-queries (`searches: [{type: "lex", query}, {type: "vec", query}]`) for the same collection.
3. Present top 3-5 results with session IDs / dates.
4. Synthesize "One Thing".

## Mode 5: HYBRID (explicit HYBRID keyword)

For fuzzy queries where BM25 expansion is not enough.

1. Strip the `HYBRID` keyword from the query.
2. Run hybrid search across your configured collections in parallel:
   ```
   mcp__qmd__query(searches: [{type: "lex", query: "<remaining query>"}, {type: "vec", query: "<remaining query>"}], collections: ["<your-collections>"], rerank: false, intent: "<one-line description of what you're trying to find / disambiguate>")
   ```
3. Read top results, present findings, synthesize One Thing.

Note: Hybrid search latency depends on hardware — typically 3-6s on CPU, ~1-3s on GPU.

## Mode 6: DEEP (explicit DEEP keyword, GPU recommended)

For complex, fuzzy, or abstract queries that need reranking.

1. Strip the `DEEP` keyword from the query.
2. Run deep search across your configured collections in parallel:
   ```
   mcp__qmd__query(searches: [{type: "lex", query: "<remaining query>"}, {type: "vec", query: "<remaining query>"}, {type: "hyde", query: "<50-100-word answer-shaped passage about <remaining query>>"}], collections: ["<your-collections>"], intent: "<one-line description of what you're trying to find / disambiguate>")
   # rerank defaults to true for deep search — GPU recommended for reasonable latency.
   ```
3. If running CPU-only, warn that deep search is slow (~34-49s) and offer to fall back to HYBRID.
4. Read top results, present findings, synthesize One Thing.

## "One Thing" Synthesis

After presenting results, synthesize a SINGLE highest-leverage next action.

Weigh these factors:
- **Momentum** — What has recent activity? What's mid-flow?
- **Blockers** — Removing a blocker unlocks downstream work
- **Closest to done** — Finishing > starting
- **Urgency** — Deadlines, time-sensitive items, blocking others

Format: **One Thing: [specific, concrete action]**

**Good:** "Finish the voice cloning test suite — 4 of 6 tests pass, fix the remaining 2 failing on audio codec mismatch."

**Bad:** "Continue working on voice cloning."

The One Thing must be actionable in the current session. Not a project-level goal, but a session-level task.

---

## Adoption notes

- **Required dependency**: [QMD](https://github.com/tobi/qmd) daemon running locally (default port 8181). All Mode 3-6 calls assume QMD is reachable.
- **Configured collections**: replace `<your-collections>` with your actual QMD collection names. Common conventions: `personal` (your operator notes), `agent` (cross-project canonical knowledge), `sessions` (your session-to-markdown conversion output).
- **Project registry**: Mode 1 looks for a known-projects table or list in your environment (commonly in a root CLAUDE.md or AGENTS.md). Configure to match your repo layout.
- **Session JSONL location**: Mode 2 assumes Claude Code's `~/.claude/projects/*/*.jsonl` storage. If using a different harness, adapt the glob.
