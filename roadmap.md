# Mosaik Roadmap

> Ordering is relative — no calendar commitments. Items move when they're ready (or when adoption surfaces a gap that bumps priority). Versioning approach below.

## Current state

**v0.1.0** — initial framework articulation + curated software-side runtime extraction + abstract example structure. In-development. One pilot validates the simpler unified-tooling case; the multi-repo + meta-repo pattern is sketched and being validated in production.

What v0.1.0 includes:

- Framework articulation in `README.md` + `TECHNICAL.md` (positioning, dual-loop, meta-repo pattern, runtime + dependencies)
- Methodology corpus for Compound Engineering adoption (`methodology/compound-engineering/` — 9 docs covering overview, migration plan, inventory, walkthrough, doc lifecycle, fresh-repo + migrate-existing scripts, meta-repo pattern)
- Live skill source (`skills/doc-structure/`, `skills/recall/`, `skills/codex-review/`)
- Live agent source (`agents/software-documenter-ce.md`)
- Agent collaboration principles (`methodology/agent-collaboration-principles.md`) — the Three Golden Rules + Code Discipline, plus the tier-pattern guidance for wiring them into a repo cluster
- Example architecture cluster (`example-architecture/`) — parent tier with AGENTS.md+shim demonstrating universal-rules-cascade-to-per-repo + meta-repo (`business-ai/`) + two per-solution repos with project-specific conventions
- Roadmap + LICENSE (MIT)

## Near-term (v0.2.0)

- Incorporate feedback from initial readers
- Anonymized concrete example (currently abstract)
- Refined README based on first read-throughs
- Documentation polish
- **Methodology: explicit walkthrough of per-solution `/ce-strategy` seeded by meta-repo via `/recall`** (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md` § "Setup procedure for per-solution repos"). The seeding pattern already works via existing tooling; the gap is articulation, not implementation.
- **Methodology: explicit framing of per-solution repos as agent runtimes** alongside conventional applications and SaaS-integration wrappers (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md` § "What the per-solution repos ARE"). Three valid shapes: conventional applications / integration wrappers around SaaS or APIs / agent runtimes invoked via agent-SDK or `claude -p`.
- **Methodology: `business/` folder conventions for meta-repo knowledge surfaces** — departments, stakeholder profiles, tools inventory, compliance constraints, decision log (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`). Requires a scoping pass first against existing surfaces (STRATEGY.md Persona section, `projects/<solution>-summary.md` decisions list) to determine what business knowledge is currently homeless vs already covered.
- **Examples: add `business/` placeholders and an agent-runtime per-solution example** (in `example-architecture/business-ai/`).
- **Public dependency matrix** — realistic install time + common failure modes for CE, QMD, the skill/agent wiring + parent-tier `AGENTS.md` setup. Codex's final review flagged this as a load-bearing aid for skeptical adopters who'd otherwise be reading marketing copy without a concrete friction picture.

## Medium-term (v0.3.0)

- First externally validated meta-repo + per-solution pattern (from production)
- `<business>-promote-solution` skill if the promote-manually friction crosses the trigger (3+ per-solution repos AND 2+ cross-promotions per week)
- Possibly: `audit-docs` skill (anti-drift defense — checks doc claims against filesystem reality)

## Long-term (v1.0)

- "Stable" framework
- Multiple external adopters
- Empirically validated at the scale and shape described

## Deferred / open questions

- Community model (governance, contribution guidelines) — if resonance emerges
- Per-language adaptations — out of scope; framework is language-agnostic
- Productized/SaaS hosting — not the plan; Mosaik is framework + open-source, not a product

## Versioning approach

Mosaik tracks releases in this repo with `vMAJOR.MINOR.PATCH` tags. The framework lives in a personal knowledge base (out of this repo's scope) and gets released here as it stabilizes. Expect breaking changes between minor releases during the 0.x phase; semantic versioning kicks in at 1.0.

Items move through the buckets above based on readiness and external adoption signals, not calendar dates. Near-term items are the next likely batch when the operator returns to v0.2.0 work.
