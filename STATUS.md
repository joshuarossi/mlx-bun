# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity contract:** **L1** = mlx-lm bit-exact parity (the naked default) ·
**L2** = mlx-optiq bit-exact parity (mixed-KV composition) · **Lab** = original
optimizations with no external oracle, gated by KL/eval + a paired-A/B win vs
the L1 baseline before any default (docs/design/unified-engine-frontier-plan.md).

## Where we are (2026-07-07 — decode@ctx gap closed: SSD write-behind flush is now idle-gated)

**The bun arms' decode@ctx losses in the 07-07 bench (e4b −9.3%, 12B
−3.9% vs mlx-lm, while short-ctx decode won on every model) were
SELF-INFLICTED CONTENTION from the --ssd-cache write-behind flush, not a
kernel gap.** The "non-blocking" flush (storeAsync on ssdWriteChain) was
only non-blocking at the event-loop level: every per-tensor step is
`ops.contiguous` (a kernel on the SAME GPU stream decode uses) →
`rawBytesView()` → a synchronous `mlx_array_eval` that blocks the JS
thread until the stream drains → a synchronous multi-MB `writeSync`, and
the `setImmediate` pacing interleaved those slices exactly between decode
tokens. The bench's decode@ctx is the median of {cold, rep1, rep2}; the
debounced ~16k-entry flush (0.4–1.1 GB bf16) lands exactly on the cached
repeats. Only bun arms carry --ssd-cache — mlx-lm runs no equivalent
background work. Internal control in the bench data: the mixed arm (4×
smaller flush bytes) BEAT both bf16 arms at decode@ctx. Reproduced
standalone (e4b, 9.5k-token entry, busy box, directional): pre-fix rep2
37.9 vs cold 47.1 tok/s (−20%); post-fix flat 45.6/44.3/45.3, restart
survival still PASS (cached=9575 after kill+respawn); the
MLX_BUN_SSD_WRITEBEHIND=0 control is equally flat (43.4/43.6/47.1 —
gated ON ≈ OFF, the gate leaves nothing on the table) with restart
cached=0, by design. Fix
(`src/serve/generation-gateway.ts`, `src/kv-store.ts`, `src/ssd-cache.ts`,
`src/server.ts`): `gateway.busy`/`onIdle()` cover BOTH lanes (the serial
lane holds the mutex but shows zero rows — activeRows alone was blind to
it); `saveKvCacheAsync`/`storeAsync` take a per-step `waitTurn` gate
awaited before EVERY tensor (a request arriving MID-flush pauses the
remaining tensors); both chain sites (write-behind snapshots AND
eviction/demotion spills) pass `() => gateway.onIdle()`.
`MLX_BUN_SSD_WRITEBEHIND=0` disables write-behind snapshots entirely
(kill switch + paired-A/B lever, server-config.md). Accepted tradeoffs
documented in ssd-kv-cold-tier.md's 07-07 scheduling-contract addendum
(durability waits for a quiet moment; spill clones' GPU release deferred
while busy, bounded by the chain). Final vs-mlx-lm decode@ctx numbers
need the quiet-machine bench rerun (loadavg was ~4–7 throughout; a
residual genuine kernel gap at 16k is not excluded — xctrace on quiet).

## Where we were (2026-07-07 — 12B completion-probe parity closed: prefill tail split)

**The 12B completion-probe parity ✗ (07-07 bench @3d56676, diverged at
char 24 in the degenerate "1111…" stream) was a STEP-0 PREFILL-CONVENTION
mismatch with the oracle.** mlx-lm 0.31.3 — BOTH its routes — prefills the
prompt only to len−1 and computes step-0 logits from a separate **L=1
forward of the last prompt token** (serial `generate_step`: drain loop
`while total−processed > 1`, then `_step(prompt)`, generate.py:430-453;
the server's batched engine: `insert_segments` forces a final 1-token
segment + `GenerationBatch._step` forwards `inputs[:, None]`,
generate.py:1645/1182/1327). We forwarded the ENTIRE final chunk and
sampled step 0 from its last position — the same token at L=1 (qmv +
vector SDPA) vs as the tail of an L=n GEMM (qmm + L-dependent SDPA) is
ulp-different in bf16 in BOTH the step-0 logits and that token's stored
KV; near-tie greedy streams flip (12B flipped at step 24 — reproduced
with per-step top-2 logprob dumps, scripts/experiments/step0-top2-dump.ts
vs the oracle transcript). Fix: generate.ts + batch-scheduler.ts
`#prefillChunk` now drain to len−1 (chunks of `min(chunkSize,
remaining−1)`) and step-0 is an L=1 forward — bookkeeping unchanged
(after step 0 the caches cover exactly the prompt, as before);
`MLX_BUN_PREFILL_TAIL_SPLIT=0` is the kill switch (server-config.md).
Verified: 12B AND cpm5 CLI-route A/B vs oracle = 64/64 token ids AND
top-2 logprob values IDENTICAL, first diverging step NONE; serve-level
HTTP probes (scripts/experiments/serve-parity-probe.ts) = completion +
chat probes byte-IDENTICAL vs live mlx-lm servers for cpm5, e4b, AND 12B
on both bun arms (unified + --batch 1). (The e4b cells were initially
asserted without a recorded run — the completeness audit flagged it; a
recorded probe run landed 2026-07-07: all four e4b cells IDENTICAL,
completion 384 chars / chat 258 chars, prompt_tokens 6/6 + 32/32.)
Fallout re-anchored: mixed-KV
golden composition now mirrors the oracle serve loop (prefill ids[:-1] →
convert → L=1 step-0; regen-mixed-kv-goldens.ts + both goldens regen'd on
this box) — gate 1's step-0 GEMV-vs-GEMM argmax anchor is RETIRED (strict
bit-compare passes, incl. batched B=1); gate 2's padded-row KL envelope
recalibrated 5e-2→2e-1 (deterministic 1.21e-1 at K=6, the documented
join-geometry threshold-effect amplitude; unpadded row stays bit-exact
incl. step 0); generated-parity's compiled-lane dispatch count is now 1
(the L=1 step-0 legitimately rides the generated quantized fast path).
Pre-existing failures on this box, NOT this change (stash-proven at
baseline): kv-quant.test.ts ×3 + parity.test.ts (stale machine goldens —
regen chip spawned), batch-grammar B=4 (chip spawned), batched extend-join
oracle (known). Spec-decode serve lane re-anchor: **DONE 2026-07-07 on
`feat/dspark-spec-decode`** — and its oracle's true shape turned out to be
MORE than tail-split: `speculative_generate_step` drains BOTH models to
len−1 with **no separate step-0 at all** (the un-drained last prompt token
heads the first verify window; an L=1 step-0 is still ulp-different from
the (1+γ)-window GEMM head and flipped a knife-edge). The live gate also
caught a pre-existing bug: an EOS accepted AS A DRAFT leaked through
onToken as content. Both fixed; gated 4/4 token-for-token vs the oracle
venv (templated prompts, γ∈{2,3}, pinned in tests/spec-serve.test.ts "L1
knife-edge"); the optiq-oracled standalone `specGenerate` deliberately
keeps full-prompt prefill (per-scheme-oracle doctrine — optiq's own
convention, read from the installed source). Goldens on the M4 Pro
reference box need the same regen when work moves there.

## Where we were (2026-07-07 — cpm5 completion-probe parity closed)

**The MiniCPM5 completion-probe parity ✗ (07-07 bench, diverged at char
249: trailing `" "`) was a DETOKENIZATION artifact, not logit
divergence.** The 64-token greedy streams are identical; the
max_tokens-final token is the bare-space token `Ġ` (id 242).
mlx-lm 0.31.3's `BPEStreamingDetokenizer.add_token` WITHHOLDS a
single-char byte-32 token in `_unflushed` ("For single spaces wait until
the next token", tokenizer_utils.py:206-218) and `mlx_lm.server` NEVER
calls `finalize()` (zero hits) — so mlx-lm silently DROPS a genuinely
generated token's text when generation ends on a bare space; our
full-sequence StreamDecoder kept it. Fix: StreamDecoder now mirrors the
serve semantics for ByteLevel tokenizers (`LoadedTokenizer.
bareSpaceTokenId` = vocab["Ġ"]): push(bareSpace) emits nothing, the next
token's delta carries the held run, flush() drops a trailing run.
Verified END-TO-END over HTTP: our server (batch 1 AND batch 8) now
renders bytes IDENTICAL to a live mlx_lm.server on the same snapshot
(249 chars, `…numbers greater than`). Model-free regression tests pin
the served id stream (tests/serve-detok-parity.test.ts); suite +
whole-repo tsc 0 green. Two durable observations: (1) upstream-worthy —
mlx_lm.server drops served text on a final bare-space token (its own
stream_generate+finalize path disagrees with its server path; candidate
lab/repro + upstream report). (2) mlx-lm's greedy stream is
ROUTE-DEPENDENT at bf16 near-ties: its CLI route (stream_generate,
full-prompt GEMM step 0) picks "focuses on" at step 50 where its OWN
server route (BatchGenerator prompt[:-1]+[last] split) picks "deals
with"; our serve matches its serve — serve-vs-serve is the contract.
Latent hazard flagged in code: clean_up_tokenization_spaces=true BPE
models have an extra mid-stream `_space_matches` rule we don't emulate
(both current BPE targets are false). No served-surface change → no
reference-doc edits.

## Where we were (2026-07-07 — A7 closure: ssd-cache RSS)

**A7 ("ctx/restart legs read high on --ssd-cache arms") root-caused in
three parts and closed** (src/kv-store.ts; fixed against the 07-07 bench
at 3d56676). (1) WRITE residual — the v3 streaming writer's per-tensor
`rawBytes()` ended in a JS-heap `.slice()`; dead copies outlive the flush
under GC lag. Now hashes/writes from a ZERO-COPY view of the contiguous
mlx buffer (`MlxArray.rawBytesView`); save allocates no JS-heap copies at
all and 0 extra mlx bytes for contiguous sources. (2) RESTORE — the
zero-copy mmap wrap became a per-restore PROCESS-LIFETIME mapping leak
after the 07-06 FFI-dtor fix (retainMmapForProcess — now DELETED), and
exact-offset-sized restores made the first decode step concat-copy the
whole entry. Restore is now a STREAMED COPY (`fromBytesCopy` per tensor +
`MADV_DONTNEED` + unmap-before-return; plain-KV lands in STEP-rounded
capacity with slack): measured peak = live entry + ONE tensor (552 vs
520 MB on a 512 MB synthetic), vmmap-clean, 12B cold cache-load→first
token 277 ms (parity with the old ~240 ms). Copy-restore byte identity
pinned for all five cache kinds (save→load(verify)→re-save
hash-identical, tests/kv-store.test.ts) + real-model bf16/quant/SSM
continuation suites green. (3) NOT a defect — most of the benched leg
delta is `ps` RSS ACCOUNTING: the write-behind's hash+write CPU-touches
the live KV entry and makes already-allocated unified-memory pages
visible (GPU-written buffers and python-arm KV never show in ps RSS —
proven with mlx active/peak counters + footprint probes). bench-serve.ts'
hardcoded "fix A7 pending in src" note replaced with the accounting
footnote. Docs: ssd-kv-cold-tier.md addendum, server-config.md restore
rows. Residual: quiet-machine bench rerun for quotable before/after legs.

## Where we were (2026-07-06, round 2 — finish-the-list)

**Everything on the open list is closed** (PLAN.md "finish-the-list"
phase; suite 1127/0, parity suites green on every change): e4b long-ctx
prefill at parity via the causal-mask fidelity fix (makeMask now hands
mlx the string "causal" for windowless multi-token chunks at any offset,
matching mlx-lm cache.py:114-125 — 872 vs 877 post-fix, was 845-862 vs
878); incremental tokenizer encode (16-59x on conversation appends,
exact via seam verification); SSM per-row extraction for Qwen3.5
hybrids; the last JS-callback buffer dtor eliminated (fromView →
native dtor + explicit JS-thread unpin); eviction-spill and demoteIdle
non-blocking (SpillSink clones + storeAsync chain); Phase-2 host-tax
worklist audited down to three real items (12B KL-max outlier, CPM
extend-join golden regen, padded-B>1 mask rebuild pending a
forced-padding A/B). Final full h2h: benchmarks-serve-2026-07-06e.

## Where we were (2026-07-06, round 1)

**Serve-bench defect sweep (2026-07-06, this session):** the 07-06 serve
h2h (valid — quiet machine) surfaced five defects; a 20-agent verified
investigation reduced them to root causes and the fixes landed together:

- **FFI deadlock/crash (the "cpm5 serial timeout" — a real product bug):**
  `MlxArray.fromPointer` registered a bun:ffi JSCallback as the mlx buffer
  dtor; mlx releases the LAST Data reference from the **Metal completion
  thread** (gpu::eval retains buffers until the command buffer finishes),
  and a JS callback invoked there deadlocks serving (completion waits on
  JS, JS blocked in `mlx_async_eval`) or SIGTRAPs mid-GC. Repro'd
  deterministically (SSD-restored KV + streamed request), fixed with a
  native no-op dtor (`dlsym(free)`, payload 0) + process-lifetime pinning
  of restore mmaps (eager unmap-after-dispose was unsound — mlx can hold
  pages past dispose). `fromView` (expert-offload only) still carries the
  JSCallback — flagged hazard. NOTE: bun:ffi symbol `.ptr` returns the
  address bit-cast to float64 (lab/repro/bun-ffi-f64) — use dlsym.
- **Gemma prompt cache dead / restart-0 (one invariant, three tiers):**
  mlx-lm guarantees a trim-free `prompt[:-1]` entry for every request
  (insert_segments' last-token split) and makes insert+fetch
  untrimmability-aware; we had that in one tier of three. Landed: serial
  boundary cap `min(stableLen, len-1)` + `snapshotAt` plumbed so the hook
  fires mid-prefill (A1); batch-lane boundary snapshot via a
  chunk-split at the boundary (A5 — fixes 12B batched 84s ctx repeat);
  SSD supersede trimmability guard + usability-aware `find()` +
  header-derived trimmable flag (A2/A4); write-behind debounce keyed by
  ns+length so the final put can't cancel the boundary write (A3);
  unconditional exact-duplicate dedupe in RAM `put()` (A6); loud logs on
  every silent-degrade path (A8). Unit-tested (prompt-cache/ssd-cache).
- **RSS:** `saveKvCache` streams per-tensor now (format v3, fixed-width
  hashes; v2 files self-invalidate) — the write-behind no longer spikes
  RSS by the whole entry (A7). Prompt-cache default cap is now
  8 GB flat (Josh's call), overridable via `--prompt-cache`.
- **Bench harness (B1-B4):** per-phase AbortSignal budgets scaled from
  measured tps (the two vanished arms were Bun's implicit 300s fetch
  timeout), phase-tagged failures that keep measured cells, child stderr
  tails, /v1/completions engine-parity probe + pinned `enable_thinking`
  chat probe (template drift no longer renders as fake "diverged at char
  0"), per-leg RSS attribution.
- **Mixed-KV "prefill loss to optiq" was FAKE — and the arm is now off
  the default bench:** LIVE-verified (runtime spies + a crash repro):
  optiq serve's KV-quant is inert on mlx-lm 0.31.3's batched path (all
  seedless requests = bf16), and seeding is NOT a workaround — a seeded
  request quantizes into the shared prompt cache and the next batchable
  request crashes the worker (`QuantizedKVCache does not yet support
  batching with history`). So the optiq-mixed HTTP arm just re-benchmarks
  mlx-lm bf16; it's removed from the default arm set (resurrectable via
  --arms). Mixed-KV perf compares mlx-bun-mixed vs mlx-bun; correctness
  stays on script-driven optiq goldens (the L2 oracle, which DOES
  quantize). lab/repro/optiq-mixed-kv-inert has the upstream ISSUE draft
  (one open question flagged: which converter fires on the seeded path).
  Our ~33% mixed-vs-own-bf16 long-prefill cost is scheme-intrinsic
  (lever: upstream quantized_matmul split-K). RESULTS.md annotated.
  Also learned: `ps` RSS is BLIND to python-mlx KV memory (measured flat
  through a 12k prefill) — never use RSS as a quant/memory signal for
  the python arms.
- **Rerun DONE same day (benchmarks-serve-2026-07-06b + 06c splice):**
  all fixes verified at full scale — e4b warm 80ms/657 (was 1346/4), 12B
  batched ctx repeat 705ms (was 84.4s), gemma restarts restore in full,
  decode leads mlx-lm 14-33% across models, agg×4 up to 2.4×. 12B
  mlx-lm baseline mystery solved: plain mlx_lm.server can't load
  gemma4_unified (worker dies, HTTP zombies) — baseline runs via optiq
  register() bf16 now. Prompt-cache default 8 GB (Josh). Follow-ups:
  batched-lane per-row cache extract under real concurrency (PLAN);
  /v1 leading-whitespace surface diffs vs mlx-lm; kv-quant RSS tripwire
  false-positive on 1B models.

## Where we were (2026-07-05)

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

**BENCHMARK HARNESS REDESIGNED same day (Josh: "run the correct things in
the correct ways"):** scripts/bench-serve.ts is the primary pass — REAL
CLI at REAL defaults (the scripts/serve.ts wrapper is deleted; bench-h2h's
legacy server leg repointed at the CLI too), one server per cell serving
ALL metrics over HTTP: decode (stability policy), cold/warm-cached TTFT,
prefill, long-context via ONE prefill + 64-token decode samples (never
"generate 16k to measure 16k"), agg×4 concurrent, ready-time. Context
recorded from measured usage.prompt_tokens. Oracle venv's console scripts
have STALE SHEBANGS (venv was moved) — python arms now invoke via the venv
python. benchmark.sh: default = serve pass (~15-30 min); --engine = the
old in-process kernel/memory/A-B matrix. Dirty-box smoke (NOT quotable):
all four arms work; warm TTFT 26 ms (ours) vs 108 ms (mlx-lm) at equal
cached tokens; agg×4 271 vs 185. NEXT QUIET-MACHINE RUN IS THE ARBITER —
including defaults-vs-defaults decode and the B=1 hop-fix verification
(cpm5 1.012 / 12B 1.005 paired post-fix; e4b reading unresolved on the
throttled box).

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

### Audio input — phase opened 2026-07-07 (branch `josh/audio-input`)

Audio-in/text-out through the chat API, e4b first. Survey done: mlx-lm
strips audio entirely (sanitize pops the towers, server 400s non-text) →
the oracle is optiq's internal gemma4 machinery (USM mel extractor +
12-block Conformer + embed_audio, complete but unexposed by its own serve
frontend). The local e4b OptiQ-4bit sidecar ALREADY carries all 752 audio
tensors + `audio_config` + token ids (boa 256000 / audio 258881 / eoa
258883) — no downloads. Plan + phase boxes: PLAN.md "audio input" phase,
design in [docs/design/audio-input-plan.md](docs/design/audio-input-plan.md).
**A0 DONE (2026-07-07):** conv2d bound (found + worked around a bun:ffi
stack-arg ABI bug — see CLAUDE.md hard-won facts +
lab/repro/bun-ffi-stack-args), §3.3 semantics resolved (audio strictly
causal), fixtures + oracle goldens live (speech greedy = token-perfect
transcription). A0-A4 DONE — audio is SERVED on e4b: live HTTP transcription matches the
oracle golden EXACTLY, mixed image+audio grounds on both media, serial-lane
isolation proven, docs shipped in the same commit. Capability discovery
landed 2026-07-07 (post-merge CodeRabbit follow-up): `audio` mirrors
`vision` on /v1/models, /library, and the pi ws `ready` frame —
`audioCapable` in src/registry.ts checks TENSORS not just config
(`has_audio_config AND has_audio_tower`, header-only scan), so the 12B
stub sidecar reads audio=false everywhere and clients stop probing for
400s. Remaining: A5 (quotable
bench cells need a QUIET machine — Josh-gated; 12B audio cell needs a
sidecar rebuild via optiq build_vision_sidecar — download, Josh-gated). A1 DONE:
mel port is 1-ulp-f32 from the oracle (the numpy f32 Hann window is baked
in as the spec — see PLAN.md A1).

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

### DSpark speculative drafter — PAPER CODE-COMPLETE + SERVE-INTEGRATED + DEEPSPEC ORACLE (2026-07-06); download-gated payoff

**Phase 3 (same session): DeepSeek open-sourced DSpark** (DeepSpec, MIT +
trained drafters incl. `dspark_gemma4_12b_block7` FOR OUR 12B TARGET) — so
DSpark now has a real oracle ("if someone did it, there is already an
oracle"). Two audit agents verified our build vs the paper (arXiv:2607.05147)
+ source: our loss/backbone/Markov/confidence match the paper EXACTLY; our
scheduler matches the RELEASED reference (paper Alg-1/STS = their unreleased
production layer); our Elman RNN differs from the paper's gated cell (kept as
variant). **Their module is a different architecture** — ported faithfully
(`src/spec/dspark/deepspec-module.ts`, copy-verbatim w/ source citations;
k≡v single-KV attention, scale 1.0, partial RoPE 0.25, layer_scalar, softcap,
incremental context-KV cache), wired behind the seam
(`src/spec/deepspec-source.ts`, kind auto-detect on the `Gemma4DSparkModel`
config stamp), reviewed (7 findings fixed: bf16 sampling fidelity, conf-head
leak+precision, ~+4.8 GB transpose-copy memory, 3 silent-wrongness guards).
Enablers fixed along the way: generated gemma forwards now fall back to the
monolith when hiddenTap is set (they never captured — 12B tapping would have
thrown; generator patched too), and the seam accepts d=0 (DeepSpec ℓ=0 = plain
tapped step). Oracle scripts staged (temp-0 RNG-free trace: `scripts/
oracle-dspark-deepspec.py` → `scripts/dspark-deepspec-compare.ts`). Real 12B
tap layers `[5,17,29,41,46]` adopted (our guess superseded). **PATH A RAN
2026-07-07 (post-merge): τ ≈ 2.8 (2.7× fewer target forwards, losslessness
holding) but wall-clock −3.4× — the 6.9 GB bf16 drafter's own tax. The
follow-up program is fully planned:
[docs/design/dspark-serving-program.md](docs/design/dspark-serving-program.md)
(drafter quantization — 4-bit baseline then TurboQuant as its lowest-risk
first customer — + draftBlock tightening + generated-forward tap + the
serving-UX/defaults pass; Josh picks up at TurboQuant merge, only Phase 5
actually waits for it).**

**Phase 2 (same session): every remaining paper component LANDED** via a
multi-agent build + adversarial review — Alg-1 confidence-scheduled
draft-length pruning (variable-length `DraftSource.draft()` contract, serve
loop verifies over the returned length; activation is checkpoint-driven so
uncalibrated checkpoints are unchanged), STS calibration §3.2.1
(`src/spec/dspark/calibration.ts` + `scripts/dspark-calibrate.ts`), the RNN
sequential head Eq 6 (`--seq-head rnn`, init-equivalent to Markov; ⚠
design-doc-faithful shape, paper PDF absent — flagged in code, as is the STS
estimator), the tightened draft loop (on-device token chaining, deferred conf
reads, `collectLogits:false` on serve; bit-identity pinned in
tests/dspark-infer-loop.test.ts), and the `dspark` variant rename + central
loader. A second adversarial-review wave (17 agents) confirmed 13 findings —
1 real logic bug (sample-path pruning misaligned tokens/conf/draftLogits →
OOB in verifySampling; found independently by all 3 reviewers) + 12
leak-shaped (inline-slice orphans, try-body locals invisible to finally,
calibration NaN poisoning) — ALL FIXED same session with regression checks
(the leak shapes are now a memory: [[mlx-inline-slice-leak-pattern]]).
Final gate: tsc 0 · smoke 22/22 · 84/84 across dspark+spec+server suites
(incl. real-weights; the grammar suite's `Aborted()` line is pre-existing
xgrammar WASM teardown noise, stash-proven). **All that remains is the GPU
recipe** (regen→train→calibrate→measure on 12B):
docs/investigations/dspark-handoff.md.

Architecture verified faithful (2026-07-01 review; overfit τ=3.24). **Phase 1
(this session, branch `feat/dspark-spec-decode`):** DSpark + the optiq Gemma
`-assistant` drafter are now serve-loadable behind `--draft-model` — the
`DraftSource` seam was extended for KV-borrowing sources (target donor-KV /
anchor-hidden / tapped H_ctx), provider kind is auto-detected (`dspark.json` →
DSpark, `*_assistant` → assistant, else two-model; `--draft-kind` overrides),
and the server pins `--num-draft-tokens` to a DSpark checkpoint's trained
γ. tsc-green, CPU smoke 16/16. **AssistantSource VERIFIED ON REAL WEIGHTS**
(`tests/spec-serve-assistant.test.ts`, e4b + assistant drafter, auto-gated):
serve-loop spec output is TOKEN-IDENTICAL to non-spec greedy for γ=1,2,3
(losslessness) + telemetry populates — the extended seam is proven end-to-end
(both providers share it). Ships a real ~1.09× γ=1 win with NO training. The
Phase-1 code was adversarially reviewed (multi-agent workflow) and 5
leak-on-exception bugs fixed (round/prefill scratch-tensor disposal on throw,
forwardMaybeTap partial-capture leak, DflashProvider.dispose). DSpark-source
correctness stays model-gated (needs a trained checkpoint — Josh's GPU).
Design + seam contract:
[docs/design/dspark-speculative-decoding.md](docs/design/dspark-speculative-decoding.md),
[[dspark-seam-kv-borrowing]].
**Remaining (this plan):** paper components (confidence-scheduled draft-length
pruning / STS calibration / RNN head), loop tightening, `dflash`→`dspark`
rename. **Josh-gated GPU:** data scale + **12B retarget** + train + live-τ
(27B is memory-infeasible to train on 24 GB — kept dim-generic). Handoff:
[docs/investigations/dspark-handoff.md](docs/investigations/dspark-handoff.md).

## Josh-gated (needs hardware / downloads / own shell)

0. **Audio A5 closeout** (branch `josh/audio-input`, PLAN "audio input"):
   - Quiet-machine bench cells → RESULTS.md: audio tower ms, TTFT delta
     vs text-only, RSS delta with the tower loaded (the serve test's e4b
     load+transcribe round trip was ~2.3 s on a loaded box — directional
     only, don't quote).
   - 12B audio cell: rebuild its sidecar via optiq `build_vision_sidecar`
     (selective download pulls only the audio shards; the local 12B
     sidecar holds 1 audio tensor) → then regen 12B audio goldens and
     clone the e4b test cells (per-model doctrine: every cell validates
     or defers explicitly).

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
3. ~~**Phase 13 — TurboQuant**~~ **v1 LANDED 2026-07-06** — `--kv-quant
   turbo[:k<bits>v<bits>]`, oracle = vllm-metal (vendored, bit-exact codec
   goldens), quality-vs-bpw curve gate passed on MiniCPM5-1B (k8v3 = 6.25
   effective bits @ KL 0.0325, beats uniform kv4). See PLAN.md Phase 13 +
   docs/design/turboquant-kv.md. Remaining follow-ups are non-goals recorded
   there (fused kernel, rotating layers, batching, QJL).
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
