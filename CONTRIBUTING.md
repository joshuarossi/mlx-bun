# Contributing / repo rules

mlx-bun is a **software project** — a tool. The repository holds the tool:
source, tests, scripts, user-facing docs, and small tracked fixtures.
It does not hold the tool's *outputs*. The reference for what a clean
tree looks like is [ml-explore/mlx-lm](https://github.com/ml-explore/mlx-lm):
code, tests, benchmarks (code, not results), and a handful of meta files.

These rules are enforced by `scripts/check-hygiene.ts` (runs in
`scripts/test.sh` and CI): a binary/size gate, a docs-map coverage gate,
and a tracked-root allowlist.

## What goes where

| thing | home | tracked? |
|---|---|---|
| source / tests / production scripts | `src/` `tests/` `scripts/` | yes |
| one-off research & debug scripts | `scripts/experiments/` | yes (typechecked, no dead weight) |
| user-facing docs | `docs/reference/`, `README.md` | yes |
| engineering docs for ACTIVE work | `docs/design/` | yes — and **archived to `docs/archive/` when the work closes** |
| closed investigations, old plans, release notes | `docs/archive/` | yes (frozen) |
| working state | `PLAN.md` (open phases), `STATUS.md` (current handoff) | yes — closed material moves to `PLAN-archive.md` |
| curated benchmark numbers | `benchmarks/RESULTS.md` | yes |
| **raw benchmark/report output** | `reports/` | **no** (gitignored) |
| **built model artifacts** | `~/models/<Name>/` | **never in the repo tree** |
| experiment scratch (lab arms, corpora, run outputs) | `runs/` | no (gitignored, machine-local, deletable) |
| training adapters | `adapters/` or `~/.cache/mlx-bun/adapters/` | no |
| logs of any kind | nowhere in the repo | no |

## The rules

1. **No dated artifacts in git.** Anything with a date or hostname in its
   filename is a work product, not source. `benchmark.sh` and the bench
   scripts write their dumps to the working dir — move them to `reports/`
   or delete them; only distilled numbers enter `benchmarks/RESULTS.md`.
   The root allowlist gate fails CI on new tracked root files.
2. **Models are outputs.** Quantized/folded/converted snapshots go to
   `~/models/<Name>/`. The repo never contains weights beyond the small
   allowlisted test fixtures.
3. **Docs have a lifecycle.** A design doc lives in `docs/design/` while
   its work is open and moves to `docs/archive/` when the phase closes
   (same commit that closes the phase). Investigation write-ups are born
   into `docs/archive/investigations/` — they document finished work by
   definition. Every doc appears in the CLAUDE.md doc map (gate-enforced).
4. **PLAN.md is the open work, not the history.** When a phase closes,
   its block moves to `PLAN-archive.md` with a one-line pointer left
   behind. STATUS.md holds the CURRENT state and next actions only —
   superseded "where we were" entries move to `PLAN-archive.md`.
5. **Binaries need an allowlist entry** with a size cap, rationale, and
   regen path (`scripts/check-hygiene.ts` header). Goldens' `.bin` blobs
   stay untracked forever (see `goldens/README.md` and the 179 MB → 20 MB
   history rewrite that rule came from).
6. **External environments are not repos.** The pinned Python oracle
   lives at `/Users/joshrossi/Code/mlx-lm/.venv` (mlx-lm + mlx-vlm
   reference stacks; see CLAUDE.md "Reference environment"). It is an
   environment, not a checkout, and nothing like it ever appears inside
   this repository.

## Code standards

Whole-repo `tsc --noEmit` stays at 0, including `scripts/experiments/`.
Tests gate on fixture presence and skip cleanly when weights are absent.
Reference docs (cli.md, server-api.md, server-config.md, features-matrix)
update in the SAME commit as any served-surface change. Commit messages:
`<type>: <description>` (feat/fix/refactor/test/docs/chore/perf).
