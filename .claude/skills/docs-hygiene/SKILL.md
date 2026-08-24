---
name: docs-hygiene
description: Close a phase or land a feature without leaving doc sprawl — archive-on-close, one canonical doc per fact, regenerate the docs map, run the hygiene and docs-surface gates. Use before any commit that touches docs/, PLAN.md, STATUS.md, or the served surface.
---

# docs-hygiene

The rule: one fact, one home (CONTRIBUTING.md). Flags/defaults →
docs/reference/server-config.md; routes → server-api.md; verbs → cli.md;
models → models.md; numbers → benchmarks.md; platform/oracle facts →
environment.md; design → the ONE docs/design/<topic>.md; state → STATUS.md
(≤150 lines); open work → PLAN.md (≤800 lines). Nothing else restates them.

Closing a phase:
1. Delete its PLAN.md block in the closing commit; leave a one-line pointer
   with the durable conclusion. Do NOT move it anywhere — git is the archive.
2. Its design doc: set front matter `status: landed` (or `superseded`) and
   move it to docs/archive/ ONLY if no active topic owns it; otherwise fold
   the durable design into the topic's canonical doc and delete the source.
3. Any served-surface change updates server-config/server-api/cli in the
   SAME commit (tests/docs-surface.test.ts fails otherwise).
4. `bun scripts/check-hygiene.ts --write-docs-map` then
   `bun scripts/check-hygiene.ts` — binaries, root artifacts, archive
   md-only, scripts-root allowlist, doc script paths, design front matter,
   STATUS/PLAN caps, generated map must all be OK.
5. `bun test tests/docs-surface.test.ts` and `bunx tsc --noEmit`.
6. Research scripts whose finding is now in a doc get deleted in the same
   commit (scripts/experiments/ no longer exists; don't recreate it).
