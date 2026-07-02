# Repo cleanup plan

Status: PLANNED (2026-07-02, written post-v0.0.10). The audit behind it:
`.git` was 179 MB, driven by 497 machine-specific golden `.bin` blobs
(~290 MB working tree, every regen compounding history); root has ~30
entries of mixed tracked/untracked provenance; `repro/` was undocumented.
Already done in v0.0.10: `.bin` goldens untracked + gitignored +
`goldens/README.md` policy; CLAUDE.md root-layout map. This plan is the
rest, phased so each step is safe, reversible (except C1, which is the
point), and independently shippable.

Principle: the hygiene discipline IS the product edge — every phase ends
with a guardrail so the mess can't re-form, not just a one-time sweep.

## Phase A — root consolidation (30 min, zero risk)

- `[ ]` **A1. `lab/`**: `git mv repro lab/repro && git mv spikes lab/spikes`.
  One home for "code that proves a point but isn't the product": upstream
  bug reproductions and feasibility probes. Update the CLAUDE.md layout map
  + the two docs that reference `repro/` (grep first: `grep -rn "repro/"
  docs/ *.md`).
- `[ ]` **A2. root strays** (all untracked; no git surgery): delete
  `train.log`; move `benchmarks-e4b-flag-matrix-2026-06-15.json` into
  `reports/`; confirm `.DS_Store` is gitignored globally.
- `[ ]` **A3. `archive/` → `docs/archive/`**: the two frozen HTML reports
  are docs, not a root concern. `git mv`, update CLAUDE.md map.
- Exit: root = code (`src tests scripts`), product surfaces (`docs website
  packaging bin extensions`), fixtures (`goldens fixtures lab`), meta
  (README/PLAN/STATUS/CLAUDE + configs), and gitignored working dirs. Every
  tracked root entry appears in the CLAUDE.md layout map.

## Phase B — tracked-content policy + guardrail (1 h)

- `[ ]` **B1. Binary-in-git gate**: a CI + pre-commit check (extend
  `scripts/test.sh` or a tiny `scripts/check-hygiene.ts`) that FAILS on any
  staged file that is (a) >1 MB, or (b) matches `*.bin|*.safetensors|
  *.dylib|*.gguf|*.metallib` — outside an explicit allowlist
  (`fixtures/` ≤ 2 MB each, `lab/**/lib*.dylib` ≤ 100 KB). This is the
  "can't re-form" guarantee; the goldens episode never repeats.
- `[ ]` **B2. fixtures/ audit**: 13 MB, 2 tracked `.safetensors`. Decide
  per file: needed by the model-free CI suite → stays (they're the reason
  fixtures/ exists); only used by weight-gated tests → regen script +
  untrack, same policy as goldens.
- `[ ]` **B3. tests/ binary audit**: 27 tracked `.bin` under `tests/`
  (~small). Same rule: CI-load-bearing stays, machine-specific moves to
  the goldens regen policy.
- Exit: `git ls-files | grep -E '\.(bin|safetensors|dylib)$'` returns only
  allowlisted entries; the gate enforces it forever.

## Phase C — history rewrite (the 179 MB) — JOSH GO/NO-GO

One-time, destructive-by-design, ~15 min total. Preconditions: BOTH
laptops fully pushed (verify `git log origin/main..HEAD` empty on each);
no open PRs; a fresh `git clone --mirror` tarball kept as belt-and-
suspenders until both machines are re-cloned.

- `[ ]` **C1. rewrite**: `git filter-repo --strip-blobs-bigger-than 200K
  --path-glob 'goldens/**/*.bin' --invert-paths` (exact invocation to be
  dry-run first with `--analyze`; target: drop all historical goldens
  `.bin` while keeping every text file's history intact).
- `[ ]` **C2. force-push** `main` (+ tags), re-clone on BOTH laptops
  (M1 Max + M4 Pro), re-link local-only assets (nothing tracked is lost —
  the blobs being dropped are regenerable and already untracked at HEAD).
- `[ ]` **C3. verify**: `du -sh .git` (expect ~15–25 MB), `bash
  scripts/test.sh` green, one `scripts/regen-*` smoke to prove the regen
  path, tag `v0.0.10` still resolves + release assets untouched (GitHub
  releases store assets outside git history).
- NOT doing LFS: 290 MB of churning machine-specific artifacts is exactly
  what LFS quotas punish, and the regen scripts make the artifacts
  reproducible — a fixture server is overkill for a two-laptop project.
- Exit: fresh clone < 30 MB; both laptops on the rewritten history.

## Phase D — docs debt (follow-the-map, 1–2 h, independent)

- `[ ]` **D1.** PLAN.md is 136 KB again — move closed phases older than
  Phase 17 into PLAN-archive.md (the established pattern; keep PLAN.md
  scannable).
- `[ ]` **D2.** `docs/investigations/curve-runs/` + two untracked HTML
  strays in docs/investigations: gitignore or move under `reports/`.
- `[ ]` **D3.** The CLAUDE.md doc-map lists are hand-maintained; add a
  `scripts/check-hygiene.ts` assertion that every `docs/**/*.md` appears in
  the map (same guardrail spirit as B1).

## Ordering & ownership

A and D anytime (safe, agent-executable solo). B before the next release
(the gate should exist before more contributors/agents touch the repo).
C only on Josh's explicit go, with both laptops synced the same day —
it's the only step that can't be un-shipped.
