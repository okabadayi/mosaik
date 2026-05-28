# <business>-ai (meta-repo example)

Cross-business meta-repo for unified AI transformation work. Holds the unified strategy, per-solution summaries, and cross-repo learnings.

This is an **example meta-repo** demonstrating the Mosaik framework's meta-repo pattern. Real businesses replace `<business>` with their actual name and populate with real solutions.

## Purpose

This meta-repo is the unified-view agent's "home" — strategic context, project tracking, cross-solution learnings.

## Tech Stack

| Layer | Choice |
|---|---|
| Documentation | Markdown |
| Knowledge fabric | QMD (indexed markdown search) |
| Methodology | Mosaik (CE + complementary fabric) |

## Project Conventions

> Universal collaboration rules (Three Golden Rules + Code Discipline) cascade from the parent tier `../AGENTS.md`. Items below are meta-repo-specific additions.

- Per-solution repos live as siblings (`~/repos/<business>-<solution-name>/`)
- This meta-repo doesn't contain executable code — it's the strategic + organizational substrate
- Cross-solution patterns accumulate in `solutions/` as they emerge
- Per-solution summaries in `projects/` are POINTERS to the per-solution repo's CHANGELOG Decision Log — do not duplicate the rationale here
- Cross-cutting patterns promoted to `solutions/` should be at higher abstraction than the per-solution repo's `docs/solutions/` — re-frame for cross-business applicability when promoting

## Operational Dispatcher

> Informational, not enforced. Discovery hints for ad-hoc work outside CE skill invocations.

**Canonical bullet** (from the AGENTS.md+shim methodology):
- When a bug surfaces mid-work in any per-solution repo, adding a one-line entry to that repo's `ISSUES.md` Open Issues with date + brief is the lightweight capture path; SD-CE moves it to Resolved at ship time.

**Project-specific scenarios:**
- The `projects/` directory holds thin per-solution summaries — useful starting point when context-switching between solutions
- The `solutions/` directory holds cross-repo learnings at higher abstraction than CE's per-repo solutions
- STRATEGY.md anchors the unified vision; each per-solution repo's STRATEGY.md references this one

## Current State

This is an empty example meta-repo. Real meta-repos populate as solutions deploy.
