# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity contract:** **L1** = mlx-lm bit-exact parity (the naked default) ·
**L2** = mlx-optiq bit-exact parity (mixed-KV composition) · **Lab** = original
optimizations with no external oracle, gated by KL/eval + a paired-A/B win vs
the L1 baseline before any default (docs/design/unified-engine-frontier-plan.md).

## Where we are (2026-07-05)

**Naked default = `--l1` (DECIDED 2026-07-05, uncommitted):** the full h2h
pass (benchmarks-h2h-2026-07-05, M1 Max 32GB) confirmed the L1 faithful
kernel set at exact speed parity with mlx-lm (1.00× cpm5/e4b/12B, decode
AND at-16k) while **no output-changing lever beat that baseline in a
paired A/B**: fused-decode 1.00×, fused-gelu +0–1%, the perf arm
0.62–0.93× on e4b (its one win, 12B @16k +6%, carried a KL WARN), and
quantized KV 5–20% slower decode than bf16 at ≤16k on BOTH stacks. So:
`applyDecodeRoute` now defaults the tier to l1 (bf16 KV, perf-kernel
default flipped OFF in code, serve/library kv default bf16); every
non-faithful kernel is opt-in via `--l2`/per-fork flags, and the
L1 baseline is the base future optimizations must beat (paired A/B) to
earn a default. Prior perf work is untrusted until re-proven against it.
Docs updated same session: server-config.md, cli.md, features-matrix.md,
README, faithful-l1-consolidation.md (superseding note).
**Benchmark harness hardened same session** (the 2026-07-05 report's
0.64×-vs-optiq "regression" was a mid-pass slow-window artifact —
refuted by the 07-04 pass's 1.05×): run-spread stability retries +
`unstable`/`stabilized` tags (pair verdicts withheld on unstable cells),
readable model names, chip/RAM machine labels, comparison-0 + lever-A/B
sections now render into the unified report, python-baseline prefill
warmup (the "816 vs 397" cpm5 prefill was compile-inclusion asymmetry),
KL verdict 24→96 steps, preflight high-CPU foreign-process check
(knowledgeconstructiond at 87% CPU was the likely slow-window culprit).

**Phase 1 deletion pass EXECUTED 2026-07-05** (unified-engine-frontier-plan
§6, all committed same day): deleted fused-decode, fused-gelu, fused-swiglu
(+ fused-mlp/steel-linear satellites), the perf kernel + frozen-oracle
scaffolding (tests, freeze script, tracked goldens), FaithfulMiniCPM5 +
MLX_BUN_CPM5_FAITHFUL, and `--l3` as a product mode (now a hard error
pointing at the plan; the Lab replaces it). Training needs NO flag
sanitization anymore. Surviving surface: `--kv-quant` (the one performance
trade-off) + `--l1`/`--l2` + bit-exact kill switches. Phase 0 measured the
batch-lane B=1 gap (cpm5 0.46×, e4b 0.72×, 12B 0.86× of serial — constant
~4–6 ms/step host tax; prime suspect: per-layer per-step mask rebuild) —
the Phase 2 closure worklist. The composition North Star (Josh): server →
optimized model → + mixed-precision KV → + LoRA → + spec decode → +
structured output → × sampling — all STACKABLE on one engine, no lane
routing.

**MULTI-MODEL SWITCHING LANDED same day (isolation P2, task #14):**
child-per-model pool under --isolate — route by exact /v1/models id,
spawn-overlap switch (old model serves while the new loads), lossless LRU
eviction (drain → demote prompt cache to SSD → exit). Measured: switch
1.5 s, switch-back 1.2 s with cached_tokens 103/104 — conversations
survive model eviction. --model-pool N keeps N engines hot.

**RUNTIME ISOLATION P1 LANDED same day (opt-in `--isolate`):** engine =
the whole server on a unix socket (child), parent = pure reverse proxy —
zero MLX calls, instant UI under any GPU load, crash → 502 + respawn.
Measured paired: −0.4% tok/s (noise), +2 ms TTFT, per-token SSE
granularity preserved, parent 0.6 ms mid-decode. The inter-process API is
the /v1 surface itself (decision in runtime-isolation.md — deviates from
the original gateway-IPC sketch). NEXT: P2 child-per-model pool =
multi-model switching by spawn-overlap (task #14).

**PREFIX SHARING v1 LANDED same day:** PromptCache.take() serves
NON-CONSUMING zero-copy clones (ref-counted mmap retain); put() supersedes
prefix-ancestors + duplicates (trimmable-only, so boundary snapshots
survive). N agents / new sessions sharing a system prompt reuse ONE
prefill without cannibalizing each other's entries (the old consume-and-
trim flaw). Real-model gate: B served from A's entry, A's next turn still
full-hits. v1 = compute sharing + durability; single physical prefix
across concurrent rows = the paged-KV frontier item.

**`--batch` DEFAULT FLIPPED 1→8 same day (Josh's call):** every gate met —
a lone request through the unified engine is the serial engine (bits,
speed, TTFT, prompt+SSD cache), so the cap only matters under real
concurrency (the sub-agents workload). `--batch 1` pins strict serial.

**Layer 0 LANDED same day — THE SSD TIER IS NOW A PROPERTY OF THE STORE:**
tiering moved inside PromptCache.take() (ColdTier interface; server binds
SsdCacheStore+model) → the BATCH LANE restores prefixes from disk at
admission (gated E2E); onPut fires the write-behind for both lanes; idle
demotion (--ssd-demote-idle, default 300 s with --ssd-cache) spills idle
entries and frees their GPU memory — RAM drains between agent bursts,
prefixes stay reachable via zero-copy mmap. Economics: SSD competes with
RECOMPUTE not RAM (12B: 30k context ≈ 3 min prefill vs ~1 s restore).

**Phase 3 milestone 2 LANDED same day — BATCHED ROTATING-QUANTIZED KV
(gemma's kv_config now batches; every shipped kv_config does):**
BatchedRotatingQuantCache (src/model/batched-rotating-quant.ts) = the
mlx-lm batched-ring mechanics over quantized triples, subclassing
RotatingQuantizedKVCache so the L1 attention dispatch is untouched; the
scheduler converts rotating layers at the serial boundaries and merges
rot-quant twins; the gateway accepts rotating-layer configs. Gates:
model-free per-row byte-identity vs the serial oracle through ring wrap;
gemma 12B B=2 join through the real scheduler — unpadded row KL-0 at
EVERY step, padded ≤4e-3. Two hard-won contracts recorded in the plan:
a batched cache's ropeOffsetArr must be STEP-STABLE (refresh only in
releaseRopeArr — the monolith captures-then-uses-late, the GENERATED
files re-read post-update), and generated-file instanceof guards ACCEPT
batched subclasses — an all-quant gemma batch decodes through the
generated fast path (bit-exact, proven at B=1), which is also why the
bug hid whenever any single layer stayed bf16.

**Phase 3.2 LANDED same day — LONE-REQUEST = SERIAL (adopt-don't-copy +
compiled decode at B=1 + prompt cache on the batch lane):** a row joining
an EMPTY batch now ADOPTS its solo caches as the inners (pointer handoff —
the merge copy runs only when a second row joins; the merge learned to
treat an adopted serial RotatingKVCache as its first row). Because the
lone row's caches stay serial-class, (a) the scheduler replays the serial
engine's CompiledDecode step at B=1 (same runner/traces/kill switch;
gate: free-running greedy == serial generate() token-for-token on 12B,
stepsExecuted advancing), and (b) prompt-cache take()/put() works on the
batch lane (joiners restore the longest usable prefix at admission —
multi-turn chat TTFT; never-merged rows put back with exact prompt+fed
accounting; merged rows' entries age out, v1 gap noted in the plan).
**GATE-B1-SPEED decode met on all three (apple-m1-max, paired in-process
A/B): cpm5 0.996 · e4b 0.992 (was 0.93) · 12B 0.993.** All gated suites
green; full suite green PER-FILE (monolithic bun test can jetsam on a
busy 32GB box — largestProcess=bun, pre-existing; per-file loop is the
gate). Gate-2 padded-row KL proven JOIN-STEP dependent (grid-snap bin
flips; K=6→3.5e-2 vs K=7→1.5e-1, identical on pre-3.2 main, bf16 flat)
— the test now pins the join step. Docs: server-config.md rows for
prompt-cache/compiled-decode under --batch updated + website sync run.
`--batch` default flip to 8: decode+TTFT gates now met; awaiting Josh's
call after milestone 2 (batched rotating-quant).

**Phase 3.1 P1 LANDED same day — BATCHED MIXED-PRECISION KV (first on this
stack; neither mlx-lm nor optiq compose them, live-proven earlier today):**
src/model/batched-quant.ts (quantized merge/extend/filter over triples +
BatchedQuantDecodeMaskCache), scheduler converts each joiner's solo caches
at the SERIAL chunk boundaries (rows bit-exact vs serial `--kv-quant
config` by construction), gateway kv-batchability memo (all-full-attention
kvConfig batches — cpm5; uniform bits / rotating-layer configs — gemma —
stay serial = milestone 2; a scheme-less gateway REFUSES to batch kv-quant
requests rather than silently dropping quantization, the optiq bug class).
Gates green: B=1 through the scheduler BIT-EXACT vs the cpm5 optiq golden
(new golden: regen-mixed-kv-goldens.ts --model <cpm5> --name cpm); B=2
dynamic join — unpadded row BIT-EXACT vs solo every step, padded row within
the calibrated 5e-2 envelope (bf16 same-harness ~9e-3 baseline). E2E:
`--batch 2 --kv-quant config` on cpm5 → /stats active_rows 2, coherent
output, 240 tok/s aggregate for two concurrent streams.

**Phase 2 DECODE GAP CLOSED same day:** the batch lane's B=1 tax was two
bugs — `toFloat32()` on the pipeline register enqueued an astype BEHIND
the just-dispatched next step (full-step stall per token; fixed with
`MlxArray.toIntTokens()` raw reads), and per-layer per-step mask/rope
wrapper churn (fixed with the unpadded fast path: bare caches = the
serial graph). B=1 through the batch lane: cpm5 129→264 (in-process
ratio 0.994), e4b 45→57.6 (0.93, remainder = compiled decode), 12B
25.6→29.7 (1.00). Suite 1045/0 green; batched oracles 11/11 (the CPM
extend-join golden failure PRE-EXISTS — stash-proven). The Phase-3 gate
items named here (prompt cache for batched rows, compiled decode at B=1)
both LANDED in Phase 3.2 above; quantized KV under batching landed as
Phase 3.1 above.

## Where we were (2026-07-02)

**Current release: v0.0.10** (2026-07-02, shipped on all channels) —
batching parity with oMLX (`--batch 4` matches/beats on all three shared
models), SSD KV cold tier (`--ssd-cache`: restart TTFT 12.1 s → 0.24 s, 0%
decode overhead), `--model` real override in serve/bench, serial-lane
responsiveness fix (/stats 2.5 s → 10–44 ms mid-generation).
**In-tree version: 0.0.11, UNRELEASED** — structured output merged
2026-07-03 (next-action #1 below); `bun run release` ships it (also
updates the Homebrew formula, which still points at v0.0.10).

**Faithful→L1 consolidation (2026-07-04, branch `faithful-decode-parity`,
uncommitted):** the faithful (`@mx.compile` geglu/swiglu) kernels are now the
DEFAULT for every model (qwen3/qwen3.5/universal compile unconditionally; gemma
via `MLX_BUN_COMPILED_GEGLU`, default on); the custom non-bit-exact fused-gelu
Metal kernel is now opt-in. `--l1` is a pure, hand-reproducible alias (added
`--compiled-activations` + `--fused-gelu` forks, wired into the tier presets).
`MLX_BUN_FAITHFUL` and the four unwired `Faithful*` subclasses were DELETED
(`src/faithful.ts`→`src/flags.ts`); `FaithfulMiniCPM5` was kept as the A/B
reference then retired 2026-07-05 (Phase 1). Factory no longer detours gemma
through the monolith. Bit-exact vs
mlx-lm re-verified (universal/generated/gemma/cpm5 parity, tsc 0). Plan +
decision table: [docs/design/faithful-l1-consolidation.md](docs/design/faithful-l1-consolidation.md).
Open: live qwen3-dense parity (needs a box with Qwen3-Embedding) + clean-machine
bench numbers (`./benchmark.sh --redo`).

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
   **Remaining work is now sequenced in the integration plan below**
   (B2+F4 = its Phase A; F5/F7 structural tags + U1/U2 parked with
   triggers).
2. **Grammar × spec × batching integration** — plan:
   [docs/design/grammar-spec-batching-integration.md](docs/design/grammar-spec-batching-integration.md).
   **Phases A, B, C, E EXECUTED 2026-07-03** (same session as the plan):
   **A** ✅ B2 batch-grammar gates (`tests/batch-grammar.test.ts`,
   `MLX_BUN_TEST_BATCH_DECODE=1`) + F4 per-TokenizerInfo compiler cache
   (single-flight) + F6/F3.
   **B** ✅ `serve --draft-model` / `--num-draft-tokens` (two-model spec,
   serial lane, `DraftSource` seam): **L1 GATE PASSED — 48/48
   token-for-token vs mlx-lm's speculative path** (Llama 3B target + 1B
   draft, 65% acceptance; oracle `scripts/oracle-spec-two-model.py`; tests
   `tests/spec-serve.test.ts`, `MLX_BUN_TEST_SPEC_SERVE=1`). `hasDraft`
   routes all requests serial under `--batch` (upstream parity); ring-wrap
   degrades to plain decode pre-pollution; prompt-cache reuse bypassed v1.
   **C** ✅ grammar×spec constrained verify walk (drafter free-running, mask
   rides the accept walk, matcher advances on emitted tokens only — no
   rollback): valid + 12/12 token-identical to grammar-only serial.
   **E** ✅ harness: `scripts/bench-feature-matrix.ts` (six cells over live
   SSE; TTFT p50/p95, agg tok/s, acceptance, 100%-conformance HARD gate;
   `usage.speculation` telemetry). Smoke-run green end-to-end on Llama
   3B+1B. **Clean-machine run for RESULTS.md "composition" = Josh-gated**
   (use CPM/e4b for real batch cells — see the Tier-0 note below).
   **The conformance gate found 3 real bugs in one smoke run** (all fixed):
   (1) `response_format`/`guided_*` were DEAD over HTTP — the resolver read
   only camelCase, the server passes snake_case (pre-existing since the
   feature landed; both spellings now accepted); (2) `#flushPipeline`
   emitted pending tokens without advancing grammar matchers →
   one-token-stale masks on every mid-decode join (regression test added);
   (3) **UniversalDenseModel batching decodes uneven rows at wrong RoPE
   positions** (scalar `cache.offset`, no per-row offsets) — LATENT for all
   Tier-0 archs since v0.0.9. **FIXED same day**: per-row RoPE ported
   (`UniversalRope.applyDynamic` + `ops.ropeScaledDynamic`), **gated
   token-exact vs mlx-lm B=2 on Llama-3.2-3B** (static uneven rows AND
   dynamic join/leave; goldens `batched-golden-llama32-3b.json` +
   `batched-dynamic-golden-llama32-3b.json`). Plain full-attention
   universal archs now BATCH (Llama matrix smoke: batch2 1.7× serial agg,
   TTFT 765→162 ms); maskArray (gemma2-family) + sliding universal archs
   stay serial (unvalidated cells). Related finding, FIXED same day:
   tests/universal-rope.test.ts fixtures were machine-specific (generated
   on the M1 Max per manifest.json's oracle stamp; 5 failed bit-exactness
   on the M4 Pro) — now machine-keyed like the goldens layer (flat set =
   m1-max reference for CI, `tests/fixtures/universal-rope/apple-m4-pro/`
   holds the 5 differing files; regen recipe in the test header). 11/11 on
   both chips; the local-oracle match also re-proves the runtime bit-exact
   per chip.
   **Phase D COMPLETE 2026-07-04** — all three items landed and gated:
   `--kv-budget` aggregate KV admission (queue-don't-OOM, oversized
   rejects, /stats.batch fields; tests/batch-kv-budget.test.ts);
   vectorized homogeneous sampling (one argmax over [B,V] for all-greedy
   batches, BIT-equal A/B vs per-row, MLX_BUN_BATCH_VEC_SAMPLE=0 switch;
   tests/batch-vec-sample.test.ts); extend-join (extendKVRows = mlx-lm
   BatchKVCache.extend semantics, one pad+concat per join instead of the
   O(B·S) re-merge, MLX_BUN_BATCH_EXTEND=0 switch; own oracle
   scripts/gen-batched-extend-golden.py — token-for-token on CPM + Llama;
   rotating-layer extend is a follow-up, Gemma joins re-merge sliding
   layers only). **The integration plan is fully executed.** Next per
   Josh's priority ranking: spec×prompt-cache composition (parity-plan
   §7.6) then prompt-cache-under-batching (perf-path P3) — the disk-cache
   track. Debug lever: `MLX_BUN_GRAMMAR_DEBUG=1`.
   **FOUND + FIXED (2026-07-04): the multi-turn prompt-cache miss.**
   12B turn-2 TTFT was 8.9 s (full re-prefill): at context > sliding
   window a hit requires an EXACT prefix (wrapped rings + quantized
   groups can't trim), and TWO drift sources break exactness — the
   assistant reply's decode→encode roundtrip, AND the template's
   generation PRIMER (12B ends prompts with `<|channel>thought` tokens
   the next turn's render never contains; found via token-level probe).
   **The fix: stable-boundary snapshot** — promptIdsFor probes the
   re-render (conversation + a fake reply) for the stable prefix;
   generate() gains `snapshotAt`/`onPrefillDone` (prefill splits at the
   boundary, fires while caches hold exactly that prefix);
   `cloneKvCaches` (kv-store.ts) makes zero-copy view clones of all five
   cache kinds; the server re-puts the boundary entry on every
   substantial request (take() CONSUMES entries, so hits must re-seed
   the next turn). **Measured: 12B turn-2 TTFT 9.0 s → 447 ms (2k) /
   19.2 s → 461 ms (4k)**; e4b intact; server-compat + grammar +
   spec-serve suites green. **Follow-up (open):** the bench's cache-ssd
   CELL still misses on 12B (RAM cap=1 forces every turn through disk;
   spill writes the files, e4b restores them, 12B doesn't — suspect
   find/restore on its mixed rotating-quantized entries); real-world SSD
   flow (normal RAM cap + restart survival) benefits from the boundary
   entries via ordinary spill. The
   12B/e4b mode-matrix results live in benchmarks-modes-2026-07-03/04.md
   (local artifacts); headline 12B: decode pinned ~24 t/s in EVERY tier
   (the wall), prefill ~260 t/s (M4 Pro compute-bound), batch4 agg 2×,
   grammar cells need a truncation-vs-nonconformance distinction in the
   bench (order-dependent FAILs reproduce as PASS in isolation).
   **Spec-decode sources (Josh directive 2026-07-04): DSpark is the GOAL
   drafter.** The Llama 3B+1B pair exists ONLY as the L1 oracle cell
   (mlx-lm can only speculate two-model, so proving the serve loop
   token-exact required that shape). Product path behind the SAME
   `--draft-model` seam (parity-plan §7.9): (1) near-term
   **AssistantSource** — the optiq KV-borrowing gemma assistant drafters
   (e4b + 12B artifacts downloaded, `src/spec/drafter.ts` bit-exact vs
   optiq; 12B γ=1 ≈ 1.09× measured) wrapped as a DraftSource (L2 oracle =
   optiq spec_generate); (2) the goal **DflashSource = DSpark** (L3,
   KL-gated) — blocked on its research milestones, NOT serve wiring:
   27B/12B retarget (regen+train), data scale (~thousands vs 160),
   draft-loop tightening (docs/investigations/dspark-handoff.md).
   **Benchmarks built 2026-07-03/04:** `scripts/bench-modes.ts` (mode
   matrix: TTFT/prefill/decode/agg/peak-mem across l1/l2/l3, kv4/8,
   nocompile, batch2/4, conc-4 queueing baseline, grammar cells,
   cache-ram/cache-ssd multi-turn agent cells, spec via --draft; model is
   a param, default e4b) + docs/reference/features-matrix.md (the full
   option inventory). e4b loaded-machine shape: cold long-TTFT ~2.0 s →
   **cache-ram 125 ms / cache-ssd 231 ms**; batch4 agg 111.6 t/s vs
   serial-conc4 52.4 (TTFT p50 302 ms vs 3.8 s).
3. **Decode-speed program** — THE ranked path to faster tokens, written
   for pickup: [docs/design/decode-speed-program.md](docs/design/decode-speed-program.md)
   (2026-07-04). Baseline decode is at the bandwidth wall (mode-matrix
   confirmed the roofline); the levers, in order: **1a AssistantSource**
   (gemma assistant drafter behind `--draft-model`; artifacts downloaded,
   L2 oracle, 12B γ=1 ≈ 1.09× already measured) → **2 mlx bump**
   (qmv_wide merged upstream + gather_qmm M=1 in flight = the 26B fix;
   re-run parity + bench-modes) → **3 oQ quant spike** (~3.5 bpw at equal
   KL ≈ +10–15% decode) → **1b cheaper drafter head** → **1c DSpark**
   (the GOAL drafter, ~2–3× on 27B; blocked on its research milestones,
   not serve wiring) + §4 host residuals as filler. Scoreboard =
   `scripts/bench-modes.ts` after each lever.
4. **Menu bar app** (SwiftUI + signed binary as sidecar) — adoption map #2,
   Josh wants it; /Applications/oMLX.app is the structural reference.
5. **Batching remainder not in the integration plan** — P1 quantized KV at
   B>1 (P2 perf-kernel-at-B>1 is OBSOLETE — kernel deleted 2026-07-05), P3
   prompt-cache/adapters/default-review tail, P4 device-side step chaining
   (the cpm5 single-stream −20% counter). Superseded by the unified-engine
   plan's Phase 2/3 (docs/design/unified-engine-frontier-plan.md).
   [docs/design/batching-perf-path.md](docs/design/batching-perf-path.md);
   older queue: batching-v2-plan steps 4–10.
6. **SSD tier P4 hardening** — kill-mid-write e2e, adapter-ns isolation e2e,
   scheme-flip invalidation e2e.
   [docs/design/ssd-kv-cold-tier.md](docs/design/ssd-kv-cold-tier.md).
7. **oQ-style quantization spike** in `convert` (eval-gated; arXiv-lens).
8. **Web-UI fix wave** — 6 bugs, landing order in
   [docs/planning/web-ui-pass-plan.md](docs/planning/web-ui-pass-plan.md).
9. **Remaining compat verbs/flags** (`--draft-model` itself is now
   integration-plan Phase B; still open: cache_prompt, evaluate,
   awq/dwq/gptq; flags: --chat-template*, --min-p, --log-level,
   --allowed-origins, --prompt-concurrency, --prefill-step-size) —
   [docs/design/mlx-lm-tool-parity-plan.md](docs/design/mlx-lm-tool-parity-plan.md).
10. **Curve sampler H2/H3 preregistered run**
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

1. **Fresh clean-machine benchmark** (reboot + `sudo purge` first):
   - `./benchmark.sh --redo` — the standing h2h rows.
   - The NEW composition matrix, per model (writes
     `benchmarks-feature-matrix-<date>.md`):
     `bun scripts/bench-feature-matrix.ts --model <cpm5-snapshot> --batch 4`
     (real batch cells), same for e4b; for spec cells the Llama pair works
     today (`--model <3B-snapshot> --draft <1B-snapshot>`), and the 12B
     needs a small same-tokenizer gemma draft (or the assistant drafter
     once it's behind --draft-model, parity-plan §7.9).
     Promote quotable rows to benchmarks/RESULTS.md "composition".
2. **M4 Pro post-rewrite reset** + delete the mirror backup tarball (see
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
