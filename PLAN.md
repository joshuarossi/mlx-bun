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

## Design principles

- **Logit parity is the oracle.** Every OptiQ model also runs on stock mlx-lm;
  that shared subset is the FLOOR and mlx-lm is its bit-exact oracle (a
  divergence is our bug until proven otherwise). optiq's additions (LoRA
  hot-swap, rotating KV-quant, fused prefill, MTP, SigLIP, TurboQuant) are the
  L2 ceiling, with the venv source as the reference.
- **The oracle for a capability is whoever already ships it.** Read it, copy it
  op-for-op, prove identity, then optimize. "No oracle" is the only place we
  invent, and those go behind the Lab tier (KL/eval + a paired A/B win before
  any default).
- **The GPU sets the speed; we delete overhead around it.** Decode is
  bandwidth-bound (bytes-of-weights ÷ measured GB/s = the ceiling). Wins come
  from fewer bytes per token, more tokens per weight-read, or skipped work —
  never from "faster JS".
- **mmap'd weights are immutable and shared.** Parse safetensors headers, take
  zero-copy views, hand pointers to mlx. One mapping, no copies.
- **Every perf claim gets a number on a quiet machine**, labeled host/chip/RAM,
  recorded in the eval DB. Numbers off a loaded box are not quotable.
- **Scope is the survival strategy.** Gemma (3/4), Qwen (3.x), GLM/Colibri, one
  MoE family. Not parity with mlx-lm's dozens.
- **Docs land WITH the feature.** A change to the served surface updates
  server-config.md / server-api.md / cli.md / README in the SAME commit.

## Reference environment

Machines, oracle venv pins, weight snapshot paths, HF/network quirks, and the
measured baselines live in one place: **[docs/reference/environment.md](docs/reference/environment.md)**.
Do not restate them here — a copy is a fork that rots. Two dev boxes exist and
neither is canonical; every recorded number carries its host.

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
The lever set (quantized KV, MoE, spec decode, prompt-cache persistence, wired
scope) is characterized and the winners ship as defaults. What remains is the
per-op overhead gap and the drafter economics.

- [ ] **Per-op dispatch/qmm efficiency delta vs Python (~10%).** Qwen3.8
      short-context prefill loses ~10–13% while long-context wins ~30%; the
      deficit is uniform across ops, not one bad kernel (the delta-rule scan is
      mlx-lm's exact Metal kernel, same grid/threadgroup). Candidates: our FFI
      outArray/error handling per op; mlx-c dylib build vs pip mlx codegen.
      A win here lifts EVERY model's prefill. Exit: a paired A/B on two models
      showing the short-context gap closed to ≤2%, or a written negative result.
- [ ] **Why does Python degrade with chunk count?** 113.8 tok/s @1k → 72.7 @4k
      while we hold flat. Unexplained; understanding it may name a lever we
      already hold. Exit: root cause recorded in the decode-speed doc.
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

Landed so far:
- 2026-06-17 — e4b tower + lazy loading + tier-a parity; findings in
  [generic-model-support.md](docs/design/generic-model-support.md).

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

Landed so far:
- 2026-08-18 — MTP DeltaNet rollback solved via the spec-round contract;
  [speculative-decoding.md](docs/design/speculative-decoding.md).
- 2026-08-20 — DeltaNet prefill leak (`contiguous(view)` pinning whole chunk
  buffers) found and fixed with `ops.copyOf`; environment.md hazards.
- 2026-08-22 — vision + video serve paths and the `mlx-bun-frame-extract`
  sidecar shipped; [generic-model-support.md](docs/design/generic-model-support.md).
- 2026-08-24 — v0.2.0 published with the full Qwen3.8 serving path.

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
continuous, active-row count picks B=1 or B=N, byte-budget admission clamps
instead of rejecting, and injection/eviction happen mid-flight. All four L1
decode cells are bit-parity with mlx-lm B=2. What remains is prefill shape,
the wrap-around golden, and the tiers above L1.

- [ ] **S1a — true B-wide batched prefill.** The scheduler still prefills rows
      solo and merges (that reduction-order difference is why the Gemma golden
      moved to a KL gate). The training path already has the machinery,
      parity-proven: `buildBatchedPadMask` / `BatchedMaskCache` in
      `src/train/forward.ts` (`tests/parity/train-batch-e2e.test.ts`). Wire serving to
      prefill B prompts in one forward. Exit: per-row logits bit-exact vs
      mlx-lm B=N on the CPM cell, KL-gated on Gemma.
- [ ] **Ring-wrap golden (> sliding window).** Every batched L1 cell was
      verified short-context, pre-wrap. `RotatingKVCache` per-row masking is the
      top correctness risk in the whole design. Exit: a `>window` batched golden
      from the oracle venv, green on both Gemma cells.
- [ ] **L2 parity layer** — quantized KV under batch, bit-exact vs optiq per
      row (composition inherits the scheme's oracle; never invent a KL gate for
      an oracle-backed scheme). Note the perf debt: the `[B,1,N,S]` array mask
      bypasses the fused decode kernel, so quant batched falls to
      `quantizedSdpaUnfused` — correct, slower.
- [ ] **L3 (Lab) layer** — our perf paths under batch, KL + quality gated, must
      degrade gracefully L3→L2→L1.
- [ ] **S3+ — paged KV** (rung 3: paged-attention Metal kernel + block manager;
      vLLM is the oracle) and **LoRA-group batching** (per-row adapters; today
      mixed adapters drain to solo, which Josh accepted). Density upgrades, not
      correctness.
- **Exit**: throughput scales with concurrency to the slot count then queues;
  per-row output matches the same-B oracle at every tier.

Landed so far:
- 2026-06-14 — L1 batched decode complete, all 4 cells bit-parity with
  mlx-lm B=2; [batching.md](docs/design/batching.md).
- 2026-07-01 — batched goldens moved into the machine-layered `goldens/` path.
- 2026-08-21 — continuous scheduler declared at the placement seam; byte-budget
  admission clamps; [batching.md](docs/design/batching.md).

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
      server dies with a bare MLX C++ exception on a turn that resumes a
      prompt-cached prefix (qwen3_5 hybrid SSM+KV); `--prompt-cache 0`
      serves it — root cause owed. Strict-tier A/B (corrected rows, 2026-09-02 pm): fill 5.3%,
      100% acceptance, identical calls, median wall ×0.99; the proposal trace
      (`MLX_BUN_FILL_TRACE=<file>`, `fill trace`) caught a `</think>`-triggered
      scaffold asserting tool calls the model would have answered in prose
      (10/47) — fixed. Remaining: token-identity parity on the 27B before
      default-on, echo policy levers
      (anchor K, candidates, span cap ≈ accepted length), the showcase,
      the turn-8 server-crash repro, deterministic value transforms (seam
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

Landed so far:
- 2026-06-14 — mechanism de-risked (munmap returns RAM; `gather_qmm` reads a
  page-aligned mmap bit-exactly; Metal does not wire clean file pages).
- 2026-06-14 — E1a–E1d: converter, mmap load path, `--expert-offload` CLI;
  measured phys_footprint 17.1 → 4.2 GB on the real 26B, decode unregressed,
  80 tokens identical.

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

Landed so far:
- 2026-07-07 — A0–A4: mel features at 1 ulp, tower bit-exact (rel-RMSE 2.4e-8),
  full greedy stream matching the oracle including EOS, HTTP serve gated.

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
- **Non-goals (pinned):** custom weight FORMAT or any new qmm kernel;
  activation quantization (no int4 tensor cores, decode is weight-bandwidth-
  bound); runtime weight rotation of any kind (weights fold offline, online
  rotation stays the KV codec's job); GGUF/AWQ export.

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

Landed so far:
- 2026-08-17 — W0 fold spike on Llama-3.2-1B through the unmodified engine
  (two-model KL 0.00131, per-tensor max|w| down 3–5×).
- 2026-08-18 — W1–W4: qwen3_5 corridor map, streaming fold at 27B scale, fold
  proven through STOCK mlx-lm (worst KL 0.0035); verdict recorded — rotation-
  only RTN loses at 4-bit, wins at ≤4 bpw.
- 2026-08-18 — `~/.cache/huggingface/hub/models--mjriii--Qwen3.8-27B-TQ` (local hub-cache staging, 14 GB — verified 2026-08-24; NOT on `~/models/`, which does not exist) (3.86 bpw / 13.9 GB) validated
  end-to-end: chat, vision over HTTP, MTP 71% accept and token-identical.
- 2026-08-20 — MTP serve lane fixed (two defects in the one advertised
  feature); eval-runner swap-thrash root-caused and fixed.
- 2026-08-24 — `convert --rotate-weights` shipped in v0.2.0.
- 2026-08-31/09-01 — Q0 instrument, Q1/Q2 arms measured, LDLQ + k-map drivers
  (`scripts/turboquant/{tq-trellis,tq-quantize-trellis}.ts`, `tq-ldlq-hessians.py`).
- 2026-09-02 — Q3 full recipe passed (KL 0.1553 @ 3.55 bpw, MMLU 88, tGSM 48,
  rawGSM 44); `tq-repack-fakequant.ts` eval carrier.

## Interface-based engine refactor `[ ]`

Design and exit criteria: [engine architecture §12](docs/design/unified-engine-frontier-plan.md#12-interface-based-engine-refactor).
Goal: push speed/quality/size on Macs through replaceable graph/method/session
contracts and aggressive quant-specific specialization. Interfaces must permit
fused execution without extra copies, materialization, or synchronization.
Implementation has not started. R0–R10 are ordered by the dependencies in §12.10.

- [ ] **R0** Fix/verify review findings; pin tools; freeze support, oracle and performance baselines.
- [ ] **R1** Portable contracts and method-neutral session suite; legacy adapter and dependency gates.
- [ ] **R2** Real graph/backend bindings; prove graph replacement and quant-specialized execution.
- [ ] **R3** Explicit resource/state ownership, rollback facets, codecs and checkpoint identity.
- [ ] **R4** One capability-aware execution plan, immutable configuration and preparation reservations.
- [ ] **R5** Shared AR prefill/session execution; cancellation at every safe boundary.
- [ ] **R6** Speculative, fill/grammar and diffusion implementations behind method interfaces.
- [ ] **R7** Scheduler policy separated from native batching; preserve B=1 and dynamic-row behavior.
- [ ] **R8** Client/task interfaces for applications; shared protocol types and async library bootstrap.
- [ ] **R9** Adapt existing isolation/model pool; coordinate managed GPU resources and failure handling.
- [ ] **R10** Full conformance/frontier scorecard, measured specialization selection, cutover and legacy removal.

Refactor PRs may be frontier-neutral; v2 product promotion needs a measured
speed/quality/size frontier advance and a representative local-user workload.
Shared prefill belongs to R5; true B-wide prefill remains Phase 18 S1a. D6
decisions feed R10. The linked engine document stays canonical as phases close.

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

Landed so far:
- 2026-08-21 — S0/S1: `CompletionExecutor` + immutable `RequestShape`;
  frozen `KvScheme` copies close the mutation holes.
- 2026-08-21 — S2/S3: immutable model declaration; `serial` vs `continuous`
  declared at the placement seam; raw `kvConfig` bypasses removed.
- 2026-08-24 — merged and shipped in v0.2.0 (2,064 tests, 75 skips, 0 failures).

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

Landed so far:
- 2026-06-19 — steel flash-CCE fwd+bwd in production: e4b backward 3687 → 754 ms,
  peak 0.93 GB flat at M=8192, dh parity 0.40%/0.28%.
- 2026-07-02 — coeff filter + blockMax skip default-ON at 1e-5 (1.71×/3.16×
  backward) with a standing teacher-forced fidelity regression test.

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

Landed so far:
- 2026-08-23 — the pipeline design consolidated into one canonical doc
  (supersedes memory-synthesis / write-pipeline-entity / bucketing-stage /
  memory-system / memory-inference-path / the-dreaming-master-plan).

## Maintainability program

What remains of the repo-taming campaign after phases 0–3 (docs, files, agent
instructions, and the hygiene gates that enforce every rule). Phase 4 is the
code seams. The principle throughout: darlings are QUARANTINED and measured,
not killed on taste.

- Shared prefill extraction is tracked in **Interface-based engine refactor R5**.
  Preserving solo prefill semantics and building true B-wide prefill are separate
  changes; the latter remains Phase 18 S1a with its own numerical gates.
- Landed 2026-08-30: the request pipeline — `src/server.ts` 3,690 → 1,541
  lines. A request is data; each stage is one program with a declared input
  and output, composed in order: `new ChatRequest(body)` (validates) →
  `ChatStage.run` → `InferenceRequest` → `InferenceStage.admit` (memory
  ceiling; seals the plan) → `InferenceStage.run` (gateway picks the lane) →
  `InferenceResult` → wire (`openai-wire.ts` JSON/SSE; Anthropic and
  Responses reuse `ChatStage` with their own formats; `/v1/completions` is
  `TextCompletionStage` into the same inference stage — its duplicated
  framing is gone, `http.ts` is the one JSON/SSE writer). Around it:
  `model-host.ts` (`loadContext`, tower getters), `chat-request.ts` (request
  classes + validators), `request-prep.ts` (options/template/prompt-ids),
  `token-streams.ts`. `tests/serve/pipeline.test.ts` runs the stages with
  a scripted engine and asserts on result objects. No invented token caps:
  a request that omits `max_tokens` runs to EOS or the admitted context
  (admission is the limit; DEVIATION from mlx_lm.server's 512 default on
  raw completion, `--max-tokens 512` reproduces it). Still in `createServer`
  (~900 lines): `runGeneration` (the serial engine), the `/fit` `/stats`
  `/signal` `/generate` branches.
- Landed 2026-08-23: the batch lane reports real prefill/decode timing (admission→first token→finish marks in `BatchScheduler`; `GenerationGateway` derives tok/s).
- Landed 2026-08-24: tests live in `tests/{unit,serve,using}` (CI, model-free) and `tests/{parity,research}` (weights/oracle-gated); `scripts/test.sh` shards by directory; hygiene check 10 keeps weights/opt-in dependencies out of the CI tiers.
- Landed 2026-08-24: `src/lab/{curve,paged-kv,expert-trace}` quarantined with hygiene check 11 (`LAB_IMPORT_ALLOWLIST` records the six existing production edges as debt; any new edge fails CI). Diffusion stays in place until D6 decides it — it is wired through factory/train/eval/gateway.
- [ ] **D6 darlings — decide by measurement, one at a time.** Each needs either
      a demonstrated user or a deletion commit; none should sit in the default
      path unproven: `src/model/generated/*` twins vs the hand-written model
      files; `src/diffusion/` (no CLI entry point reaches it); the curve/HLG
      sampler (`src/lab/curve/curve-sampler.ts`); the expert-offload cluster
      (`expert-{io,offload,offload-build,residency,trace,usage}.ts` — six files
      for one flag); paged-KV; the DSpark triplets; compiled-decode
      (`src/model/compiled-decode.ts` + `src/mlx/compile.ts`); and the three pi
      provider wirings (`harness-pi.ts`, `pi-provider.ts`, `pi-terminal.ts`,
      `pi-web.ts`) that overlap.

Landed so far:
- 2026-08-23 — `scripts/experiments/` (178 one-offs) and the `scripts/` root
  cleanup deleted; live files homed under `scripts/{oracle,memory,turboquant}/`.
- 2026-08-24 — one canonical doc per topic, generated docs map, front-matter
  plan-anchor gate, STATUS/PLAN line caps, `tests/unit/docs-surface.test.ts`.
