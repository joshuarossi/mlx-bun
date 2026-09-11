# Public readiness — handoff (2026-09-11)

Task list and verified context for the outreach thread. The scope and
acceptance criteria for each milestone live in
[public-readiness.md](public-readiness.md); milestone state lives in
[PLAN.md](../../PLAN.md#public-readiness). This document says what was
verified today, what that changes, and what to do next, in order.

## Update after handoff

The GPTQ report is filed as [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878).
The issue contains the complete runnable reproduction and proposed fix; the
local reproduction files have been removed. Independent-reference regression
coverage and upstream follow-up remain open. Presentation changes and GitHub
metadata are also complete on this branch. The sections below preserve the
review handoff as written; their original state labels predate this update.

## What was verified today

**The listing target is stalled.** The mlx-framework.org "community" section
is a single link to [discussion #654](https://github.com/ml-explore/mlx/discussions/654);
there is no separate curated page. The pinned list in #654 was last edited
2025-10-17. Every comment since March 2026 (at least 20, including two
projects named `mlx-serve`, `mlx-node`, `atlas`, `squish`, `mlx-chronos`,
`mlx-tsfm`) has no maintainer reply and none were added. Only `awni` or an
ml-explore member with write access can edit that post.

**Awni Hannun no longer maintains MLX.** He left Apple in February 2026 (last
`ml-explore/mlx` commit 2026-02-24) and is at Anthropic. He still comments on
mlx-lm issues occasionally (last seen 2026-08-24) but is not the person who
will act on a listing request. Named successors: Angelos Katharopoulos
(`angeloskath`), Cheng Zhao (`zcbenz`), Jagrit Digani (`jagrit06`),
Anastasiia Filippova (`nastya236`), Ronan Collobert. Recent mlx-lm committers:
`michalk8`, `zcbenz`, `angeloskath`.

**The GPTQ bug is live upstream and unreported.** `mlx_lm/quant/gptq.py`
on `main` (1b3594b, 2026-09-09) still contains both defects at lines 126–127:
the `k : k + j` window that propagates past the block edge, and
`err[..., k : k + 1]` indexing a group-local buffer with a global column
index (a silent no-op for every block after the first). Issue search for
`gptq` in ml-explore/mlx-lm returns only perf/memory reports (#1094, #1098,
#1122). The reproduction is included in [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878).

**The category is crowded.** Already in the #654 thread: `mlx-serve`
(ddalcu, Zig, no Python, Gemma 4 + Qwen 3.x, MTP, TurboQuant KV, OpenAI +
Anthropic APIs), `mlx-serve` (raspoli), `mlx-node` (Node.js inference and
training APIs), `mlx-omni-server`, `squish`. "No Python OpenAI-compatible
server" is not a differentiator. "TypeScript library" needs a comparison
with `mlx-node` before it is claimed as one.

**Other places a project actually gets listed.** `raullenchai/awesome-mlx`
(466 stars, last push 2026-04-11) accepts PRs. `igurss/mlx-chronos` (last
push 2026-08-22) is a benchmark suite and leaderboard for MLX inference
engines with reproducible JSON submissions.

## What this changes

- A #654 comment is the last step and should be expected to sit. The
  outcomes that are actually reachable, in order of value: a merged or
  acknowledged upstream fix; a Show-and-tell post that a current maintainer
  replies to; an `awesome-mlx` PR; an `mlx-chronos` submission; and, if any
  of those produce a conversation with a maintainer, the listing ask goes in
  that thread rather than into the #654 pile.
- Outreach copy should not be written for Awni. It should be written for
  `angeloskath`/`zcbenz`-style readers: correctness first, measured numbers
  with machine labels, an upstream contribution in hand, no digs at mlx-lm.
- The first-impression fixes matter more, not less: a maintainer visit will
  be rare and there is one chance at it.

## State of the work (working tree, this branch)

Done or in flight in the uncommitted diff on `chore/public-readiness`:

- `docs/planning/public-readiness.md` rewritten as P0–P5; PLAN block updated.
- `docs/reference/benchmarks.md` restructured: parity table first, latest
  h2h second; campaign ledger moved to
  `docs/archive/investigations/benchmark-ledger-through-v0.4.0.md`.
- README lead paragraph narrowed to library + server; STATUS/PLAN link
  removed from the README table.
- `lab/repro/mlx-lm-gptq-block-indexing/repro.py` written (CPU-only, no
  weights; asserts the installed source matches, runs original vs corrected).
- `docs/reference/models.md` edited (roster/evidence reconciliation, partial).

Not started: oracle setup script and lock (P2), package ownership map (P3),
tarball/first-run/library-consumer verification and GitHub metadata (P4),
every outreach draft (P5).

## Tasks, in order

Each task names its owner: **agent** (can be done in a session), **Josh**
(needs approval, an account, a server, or a download). Session rules apply:
no long-running servers or multi-GB downloads from a session.

### T1 — Upstream GPTQ report (P0) — agent drafts, Josh submits

Filed 2026-09-11 as [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878)
(both defects, CPU-only fixture, observed result on 0.31.3 and upstream
`e5962529`, proposed two-line patch). Recorded in
[turboquant.md](../design/turboquant.md) and `scripts/turboquant/tq-gptq.py`.

Remaining:

1. **Open the PR.** The branch is pushed:
   [joshuarossi/mlx-lm:fix-gptq-block-indexing](https://github.com/joshuarossi/mlx-lm/tree/fix-gptq-block-indexing)
   (`d4d38d9`): the two-line change in `mlx_lm/quant/gptq.py` plus
   `tests/test_gptq.py`, which compares `gptq_quantize` against a
   column-by-column reference (paper form, no lazy block update) over four
   groups, with a single-group control. On upstream `e596252` the
   multi-group test fails (max abs dequantized diff 0.38) and the control
   passes; on the branch both pass. black 25.1.0 / isort 6.0.0 / ruff
   0.16.6 are clean. **Josh writes the PR description himself**: mlx-lm's
   CONTRIBUTING.md forbids AI-written PR text and requires disclosing how
   AI was used in the code. Same policy applies retroactively to the
   wording of #1878.
2. **Follow up.** Check the issue/PR for maintainer questions every few
   days; answer with the fixture output, not prose. Record the PR URL next
   to the issue link in turboquant.md when opened.

Acceptance: PR opened and linked from the issue; any maintainer question
answered; outcome (merged, changed, declined) recorded in turboquant.md.

### T2 — Finish the internal-voice scrub (P1) — agent

Current counts in public entry points (`rg -c "Josh"`): STATUS.md 4,
`docs/reference/environment.md` 3. `benchmarks.md` is clean after the
restructure; check the archive ledger is linked, not rendered by the site.
Also grep the website source and every `docs/reference/*.md` for
`authorized`, `diagnostic mode`, `machine policy`, `Josh requested`,
`per Josh` and rewrite as technical conditions (keep the CPU/swap/memory
facts, drop the approval framing). Do not touch `PLAN.md`/design docs for
this; they are internal by design and no longer linked from the README.

Acceptance: the greps return zero in README, STATUS, CONTRIBUTING,
`docs/reference/*`, `website/src/**`; `bun scripts/check-hygiene.ts` passes.

### T3 — Fix the site claims (P1) — agent

`website/src/content/docs/index.mdx` "Why it's different" and the numbers
table:

- "Fastest to first token … of any stack tested" → "vs `mlx_lm.server` and
  optiq serve" and state that it is server overhead at warm cache, not
  model speed.
- Remove "no segfaults on exit".
- "bit-exact to the Python reference" → "bit-exact logits vs mlx-lm on the
  validated configurations (link to the parity table)".
- Reduce the eight feature cards to library, server/API, correctness,
  measured performance; fold memory/curves/training/diffusion into one
  "also in the box" line.
- First-run model: the site shows `MiniCPM5-1B` (index.mdx:24,
  quickstart.md:16, installation.mdx:81); `DEFAULT_REPO_ID` in `src/fit.ts:88`
  is the 7 GB e4b. Pick one and make code, README and site agree.

Acceptance: `bun run --cwd website build` passes; a narrow-viewport check
of the landing page; `tests/docs-surface.test.ts` passes.

### T4 — Roster vs parity evidence (P1) — agent

`models.md` labels Qwen3.5-4B, Qwen3.8-27B and eleven Tier-0 archs L1;
the parity table in `benchmarks.md` lists four Gemma/MiniCPM rows. For each
L1 row, either add the artifact + test file to the parity table (the Qwen
oracle cases and universal goldens exist under `tests/parity/` and
`scripts/oracle/gen-universal-golden.py`) or mark the row "family-supported,
artifact-unvalidated" in the roster. No row may claim L1 without a named
test.

Acceptance: every L1 in `models.md` resolves to a row in `benchmarks.md §1`.

### T5 — Reproducible oracle (P2) — agent builds, Josh runs the clean check

1. Add a new `setup.sh` under `scripts/oracle/` (plus a committed lock, pip
   freeze or `uv` lock) that recreates the pinned venv anywhere and prints
   the `MLX_BUN_ORACLE_VENV=` line. Until the file exists, do not write its
   full path into a live doc: hygiene check 7 fails on script paths that do
   not exist, and `public-readiness.md` P2 currently trips it. Pins come from
   [environment.md](../reference/environment.md) (mlx 0.32.2, mlx-metal
   0.32.2, mlx-lm 0.31.3, Python 3.13.5).
2. Document one command chain that ends in a real pass, not a skip:
   setup → `mlx-bun get MiniCPM5` (sub-GB) → regen the MiniCPM goldens with
   `scripts/regen/minicpm5.ts` → `bun test tests/parity/minicpm5-parity.test.ts`.
   Make the test fail loudly when goldens or venv are missing.
3. Explain, in that section, machine-layered goldens and the fast-SDPA
   dispatch boundary (L ≥ 16) so a reader on another Mac knows why their
   binary goldens differ from the tracked manifest.
4. Josh: run the chain on the other dev box from a clean checkout and record
   wall time. Do not print a duration in docs until this run supports it.

Acceptance: the chain passes on a machine that never had Josh's venv path.

### T6 — Package ownership map (P3) — agent

Produce the dependency map the milestone asks for
(`reports/public-readiness/` already has source-import and dry-run
reports): which `src/` roots the `mlx-bun`, `mlx-bun/engine`, `mlx-bun/client`
exports reach, which runtime deps and native assets each needs, and what
the CLI/server/app layers add. Recommend keep-as-is or extract, with the
reason. Compare against `mlx-node`'s packaging while doing it, since that is
the closest JS-side comparison and the pitch depends on the difference.

Acceptance: the map and decision recorded in engine architecture §12.15;
no code move unless justified in that record.

### T7 — Candidate, tarball, metadata (P4) — agent prepares, Josh verifies

- `bun pm pack --dry-run` and inspect: no `reports/`, `runs/`, goldens
  blobs, or research output; `bin`, `src`, `docs` present.
- GitHub repo settings (currently empty): description, homepage
  `https://mlx-bun.dev`, topics `mlx apple-silicon bun llm metal
  openai-compatible`. `gh repo edit joshuarossi/mlx-bun --description ...
  --homepage ... --add-topic ...`.
- Josh, on a clean user account or fresh machine: `curl … | sh`, first
  `mlx-bun serve`, browser chat, one streaming request, one `openai` SDK
  call, one library consumer importing `mlx-bun/engine`. Record what broke.

Acceptance: as written in public-readiness.md P4.

### T8 — Outreach drafts (P5) — agent drafts, Josh posts

Write all four before posting any, so they agree:

1. **Discord intro** (MLX Community, verify channel first): three
   sentences, the parity command from T5, one ask ("does the TypeScript
   integration make sense to you; what would you want from the library
   API"). No numbers without a machine label.
2. **Show and tell** post on ml-explore/mlx: what it is, how to reproduce
   the parity claim, the h2h table with losses, the upstream GPTQ PR link,
   known limits, the model roster. This is the artifact a maintainer might
   actually read.
3. **awesome-mlx PR** and an **mlx-chronos** submission (check the
   submission format in that repo; our `bench-serve.ts` output may map to
   it).
4. **#654 comment**: the one-line sentence already drafted in
   public-readiness.md P5.

Post order: T1's upstream PR → Discord → Show and tell → awesome-mlx /
chronos → #654. If a maintainer replies anywhere, ask for the #654 add in
that reply.

## Do not

- Do not write copy aimed at Awni or predict Apple's reaction.
- Do not compare against mlx-lm without the machine, artifact and settings
  on the same line as the number.
- Do not claim family-wide bit-exactness; claim it per validated artifact.
- Do not start servers or multi-GB downloads from a session for T5/T7.
- Do not touch `PLAN.md`, `public-readiness.md`, `benchmarks.md`, `README.md`
  or `models.md` in this tree without checking `git status` first; another
  session was editing them on 2026-09-11.
