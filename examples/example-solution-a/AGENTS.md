# example-solution-a (customer-data-pipeline)

Generic per-solution repo demonstrating the Mosaik framework's per-solution structure. Real per-solution repos replace placeholder content with actual solution details.

## Tech Stack

| Layer | Choice (example) |
|---|---|
| Language | Python 3.12 |
| Data | SQLite + Airflow |
| API | FastAPI |
| Deployment | Docker on the operator's chosen host |

## Project Conventions

- Use `bun` for any frontend tooling (if added later)
- Follow `<business>`-wide naming conventions per the meta-repo's STRATEGY.md
- All public-facing changes require an entry in CHANGELOG Decision Log

## Components & Architecture

> EMPTY at scaffolding per the Mosaik framework — populates as features ship via SD-CE `ship docs`.

## Operational Dispatcher

> Informational, not enforced.

**Canonical bullet**:
- When a bug surfaces mid-work, add a one-line entry to `ISSUES.md` Open Issues with date + brief; SD-CE moves it to Resolved at ship time.

**Project-specific scenarios**:
- This solution is part of the `<business>-ai` meta-repo. See `~/repos/<business>-ai/STRATEGY.md` for the unified business context.
- Cross-solution patterns live in `~/repos/<business>-ai/solutions/` — useful starting point when this solution's work touches patterns shared with sibling solutions.

## Current State

**Compound Engineering — Phase A piloted.** See `CHANGELOG.md` Current Focus.
