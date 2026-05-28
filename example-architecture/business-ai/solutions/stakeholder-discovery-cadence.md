---
type: cross-cutting-pattern
status: example
---

# Cross-Cutting Pattern (Example): Stakeholder Discovery Cadence

> Example cross-repo learning. Real meta-repos accumulate patterns at this abstraction layer as solutions get built.

This file holds patterns identified across multiple per-solution repos at deliberately higher abstraction than CE's per-repo `docs/solutions/`.

## The pattern

When discovering requirements for a new solution, interviewing the affected operator(s) directly produces better requirements than reviewing existing documentation alone.

**Cadence:**

- Schedule 30-45 min recorded interview
- Lead with open-ended questions about current workflow
- Ask about pain points only after understanding the workflow
- Capture verbatim quotes for operator's exact pain articulation
- Sleep on findings before drafting requirements

## Where this came up

- `<business>-customer-data-pipeline` brainstorm phase (2026-MM-DD)
- `<business>-internal-knowledge-base` brainstorm phase (2026-MM-DD)
- [More instances accumulate over time, with each instance linking back to the per-solution repo's `docs/brainstorms/`]

## Anti-patterns

- Skipping the interview and inferring from existing docs (misses operator's actual constraints)
- Proposing solutions during the interview (interview becomes solution-validation instead of discovery)
- Combining multiple stakeholders in one session (their workflows diverge; the result is averaged-out requirements that fit nobody)

## When to promote a pattern here

A learning belongs in this meta-repo's `solutions/` when it:

- Recurs across 2+ per-solution repos
- Sits at higher abstraction than the specific stack/feature
- Applies to workflow / methodology / stakeholder dynamics / AI-handoff conventions rather than per-stack technical specifics

Per-stack technical learnings stay in the per-solution repo's own `docs/solutions/` (managed by CE's `/ce-compound`).
