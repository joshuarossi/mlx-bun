# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity tiers (the governing contract):** **L1** = mlx-lm bit-exact parity ·
**L2** = mlx-optiq bit-exact parity · **L3** = original optimizations beyond both,
gated by math checks + KL/quality (not bit-exactness).

**Current release: v0.0.8** (2026-06-24) — npm + Homebrew + GitHub.

## SESSION WRAP 2026-07-01 — main is PUSH-READY. Release sequence: `git push` → `bun run release` IN THE SAME SITTING

(The site auto-deploys from the push via GitHub Pages and already documents
v0.0.9 behavior — binaries must follow immediately or fresh users hit a
port-8080-docs/port-8090-binary mismatch.) Release notes DRAFT:
[docs/planning/release-notes-v0.0.9.md](docs/planning/release-notes-v0.0.9.md).

**Landed today (~35 commits, all verified, tsc 0, no Claude trailers):**
mlx_lm.server drop-in surface complete (endpoints/fields/flags/logprobs,
L1-faithful sampler ports) · verbs: fuse/convert/perplexity/upload/gc ·
ORPO `sft_scope` (paper/TRL-faithful default; `response` bit-exact pinned) ·
Tier-0 generic models (UniversalDense, 11 archs; llama/qwen2/gemma2 verified
bit-exact) · 12+1 kernel-review bug fixes incl. the **--l2 tier restoration**
(perf kernel demoted to --l3 — envelope-gated, evidence in 381382c) ·
batching v2 steps 1–3 (capability gate, containment, drain, pipelining) ·
registry canonical dedupe + gc (~24.7GB found; NOT deleted — see task
notes on the 12B vision-weights decision + tests/paths.ts pins first) ·
pi integration 10 fixes (generics tool-calling, memory tools, harness) ·
website+README six-goals pass (23 pages; deploy release-gated) · CI gate ·
batched goldens machine-keyed (the "regression" was M4-Pro fixtures; ALL
code exonerated, 11/11 green) · decode-roofline look-again (**the floor
claim was wrong** — only the 12B is at the wall; docs/investigations/
decode-roofline-lookagain.md) · curve-sampler distinctness THEOREM + witness
(TV 0.11–0.19 at forks unreachable by any truncation sampler; old "wash"
verdict invalidated — it measured the wrong sampler; preregistered protocol
in docs/planning/curve-sampler-research-plan.md).

**Next actions, ranked (each has a tracked plan):**
1. Josh: push + publish v0.0.9 (sequence above), then optionally `gc --yes`
   after the 12B-vision decision + test-pin updates.
2. Kernel backlog #1 — flip the measured 1.35× coeff filter
   (docs/investigations/kernel-perf-review-2026-07.md) + the decode
   graph-build-overlap spike (the roofline doc's top fix).
3. Web-UI fix wave (docs/planning/web-ui-pass-plan.md — 6 bugs, landing order inside).
4. Batching steps 4–10 (docs/design/batching-v2-plan.md).
5. serve --draft-model + remaining verbs (docs/design/mlx-lm-tool-parity-plan.md).
6. Curve H2/H3 preregistered run (docs/planning/curve-sampler-research-plan.md).
7. Dynamic-λ controller build (docs/design/orpo-dynamic-lambda.md).
8. fit-as-recommender; memory-docs banner pass + `mlx-bun route` verb
   (docs/planning/memory-docs-and-dag-plan.md); DSpark live-τ.
Open kernel bug (deferred, file was owned): FUSED_DECODE×compiled-decode
trace-freeze — docs/investigations/kernel-perf-review-2026-07.md "STILL OPEN".

## Multi-agent review + cleanup (2026-07-01) — verified state, open decisions

Two adversarially-verified review workflows (13 agents) swept the whole repo; the
full report is local at `reports/project-review-2026-07-01.md` (gitignored). What
landed the same day: repo hygiene sweep (scratch logs/example.ts/pycache/runs
untracked; megakernel → `scripts/experiments/`; orphan worktree removed;
`fix/section-synthesis` third-person-voice fix **merged**), docs truth pass (this
file rewritten; flash-attn story reconciled; README/CLAUDE.md doc map refreshed).

**Confirmed findings, still open (ranked):**
1. ~~**ORPO L_SFT scope divergence**~~ **DONE 2026-07-01** — `sft_scope:
   full|response` landed across every ORPO path (naive/chunked/fused/flash /
   prefix-shared / all four segmented classes), **default `full`**
   (paper/TRL-faithful: chosen-NLL = token-mean CE over the full
   prompt+response, only padding excluded, from the same chosen forward);
   `response` reproduces old runs bit-exactly (regression-pinned in
   `tests/train-orpo.test.ts`). The odds-ratio ℓ terms stay response-only in
   BOTH modes (matches TRL). Config: TrainConfig `sftScope` / job `sft_scope` /
   `SFT_SCOPE=` env in `scripts/train-orpo.ts`. Cross-path full-scope parity +
   an sftLoss(promptLen=1) oracle wired in `tests/train-orpo-fused-ce.test.ts`.
   Docs: `docs/design/orpo-training.md` (“The objective” — resolved note),
   `docs/reference/training.md` (config table + ORPO section). Remaining: the
   one-line `--sft-scope` CLI flag in `src/cli.ts` (file owned by another
   workstream at land time).
2. **DSpark τ=3.24 is a teacher-forced proxy** — `evalTau` feeds the Markov head
   ground-truth previous tokens; live decode threads the drafter's own drafts.
   Run `scripts/dspark-measure-dflash.ts` (live τ via `meanAcceptLen`) on the
   overfit checkpoint before the 27B retarget. Architecture itself verified
   faithful (see DSpark section).
3. ~~**Memory batching default**~~ **DONE 2026-07-01** — `memoryBatchSize()`
   default flipped 8 → 1 (serial, bit-exact; batching measured 1.7–1.9× slower).
   Opt back in with `MLX_BUN_MEMORY_BATCH=8`.
4. **No CI** — the only GitHub workflow deploys the website; nothing runs
   `bunx tsc --noEmit` or `bun test` on push. Add a gate.
5. **Test gaps** — DPO has zero loss/e2e tests; ORPO fused-CE tests assert only
   "loss decreases" (real grad-parity checks live un-wired in
   `scripts/experiments/`); DSpark smoke tests live outside `tests/`.
6. ~~**`mlx-bun memory status`** stub text~~ **DONE 2026-07-01** — status +
   help now report synthesis as available (`mlx-bun memory synthesize`).

**In progress (Josh directive 2026-07-01):** CLI flags/defaults parity with
`mlx_lm.server` + implement all missing mlx-lm functionality. Done 2026-07-01:
default port 8090 → 8080, default host all-interfaces → 127.0.0.1 (loopback,
`--host 0.0.0.0` = LAN opt-in), `--temp` alias for `--temperature`,
`--decode-concurrency` semantics documented honestly (accepted for drop-in
compat; enables continuous batching with that cap, not mlx-lm's
per-BatchGenerator parallelism); L1-faithful min_p/XTC/presence+frequency
penalties/logit_bias in the sampler AND wired end-to-end through all three
protocol surfaces (mlx-lm wire names incl. `*_context_size`; serial-lane-only
under `--batch N`, v1); `POST /v1/completions` (raw text completion,
non-stream + SSE, no chat template, mlx-lm's 512 default max_tokens);
`GET /health` (byte-exact mlx-lm body); `/v1/models` lists served model first
+ all registry-known supported models, `/v1/models/<id>` filter; serve
`--adapter <dir>` (+ `--adapter-path` alias) mounts at startup and becomes the
request default (fixes the `mlx-bun train` completion-message inconsistency);
`logprobs`/`top_logprobs` end-to-end on chat + text completions — mlx-lm's
EXACT semantics (distribution = post-processor pre-truncation log-softmax,
generate.py L409-422; response = server.py generate_response's id-keyed block,
NOT OpenAI's; validation bool + int∈[0,11]∪{-1}; stream chunks carry no
logprobs, faithfully — mlx-lm never emits them when streaming; serial-lane-only
under `--batch N`; zero-cost when not requested).
Tests: tests/server-compat.test.ts. Also done 2026-07-01: `fuse`/`convert`/
`perplexity` verbs, server `--max-tokens`; `upload` verb (mlx_lm.upload
--path/--upload-repo parity over native `src/hf-push.ts`, + `convert
--upload-repo` runs the push after converting; tests/cli-upload.test.ts);
`--sft-scope full|response` on `mlx-bun train` (CLI spelling for the trainer's
`sft_scope`); 14-finding CLI audit applied (fit --ctx help→8192 = code, embed
no-query auto-picks a downloaded embedding model instead of a chat starter,
pi flag-strip covers --batch/--adapter/--hlg-*/--no-open/--l1-3, `setup` is a
true `memory` alias + unknown memory subcommands exit 1, --l1/--l2/--l3 +
generate + train-watch documented in help, doc lies fixed in memory.md /
server-config.md). Remaining gaps (verified vs the oracle venv): no
`--draft-model`/
`--num-draft-tokens`/`--chat-template*`/`--min-p`/`--log-level`/
`--allowed-origins`/`--prompt-concurrency`/`--prefill-step-size` flags;
CLI verbs cache_prompt/evaluate/awq/dwq/gptq absent.
Deliberately not ported: `role_mapping` (mlx-lm's synthetic "USER:/ASSISTANT:"
prompt assembly, used ONLY when a tokenizer has no chat template — every
mlx-bun-supported model ships a real template, so the branch is unreachable
here). Known adjacent gap: `/v1/responses` logprobs — OpenAI's Responses API has its
own knob (`include: ["message.output_text.logprobs"]` + `top_logprobs`); the
optiq shim oracle accepts flat `logprobs`/`top_logprobs` fields and validates
them (responses_server.py L195-196) but its output translation DROPS the block
(zero logprobs mentions in responses_shim.py), so no reference emits Responses
logprobs. Ours doesn't map the fields at all; deferred until a client needs it.
`/v1/messages` (Anthropic) has no logprobs in the protocol — correctly absent.

## THE DREAMING (local personal-wiki memory) — ACTIVE. Handoff: [docs/design/the-dreaming-handoff.md](docs/design/the-dreaming-handoff.md)

Conversations → chunks → entities → **subject articles** → cross-linked,
self-healing wiki, all local (`src/memory/`). **Works end-to-end on real data.**
Staged, chronological, resumable pipeline (`stages.ts`): segment (our
e4b-chunk-300 chunker) → extract → route (surface-EVERYTHING) → create/patch
(self-healing, date-aware, `## History`) → reconcile → link (18%→96% See-also,
22.7× edges) → wikify. Reference: [docs/reference/memory.md](docs/reference/memory.md).

- **Inference-path rework LANDED** (`src/memory/model.ts`): the in-process
  gateway design from [docs/design/memory-inference-path.md](docs/design/memory-inference-path.md) —
  ONE shared TaskModel + mounted chunk adapter + BatchScheduler,
  `callLocal`/`callLocalBatch`, template fix ({system,user}) included. (The old
  "wire through a persistent HTTP server" framing is obsolete — the design doc
  chose in-process.) Known issue: batch default 8 vs measured-better serial (open
  finding #3 above).
- **Third-person voice + Wikipedia carve-outs fix merged** (was stranded on
  `fix/section-synthesis`; merged 2026-07-01).
- **Full-corpus import PAUSED at cursor 900/2096 (~43%)** (677+ articles in
  `~/.mlx-bun/wiki-full`); resumable via
  `bun scripts/experiments/dreaming-full-run.ts`. NOTE: the wiki-full git tree
  has ~11 uncommitted mid-batch article edits from the 2026-06-29 interruption —
  review/commit or reset before resuming. Real vault `~/.mlx-bun/wiki` untouched.
- **Standing rules:** notability = "recurs in your thinking" (no ownership gate);
  subject-based articles; chronological; cross-linking is WIKIFY's job; prompts
  SCHEMATIC; Lucien = read-only oracle; quality judged by CLOUD JUDGE, never bucket-F1.
- **Next:** flip batch default → resume import (~50h serial) → reindex +
  `memory link` → judge a broad sample → promote to the real vault + nightly fold-in.

## DSpark speculative drafter — faithful build done; architecture verified 2026-07-01. Handoff: [docs/investigations/dspark-handoff.md](docs/investigations/dspark-handoff.md) · Design: [docs/design/dspark-speculative-decoding.md](docs/design/dspark-speculative-decoding.md)

Faithful DSpark = DFlash multi-layer KV injection (Eq 2–3) + Markov head +
confidence head, `src/spec/dspark/*-dflash.ts` (v1 `*.ts` kept as superseded
baseline). The 2026-07-01 adversarial review verified the implementation faithful
end-to-end: Eq 2–3 injection, masks, heads, position embeddings, the p^t/TV
off-by-one fix, no target leakage, and the sliding-window `trim(n,bypass)`
rollback all confirmed correct. Repo typechecks 0; CPU smokes 16/16 + 33/33.
- **Caveat (review finding #2):** the overfit proof (per-pos ~0.75, τ 3.24) is a
  **teacher-forced analytic proxy** — measure live τ with
  `scripts/dspark-measure-dflash.ts` before trusting it for the decode loop.
- **Two gaps to a real speedup (not architecture):** (1) DATA — 160 articles
  generalize to per-pos ~0.17 (paper uses 1.3M×10). (2) TARGET SPEED — e4b
  (45.9 tok/s) is ~worst-case for the fixed draft overhead; the **27B agentic
  workload is the real target** (τ≈3 could net ~2–3×).
- Not wired into serve/CLI (research-only); smoke tests live in `scripts/` not
  `tests/` (review finding #5). Minor: v1 loader lacks a checkpoint-variant guard.
- **Next:** live-τ measurement → retarget 27B/12b (regen+train; 27B/32GB is
  memory-tight) → scale data → tighten draft loop → RNN head + STS + Alg-1
  scheduler → rename dflash→dspark.

## ORPO / training stack — shipped in v0.0.5+; open items

The full stack (flash-CCE steel head fwd+bwd, segmented backward, prefix-sharing,
`mlx-bun train` CLI, warm-start, adapters-in-cache) is live — details in
[docs/reference/training.md](docs/reference/training.md) +
[docs/reference/orpo-quickstart.md](docs/reference/orpo-quickstart.md) +
[docs/investigations/steel-flash-cce-handoff.md](docs/investigations/steel-flash-cce-handoff.md).
- **Open decision:** L_SFT scope (review finding #1 above).
- **The chunk segmenter** (THE load-bearing run): distill Opus/GPT-5.5
  segmentation into a local model; scored by boundary/label accuracy vs gold
  (chunk-eval), NOT val loss.
- **CPM5 UltraFeedback dress-rehearsal** PAUSED ~step 4820 (val 1.66→~1.50
  plateau; checkpoints in `./adapters/cpm5-uf-8h/checkpoints/`, best ~step-04200);
  resumable via `RESUME=<ckpt>`. Long runs MUST be launched from Josh's own shell
  (`nohup … &`) — agent-spawned runs get reaped (~47 min).
- **The e4b overnight** — `scripts/train-orpo.ts` full stack at 8192 (Josh runs it).
- Flash-attn kernel status (reconciled 2026-07-01): port bugs fixed +
  FD-validated at T≤256; e4b ≥2K re-validation pending; ~30× slower — default
  `ops.sdpa` remains the path.
- Test gaps: DPO untested; grad-parity scripts un-wired (review finding #5).

## Batched serving (Phase 18) — engine live; polish open

`--batch N` continuous batching is live for full-attention (CPM) AND
sliding-window (Gemma), bit-parity with mlx-lm B=N; scheduler + gateway wired
into the server. Full history in PLAN.md Phase 18 / PLAN-archive; design:
[docs/design/parallel-slots.md](docs/design/parallel-slots.md).
Remaining polish (all optional): `extend` join op (today a join re-merges,
O(B·S)), prompt-cache reuse under batching, `B×S_max` KV-budget admission,
clean-machine throughput numbers (Josh-gated). L2 (quantized-KV batched) and L3
(perf kernels under batching) are later rows — batched + mixed-precision KV is a
novel extension (no oracle), KL-gated, deferred.

## Open / Josh-gated

These need Josh physically (hardware, downloads, reboots):

1. **Clean-machine `./benchmark.sh --redo`** after a reboot (+ `sudo purge`) —
   quotable rows; promote into `benchmarks/RESULTS.md`. Also gates the
   `MLX_BUN_PERF_KERNEL` default flip and DiffusionGemma D4 perf numbers.
2. **M1 Max rerun** — `git pull` then `./benchmark.sh --redo`.
3. **Phase 14 — Qwen3.6-27B confirmation** (~15 GB download):
   `bun scripts/regen-qwen-parity-goldens.ts 27b` then
   `MLX_BUN_TEST_QWEN35=1 bun test tests/qwen-parity.test.ts`. 4B both bars green.
4. **Phase 13 — TurboQuant** (promoted research direction).
5. **Vision remainder** — audio tower + 26B/31B SigLIP (e4b + 12B live).
6. **The e4b ORPO overnight** + resuming the CPM5 UF run (own-shell `nohup`).

## Recently completed (pointers, not state)

- **DiffusionGemma-26B-A4B-it port — COMPLETE** (D1 bit-exact forward, D2
  token-for-token denoising, D3 text+image serving, D5 diffusion-LoRA; D4 perf is
  Josh-gated bench). Dossier: [docs/design/diffusion-gemma-port.md](docs/design/diffusion-gemma-port.md).
- **MiniCPM5 decode megakernel — SHELVED** (research only; mlx per-op is already
  near the bandwidth floor at M=1). Code now in `scripts/experiments/`; findings
  in PLAN-archive + [[megakernel-qmv-port-win]].
- **Vision SigLIP sidecar (e4b), segmented backward (Phases A+B), distribution
  (npm/brew/install.sh), onboarding, adapters end-to-end, expert offload E1,
  batching bring-up** — all merged; history in PLAN.md / PLAN-archive.md.

## Archived handoffs

Superseded session summaries (incl. the full DiffusionGemma incremental history,
the 2026-06-17 "current state" block, and the 06-10/06-11 handoffs) live in
[PLAN-archive.md](PLAN-archive.md). This file holds only current state.
