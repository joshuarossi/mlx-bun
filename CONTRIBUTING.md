# Contributing / repo rules

mlx-bun is a **software project** — a tool. The repository holds the tool:
source, tests, scripts, user-facing docs, and small tracked fixtures.
It does not hold the tool's *outputs*. The reference for what a clean
tree looks like is [ml-explore/mlx-lm](https://github.com/ml-explore/mlx-lm):
code, tests, benchmarks (code, not results), and a handful of meta files.

These rules are enforced by `scripts/check-hygiene.ts` (runs in
`scripts/test.sh` and CI): content-sniffed binary/size gate, root-artifact
check (tracked or not), `docs/archive/` .md-only, `scripts/` root allowlist,
doc script-path validity, design-doc front matter (status/axis/anchor),
STATUS ≤150 / PLAN ≤800 line caps, and the generated `docs/README.md` map
(`--write-docs-map`). `tests/unit/docs-surface.test.ts` diffs the served surface
(serve flags, HTTP routes) against `docs/reference/server-config.md` and
`server-api.md` in CI.

## What goes where

| thing | home | tracked? |
|---|---|---|
| source / production scripts | `src/` `scripts/` (root allowlisted; job families in `scripts/{regen,dspark,bench,oracle,memory,turboquant,examples,packaging}/`) | yes |
| tests — the directory IS the gate | `tests/unit` `tests/serve` `tests/using` (model-free, run in CI) · `tests/parity` `tests/research` (weights / oracle venv / opt-in; never in CI) · `tests/support` helpers · `tests/fixtures` | yes |
| one-off research & debug scripts | nowhere — write the finding into a doc, then delete the script (git is the archive; `scripts/experiments/` removed 2026-08-23) | no |
| user-facing docs | `docs/reference/`, `README.md` | yes |
| engineering docs for ACTIVE work | `docs/design/` | yes — and **archived to `docs/archive/` when the work closes** |
| closed investigations, old plans, release notes | `docs/archive/` | yes (frozen) |
| working state | `PLAN.md` (open phases), `STATUS.md` (current handoff) | yes — closed material is DELETED in the closing commit; git is the archive |
| curated benchmark numbers | `docs/reference/benchmarks.md` | yes |
| **raw benchmark/report output** | `reports/` | **no** (gitignored) |
| **built model artifacts** | `~/models/<Name>/` | **never in the repo tree** |
| experiment scratch (lab arms, corpora, run outputs) | `runs/` | no (gitignored, machine-local, deletable) |
| training adapters | `adapters/` or `~/.cache/mlx-bun/adapters/` | no |
| logs of any kind | nowhere in the repo | no |

## The rules

1. **No dated artifacts in git.** Anything with a date or hostname in its
   filename is a work product, not source. `scripts/bench-serve.ts all` and the bench
   scripts write their dumps to the working dir — move them to `reports/`
   or delete them; only distilled numbers enter `docs/reference/benchmarks.md`.
   The root allowlist gate fails CI on new tracked root files.
2. **Models are outputs.** Quantized/folded/converted snapshots go to
   `~/models/<Name>/`. The repo never contains weights beyond the small
   allowlisted test fixtures.
3. **One fact, one home.** Flags/defaults → `docs/reference/server-config.md`;
   routes → `server-api.md`; verbs → `cli.md`; models → `models.md`; numbers
   → `benchmarks.md`; oracle/platform facts → `environment.md`; design → the
   ONE `docs/design/<topic>.md` (new ports/features become sections, not
   files). Every design doc carries front matter
   (`status: active|landed|superseded`, `axis: ON|USING|BOTH`,
   `canonical-for`, `plan-anchor`, `last-verified`); `status: active` must
   name an open PLAN.md heading. When a topic closes, fold its durable design
   into the canonical doc and delete the source; investigation write-ups go
   to `docs/archive/investigations/` (frozen, .md only). The doc map
   `docs/README.md` is generated — never hand-edit it.
4. **PLAN.md is the open work, not the history.** When a phase closes,
   its block is deleted in the closing commit, leaving a one-line pointer
   with the durable conclusion (details land in the topic's design doc or
   `docs/reference/benchmarks.md`). STATUS.md holds the CURRENT state and
   next actions only — superseded entries are deleted, not relocated.
   Git is the archive: `git log --oneline -- PLAN.md`, and
   `git show 3199c75:PLAN-archive.md` for the pre-2026-08 closed history.
5. **Binaries need an allowlist entry** with a size cap, rationale, and
   regen path (`scripts/check-hygiene.ts` header). Goldens' `.bin` blobs
   stay untracked forever (see `goldens/README.md` and the 179 MB → 20 MB
   history rewrite that rule came from).
6. **External environments are not repos.** The pinned Python oracle
   lives at `/Users/joshrossi/Code/mlx-lm/.venv` (mlx-lm + mlx-vlm
   reference stacks; pins in `docs/reference/environment.md`). It is an
   environment, not a checkout, and nothing like it ever appears inside
   this repository.

## Code standards

Whole-repo `tsc --noEmit` stays at 0, including every script under `scripts/`.
`bun run typecheck` runs the repository, web, and portable-engine checks with the exact TypeScript
version in package.json and bun.lock; local tests and CI use this same command.
Tests gate on fixture presence and skip cleanly when weights are absent;
a test that needs weights, the oracle venv, or an `MLX_BUN_TEST_*` opt-in
lives under `tests/parity/` or `tests/research/`, never under the CI dirs.
`bash scripts/test.sh` runs hygiene → typecheck → the model-free tier →
the gated tier (two processes, so GPU residency never crosses suites).
Reference docs (server-config.md, server-api.md, cli.md, models.md)
update in the SAME commit as any served-surface change (gate: tests/unit/docs-surface.test.ts). Commit messages:
`<type>: <description>` (feat/fix/refactor/test/docs/chore/perf).
