# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity tiers (the governing contract):** **L1** = mlx-lm bit-exact parity ·
**L2** = mlx-optiq bit-exact parity · **L3** = original optimizations beyond both,
gated by math checks + KL/quality (not bit-exactness).

## Where we are (2026-07-02)

**Current release: v0.0.10** (2026-07-02, shipped on all channels) —
batching parity with oMLX (`--batch 4` matches/beats on all three shared
models), SSD KV cold tier (`--ssd-cache`: restart TTFT 12.1 s → 0.24 s, 0%
decode overhead), `--model` real override in serve/bench, serial-lane
responsiveness fix (/stats 2.5 s → 10–44 ms mid-generation).
**In-tree version: 0.0.11, UNRELEASED** — structured output merged
2026-07-03 (next-action #1 below); `bun run release` ships it (also
updates the Homebrew formula, which still points at v0.0.10).

**Repo state:** main == origin/main, tree clean, tsc 0. CI is live
(`.github/workflows/ci.yml`: hygiene gate + typecheck + model-free tests —
the 2026-07-01 review's "no CI" finding is closed). The Phase C git history
rewrite EXECUTED 2026-07-02: `.git` 182 MB → **~8 MB on this box**, 497
historical goldens `.bin` purged, HEAD tree bit-identical, tags remapped,
force-pushed. B2 also closed same day: the last tracked multi-MB binaries
(fixture adapter safetensors) are untracked, sha256-pinned in
`scripts/fetch-test-fixtures.sh`; hygiene gate green with ZERO multi-MB
binaries tracked. **Remaining tail:** M4 Pro one-line reset
(`git fetch --tags --force --prune && git reset --hard origin/main`), then
delete `~/mlx-bun-mirror-backup-2026-07-02.tar.gz`.

**The 2026-07-02 session in one line:** oMLX adoption wave 1 (canonical
roadmap: [docs/design/omlx-adoption-map.md](docs/design/omlx-adoption-map.md))
+ the kernel-perf-review backlog fully resolved (every item landed, refuted,
or shelved with numbers — ledger:
[docs/investigations/kernel-perf-review-2026-07.md](docs/investigations/kernel-perf-review-2026-07.md))
+ repo cleanup phases A/B/C/D-gate
([docs/design/repo-cleanup-plan.md](docs/design/repo-cleanup-plan.md)).

## Next actions, ranked

1. **Structured output follow-ups** — the feature itself **MERGED to main
   2026-07-03** (was branch `feat/structured-output`, deleted after merge;
   adoption map #1 closed). `@mlc-ai/web-xgrammar` (WASM, Apache-2.0 — the
   same xgrammar oMLX uses) → per-step token-bitmask grammar-constrained
   decoding on `/v1/chat/completions` + `/v1/completions`; full
   `response_format` (json_object/json_schema) + `guided_grammar`/
   `guided_regex`/`guided_choice`/`structured_outputs` surface; L2-verified
   vs oMLX (byte-identical content through the real chat template);
   oMLX-parity degrade path (system-prompt injection + Warning header,
   never 500). Serial AND batched lanes: B0 `hasGrammar` routing + B1
   per-row matchers driven by the scheduler's read-before-build
   `#stepGrammar`, plus a module-level wasmQueue serializing ALL xgrammar
   WASM calls (the single-threaded instance corrupts under concurrent
   fills). Kill switches `MLX_BUN_GRAMMAR=0` / `MLX_BUN_GRAMMAR_BATCH=0`.
   Grammar+gateway tests 27/27 green on this box 2026-07-03 (model-free).
   Design + serial-code review + batch plan + XGrammar-2 addendum:
   [docs/design/structured-output.md](docs/design/structured-output.md).
   **Remaining:** B2 model-gated scheduler tests + bench (mixed batch,
   all-grammar B=4 with four different schemas, churn, mid-JSON
   truncation); F4 compiler cache per TokenizerInfo (agentic schema
   replay); F5 real regex support (WASM has no `fromRegex`; today only the
   regex∩EBNF subset); F6 `guided_choice` control-char escaping; F7
   structural tags for thinking models (Qwen3.5 `<think>`);
   whitespace-format parity vs oMLX (version skew, not correctness); U1/U2
   engine upgrades (rebuild WASM from current xgrammar main / native
   TVM-FFI).
2. **Menu bar app** (SwiftUI + signed binary as sidecar) — adoption map #2,
   Josh wants it; /Applications/oMLX.app is the structural reference.
3. **Batching refinements** — batching-perf-path P0–P3 (extend-join,
   vectorized sampling, admission, `--batch 4` default review) + P4
   device-side step chaining (the cpm5 single-stream −20% counter).
   [docs/design/batching-perf-path.md](docs/design/batching-perf-path.md);
   older queue: batching-v2-plan steps 4–10.
4. **SSD tier P4 hardening** — kill-mid-write e2e, adapter-ns isolation e2e,
   scheme-flip invalidation e2e.
   [docs/design/ssd-kv-cold-tier.md](docs/design/ssd-kv-cold-tier.md).
5. **oQ-style quantization spike** in `convert` (eval-gated; arXiv-lens).
6. **Web-UI fix wave** — 6 bugs, landing order in
   [docs/planning/web-ui-pass-plan.md](docs/planning/web-ui-pass-plan.md).
7. **serve `--draft-model` + remaining compat verbs** (cache_prompt,
   evaluate, awq/dwq/gptq; flags: --chat-template*, --min-p, --log-level,
   --allowed-origins, --prompt-concurrency, --prefill-step-size) —
   [docs/design/mlx-lm-tool-parity-plan.md](docs/design/mlx-lm-tool-parity-plan.md).
9. **Curve sampler H2/H3 preregistered run**
   ([docs/planning/curve-sampler-research-plan.md](docs/planning/curve-sampler-research-plan.md))
   · **dynamic-λ controller** ([docs/design/orpo-dynamic-lambda.md](docs/design/orpo-dynamic-lambda.md))
   · fit-as-recommender + memory-docs banner pass + `mlx-bun route` verb
   ([docs/planning/memory-docs-and-dag-plan.md](docs/planning/memory-docs-and-dag-plan.md)).

## Active workstreams

### Batched serving — engine live, wave-1 upgraded

`--batch N` continuous batching is live for full-attention (CPM),
sliding-window (Gemma), AND Qwen3.5 (SSM batched path, token-exact vs
mlx-lm B=2 oracle; per-row logits processors killed the hidden serial
route from its default repetition penalty). `--batch 4` matches/beats oMLX
(cpm5 349 vs 339 tok/s, e4b −3%, Qwen3.5 −1%, TTFT 2–3× better). Burst
decode (oMLX's GIL trick) built and REFUTED for Bun; reverted with
breadcrumb. `MLX_BUN_LANE_DEBUG=1` for lane tracing. Remaining polish =
next-actions #3. L2 (quantized-KV batched) and L3 (perf kernels under
batching) are later, KL-gated rows. Design:
[docs/design/parallel-slots.md](docs/design/parallel-slots.md), history in
PLAN.md Phase 18.

### Training / ORPO — stack shipped; kernel backlog cleared 2026-07-02

The full stack (flash-CCE steel head fwd+bwd, segmented backward,
prefix-sharing, `sft_scope` incl. `--sft-scope` CLI flag, warm-start,
adapters-in-cache) is live — see
[docs/reference/training.md](docs/reference/training.md). 2026-07-02
kernel-review closeout (details + evidence in
[kernel-perf-review-2026-07.md](docs/investigations/kernel-perf-review-2026-07.md)):
- **#1 LANDED**: coeff filter + blockMax skip default ON at 1e-5 — combined
  backward 1.71× CPM5 / 3.16× e4b vs exact, fidelity-gated.
- **#8 LANDED**: boundedSftCe — e4b M=6000 head 16.60 → 6.60 GB, dh relnorm
  0.0. Landing it exposed the upstream qmm M=2–3 correctness bug;
  workaround shipped (logitsFromHiddenPadM) — resolved, nothing pending.
  (The adjacent small-M perf cliff is already tracked upstream as
  ml-explore/mlx#3553, with qmv_wide merged post-0.31.2 — re-measure the
  pad workaround + small-M paths on the next mlx bump.)
- **#3 LANDED**: head auto-dispatch by M (MLX_BUN_FLASH_MIN_M=1024).
- **#9 LANDED**: segmented-step overhead — grads byte-identical, short-seq
  steps −34/−38%, @8K flat.
- **#2 REFUTED** by measurement (segment_size is the whole knob; seg1 =
  14.59 GB e4b @8K, fits the 24 GB M4 Pro). **#4 REFUTED** end-to-end and
  reverted. FUSED_DECODE×compiled-decode trace-freeze **FIXED**.
- Decode graph-build-overlap spike **REFUTED** — the pipelined loop already
  hides the host build; the recoverable decode gap is entirely GPU-side.

Open training items: chunk segmenter distillation (THE load-bearing run) ·
CPM5 UltraFeedback run PAUSED at step 4800 (checkpoints in
`adapters/cpm5-uf-8h/checkpoints/`, best = step-04200 val 1.5008; resume
via `RESUME=<ckpt>`, must launch from Josh's own shell — agent-spawned
runs get reaped) · e4b overnight (Josh runs it) · test gaps: DPO loss/e2e
untested (only dataset masking is covered, `tests/dpo-masking.test.ts`),
ORPO grad-parity scripts un-wired in `scripts/experiments/` (parity-orpo,
segmented-grad-test-*), DSpark smokes live in `scripts/` not `tests/`.

### THE DREAMING (local wiki memory) — ACTIVE, import paused

Works end-to-end on real data; staged resumable pipeline in
`src/memory/stages.ts`. In-process gateway landed (`src/memory/model.ts`);
memory batch default is 1 (serial, measured faster; `MLX_BUN_MEMORY_BATCH=8`
to opt back in). **Full-corpus import PAUSED at cursor 900/2096 (~43%)**
(`~/.mlx-bun/full-run-cursor.txt`), 923 articles in `~/.mlx-bun/wiki-full`;
that tree has 36 uncommitted files from the 2026-06-29 interruption (9
modified + ~27 untracked new articles; last commit = the cross-link pass) —
review/commit or reset before resuming via
`bun scripts/experiments/dreaming-full-run.ts`. Real vault `~/.mlx-bun/wiki`
untouched.
**Next:** resume import (~50 h serial) → reindex + `memory link` → cloud-judge
a broad sample → promote to the real vault + nightly fold-in. Handoff:
[docs/design/the-dreaming-handoff.md](docs/design/the-dreaming-handoff.md).

### DSpark speculative drafter — faithful build verified; research-only

Architecture verified faithful end-to-end (2026-07-01 adversarial review).
**Caveat:** the τ=3.24 overfit proof is a teacher-forced proxy — run
`scripts/dspark-measure-dflash.ts` (live τ) before trusting it. Two gaps to
a real speedup: DATA (160 articles → per-pos ~0.17) and TARGET (the 27B
agentic workload is the real payoff, not e4b). Not wired into serve/CLI.
**Next:** live-τ → retarget 27B/12b → scale data. Handoff:
[docs/investigations/dspark-handoff.md](docs/investigations/dspark-handoff.md).

## Josh-gated (needs hardware / downloads / own shell)

1. **M4 Pro post-rewrite reset** + delete the mirror backup tarball (see
   "Where we are"). One line, then both boxes are on rewritten history.
2. **Phase 14 — Qwen3.6-27B confirmation** (~15 GB download):
   `bun scripts/regen-qwen-parity-goldens.ts 27b` then
   `MLX_BUN_TEST_QWEN35=1 bun test tests/qwen-parity.test.ts`.
3. **Phase 13 — TurboQuant** (promoted research direction).
4. **Vision remainder** — audio tower + 26B/31B SigLIP (e4b + 12B live).
5. **e4b ORPO overnight** + resuming the CPM5 UF run (own-shell `nohup`).

(Benchmark reruns aren't tracked here — nothing is gated on them; run
`./benchmark.sh` whenever quotable numbers are wanted.)

## Recently resolved (pointers, not state)

- **v0.0.9** (2026-07-01): mlx_lm.server drop-in surface (endpoints, fields,
  logprobs, L1-faithful samplers), fuse/convert/perplexity/upload/gc verbs,
  Tier-0 generic models (11 archs), --l2 tier restoration, CI gate, curve
  sampler distinctness theorem. Full wrap archived in PLAN-archive.md.
- **2026-07-01 multi-agent review**: all six confirmed findings now closed
  except DSpark live-τ (workstream above) and the test gaps (training
  section above). Full report local at `reports/project-review-2026-07-01.md`.
- **26B gather-qmm profile** (2026-07-02): gap = mx.gather_qmm's missing M=1
  fast path; custom gather-qmv kernel built, correct, SHELVED on decisive
  numbers (dispatch fixed-cost eats the prize). Upstream is already on the
  small-M path (mlx#3553 + qmv_wide merged, gather_qqmm in flight); our only
  remaining route is a fused whole-MLP kernel in a dedicated session.
  Evidence in `scripts/experiments/`.
- **DiffusionGemma-26B port COMPLETE** · **MiniCPM5
  megakernel SHELVED** · vision SigLIP e4b, segmented backward, distribution,
  adapters e2e, expert offload E1 — all merged; history in PLAN/PLAN-archive.

## Archived handoffs

Superseded session wraps (incl. the full v0.0.9 2026-07-01 wrap, the
multi-agent review detail, DiffusionGemma history, and older handoffs) live
in [PLAN-archive.md](PLAN-archive.md). This file holds only current state.
