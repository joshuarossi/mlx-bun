# Docs & repo-organization cleanup plan

**Status:** executed 2026-06-14 (P0 + P1 + P2 #11). Held: P2 #9/#10
(src/ and scripts/ moves — they change import paths / script references
and need a test run, so deferred to their own pass). Authored 2026-06-14.

**Execution state (verified 2026-06-17):**
- P0 #1 — **DONE**: `AGENTS.md` is a symlink → `CLAUDE.md`; drift risk resolved.
- P0 #2 — **DONE**: `benchmarks/RESULTS.md` created; old committed benchmark artifacts `git rm`'d. Root untracked spew (`benchmarks-h2h-2026-06-13-*` etc.) is now cleaned — no untracked report files found at root.
- P0 #3 — **DONE**: root HTML/md spew cleared (no `benchmarks-h2h-*.md`, `benchmark-report-*.html`, `kernel-fusion-report-*.html`, or `project-review.html` at root).
- P0 #4 — **DONE**: hardcoded test count removed from CLAUDE.md (no "All 72 tests" present).
- P1 #5 — **DONE**: `STATUS.md` exists at root.
- P1 #6 — **DONE**: `docs/planning/` exists with `IDEAS.md`, `PRODUCT_ROADMAP.md`, `ResearchTopics.md`, `journal.md`.
- P1 #7 — open (optimization_plan.md still lives in docs/design/ as a standalone).
- P1 #8 — status unknown (archive/ not verified in this pass).
- P2 #9 — **NOT DONE**: `harness-pi.ts`, `pi-provider.ts`, `pi-terminal.ts`, `pi-web.ts` still live flat in `src/` root (no `src/pi/` subdirectory).
- P2 #10 — **PARTIALLY DONE**: ~57 one-off research/debug scripts moved to `scripts/experiments/`; production + tooling + bench-* + regen-* + parity-* + gen-model + eval/serve remain at `scripts/` root (the full bench/regen/build split was not applied).
- P2 #11 — **DONE**: CLI vocabulary reconciled.

**Scope & ethos.** Private repo, single author + agents, MLX-by-identity.
No OSS/community scaffolding (CONTRIBUTING, issue templates, badges) —
out of scope by design. **Prefer move / consolidate over delete.** The
one exception is regenerable benchmark *output* (md/json/html report
artifacts): those are noise, not experiments, and are explicitly
deletable per Josh's direction. Losing *experiments* and code paths are
never deleted (see memory: "don't delete optionality on one
measurement").

---

## The centerpiece: benchmark provenance (corrected)

The original analysis mis-framed this. The correct policy:

- Benchmark **runs** are date- and machine-stamped, regenerable, and
  machine-specific. They do **not** belong in the durable repo. The
  existing `.gitignore` rule `benchmarks-h2h-*` (ignore all raw runs) is
  **correct and stays**.
- The actual defect today: a handful of raw run files leaked into git
  history (committed before that ignore rule existed), and the README's
  headline performance claims cite one of them
  (`benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md`) as the
  source of truth. The repo's central perf claim depends on exactly the
  kind of ephemeral artifact the gitignore says shouldn't be tracked.

**The fix:** one curated, intentionally-maintained record, structured
around the **three distinct kinds of measurement** below; raw runs stay
local/ignored; the eval DB remains the structured backing record.

### The three kinds of benchmarks (the record's structure)

These are categorically different — one is pass/fail correctness, one is
a perf number, one is a quality delta — and `RESULTS.md` must keep them
in separate sections rather than one undifferentiated table. They map to
the project's three-tier parity model (L1/L2/L3).

1. **Parity (porting correctness) — pass/fail, not a number.** Are we
   bit-for-bit with the upstream oracle under like-for-like config?
   - mlx-lm + standard (bf16) KV cache → bit-exact (L1).
   - mlx-optiq + mixed-precision KV cache → bit-exact (L2).
   Record as a matrix of model × mode → ✓/✗ (+ commit, oracle versions).
   This is the gate the perf/quality numbers are only meaningful *under*.

2. **Performance — like-for-like numbers, two comparison axes.** Under
   the parity constraints above, measure tok/s, prefill/s, decode/s,
   TTFT, startup, RSS, peak memory. Two axes:
   - **vs the oracles** — mlx-bun vs mlx-lm / mlx-optiq, same model, same
     mode, same machine, same day.
   - **vs our own compat mode** — mlx-bun's NEW optimizations vs
     mlx-bun's own compatible (bit-exact) path, to prove an optimization
     actually beats the baseline it diverges from.

3. **Quality — for our non-bit-exact optimizations only (L3).** When a
   custom path trades exactness for speed, quantify what the trade costs:
   - **mean score across the 6 eval tasks** (`src/eval/tasks/`: bfcl,
     gsm8k, hashhop, humaneval, ifeval, mmlu), vs the compatible upstream.
   - **KL divergence** vs the compatible distribution.
   Purpose: enable statements like *"the optimized path gains 23% tok/s
   while holding ±5% on the 6-test mean"* — the perf win is only worth
   claiming alongside its measured quality cost.

### B1. Create `benchmarks/RESULTS.md` (the new durable record)
- Three top-level sections: **Parity** (model × mode → ✓/✗), **Performance**
  (oracle comparison + our-optimized-vs-our-compat), **Quality** (6-test
  mean + KL for non-exact paths). Each row carries provenance (machine,
  date, commit, model, mode, oracle versions).
- Named so it does **not** match `benchmarks-h2h-*`, so it's tracked
  deliberately and future raw runs never auto-collide with it.
- Migrate the headline numbers Josh wants to keep (currently the 06-11
  matrix, plus the 06-13/06-14 follow-ups) into the right section
  **before** removing the raw files, so README's claims never lose their
  source.
- Point README's "Full table" link at `benchmarks/RESULTS.md`.

### B2. Remove the old committed benchmark artifacts
`git rm` the leaked raw runs and verification dumps (numbers preserved in
B1 + the eval DB):
- `benchmarks/benchmarks-h2h-2026-06-10-Joshs-MBP-2025.md`
- `benchmarks/benchmarks-h2h-2026-06-10-Joshs-MacBook-Pro.md`
- `benchmarks/benchmarks-h2h-2026-06-10.md`
- `benchmarks/benchmarks-h2h-2026-06-11-Joshs-MBP-2025.md`
- `benchmarks/lab-verification.json`
- `benchmarks/lab-verification-mixed.json`

Also clear the loose **untracked** root spew (delete or move to an
ignored `reports/`): `benchmarks-h2h-2026-06-13-*.md`,
`benchmarks-h2h-2026-06-14-*.{md,html}`, `benchmark-report-*.html`,
`kernel-fusion-report-*.html`, `project-review.html`.

`scripts/verify-lab.ts` keeps writing `benchmarks/lab-verification.json`
locally — it'll just be gitignored now (add `benchmarks/lab-verification*.json`
to `.gitignore`).

### B3. Eval DB — leave where it is (decided 2026-06-14)
- `~/.cache/mlx-bun/evals.sqlite` ([src/evaldb.ts:8](../../src/evaldb.ts))
  stays user-local — it is the structured backing record of every run.
  **Not tracked in-repo** (binary SQLite in git doesn't diff, churns, and
  grows history). `RESULTS.md` is the committed human-readable record; the
  DB is its machine-local source. Decision confirmed by Josh — closed.

### Do NOT touch
`goldens/*.json` and `goldens/**` are the correctness oracle golden
files, not benchmark output. Leave entirely alone.

---

## P0 — Quick, safe wins (low risk)

| # | Action | Why |
|---|---|---|
| 1 | Collapse `AGENTS.md` → `CLAUDE.md` (make AGENTS.md a 1-line pointer or symlink). | They're byte-identical except the title line — guaranteed to drift. |
| 2 | B1–B2 above: create `RESULTS.md`, migrate numbers, `git rm` old artifacts, point README at it, gitignore `lab-verification*.json`. | Fixes benchmark provenance; declutters; keeps gitignore policy honest. |
| 3 | Relocate untracked root HTML/md spew into an ignored `reports/` (or delete). | De-clutters the working-tree root. |
| 4 | Drop the hardcoded "All 72 tests" in CLAUDE.md (say "the suite" / reference the count command). | 57 test files now — a baked-in number that's already wrong. |

## P1 — Structural consolidation (the real navigability win)

| # | Action | Why |
|---|---|---|
| 5 | Add `STATUS.md` (or a pinned top section in PLAN.md) holding only live handoff: current state + next action + blockers. Move PLAN.md's `NEXT UP` / `NEXT SESSION PICKUP` / `SESSION SWEEP` blocks into it. | Separates transient "do this next" from 2,475 lines of durable phase history; gives agents one entry point. |
| 6 | Create `docs/planning/` and move `PRODUCT_ROADMAP.md`, `IDEAS.md`, `ResearchTopics.md`, `journal.md` under it. Leave only README + PLAN.md (+ STATUS.md) at root. Add a ~6-line "doc map" to README. | Root is currently a 6-file planning thicket; extends the taxonomy that already works in `docs/`. |
| 7 | Pick one home for the optimization plan: fold `docs/design/optimization_plan.md` into PLAN.md Phase A–E, or have PLAN.md link out to it as canonical. | Two homes for the same plan = drift. |
| 8 | Resolve the archive overlap: `archive/pi-builtin-investigation.html` duplicates [docs/investigations/pi-builtin-investigation.md](../investigations/pi-builtin-investigation.md). Decide whether `archive/` (tracked; 2 HTML files: `mlx-bun-lab-report.html` + `wwdc-mlx-bun.html`) should be tracked at all, or moved to an ignored location. Keep the `.md`, drop the duplicate. | Stops committing heavyweight generated HTML; one source per investigation. |

## P2 — Polish (optional)

| # | Action | Why |
|---|---|---|
| 9  | Group `src/pi/` (`harness-pi.ts`, `pi-provider.ts`, `pi-terminal.ts`, `pi-web.ts`). | `src/` root is 31 flat files; this is an obvious cohesive cluster. |
| 10 | Sort `scripts/` into `scripts/{bench,regen,build}/` (40 files, clear prefixes). | Navigability only; low urgency. |
| 11 | Reconcile CLI vocabulary: README quickstart uses the shipped `mlx-bun` verb (with a one-line "from a clone, `bun src/cli.ts` is the same"). | README/roadmap/package.json currently mix `bun src/cli.ts` and `mlx-bun`. |

---

## Execution order (after slots work is pushed)

1. P0 #1, #4 (trivial, isolated).
2. Benchmark block B1 → B2 → README relink (do B1 fully before B2).
3. P0 #3 (root spew).
4. Confirm B3 eval-DB decision with Josh.
5. P1 #5–#8 (the structural moves; one commit per item so history stays legible).
6. P2 as appetite allows.

Each step keeps the test suite green and changes no source behavior — this
is docs + file layout only.
