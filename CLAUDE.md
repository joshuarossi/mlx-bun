# CLAUDE.md — agent entry point for mlx-bun

**What.** A Bun/TypeScript inference engine + OpenAI-compatible server for
Apple Silicon on MLX: bit-exact with mlx-lm by contract (L1), with
mlx-optiq mixed-KV as the second oracle (L2) and a no-oracle Lab tier that
must win a paired A/B before any default. Single binary; JS library too.

**Where to read, in order.**
1. [STATUS.md](STATUS.md) — current state, threads, next action (≤150 lines).
2. [PLAN.md](PLAN.md) — open work with exit criteria (≤800 lines). Closed
   history is git: `git log --oneline -- PLAN.md`, `git show 3199c75:PLAN-archive.md`.
3. [CONTRIBUTING.md](CONTRIBUTING.md) — the rules, every one gate-enforced.
4. [docs/README.md](docs/README.md) — generated map of every doc. One fact,
   one home: flags/defaults → `docs/reference/server-config.md` · routes →
   `server-api.md` · verbs → `cli.md` · models → `models.md` · numbers →
   `benchmarks.md` · oracle/machines/platform gotchas → `environment.md` ·
   design → the one `docs/design/<topic>.md` (front matter carries status).

**Ground rules (repo-specific; global ones live in ~/.claude/CLAUDE.md).**
- Never start long-running servers or multi-GB downloads from a session.
  Josh runs servers (`/Users/joshrossi/Code/mlx-lm/serve.sh` is the Python
  reference server); curl against a running one is fine. Ask before
  anything persistent. Never touch the GPU while a training run is active.
- Logit parity with the pinned oracle venv is the correctness oracle
  ([environment.md](docs/reference/environment.md) has the path and pins).
  Copy the oracle op-for-op, prove identity, then optimize. A perf gap vs
  mlx-lm/optiq is OUR bug until proven otherwise.
- Every perf claim gets a number on a named machine (two dev boxes, neither
  canonical); quotable numbers come from `bun scripts/bench-serve.ts all`
  on a quiet machine and land only in `docs/reference/benchmarks.md`.
- Docs land WITH the feature in the same commit: a served-surface change
  updates server-config/server-api/cli — `tests/docs-surface.test.ts` and
  `bun scripts/check-hygiene.ts` fail otherwise. Regenerate the map with
  `bun scripts/check-hygiene.ts --write-docs-map`.
- Work the plan: take the next unchecked box in PLAN.md; when a phase
  closes, delete its block (leave a one-line pointer) — nothing moves to an
  archive file.
- Research one-offs: write the finding into the topic's doc, then delete
  the script. `scripts/` is production tooling only (allowlisted).

**Skills** (`.claude/skills/`): `/bench` quotable h2h · `/parity-regen`
goldens from the oracle · `/release` signed+notarized publish (never
without Josh's go) · `/docs-hygiene` close a phase without sprawl.

**Layout.** `src/` engine+server+CLI · `tests/` (weights-gated suites skip
cleanly) · `scripts/` tooling + `scripts/{oracle,memory,turboquant,examples,packaging}/`
· `docs/` per the map · `website/` generated from `docs/reference/` ·
`goldens/` tracked manifests, untracked machine-specific blobs · `fixtures/`
tiny CI inputs · `lab/repro/` upstream-bug repros · `bin/` npm launcher.
Untracked, machine-local: `runs/ adapters/ reports/ dist*/` (`bun run clean`).

`AGENTS.md` is a symlink to this file.
