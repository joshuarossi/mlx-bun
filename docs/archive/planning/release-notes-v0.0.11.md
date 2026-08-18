# v0.0.11 release notes

Everything since v0.0.10. The big themes: mlx-bun grows a second modality
(audio), a constrained-decoding stack (structured output / grammar),
speculative decoding, a novel KV-cache quantization scheme (TurboQuant),
completed dynamic batching, crash-isolated serving, and a ground-up
rewrite of the web chat UI. The decode-default story also resets: after
benchmarking every custom performance kernel in a paired A/B against the
bit-exact baseline and finding none of them won, they were deleted —
naked `mlx-bun serve` now runs the faithful, mlx-lm-parity kernel set by
default.

## Audio input (Gemma e4b)

- OpenAI-style `input_audio` parts are served end-to-end: WAV/AAC
  transcode, a USM mel-spectrogram extractor, and a Conformer tower
  ported bit-exact (rel-RMSE 2.4e-8) against the oracle.
- Build-out ran phase-by-phase (A0–A5): a `bun:ffi` conv2d binding for
  the front-end, the multimodal prompt builder wired to the LM, and
  capability discovery for audio surfaced consistently across
  `/v1/models`, `/library`, and the pi websocket handshake — mirroring
  how vision capability is advertised.

## Structured output / grammar-constrained generation

- `response_format` (`json_object`, `json_schema`, `text`) and
  `guided_grammar`/`guided_regex`/`guided_choice`/`structured_outputs`
  are wired into both `/v1/chat/completions` and `/v1/completions`, built
  on `xgrammar`: a `GrammarController` masks logits inside the decode
  loop, with a per-`TokenizerInfo` compiler cache and a `MLX_BUN_GRAMMAR=0`
  kill switch.
- The batched lane got its own per-row matcher path so grammar-constrained
  requests don't force a request onto the serial lane, and grammar
  composes with `--draft-model` (the verify walk respects the mask).
- Two defects found and fixed during the build: the oMLX-parity
  JSON-system-prompt degrade path (used when a client can't do function
  calling) had gone unreachable behind a dropped hint, and the WASM
  grammar controllers were leaking on every early-400 reject path
  (SSRF-blocked media, vision/audio validation failures, bad
  `logit_bias`, etc.) — both fixed, with disposal now covering all paths.

## Speculative decoding

- `--draft-model` lands in serve: a two-model, serial-lane speculative
  decoding path verified token-for-token against mlx-lm's own
  `--draft-model` oracle (`DraftSource` seam, rewind rule, batched-verify
  lm-head).
- An ngram / jump-forward draft kind ships alongside the model-based
  drafter for cases with no small model available.
- A DeepSpec (DSpark) drafter-quant research track is underway
  (Phase 1 landed) targeting the larger models; per
  `benchmarks/RESULTS.md`, the first live pair (12B target +
  bf16 DeepSpec drafter, 26–33% acceptance) measured net **slower**
  than serial on a loaded box — spec decoding stays **off by default**
  pending a quantized-drafter pair that clears the 1.3× bar.

## TurboQuant KV-cache quantization

- `--kv-quant turbo[:kXvY]` adds a rotation-based per-group KV
  quantization scheme (sign-FWHT + Lloyd-Max for values), proven
  bit-exact against the vendored vllm-metal reference
  (`goldens/turboquant.json`).
- Per `benchmarks/RESULTS.md`, the k8v3 default holds a lower KL-vs-bf16
  than affine uniform kv4 while compressing KV **2.56×** (measured on
  MiniCPM5-1B, paired quality/KL harness). It's a memory/context lever,
  not a speed lever — v1 dequant-on-fetch is slower per decode step at
  long context, so it stays **opt-in, not default**, per the project's
  "levers must earn defaults" rule.

## Batching: Phase D completed

- Aggregate `--kv-budget <GB>` admission with FIFO queuing, vectorized
  homogeneous sampling (penalties/`logit_bias`/`min_p`/XTC all run
  per-row in the batch), and extend-join so a request can join an
  in-flight batch mid-flight instead of waiting for a full drain.
- Per-row RoPE lands for Tier-0 universal architectures, lifting the
  batching gate for those models (e.g. Llama).
- Batched mixed-precision quantized KV — the first stack to compose
  per-row KV quantization with batching.
- `--batch` default changes from 1 to 8 (see Breaking changes below).

## Runtime isolation

- `--isolate` runs the engine as a crash-isolated child process behind a
  reactor parent, restarting with backoff on a crash — the product rule
  is **"the AI may crash, the UI never may"** (`docs/design/runtime-isolation.md`).
- `--model-pool` extends this to a child-per-model pool: LRU residency,
  spawn-overlap switching (no dead time swapping models), and
  `POST /admin/drain` for graceful eviction.

## Optional paged KV cache

- `--paged-kv` adds a vLLM-style block-table paged KV cache
  (`PagedKVCache` + `BlockPool`) feeding the unchanged stock SDPA via
  block gather. Default off; v1 scope is serial `--batch 1`, the
  Gemma4 family, bf16 — it refuses to silently combine with
  `--batch N>1`, `--kv-quant`, or `--draft-model`.

## Prompt cache overhaul

- Prefix-sharing v1: `take()` now returns non-consuming, ref-counted
  clones instead of consuming/trimming the donor entry, so multiple
  agents or sessions can reuse one prefill without cannibalizing each
  other's cache.
- The SSD cold tier is promoted from an add-on to a first-class property
  of the cache store, with `--ssd-demote-idle <seconds>` (default 300,
  requires `--ssd-cache`) freeing GPU memory by demoting idle entries;
  `/stats` gains `ssd_cache.demotions`.
- A stable-boundary snapshot fix restores prompt-cache hits for
  multi-turn agent traffic beyond the sliding window — this was
  previously a silent cache miss on turn 2+ of long conversations.
- The SSD write-behind flush is now idle-gated, so background disk
  writes stop contending with decode at long context; the earlier A7
  RSS regression on the ssd-cache path closed with zero-copy write views
  and a streamed copy-restore.

## Web chat UI: ground-up redesign (Phases 0–3)

- Streaming render rewritten to be block-memoized (no more O(n²)
  re-parse of the growing message), with a typed module split.
- New surfaces: a memory panel, adapter routing, a system-prompt editor,
  an approval gate, client-side RAG over chat history (BM25, no server
  round-trip), a Model Hub, Canvas, per-message sampling controls,
  self-healing tool calls, a command palette, full-text search, and
  chat export.
- An app-aware assistant (v1) that can see and navigate its own UI —
  spotlight/selector resolution now treats a model-invented or malformed
  selector as a miss instead of throwing inside the websocket handler.
- PWA support, plus a round of visual-QA fixes: the phone nav band,
  light-theme code legibility, a composer placeholder regression, memory
  panel markdown chrome, the theme-toggle Auto button, a clipped status
  pill, and tab flex-shrink pinned to zero on phones.

## Security: media-fetch SSRF hardening

- `image_url`/`audio_url` fetches now refuse private/loopback/link-local/
  CGNAT destinations and non-`http(s)` schemes by default, re-validate
  through up to 5 redirect hops, enforce a 10s wall-clock timeout, and
  cap bodies at 64MB.
- LAN use needs the new escape hatch: `--allow-private-media` /
  `MLX_BUN_ALLOW_PRIVATE_MEDIA=1`.

## Fixed

- 12B `/v1/completions` probe parity: adopted the oracle's step-0
  prefill convention (drain to len−1, step 0 from an `L=1` forward of the
  last prompt token). Per `benchmarks/RESULTS.md`, live HTTP probes are
  now byte-identical to `mlx_lm.server`/optiq serve for MiniCPM5-1B,
  gemma-4-e4b, and gemma-4-12B, on completion and chat probes, in both
  the `--batch 8` default lane and `--batch 1`.
- BPE detokenization now mirrors mlx-lm's bare-space hold-back and
  never-finalize semantics exactly.
- Cache invariant enforced on every tier; an FFI destructor deadlock
  fixed; write-behind made non-blocking; per-row batch cache extraction
  fixed.
- `generate()` now yields a macrotask between prefill chunks, keeping the
  isolation path (and the server generally) responsive during long
  prefills.
- Benchmark harness: the `--batch 1` serial control arm now runs by
  default (it had been skippable, which undermined validating the new
  batch-8 default); `--engine` is additive instead of mutually exclusive
  with the serve pass; the batch-path test now asserts cumulative
  `/stats` `submitted_rows` instead of a stale `cachedTokens=0` premise.
- `any_whitespace` grammar knob landed; batch-grammar gates re-anchored
  to compact separators.

## Infra / benchmark harness redesign

- `benchmark.sh` + `scripts/bench-modes.ts` now spawn real CLI paths
  instead of bench-local server wrappers, folding bit-parity and
  peak-memory checks into the same serve cells (one pass instead of
  several). New columns: cold-start and restart-survival; new workload:
  `xl` (~4k prefix); a feature-matrix benchmark mode.
- Repo cleanup: `lab/` consolidation, a binary-tracking hygiene gate, and
  a git history rewrite that took the repo from 182MB to 20MB, removing
  the last multi-MB binaries from the index.
- New design docs: `unified-engine-frontier-plan`, `dspark-serving-program`
  (the DeepSpec/DSpark spec-decode research program), `structured-output`,
  `web-chat-redesign` (+ app-aware-assistant, superset-doctrine, and
  visual-QA-bar notes), `paged-kv-cache`, `batching-perf-path` /
  `batching-v2-plan`, `runtime-isolation`.
- Doc drift swept: env-lever table entries (`MLX_BUN_DSPARK_MINCONF`,
  `MLX_BUN_BATCH_NO_PIPELINE`, `MLX_BUN_EXPERT_OFFLOAD`), ngram
  draft-kind coverage in README/server-api, doc-map sync, an openwiki
  investigation write-up. STATUS.md was rewritten to current-state-only
  several times through the release to keep handoff notes accurate.
- A new ground rule was recorded in CLAUDE.md: changes to the served
  surface must update the user-facing reference docs in the same commit.
- A direct optiq mixed-KV bit-parity golden replaced an indirect
  ours-vs-ours comparison; a bit-exact L1 parity harness was added for
  the Qwen3-30B-A3B MoE port, with uniform quantized KV confirmed
  bit-exact against mlx-lm's own `--kv-bits` and a stock-mlx-lm baseline
  added to the bench.
- Dependency/CI bumps: pi, `actions/checkout`, and the site build moved
  off a deprecated Node runtime.

## Breaking / behavior changes

- **`--batch` default changes from 1 to 8.** Serving now batches by
  default whenever concurrent requests arrive; pass `--batch 1` to force
  strict serial (needed if you require arrival-order-independent,
  bit-identical numerics).
- **The default decode path changed.** Naked, no-flag serving now runs
  the faithful, bit-exact-vs-mlx-lm kernel set — what `--l1` used to
  mean. `--l1`/`--l2`/`--l3` are now pure aliases over per-feature flags
  rather than distinct performance tiers. Every custom-kernel path that
  didn't beat this baseline in a paired A/B was deleted in the same
  pass: the fused-decode kernel, fused-gelu/fused-swiglu/fused-mlp/
  steel-linear Metal kernels, the flash-decode "perf" kernel and its
  frozen-oracle test scaffolding, `--l3`, and `FaithfulMiniCPM5` /
  `MLX_BUN_CPM5_FAITHFUL`. None of these flags or code paths exist
  anymore. `MLX_BUN_FAITHFUL` is also gone (superseded by the faithful
  kernels being the default) — the server's unset `--kv-quant` now
  defaults to bf16 instead of `kv_config`, so getting the old default
  composition requires an explicit `--kv-quant`.
- **New CLI/API surface:** `--kv-quant turbo[:kXvY]` (TurboQuant),
  `--paged-kv` (off by default; refuses to combine with `--batch N>1`,
  `--kv-quant`, or `--draft-model`), `--draft-model` (speculative
  decoding), `--isolate` and `--model-pool` (runtime isolation),
  `--kv-budget <GB>` (aggregate KV admission), `--ssd-demote-idle
  <seconds>` (default 300, requires `--ssd-cache`),
  `--allow-private-media` / `MLX_BUN_ALLOW_PRIVATE_MEDIA=1`, and the
  `response_format` / `guided_grammar` / `guided_regex` / `guided_choice`
  / `structured_outputs` request fields (kill switch:
  `MLX_BUN_GRAMMAR=0`).
- **Media fetches are restricted by default.** `image_url`/`audio_url`
  now refuse private/loopback/link-local/CGNAT destinations and
  non-`http(s)` schemes — previously they fetched anything. LAN media
  needs the new escape hatch above.
- **`PromptCache.take()` semantics changed.** Cache hits now return
  non-consuming, ref-counted clones instead of consuming/trimming the
  donor entry — code holding onto the old consuming behavior should
  re-check callers.

Full details and measured numbers: STATUS.md, `benchmarks/RESULTS.md`,
and the design docs referenced above. Credit where due: TurboQuant's
codec is verified bit-exact against the vendored vllm-metal reference,
and the speculative-decoding path is verified token-for-token against
mlx-lm's own `--draft-model` implementation.
