# Qwen3.8-27B optimization campaign — execution log (2026-09-04 → 2026-09-08)

Verbatim move of `docs/design/decode-speed-program.md` §7.8 ("Execution progress and next measurements"); the per-row outcomes, retained flags and open gates it fed are in that doc's §7.13. Evidence filenames resolve to `reports/qwen38-rd/` on the measuring host (Apple M4 Pro, 24 GB unless stated); host names are provenance, not scope.

## §7.8 Execution progress and next measurements (as archived)

Use the integrated memory safeguards and relevant numerical controls in
section 7.1, then measure the expensive computation. The existing benchmark
accepts an exact local artifact and can print its
commands without loading a model. The first prepared jobs are the affine
flagship on mlx-bun serial versus mlx-lm, followed by packed Q3 on mlx-bun
serial. Start at 4k context; widen only after the measured memory row.
The commands and preparation mode are documented in
[benchmarks.md](../reference/benchmarks.md#running-the-benchmark).

The harness now keeps all five decode samples, uses reproducible nonces with
`--workload-seed`, pins thinking mode across arms, and saves request bodies,
counts, finish reasons, errors and wall times in a JSON companion. It rejects
missing token usage instead of counting SSE chunks as tokens. Each block
still needs an explicit AB/BA order and a distinct output path; one harness
pass is a screening block, not the full paired-session confidence interval.
Identical decoded text and prompt counts remain a smoke check; engine logit
and token-ID gates provide the stronger correctness evidence.

The matched-prefill MTP control exposed a separate ordinary-generation
latency cost: the serial loop constructs the next decode step before yielding
token zero. A runtime-only source transform yields the first sampled token
before that construction, retaining the later pipeline and excluding fill,
grammar and resumed generation. Its initial packed-model pair preserves every
token ID, live cache state, cache key, usage count and finish reason at raw
prompt lengths 6/128/512. Native first-token latency improves while complete
generation time is approximately flat. Six lifecycle tests, the 26 existing
fill-loop tests and 15 binding tests pass with the prototype. One binding
cancellation expectation needs the new event order: token zero may arrive
before cancellation triggered inside the subsequent forward; no token arrives
after cancellation. Consumer return at that first yield leaves a correctly
described prompt-only cache. Those screens changed only the runtime-loaded module.

The first serial HTTP pair preserves all seven warm/measured responses but
does not reproduce the native TTFT improvement. Client-visible output can lag
token zero through detokenizer buffering. A separate sink observer confirms
that these raw prompts first generate bare-space token 220, which emits no
event, followed by token 17 (`2`), which emits content and yields for network
progress. Both arms preserve that sequence; earlier delivery of the hidden
space cannot improve client TTFT. Keep this negative result and test chat
fixtures before attributing a serving win or integrating the prototype.
Both screens keep sources fixed and exit cleanly. Evidence:
`first-yield-native-screen{,-review}.json`, `first-yield-http-screen.json`,
`first-yield-http-observe.json` and its per-server `*.sink.json` records,
`first-yield-smoke-candidate-v2.txt`, `first-yield-existing-loop-tests.txt` and
`first-yield-binding-order-tests.txt` in the campaign report directory.

The subsequent three-fixture chat HTTP screen preserves all seven paired
responses and improves first visible output on each measured fixture, with
approximately flat complete-request time. Evidence:
`first-yield-chat-http-screen{,-review}.json`. A simplified version captures
the current sample index before yielding and increments the normal generated
count immediately, avoiding a second stats counter. Its control passes eight
tests and the candidate passes 49 lifecycle, binding and fill-loop tests,
including two- and three-token budgets. The first budget test expected an
explicit native `length` reason, but the incumbent leaves budget completion
implicit; the corrected assertion preserves that contract. Evidence:
`first-yield-v2-{control-tests,tests,tests-corrected}.txt`. The simplified
prototype then completes six fresh-process native pairs. All 36 warm/measured
token, live-state, cache-key and usage comparisons agree; every measured pair
improves first-token latency at all three prompt lengths. Complete generation
time is approximately flat. All 12 children exit cleanly with fixed sources
and the same remaining active allocation after explicit cleanup. Evidence:
`first-yield-native-v2-repeat{,-review}.json`. Six chat server pairs then
complete all 84 requests with 42 exact response/count/finish comparisons.
Every measured pair improves first visible output, with approximately flat
complete-request time. The sampled native audit also preserves token IDs,
requested log probabilities and live cache state across two seeds and two
prompt lengths, with penalties enabled. Both runs keep sources fixed and
exit cleanly. Evidence: `first-yield-chat-http-v2-repeat{,-review}.json` and
`first-yield-sampled-native.json`. Other artifacts and cached/pressure
acceptance remain, including first-token consumer return and follow-up reuse.

The serial change is now integrated behind `MLX_BUN_EARLY_FIRST_TOKEN=1`,
default off. Its scheduling decision comes from the binding's captured
runtime; request and execution interfaces are unchanged. Eight permanent
binding tests cover both settings, captured-policy isolation, short budgets,
early return, cancellation and initial EOS. The focused tests and enabled-fill
regression pass, as do all three typechecks, hygiene and the complete
model-free suite: 1,831 pass, 10 skip, zero failures. The first cancellation
test incorrectly expected final stats after an exception; the corrected test
preserves the existing null-stats contract for aborted runs. Orderly consumer
return still reports the emitted token and exact cache key. Real-model and
HTTP flag comparisons follow the prototype measurements before this thread
can close. Evidence: `first-yield-production-unit{,-v2}.txt`,
`first-yield-production-fill-enabled.txt`, `first-yield-production-typecheck.txt`,
`first-yield-production-hygiene.txt` and `first-yield-production-model-free.txt`.
The integrated packed-model native pair preserves all six warm/measured
token/state/key/usage comparisons. Its serial HTTP pair completes 14 responses
with all seven paired text/count/finish checks exact. Both reproduce earlier
first-token delivery and keep sources fixed with clean child exits. A slow
HTTP warmup is retained; these integration screens do not replace the six
balanced prototype pairs for timing evidence. Evidence:
`first-yield-production-native-r6{,-review}.json` and
`first-yield-production-http-r6{,-review}.json`. Closed source-transform and
duplicate test helpers are removed; permanent tests and raw reports remain.
The first integrated RTN4 native pair also preserves all six token/state/key
comparisons. Its apparent large complete-time difference is not accepted as
a speed gain: step intervals change substantially within the control process,
system swap grows and final preflight records substantial Chrome CPU use.
Keep this correctness result and repeat timing before attribution. Evidence:
`first-yield-production-native-rtn4{,-review}.json` and per-token arrival times
in the same report. No unrelated application was stopped.

The continuous scheduler has its own first-output boundary: an empty group
finishes preparation and emits token zero, then advances decode before its
event-loop yield. A separate prototype adds a yield only when preparation
leaves exactly one active row and no queued arrivals. It preserves grouped
short admissions and stops immediately if the group closes during that await.
Nine scheduling tests pass for each control/candidate arm; an actual
continuous HTTP screen must verify wire placement and client arrival time.
Evidence: `first-prepare-scheduler-{control,candidate}.txt` and the frozen
`first-prepare-http-screen-plan.json` in the campaign report directory.

Six subsequent AB/BA blocks complete on the M4 Pro with 12 clean server exits,
84 responses and 42 exact paired responses, including counts, finish reasons
and cache usage. The actual continuous lane and submitted-row increment are
checked for every request. Median paired TTFT changes are -7.66% for code,
-7.90% for explanation and -5.63% for JSON, about 74–77 ms earlier. Complete
request time changes by +0.15%, +0.04% and +0.08%, respectively. One code pair
has 2.20% worse TTFT and remains in the report. The machine begins with Chrome
CPU activity and existing swap, so these are diagnostic measurements. Chrome
is unrelated background load; a Bun HTTP client sends requests directly to
the server without the chat UI. Source hashes remain fixed. Evidence is
`first-prepare-http-repeat{,-review}.json`; scheduler lifecycle and broader
request gates remain before integration.

The continuous option is now integrated under `MLX_BUN_EARLY_FIRST_TOKEN`,
default off. The MLX backend reads its captured runtime and passes a boolean
to the generic scheduler. No request or execution-contract field is added.
After the early yield, the scheduler restarts its policy loop so new arrivals,
cancelled queued work, admission holds and shutdown are observed before the
next step. Eight added unit cases cover those transitions, short-admission
grouping, an existing active row and cleanup on a failed yield. All 1,839
model-free tests, the three typechecks and hygiene pass. Integrated real HTTP,
cache, pressure and quiet gates remain. The integrated native option also
passes four sampled cases per artifact on packed Q3 and RTN4, preserving all
32 token IDs, requested log probabilities, cache keys, live KV/recurrent state
and usage. Each arm returns to the same measured native allocation baseline
after disposal. These are correctness checks, not repeated timing claims.
Evidence is `first-prepare-production-{unit,model-free,typecheck,hygiene}.txt`
and `first-yield-production-sampled-{r6,rtn4}.json`.

The first integrated continuous HTTP attempt is retained as a setup failure.
Its driver set the new option after MLX imports had captured the runtime, so
the candidate's execution counter remained zero and rejected the run. The
corrected driver sets the flag in the child environment before imports. Both
arms then execute the same instrumented production source, with seven early
yields in the candidate and zero in the control. All seven paired responses
and usage/finish checks pass, with fixed source and clean exits. TTFT improves
by 68–90 ms across the three measured fixtures; this one-block integration
check does not replace the six prototype timing pairs. Evidence is
`first-prepare-production-http-r6-v2{,-review}.json`; the original unsuffixed
report preserves the failed path-coverage check.

Nine packed-Q3 native cache-lifecycle pairs also pass. At prompt lengths
6/128/512, each arm either returns after one token, returns after two, or
aborts after one, then reuses its own borrowed cache for a 16-token follow-up.
An early first-token return/abort covers the prompt alone; the incumbent has
already fed token zero. Clean-return cache keys reflect those exact positions,
and an aborted generation retains the existing null-stats contract. A
one-token follow-up suffix with ordinary tail splitting gives matched M=1
forwards for any missing emitted token. All subsequent tokens, requested log
probabilities, final live cache states and cache keys match. Both processes
return to 16,390 native active bytes after disposal, without forced GC, and
the source stays fixed. This proves the covered native reuse transitions;
HTTP cache/SSD pressure and broader suffix shapes remain. Evidence is
`first-yield-production-cache-r6.json`. The same nine pairs also pass on RTN4,
including every follow-up token, requested log probability, cache key and live
state. Both RTN4 arms return to six native active bytes after disposal. Its
separate evidence is `first-yield-production-cache-rtn4.json`.

The broader native suffix screen completes 110 follow-ups across both Qwen
quants at suffix lengths 1/2/3/4/5/8/31/127/511/512/513. It does not pass
universal identity. After returning at token one, the early arm's prompt-only
cache makes the next prefill one token longer. Seven packed and six RTN4
cases change log probabilities or live state; two packed cases and one RTN4
case also change emitted IDs. Every two-token-return case remains exact.
Feeding the missing emitted token separately at M=1 restores exact stopped
state and all 22 aligned follow-ups, including requested log probabilities
and cache keys. Both arms return to their original active-allocation baselines.
This identifies a prefill-shape effect, not a seed mismatch or a corrupted
snapshot. Keep the option experimental; reconciling the first-token cache
boundary needs an implementation and performance gate before default
promotion. Evidence is `first-yield-suffix-qwen{,-review}.json`. The preceding
Llama smoke also records a natural 512-token suffix state/logprob difference.

The integrated option also passes the saved seven-request agent-boundary/SSD
gate in serial and actual continuous serving on the M4 Pro 24 GB. The first
six one-token budgets retain their original path; each lane's counter proves
the new option runs once on the final 512-token request. All 14 paired choices
and complete usage records match. The longest prompt has 14,465 tokens and
reuses the same 12,953-token prefix in every arm. All four final flushes report
14 durable entries, no pending/missing/failed snapshots, and a longest durable
prefix of 14,976 tokens. Sources stay fixed and all servers exit cleanly.
These non-streaming responses establish the covered memory/cache lifecycle,
not a TTFT result or an agent task success. Broader suffix shapes remain.
Evidence is
`first-token-production-long-{serial,continuous}{,-review}.json`.

Actual streaming HTTP cancellation and arrival checks now pass 120 requests
across eight Qwen servers, covering packed Q3 and RTN4, serial and continuous
serving, and both option settings. Each server aborts twice at headers and
twice at first output, then completes an independent recovery request after
each abort. The server observes all 32 cancellations and settles before
consuming the 512-token budget. Every recovery response, usage record and
finish reason matches its reference. Final active MLX allocation equals the
loaded-model baseline exactly, with no cache entries or active/pending rows.
One-token budgets also remain exact. Both overlapping-arrival fixtures
observe two active rows in continuous serving, with actual admission counts;
serial serving remains serial. All sources stay fixed and servers exit
cleanly. A preceding Llama smoke adds 60 requests and 16 cancellations.
These instrumented checks establish lifecycle behavior, not speed. Concurrent
trajectories are not compared across differing admission timing and batch
shapes. Evidence is `first-token-lifecycle-{llama,qwen}{,-review}.json`.

The first actual continuous HTTP pair then completes all 14 requests with
seven exact response/count/finish comparisons and verified batched placement.
First visible output improves on all three measured chat fixtures; complete
time varies slightly. Both servers exit cleanly with fixed sources. This
remains a prototype pending balanced repeats and broader scheduling gates.
Evidence: `first-prepare-http-screen{,-review}.json`.

The first performance work after the pull uses the packed artifact's actual
k2/k3/k4 matrices. The M=1/2/3/4/5/8 screen identifies the gate/up crossover
and the down-projection bit-width asymmetry. Shared-M reduce and fused gate/up
kernels are retained as experimental variant 7 after exact matrix/MLP checks
and six balanced diagnostic A/B blocks. Variant 8 adds a balanced and aligned
3-bit down kernel; it improves the observed M=1/2/4 full-model forwards while
preserving logits, live state and subsequent-token checks. A device LUT for the existing f32
code values loses on this M4 and is recorded as a negative result. Kernel
implementation, commands and evidence live in turboquant.md's packed-kernel section.

The full packed 27B passes logits, live recurrent/KV state and subsequent-token
identity at M=1..5. Six paired native-forward blocks also retain the gain at
M=2/4, but they use a short synthetic prefix and project every output position.
They are not HTTP decode, verified MTP or strict-fill throughput measurements.
The existing exact-artifact graph/session/cache gate passes on the packed
model as well. Variant 6 remains the default.

The packed 27B strict-fill regression passes on variants 6 and 7: nonzero
assert injection, no verification events and exactly matching emitted tokens.
This is one tool-call fixture, not a held-out determinism or timing result.
The last-position-only native append sweep covers M=1/2/3/4/5/8/9/16 with
six paired blocks, preserving candidate/current logits and live state in every
cell. It retains the small-M gain and confirms the M=4/5 whole-model cost
discontinuity. Raw evidence: `reports/qwen38-rd/shared-m-append-lengths.json`.

Variant 10 now shares scatter decode across small M as well. It passes the
same exact full-model gates and improves M=2..4 against variant 8 in six
paired native blocks. Variant 9 separately moves expanded-projection
evaluation to the existing layer boundary. Its observed outputs agree, but
peak memory rises. Extending the packed crossover to M=8 is a distinct Lab
candidate with observed output differences. The packed-kernel section in
turboquant.md owns these implementations and evidence.

Integrated variant 11 adds direct tiled gate/up prefill for M=5..32, with
the same full-model logit/state gates and paired native improvement against
variant 10. The operation has no model-name dependency; its dispatch profile
currently covers the measured Qwen MLP geometry. It also improves the strict
fill fixture's complete generation time in six paired fill/no-fill blocks,
with identical emitted tokens and no verification forwards. This remains
fixture evidence, not a universal determinism proof. Evidence:
`variant11-full-model-review.json` and
`strict-fill-v11-cap32-served-eos.review.json`. Six paired raw-completion
HTTP blocks per method improve first-token and complete-request latency,
with identical output, through strict serial and continuous B=1 execution.
They cover one six-token prompt and eight/64 output tokens; concurrency and
broader-workload conclusions remain open. Evidence: `trellis-v11-http.json`
and `trellis-v11-http-review.json`.

Variant 12 adds tiled split-K down projection at M=5..8. The integrated
kernel passes exact full-model logits/state/continuation checks and improves
six native paired blocks without changing the paths outside that range.
Its implementation and sweep evidence live in turboquant.md. Serving and
combined-candidate measurements remain separate gates. The combined variant
12 versus original variant 6 now passes six raw-completion HTTP pairs for
each serial/default scheduling method, with matching text and actual token
counts at eight/64 output tokens. Source hashes stay fixed throughout all
24 bounded server processes. These one-prompt, B=1 diagnostics improve both
TTFT and complete-request latency; they do not establish concurrent load or
quiet-machine performance. Evidence: `trellis-v12-combined-http.json` and
`trellis-v12-combined-http-review.json`. The exact-input native control also
improves first-token and complete-request time in six paired blocks per
output length, with identical emitted IDs. One candidate worker escaped
through Bun with a C++ exception; its traced replay and the complete repeated
pair succeed. The original failed block is retained and excluded from timing
aggregation. This does not close the runtime reliability issue. Evidence:
`trellis-v12-combined-native-review.json`, its original/resumed reports and
`trellis-v12-native-failure-replay.json`.

The packed serving comparison now also covers four simultaneous raw
completions. Six fresh-process pairs compare variants 6 and 12, with a warm
four-request wave followed by a measured wave. Every arm observes four active
batch rows, all responses/counts/finish reasons agree, and the candidate
improves complete-wave throughput in every pair. Prompt and SSD caches are
disabled; the source snapshot stays fixed and all twelve servers exit cleanly.
These diagnostics establish that the shared small-M kernels improve actual
concurrent serving, alongside the earlier B=1 results. Mixed lengths, larger
concurrency and quiet-machine acceptance remain separate gates.
Evidence: `trellis-concurrent-http.json` and
`trellis-concurrent-http-review.json`.

The operation trace led to smaller M=5..8 matrix tiles and deferred evaluation
for direct tiles. Dense expansion retains its projection boundary. The
integrated kernels pass targeted units and an old-source/new-source comparison
at ten append lengths, including logits, live cache bytes and continuation.
Six subsequent HTTP process pairs compare the previous and updated variant 12
at B=1 and eight concurrent requests. Every wave observes the expected active
row count; all paired warmup and measured responses, token counts and finish
reasons agree. Eight-request throughput improves consistently; B=1 first-token
latency improves, with a much smaller complete-request gain. All twelve servers
exit cleanly and the source hashes remain fixed. The initial explicit-seed
pilot routed through serial and is excluded from batching evidence. These
remain loaded-machine diagnostics (measured on the M4 Pro), with variant 6 unchanged. Evidence:
`trellis-tile-integrated-forward-review.json`, `trellis-tile-http-review.json`
and `trellis-tile-seeded-serial-http-review.json` in the campaign directory.
Six old/new native process pairs also preserve all 64 emitted IDs and finish
reasons in warmup and measurement. First-token latency improves in every pair;
the complete native request improves slightly because single-row decode is
unchanged. All twelve workers complete with fixed source hashes. Evidence:
`trellis-tile-native.json` and `trellis-tile-native-review.json`.
The tile and evaluation-boundary experiments are detailed in turboquant.md.

The existing `bench-serve.ts all` suite also completes two AB/BA process pairs
for packed variants 6 and 12 with the serial arm, fixed workload seed and 192
decode tokens. Source snapshots match across all four runs. All 38 paired
recorded requests and the separate raw/chat parity probes agree; every server
exits cleanly, all SSD entries are durable, and no failed samples are dropped.
Single-request decode improves consistently at both tested contexts. Cold
prefill improves modestly; warm first-token latency varies between pairs and
sampled RSS shows no reduction. The requested context target produces 2,679
actual prompt tokens. The four-request aggregate leg is serial queue throughput,
not batching evidence. This loaded-machine diagnostic (M4 Pro 24 GB) does not promote a default or
replace quiet-machine acceptance. Evidence:
`single-request-suite-packed.json` and `single-request-suite-packed-review.json`,
with all four raw suite reports in the campaign directory.

Variant 13 adds vectorized packed-weight expansion after a larger fused-tile
screen failed to beat native matmul. The operation and packing contract are
documented in turboquant.md. Focused tests cover every codebook state, circular
windows, scale dtypes, strided inputs and fallback. The integrated 12/13
comparison preserves logits, live cache bytes and continuation at five append
lengths across seven blocks, including six measured AB/BA pairs. Actual kernel
calls confirm the eligible prefills improve while M=1/8 retain their existing
path. All three typechecks, hygiene and 1,795 model-free tests pass. Evidence:
`trellis-vector-integrated-full-model-review.json` and
`trellis-vector-integrated-{unit,typecheck,hygiene,model-free}.txt` in the
campaign report directory.

Two subsequent AB/BA pairs through the existing serving suite preserve all 38
paired requests, raw/chat parity and SSD restart durability. All four servers
exit cleanly with fixed source snapshots and no failures. Cold TTFT at the
smaller prefill improves modestly, while decode, long-context TTFT and RSS are
approximately flat. Cached TTFT varies substantially, so it is not an accepted
kernel gain. An external browser/build/test burst occurs near the first pair's
transition and is retained in the observations. This result does not establish
a broad serving improvement or promote variant 13. Quiet-machine acceptance
remains. Evidence: `vector-expand-suite-packed.json`,
`vector-expand-suite-packed-review.json` and
`vector-expand-suite-load-observations.json` in the campaign directory.

Six further serial HTTP AB/BA pairs isolate 6/16/128/512-token prompts with
64 generated tokens and prompt/SSD caching disabled. Each shape receives a
separate warmup; all first-shape timings are retained. Every paired response,
token count and finish reason matches across all 54 warmup/measured requests,
sources remain fixed, and all twelve servers shut down cleanly. TTFT and
complete-request time improve in every 16/128-token pair. The six-token
control and decode speed are flat; the 512-token and sampled RSS results are
less consistent. Six default-scheduler pairs repeat the improvement at
16/128 tokens, with exact responses, fixed sources and clean shutdowns.
Per-request telemetry proves scheduler admission. Existing swap usage and
background CPU activity keep both series (measured on the M4 Pro) diagnostic; the 512-token
effect remains less consistent. Evidence:
`trellis-vector-short-http-paired-{serial,default}.json` and the corresponding
`-review.json` files in the campaign directory. Quiet, second-machine and
pressure acceptance remain before any default promotion.

The updated affine controls now complete six alternating Bun/MLX-LM process
pairs for each flagship, compact and RTN4 artifact. They use the same six raw
prompt IDs, 64 output tokens, tokenizer/model EOS handling, production wiring
decisions and fresh-cache cleanup. Every pair emits identical IDs. Complete
native request time is close, with a small median Bun advantage; MLX-LM has
slightly lower first-token latency. These diagnostic controls establish no
new kernel win or HTTP conclusion. All 36 workers finish and the source
snapshot stays fixed. Evidence: `native-affine-paired.json` and
`native-affine-paired-review.json` in the campaign report directory.

The shared grammar bitmask candidate compares host expansion, direct Metal,
compiled Metal and XGrammar's compiled MLX bitmap-table approach. The compiled
Metal operation preserves the additive mask's bytes for bf16/f16/f32,
strided inputs, missing words, signed zero and nonfinite values. Its owned
host snapshot survives matcher mutation before lazy evaluation. Repeated
calls release their arrays after stream synchronization. Complete greedy,
sampled and logprob-enabled sampling retains identical selected tokens and
logprob bytes across changing masks at three vocabulary sizes, and improves
eight paired blocks against the actual host loop. An earlier probe used a
slower host callback expansion and is excluded from performance evidence.
Grammar integration is opt-in pending actual serving measurements. Evidence:
`token-mask-probe.json`, `token-bitmask-unit.txt` and
`token-bitmask-grammar-metal.txt`, plus `token-mask-sampling.json` and
`token-mask-sampling-review.json` in the report directory.

The first dense attention prototype adapts vLLM-Metal's register-resident
online softmax. It reduces temporary memory but loses the timing screen.
Instantiating pinned MLX Steel attention at head dimension 256 is faster on
some self-attention shapes, while the long-K/short-Q suffix case remains
slower. Tiling must follow both lengths and the device's workspace limit.
This changes numerics relative to the current unfused bf16 path and stays
Lab pending model and task-quality checks. Evidence:
`steel-attention-tune-manifest.json` and its per-tile reports. The initial
probe's small-head error metrics used physical output order; the corrected
contiguous readback agrees with the pinned oracle and CPU reference in
`attention-cpu-check.json` and `attention-oracle-check.json`.
The full packed-model Steel test is flat at 128/512 prompt tokens; one
512-token cell exceeds its predeclared last-logit KL screen, despite matching
the observed argmax. It has no model-level speed or quality acceptance.
Moving Q into threadgroup storage and transposing K storage did not rescue
the separate register-based prototype's timing. Evidence:
`attention-full-model-packed-128-512-review.json` and
`dense-attention-memory-tune-review.json`. Larger-context and exact-arithmetic
attention candidates remain separate experiments.

Graph export now records the existing evaluation boundaries for variants
6/8 at M=1/4/5. Small-M forward has one final evaluation boundary. M=5 has
192 projection evaluations, 64 layer evaluations and a final evaluation.
The exported graphs identify the exercised operations, including affine
projections, packed custom kernels, GDN, convolution, norms, RoPE, attention
and casts. Counts are exported operation occurrences, not GPU dispatches.
Raw graphs and the manifest are in `reports/qwen38-rd/graph-captures/`.

An attached Metal System Trace captures the warmed Bun target and its GPU
encoder intervals. The installed release MLX labels only command buffers
and encoders, so individual-kernel duration attribution remains open. The
capture covers part of prefill and decode; it is not a complete TTFT trace.
The first launch-based capture contains no target GPU work and is excluded.
Evidence: `variant8-attached.trace` and `attached-trace-summary.json` in the
same report directory. A pinned MLX source checkout supports inspection of
the actual dispatch and an isolated profiling build without changing the
oracle or installed runtime.

The isolated profiling build now records the kernel name, dispatch grid,
threadgroup geometry and pipeline limits for each submitted dispatch. A second
attached trace adds operation labels to encoder scopes. Those scopes contain
multiple operations, including zero-work views, so their GPU duration cannot
be attributed to the label's final operation. The selected Xcode counter
profile is unsupported on this M4 and exports no shader or counter samples.
Use the dispatch inventory to select isolated operation experiments while
individual GPU timing remains open. Evidence: `labelled-v8-analysis.json`,
`labelled-v8-kernels.txt` and `variant8-labelled.trace` in the report directory.

A direct device capability query exposes timestamp counters only at compute
stage boundaries on this M4 Pro. Dispatch-level sampling is unsupported.
The isolated pinned runtime now samples each operation in a separate encoder,
reserving two slots in a shared counter buffer and resolving them once per
completed command buffer. A per-operation allocation first exhausted Metal's
sample-buffer resources; a larger pool exceeded its documented-in-error size
limit. Both failed attempts are retained, and the final pool fits that limit.
The installed native library and Python oracle are unchanged.

Calibration compares the release library, the isolated build without
segmentation, segmentation alone, and counters. At B=1 and append lengths
1/4/8/128 from a 32-token prefix, every arm preserves logits, live cache bytes
and one continuation across one warmup and three measured forwards. The
instrumented full-forward overhead is small in this screen. All recorded
timestamps are valid, and sampled CPU/GPU clock pairs agree. These are
operation-encoder intervals: operations with multiple dispatches stay grouped,
intervals can overlap and include waits, and their sum is not GPU wall time
or critical-path attribution. The small-M trace directs further work toward
packed projections and affine matvecs; the eight-token trace exposes the
cost of the tiled prefill path. Evidence: `metal-counter-capabilities.json`,
`mlx-counter-source-manifest.json`, `mlx-counter-build.patch`,
`metal-counter-pooled-unit.stderr.txt` and
`metal-counter-calibration-review.json` in the report directory.

A separate schedule recorder now preserves MLX's normal encoder and command
buffer boundaries. It counts existing dispatches, barriers, fence waits and
temporary references, and reads command-buffer GPU start/end times in the
completion handler, following [Metal's timing contract](https://developer.apple.com/documentation/metal/mtlcommandbuffer/gpustarttime).
It rejects simultaneous operation segmentation. The first smoke test exposes
a unit mistake in the recorder: the pinned runtime's `buffer_sizes_` adds
`data_size()`, which counts dtype elements. Correct the recorder to report
that heuristic as elements and multiply by item size for temporary bytes.
The effective M4 Pro submission defaults are 50 dispatches and 50 shifted
element-count units. The setting's upstream name remains
`MLX_MAX_MB_PER_BUFFER`; it is not a literal byte ceiling. Temporary-reference
totals are also not peak resident memory.

The corrected recorder passes 45 complete generations across Llama 1B and
Qwen packed/RTN4, comparing the ordinary library, the isolated library without
telemetry and the recorder with native/raw/compiled sampler arms. Every
token, live state byte and usage record agrees. Warmed complete timings show
no clear systematic instrumentation shift in this screen; repeated overhead
calibration remains necessary for quantitative timing attribution. The
64-token packed sampling trace loses four dispatches per token with fusion,
but all three sampler arms still submit 3,905 buffers containing dispatches.
Many additional buffers contain no kernel dispatches; they may still carry
event waits or signals. Audit callers before attempting to remove them.
Command-buffer spans include internal waits, so their union is not kernel
active time or device utilization. Evidence is `mlx-schedule-source-manifest.json`,
`mlx-schedule-smoke-v2.log` and `top-p-schedule-screen{,-review}.json`.

A separate caller trace attributes 24 zero-dispatch submissions during steady
packed greedy decode to the pressure branch in MLX's `eval_impl`, reached
through `async_eval`. That branch finalizes open GPU streams before waiting
for outstanding work. All three traced generations preserve emitted IDs,
live cache bytes and usage against the calibrated recorder. Startup-only
stacks had instead reached final evaluation and synchronization, so they
could not establish the steady decode cause. The trace adds CPU logging and
is not timing evidence. These observations do not establish that an empty
dispatch list has no event work. Keep the validated recorder separate from
the caller-trace build. Evidence is `empty-submit-r6-steady-trace{,-review}.json`
and `mlx-empty-submit-steady-source-manifest.json`.

The next stock-library screen varies MLX's command-buffer submission limits,
bounded breadth-first graph traversal and optional Metal synchronization
implementation. Measure complete warmed generation, with matching token IDs,
requested log probabilities and live state, before changing native code or
retaining a setting. New-shape prefill cells are correctness screens until
their shapes are warmed in both arms. Positive cells require balanced native
and actual serial/continuous HTTP repeats, plus memory and disposal checks.
The frozen screen is `graph-schedule-screen-plan.json`.

That first screen passes all 120 generations and 27 complete arm comparisons
on Llama 1B and Qwen packed/RTN4. No packed-model decode setting has a
compelling first-pass gain. The later RTN4 timings overlap with unrelated
disburse TypeScript/Vite/Playwright jobs, including higher load and swap use.
Exclude RTN4 timing from tuning decisions and repeat it after those workers
exit; retain its exactness results. Llama's smaller-buffer observation needs
balanced repeats. Evidence is `graph-schedule-screen{,-review}.json` and
`graph-schedule-screen-contamination.json`. Retained tuning belongs at the
existing model-owned execution seams; these experiments do not establish
new global defaults.

The RTN4 rescreen completes 40 generations with nine exact arm comparisons,
including a return to the default settings at the end. The apparent 0.94%
greedy gain with traversal width 64 matches the ending default's 0.92% drift;
sampled generation is flat in both. Larger submission limits also fail to
improve both decode fixtures. No Qwen setting advances from this screen.
New-shape prefill timings remain excluded. Evidence is
`graph-schedule-rtn4-rescreen-v2{,-review}.json`.

Llama's six balanced native pairs preserve all 30 paired generations, including
requested log probabilities and live state. Reducing both submission limits
to 25 lowers complete warmed generation time by 2.44% for greedy and 2.30%
for sampled output; all six pairs improve in each cell. TTFT is effectively
flat. Peak MLX allocation falls in the measured cells, which is not a claim
about physical RAM savings. Six actual HTTP pairs per lane then preserve all
84 paired responses across 168 requests. Complete time improves by
1.86–3.02% in serial and 2.22–3.00% in continuous serving across the three
fixtures, with every pair faster. These results (measured on the M4 Pro) remain diagnostic pending a quiet-machine repeat.
The controls are `graph-schedule-llama-repeat{,-review}.json` and
`graph-schedule-llama-http-repeat{,-review}.json`. MLX caches these settings
at device initialization; assigning environment variables from a later
model forward would not apply the measured policy. Broader contexts,
lifecycle coverage and scoped integration remain.

A separate native prototype elides `finalize` only when the command buffer
has not been touched since the preceding commit. Access to the buffer,
encoder creation, output registration and temporary registration all make it
ineligible. This preserves event-only and completion-handler work, and leaves
explicit synchronization unchanged. The isolated build and its disabled arm
each pass 84 stream/lifetime cases against the installed library, spanning
three dtypes, two sizes, two memory limits, CPU/GPU and GPU/GPU dependencies,
view-only events and disposal before asynchronous completion. All cases
return active memory to zero. The subsequent 45 complete generations also
preserve IDs, requested log probabilities, live state and usage across the
three artifacts and both library controls. Packed generation is effectively
flat. Six subsequent RTN4 AB/BA pairs preserve all 30 paired generations but
find no reliable gain: complete greedy time changes by -0.069%, sampled by
+0.108% and warmed prefill by +0.011%. Peak MLX allocation is flat. Close the
prototype without production integration. Evidence
is `mlx-untouched-finalize-source-manifest.json` and
`untouched-finalize-stream-default{,-review}.json`, plus
`untouched-finalize-native{,-review}.json` and
`untouched-finalize-rtn4-repeat{,-review}.json`.

The separate exact traces confirm that the prototype removes the intended
submissions. For 64 packed sampled tokens, zero-dispatch buffers fall from
3,311 to 194, while all 116,164 dispatches and 3,905 buffers containing
dispatches remain. RTN4's corresponding zero-dispatch count falls from 4,083
to two; its 115,947 dispatches remain. The sampled skip counters record
3,113/4,072 omitted calls. Counts need not subtract exactly between runs
because pressure callbacks and completion timing vary. This is mechanism
evidence, not an end-to-end speed claim. Evidence is
`untouched-finalize-trace{,-review}.json`.

The optional upstream `MLX_METAL_FAST_SYNCH=1` mode stalls in the installed
library's large bf16 three-stream case under the probe's small submission
limits. A stack sample finds the host in `scheduler::wait_for_one` and a
worker in `Fence::wait`. Stop only that probe after more than 100 seconds
without progress, retain its partial results, and rerun all default-mode
cases successfully. Do not attribute this stock-library failure to the new
prototype or treat the unrun experimental-mode arms as passes. Evidence is
`untouched-finalize-stream.json`, `untouched-finalize-stream-fast1-interruption.json`
and `untouched-finalize-stream-fast1-default.sample.txt`.
The initial interruption annotation mislabeled that case as f32; the partial
report's dtype 12 identifies bf16. The corrected attribution is recorded in
`untouched-finalize-stream-fast1-failure-review.json`.

The existing GDN stage profiler has also been run at M=1/4/128/512 against
unprofiled forwards from the same prefix. Observed logits agree. Its added
stage/layer evaluations substantially inflate small-M time, so those stage
durations cannot substitute for GPU kernel attribution. Evidence:
`reports/qwen38-rd/gdn-stage-probe.json`. A fused convolution/SiLU/copied-tail
prototype matches the tested bf16/f32 outputs and live tail at B=1/2. It
requires MLX's typed sigmoid expression; a float32 rewrite changes bf16
results. The opt-in operation now passes full packed-model logits, live
state, continuation and speculative rollback checks. Its initial memory
benefit exposed an aliasing baseline: `mlx_copy` retains the source buffer.
The default path now uses a shared compact materialization operation backed
by stock MLX DynamicSlice, with gradient and compiled-execution gates.
Replacing the alias preserves all tested packed-model logits, live state,
continuation and rollback bytes. Explicit disposal still owns handle cleanup;
the copy change allows the large backing allocation to be released.
Against an independently materialized baseline, convolution fusion has
approximately flat full-model timing and similar peak memory. It remains an
unpromoted R8 experiment. Evidence: `qwen-conv-materialized-packed.json`,
`materialize-final-packed-comparison.json`, and `conv-probe-typed-sigmoid.json`.
The final stock-copy rerun is a correctness gate; concurrent CPU trace exports
exclude its diagnostic timings from performance comparisons.

GDN specialization now covers threadgroup layouts, fixed sequence lengths,
loop unrolling, compiled wrappers and typed sigmoid fusion. Correcting the
initial float32 sigmoid rewrite restores exact bf16 recurrence and state.
The subsequent shape sweep passes all 114 cells. A compiled fixed-length
candidate preserves full-model logits, live state and continuation, but its
isolated gains mostly disappear in full forwards. A separate fused recurrence,
output RMS normalization and gate kernel passes 60 isolated shape/dtype cells
and the small-M full-model checks. Its full-forward improvement is too small
to justify integration at this point. Neither candidate changes production
dispatch. Evidence: `gdn-specialization-typed.json`,
`gdn-static-full-model-review.json`, `gdn-fused-norm-probe.json` and
`gdn-fused-norm-full-model-review.json`.

The affine matvec layout screen preserves pinned MLX's reduction arithmetic
while varying output rows per SIMD group and groups per threadgroup. Actual
packed-artifact head and GDN projection weights pass exact checks with both
direct and compiled wrappers. The best isolated head cells improve only
slightly, and the small-M projection results are mixed. There is no accepted
whole-model gain. Combined projection dispatch remains a separate candidate.
Evidence: `affine-qmv-screen.json` and `affine-qmv-compiled.json`.

A second affine prototype shares packed weights and quantization metadata
across four or eight input rows, preserving MLX's dot-product and SIMD
reduction order. The corrected real-matrix screen passes all 50 cases; larger
GDN projections improve in isolation, while vocabulary-head gains are smaller.
An initial bf16 failure was large, not rounding noise: some shared-row layouts
read incorrect scale/bias values. Explicit bf16 bit expansion avoids the
observed failure without resident float32 metadata copies. Direct and compiled
bf16/f32 debug cells then agree exactly. The underlying compiler cause is not
established. Six full-model pairs preserve logits, live cache bytes and
continuation on both packed and plain RTN4 artifacts. RTN4 improves consistently
at M=4/8 with unchanged peak allocation and flat unused-shape controls. Packed
improves little; its unused M=128 control also shifts, so the smaller packed
timing difference needs an independent check. Six RTN4 HTTP process pairs
then preserve all 108 paired warmup/measured responses, token counts and
finish reasons. Every measured eight-request wave reaches eight active rows
and improves throughput; the single-request control is approximately flat.
All twelve servers exit cleanly with fixed source hashes. Evidence:
`affine-shared-m-http-rtn4-review.json`, `affine-shared-m-probe.json`,
`affine-shared-m-probe-initial.json` and
`affine-shared-m-debug-scale-bits.json`, plus
`affine-shared-m-full-model-{packed,rtn4}-review.json`.

The retained shared operation is `src/mlx/affine-shared-m.ts`, opt-in via
`MLX_BUN_AFFINE_SHARED_M=1` [both later removed with the MLX 0.32.2 runtime
consolidation, §7.12 of the design doc; frozen source controls retain them]. Eligibility follows dtype, quantization, shape
and stream rather than a model name. It retains native MLX for unsupported
cells and during shapeless compile traces: the native CustomKernel primitive
cannot infer output shapes there. The trace context is restored on return or
exception. Shape-specific compiled calls remain eligible. Focused tests cover
strided activations and metadata, leading dimensions, shape changes and
fallbacks. A cleaned-up kernel passes another six RTN4 full-model pairs and
retains the gain. Six final production-flag HTTP pairs preserve all 156 paired
warmup/measured responses with fixed source hashes and clean server exits.
Both four- and eight-request throughput improve in every pair; the
single-request control is flat. Dispatch counters confirm M4 and M8 use the
shared operation. Broader artifacts and quiet-machine gates remain. Evidence:
`affine-shared-m-production-full-model-rtn4-review.json`,
`affine-shared-m-shapeless.json`, `affine-shared-m-integrated-unit.txt` and
`affine-shared-m-integrated-http-rtn4-review.json`.

The next row-width screen passes all 112 real RTN4 matrix cases at
M=2/3/5/6/7. Six full-model pairs per width also preserve logits, live state
and continuation. M2 loses and retains native dispatch. M3 improves slightly;
M5/6/7 improve consistently without a material peak-memory increase. The large
head needs separate geometry: its M6/7 shared-row cells lose even when smaller
projections win. Wider integration therefore keeps those head cells native.
Evidence: `affine-shared-m-width-rtn4-review.json` and
`affine-shared-m-width-full-model-rtn4-review.json`.

A broader-format prototype initially fails nine of 216 arithmetic cells,
all bf16 M8 layouts with 3- or 5-bit weights. The errors are large and survive
float32 output storage. Float32 activations remove the large error but also
change the reference's typed arithmetic. Explicit bf16 input expansion plus
rounding after each typed addition preserves that arithmetic and passes all
216 dtype/bit/group-size cells. Evidence:
`affine-shared-m-all-bits-correctness-review.json`,
`affine-shared-m-all-bits-debug.json` and
`affine-shared-m-all-bits-explicit-input-correctness-review.json`.

The compact artifact supplies actual 3-bit head/MLP and 8-bit attention/GDN
matrices. All 80 real-matrix cells agree exactly, including compiled calls.
Reusing each packed load for two input rows at 3-bit and four at 8-bit wins
the retained M4/8 cells. Both compute four output rows per SIMD group, with
two SIMD groups per threadgroup. Six full-model pairs
with the prototype and another six with the cleaned production operation
preserve logits, live cache bytes and continuation; both row counts improve,
unused-shape controls stay approximately flat and peak allocation is unchanged.
The 3/8-bit implementation now lives in `src/mlx/affine-shared-quant.ts`, under
the same opt-in flag and native fallback rules [also removed in the §7.12
consolidation]. Other bit widths and group
sizes remain research-only. Evidence:
`affine-shared-m-all-bits-explicit-compact-review.json`,
`affine-shared-m-all-bits-full-model-compact-review.json` and
`affine-shared-m-broader-full-model-compact-review.json`.

The final 4-bit operation includes M3/5/6/7, retaining native M2 and the large
head at M5/6/7. Six complete-model pairs per width preserve logits, state and
continuation. Six production-flag HTTP pairs at B1/3/5/6/7 preserve all 264
paired warmup/measured responses. Each measured wave reaches the requested
active width; candidate dispatch is observed and all twelve servers exit
cleanly. Concurrent throughput improves in every pair. Single-request decode
is approximately flat. All pairs are retained, including noisier final runs:
the machine has residual swap, XProtect is active at the initial preflight,
and unrelated build/browser activity is observed after the run. This remains
a diagnostic result. Wider model coverage remains open.
Evidence: `affine-shared-m-broader-full-model-rtn4-review.json` and
`shared-affine-frontier-http-rtn4-review.json`. Current focused tests, all
three typechecks, hygiene and the complete model-free tier pass; the latter
has 1,785 passes, ten skips and no failures. Evidence:
`affine-shared-m-broader-{unit,typecheck,hygiene,model-free}.txt`.

Six final compact production-flag HTTP pairs preserve all 156 paired warmup
and measured responses, usage counts and stop reasons. Both B4 and B8 improve
in every measured pair; the median B1 control is flat, with individual noisy
outliers retained. Actual active widths and both 3/8-bit dispatches are
observed, all twelve servers exit cleanly and source hashes remain fixed.
Residual swap keeps this diagnostic. Evidence:
`shared-affine-frontier-http-compact-review.json`.

A subsequent host-overhead prototype caches shape-specific compiled calls
around these shared-affine kernels. Every weight/scale/bias/activation remains
a dynamic input, so one compiled function can serve distinct model layers.
Six compact full-model pairs retain exact logits, state and continuation;
24 compiled configurations serve all eligible projections without new traces
in measured rows. The eligible M4/8 cells improve modestly. Six subsequent
HTTP process pairs preserve all 156 paired warm/measured responses with clean
server exits and fixed source hashes. Serving gains shrink to approximately
flat at B1/4 and a small B8 difference. This does not justify integrating the
extra compiled-function cache at present. Evidence:
`affine-compiled-call-cache-full-model-compact-review.json` and
`affine-compiled-call-cache-http-compact-review.json`.

The grammar-mask operation now completes six compact HTTP process pairs at
B1/4 with shared-affine enabled in both arms and grammar jumping disabled.
All 60 paired warm/measured responses match and satisfy the frozen JSON
schema; both arms apply the mask the same number of times. Every concurrent
wave reaches four active rows, source hashes remain fixed and all servers
exit cleanly. The timing is inconclusive for promotion: residual swap and
overlapping unrelated build/browser work are recorded, the B1 median is
approximately flat and the B4 median regresses. Preserve all samples and
revisit on a controlled session. Host masking remains default. Evidence:
`grammar-mask-http-compact-review.json`.

A fused affine gate/up/SwiGLU prototype shares activation loads and replaces
the two projections plus activation dispatch. Its first version preserves
both projection outputs but fails the activation check: a float32 sigmoid
expression differs from MLX's dtype-specific expression. The corrected
kernel passes all 48 real RTN4 small-M cells, including complete MLP output.
Only M=1 benefits in that isolated screen. Restricting the full-model prototype
to M=1 preserves logits, live state and continuation across six paired blocks,
but its full-forward gain is too small to justify integration. Longer-M
forwards retain the original path. Evidence: `affine-gateup-debug.json`,
`affine-gateup-debug-typed.json`, `affine-gateup-typed.json` and
`affine-gateup-full-model-review.json`. The existing packed activation's
separate arithmetic contract needs its own audit before reusing that code
in an affine operation.

A residual-add/RMSNorm kernel preserves the native reduction topology and
the rounded residual before normalization. All 90 synthetic bf16/f16/f32
cases preserve both outputs. Six packed-model pairs at M1/4/8/128 then
preserve logits, live cache bytes and continuation, with 64 fused calls per
forward. M1 is slightly slower, M4/8 are approximately flat and M128 varies.
The complete path does not establish a compelling benefit, so this version
is not integrated. Operation samples include wrapper/evaluation costs and are
not GPU-only timestamps. Evidence: `residual-rms-screen-scalar-review.json`
and `residual-rms-full-model-packed-review.json`. Earlier driver/binding
failures occurred before timing and remain separate. Closed helpers are
removed after recording the finding.

The first real HTTP screen uses the compact artifact through bounded CLI
servers. It retains request hashes, actual usage, arrival times, cache hits,
restart durability, concurrent request completion and failures. Its cold
context leg required a Bun restart; the retried nonce changed the prompt, so
that context comparison is unmatched. The chat probe also diverged despite
equal prompt counts. Frozen chat IDs produce identical direct Bun/Python
tokens. A cold HTTP control reproduces the Python difference only in its
seedless BatchGenerator path; `seed=0` selects its serial method and matches
the direct text. Compare those execution methods separately. The Bun HTTP
sample also omits a final space, so it has no byte-identical wire-output claim.
The benchmark records failed-attempt
stderr and process status, including failures recovered by retry. This screen
is diagnostic and establishes no serving win. Evidence and exclusions:
`serving-compact-screen-0.review.json` and
`serving-primes-native-comparison.json` in the report directory.

Repeated native-throw traces identify the continuous serving crash as Metal
command-buffer out-of-memory. Bun 1.4.2 avoids it in one screen but misses
one pending SSD snapshot at its first restart boundary; neither issue is
closed. Continuous preparation and decode now share the serial memory
guard, entered after cache acquisition under the execution lease. Ownership,
refusal and guard restoration tests pass. The same context failure still
reproduces: the affine graph's transient allocations occur at evaluation,
after the per-layer construction checks. Investigate allocator residency
and snapshot retention before declaring this fixed. Evidence:
`serving-compact-bun140-throw.review.json`,
`serving-compact-bun142-throw.review.json` and
`serving-compact-shared-guard.review.json`. Source snapshots now include
untracked kernels as well as tracked changes.

The frozen compact request isolates a cache-consumption cause: after one
warm repeat transfers the exact recurrent boundary out of RAM, a third
identical prompt loses that prefix and prefills again. Stopping after two
requests also reproduces a missing SSD snapshot followed by a false-success
flush; restart cannot reuse the longer untrimmable descendant. Persisting the
boundary before transfer preserves the third request's prefix. Durability
records now remain dirty until actually covered, and already-durable records
avoid another clone. Ownership/failure and coordinator regression gates pass.
The three-request HTTP replay preserves output and cached tokens through
repeat and restart, with no missing flush. The two-request replay also writes
the consumed boundary before restart. This requires a synchronous SSD write
on the first transfer when that boundary is not already durable. The complete
compact serving diagnostic now finishes context repeats, SSD flush/restart
and four concurrent streams without a recorded failure. One diagnostic pass
does not close long-agent or repeated reliability acceptance. Evidence:
`ssd-boundary-before.json`, `ssd-boundary-two-before.json`,
`ssd-boundary-after.json`, `ssd-boundary-two-after.json`,
`ssd-boundary-tests.txt` and `serving-compact-boundary-fixed.review.json`
in the campaign report directory.

The merged packed path now passes the seven saved Pi tool-result boundaries
in separate serial and continuous server processes. Both arms use variant 12
and the same frozen requests. Each completes the longest prompt, emits the
requested 512 tokens, demotes old cache entries under pressure, and finishes
with a durable SSD flush and no pending, missing or failed snapshots. Responses
match across the two methods and the source snapshot stays fixed. The system
prompt was reconstructed once with the installed Pi package and frozen;
historical system-prompt byte identity is not established. This is a bounded
memory/integration check, not a long-running agent success claim. No returned
tools execute. Evidence: `agent-boundary-fixture.json`,
`agent-boundary-current.json` and `agent-boundary-current-review.json`.

The M4 DeltaNet fixture discrepancy is now traced to the cached reference,
not a Bun/oracle disagreement. Both implementations match gate values, output
bytes and complete recurrent state on the frozen inputs. The explicit
replay changes one older expected output and adds oracle provenance/state
hashes. The platform evidence and regeneration procedure live in
[environment.md](../reference/environment.md).

R22 now tests immutable file-backed weights through page-aligned Metal roots
and ordinary MLX tensor views. The existing external-buffer entry point is
sufficient for element-aligned tensors; each root includes the leading page
padding and the tensor view carries the offset. This resembles
[llama.cpp's mapped Metal buffer views](https://github.com/ggml-org/llama.cpp/blob/427291b5b34cd914a31b3fd3b61a68f6184f4b9f/ggml/src/ggml-metal/ggml-metal-device.m#L1999),
which align the root pointer and split oversized mappings into overlapping
views. The prototype uses no new artifact and no new production loader.
Small metadata and unsupported element alignment retain native loading.
All 32 operation cases match payload bytes and GPU add/matmul results;
pointer equality proves that the candidate aliases the file, and file hashes
stay unchanged. The Llama 1B artifact is ineligible because its large payloads
start at odd byte offsets, so that initial native/native control establishes
no candidate performance result.

The first packed 27B native pair maps 758 tensors, 11,895,111,680 payload
bytes, through 11,907,530,752 bytes of page windows. Prefix state, ten
full-forward logit/live-state/continuation cases and both generation token
sequences match. The subsequent six-pair repeat preserves all 60 full-forward
logit/state/continuation cases, every prefix state and all 12 generation
comparisons. Sources stay fixed and all 12 child processes exit cleanly.
The measured 64-token generation is 0.25% slower by median paired wall-time
ratio, with no faster pair; TTFT is approximately flat. M1 is about 0.6%
faster, while M4/8/128/512 give no consistent useful improvement. Evidence:
`mmap-weights-native-packed-paired{,-review}.json`. Readiness varies strongly
with order and file-cache state, so it has no cold-start improvement claim. Process RSS and macOS
physical-footprint accounting fall sharply because most private copied weights
become file-backed mappings. That does not shrink model bytes or establish a
corresponding reduction in total physical RAM: clean file pages and GPU
residency require separate accounting. Preserve MLX active/peak bytes, RSS,
`vmmap` output and system pressure together. Evidence:
`reports/qwen38-rd/mmap-page-window{,-pointer}-screen.json` and
`mmap-weights-native-{llama1,packed}-screen.json`.

The serial HTTP follow-up completes six fresh-server pairs with all 42
warm/measured response texts, usage counts and finish reasons exact. Sources
remain fixed and all servers exit cleanly. Warm complete-response time is
0.04% to 0.14% slower by median paired ratio; decode is 0.14% to 0.21% slower.
Median per-server peak RSS changes from 12,182,749,184 to 482,508,800 bytes.
The recorded physical-footprint summaries show the same private/file-backed
accounting change, not a smaller tensor working set. Evidence:
`mmap-weights-http-serial{,-review}.json`. Default scheduling, system-memory
pressure and cold file-cache behavior remain separate gates.

The initial prototype retains immutable roots and mapping owners for the
process, matching the existing external-array lifetime requirement. A retained
loader must also prove unload, outstanding GPU-reference ownership, repeated
model replacement, pressure behavior and HTTP performance. No default or
production lifetime change follows from this screen. A subsequent ownership
prototype stores array/root handles with each `Weights` instance and releases
them on disposal. Existing shard mappings remain mapped for the process. Three
full-artifact cycles each load 2,019 tensors and release all 13,056,265,696
active bytes. An outstanding GPU consumer survives weight disposal, produces
the exact expected output and releases the remaining 2,048 bytes on disposal;
active memory is zero before GC. Evidence:
`mmap-weights-ownership-packed{,-mapping}.json`. Three additional cycles
retain a single-input lazy negation, dispose the weights before submitting it,
and then evaluate it. Outputs remain exact; the pending view retains
39,747,584 bytes until its disposal, after which active memory returns to zero
before GC. Evidence: `mmap-weights-single-consumer-lazy{,-mapping}.json`.
The whole-tensor follow-up fails output identity on the first cycle after
owner disposal, although active memory returns to zero and the source tensor
still matches the untouched original artifact. The earlier small view did
not qualify for unary buffer donation: MLX also bounds excess backing-buffer
bytes. Thus those passing cases did not establish donation safety. Keep this
read-only loader out of production; reduce the failure on scratch data and
test writable private mappings with native lifetime ownership. Evidence:
`mmap-weights-whole-consumer-lazy.json`, its log and
`mmap-whole-consumer-source-integrity.json`. Full serving, default-scheduler
and pressure gates remain for any corrected loader.

Scratch files isolate the failure across float32/bfloat16 and aligned/offset
views. With a retained root, all read-only cases are exact and output uses a
separate buffer. After root release, all four donated read-only cases return
the original input bytes instead of the negation. Private writable mappings
preserve every output, including donation, and leave each file unchanged.
Evidence: `mmap-donation-{ro,cow}-screen.json`. The corrected prototype gives
each private page window a native payload destructor that unmaps it on the
last MLX buffer release. It uses no JavaScript destructor or new production
API. All eight scratch ownership cases preserve output and file bytes, retain
the mapping through the live consumer, and release every mapping afterward.
Three full-artifact cycles then preserve the whole-tensor lazy negation after
weight disposal. Only its 1,654,784-byte mapping survives until the pending
consumer is disposed; native mapping counts and MLX active bytes return to
zero before GC. Evidence: `mmap-managed-donation-screen.json` and
`mmap-weights-managed-whole-consumer-lazy{,-mapping}.json`. A further 64-cycle
scratch gate submits chained operations asynchronously and disposes the
input handles. Half the cycles check every output value; the others dispose
the final output before synchronization. All release every native mapping and
return MLX active memory to zero. Evidence: `mmap-managed-submitted.json`.
Six subsequent private-mapping native blocks on the M4 Pro 24 GB preserve 60 full-forward
logit/state/continuation cases and 12 8/64-token generation comparisons, with
fixed sources, clean exits and zero remaining native mapping windows. The
64-token warm generation median paired wall-time change is +0.02%; TTFT is
+0.13%. Warm full forwards at M1/4/8/128/512 have no useful consistent speed
gain. The opening-plus-first-hidden-forward phase is about 7.38 seconds slower
by median paired difference, but that observation materializes different
amounts of the model. After the hidden-only forward, native head tensors are
still lazy while mapped roots already account for their full extent. The
727,580,672-byte active-allocation difference is exactly the 715,161,600-byte
head plus 12,419,072 bytes of page padding, in all six pairs. Large changes in
RSS and `vmmap` physical-footprint accounting still do not establish how much
system RAM is saved. Child wall time includes `vmmap` inspection and is not a
performance metric. Evidence is
`mmap-weights-managed-native-repeat{,-review}.json` and
`mmap-initial-residency-attribution.json`.

A separate lazy-view control removes per-tensor evaluation and pointer checks
from loading. All 64 unsubmitted consumers and 64 submitted consumers remain
valid after releasing their weight owners, then release every mapping and
return active allocation to zero without forced GC. Its model screen preserves
ten full-forward cases and both generations, but warm 64-token generation is
+0.22% slower and the first hidden-forward phase does not improve. This rules
out retaining the lazy change on that screen; it does not isolate the cause
of the first-use cost. Evidence is
`mmap-lazy-view-ownership.json` and
`mmap-weights-lazy-managed-native-screen{,-review}.json`. Neither prototype is
integrated.

A subsequent four-arm screen measures opening the model through the first
generated token, completing all 64 tokens, then a warm 64-token generation.
Native loading, lazy private mappings, mapped pages with an OS read-ahead
hint, and mapped pages read once per page preserve all token IDs, live state
and usage, then release every mapping. On the M4 Pro 24 GB, native first-token
time from opening is 14.09 seconds; lazy mapping is 13.62 seconds, read-ahead
19.97 seconds and explicit reads 30.50 seconds. These timings include the
preparation itself. Warm generation is approximately flat. The two CPU
preparation methods lose this screen. Lazy mapping's small first-generation
gain needs balanced repeats: this is one fixed-order block with unpurged
filesystem cache. Neither a cold-storage result nor a physical-memory saving
is established. Evidence is `mmap-prefault-native-screen.json`.

The balanced follow-up rejects that apparent cold-generation gain. All six
fresh-process pairs preserve both 64-token generations, live state and usage,
with fixed sources, clean exits and all 758 mappings released. First-token
time from opening is worse in five pairs: the median paired change is +18.42%
or +2.24 seconds. Completing the first generation is +12.93% or +2.29 seconds;
warm generation is approximately flat at +0.24%. One large native outlier
remains in the report. The filesystem cache is unpurged and the machine is
not quiet, so these are diagnostic results. RSS accounting falls sharply for
file-backed pages but physical-memory savings are still unproven. Close this
loader as a performance candidate on the measured workload; no integration
or HTTP speed claim follows. Closed loader, page-preparation and ownership
helpers are removed; raw plans and evidence remain in
`mmap-cold-native-repeat{,-review}.json`.

The first full-model pair with native private mappings preserves prefix state,
all ten checked logit/live-state/continuation cases and both 8/64-token
generation sequences. Sources remain fixed; both children exit cleanly and
the mapped child releases all 758 native windows before exit. Its 64-token
wall time is approximately flat. This single pair is a correctness screen,
not a performance acceptance. Evidence:
`mmap-weights-managed-native-screen{,-review}.json`. Repeated native/HTTP,
and pressure gates still apply. A subsequent API ownership gate preserves
pending-consumer output and rematerialized source bytes after `release`,
`releaseShard` and `dispose`. It rejects a late view change and releases the
mapping after an intentional tensor-fixup failure. All native mapping counts
and MLX active bytes return to zero. Evidence:
`mmap-managed-shard-release{,-mapping}.json`.

Plan at this point (the MTP and strict-fill measurements were later
completed; see speculative-decoding.md §4.7/§7.4 and the design doc §7.13):
finish MTP and strict-fill request measurements after the kernel
changes, broaden their correctness and state audits, and obtain individual
kernel attribution. Continue shared GDN/convolution/affine/prefill work and
the exact-artifact controls across quants. Quiet application A/Bs, pressure
replay and quiet-machine gates remain. Recheck process ownership and preflight
before each GPU run; diagnostic measurements cannot promote a default.

The native-owned managed mapping is visible to MLX allocation accounting.
Across all ten full-model rows in its paired screen, mapped peak allocation
exceeds the incumbent by exactly 12,419,072 bytes, the difference between
page-aligned root and payload bytes. The low process RSS is not evidence of
an unaccounted model in the async-scheduling threshold. Combining these
experiments still needs a separate pressure gate. Evidence:
`mmap-managed-active-accounting-review.json`.

A dedicated KV append dispatch probe covers 18 bf16 cases with four KV heads
and dimension 256, at depths 65/256/2049/2048/8193/8192. Every active prefix,
new row and retained snapshot remains exact; explicit cleanup returns MLX
active allocation to zero. With spare capacity and no retained view, each
SliceUpdate dispatches only the new-row copy. Holding an evaluated temporal
view adds a full-buffer copy; releasing it restores donation. At a 256-step
growth boundary, the pair allocates padding, concatenates old/new storage
and appends, totaling eight dispatches regardless of retained views. This
rejects the assumption that ordinary cache append always copies the full
buffer. The next gate is a real-generation census of retained views and
growth; instrumented one-shot timings do not establish a speed win. Evidence:
`kv-append-donation-probe{,-review}.json` and its native dispatch log.

A real native-generation census on the interleaved v13 artifact uses a
2,049-token synthetic prompt and 32 generated tokens. Without a prompt
snapshot, all 1,024 observed one-row K/V appends dispatch only the new-row
copy. Retaining a real `cloneKvCaches` snapshot produces 32 full-buffer copies,
one per K/V buffer, then 992 new-row-only appends. Both runs emit identical
IDs with fixed sources. This rejects a repeated whole-cache copy in the
tested native path; serving, deeper contexts and other cache types remain
separate coverage. The counter build is for attribution, not timing claims.
Explicit cleanup leaves 16,390 active bytes, so this is not a zero-allocation
claim. Evidence: `kv-append-model-trace-2049{,-review}.json` and its dispatch
log under campaign reports.

The actual HTTP census confirms the same append behavior at a verified
2,049-token text prompt. Serial and continuous servers each complete two
16-token warmups and a 32-token measured response. All three paired outputs,
counts and finish reasons match, the continuous lane is verified, and both
servers exit cleanly with fixed source. Each measured request has 1,024
one-row K/V update encoders, all writing only the new row; neither performs
a full-buffer copy for those appends. No matching update records fall outside
the request phase markers. This rejects a repeated whole-cache-copy hypothesis
for both tested HTTP lanes with prefix caching disabled. Deeper context,
retained snapshots, growth boundaries and compressed caches remain separate
regimes. The original token-array HTTP fixture was correctly rejected by the
endpoint; the corrected text fixture is encoded and hashed by the Bun
tokenizer before tracing. Evidence is
`kv-append-http-text-census{,-review}.json` and its per-server dispatch logs.

The native census also passes at an 8,193-token prompt with 32 generated
tokens. Ordinary ownership again gives 1,024 new-row-only K/V writes. A held
snapshot gives 32 whole-buffer copies followed by 992 new-row-only writes.
The two runs emit identical IDs, cover the same 8,224 cached tokens, keep
sources fixed and return to 16,390 active bytes after explicit cleanup.
Each phase also contains 480 larger prefill updates. These counts classify
`SliceUpdate` encoders only; allocation/growth and copy traffic in other
operations remain separate measurements. Evidence is
`kv-append-native-8193{,-review}.json` and its dispatch log. There is no timing
claim or new append kernel from this attribution result.
