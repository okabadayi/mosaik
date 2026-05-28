# Mosaik Roadmap

## Current state

**v0.1.0** — initial framework articulation + curated software-side runtime extraction + abstract example structure. In-development. One pilot validates the simpler unified-tooling case; the multi-repo + meta-repo pattern is sketched and being validated in production.

## Near-term (v0.2.0 — 4-6 weeks from v0.1.0)

- Incorporate feedback from initial readers
- Anonymized concrete example (currently abstract)
- Refined README based on first read-throughs
- Documentation polish
- **Methodology: explicit walkthrough of per-solution `/ce-strategy` seeded by meta-repo via `/recall`** (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md` § "Setup procedure for per-solution repos"). The seeding pattern already works via existing tooling; the gap is articulation, not implementation.
- **Methodology: explicit framing of per-solution repos as agent runtimes** alongside conventional applications and SaaS-integration wrappers (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md` § "What the per-solution repos ARE"). Three valid shapes: conventional applications / integration wrappers around SaaS or APIs / agent runtimes invoked via agent-SDK or `claude -p`.
- **Methodology: `business/` folder conventions for meta-repo knowledge surfaces** — departments, stakeholder profiles, tools inventory, compliance constraints, decision log (in `methodology/compound-engineering/11-meta-repo-pattern-for-heterogeneous-businesses.md`). Requires a scoping pass first against existing surfaces (STRATEGY.md Persona section, `projects/<solution>-summary.md` decisions list) to determine what business knowledge is currently homeless vs already covered.
- **Examples: add `business/` placeholders and an agent-runtime per-solution example** (in `examples/business-ai/`).

## Medium-term (v0.3.0 — Q3 2026)

- First externally validated meta-repo + per-solution pattern (from production)
- `<business>-promote-solution` skill if the promote-manually friction crosses the trigger (3+ per-solution repos AND 2+ cross-promotions per week)
- Possibly: `audit-docs` skill (anti-drift defense — checks doc claims against filesystem reality)

## Long-term (v1.0 — 2027 H1 earliest)

- "Stable" framework
- Multiple external adopters
- Empirically validated at the scale and shape described

## Deferred / open questions

- Community model (governance, contribution guidelines) — if resonance emerges
- Per-language adaptations — out of scope; framework is language-agnostic
- Productized/SaaS hosting — not the plan; Mosaik is framework + open-source, not a product

## Versioning approach

Mosaik tracks releases in this repo with `vMAJOR.MINOR.PATCH` tags. The framework lives in a personal knowledge base (out of this repo's scope) and gets released here as it stabilizes. Expect breaking changes between minor releases during the 0.x phase; semantic versioning kicks in at 1.0.
