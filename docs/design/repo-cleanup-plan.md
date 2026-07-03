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

## What can actually be lost? Nothing. (Read this before re-litigating.)

Every binary this plan untracks or purges survives in MULTIPLE independent
places, so "we might lose the goldens/fixtures" is not a reason to stall:

1. **Both dev laptops' working trees** — `git rm --cached` and `.gitignore`
   never touch disk; the files sit exactly where they were.
2. **Git history** — until Phase C runs, every previously-committed byte is
   still in `.git` and recoverable with `git show <rev>:<path>`.
3. **The Phase-C mirror backup** — `scripts/history-rewrite.sh` refuses to
   rewrite before writing `~/mlx-bun-history-backup-<date>.tar` (a full
   pre-rewrite mirror, kept forever). Even after the purge, every historical
   blob is one `tar -x` away.
4. **Regen scripts** — goldens regenerate from `scripts/regen-*` + the
   oracle venv; the universal-rope fixtures from their gen script.
5. **Pinned-hash fetch** — the two LoRA adapter fixtures are sha256-pinned
   in `scripts/fetch-test-fixtures.sh`, sourced from the `test-fixtures-v1`
   GitHub release (one command to create — see the script header) or
   either laptop.

And no test can break: every suite that reads a binary fixture gates on
FILE PRESENCE and skips cleanly when it's absent (goldens via
tests/goldens.ts, LoRA via `haveAdapters`, universal-rope via its own
check). Untracked ≠ deleted ≠ unrunnable.

## Phase A — root consolidation (30 min, zero risk) — DONE 2026-07-02

- `[x]` **A1. `lab/`**: `git mv repro lab/repro && git mv spikes lab/spikes`.
  One home for "code that proves a point but isn't the product": upstream
  bug reproductions and feasibility probes. Update the CLAUDE.md layout map
  + the two docs that reference `repro/` (grep first: `grep -rn "repro/"
  docs/ *.md`).
  - Also updated every path reference (CLAUDE.md, PLAN.md, PLAN-archive.md,
    docs/investigations/lab-build-journal.md, docs/design/docs-reorg-plan.md,
    and the `repro/`-pointing comments in src/mlx/{ffi,array,autograd,ops}.ts
    + tests/{ffi-jit,train-autograd}.test.ts + the repro's own ISSUE.md).
- `[x]` **A2. root strays** (all untracked; no git surgery): delete
  `train.log`; move `benchmarks-e4b-flag-matrix-2026-06-15.json` into
  `reports/`; confirm `.DS_Store` is gitignored globally.
  - `train.log` deleted; benchmark json moved to `reports/`; `.DS_Store`
    already globally gitignored (`.gitignore`).
- `[x]` **A3. `archive/` → `docs/archive/`**: the two frozen HTML reports
  are docs, not a root concern. `git mv`, update CLAUDE.md map.
- Exit: root = code (`src tests scripts`), product surfaces (`docs website
  packaging bin extensions`), fixtures (`goldens fixtures lab`), meta
  (README/PLAN/STATUS/CLAUDE + configs), and gitignored working dirs. Every
  tracked root entry appears in the CLAUDE.md layout map.

## Phase B — tracked-content policy + guardrail (1 h) — DONE 2026-07-02 (B2 closed same day)

- `[x]` **B1. Binary-in-git gate**: `scripts/check-hygiene.ts` — FAILS on
  any tracked file that is (a) >1 MB, or (b) matches `*.bin|*.safetensors|
  *.dylib|*.gguf|*.metallib` — outside an explicit, size-capped, justified
  allowlist. Wired into `scripts/test.sh` (runs before tests) AND CI
  (`.github/workflows/ci.yml` `hygiene` job, gates typecheck). Supports
  `--staged` for pre-commit use. This is the "can't re-form" guarantee.
- `[x]` **B2. fixtures/ audit**: 13 MB, 2 tracked `.safetensors`.
  Decision per file:
  - `fixtures/adapters/{upper,french}/adapters.safetensors` (6.6 MB each):
    KEEP tracked, on the gate's explicit allowlist (cap 7 MB). They are
    stable one-time-trained LoRA adapter INPUTS (trained 2026-06-10, never
    churned) for the opt-in `MLX_BUN_TEST_LORA` hot-swap test, which also
    requires the e4b base. The tracked `adapter_config.json` + `data-*/`
    jsonl fully describe how to reproduce them; a bit-exact regen script
    (trainer-of-record: optiq `lora train` vs mlx-lm — the saved config is
    ambiguous) is a Josh task to confirm + smoke. NOT untracked now because
    an untested untrack would break the lora hot-swap parity test, and these
    do not churn (the goldens-bloat problem was *churning* artifacts). This
    is a deliberate allowlist exception, not the default `fixtures/ ≤ 2 MB`
    policy.
  - **CLOSED later the same day**: untracked + gitignored after pinning the
    bytes by sha256 in `scripts/fetch-test-fixtures.sh` (fetch from the
    `test-fixtures-v1` release / either laptop / pre-rewrite history; the
    gated LoRA test skips cleanly when absent — verified). The regen-
    ambiguity concern was real but orthogonal: preservation is by pinned
    original bytes, not by retraining. Allowlist entry removed; gate green
    with ZERO multi-MB binaries tracked.
- `[x]` **B3. tests/ binary audit**: 27 tracked `.bin` under
  `tests/fixtures/universal-rope/` (4–8 KB each, ~108 KB total). All are
  model-free CI-load-bearing bit-exact oracle fixtures (used by
  `tests/universal-rope.test.ts`, which skips cleanly if absent),
  regenerated by `scripts/gen-universal-rope-fixtures.py`. STAY, on the
  allowlist (cap 16 KB each). Also allowlisted: `tests/fixtures/qwen-delta-golden.json`
  (1.08 MB text JSON golden, model-free, regen script exists).
- Exit: `git ls-files | grep -E '\.(bin|safetensors|dylib)$'` returns only
  allowlisted entries; the gate enforces it forever.

## Phase C — history rewrite (the 179 MB) — DONE 2026-07-02 (Josh go)

Executed 2026-07-02 on Josh's explicit go. Result: `.git` **182 MB →
20 MB**. Notes on what actually ran (vs the sketch below):

- C1: dry-run `--analyze` confirmed goldens `.bin` = the entire bloat.
  Actual invocation, narrower than sketched (no size threshold needed):
  `git filter-repo --invert-paths --path-glob 'goldens/*.bin'
  --path-glob 'goldens/*/*.bin'` — both globs needed because git
  pathspec `**` doesn't span the flat + one-deep layout; covers all 497
  historical blobs. Verified pre-push: 343 commits in/out, HEAD tree
  bit-identical to original, zero `.bin` left anywhere in goldens
  history, tags remapped.
- C2: force-pushed main + branches + tags. Mirror backup at
  `~/mlx-bun-mirror-backup-2026-07-02.tar.gz` (143 MB) — delete once
  both boxes verified. M1 Max done: fetch --force + reset --hard,
  surviving branches remapped, stale agent-session worktrees/branches
  deleted (Josh: only main matters), stray `refs/codex`/`refs/original`
  pruned, reflog expired, gc'd to 20 MB. **M4 Pro remaining (Josh)**:
  `git fetch origin --tags --force --prune && git reset --hard
  origin/main` (or fresh clone).
- C3: `v0.0.10` resolves; release assets untouched (they live outside
  git history); hygiene gate green; regen path proven live —
  `bun scripts/regen-fused-sdpa-goldens.ts` rewrote
  `goldens/apple-m1-max/fused-sdpa.{json,bin}`. The full suite could not
  be run from the executing session (tooling restriction); run it once
  per box as the final check.

**Now ONE COMMAND**: `scripts/history-rewrite.sh` (dry-run by default,
`MLX_BUN_REWRITE_GO=1` to execute) — it enforces every precondition below,
writes the permanent mirror backup first, purges goldens `.bin` + the
adapter safetensors from history, force-pushes, and prints the re-clone
steps for the other laptop.

One-time, destructive-by-design, ~15 min total. Preconditions: BOTH
laptops fully pushed (verify `git log origin/main..HEAD` empty on each);
no open PRs; a fresh `git clone --mirror` tarball kept as belt-and-
suspenders until both machines are re-cloned.

- `[x]` **C1. rewrite**: `git filter-repo --strip-blobs-bigger-than 200K
  --path-glob 'goldens/**/*.bin' --invert-paths` (exact invocation to be
  dry-run first with `--analyze`; target: drop all historical goldens
  `.bin` while keeping every text file's history intact).
- `[x]` **C2. force-push** `main` (+ tags), re-clone on BOTH laptops
  (M1 Max + M4 Pro), re-link local-only assets (nothing tracked is lost —
  the blobs being dropped are regenerable and already untracked at HEAD).
- `[x]` **C3. verify**: `du -sh .git` (expect ~15–25 MB), `bash
  scripts/test.sh` green, one `scripts/regen-*` smoke to prove the regen
  path, tag `v0.0.10` still resolves + release assets untouched (GitHub
  releases store assets outside git history).
- NOT doing LFS: 290 MB of churning machine-specific artifacts is exactly
  what LFS quotas punish, and the regen scripts make the artifacts
  reproducible — a fixture server is overkill for a two-laptop project.
- Exit: fresh clone < 30 MB ✓ (20 MB); M1 Max on rewritten history ✓;
  M4 Pro pending its one-line reset (see notes above).

## Phase D — docs debt (follow-the-map, 1–2 h, independent) — gate DONE 2026-07-02

- `[~]` **D1.** PLAN.md is 139 KB — move closed phases older than Phase 17
  into PLAN-archive.md (the established pattern; keep PLAN.md scannable).
  - **Finding (2026-07-02):** no candidates currently. Every phase <17 in
    PLAN.md (6, 7, 12, 13, 14, 15, 16) is marked `[~]` or `[ ]` — none are
    `[x]`/CLOSED, and the established archive pattern archives only
    `[x]`-marked phases. Phases 6 and 16 have *all* their checkboxes
    checked but carry a deliberate `[~]`; reclassifying them to closed +
    archiving is a Josh state-call (they may have ongoing narrative
    threads). The closed `oMLX` phase (2026-07-02) and Phase 19 are
    *newer* than 17, so they stay in PLAN.md as recent history per the
    criterion. Revisit D1 when a <17 phase is confirmed closed.
- `[x]` **D2.** `docs/investigations/curve-runs/` + two untracked HTML
  strays in docs/investigations: gitignore or move under `reports/`.
  - Already satisfied: `docs/investigations/curve-runs/` is gitignored
    (`.gitignore`), and the four HTML strays (`curve-terrain.html`,
    `hlg-ab.html`, `hlg-report.html`, `hlg-explorer.html`) are gitignored
    via `docs/investigations/*.html`. No action needed.
- `[x]` **D3.** The CLAUDE.md doc-map lists are hand-maintained; add a
  `scripts/check-hygiene.ts` assertion that every `docs/**/*.md` appears in
  the map (same guardrail spirit as B1).
  - Implemented in `check-hygiene.ts` (`docs-map` check). First run caught
    10 drifted docs (3 design, 1 investigation, 6 planning) — all added to
    the CLAUDE.md map. Gate now green; CI enforces it on every push/PR.

## Ordering & ownership

A and D anytime (safe, agent-executable solo) — DONE 2026-07-02. B gate
DONE 2026-07-02 (B2 adapter-untrack deferred to Josh — see B2 finding).
C executed 2026-07-02 on Josh's explicit go — only remaining tail is the
M4 Pro reset + deleting the backup tarball once both boxes are green.
