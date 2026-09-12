# PLAN — the open work

Everything below is UNFINISHED. A thread closes by DELETING its block: the
durable conclusion belongs in the canonical doc for its topic (`docs/design/*.md`,
`docs/reference/*.md`), never in a findings narrative here (CONTRIBUTING.md rule 4).
Markers: `[ ]` todo, `[~]` in progress. Hard cap 800 lines, gate-enforced by
`bun scripts/check-hygiene.ts`.

- Live state / next action: [STATUS.md](STATUS.md). Doc map: [docs/README.md](docs/README.md).
- Closed phases and their findings: `git log --oneline -- PLAN.md`;
  pre-2026-08 history is `git show 3199c75:PLAN-archive.md`.
- Headings quoted by a design doc's `plan-anchor:` are load-bearing —
  `grep -n 'plan-anchor:' docs/design/*.md` before renaming one.

## Public readiness

Goal: first-visit clarity and reproducible correctness; upstream contribution, Discord, Show and tell, then listing. [Acceptance](docs/planning/public-readiness.md).

- [~] P0: Both GPTQ defects reported in [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878); fix and regression test open as [mlx-lm PR #1880](https://github.com/ml-explore/mlx-lm/pull/1880). Review follow-up remains.
- [~] P1: Remove internal voice, restructure benchmarks and reconcile roster evidence; verify public presentation.
- [~] P2: Pinned oracle setup and MiniCPM clean-start comparison pass (100 exact vectors/tokens); finish per-roster artifact/run provenance.
- [~] P3: Settle package/API ownership from dependency and asset evidence; preserve published imports.
- [ ] P4: Verify candidate packaging, first-run/library demo and repository metadata; reuse matching evidence.
- [ ] P5: Review and post Discord intro, incorporate feedback in Show and tell, then submit the listing comment.

## Design principles

- **Logit parity is the oracle.** Every OptiQ model also runs on stock mlx-lm; that shared subset is the FLOOR and mlx-lm is
  its bit-exact oracle (a divergence is our bug until proven otherwise). optiq's additions (LoRA hot-swap, rotating KV-quant,
  fused prefill, MTP, SigLIP, TurboQuant) are the L2 ceiling, with the venv source as the reference.
- **The oracle for a capability is whoever already ships it.** Read it, copy it op-for-op, prove identity, then optimize. "No
  oracle" is the only place we invent, and those go behind the Lab tier (KL/eval + a paired A/B win before any default).
- **Measure the limiting resource.** Weight traffic, decode arithmetic, occupancy, dispatch, synchronization and memory
  pressure can each limit a regime. Profile the critical path before choosing a kernel or host rewrite.
- **Weight buffers are immutable and shared.** Read headers for inventory; native MLX loads tensor bytes lazily into its own
  Metal-visible buffers. Avoid extra resident copies in retained optimizations.
- **Every perf claim gets a number on a quiet machine**, labeled host/chip/RAM, recorded in the eval DB. Numbers off a loaded
  box are not quotable.
- **Scope is the survival strategy.** Gemma (3/4), Qwen (3.x), GLM/Colibri, one MoE family. Not parity with mlx-lm's dozens.
- **Docs land WITH the feature.** A change to the served surface updates server-config.md / server-api.md / cli.md / README
  in the SAME commit.
- **Separate concerns through interfaces.** Scheduling chooses work; inference methods advance it; model backends execute it;
  the shared cache retains reusable state from both prefill and decode. RAM/SSD placement belongs to storage. Resolve
  configuration once by concern. Preserve fused execution, buffer ownership and overlap; measure the complete request after
  extraction. Reuse existing optimized kernels and keep developing faster specializations. Fuse work, remove operations and
  avoid materialization where measurements support it. Keep scheduling changes separate from kernel experiments in A/Bs.

## Reference environment

Machines, oracle venv pins, weight paths, HF/network quirks and baselines live in **[environment.md](docs/reference/environment.md)**.
Do not duplicate them here. Neither dev box is canonical; every recorded number carries its host.

## Testing strategy

`bun test` only — one toolchain, no vitest.

- **Unit (every run):** header parsing, config/quant metadata, chat templates,
  registry, mask builders. Fixture-driven, model-free.
- **Golden-file oracle (the safety net):** regen scripts run the pinned Python
  reference and dump goldens; regeneration is always an explicit command. The
  parity bar is tiered:
  - **(a) bit-exact `toBe(0)`** — single-forward logits from identical state,
    for stock decode and every quantized-KV path. Cross-stack always sits here.
  - **(b) bounded tolerance** — only for paths that differ BY DESIGN inside our
    own stack (tiled-vs-unfused SDPA, gather_qmm-vs-quantized_matmul).
  - **(c) speculation** — exact equality on tie-free prompts; otherwise
    long-prefix agreement plus accept/reject trace equality vs the reference.
  - **(d) router/MoE** — bit-exact single-forward logits with explicit gate
    tie-break handling.
  - **(e) batched** — bit-exact vs **mlx-lm at the same B**, never vs our own
    B=1. Padded rows carry a KL bound (batching changes reduction order).
  Whole-trajectory equality is never the bar: greedy trajectories are
  loop-shape-sensitive past bf16 ties, inside mlx-lm as much as here.
- **Machine-layered goldens.** Logit goldens are bit-exact only on the GPU that
  produced them (M1 vs M4 metallibs diverge at the fast-SDPA dispatch boundary,
  L ≥ 16). `goldens/<name>` is the reference set; `goldens/<machine-key>/<name>`
  overrides it. All reads go through `tests/support/goldens.ts`; regen scripts write to
  `goldenOutDir()` so a non-reference box can never clobber the reference set.
  Any new fixture that encodes logits or greedy tokens MUST go through that
  layer — bypassing it is the recurring failure (fixed twice already).
- **FFI/memory:** alloc-dispose loops asserting wired memory returns to
  baseline. GPU suites run serially; never overlap model-loading processes.
- **Integration:** server on an ephemeral port inside the test process (dies
  with the test), real chat + vision + audio + streaming, kill mid-stream and
  assert clean restart.
- **Tiering:** weights-loaded suites are opt-in/slow; everything else runs on
  every change. Two-shard gate before any release.

## Cross-cutting (standing items)

- **License headers**: every ported file names its upstream source + license.
- **Bun upgrade gate**: the bun#32054 regression test and the FFI soak
  (`tests/unit/ffi-jit.test.ts`) must pass before any version bump.
- **Quiet-box numbers are owed.** The current serve/prefill/decode matrix was
  measured on a loaded M1 Max; nothing enters `docs/reference/benchmarks.md` as
  canonical until it is re-run under the preflight gate.
- **Startup leg (c)**: ready-time is measured per stack; the purge-cold
  first-token rows (fresh process, page cache cleared vs warm) are still
  unmeasured — the last hole in the h2h matrix.
- **Standing hazards** (re-verified 2026-08-24): the `bench-serve` kv-quant RSS
  check misfires with `--ssd-cache`; `WIRE_THRESHOLD` in generate.ts is
  host-relative and the 12B sits near the boundary on 24 GB.

## Phase 6 — Speed: change what gets computed `[~]`

Canonical doc: [decode-speed-program.md](docs/design/decode-speed-program.md).
Qwen3.8-27B is the current priority; section 7 owns its full matrix, experiment IDs and gates. Accepted PR #48 changes shipped in v0.4.0; the remaining program stays open.
Per Josh, finish this campaign on the M4 Pro; M1 Max runs are outside its acceptance requirements.
Josh clarified that isolated background CPU activity is not a blocker when memory and the GPU are available. Record the explicit audio-daemon CPU allowance, retain memory/thermal checks, and require stable alternating pairs; “quiet” gates below use that campaign policy.

Current milestone, revised by Josh: use shared batching by default with
effectively equal measured B1 performance; retain serial as an available option.
Serving already defaults to `--batch 8`; a lone eligible request runs at B1
inside the scheduler, while explicit `--batch 1` selects serial. No runtime
default change is needed. Complete feature migrations through the existing
interfaces, including R17, without making every combination or serial deletion
a prerequisite for this milestone. Serial removal is deferred. Keep specialized
kernels and configuration/default optimization in scope. Reuse completed
evidence; rerun only for a named change, missing case or reproduced failure.

- [~] **R17 shared output cache:** replace Qwen MTP's private prefill store
  with the existing cache interface. Decode publishes processed-token state;
  the cache chooses retention and RAM/SSD placement from its settings. The
  shared contract and companion-state RAM/SSD storage are implemented and pass
  focused checks on M1 Max and M4 Pro. Qwen prefill capture/restore now uses
  that interface; bf16/KV4 RAM reuse and SSD restart continuations pass on both.
  Shared generated-row publication is adopted; M1/M4 bf16/KV4/TQ tests retain
  actual processed IDs and exact immutable RAM/SSD continuations at B4; HTTP tool turns pass RAM and fresh-process SSD reuse with thinking off/on. Final composition with the prefill-policy fix passes M4 native/HTTP, full-suite and matched short checks. Token provenance and optional-snapshot reclamation pass the reproduced Kanban BPE miss/Metal OOM with identical CSS output/usage. The fresh full task completes with all follow-ups cached and no inference failure; latest SSD state persists, but older unwritten snapshots are lost and the untouched app fails filter reset/keyboard editing. Older-history retention and app quality remain open; numbers are in benchmarks.md.
  Exit: actual generated-ID alignment, immutable snapshots after continued
  decode, RAM reuse, SSD eviction/restart restore, earlier-boundary fallback,
  complete byte accounting and saved Kanban next-turn timing. Details: §7 R17.
- [~] **Scheduling and method separation:** consolidate single-request execution
  as B=1 through the same method/session contracts used at larger B. Keep batch
  membership out of decode and cache placement out of scheduling. Method
  selection now precedes placement; configured drafts no longer exclude
  supported ordinary fallbacks from batching. Phase 18 owns
  the feature matrix and missing batch implementations; a serial fallback does
  not complete a batch-parity cell. Exit: one request lifecycle, same-B oracle
  gates, request-feature parity, cancellation/ownership coverage and paired B=1
  latency plus B=2/4/8 throughput on the M4 Pro. Freeze the existing serial path
  as the control; compare identical artifacts, kernels, method/sampling settings,
  inputs and initial cache state. A throughput gain cannot hide a B=1 latency
  loss or a missing feature. Resolve each recorded regression separately; serial deletion is deferred and does not block the existing batching default.
- [~] **Configuration consolidation:** inventory each flag's owner and effective
  value, bind one configuration per concern, and remove duplicate path-specific
  controls after their callers migrate. Keep existing CLI compatibility during
  migration. Exit: every served setting reaches its owning interface, no decode
  loop rereads mutable configuration, and docs describe actual supported
  combinations. The shared prefill-default/request-override fix is adopted after M1 native sampling/MTP, full model-free and typecheck gates; M4 composed prefill checks and matched short timing pass. Architecture §12.5–12.7 owns the interface contract.
- [~] **Measured defaults:** candidate source now selects Trellis v13, eligible
  Qwen KV4 speculation and paired MTP prefill reuse without opt-in flags. These
  changes are unreleased and need default-selection regression checks. R17
  output persistence and unified execution remain unfinished. Compare MTP
  depths 1/2/3/4 and ordinary decode: the short screen and four context repeats
  are complete. Late-context 2048-token prefill failed; 256-token chunks complete at 78,678 prompt tokens with MTP1/2/3; the ordinary cached repeat OOMed and recovered only on a changed retry request; allocation investigation and balanced repeats remain before choosing a common-use default. Defaults: server-config.md; evidence: benchmarks.md.

- [~] **Completed default-suite follow-up:** MiniCPM/Qwen timed-output divergence is traced to the reference server's thinking-segment prefill boundaries. The explicit unsplit reference control reproduces all ten saved Bun decode responses and usage; both first-request native traces match 192 complete logit vectors. These are correctness diagnostics, with one differing cache-reuse count. Qwen layer evaluation and full-batch reservation pass 38 retained-history/context/restart requests and twelve exact native oracle cases. Josh rejects predictive default refusals: keep estimates advisory, remove reservation hooks, and validate full requested work before repeating affected cells on M4 Pro. SSD flush acceptance and the separate packed Trellis/KV4/MTP result are recorded in benchmarks.md.

- [~] **27B R0:** controls on `673b43f` plus local diff; six same-artifact native Bun/MLX-LM pairs per flagship/compact/RTN4 match 64 emitted IDs and complete timings are close. Graph boundaries, dispatch inventory and calibrated operation timestamps captured. Prioritize the existing serving suite's single-request decode, cold/cached TTFT, 1k/long prefill, RSS and readiness cells; retain separate native timings and GPU-memory accounting. Multi-dispatch/critical-path attribution and quiet serial/default/mlx-lm pairs remain. Unrelated refactor acceptance stays separate.
- [~] **27B R1–R7:** variants 7/8/10 share small-M gate/up and scatter work. Variants 11/12 add direct short-prefill tiles, with native/HTTP state and response acceptance. The existing single-request suite confirms the v12/v6 decode improvement in two AB/BA pairs. Forty larger fused-tile cases are exact but slower. Variant 13 instead vectorizes bf16 expansion; operation, full-model and HTTP outputs are exact. Smaller native, serial HTTP and default-scheduler prefills improve, while existing-suite HTTP timing is mostly flat. R6 integrated readers and a lossless separate artifact preserve native generation and both HTTP paths with a small decode gain, flat RSS and no duplicate codes. Bounded v13 expansion scheduling is opt-in after native, both short HTTP repeats and both long-agent pressure gates pass; broader/combined and quiet acceptance remain. Six M4 Pro serial v6/v13 pairs now pass under the recorded audio-CPU allowance, with exact outputs and a fixed source; final-source native state and bf16/KV4 MTP-prefix gates also pass. Six continuous and six combined KV4/MTP pairs pass with matching outputs; broader pressure acceptance remains open. Variant 9 and the numerical M<=8 crossover remain Lab. Audit the packed activation distinction separately.
- [~] **27B R15:** Parser guards and model-owned committed-token appends are integrated. Native affine row arithmetic and MLX attention-length transitions preserve one-token logits/state on qualified M4 Pro Qwen graphs. Operation, full-model boundary, model-free, typecheck and HTTP cancellation gates pass. The final internal-SSD comparison completes 96 exact responses across twelve balanced pairs with request-time gains on both quants and no failures. Both earlier external-drive warmup failures remain recorded separately; active models now use verified internal copies. Quantized-KV and speculative combinations remain gated. Reusing the existing state-view interface fixes retained append views; R6 ordinary/fused TurboQuant passes the initial numerical/allocation screen, while affine KV4 fails. Broader combination checks remain. Held-out, other-model, combined/pressure and quiet gates remain. Evidence: speculative-decoding §7.4.
- [~] **27B R8–R14/R16:** Shared affine weight reuse improves RTN4 M3..8 and compact M4/8 full forwards and serving with exact outputs; M2 and unsupported head cells stay native. Final flag pairs, shapeless fallback, all typechecks and the complete model-free tier pass. Compiled-call caching is exact but its small native gain disappears in HTTP; no integration. A broader 4-bit prototype preserves full-model state on Gemma 12B/e4b, MiniCPM and Llama 1B/3B; only the larger Gemma cells improve. The narrower integrated selection passes native/live-input checks and Gemma HTTP timing pairs against both prior shared dispatch and native. B4/8 improve, B1 is flat; recorded B8 warmup response variation remains. Finish broader-model controls. Compact state copy passes packed gates; fused convolution, GDN fusion and affine layout screens have no compelling model win. Shared grammar masking preserves HTTP responses but timing is inconclusive. D256 attention fails one KL screen. The opt-in early first-token change passes native and sampled Q3/RTN4 gates. Continuous scheduling passes integrated HTTP acceptance after six exact prototype pairs; native Q3/RTN4 cache reuse and both long cached/SSD gates pass. Actual HTTP cancellation, independent recovery and overlapping arrival now pass on both Qwen quants and serving lanes. Reconcile the first-token cache boundary: the broader suffix screen changes some ordinary follow-ups, while explicit M=1 alignment restores exactness. Continue single-request graph/prefill work and the shared-operation audit.
- [~] **27B R17–R24:** native MTP cost recheck finds workload-dependent results. Six three-arm held-out HTTP blocks on the interleaved packed artifact preserve response text and improve complete time for fixed/adaptive MTP, with additional RSS. The native follow-up preserves token IDs and source-cache alignment through 500 rounds; EOS usage now follows native/oracle accounting. Served EOS-at-budget checks pass. Six saved-companion blocks preserve all responses with modest request-time gains and lower RSS; native same-input logit/state gates pass; six matched-prefill blocks per packed/RTN4 quant preserve all MTP/native responses and median complete-time improvements, with known RTN4 tail-split differences retained separately. Longer sessions, other quants and quiet gates remain. Cache/scheduler, all quants, wider algorithms and combined frontier on the M4 Pro remain open.
- [~] **Project-wide kernel and graph coverage:** inventory every owned Metal kernel, invoked native MLX operation, compiled graph and fallback; map each to model families and generating/serving workloads. Retain improvements only after complete native and serial/continuous HTTP comparisons; inspect scheduling, synchronization, buffer lifetimes and next-step overlap when isolated fusion gains disappear. Both sparse-attention keys now use uint32; exact operation/model-state gates and balanced selection timing pass, while real Colibri serving remains unmeasured. Top-p fusion preserves full requests but fails the Qwen timing repeat. Submission/traversal screens retain no Qwen setting, and omitting untouched finalizations also fails its balanced repeat. Llama's smaller submission limits improve six native pairs and six actual HTTP pairs per lane; broader context, lifecycle and model-owned integration remain. Device Trellis codebook lookup loses and is closed. The scoped threadgroup table is integrated into experimental v13; full-model identity and six integrated MTP HTTP pairs pass with small complete-time gains. Six integrated four-request serving pairs preserve all responses with a small median gain; per-cohort call maps separate matched work from arrival scheduling. Combined/pressure and quiet acceptance remain. Include memory movement and host overhead. Qwen is the lead workload, not the scope boundary. Preserve a per-operation evidence ledger and a repeatable M4 Pro comparison bundle.
- [~] **Video follow-ups:** Joint TurboQuant K/V decoding is integrated as an opt-in after operation, long-context, RTN4 and deferred-consumer state gates. Integrated R6/RTN4 native identity and six serial HTTP pairs per quant pass response gates. Allocation diagnostics distinguish live-array ownership from MLX buffer capacity. Finish combined/pressure and quiet acceptance. Six balanced long-context three-arm HTTP blocks preserve all responses and improve complete time. The narrower inverse-rotation operation passes both integrated model gates and six HTTP pairs per quant; every decode pair improves, R6 complete time improves and RTN4 complete time remains inconclusive. Grouped greedy readback is closed after six balanced three-arm HTTP blocks preserve responses but establish no broad request-time benefit. Direct packed-key attention is exact but slower than the integrated decoder in complete-operation repeats; that additional speed candidate is closed. The integrated R6 and RTN4 inverse-rotation gates pass on MLX 0.32.2. Six actual HTTP pairs each on MiniCPM/Gemma deferred consumers preserve responses and improve complete time on consolidated source. Current-artifact context/memory and Qwen DFlash2 architecture/selector work remain. Approximate prompt selection stays a separate quality-gated Lab arm. Details: decode-speed-program §7.11 and turboquant.md.
- [~] **Latest MLX runtime:** MLX 0.32.2 and matching MLX-C are released in native pack 0.4.0, targeting macOS 14; matching references are installed. Same-version RTN4 logits/state pass all twelve cells on both old/new cores and both new-core builds. Model-free suites and all typechecks pass. The inverse-KV R6 gate passes on the new core. The replacement for changed native small-prefill arithmetic passes all 36 integrated forward/state cases, six generations and six HTTP pairs per serial/continuous lane exactly. Actual 4K/8K same-version logits/state/continuations pass. The 24-worker native runtime screen shows flat short decode and inconclusive long-prefill timing. The package selects native pack 0.4.0, binds one C API and removes obsolete old-core affine dispatch. Both benchmark entry points select a version-checked reference. Both inverse-KV model gates and all twelve deferred-model serving pairs pass. Consolidated model-free/typecheck/hygiene gates and all final-source Qwen identity cases pass. Integrated inverse-rotation serving also passes; all eighteen broader MiniCPM5/Llama/Gemma oracle cases pass after matching MiniCPM5 prefill SwiGLU. Complete combined/pressure acceptance. Frozen old/new source controls preserve earlier comparisons. Shapeless custom-kernel support remains absent upstream. Fixed-input proxies and ordinary fixed-shape recurrent groups can preserve full-model identity; balanced recurrent-group timing is nearly flat, so neither adds production graph machinery. The SSD compatibility key now includes backend runtime/GPU numerical identity; synthetic and real RTN4 restart gates pass. Details: decode-speed-program §7.12.
- [~] **Kanban task acceptance:** The fresh Pi task on the required 12 GB artifact now completes and its untouched app passes functional browser checks. The published Luke Q3 128K xhigh profile, prompt and frozen sources pass the audit. The isolated KV4/MTP/paired-prefix path includes the verified history/parser fixes, bounded draft ownership and bounded range cache; sustained native replay preserves output and acceptance. Collect matched successful original/final comparisons before claiming a task-time speedup. The composed path is included in PR #47 behind opt-in flags; complete remaining native/serving gates before promoting it. Prioritize measured repeated-prefill and compaction costs, plus the queued native scheduling/kernel screens. Preserve failed attempts, raw lifecycle records and the corrected derived compaction count. Complete the portable Bun benchmark and HTML report at the final accepted revision. Protocol: decode-speed-program §7.7; measured result: benchmarks.md.
- [ ] **Same-prompt Kanban on MLX-LM (Josh-requested future test):** Run the exact pinned Kanban prompt through the same Pi harness on MLX-LM in a fresh workspace. Freeze sampling/seed, thinking, context limits, compaction and tool access; record all cache/MTP differences. Select and record a supported reference artifact and available-memory fit before execution; our packed Trellis artifact is not a stock MLX-LM same-artifact control. Save complete JSONL/request/response traces and untouched app output. Compare independent functional quality, generated output/repetition, prompt/output/cached tokens, tool errors, compactions, peak memory and whole-task/TTFT/decode time against the successful run. Separate artifact/quant differences from engine effects; no engine-only speed ratio from unlike artifacts. Future work only, no server or inference launched for this request. Protocol: decode-speed-program §7.7.
- [~] **Final benchmark and multi-machine HTML report:** offline native/serve import, HTML rendering, fixtures and full-output identity checks are implemented. Incompatible request, artifact, host, source and qualification cells cannot supply speed ratios; legacy failures and retries remain visible. The bounded M1 MiniCPM live smoke completes; concurrent reference output differences remain, and diagnostic timings cannot qualify. Paired block uncertainty and same-arm environment baselines are implemented and tested. Complete the frozen protocol, quality inputs and final quiet matrix after optimization gates. Cover single-request latency/throughput, prefill, startup, memory, cache reuse and sustained serving with same-artifact MLX-LM controls where supported. Protocol: decode-speed-program §7.10; current renderer limits: benchmarks.md.
- [ ] **27B closeout:** separate native and serving acceptance, shared-operation eligibility and cross-model gates, evidence for every candidate, explicit unresolved blockers, held-out quality, project-wide kernel coverage and final source review. Audit pre/post-refactor request, adapter, scheduling and cleanup costs at fixed kernel settings; preserve the request/execution interfaces while removing measured overhead.

Existing lever measurements retain their original model, machine and revision.
The merged interface refactor is not a new speed baseline.

- [ ] **Recheck per-op and chunk-count gaps vs Python.** Earlier loaded-machine
      Qwen traces reported a short-prefill loss and long-prefill advantage.
      Reproduce on the current same-artifact controls, then separate FFI/encode
      overhead, native library builds, chunk scheduling and graph evaluation.
      Exit: attributable paired evidence or a recorded non-reproduction.
- [ ] **Cheaper drafter head to extend spec decode past γ=1.** 12B γ=1 is a ~9%
      win with the batched verify; γ≥2 loses because the drafter re-reads a
      full-vocab tied head every draft step. Exit: γ=2 net-positive on a quiet
      box, or the lever is declared γ=1-only and documented.
- [ ] **Clean-machine rerun before any spec-decode number is quoted**, plus the
      optional `strictVerify` flag that restores per-position bit-exactness to
      stock decode (we are the only stack that can offer it).
- **Exit criterion**: each lever CHARACTERIZED with quiet-box numbers in the
  eval DB, and the best configuration per (model, context) shipped as default.
  Compare same-model, same-context only.

- [ ] **Logical jump-ahead prefill and micro-compaction (Josh's research proposal):** Evaluate oracle savings, online inference of continuations from reasoning/partial calls, and recovery cost at retained task quality. Compare post-tool reasoning micro-compaction separately and combined, including summary/state-rebuild costs and failed runs. Design and proposed preprint: [speculative-decoding §7.5](docs/design/speculative-decoding.md#75-logical-jump-ahead-prefill). Research is queued; this entry does not claim an implemented semantic policy or measured speedup.

## Phase 7 — Kernel experiments (research track) `[ ]`

Only after profiling shows where bytes move unnecessarily. Negative results
count — this is the research part of the project.

- [ ] Profile per-tile dispatch overhead in the N-tiled SDPA path.
- [ ] Custom fused Metal kernel for one exact config (4-bit, group 64, Gemma
      GQA shape): matmul + online-softmax update in one kernel via mlx's
      custom-kernel hook. Target: long-context prefill.
- [ ] 8-bit-specific tuning and e4b/26B kernel enablement (the old
      Optimization-Plan-E steps 6/7). Blocked by design: a CustomKernel cannot
      live in the whole-graph closure (no `output_shapes`), so e4b/26B generated
      dispatch emits compat tiled/unfused only. Optional until those models
      leave the MoE/whole-graph constraints.
- [ ] Write up findings either way, into the decode-speed doc.

## Phase 12 — SigLIP vision tower — remaining `[~]`

e4b is served and gated (`tests/parity/e4b-vision.test.ts`); the residual is fidelity
and coverage, not capability.

- [ ] **Drive Gemma vision to bit-exact.** Every primitive already matches the
      oracle bit-for-bit (proven model-free); the residual ~1% rel-RMSE is
      full-graph composition order accumulating sub-bf16 rounding, amplified by
      scale=1.0 on RMS-normed q/k. The fix is matching optiq's exact op /
      lazy-eval / fusion ordering, readable from `optiq/vlm/gemma4/{vision,merge}.py`.
      Exit: rel-RMSE 0.0000% on the resize-free fixture, like the text models.
- [ ] **26B-A4B / 31B SigLIP**: same tower, never exercised — pick up by config
      and run the tier-a gate. Gemma video frames remain unbuilt (Qwen3.8 video
      is a separate, landed path).

## Phase 14 — Qwen 3.x family bring-up `[~]`

Qwen3.8-27B serves text, images, video, thinking controls, XML tool calls, and
native MTP (v0.2.0). Remaining: provenance, one live smoke, the KV story, and
the retirement of the superseded 3.6 target.

- [ ] **14f — artifact provenance.** Parity cannot catch a botched conversion:
      run a perplexity/eval sanity pass on each served Qwen artifact (a bad
      artifact is equally bad in both stacks). Exit: ppl row per artifact in the
      eval DB.
- [~] **14r-c — end-to-end serve smoke.** Template layer, `reasoning_effort`
      depth mapping, `preserve_thinking`, think-tag streaming, and the XML
      tool-call parser are implemented and verified against the real template;
      docs landed. REMAINING: one live-server round trip covering thinking
      stream + tool call + eos.
- [ ] **14r-d — KV compression (Lab).** No published mixed-KV config exists for
      this model, so the affine per-layer path has nothing to mirror.
      **TurboQuant is the primary KV story** (`--kv-quant turbo:k8v3`): head_dim
      256 is in the supported set and `maybeTurboQuantizeKv` already skips the
      48 SSM layers. Context math: 16 KV layers ≈ 64 KB/token bf16 → 262k ≈
      16.8 GB vs ~6.6 GB at k8v3; SSM state is ~150 MB regardless of context.
      Exit: a per-model KL + quality gate cell on 3.8 (the v1 gate ran on CPM5).
      Default OFF; uniform affine kv8/kv4 stays the mlx-lm-comparable option.
- [ ] **14y — 1M context (YaRN), opt-in.** The shipped config is
      `rope_type: "default"`, so nothing is silently missing today; yarn
      activates only if the user edits `rope_scaling`. Oracle when we build it:
      mlx-lm's generic `YarnRoPE` (beta_fast/beta_slow correction ramp + mscale
      attention scaling); mlx-vlm carries the same math and its
      `MRoPERotaryEmbedding` needs yarn-scaled inv_freq for vision×yarn. Port =
      precompute yarn-corrected inv_freq + attention_scaling and feed the SAME
      mrope kernel; the fast-rope text path needs a scaled-freqs variant
      (`mx.fast.rope` takes `freqs=`). Flag-gated, never default (static YaRN
      penalizes short contexts). Fit math first — 1M KV needs the KV ladder.
- [ ] **14r-b2 — consolidate on the best.** Once 3.8-27B is fully green, retire
      the 3.6-27B target: drop its paths, gates, and docs rows, let the snapshot
      gc. Keep Qwen3.5-4B as the SMALL arch-regression gate for the shared
      qwen3_5 graph (no small 3.8 exists — the family is 27B + 2.4T only).
- [ ] **14h — DSpark cross-check (optional).** `RadixArk/Qwen3.8-27B-DSpark` vs
      the native MTP head — measure, don't assume.

## Compat CLI surface + parity harness `[ ]`

One set of verbs serving three depths (automatic / compat / stick-shift). mlx-lm
is the vocabulary because it is the WWDC default and outweighs mlx-optiq ~425×
on installs. Three laws: one surface with mlx-lm names (`mlx-bun.<verb>` is a
pure alias of `mlx-bun <verb>`); compatibility is a SUPERSET, never an
intersection; gate behind a flag only where always-on would degrade the
automatic experience. Surface parity ≠ architecture parity — an unsupported
model errors clearly, it never silently misbehaves.

- [ ] Verb router + dotted-alias bin entries, one flag vocabulary.
- [ ] Reconcile the ad-hoc flags: `serve --kv-quant` →
      `--kv-bits/--kv-group-size/--quantized-kv-start` (deprecated alias kept);
      `--prompt-cache` → `--prompt-cache-size/-bytes`.
- [ ] Wire the wiring-only verbs (engine already exists): `generate`, `chat`
      (faithful REPL), `server`/`benchmark` flag parity, `manage`
      (`--scan/--delete/--pattern`), `cache_prompt`, `lora info`,
      `latency`/`fit --calibrate`.
- [ ] Honest stubs for unimplemented verbs: exit non-zero with
      `not implemented in mlx-bun yet` — never silently accept.
- [ ] **Parity harness** against the oracle venv: per-verb flag-surface diff
      (every `mlx_lm.<verb> --help` flag accepted or explicitly rejected, never
      silently ignored) + deterministic behavior diffs (`generate --seed --temp 0`,
      `manage --scan`, `cache_prompt` round-trip) + gap-honesty assertions.
- **Exit criterion**: aliases exist for every mlx-lm verb; the harness is green
  for the wired set and asserts the stub message for the rest; existing parity,
  server, and tool suites stay green after the flag reconciliation.
- **Behind this layer** sit the capability buckets that light up the remaining
  verbs: model quantization (`convert`/`awq`/`dwq`/`gptq`/`dynamic_quant` —
  partly landed via `convert --rotate-weights`), training (`lora --train/--test`,
  `fuse`), eval (`evaluate`, `perplexity`), distribution (`upload`, `share`).

## Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)

Canonical docs: [batching.md](docs/design/batching.md), [kv-cache.md](docs/design/kv-cache.md).
The continuous scheduler is LIVE and default: `place()` declares serial or
continuous, active-row count picks B=1 or B=N, and injection/eviction happen
mid-flight. Default memory estimates are advisory; explicit user limits still
apply. Separate serial execution and feature exclusions remain. Phase 6 keeps
their consolidation as follow-up work after the batched-default milestone, alongside
prefill shape, the wrap-around golden and the tiers above L1.

- [~] **Shared execution and feature parity:** audit and implement ordinary and
      speculative decode, sampling/seed, logprobs, grammar/fill, adapters,
      supported KV schemes, media, prefix/output cache, resume, usage and
      cancellation through the same contracts at B=1 and B>1. Record each
      supported, missing and unvalidated combination with its test. MTP with concurrent requests is in scope; the method implementation owns
      differing accepted lengths, independently of scheduling policy. Keep numerical comparisons at the same B. Exit: no feature is
      silently dropped to batch a request, no serial fallback is counted as
      batched acceptance, and B=1 has no measured request-time regression.
      TurboQuant's rotated KV layout and fused kernels must compose with ordinary and speculative groups; current affine KV4/KV8 checks do not qualify TurboQuant. An isolated TurboQuant codec/row-storage candidate passes focused byte-preservation and native Qwen target rollback/continuation controls on both Macs; ordinary/MTP serving, seeded logprobs, true B4, RAM/SSD reuse and the full suite pass on both Macs in isolation; MTP3 native coverage and the integrated short/context settings screen pass; the reviewed shared MTP/TQ patch and Gemma ownership fix are now adopted in the unreleased working tree. Late-context/default selection and M4 pressure remain open; both Gemma artifacts and complete suites pass on both Macs. Delayed ordinary TQ conversion and reuse-boundary handling pass both-machine multi-family and M4 composed MTP checks; the patch is adopted and the main full suite/typecheck pass. Delayed speculative TQ is now adopted after both-machine native/SSD checks and composed M4 full-suite/typecheck/hygiene acceptance; main full suite/typecheck pass. Delayed affine Qwen conversion is now adopted. Variable proposals pass M1/M4 correctness and alternating fixed-MTP timing controls, and the verifier is adopted and main suite/typecheck pass; its prompt-lookup provider passes both-machine bf16/KV4/KV8/TQ B4 serving, generated-prefix RAM/SSD, policy and MTP regression checks plus complete suites; Both M4 lookup arm orders preserve single-request outputs with small decode gains and new cache reuse, but concurrent outputs differ and observed throughput is lower; default depth-10 KV4 coverage now passes on both Macs. The lookup provider is adopted; main full-suite, typecheck and hygiene checks pass. A separate one-token prefill maintenance candidate passes M1/M4 continuation/suite checks; alternating M4 timing preserves outputs and lowers cached latency; direct serial/shared timing still shows a cached-latency regression. The 8k M1 allocation comparison preserves outputs with nearly unchanged peak live allocation and a larger final pool. Wider packed down-projection passes both-machine correctness but loses M4 concurrent throughput; not adopted. Delayed affine KV4/KV8 is now adopted through the shared TQ row-transition lifecycle after both-machine native rollback/continuation, seeded ordinary/MTP serving, SSD precision-boundary restoration, full-suite and typecheck checks. Alternating M4 fixed-settings timing preserves all outputs and is effectively flat. Main integration suite/typecheck/hygiene pass; delayed-affine prompt lookup also passes both-machine active-proposal checks. Captured attention views are now adopted after both-machine Gemma 12B/e4b and MiniCPM KV4/KV8 state/logit checks, Qwen rollback/MTP/lookup and SSD continuations. Both candidate suites/typechecks pass; M4 decode/cached/throughput timing is effectively flat, with the final control CPU-daemon flag retained under Josh's background-CPU policy. Main integration suite/typecheck/hygiene pass. Multi-token bf16/KV4/KV8 rotating storage is now adopted after both-machine block/state, Gemma ring-wrap, suite and typecheck checks; main typecheck/hygiene pass. Delayed rotating affine conversion is now adopted after both-machine Gemma 12B/e4b uniform/per-layer native state/logit, RAM/SSD continuation, seeded B1/B2/B3 serving, Qwen MTP/TQ/lookup regressions, complete suites and typechecks. Four alternating M4 benchmark arms preserve all responses with effectively flat decode/cached/throughput timing; main integration suite, typecheck and hygiene pass. The isolated singleton-admission candidate passes both-machine correctness and preserves M4 HTTP responses with lower cached latency, but the physical-copy explanation is disproven; attribution/repetition precede adoption. The same investigation exposes an actual recurrent-row retention bug: extraction aliases the entire group. The compact-extraction fix is adopted after both-machine allocation/native/generated RAM/SSD/suite/typecheck gates and exact four-arm M4 HTTP responses; main integration suite and typecheck pass. Startup equivalence remains open. MiniCPM prefix coverage now honors trimmable-donor supersession.
      Standalone drafting is now integrated through one draft graph at B1/B>1: independent recurrent/attention snapshots, shared sampling and backend-coded RAM/SSD companions. Both-machine 27B serving/TQ generated-cache checks, pinned Llama oracle, full suites/types and existing MTP/lookup regressions pass. Four M4 arms with 2 GiB RAM plus SSD improve decode, cached latency and aggregate throughput; cold/startup cost, changed concurrent text and the 4 GiB allocation failure remain recorded. Main integration suite, typechecks and hygiene pass. Full-attention target capability binding is integrated after both-machine Llama/MiniCPM serving, generated RAM/SSD, wide same-B oracle, pinned shared Llama speculation and Qwen regressions. Four M4 arms improve Llama decode and concurrent throughput with paired cache reuse; cold-prefill cost and one changed concurrent response remain recorded. Main integration suite, all typechecks and full hygiene pass. Rotating target transactions are integrated after both-machine real-window Gemma continuation, default-depth lookup serving, padded same-B oracle, generated RAM/SSD, Qwen regressions and final suites/types. Four M4 arms improve concurrent throughput and cache reuse with effectively equal B1 decode; startup variation and changed concurrent trajectories remain recorded. Main integration suite, all typechecks and full hygiene pass. Assistant drafting is integrated after both-machine e4b/12B graph, serving/generated RAM/SSD, e4b optiq end-to-end and Qwen regression checks, full suites/types and four M4 arms. Decode, aggregate throughput and cache reuse improve; startup readiness, higher retained RSS and changed concurrent responses remain recorded. Strided weight views fix the pre-existing M4 hidden mismatch. Main integration suite, all typechecks and full hygiene pass. DeepSpec context rows and its shared graph are integrated after both-machine bf16/4-bit graph controls, real serving/generated RAM/SSD checks at depth seven, active real-window speculation, full suites/types and four M4 arms. Aggregate throughput and cached latency improve; startup cost and one changed concurrent response remain recorded. Main integration suite, all typechecks and full hygiene pass. DSpark/DFlash is integrated with shared projected-context ownership after both-machine seeded Markov/RNN serving/generated RAM/SSD, independent confidence/sampling, DeepSpec regressions, full suites and typechecks. Four M4 extraction arms preserve every response and usage record with a small measured performance cost; Josh confirms no DSpark/DFlash checkpoint has been trained yet; seeded fixtures validate execution, and trained-artifact performance remains unmeasured. Main integration suite, all typechecks and full hygiene pass. The shared artifact-identity memo is integrated after both-machine Qwen MTP/TQ, DeepSpec serving/generated RAM/SSD, mutation/restart tests, full suites/types and four exact M4 arms. It preserves existing cache namespaces and reduces repeat-load readiness, startup and retained RSS without changing decode; the main integration suite, all typechecks and full hygiene pass. Uniform start-zero KV4/KV8 rotating speculation and opaque assistant donor attention are integrated after both-machine provider serving/generated RAM/SSD checks, real-window transactions, same-width graph controls, pinned regressions, full suites/types and six M4 benchmark arms. Plain and encoded storage share rollback bookkeeping; the assistant compatibility source uses the shared row graph. The pinned oracle reproduces different-width affine rounding; live KV4 repeats are exact but can differ from the old ordinary fallback. Same-settings bf16 responses/usage remain exact with effectively unchanged throughput; KV4 improves aggregate throughput with changed text and slightly more prefill time. Main integration suite, all typechecks and full hygiene pass. TurboQuant donor composition is integrated and passes both-machine provider/SSD/precision-transition checks, independent assistant codec/graph controls and final suites/types. An M1 oracle failure exposed the existing centroid matmul shortcut; the candidate restores bf16 multiply/sum and lowest-token-ID tie selection. Twelve frozen M4 comparisons are complete; source-only costs and TQ setting tradeoffs are recorded. The TQ patch is integrated and main suite, typechecks and full hygiene pass. Delayed/per-layer affine rotating speculation is integrated after both-machine provider/native/SSD, donor ownership and real-window exact-logit checks, full suites/types and six M4 arms. Fresh pinned references resolve missing M4 blobs and the M1 stale-MLX continuation golden. Bf16 responses/usage remain exact; per-layer KV trades single-request gains for aggregate throughput. Main integration suite, types and full hygiene pass. GLM native MTP row/provider/cache composition is integrated from the tested isolate: both-machine tiny-model B1/B4 with DSA, native absorption, empty/unequal rows, generated SSD and full-suite/SSD/typechecks pass. Batch-wide sparse verification, shared selections and compressed attention padding match six independent same-B Python/MLX hidden/state cases per machine exactly. Final GLM-5.2 Colibri artifact testing is deferred by Josh; it is not a blocker for the remaining decode work. Paged storage is integrated through request-state policy and row-layout interfaces after both-machine native B1/B3 small/default-block exact-logit controls, HTTP sampling/logprobs/grammar, failure cleanup, full suites/types and eight M4 arms. Matching snapshot boundaries resolves the initial long-input comparison mismatch. Ordinary timing is effectively flat; shared paging improves aggregate throughput with effectively equal B1 decode, while cold prefill and changed concurrent text remain recorded. Main integration suite, typechecks and full hygiene pass. Adapter-plus-lookup capability composition is integrated after both-machine bf16/KV4/TurboQuant native, ordinary-adapter regressions, generated HTTP/RAM/SSD, exact token alignment, full suites/typechecks and eight M4 arms. Ordinary source cost is flat; enabled lookup has low acceptance and loses aggregate throughput, with eight stricter-match M4 arms complete and no setting dominating ordinary decoding. Defaults remain unchanged; main integration suite, typechecks and full hygiene pass. Ordinary continuation restore/capture hooks through the existing driver and a shared checkpoint-policy port pass isolated B1/B4 SSD restoration on both Macs; queued persistence passes both-machine ownership/race/native/full-suite/SSD/typechecks, plus M1 multi-family restart checks. Combined shared HTTP resume now passes both-machine compiled/uncompiled serial1/shared1/shared4 and mixed grammar controls, exact generated checkpoint restoration, full suites and typechecks. Ten M4 timing arms are complete: shared checkpoint execution improves aggregate throughput with effectively equal B1 decode; one concurrent response and prefix reuse differ. The tested continuation composition is now integrated for the PR. Both-machine immediate/delayed affine4/8, per-layer and TurboQuant resume pass; expanded compiled/mixed-grammar checks exposed and resolved adopted-row capture, restored-token dtype and lazy RoPE-constant compilation issues. Qwen/Llama/MiniCPM now pass native/HTTP shared resume through the same ports. Combined suites/SSD/typechecks pass on both machines and eight matched M4 timing arms are complete, with exact unchanged-setting responses/usage and effectively flat performance. These gates are complete and the candidate is integrated. The packed-27B native check passes; the HTTP fixture now opens fresh weight handles per model to remove its reused-materialized-weights setup failure. Adapter resume is integrated for the PR through the existing policy; its focused native/HTTP composition checks are separate from the completed ordinary matrix. The sampler-owned independent operation is integrated after both-machine numerical/native/SSD/full-suite/typechecks and twelve matched M4 arms. Ordinary throughput stays flat; lookup aggregate throughput improves without a default change. Main integration suite, typechecks and full hygiene pass. The end-to-end interface map in engine architecture §12.14 separates request policy, chat rendering, tokenization, scheduling, inference methods, sampling, state and RAM/SSD persistence; finish the remaining narrow ports and generated-output cache edge.
      Ordinary logprobs and explicit seeds now use the shared sampler in groups; uniform affine KV now shares conversion and batch layouts.
      Focused and M4 native/HTTP B=1/B=2/B=3 checks pass. Existing M1/M4 ordinary baselines are preserved. The row-transaction and MTP-graph interfaces are adopted in the working tree after native full-target/draft checks on both Macs. Device-chained draft rows and complete draft/verify/accept/commit steps now pass native B=1/2/4 checks on both Macs; the existing request adapter shares verification sampling. Model-free checks pass. Shared state membership now passes the same full-round controls. The shared output step handles independent consumer stops/failures before aligned state commit; final-source retirement/continuation checks pass on both Macs. Affine row layouts and zero-proposal rounds now compose with the same method; bf16/KV4/KV8 native checks and both complete suites pass. Provider-owned draft groups now reuse the companion checkpoint format; full-round, SSD and suite checks pass on both Macs. Coordinated target/draft admission is adopted after both-machine full-round and ownership/failure checks. An isolated method-interface candidate now executes four concurrent KV4 MTP HTTP requests on both Macs with seeded sampling and logprobs. Mixed grammar and SSD restoration pass on both Macs; late joins and admission-cleanup containment pass on M1. Readiness now lets scheduling flush method output before more preparation work; that integration is adopted, with strict timing acceptance open. Uniform replay retains its existing kernel; the uniform state-only optimization did not establish a serving win. New logprob comparisons expose cached-output latency work; same-B external oracle and broader compositions remain.

- [~] **S1a — true B-wide batched prefill.** Ordinary cohorts are adopted.
      Compatible late arrivals join between chunks, preserving each request's
      maintenance/checkpoint/tail boundaries through the shared cache ports.
      Same-B Qwen 27B/Gemma 12B full/sampler logits and cache checks pass on
      both Macs, as do MTP regressions, full suites and typechecks in isolation.
      Corrected four-arm M4 timing is flat with changed concurrent text;
      admission-only control attributes the text changes to shared prefill.
      Main integration suite/typecheck pass. Strict long-prefill timing remains open;
      Admission budgeting, provider-owned MTP prefill and the common target driver for ordinary/MTP/lookup are now adopted. Both-machine suites/types and same-B target oracle pass, alongside native chunk-arrival, lifecycle, affine/TQ, lookup and generated RAM/SSD checks. Shared prefill initially retained deferred parent-batch snapshots and slowed decode; the common RAM cache now resolves target/companion snapshots at ownership transfer. Matched M4 runs recover expansion cost and improve concurrent throughput while preserving shared-preparation responses/usage. Main integration suite, typechecks and hygiene pass. Full-attention delayed affine/TQ padding is now integrated after both-machine pinned cache/model, seeded delayed-serving and generated RAM/SSD checks. Four M4 arms preserve all responses/usage, with a small measured throughput decrease recorded in benchmarks.md; strict dominance is not established. Main integration suite/typechecks pass. A fresh M4 Gemma staggered-long serial/shared comparison improves aggregate performance with effectively equal B1 decode, but first-request latency remains unresolved. Broader composed oracle coverage and strict long-prefill/B1 acceptance remain.
      Exit: same-B oracle logits, lifecycle/cache parity and matched M4 timing.
- [x] **Ring-wrap oracle (> sliding window).** The live same-B oracle now
      checks unequal offsets, wrap during decode, retirement and a late join
      already beyond the window. Gemma 12B and e4b pass full-vector equality
      against the pinned same-B oracle on both M1 Max and M4 Pro.
- [ ] **L2 parity layer** — quantized KV under batch, bit-exact vs optiq per
      row (composition inherits the scheme's oracle; never invent a KL gate for
      an oracle-backed scheme). Note the perf debt: the `[B,1,N,S]` array mask
      bypasses the fused decode kernel, so quant batched falls to
      `quantizedSdpaUnfused` — correct, slower.
- [ ] **L3 (Lab) layer** — our perf paths under batch, KL + quality gated, must
      degrade gracefully L3→L2→L1.
- [ ] **S3+ — paged KV** (rung 3: paged-attention Metal kernel + block manager;
      vLLM is the oracle). **LoRA-group batching** now passes native and same-B
      oracle checks on M1/M4; performance acceptance remains. Density upgrades, not
      correctness.
- **Exit**: throughput scales with concurrency to the slot count then queues;
  per-row output matches the same-B oracle at every tier.

## Phase: agentic KV reuse — semantic anchors + free draft sources `[ ]` (opened 2026-08-30)

Origin: FreeToken (arXiv 2608.16157). Its headline PCIe co-execution is moot
on unified memory; two ideas survive the port. Canonical docs on landing:
[kv-cache.md](docs/design/kv-cache.md) (K1/K2),
[speculative-decoding.md](docs/design/speculative-decoding.md) (K3).

- [ ] **K1 — measure the miss before building.** Replay real agent
      transcripts through the template layer and measure, per turn: LCP
      survival vs the previous rendering, and how often the divergence point
      sits at a semantic boundary (tool-call close, turn end, think-close —
      where agent frameworks actually edit context). Split by cache class:
      trimmable KV already resumes exactly at the LCP, so the payoff lives
      entirely in the untrimmable kinds (SSMCache, wrapped rings), which
      today serve only exact-length matches → any agentic edit is a full
      re-prefill on Qwen3.8's 48 SSM layers. Exit: "% of re-prefill tokens
      semantic anchors would save" per cache class, or a measured "not worth
      it".
- [ ] **K2 — anchor snapshots (only if K1 pays).** Generalize the existing
      prompt-boundary snapshot (ONE trim-free entry at the template probe's
      boundary) to N anchors at semantic boundaries: zero-copy clone-and-put
      mid-generation, reusing `PromptCache` entries/eviction/supersession
      as-is. Cost model first: SSM state ≈ 150 MB per anchor on Qwen3.8
      (14r-d), so anchors need a per-conversation cap. Residency only, not
      numerics — same caches from an earlier boundary, so the bar is
      bit-exact continuation, no Lab gate. Trimmable-KV paths must be
      provably unregressed.
- [~] **K3 — tool-call fill table (lookup, not speculation).** K3a (append
      mechanism) + K3b (strict schema/template rows) LANDED, default off:
      `MLX_BUN_FILL=strict`, `src/fill/{fill-session,schema-rows}.ts`, the
      fill branch in `generate.ts`, `usage.fill`, design in
      [speculative-decoding.md](docs/design/speculative-decoding.md) §7.
      Rows are compiled by diffing probe renderings of the model's own
      template, so the compiler knows no tool-call syntax. First 0.8B weights
      run (2026-08-31): mechanism clean (12/29 tokens injected, 16 decode
      steps vs 28) but ids diverged — placeholder-name probes split Qwen3.5's
      merged `=get` token. Fixed: every span is now sliced from a REAL-name
      rendering, and the regression gate is token-ID containment, not text.
      Weights gate PASSED on Qwen3.5-0.8B (token-identical, 12/28 injected,
      decode 15 vs 28). K3c LANDED behind `MLX_BUN_FILL=echo` (Lab, default
      off): one `ProposalSource` interface with two policies over ONE apply
      primitive — `assert` (determined; no readback, no checkpoint) and
      `verify` (likely; argmax read from the same forward's free logits,
      rejected tail rewound through the spec lane's cache contract, decode
      resumes at the first disagreement). Echo = growing k-gram index
      (`GrowingMatcher` port) + branch-point stopping; `assert` additionally
      requires CORROBORATION (≥2 occurrences agreed) after an uncorroborated
      copy was observed replaying a mocked tool RESULT 30 tokens past
      `</tool_call>`. Not migrated: the spec lane's DraftSources (adapter is
      future work). K3d LANDED: `scripts/fill.ts <replay|ab|report>` +
      `scripts/fill/` — mocked-replay over recorded sessions (reader ported
      from `reports/k3-replication/analyze.py`; `tools` synthesized, the JSONL
      has none), paired interleaved arms (fill is process-wide → two servers),
      the echo gate (agreement not dropping under McNemar's one-sided 95%
      bound AND median wall clock strictly improving), and the showcase with
      the bandwidth-ceiling check. Model-free and unit-tested against a stub
      server (`tests/research/fill-echo-replay.test.ts`,
      `tests/unit/fill-session-reader.test.ts`); NO live numbers yet — the A/B
      is Josh's shell, two servers, and it is what decides whether echo ever
      becomes a default. LIVE RUN 2026-09-02 (27B, serial arms, 32 paired
      turns; speculative-decoding.md §7.3): echo injects 7.4% (read turns
      32%) with agreement held but wall clock ×1.00 — 76% of proposed span
      positions rejected at verify, so the multi-token forward costs more
      than the decode it saves → echo gate FAILS, stays Lab. Found and fixed
      on the way: batch lane never fills (A/B needs `--batch 1`); strict
      rows compiled EMPTY on Qwen3.x thinking templates (primer `\n` merges
      with the reply's `\n</think>`) — text-level boundary fix, 4 rows on
      the 27B. BUG found by the A/B (`lab/repro/serve-crash-turn8`): the 27B
      server died with a bare MLX C++ exception on a turn that resumed a
      prompt-cached prefix (qwen3_5 hybrid SSM+KV); `--prompt-cache 0`
      served it. The earlier ownership-transfer mitigation is superseded by
      immutable RAM views with eventual SSD persistence. Repeated-prefix and
      restart-restore gates pass on both Macs, including the saved long prefix;
      final paired serving and broader pressure acceptance remain open.
      SSD write-behind also had a check/use race, but its causal role in the
      native crashes was not established:
      `onIdle()` observed an idle gateway, then a request acquired the engine
      before the writer's blocking tensor readback. Each tensor step now runs
      under `gateway.runExclusive`; client cancellation also preserves the
      latest in-flight generation checkpoint. Long buffered tool-call bodies
      now receive SSE comment heartbeats; without them Pi's default 300 s
      HTTP-idle timer terminated a real 14 KB `write` call twice.
      Native exception instrumentation now identifies Metal command-buffer
      OOM. Packed prefill evaluation boundaries and pressure-driven SSD
      demotion pass fourteen boundary requests, including fresh prefixes and
      a 512-token final response. The saved Pi evaluation is resumed with
      physical-memory logging; the full app is not complete.
      Strict-tier A/B (corrected rows, 2026-09-02 pm): fill 5.3%,
      100% acceptance, identical calls, median wall ×0.99; the proposal trace
      (`MLX_BUN_FILL_TRACE=<file>`, `fill trace`) caught a `</think>`-triggered
      scaffold asserting tool calls the model would have answered in prose
      (10/47) — fixed. Packed 27B token-identity fixture now passes on
      variants 6/7; held-out/adversarial identity and a wall-time win remain
      before default-on, alongside echo policy levers
      (anchor K, candidates, span cap ≈ accepted length), the showcase,
      deterministic value transforms (seam
      only). Original brief:
      The model is
      a next-token function; injected context is indistinguishable from
      generated context. So the engine keeps a per-request fill table and,
      whenever the stream enters a determined span, APPENDS the span's
      tokens itself (one prefill step) and resumes decode after it — the
      model is only consulted for tokens it doesn't already know. Table
      rows: (a) schema-derived, compiled mechanically from each request's
      `tools` array — call-open scaffold, name completion after its first
      disambiguating token, sole-required-key skeletons, last-remaining-key
      transitions, call close; (b) observed per-(model, tool) first-key
      rows from corpus replay (pi corpus, 2,415 calls: bash first-key
      `command` 1316/1316; first-key style is per-model house style —
      gpt-5.5 path-first 667/667, GLM-5.2 edits/limit-first). Decode is
      spent only at the trigger, one name token, values, and real branch
      points (unmapped first key, array continue-vs-close). Corpus
      estimate ~15 scaffold tokens/call ⇒ ~35–40k decode passes over the
      corpus. Fallback: any mismatch stops injecting (1/2,415 malformed
      calls observed). Two modes with different bars:
      - **Strict fill** (schema rows only): token-identical by
        construction — ships on parity evidence alone.
      - **Greedy fill** (echo injection): a turn-scoped repeat detector —
        when the generation tail matches a span earlier in the turn
        (thinking, prior results) past a threshold, inject the span's
        continuation up to a delimiter (closing quote/brace), including
        deterministic transforms (url-encode, JSON-escape). Doctrine: the
        model has no memory and no intent — an injected echo is
        indistinguishable to it from its own choice; a semantically wrong
        fill costs a wasted round trip, the same failure class as the
        model's own typos, and self-corrects in the loop. So the bar is
        NOT token identity (sampling never guaranteed it); it is a paired
        A/B on task success + wall clock (Lab gate), default off.
      Measured copy-from-context rates (pi corpus, value verbatim earlier
      in session): edit.path 97%, read.path 65%, write.path 35%,
      bash.command 5% whole-string (pieces are copies; whole-string is
      the wrong granularity). Same-message thinking holds the exact value
      only ~2% — reasoning names targets; prior tool results carry the
      strings. At local decode rates (~10 tok/s) the injectable ~30–40
      tokens/call ≈ 3 s/call, ~15 min over a 296-call session.
      Replay doctrine: the transcript IS the environment — the model
      cannot distinguish executed from mocked tool results, so the A/B
      replays recorded sessions with results mocked verbatim from the
      JSONL: deterministic, side-effect-free, whole-corpus.
      Showcase: ONE large tool-dense prompt (edit/read-heavy, mocked
      results), fill on/off paired, emitted AND decoded tok/s side by
      side on a labeled machine. apparent = decode/(1−fillFrac); at
      ~65% fill the emitted rate exceeds the model's bandwidth ceiling
      (bytes ÷ GB/s) — the skeptic's own napkin math proves the filled
      tokens never touched the weights. Quote agentic-replay numbers
      only; chat decode is unchanged and the writeup says so.
      Target region: the agentic tool-call loop (one prompt → ~10 tool
      calls + reasoning → one response — most generated tokens live there,
      and it is maximally self-similar). Phase 6's γ≥2 blocker is drafter
      economics; a drafter that costs nothing sidesteps it: (a) session
      self-lookup n-gram drafts — the context IS the corpus (tool names
      from a small fixed set, argument keys repeated every call, values
      copied from earlier tool results: paths, IDs, URLs); (b)
      schema/grammar forced tokens inside tool-call JSON (structurally
      determined positions — distinct from response-format structured
      output, which is already known territory). Measurement first,
      mechanism later: replay agent tool-loop transcripts recording at each
      position whether each draft source proposes the accepted token;
      acceptance heatmap split by region (tool-call span / reasoning /
      prose) decides build-or-drop. Oracles when built: SGLang jump-forward
      / llama.cpp grammars (forcing), HF prompt-lookup (n-gram). Drafts
      verify through the existing spec-round contract, so a wrong guess
      costs a rejected lane, never a wrong token (tier c); tokenizer-
      boundary drift in forced text is likewise just lost acceptance. Exit:
      measured acceptance ≥ break-even for γ=2 on a quiet box, or the track
      is dropped with the numbers recorded.

## Phase: resumable long-agent generation `[~]` (opened 2026-09-03)

The 27B Kanban eval runs for hours, longer than an attached tool session and
long enough that a laptop shutdown should not discard the decode. The engine
now snapshots the cache-covered emitted prefix plus the already-sampled next
token. This supports Qwen's untrimmable recurrent state without recomputation.

- [x] Model-loop resume preserves the uninterrupted token sequence and sampler
      step; original prompt/completion accounting survives replay.
- [x] SSD checkpoint is atomic, restart-scannable, isolated from normal prompt
      lookup, newest-only, and removed on normal completion.
- [x] Public opt-in surface: `--generation-checkpoint N`, requiring
      `--ssd-cache` and `--batch 1`; unsupported stateful compositions stay off.
- [ ] Real 27B gate: interrupt after a durable checkpoint, restart server and
      Pi with the identical request, confirm replay + continuation, then record
      checkpoint size and stall on the M1 Max.
- **Exit criterion:** the Kanban task completes across a real process restart
  with no output divergence before/after the checkpoint; the persisted file
  fits under the configured SSD cap and the measured checkpoint tax is stated.

## Phase 20 — Expert offload: single-user MoE residency `[~]` (2026-06-14)

Single-user task locality makes per-task expert residency viable where a
multi-tenant server cannot. The mechanism is fully de-risked and E1a–E1d are
built and bit-exact; what remains is quotable numbers and the capability the
mechanism unlocks.

- [ ] **E1e — quiet-box tok/s** into `docs/reference/benchmarks.md`; optional
      hot-expert pinning if long or under-pressure runs regress; offload
      scales/biases for the last ~6% (verify a bf16-from-mmap GPU read first).
- [ ] **E2 — domain prefetch** reusing the `/v1/adapters` surface: a per-session
      `domain` hint warms that domain's profiled hot set, learned online. Still
      bit-exact (misses fault to SSD). Measure cold-start vs warm latency and
      switch cost. E0 measured the payoff: coding vs writing/chat hot-set
      Jaccard 0.42/0.44, so distinct domains do pay.
- [ ] **E3 — admit a non-fitting model**: bring up a 35B-A3B-class MoE under
      offload on 24 GB and flip the "larger hardware only" line. Measure the
      domain-switch warm-up (I/O floor is single-digit seconds).
- [ ] **E4 — (optional) pinned mode**: restrict routing to the warm set for
      zero-miss decode. Lossy → KL + 6-task quality gated, default-off, never
      the only path.
- **Exit criterion**: the 26B MoE served bit-exact with resident footprint at
  the measured target, machine stays usable, domain-switch cost quantified,
  promoted into `docs/reference/benchmarks.md`.
- **Scope boundary**: single-user / single-active-task. Batched slots lose the
  locality guarantee — experts stay resident there, and offload files stay
  separate from the batch work.

## Phase: audio input — gemma-4 audio tower `[ ]`

Audio-in/text-out through the chat API on e4b, using the sidecar tensors we
already hold. A0–A4 are done and gated; only measurement and coverage remain.

- [ ] **A5 — bench + coverage.** `scripts/bench-serve.ts all` cells (tower ms,
      TTFT delta, RSS delta) into the curated results; the 12B audio cell needs
      a sidecar rebuild (the local 12B sidecar has one audio tensor); document
      audio × batching = serial. Exit: numbers curated, e4b cell validated, 12B
      validated or explicitly deferred with a reason.
- **Non-goals (pinned):** TTS/STS/transcription endpoints, streaming audio,
  >30 s input, video, batched audio prefill, 26B-A4B/DiffusionGemma (no
  `audio_config` — architectural).

## Phase: TurboQuant weights — rotation-folded quantization, Qwen3.8-27B target `[ ]` (opened 2026-08-17)

Canonical doc: [turboquant.md](docs/design/turboquant.md). Goal: the
best-possible Qwen3.8-27B experience on our hardware via QuaRot/SpinQuant-style
rotation folding (orthogonal R folded offline into producer/consumer weight
pairs across the residual stream, RMSNorm γ absorbed first) ahead of
quantization into mlx's EXISTING formats — no new qmm kernels. Nobody publishes
a rotation-based MLX quant of this model; the whole ecosystem handles outliers
by per-layer allocation. Gate: perplexity + a frozen 6-task eval at equal
effective bpw vs plain affine convert AND vs OptiQ-4bit, eval DB rows, models
run sequentially, results labeled host/chip/RAM.

- [~] **W5 — calibration composition (the 4-bit flagship win).** Every leg has a
      shipped oracle in the pinned venv: GPTQ = `mlx_lm.quant.gptq` (forked in
      `scripts/turboquant/tq-gptq.py` for a language-only filter — vision H
      stays a zero scalar and must stay bf16 — plus a real upstream bug fix:
      their `err[..., k:k+1]` uses the GLOBAL column index on a group-local
      buffer and mlx silently no-ops the out-of-range slice assign, losing
      cross-group error propagation after the first group); sensitivity =
      `mlx_lm.quant.dynamic_quant` plus OptiQ's shipped per-layer map for this
      exact 27B (a 5.14-bpw artifact — comparisons are per-bpw-band). 27B needs
      a CHUNKED Hessian/GPTQ driver: the stock flow holds the whole bf16 model
      plus all Hessians resident, and `layers.N.mlp.down_proj` H alone is 1.2 GB f32.
      - [ ] **W5a** 0.8B matrix: {plain, rotated} × {RTN, GPTQ} @4bit. Gate:
            GPTQ > RTN and rotated+GPTQ ≥ GPTQ.
      - [ ] **W5b** add the allocation axis (dynamic_quant / OptiQ map); pick
            the best ≤4.5 bpw recipe.
      - [ ] **W5c** chunked 27B production run + ppl/eval gates.
- [~] **W6 — release as a SINGLE REPO.** One artifact = quantized trunk + bf16
      vision (in-main + optiq sidecar) + folded MTP companion at `mtp/`. Engine
      side is landed (`--draft-kind mtp` with no `--draft-model` resolves
      `<model>/mtp/`; docs same commit). Publish the W5 winner via
      `mlx-bun upload`. Blocked on the recipe outcome and Josh's go.
- [ ] **W6.5 — DOGFOOD GATE** (publish blocker, ahead of W6 upload: "I wouldn't
      even publish this model if we can't run it").
      - [ ] `mlx-bun perplexity` on qwen3_5 — the trainForward cache stub lacks
            `SSMCache.advance` (`src/model/qwen3_5.ts:226`).
      - [ ] Dogfood close-out: re-score a ~30-question GPQA subset through
            mlx-bun and match the mlx-lm scores. Turns cross-engine parity into
            a certification-data claim and moves future eval sweeps in-engine.
      - [ ] 24 GB near-ceiling UX: a 17 GB model + 1k prefill hits an
            uncatchable async-GPU-OOM panic at the default iogpu wired limit
            (≈75% of RAM); `sysctl iogpu.wired_limit_mb=21504` fixes it. serve/cli
            should detect `weightsBytes ≈ default limit` and PRINT the advice up
            front instead of dying mid-request; document in memory.md and the
            model README. Admission doctrine: clamp/advise, never refuse.
- [ ] **W7 — Pareto frontier** ("we shouldn't operate in a vacuum"). Map
      (intelligence × tok/s × memory) for local models on consumer Macs at the
      24 GB and 32 GB budgets with Qwen3.8-27B as the case study. Deliverable: a
      measured frontier chart plus the claim "highest benchmarks and highest tps
      at this memory level", defended against NON-OURS points.
      - Arms: ours {GPTQ-4bit, TQ-mixed 3.86 bpw} × mlx-bun; published
        {OptiQ-4bit 5.14 bpw, mlx-community RTN-4bit} × {mlx-bun, mlx-lm};
        cross-ecosystem anchor {GGUF Q4_K_M × llama.cpp/Ollama}. The KV axis
        composes: `--kv-quant turbo:k8v3` is the context-headroom lever at fixed
        weight bpw.
      - Intelligence: ppl ladder + frozen-eval subset (mmlu 100 / gsm8k 50
        minimum) per arm. Speed: quiet-machine `bench-serve all` decode/TTFT per
        arm (the 24 GB cut NEEDS the M4 Pro — Josh-gated). Memory: peak
        footprint + max-context-that-fits at each budget.
      - Honesty rails: paired same-corpus same-seed, per-bpw-band comparisons,
        no perf claims off a loaded box.
- [~] **Q — sub-4-bpw frontier (opened 2026-08-31; findings in turboquant.md
      "Q campaign").** Rotation + trellis + LDLQ + borrowed sensitivity, judged
      by KL-vs-bf16 (screen) AND MMLU-100 / tGSM-50 / rawGSM-50 (verdict).
      - [x] **Q0** KL-vs-bf16-teacher instrument on 32 GB (dump + two scorers,
            self-KL 0, cross-stack byte-identical).
      - [x] **Q1** affine arms scored: compact-norot 0.2524 (rawGSM 0/50),
            compact-rot 0.6054; rotation hurts affine.
      - [x] **Q2a/b** trellis k3 uniform: rot 0.4240 / norot 0.5648; rotation
            helps the trellis. No trellis cell beats affine yet.
      - [x] **Q2c** LDLQ: Hessians done; uniform-k3 encode superseded by Q3
            (LDLQ's isolated contribution not separately measured).
      - [x] **Q3** rot + LDLQ + k-map 3.00 — PASSED 2026-09-02: KL 0.1553 at
            3.55 bpw (flagship 0.1646 @ 4.80; compact-norot 0.2524), MMLU 88,
            tGSM 48/50, rawGSM 44/50 (no EOS cliff). 3.25 not needed.
      - [~] **Q4** task columns: Q3 done (on the 8-bit eval carrier,
            `tq-repack-fakequant.ts`); q2a/q2b still owed; rawGSM EOS-cliff
            root cause on the unrotated affine arm still owed.
      - [~] **Q2b** packed trellis format + Metal decode kernels LANDED
            (`src/quantize/trellis.ts`, `src/model/trellis-linear.ts`,
            `tq-quantize-trellis-packed.ts`; frozen fake-quant codec/driver
            untouched). Packed Q3 = 12.14 GiB, decode bit-identical to the
            fake-quant, KL 0.1550 through our serving path. M1 Max: 9.3 tok/s
            vs the flagship's 18.9 after three kernel rounds (decomposition in
            turboquant.md "Q2b measured": the 1MAD decode and the axis-0 down
            matvec are the cost; M1 decode is latency-bound so ALU/weight is
            wall clock). Served weight is f32 code×scale (bf16 rounding cost
            as much as decoding). Remaining: M4 Pro number; decide the
            down_proj coding axis — SETTLED 2026-09-03, keep the ROTATED
            (output) axis. `--down-axis in` gives 11.3 tok/s vs 9.3 at
            identical KL (0.15543 vs 0.15501), identical MMLU (88) and tGSM
            (47 vs 48), but rawGSM 29/50 vs 44/50 — strictly nested (15
            regressions, 0 improvements), failure mode = immediate EOS /
            empty continuation, the `tqalloc-norot` cliff class. Incoherence
            processing MUST reach the coded axis. Carry-forward:
            `…-k300-packed`; the downin arm is the counter-example of record.
            `MLX_BUN_TRELLIS=expand` stays the fallback.
      - [ ] **Q5** 2.75-budget arm (k2/k3/k4 68/104/20, ~10.8 GiB) — the size
            axis; same gate as Q3.
- The original W baseline uses existing formats and offline folding. Phase 6's
  27B performance program now includes custom formats/kernels, alternative
  algorithms and activation/rotation candidates under Lab gates.

**Queued follow-ups** (post-campaign; the GPU is owned by certification until
then) — designs in [speculative-decoding.md](docs/design/speculative-decoding.md)
and [orpo-training.md](docs/design/orpo-training.md):

- [ ] **DSpark×27B Track A:** confidence-scheduled verification on the stock MTP
      head (dynamic γ, STS calibration, no drafter training) — paired A/B vs
      fixed-γ MTP.
- [ ] **DSpark×27B Track B:** a true multi-token drafter targeting the TQ trunk
      (the 17 GB quant kills the "27B infeasible to train" premise;
      teacher-forced data gen on the frozen trunk). Gate: beat MTP's 0.68
      generalizing acceptance or drop the track.
- [ ] **ORPO LoRA on the TQ 27B (QLoRA shape):** frozen 17 GB base + bf16
      adapters. First step is a one-layer-backward memory probe at target
      sequence lengths. Adapters are rotation-basis-married to this artifact —
      say so on the card if published.

## Interface-based engine refactor `[~]`

Design and exit criteria: [engine architecture §12](docs/design/unified-engine-frontier-plan.md#12-interface-based-engine-refactor).
Primary target: **Josh’s Qwen3.8-27B quants**; unavailable artifacts defer target validation only.
Goal: push speed/quality/size on Macs through replaceable graph/method/session
contracts and aggressive quant-specific specialization. Interfaces must permit
fused execution without extra copies, materialization, or synchronization.
R1–R9 and the R10 code migration merged in `673b43f` (PR #46). Implementation
and upstream test/diagnostic evidence: architecture §12.13. Default memory estimates are advisory by Josh's instruction; native
regressions confirm that a false-positive estimate does not refuse execution.

- [ ] **R0/R10 acceptance:** use the 27B R0 matrix in Phase 6 for designated
      quants and quiet paired performance on the M4 Pro. Include the merged
      memory fix and the provenance-backed M4 Pro DeltaNet oracle gate.
- [ ] **Remaining compatibility cells:** unavailable model/drafter/oracle
      fixtures stay explicit. No quant recipe or numerical default is promoted
      by interface tests or loaded-machine diagnostics.

Product promotion needs a measured speed/quality/size advance and a local-user
workload. Shared prefill landed; true B-wide prefill remains Phase 18 S1a.

## Serving architecture consolidation `[~]` (opened 2026-08-21)

Canonical docs: [unified-engine-frontier-plan.md](docs/design/unified-engine-frontier-plan.md),
[generic-model-support.md](docs/design/generic-model-support.md). S0–S3 are
merged: one `CompletionExecutor` owns admission, semantic events, logprobs,
finish reason, usage, lane reporting, and cleanup for chat and raw-text,
streaming and non-streaming; `place()` produces one immutable scheduling
decision; model construction resolves one immutable declaration (artifact
identity, fidelity, required capabilities, loader/graph/loop composition) with
exact revisions pinned and mismatches refusing rather than downgrading.

- [ ] **S4 — land and post-merge verify.** Rerun the real server/UI conversation
      on merged `main` (streaming, tool cards, context carryover, metrics,
      composer recovery). Exit when checks are green, no server is left running,
      and this block closes; retain the canonical engine doc for the v2 refactor.

## Phase: Steel flash-CCE ORPO head + full ORPO training stack `[~]` (runs)

Canonical doc: [orpo-training.md](docs/design/orpo-training.md). The `[M,V]`-free
head, prefix sharing, segmented backward, warm-start, and the launcher are built
and gated (parity vs autograd, e4b fits at 8192). The open half is the *runs* —
a trained artifact is the only real proof.

- [ ] **End-to-end quality eval of a completed ORPO run.** The dress rehearsal
      was honest and negative: an 800-step CPM5 UltraFeedback run left IFEval
      flat at 22.5% — general data plus a tiny run is the wrong lever.
- [ ] **The chunk-segmenter run** is the load-bearing one: distill Opus/GPT-5.5
      segmentation, score boundary/label accuracy vs gold. It localizes the
      Dreaming pipeline's chunk-recent stage. Beware the known metric trap —
      the chunk-eval score measures well-formedness, not accuracy.
- [ ] The big CPM5 UF run and the e4b overnight, launched DETACHED (agent-spawned
      background runs are reaped by the runtime at ~47 min — not a crash).

## Memory / the Dreaming — open items

Canonical doc: [dreaming-nightly-pipeline.md](docs/design/dreaming-nightly-pipeline.md).
The write path, the nightly DAG, and the read tools are built (`src/memory/`,
`scripts/memory/`); these are the gaps between "built" and "runs itself".

- [ ] **Ingest is not wired into the nightly run.** `ingestSessions` has no
      caller outside tests and `runSynthesis` assumes the corpus is already in
      the store, so the launchd job cannot fold in new pi sessions. Sequence:
      ingest → the existing DAG; the per-source watermark already exists.
- [ ] **Bucket stage.** The story-keyed BUCKET accumulator, RESOLVE, and
      delta-at-once synthesis must REPLACE the per-chunk patch loop (not wrap
      it). Cardinal rule: one edit per (bucket, article) per run. The
      `buckets`/`chunk_buckets` tables already exist and hold only `_captured`.
- [ ] **`memory synthesize --since/--model` are parsed and dropped.** `src/cli.ts`
      passes them into `runSynthesis`, which never reads them
      (`src/memory/pipeline.ts`). Either apply them or reject them — a silently
      ignored flag is the failure mode this repo has a rule against.
- [ ] **Embeddings-as-instruments decision.** The pipeline has a permanent
      no-embeddings tripwire; `sectionCohesion` and the embedding-signal scripts
      survive only as offline eval instruments. Decide: keep as instruments or
      delete. Deleting them is an explicit decision, not a silent rewrite.
- [ ] **Nightly DAG order**: RECONCILE over every article (today: touched stems
      only) plus one closing NORMALIZE/EDITORIAL pass.
- [ ] **Promote + schedule**: once the `~/.mlx-bun/wiki-full` import is judged
      good on a broad cloud-judged sample, reindex, link, browse in Obsidian,
      point `~/.mlx-bun/wiki` at it, enable the nightly job, and drop the
      non-portable `Reference/` symlinks into the repo.

## Maintainability program

What remains of the repo-taming campaign after phases 0–3 (docs, files, agent
instructions, and the hygiene gates that enforce every rule). Phase 4 is the
code seams. The principle throughout: darlings are QUARANTINED and measured,
not killed on taste.

Shared prefill, model-owned execution and the default session lifecycle merged
in `673b43f`; design and evidence live in engine architecture §12.13. True
B-wide prefill remains Phase 18 S1a. The request pipeline, test-directory
separation and Lab import boundaries are implemented; their gates remain.

- [ ] **D6 darlings — decide by measurement, one at a time.** Each needs either
      a demonstrated user or a deletion commit; none should sit in the default
      path unproven: `src/model/generated/*` twins vs the hand-written model
      files; `src/diffusion/` (no CLI entry point reaches it); the curve/HLG
      sampler (`src/lab/curve/curve-sampler.ts`); the expert-offload cluster
      (`expert-{io,offload,offload-build,residency,trace,usage}.ts` — six files
      for one flag); paged-KV; the DSpark triplets; compiled-decode
      (`src/model/compiled-decode.ts` + `src/mlx/compile.ts`). Pi provider
      wiring is consolidated into one builder; that D6 item is closed.
