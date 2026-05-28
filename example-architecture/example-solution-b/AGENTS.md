# example-solution-b (internal-knowledge-base)

Generic per-solution repo demonstrating the Mosaik framework's per-solution structure. Different shape than `example-solution-a` (TypeScript + Next.js + vector store rather than Python data pipeline).

## Tech Stack

| Layer | Choice (example) |
|---|---|
| Frontend | Next.js |
| Vector store | Pinecone |
| RAG | LangChain |
| Deployment | Vercel + Pinecone managed |

## Project Conventions

> Universal collaboration rules (Three Golden Rules + Code Discipline) cascade from the parent tier `../AGENTS.md`. Items below are project-specific additions.

- Use `bun` (not `npm`) for the JavaScript stack
- Embeddings model is pinned per the CHANGELOG Decision Log — do not change without an explicit decision entry
- Document retrievals over a confidence threshold get logged for offline review
- Retrieval confidence threshold tuning requires logging output of the offline evaluation script before merge

## Components & Architecture

> EMPTY at scaffolding — populates as features ship via SD-CE `ship docs`.

## Operational Dispatcher

> Informational, not enforced.

**Canonical bullet**:
- When a bug surfaces mid-work, add a one-line entry to `ISSUES.md` Open Issues with date + brief; SD-CE moves it to Resolved at ship time.

**Project-specific scenarios**:
- This solution is part of the `<business>-ai` meta-repo. See `~/repos/<business>-ai/STRATEGY.md` for the unified business context.
- Document indexing pipeline is the load-bearing component — anything touching it warrants `/ce-code-review` even at Solo tier.

## Current State

**Compound Engineering — Phase A piloted.** See `CHANGELOG.md` Current Focus.
