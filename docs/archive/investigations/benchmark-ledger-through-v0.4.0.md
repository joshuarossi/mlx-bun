# Benchmark ledger through v0.4.0

Frozen campaign record moved from `docs/reference/benchmarks.md`. Entries describe
the source and machine conditions at measurement time; references to unreleased
work and internal procedures are historical. Current results and reproduction
instructions live in [benchmarks.md](../../reference/benchmarks.md).

The durable, hand-maintained benchmark record. Raw per-run files
(`benchmarks-h2h-<date>-<machine>.md/.html`) are gitignored ephemera; the
structured backing record is the user-local eval DB
(`~/.cache/mlx-bun/evals.sqlite`). Promote a run into this file
deliberately when it becomes the new reference.

New raw request records also retain the server's final `usage` object,
including execution lane and speculative counters when supplied. The reader
captures these already-parsed fields after timing finishes; older reports may
lack them. This lets settings comparisons verify which method actually ran.

The optional `mlx-bun-isolated` arm runs the same CLI/model/request cells through
`--isolate`; select it alongside `mlx-bun` to compare transport cost. Its RSS
column sums the parent and descendant processes. This is aggregate process RSS,
not deduplicated physical memory; shared runtime pages may appear in both.

The current closeout candidate follows Josh's advisory-memory policy: requests
are attempted without fit-based refusal or completion clamping by default.
Earlier reservation variants remain diagnostics, including successful trials;
they are not the product policy. Explicit budgets/context caps still apply.
No speed default has been promoted by these memory experiments.

The advisory candidate's M4 Pro replay (`m4-advisory-short.md.json`) retains
all 23 comparable successful request outputs and usage/cache counts from
the earlier R0 run. Five-sample decode medians are 14.812 tok/s serial and
14.677 tok/s continuous; this is one diagnostic run, not a paired speed win.
Both lanes complete decode and cold/warm 1K prefill. The aggregate retained
history hits actual Metal insufficient-memory errors: serial recovers on the
harness retry; continuous fails both attempts. These are runtime failures,
not predictive refusals. Local regression tests deliberately give the live
model an impossible accounting estimate and verify both lanes still execute.
Review: `reports/qwen38-closeout/m4-advisory-short-review.json`.

## Rotating target speculation through shared execution

M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2. Gemma 4 12B OptiQ, prompt lookup
at its default depth ten, bf16 KV, 2 GiB RAM cache plus temporary SSD,
192 decode tokens, four concurrent requests and default capacity eight.
Production `bench-serve.ts all`, context sweep skipped, seed `rotating-spec-0`,
diagnostic mode under Josh's machine policy. Final comparison order is
control-1, candidate-2, control-2, candidate-3; an earlier candidate-1 predates
the final singleton boundary correction and is excluded from these means.

| Metric (mean of two arms) | Previous serial placement | Shared rotating placement | Change |
|---|---:|---:|---:|
| Single-request decode | 16.928 tok/s | 16.894 tok/s | −0.2% |
| Four-request throughput | 17.269 tok/s | 22.130 tok/s | +28.1% |
| Four-request wall time | 29,648.128 ms | 23,139.278 ms | −22.0% |
| Repeated-prompt TTFT | 2,505.201 ms | 199.600 ms | −92.0% |
| Cold prefill TTFT | 2,515.753 ms | 2,524.302 ms | +0.3% |
| Launch to first output | 1,571.428 ms | 1,631.817 ms | +3.8% |

All 60 recorded requests complete with matching bodies and token budgets.
Single-request text and raw completion/chat probes match. All four concurrent
responses differ across implementations, while each implementation's repeats
are exact. This measures fixed output budgets with different concurrent
trajectories. The shared cache reuses 671 tokens versus zero in the control.
Startup spans roughly 1.1–2.2 seconds in both arms; its mean does not establish
strict dominance. This closes the bf16 rotating transaction implementation,
not all speculative compositions or strict serial-removal acceptance.

Control source: `20c21f2f62383b9878966f8ea1bf74c98d58942d33351430042ff7801cb929c4`.
Final candidate: `c8213540beb87f438fbafad7115b49f494e92526c28acca930f134883d5cfdcf`.
The change is integrated in the unreleased tree. Evidence:
`reports/qwen38-closeout/composition-baseline/rotating-speculation/`, including
`benchmark-comparison.json` and all raw M4 reports.

## Full-attention speculation through shared execution

M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2. Llama 3.2 3B target and 1B
standalone drafter (4-bit weights), draft depth two, bf16 KV, 2 GiB RAM
plus temporary SSD. Production `bench-serve.ts all`, 192 decode tokens,
four concurrent requests, default capacity eight, seed `full-kv-spec-0`,
context sweep skipped, diagnostic mode under Josh's machine policy.
The same draft engine runs in both arms; target placement and paired cache
reuse change. Order: control, candidate, candidate, control.

| Metric (mean of two arms) | Previous serial placement | Shared placement | Change |
|---|---:|---:|---:|
| Single-request decode | 120.890 tok/s | 129.319 tok/s | +7.0% |
| Four-request throughput | 108.167 tok/s | 162.331 tok/s | +50.1% |
| Four-request wall time | 4,733.455 ms | 3,154.056 ms | −33.4% |
| Repeated-prompt TTFT | 891.394 ms | 44.685 ms | −95.0% |
| Cold prefill TTFT | 893.065 ms | 919.492 ms | +3.0% |
| Launch to first output | 1,070.260 ms | 978.795 ms | −8.5% |

All 60 requests complete, with identical request bodies and token counts.
Single-request text and raw completion/chat probes match. One of four
concurrent responses changes across implementations; each implementation's
repeats are exact. Usage differs by execution lane, repeated-prefix reuse
(752 tokens versus zero), and the changed response's speculative counters.
Thus aggregate timing holds token budgets fixed, with one changed trajectory.
The control launch times span 970–1,171 ms; this is not strict startup
acceptance. Cold-prefill latency still regresses. The change is integrated
in the unreleased tree; defaults remain unchanged.

Control source: `3a420497bf8a8c6be5896050b45773d541515a22e737d8775522d742221a8d41`.
Candidate source: `20c21f2f62383b9878966f8ea1bf74c98d58942d33351430042ff7801cb929c4`.
Evidence: `reports/qwen38-closeout/composition-baseline/full-kv-speculation/`,
including four raw M4 reports and `benchmark-comparison.json`.

## Standalone drafting: first shared-executor comparison

M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2. Qwen3.8 packed 27B target plus
Qwen3.5 0.8B OptiQ standalone drafter, depth two, KV4 from token zero,
4 GiB RAM cache plus temporary SSD, 192 decode tokens and four concurrent
requests. Production `bench-serve.ts all`, seed `standalone-serving-0`,
context sweep skipped; advisory diagnostic mode under Josh's machine policy.

| First run | Single-request decode | Repeated-prompt TTFT | Reused tokens | Four-request throughput |
|---|---:|---:|---:|---:|
| Previous standalone provider | 8.936 tok/s | 5,987.688 ms | 0 | 8.617 tok/s |
| Shared standalone candidate | 13.945 tok/s | 122.100 ms | 756 | GPU allocation failure |

The initial candidate's aggregate phase failed both attempts with native Metal
insufficient-memory errors. A complete-sequence profile reproduces the failure
with 4,005 MiB of accounted cache entries and an observed 17,987 MiB peak;
a fresh aggregate completes. Retained RAM entries consume batch headroom.

A second matched comparison uses **2 GiB RAM plus SSD in both arms**, in
candidate/control/control/candidate order. Other settings are unchanged;
default capacity is eight, with four concurrent requests. All 60 recorded
requests complete without failures. Means of the per-arm measurements:

| Metric | Previous standalone provider | Shared standalone provider | Change |
|---|---:|---:|---:|
| Single-request decode | 8.882 tok/s | 13.970 tok/s | +57.3% |
| Four-request throughput | 8.614 tok/s | 9.343 tok/s | +8.5% |
| Four-request wall time | 59.437 s | 54.807 s | −7.8% |
| Repeated-prompt TTFT | 5,989.823 ms | 122.527 ms | −98.0% |
| Cold prefill TTFT | 5,993.083 ms | 6,153.492 ms | +2.7% |
| Launch to first output | 4,332.735 ms | 4,537.720 ms | +4.7% |

All request bodies, token counts and single-request text match; raw completion
and chat probes also match. Candidate repeats preserve single-request text and
usage. Concurrent text and acceptance counters differ both across implementations
and between candidate repeats as admission geometry changes; throughput is a
fixed-token-budget serving measurement, not identical generated content.
The new provider retains recurrent draft history after rejection; the old
provider discarded that history. It also retains paired cache state, with
756 tokens reused on the repeated prompt versus zero in the control.

The provider is integrated in the unreleased working tree. The cold/startup
cost and the 4 GiB failure remain; this does not close strict serial dominance
or select application defaults. MTP comparisons use a different drafter and
must remain separate. Control source is
`0a7e65986e57b493e7ab30a2e328a1eb591b03b029f59e342fd8a01471538613`;
candidate source
`3a420497bf8a8c6be5896050b45773d541515a22e737d8775522d742221a8d41`.
Evidence: `reports/qwen38-closeout/composition-baseline/two-model-batch/`,
including `ram2/benchmark-comparison.json` and raw request records.

## Current serial versus shared execution: staggered Gemma requests

M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0, unreleased source
`0a7e65986e57b493e7ab30a2e328a1eb591b03b029f59e342fd8a01471538613`.
Gemma 4 12B OptiQ, ordinary KV4, 4 GiB RAM prompt cache and temporary SSD.
`bench-serve.ts all` uses 192 decode tokens, skipped context sweep,
`--aggregate-context 2048 --aggregate-stagger-ms 25`, seed `prefill-long-0`.
The serial arm pins `--batch 1`; the shared arm uses the default capacity eight. The four aggregate prompts contain 1,289/1,281/1,287/1,287
tokens with 13/12/14/12 cached, and each emits 128 tokens. Diagnostic mode
follows Josh's retained-swap policy; no competing GPU job runs during timing.

| run order | median decode tok/s | cached first-token ms | aggregate tok/s | aggregate wall ms | first request TTFT ms | mean TTFT ms |
|---|---:|---:|---:|---:|---:|---:|
| serial 0 | 26.3177 | 155.205 | 11.4938 | 44545.58 | 10037.72 | 24644.60 |
| shared 0 | 26.0648 | 155.797 | 19.7660 | 25903.03 | 9287.39 | 16360.50 |
| shared 1 | 26.2129 | 154.351 | 20.1601 | 25396.75 | 9031.62 | 15985.86 |
| serial 1 | 25.9724 | 156.207 | 13.0064 | 39365.23 | 4776.07 | 19477.02 |

Mean aggregate throughput increases **62.96%**, total aggregate time falls
**38.86%**, and mean first-token latency falls **26.69%**. Single-request
decode is effectively equal, −0.024% in throughput or +0.056% in summed
request time; cached latency falls 0.406%. First-request latency does not
dominate: the second serial sample starts in 4.78 s versus shared samples
near 9.1 s. Startup also has an initial serial outlier, so it is not a settled
comparison. These limits keep strict serial deletion acceptance open.

All 60 requests complete without failure. Request bodies, usage excluding
the expected lane label, token/cache counts and finish markers match. All
single-request texts match; all four concurrent texts differ between serial
and shared. Repeated runs of each arm produce identical text. This measures
throughput for the same submitted workload and output-token budgets, not
identical generated content. Same-B model oracle checks remain separate.
Source hashes stay fixed throughout both blocks. Raw reports and comparison:
`reports/qwen38-closeout/composition-baseline/current-serial-dominance/`.

## Delayed full-attention padding: M4 comparison

The unreleased cache implementation now supports padded prefill while full
attention rows transition independently from BF16 to affine or TurboQuant.
Shared row positions and codec ownership replace separate padding logic.
The existing uniform KV4 decode still uses the same packed attention code.

M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0. Qwen3.8-27B packed
interleave2 target and folded RTN4 MTP companion, depth 2, KV4 from token zero,
4 GiB RAM prompt cache, temporary SSD cache, configured batch capacity 8,
four concurrent requests. Production `bench-serve.ts all`, 192 decode tokens,
`--skip-context`, workload seed `mtp-serving-block-0`, async expansion off and
fused TQ decode enabled. Diagnostic mode follows Josh's retained-swap policy;
free memory starts at 90–93%, retained swap at 1.6–2.8 GiB. No other GPU job
runs during timing. The audio-daemon allowance is explicit.

| arm, in order | median decode tok/s | aggregate tok/s | cached first-token ms | ready ms | cold start ms |
|---|---:|---:|---:|---:|---:|
| control 1 | 19.2267 | 16.4810 | 98.186 | 610.78 | 4085.57 |
| candidate 1 | 19.1023 | 16.4524 | 98.070 | 821.10 | 4167.10 |
| candidate 2 | 19.1224 | 16.4746 | 99.601 | 614.60 | 4009.12 |
| control 2 | 19.3181 | 16.5351 | 99.174 | 621.53 | 3982.93 |

Candidate/control means change decode throughput by −0.831%, aggregate
throughput by −0.270%, cached latency by +0.157%, and cold start by +1.335%.
One candidate readiness sample is about 200 ms higher; the other overlaps
controls. These measurements establish no speed improvement or strict serial
performance dominance. The feature is integrated with these limits recorded;
long-prefill and B1 performance acceptance remain open.

All 60 request bodies, responses, usage/speculation counters, token counts,
finish reasons and completion markers match. No requests fail. Each source
snapshot stays fixed: control `7f06df944eb062703711f29b086879718868803c00367dd992b3a5bb8d0fac8e`,
candidate `0a7e65986e57b493e7ab30a2e328a1eb591b03b029f59e342fd8a01471538613`.
Both-machine cache/model and seeded delayed-conversion gates accompany this
comparison. Evidence: `reports/qwen38-closeout/composition-baseline/full-delayed-prefill/`,
including `benchmark-comparison.json`, `manifest.json`, and `m4/` raw reports.

## Shared MTP prefill: M4 comparison and scheduling attribution

Apple M4 Pro, 24 GB; Bun 1.4.2, MLX 0.32.2. Packed interleave2
Qwen3.8-27B, affine KV4, folded MTP2, four concurrent requests (configured
maximum batch 8), 4 GiB prompt cache,
192 output tokens per decode request, five decode samples, context sweep off.
`bench-serve.ts all` uses workload seed `mtp-serving-block-0`, fused TQ enabled
and async Trellis expansion disabled. Four balanced runs use
control/candidate/candidate/control order. The first control started with zero
swap; subsequent runs used `--diagnostic` after swap returned. All runs finished
without request failures and retained stable source hashes within each run.

| Preparation policy | Runs | Mean decode median tok/s | Mean concurrent tok/s |
|---|---:|---:|---:|
| Control: existing MTP preparation | 2 | 19.331 | 15.194 |
| Common driver, shared prefill | 2 | 19.069 | 14.076 |
| Common driver, individual preparation | 2 | 19.158 | 15.508 |
| Common driver, finish resumed final step first | 1 | 19.3 | 14.099 |

Shared prefill loses **1.35%** single-request decode rate and **7.36%** concurrent
throughput relative to the balanced control means. Mean concurrent wall time
rises from 33.718 to 36.374 seconds. Cached first-output latency is 98.23 versus
99.85 ms; cold 1K first-output latency is 5844.61 versus 5997.68 ms.

All 60 requests in the balanced comparison preserve request hashes,
prompt/output/cache counts, finish reasons and completion markers. Single-request
text and usage are exact. Three of four concurrent responses change between
control and candidate; each arm reproduces its own text and full usage exactly.
Thus this is a serving comparison with changed concurrent numerical trajectories,
not an identical-work kernel timing. Total concurrent speculative rounds fall
from 234 to 232, so an increase in round count does not explain the slowdown.

The individual-preparation control changes only the scheduler admission budget
from 2048 to zero and retains B4 decode and the same common driver. Both runs
reproduce every control response and full usage record. The clean repeat
confirmed that this is the only source difference. Finishing resumed final
steps first instead leaves concurrent responses/usage identical to shared
prefill and does not recover its throughput. None of these isolated candidates
is adopted. The next investigation is preparation-to-decode cache state and
actual work per round.

Two instrumented follow-ups locate the sustained cost in target verification.
Across 53 B4 rounds per arm, median complete-round time is 540.64 ms with
shared preparation versus 459.01 ms with individual preparation. The target
forward interval is 510.50 versus 430.34 ms; draft generation is 12.11 versus
12.15 ms. These are lazy-execution phase timings, so the target interval includes
any work it forces; layer-level attribution is still needed. Independent saved
SSE timestamps reproduce the uninstrumented gap (about 542 versus 459 ms
between output bursts during seconds 10–25).

Further probes run three B4 rounds with layer synchronization. Both arms use
128 packed gate/up calls and 64 expanded down-projection calls, with identical
M=12 and bf16 geometry. The down-projection evaluation interval, which also
forces the preceding lazy packed gate/up work, is 412.68 versus 355.75 ms.
This narrows the cost to MLP evaluation but does not distinguish its packed
kernels from weight expansion/native matmul. Phase/layer probes preserve their
respective control responses and usage. A separate candidate evaluates target
state and clears the temporary buffer pool after preparation; it completes
without failures at 14.3 concurrent tok/s, still below individual preparation.
It is not adopted. Profiles: `mtp-cohort-layer-profile.json` and
`mtp-cohort-trellis-profile.json`; drain result: `mtp-cohort-drain-manifest.json`.

A subsequent split probe evaluates inputs, packed projections, expanded weights
and matrix products separately. Across three instrumented B4 rounds, median
expansion time is 157.92 ms after shared preparation versus 85.55 ms after
individual preparation. Packed gate/up evaluation is 232.03 versus 229.83 ms;
expanded-weight matrix multiplication is 88.75 versus 84.07 ms. These inserted
synchronization points change absolute latency and serve only to locate work.
The separate input-evaluation candidate passes M1 native MTP serving but reaches
13.8 concurrent tok/s on the M4, so it is not adopted. Evidence:
`mtp-cohort-split-profile.json`, `split-profile-*.md.json`, `input-eval-1.md.json`.

Smaller vector expansion tiles (32, 64 and untiled) reach 14.15–14.22
concurrent tok/s; variant 12 reaches 13.30; a residency refresh reaches 14.00.
All preserve their shared-prefill reference responses and usage, and none is
adopted. Memory instrumentation observes 16.823 GiB active after shared
preparation versus 16.534 GiB after individual preparation. A native ownership
probe confirms that a deferred compact row copy retains its larger parent
allocation until evaluated.

Evaluating target snapshots before RAM retention recovers concurrent throughput
in two M4 runs: **16.268 and 16.299 tok/s**, averaging 16.283, versus 14.076
for the original shared-preparation pair (**+15.68%**) and 15.508 for the two
individual-preparation controls (**+5.00%**). Concurrent wall time falls to
31.473 and 31.414 seconds. Single-request decode medians are 19.277 and 19.108
tok/s; cached first output is 100.66 and 100.76 ms. All 30 requests preserve
request hashes, output text and full usage exactly against shared preparation.
Source is stable in both runs. The M1 native serving test passes 229 assertions.
The final implementation below moves this behavior from method-local capture
to the common cache ownership boundary for every producer.
Evidence: `mtp-cohort-snapshot-eval-review.json`,
`mtp-cohort-expansion-screen-review.json`, `mtp-cohort-memory-profile.json`.

Moving materialization into the shared RAM cache, including companion tensors,
preserves all 30 responses and usage records in two further M4 runs. Concurrent
throughput is **16.477 and 16.384 tok/s**; single-request decode is 19.127 and
19.205 tok/s; cached first output is 97.62 and 98.79 ms. The common implementation
passes 2,150 M1 tests (14 skipped), all typechecks, and the generated TurboQuant
RAM/SSD continuation test at MTP3/B4. M1 native lookup passes 228 assertions and the ordinary 4096-token TQ prefix
ownership test passes 40. A fresh current-tree control reaches 19.245 decode
and 15.539 concurrent tok/s, with 99.02 ms cached first output. Against that
control, the common-cache pair averages **5.74% higher concurrent throughput**,
0.41% lower single-request decode and 0.83% lower cached first-output latency.
This is a two-candidate/one-control comparison; the older balanced control
pair remains above. The M4 suite passes 2,154 tests (10 skipped), both-machine typechecks pass, and
M4 native TQ MTP serving passes 229 assertions. The shared driver and common
cache fix are adopted in the unreleased working tree; main integration
suite, typechecks and hygiene pass. Strict serial dominance remains open. Review:
`mtp-cohort-cache-boundary-review.json`; source/validation:
`mtp-cohort-cache-boundary-manifest.json`.

The final memory profile differs from the original shared-preparation profile
only in the two cache implementation files. Active GPU allocation falls from
16.823 to **16.458 GiB**, releasing **373.37 MiB**. Median weight-expansion time
falls from **147.57 to 86.17 ms** across three instrumented B4 rounds, matching
the individual-preparation profile's 87.99 ms. Routes, geometry and call counts
are unchanged; all 15 responses and full usage remain exact. The retained-memory
regression passes with materialization and fails when it is disabled. Profile
latencies locate the cost; the uninstrumented runs above measure serving speed.
Evidence: `mtp-cohort-memory-profile.json` and
`memory-profile-cache-boundary.md.json`.

Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`:
`mtp-cohort-benchmark-comparison.json`, `mtp-cohort-admission-comparison.json`,
source manifests/patches, seven comparison runs and instrumented follow-ups in
`mtp-cohort-m4/*.md.json`; phase timing is in `mtp-cohort-phase-profile.json`.

## Delayed affine row composition: fixed-settings M4 regression

Apple M4 Pro, 24 GB, macOS 27.0.0, Bun 1.4.2, MLX 0.32.2/native pack
0.4.0. The existing `bench-serve.ts all` suite ran control/candidate/candidate/control
on the packed interleave2 Qwen3.8-27B artifact with KV4, MTP2, 192 output tokens,
five decode requests, prompt cache 4 and context sweep disabled. Workload seed
`mtp-serving-block-0`; fused TQ enabled, async Trellis expansion disabled.
All preflights passed with Josh's audio-daemon allowance. Source stayed fixed:
control `88da0dca100cdb012cbd4330638cc43b727dbb853a5b1ef6aded60bc6fe1eb0d`,
candidate `eacbb8c7d9e1a2f06c4235f71dc7db51f29b8bd27a9940a5e802a056220ff336`.
Remote checkout HEAD was `0c355f4`; source hashes include the unreleased changes.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 55,730.95 | 97.33 | 15.9259 |
| Candidate 1 | 55,585.20 | 97.57 | 15.8891 |
| Candidate 2 | 55,678.22 | 99.36 | 15.7890 |
| Control 2 | 55,682.47 | 99.41 | 15.7812 |

All 60 request records retain identical request hashes, response text, complete
usage, token counts and finish reasons. Combined candidate/control changes are
−0.135% decode wall time, +0.099% cached latency and −0.091% aggregate throughput.
Peak RSS is effectively unchanged. Startup was less stable: the initial control
reached readiness in 608 ms versus about 800 ms in the later arms, and its cold
start was 3,443 ms versus about 4,200–4,300 ms afterward. The candidate overlaps
the final control, but this screen does not establish startup equivalence.
The decode and cached-latency changes overlap the observed
control variation: the existing default path is effectively flat. This is a
regression check for integrating delayed-affine support and the shared transition
lifecycle, not a measurement of delayed conversion speed or serial dominance.
Both-machine native/serving/SSD correctness gates qualify the new composition.
Raw records and comparison: `reports/qwen38-closeout/composition-baseline/delayed-affine/`.

## Captured attention views: M4 regression

Same M4 Pro 24 GB/toolchain, packed Qwen artifact and 192-token KV4/MTP2
protocol as the delayed-affine comparison above. Order is again
control/candidate/candidate/control, with unchanged requests and initial cache
settings. Control source is
`eacbb8c7d9e1a2f06c4235f71dc7db51f29b8bd27a9940a5e802a056220ff336`;
candidate source is
`f94a8212be222056a0d1cdc70c45c3d7f2e50a937eb89560a719ee4bf21c61f7`.
Both sources remain fixed throughout their runs.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 55,784.51 | 97.57 | 15.8553 |
| Candidate 1 | 55,656.05 | 97.18 | 15.9355 |
| Candidate 2 | 55,687.98 | 97.26 | 15.9648 |
| Control 2 | 55,680.16 | 97.45 | 15.9668 |

All 60 request records match in input hash, output text, complete usage, token
counts and finish reason. Combined decode wall time changes −0.108%, cached
latency −0.298%, and aggregate throughput +0.246%; peak RSS is unchanged.
These are effectively flat regression results, not a general speedup or serial
dominance result. Initial-control startup was faster than every subsequent
arm: readiness 607 ms versus 817–818 ms; cold start 3,487 ms versus 4,210–4,254 ms.
Startup equivalence remains unproven.

All start checks pass with the audio-daemon allowance. The final control's raw
end check flags `/usr/libexec/mobileassetd` at 84% CPU and 23 MB RSS, while free
memory remains 92%. That flag remains in the raw result. Under Josh's policy
allowing isolated background CPU activity, the stable paired decode/cached
measurements support feature integration; this is not an entirely unflagged
four-arm run. The initial wrapper's separate oracle-path error occurred before
inference and is retained as a failed launch, not a timing sample.

The changed attention-view operations are qualified by both-machine full-model
Gemma/MiniCPM state/logit checks, Qwen rollback/MTP/lookup checks and exact SSD
continuations. This default-settings screen does not measure delayed conversion
speed. Evidence: `reports/qwen38-closeout/composition-baseline/kv-attention-view/`.

## Delayed rotating affine composition: M4 regression

Same M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0 and packed
Qwen KV4/MTP2 protocol as the preceding comparisons: 192 output tokens,
five decode requests, prompt cache 4, workload seed `mtp-serving-block-0`,
context sweep disabled, fused TQ enabled and async expansion disabled.
The four arms ran control/candidate/candidate/control with stable sources:
control `1b1ededa649088e8338a2930b4ae152e66edf7e4048e2dc8d0b7a3859691800c`,
candidate `c7d58f7ec867015eff7bbc9a7f02d13baea28173dd312bd504e9b880659278eb`.
Every start/end preflight passed with the recorded audio-daemon allowance;
there were no request or phase failures.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 55,775.68 | 97.24 | 15.9569 |
| Candidate 1 | 55,608.34 | 97.49 | 16.0176 |
| Candidate 2 | 55,692.19 | 97.55 | 15.8421 |
| Control 2 | 55,661.04 | 99.17 | 15.8041 |

All 60 records match in request hash, response text, complete usage including
speculation counters, token counts and finish reason. These HTTP records do
not contain emitted token IDs; native tests provide the numerical evidence.
Candidate versus control means change decode wall time by −0.122%, cached
latency by −0.696% and aggregate throughput by +0.311%. Peak RSS spans
12,208–12,224 MB. These are effectively flat regression results. The first
control reaches readiness in 609 ms and cold start in 3,610 ms; the remaining
arms take 817–818 ms and 4,235–4,288 ms. Startup equivalence remains unproven.

This checks the shared lifecycle on the existing default Qwen path. It does
not measure positive-threshold Gemma conversion speed or establish serial
dominance. Both-machine Gemma KV4/KV8 and per-layer native state/logit,
RAM/SSD continuation and seeded serving tests cover the new composition;
fresh-process Gemma and long-pressure acceptance remain open.
Evidence: `reports/qwen38-closeout/composition-baseline/delayed-rotating/`.

## Singleton admission attribution on M4 Pro

A synthetic Qwen-shaped MLX 0.32.2 probe compares singleton `copyOf` with
`contiguous`, using evaluated donors: 48 recurrent states, 16 KV4 layers at
757 logical tokens with 768-token capacity, and their combination. Each arm
has four warmups and twenty samples; order is control/candidate/candidate/control.
The combined logical storage is 168,099,840 bytes. Both implementations add
**zero live GPU allocation** during admission. Combined median admission times
are 0.1463/0.1435/0.1470/0.1464 ms in execution order. There is no demonstrated
physical-copy saving; `copyOf` already shares storage in this runtime.
These synthetic measurements do not establish complete-request speed. The
initial probe launch omitted the required stream argument to `synchronize`;
its failure is retained separately and supplied no timing sample.

The completed four-arm `bench-serve.ts all` comparison uses the same M4
Qwen KV4/MTP2, 192-token protocol as above. Control source is
`c7d58f7ec867015eff7bbc9a7f02d13baea28173dd312bd504e9b880659278eb`;
candidate is `b7361d962c70f0efbb5c55c32f06996103015477095833c98d83928cc23ddd52`.
All source snapshots and start/end preflights pass. All 60 request hashes,
response texts, complete usage/speculation counters, token counts and finish
reasons match, with no request or phase failures.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 56,033.78 | 99.64 | 15.8719 |
| Candidate 1 | 55,590.06 | 97.28 | 15.9511 |
| Candidate 2 | 55,682.16 | 97.35 | 15.9217 |
| Control 2 | 55,725.68 | 99.44 | 15.9324 |

Candidate/control means change decode wall time −0.436%, cached latency
−2.230% and aggregate throughput +0.216%. Both candidate cached samples are
lower than both controls, although the physical-copy hypothesis is disproven
and MTP group admission follows its first published token. The latency result
needs attribution/repetition before treating this replacement as an accepted
optimization. Controls report readiness at 608 ms and candidates at 816 ms;
the readiness probe polls every 200 ms, so these observations have coarse
resolution. Cold starts are 3,414/4,114/4,224/4,017 ms in execution order.
Startup equivalence and direct serial dominance remain unproven. Both-machine
native, serving, full-suite and typecheck checks pass; the candidate is isolated.
Evidence: `reports/qwen38-closeout/composition-baseline/singleton-state/`.

## Recurrent row retention diagnostic on M1 Max

Apple M1 Max 32 GB, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0. A synthetic
Qwen-shaped recurrent layer contains 3,207,168 logical bytes per row. After
extracting one row and disposing its source, the existing implementation keeps
3,211,264 / 6,422,528 / 12,828,672 / 25,657,344 live allocator bytes for source
B=1/2/4/8. A proper-subset compact copy retains 3,211,264 bytes in every case,
including allocator rounding. B1 continues to share its whole allocation.
This measures one layer, not full-model RSS or request time. The allocation
regression fails against unchanged source and passes with exact values on the
isolated fix. Both-machine MTP and bf16/KV4/TQ generated RAM/SSD continuation,
complete-suite and typecheck checks pass. The allocation regression also passes
on M4. The reviewed extraction fix is adopted in the unreleased working tree.

The M4 Pro 24 GB `bench-serve.ts all` check uses the same packed Qwen KV4/MTP2,
192-token protocol above, in control/candidate/candidate/control order. Sources
remain fixed: control
`c7d58f7ec867015eff7bbc9a7f02d13baea28173dd312bd504e9b880659278eb`, candidate
`bdc1241596526f42d68ba0988fc63cd90dce73ce8d048b45d9bfa1cc0c5872c7`.
All start/end preflights pass; all 60 request hashes, response texts, full usage
and speculation counters, token counts and finish reasons match. No failures.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 56,548.78 | 99.48 | 15.7814 |
| Candidate 1 | 55,608.23 | 99.02 | 15.9869 |
| Candidate 2 | 55,785.82 | 97.41 | 15.8657 |
| Control 2 | 55,636.97 | 99.47 | 15.9106 |

Candidate/control means change decode wall time −0.706%, cached latency
−1.264% and aggregate throughput +0.507%. The initial control is slower than
the remaining arms; candidate throughput overlaps the control range, and the
second candidate decode total is slightly above the second control. Treat
these as a regression check for the storage fix, not a broad speedup or serial
dominance result. Peak RSS spans 12,208–12,240 MB. Startup remains unresolved:
readiness is 608/816/816/817 ms and cold start 3,704/4,177/4,240/4,181 ms.
The short workload does not establish long-context pressure acceptance.
Evidence: `reports/qwen38-closeout/composition-baseline/ssm-extraction/`.

## Batched prefill cohorts: M4 regression before projection correction

Unreleased isolated candidate against the previously validated delayed-padding
checkout. Apple M4 Pro, 24 GB; Bun 1.4.2, MLX 0.32.2/native pack 0.4.0.
Gemma 4 12B OptiQ, ordinary generation, KV4, RAM prompt cache 4 GB, default
batch capacity 4. Both checkouts have HEAD `0c355f4` plus frozen source changes.
Control source SHA-256 `89d209400c1f683143ee9afea30e8a440ee00159fe96ba8e1c3bbe5893c744ac`;
candidate `2431d0395ad7e752991bc47817cf8c6f54a6d74fb6e0f6fc08598e314ce6d937`.

Protocol: `bun scripts/bench-serve.ts all --model-path <Gemma-12B-OptiQ>
--arms mlx-bun --tokens 192 --skip-context --kv-quant 4 --prompt-cache 4
--workload-seed delayed-padding-0 --allow-cpu-process /usr/libexec/audiomxd`.
Run order is control, candidate, candidate, control. All preflights and saved
machine checks pass, with 217 MB swap and the explicitly allowed audio daemon.
Source hashes remain fixed throughout all four arms; no request failures.

| arm | five decode requests, total ms ↓ | cached first-token ms ↓ | B4 aggregate tok/s ↑ | ready ms | cold-start ms | peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|
| control 1 | 38,010.26 | 154.517 | 72.966 | 609.34 | 2,150.35 | 8,985.45 |
| candidate 1 | 38,063.00 | 154.884 | 72.965 | 608.25 | 1,026.27 | 8,990.06 |
| candidate 2 | 37,950.08 | 154.601 | 73.024 | 608.52 | 1,024.44 | 8,985.66 |
| control 2 | 37,906.38 | 154.930 | 73.032 | 609.03 | 1,029.51 | 8,967.28 |

Candidate means: decode wall **+0.127%**, cached latency **+0.012%**, aggregate
throughput **−0.006%**. These results establish no speed win or strict serial
dominance. The first control's cold-start outlier does not establish a startup
improvement. This short-prompt workload does not measure long-prefill scaling.

All request bodies, token counts, usage, finish reasons and completion markers
match. Both candidates change the text of concurrent rows 1–3; candidate repeats
are identical to each other, as are control repeats. Other responses and parity
probes match. This is not an all-responses-identical regression result. Same-B
model checks pass on Qwen 27B and Gemma 12B on both Macs, and an admission-only diagnostic restores all
baseline responses, tying the text changes to shared prefill. An added M4 token-zero check subsequently
found a sampler-logit mismatch when finished rows project separately. A follow-up
candidate projects the batch before selecting sampler rows; these timing numbers
do not measure that fix. The corrected projection passes the M4 model/sampler
checks. Its fresh comparison is recorded below; the earlier measured candidate is not adopted.

Raw evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`,
including source manifest/patch, native checks and the four complete reports.

## Batched prefill cohorts: corrected M4 comparison

The benchmark now also accepts `--aggregate-context <approximate tokens>` and
`--aggregate-stagger-ms <milliseconds>` for long, staggered HTTP requests.
Zero preserves the original short-prompt/simultaneous workload. Reports record
these settings, actual submission offsets, prompt/cache counts, first-token
latencies and total aggregate wall time. These workload changes must match
between comparison arms; the historical short-prompt numbers below use zeros.

The corrected candidate projects the forward batch before selecting each
sampler's logits. It is adopted in the unreleased working tree. Same machine,
model, protocol, settings and control as the preceding comparison, with fresh
control/candidate/candidate/control runs. Candidate source SHA-256
`84abd86ac44155298ec14cc59eeb0b51a0f1862d45e199b3597ef8a22d24a31f`.
All source hashes remain fixed, all preflight/save checks pass, and every arm
reports zero failures. Retained swap is 215 MB; the audio daemon allowance is
explicit, as in the preceding run.

| arm | five decode requests, total ms ↓ | cached first-token ms ↓ | B4 aggregate tok/s ↑ | ready ms | cold-start ms | peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|
| control 1 | 37,975.15 | 155.060 | 73.009 | 608.52 | 1,033.49 | 8,977.16 |
| candidate 1 | 37,989.93 | 154.810 | 73.042 | 608.63 | 1,029.35 | 8,980.83 |
| candidate 2 | 37,971.84 | 154.802 | 73.071 | 608.51 | 1,030.21 | 8,974.33 |
| control 2 | 37,974.80 | 154.991 | 73.003 | 609.87 | 1,027.01 | 8,954.62 |

Candidate means: decode wall **+0.016%**, cached latency **−0.142%**, aggregate
throughput **+0.069%**. Ready time changes by −0.102%, cold-start time by
−0.045%, and peak RSS by +0.130%. This is effectively flat performance for the
short-prompt workload, with no established speed win or strict serial dominance.
Long-prefill scaling remains unmeasured by this workload.

All 60 requests complete. Request bodies, token counts, usage, finish reasons
and completion markers match the baseline. The two candidate repeats produce
identical responses; the two controls do too. Three concurrent responses differ
between candidate and control, as in the earlier admission-only attribution.
Other responses match. These cross-shape text differences do not establish
an engine-only coding-task speedup or an all-responses-identical result.
The corrected same-B Qwen 27B and Gemma 12B checks include full logits,
token-zero sampler logits and restored continuation on both Macs.

Raw evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`,
particularly `projection-m4/`, `projection-benchmark-comparison.json`, and
`projection-manifest.json`. Main integration results are recorded in the manifest.

## Staggered long prefill: M4 regression

Gemma 4 12B OptiQ, M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0.
Same ordinary KV4/cache settings as the preceding corrected comparison.
The benchmark adds `--aggregate-context 2048 --aggregate-stagger-ms 25` and
uses `--workload-seed prefill-long-0`. Actual aggregate prompt counts are
1,289/1,281/1,287/1,287, with matching cache hits of 13/12/14/12 across all arms.
The target length is a character-based estimate, not a measured token count.
Client submission offsets are approximately 0/26/51/76 ms. Each request
produces 128 completion tokens. The existing prefill chunk default is 2,048.

Control source SHA-256
`4ab50112e6464d0d778f80398d8f61e3740c9a6dd5c3c9725f34b255c26b7711`;
candidate `003827c79e0bcefd65c33fe7366faa28ca60d7fd428063f6c3a159efd7a60991`.
Both include the same benchmark extension; inference code matches the preceding
control/corrected candidate respectively. All source hashes stay fixed, all
preflight/save checks pass, and all requests complete without failure. The
explicit audio allowance applies; retained swap remains 215 MB.

| arm | aggregate wall ms ↓ | aggregate tok/s ↑ | first request TTFT ms ↓ | mean request TTFT ms ↓ | peak RSS MiB |
|---|---:|---:|---:|---:|---:|
| control 1 | 25,278.61 | 20.254 | 9,007.88 | 15,911.29 | 8,947.95 |
| candidate 1 | 26,328.98 | 19.446 | 18,696.52 | 19,042.67 | 8,997.20 |
| candidate 2 | 26,543.42 | 19.289 | 18,849.50 | 19,193.88 | 9,013.50 |
| control 2 | 26,388.15 | 19.403 | 9,493.52 | 16,771.75 | 8,949.66 |

Candidate means show **2.333% longer aggregate wall time**, **2.324% lower
throughput**, **102.936% higher first-request TTFT**, and **16.992% higher mean
TTFT**. The controls' aggregate wall times differ by 4.4%, so the exact small
throughput penalty is not stable enough to generalize. The large first-request
latency penalty repeats clearly. Short decode request wall time changes by
−0.066%, and cached TTFT by −0.036%. Shared prefill has not passed long-request
performance acceptance. No serial deletion or default promotion follows.

Requests, usage, counts, finish reasons and completion markers match. Concurrent
rows 1–3 change text; other responses match, and each pair of repeated arms is
internally identical. This remains a comparison of identical submitted work,
not an all-responses-identical result or a coding-task quality assessment.

An M1 diagnostic with `MLX_BUN_P2R_TRACE=1` records the first request's internal
token-zero completion at about 6.25 s, but its first response write at 25.94 s.
The following B3 prefill chunk spans 18.25 s. This points to long preparation
work delaying active output, rather than admission waiting alone. It is
instrumented M1 attribution, not an M4 performance claim. A bounded M4 screen
with prefill chunks of 256 completes at 26,526.13 ms aggregate wall time and
19.302 tok/s, with first-request TTFT 13,235.29 ms. It improves first output
relative to the candidate's 2,048-token chunks but still trails the earlier
control. The matching 256-token control completes at 26,011.10 ms and
19.684 tok/s, with first-request TTFT 7,232.19 ms. The candidate therefore
still has 1.980% longer wall time and 83.005% higher first-request TTFT at
matching chunk size. Source/preflight/save checks pass with no failures.
Requests, usage/counts and completion markers match, but all four concurrent
texts differ. This one-pair screen does not qualify a default. Smaller chunks
change KV conversion boundaries and do not resolve the admission/work-unit
performance problem. Raw comparison: `long-chunk256-comparison.json` in the
evidence directory below.

Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`,
including `long-m4/`, `long-benchmark-comparison.json`, and
`long-m1-prefill-traces.json`.

## Prefill admission work budget: M4 comparison

The isolated scheduler candidate limits admission to an existing prefill cohort
using initial uncached token work. Its internal budget is 2,048 tokens; a larger
request still enters alone and runs through the same preparation method. An
earlier shrinking-weight screen restored first TTFT to 9,538.63 ms but completed
the group in 26,797.77 ms, versus 9,012.73/25,295.58 ms in the first control,
and still changed three responses. The fixed-weight candidate below avoids
attaching another long prompt to a nearly completed request.

M4 Pro 24 GB, Gemma 4 12B OptiQ, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0.
Same protocol and exact inputs as the preceding staggered-long comparison,
including KV4, prompt cache 4 GB, chunk default 2,048, 25 ms arrival spacing,
and `prefill-long-0`. Actual prompt/cache/output counts match. Control source
SHA-256 `4ab50112e6464d0d778f80398d8f61e3740c9a6dd5c3c9725f34b255c26b7711`;
fixed candidate `2dcee8a99708c66facd8aa296fe8b990de92eca5031453888947e9f9f35dfd72`.
Run order was control 1, the earlier shrinking-weight screen, fixed candidate 1,
fixed candidate 2, control 2. All source hashes remain fixed within their runs;
all preflight/save checks pass under the explicit audio-daemon allowance, with
215 MB retained swap and no failed requests.

| arm | aggregate wall ms ↓ | aggregate tok/s ↑ | first request TTFT ms ↓ | mean TTFT ms ↓ | five decode requests, total ms ↓ | cached TTFT ms ↓ |
|---|---:|---:|---:|---:|---:|---:|
| control 1 | 25,295.58 | 20.241 | 9,012.73 | 15,955.67 | 37,922.95 | 154.872 |
| candidate 1 | 25,550.88 | 20.038 | 9,031.34 | 16,089.03 | 37,960.58 | 154.755 |
| candidate 2 | 26,390.25 | 19.401 | 9,526.85 | 16,783.75 | 38,091.45 | 155.456 |
| control 2 | 26,122.33 | 19.600 | 9,289.83 | 16,519.82 | 37,973.20 | 155.051 |

All 60 responses in the four fixed-candidate/control arms match exactly, including
request bodies, usage/counts, finish reasons and completion markers. Candidate
means are +1.018% aggregate wall time, −1.007% throughput, +1.397% first-request
TTFT, +1.223% mean TTFT, +0.205% short decode wall and +0.093% cached TTFT.
This restores the large latency regression from unrestricted cohorts, but does
not establish strict performance dominance. Aggregate timings vary by about
3.3% within both candidate and control pairs. No default-speed win is claimed.

The policy is adopted in the unreleased working tree. Complete suites/types
and long-prefix Qwen/TurboQuant and Gemma/KV4 ownership checks pass on both
Macs. Main integration suite/typecheck pass.
A separate lifetime review found that the new loop retains unused hidden output
through cache maintenance, unlike the existing shared prefill primitive. Its
release-order screen is complete and is not adopted, as recorded below.

Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`,
including `budget-m4/`, `budget-fixed-benchmark-comparison.json`, the earlier
`budget-remaining.patch`, and `budget-fixed-manifest.json`.

## Prefill early-release lifetime screen: no measured win

The candidate disposes input IDs immediately after prefill forward and unused
hidden output before cache maintenance. Its control is the adopted fixed-work
admission policy above. Same M4 Pro 24 GB, Gemma 4 12B OptiQ snapshot, Bun 1.4.2,
MLX 0.32.2/native pack 0.4.0 and production `bench-serve.ts all` protocol:
KV4, prompt cache 4 GB, 192 decode tokens, skipped context sweep,
`prefill-long-0`, aggregate context target 2,048 and stagger 25 ms.
Actual aggregate prompts/cache hits remain 1,289/13, 1,281/12, 1,287/14,
1,287/12, with 128 output tokens each. Control source SHA-256
`2dcee8a99708c66facd8aa296fe8b990de92eca5031453888947e9f9f35dfd72`;
candidate `46b351c3a4f4ed1442c946de388638b01611419fcc5a060c407f7a9da9584a80`.

| arm, in run order | aggregate wall ms ↓ | aggregate tok/s ↑ | first request TTFT ms ↓ | five decode requests, total ms ↓ | cached TTFT ms ↓ |
|---|---:|---:|---:|---:|---:|
| control 1 | 25,394.38 | 20.162 | 9,020.58 | 38,018.88 | 154.911 |
| candidate 1 | 25,537.82 | 20.049 | 9,033.96 | 37,966.96 | 154.710 |
| candidate 2 | 26,290.25 | 19.475 | 9,402.95 | 38,027.90 | 154.732 |
| control 2 | 25,888.99 | 19.777 | 9,164.43 | 38,000.93 | 154.781 |

All 60 responses, request bodies, usage/counts, finish reasons and completion
markers match exactly. All source/preflight/save checks pass; retained swap
stays at 208.25 MB under the explicit audio-daemon CPU allowance. No requests
fail. Candidate means are +1.062% aggregate wall time, −1.039% throughput,
+1.385% first TTFT, +1.366% mean TTFT, −0.033% short decode wall and
−0.081% cached TTFT. Aggregate run spread is 1.95% in controls and 2.95% in
candidates, so these small differences do not establish a causal slowdown.
Mean peak RSS differs by only −1.95 MB, or −0.022%, with no pressure test.
Cold start has a 2,132 ms first-control outlier versus roughly 1,095–1,100 ms
in the other three arms; its mean ratio is not evidence of a startup gain.

No speed or material measured-memory benefit is established. The candidate
remains isolated and is not adopted. M1 full suite/typecheck and Qwen 27B
same-B model/sampler/continuation checks on both Macs pass; M4 full suite and
typecheck were not run for this unadopted screen.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`,
including `drain-m4/`, `drain-benchmark-comparison.json` and `drain-manifest.json`.

## MTP preparation port and compiled activation: M4 comparison

This seven-file change adds provider-owned draft prefill using the existing
Qwen row state and replaces the companion's unfused MLP activation with the
compiled SwiGLU already used by the target. The new prefill port is not yet
connected to shared target preparation. This HTTP comparison therefore covers
the activation and row-lifecycle changes, not batched MTP prefill performance.
The same-B pinned companion check found 11 differing bf16 output values out of
10,240 in one decoder continuation with the old activation, maximum absolute
difference 0.0078125; KV already matched. The shared compiled activation passes
all tested KV/full-decoder continuations at B1/B2/B3/B4 on both Macs, including
a 2,051-token prefix and cold/restored joins.

M4 Pro 24 GB, packed Qwen 27B Trellis interleave2 artifact and folded RTN4/g64
MTP companion, Bun 1.4.2, MLX 0.32.2/native pack 0.4.0. Production
`bench-serve.ts all`, explicit `mlx-bun` arm, MTP2, KV4, prompt cache 4 GB,
192 decode tokens, five decode requests, context sweep disabled, original
short aggregate prompts at concurrency four, seed `mtp-serving-block-0`.
`MLX_BUN_TURBOQUANT_FUSED_DECODE=1` and
`MLX_BUN_TRELLIS_ASYNC_EXPAND=0` match the preceding MTP controls.
Control source SHA-256
`2dcee8a99708c66facd8aa296fe8b990de92eca5031453888947e9f9f35dfd72`;
candidate `69f3f37388ca0fdda2dd836786a20cb588c947fdc476b6206d617d7312d366fa`.

| arm, in run order | five decode requests, total ms ↓ | concurrent aggregate tok/s ↑ | cached TTFT ms ↓ |
|---|---:|---:|---:|
| control 1 | 55,546.48 | 15.7645 | 99.415 |
| candidate 1 | 55,705.24 | 15.6455 | 99.348 |
| candidate 2 | 55,931.24 | 15.7543 | 96.942 |
| control 2 | 55,905.67 | 15.7074 | 97.644 |

All 60 request bodies, response texts, prompt/output/cache token counts,
finish reasons and completion markers match. Five records per candidate arm
have different speculation statistics; candidate repeats agree exactly, as do
the controls. Four of the five decode requests have changed acceptance traces,
and one concurrent response has changed draft/acceptance counts. This follows
the corrected draft arithmetic and is not identical internal work. The targets
still return the same text and token counts.

Descriptive candidate/control means change decode wall by +0.165%, aggregate
throughput by −0.229%, aggregate wall by +0.230% and cached TTFT by −0.390%.
Readiness and cold-start means change by +0.059% and +0.051%. Mean peak RSS is
14.82 MB lower, without a pressure test. All source/preflight/save checks pass
under the audio-daemon allowance, with no request or phase failures. Retained
swap grows across the runs, from 200.25 MB before the first control to 297.88 MB
after the final control; the environment is not a fixed zero-swap control.

No speed win, identical-work ratio or serial dominance is established. The
provider port and numerical correction are adopted in the unreleased working
tree after both-machine companion-oracle, native MTP, full-suite and typecheck
checks. Main integration suite/typecheck pass. Shared target/MTP prefill integration,
its serving/caching gates and a combined performance comparison remain open.
Evidence: `reports/qwen38-closeout/composition-baseline/prefill-cohort/`, including
`mtp-prefill-m4/`, `mtp-prefill-benchmark-comparison.json`,
`mtp-prefill-manifest.json`, and `mtp-prefill.patch`.

## Delayed rotating prefill: M4 regression

Gemma 4 12B OptiQ 4-bit, snapshot
`5b1101065d2094c8f12aa87fee80e0afa5b292b7`, on the **M4 Pro / 24 GB**.
Bun 1.4.2, MLX 0.32.2, native pack 0.4.0. The control is
`padded-partial-validation`; the candidate is `delayed-padding-validation`.
Both use remote HEAD `0c355f4` plus their recorded working-tree changes.
The production snapshots are respectively
`27b65281f031a4ffc4f7db057a264f32aa8bbfab70bf4c2acb357176148f38b2` and
`89d209400c1f683143ee9afea30e8a440ee00159fe96ba8e1c3bbe5893c744ac`.

Four alternating runs use `bun scripts/bench-serve.ts all`, the exact artifact
above, `--arms mlx-bun --tokens 192 --skip-context --kv-quant 4 --prompt-cache 4
--workload-seed delayed-padding-0 --allow-cpu-process /usr/libexec/audiomxd`.
All preflights pass under the authorized audio-daemon CPU allowance, with fixed
source in each arm and identical workload/runtime settings. All 60 request
bodies, response texts, usage records, token counts and finish reasons match;
the separate parity probes also match. No request or phase failed.

| Arm | Five decode requests, total wall ms | Cached TTFT ms | B4 aggregate tok/s | Ready ms | Cold start ms | Peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|
| Control 1 | 37,952.57 | 154.73 | 72.98 | 608.63 | 1,022.52 | 8,992.91 |
| Candidate 1 | 37,969.02 | 155.03 | 72.85 | 607.89 | 1,024.32 | 8,971.34 |
| Candidate 2 | 38,284.21 | 155.46 | 72.54 | 608.21 | 1,021.92 | 8,982.78 |
| Control 2 | 38,207.34 | 155.07 | 72.90 | 608.12 | 1,023.51 | 8,990.95 |

Candidate means are **0.123% higher decode wall time**, **0.222% higher cached
TTFT** and **0.339% lower aggregate throughput**. Both candidate aggregate
observations are below both controls. These are small unfavorable differences,
not evidence of a speed win. Readiness is in the same 200 ms polling interval;
this Gemma block does not resolve the separate Qwen startup/cached-latency debt.

The change adds delayed rotating-cache preparation and is retained as feature
work. This benchmark exercises current serving, which still prefills requests
separately; it does not measure the future batched-prefill path or establish
serial dominance. Native preparation tests cover mixed-format attention and
encoded state through B8, with the numerical scope documented in batching.md.
Raw records and comparison: `reports/qwen38-closeout/composition-baseline/delayed-padding/`.

## Recurrent padded prefill: M4 regression

Joshs-MBP-2025.local, Apple M4 Pro 24 GB, Bun 1.4.2, MLX 0.32.2/native
pack 0.4.0. Four alternating `bench-serve.ts all` arms use the same packed
Qwen KV4/MTP2, 192-token protocol above. The control includes the adopted
full/rotating KV padding interfaces. Sources remain fixed: control
`5431fdd0f20225e0493b12fb251db0b773f93d6ca92a2a5d09d64882a1161d04`,
candidate `98f5fb5038e3b63f3d1e28a3084f5d1da0a475aa28307761defd26f681e4eb82`.
Every start/end preflight passes with the audio-daemon allowance. All 60
requests match in request hash/body, text, complete usage/speculation counters,
token counts and finish reason. The separate parity probes also match. There
are no request or phase failures.

| Arm | Five decode requests, total ms | Cached TTFT ms | Concurrent aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 55,951.11 | 97.49 | 15.7960 |
| Candidate 1 | 55,713.07 | 97.38 | 15.8332 |
| Candidate 2 | 55,628.97 | 97.20 | 15.9066 |
| Control 2 | 55,639.46 | 98.99 | 15.9824 |

Candidate/control means change decode wall time by −0.223%, cached latency
by −0.964% and aggregate throughput by −0.122%. Candidate aggregate throughput
falls within the control range; cached latency is lower in both candidate arms.
This supports integration as a feature addition with
roughly flat decode/request performance, not a speedup or serial-dominance
claim. Peak RSS ranges from 12,161 to 12,227 MB. Readiness is
608/817/813/612 ms; both candidate observations fall one 200-ms polling
interval later. Cold start is 3,726/4,207/4,200/4,006 ms. Startup equivalence
remains unproven and is not covered by the flat decode conclusion.

This checks existing unpadded serving behavior. Actual padded behavior passes
same-B 27B logit and convolution/recurrent-state oracles on both machines,
including B1 and uniform/unequal B3. MTP, TurboQuant, generated RAM/SSD reuse,
complete suites and typechecks also pass on both Macs. True batched serving
prefill, delayed-codec preparation and long-pressure acceptance remain open.
The recurrent-padding change is adopted in the unreleased working tree.
Evidence: `reports/qwen38-closeout/composition-baseline/padded-ssm/`.

## Packed Qwen serial closeout on M4 Pro

Six balanced v6/v13 pairs on **Joshs-MBP-2025.local, Apple M4 Pro 24 GB**
complete with **114 matching paired requests and no failures**. This uses
Bun 1.4.0, MLX 0.32.2 and the advisory-memory candidate on `0c355f4` plus
its recorded patch. Source snapshot
`e0ebcb3fd1be6024623ffb4db08cdb5b7322a823d43df7ef1e803d11b37131b7`
is unchanged across all twelve runs. The packed interleaved artifact's
20-file manifest hashes to
`24c56033e1ae4c816747f763b76a7420b6327236a3736c2a89462a22e4e512ce`.
Preflight passes under Josh's explicit `/usr/libexec/audiomxd` CPU allowance;
all blocks retain their memory, swap and thermal observations.

| Metric | v6 → v13 or paired factor | 95% block interval |
|---|---|---|
| Decode request wall time | 20.507 → 17.826 seconds pooled median; **1.1504×**, or **13.08% less time** | 1.1493–1.1514× |
| Decode SSE-window rate | 10.026 → 11.593 tok/s pooled median; 1.1562× | 1.1557–1.1568× |
| Cold 1K TTFT | 1.0145× | 0.9997–1.0292×; inconclusive |
| Warm 1K TTFT | 1.0889× | 1.0710–1.1083× |
| Long-prompt TTFT | 1.0039× | 0.9995–1.0083×; inconclusive |
| Four queued requests, aggregate rate | 1.1464× | 1.1457–1.1470× |
| Peak process RSS, inverse ratio | 0.9948× | 0.9755–1.0107×; no demonstrated reduction |

Factors above one favor v13. Intervals resample the six block log-ratios of
within-run summaries, not the individual requests. These describe this
controlled session, not variation across days or p99 latency. Each run has
five 192-token decode requests, cold/warm prefix requests, restart restoration
and the four-request aggregate leg. Actual long prompts contain
10,397–10,399 tokens despite the synthetic `--context 16384` target. Both arms
use serial serving and bf16 KV; output hashes, prompt/output/reused-token
counts and finish reasons match throughout. The aggregate leg is queued
serial throughput, not evidence of simultaneous batch execution.

Final-source native checks also preserve full logits, cache state and
continuation at eight input lengths. Paired MTP-prefix restoration passes with
both bf16 and KV4 storage. Continuous and combined paired results follow below;
broader composed/pressure acceptance remains open; **no default is promoted by this serial result alone**.
Raw bundle: `reports/qwen38-closeout/m4-v6-v13-b{0..5}-v{6,13}.md.json`;
review and offline HTML: `m4-v6-v13-review.json`,
`m4-v6-v13-comparison.html`. Native evidence: `m4-final-native-runner.json`
and `m4-final-v13-*.log` in the same directory.

Six balanced longer-context continuous-serving pairs now pass on the same
M4 Pro, artifact, Bun/MLX versions and CPU allowance above. All 114 paired
requests match with no failures. Each run uses 256-token decode requests and
actual long prompts of about 20,717 tokens. The frozen source snapshot is
`363f74acc1e432677bfe333eec001c9111a1fb2c10128603409568f86dad58bb`.
The paired decode request-time factor is 1.15235×, or 13.22% less time,
with a 95% block interval of 1.15164–1.15316×. Four-request aggregate
throughput improves 2.37742×, with a 95% block interval of 2.37615–2.37856×.
These are same-session intervals, not across-day or sustained-load results.
Raw reports and review are
`reports/qwen38-closeout/m4-final-continuous-b{0..5}-v{6,13}.md.json`
and `m4-final-continuous-review.json`.

All six serial KV4 plus two-token MTP pairs with paired RAM prefixes now
pass, with all 114 paired requests matching and no failures. Source, host,
artifact and qualification match the longer-context continuous series above.
The paired decode request-time factor is 2.15832×, or 53.67% less time,
with a 95% block interval of 2.15467–2.16129×. Aggregate queued throughput
improves 2.07990×, with a 95% block interval of 2.07838–2.08162×. At long
context, decode SSE-window throughput improves 2.03668× and first-token time
improves 1.03885×. These compare kernel variant 13 with variant 6 while keeping
KV4 and MTP enabled in both arms; they do not isolate the benefit of MTP or
compare KV formats. All twelve restart requests reuse zero tokens: paired MTP
prefixes are RAM-only, so this is fresh-prefill restart measurement, not SSD
restoration. Raw reports and review are
`reports/qwen38-closeout/m4-final-kv4-mtp-b{0..5}-v{6,13}.md.json`
and `m4-final-kv4-mtp-review.json`. These measured settings are now selected in
the unreleased candidate source as documented in server-config.md; changing
default selection does not complete output-cache or execution consolidation.

The saved Kanban first-turn audit finds 50,479 reasoning tokens shared with
the next request beyond the original 2,550-token prompt. The following prompt
has 53,175 tokens. This is an offline tokenizer/template comparison, not a
performance measurement: no generated-state checkpoint has yet been accepted
for this saved long turn, and no saved time is claimed for it. Evidence:
`reports/qwen38-closeout/r17-first-tool-prefix-opportunity.json`.

## Running the benchmark

`bun scripts/bench-serve.ts all` is THE benchmark — one pass, real servers,
real paths, every number that matters. Per model × arm (mlx-bun@defaults ·
mlx-bun `--batch 1` [the control arm — `--no-serial` skips] · mlx-lm ·
mlx-bun-mixed · optiq-mixed) it measures decode tok/s (five fixed samples,
all retained; unstable runs flagged), TTFT cold (~1k, nonce-busted) and warm/cached (each stack's own
prompt cache), prefill tok/s, long-context prefill/TTFT/decode (ONE measured
prefill; decode sampled on 64 tok + 2 cached repeats), aggregate tok/s at 4
concurrent streams, peak RSS (sampled; undercounts GPU), and load→ready time.
The same cells compare decoded text from greedy probes of up to 64 tokens
between stacks of the same scheme, including the serial control vs mlx-lm.
Prompt-count inequality rejects a comparison as template/tokenizer drift;
matching counts and text are a smoke check, not proof of identical token IDs
or logits. Missing usage cannot produce a passing verdict. The engine's
pinned logit oracle remains the correctness gate.

```sh
bun scripts/bench-serve.ts all                       # cpm5 + e4b + 12B + Qwen3.8-27B, all arms
bun scripts/bench-serve.ts all --no-serial           # skip the --batch 1 control arm
bun scripts/bench-serve.ts all --models cpm5,qwen27b # subset
bun scripts/bench-serve.ts all --skip-context        # drop the long-context leg
bun scripts/bench-serve.ts all --context 8192        # shorter context leg
```

For an exact local quant use `--model-path <dir>` and optionally `--label`.
It replaces the registry selection and cannot be combined with `--models`.
`--dry-run` prints artifact metadata and server commands, with no preflight,
model load, database write or server process. Packed trellis skips stock
mlx-lm/optiq arms; explicitly requesting those arms fails before starting a
server. A fake-quant/8-bit carrier is a separate artifact and cannot establish
same-artifact packed performance or decode parity.

```sh
bun scripts/bench-serve.ts all --model-path /path/to/quant --label qwen38-quant --dry-run
bun scripts/bench-serve.ts all --model-path /path/to/affine --arms mlx-bun-serial,mlx-lm --context 4096 --out reports/affine-h2h.md
bun scripts/bench-serve.ts all --model-path /path/to/packed --arms mlx-bun-serial --context 4096 --out reports/packed-baseline.md
bun scripts/bench/model-inventory.ts /path/to/affine /path/to/packed > reports/model-inventory.json
```

`--workload-seed <block-id>` generates identical nonce-prefixed prompts for
every engine and artifact in that block, with distinct nonces for retries.
`--logprobs` and `--top-logprobs N` apply capture settings to every timed
request, including concurrent requests, and record them in the workload and
request hashes. SSE timing measures capture cost; wire-level logprob values
are checked separately by the native/HTTP composition tests.
Thinking is pinned on for all chat measurements. Long-context filler uses a
fixed character estimate so token-count drift cannot silently change the
input on one engine. Record actual token counts and compare raw request hashes.
Use phase/attempt/index to distinguish a cold request from its identical warm
repeat; request hashes alone do not identify cache state.
For paired trials, alternate `--arms mlx-bun-serial,mlx-lm` and the reversed
order across blocks; give every block its own seed and `--out` path.

Configured engine experiments accept `--draft-model`, `--draft-kind`,
`--num-draft-tokens`, `--kv-quant`, `--prompt-cache` and `--adapter`. These options
require explicit `--arms mlx-bun-serial,mlx-bun` (or either engine arm); run
oracle controls separately. Both selected engine arms receive identical overrides.
The dry-run, raw JSON and Markdown report retain the settings and relevant
runtime overrides. No script under `reports/` is required to launch them.
For the current packed Qwen artifact on the M4 Pro, run this after closing
other workloads. It exercises the opt-in KV4/MTP/paired-prefix configuration
through the current checkout and writes a new dated report under `reports/`.

```sh
MLX_BUN_TRELLIS_VARIANT=13 MLX_BUN_QWEN_SPEC_KV4=1 MLX_BUN_MTP_PROMPT_CACHE=1 MLX_BUN_RD_PREFILL_CHUNK=256 \
bun scripts/bench-serve.ts all \
  --model-path "$HOME/models/Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd" \
  --arms mlx-bun-serial \
  --draft-model "$HOME/models/Qwen3.8-27B-MTP-folded-rtn4-g64-rd" \
  --draft-kind mtp --num-draft-tokens 2 --kv-quant 4 --prompt-cache 4 \
  --context 4096 --tokens 192 --workload-seed pr47-block-0
```

Append `--dry-run` to inspect the command first. This serving suite is separate
from the Luke Kanban task and does not establish its task-time speedup. This
entry point writes Markdown plus the `<report>.md.json` companion; the offline
HTML comparison report renders from saved companions:

```sh
bun scripts/bench/report.ts reports/a.md.json reports/b.md.json --out reports/compare.html
bun scripts/bench/report.ts reports/a.md.json reports/native-bun.json --out reports/compare.html --baseline mlx-bun-serial
```

Use `--baseline mlx-bun-serial --baseline-env MLX_BUN_TRELLIS_VARIANT=6`
to compare environment-selected variants of that same arm. The selected
setting stays visible in both serving tables; the usual identity and workload
requirements still apply.

Inputs are auto-detected: bench-serve schema-4 `<report>.md.json` files and
`scripts/bench/native.ts` `native-inference-diagnostic` JSON. Rendering reads
the saved JSON only — no weights, server, GPU, Python or network. The single
self-contained file shows a provenance panel per input (file sha256, machine
string, commit, Bun, runtime overrides, source snapshot hashes, server
commands, workload seed, thinking mode), a per-machine serving matrix with a
status on every cell (measured, recovered on retry, failed with the phase
error, not-measured, or unsupported with the reason), correctness flags beside
the timings (finish-reason mix, actual vs requested output counts, early EOS,
warm/restart cached-token counts, durability, request errors, retries, parity
verdicts), ratios only against a baseline arm on the same machine key,
artifact and workload (`--baseline mlx-lm|mlx-bun-serial|mlx-bun`; default
mlx-lm when present), per-machine comparison columns, decode-sample strips,
an RSS-versus-decode plot, a native token-identity table, and the retained
failures, stderr tails and raw request table. "decode" stays the SSE-window
rate and "actual output / wall" the completion-token rate; RSS is process
RSS from `ps`. The paired uncertainty table groups fixed-source trials across
workload seeds and gives a 95% percentile-bootstrap interval for the geometric
mean of block ratios. It resamples block log-ratios, requires at least five
distinct seeds and ignores duplicate seeds. Its baseline is fixed when the
report is generated. Quality-versus-size renders "not measured" until a quality
input exists.

Request-derived speed ratios require matching request hashes, attempts, full
output hashes, prompt/output and reused-token counts, and finish reasons. A mismatch keeps the
absolute timings visible and suppresses the ratio. Full output hashes survive
fixture trimming. Retry summaries use the final attempt; earlier samples and
failures remain in the raw table. Diagnostic, nonquiet and changing-source
runs cannot earn speed ratios. Cross-file comparisons require a recorded
hostname, matching artifact path/config and the complete workload definition;
matching config files alone do not establish matching weights. New serving
companions record hostname and OS. Old files with no hostname compare only
within their own file. Displayed ratios are ratios of medians, not paired
confidence intervals or default-promotion evidence.

The bounded M1 Max smoke of this path uses MiniCPM, 16 requested decode
tokens, `--skip-context`, and the unsplit reference. Both real-server arms
complete without failed phases on fixed source. Warmup, the parity chat,
five decode requests and the cold/warm 1K requests match full output hashes
and reused-token counts. Concurrent four-request outputs still differ.
Short decode timings are unstable; the run is explicitly diagnostic and
cannot supply speed ratios or M4 acceptance. Raw data and review:
`reports/qwen38-closeout/serve-smoke.md.json` and `serve-smoke-review.json`.
The offline `comparison.html` includes this run beside both machines' saved
evidence. Automated rendering/escaping checks pass; browser URL policy
blocked visual inspection of the local HTML file.

`--reference-prefill server` keeps stock MLX-LM system/thinking segmentation
and is the default. `--reference-prefill unsplit` selects an explicit Python
reference control that passes one whole-prompt segment to BatchGenerator,
which still reserves the final token. Tokenization, model operations,
sampling and HTTP handling remain in the pinned reference. This changes
prefill and cache policy and is recorded in commands, workload identity and
the Markdown report. It applies to the `mlx-lm` arm, including models that
need OptiQ registration. Use it only where it matches the Bun request's
boundaries; it does not promise matching arbitrary multi-turn snapshots.

```sh
bun scripts/bench-serve.ts all --models cpm5,qwen27b --arms mlx-bun,mlx-bun-serial,mlx-lm --reference-prefill unsplit --out reports/matched-prefill.md
```

For an exclusively allocated GPU, `--allow-cpu-process /absolute/command`
permits one explicitly reviewed background command to exceed the CPU
threshold. The exact command and observed activity remain in the raw
preflight snapshots and the report names the allowance. RSS, swap, thermal
and overall-load checks still apply. This is not proof of an idle GPU or
stable timing: verify GPU ownership and compare alternating repeated runs.
Josh authorized this policy for `/usr/libexec/audiomxd` on the M4 Pro;
CPU activity alone no longer blocks this campaign. Earlier diagnostic
runs keep their original classification.

`--diagnostic` explicitly permits a loaded-machine serving run. It records
the preflight snapshot and writes `*-serve-diagnostic` DB rows, which cannot
serve as canonical results. Server children use the invoking Bun executable,
so an isolated runtime comparison actually changes the server runtime too.

The Markdown report has a `<report>.md.json` companion containing all chat
requests, results, failures and retries, plus config/source-diff hashes and
server commands. Schema 4 also hashes a sorted manifest of tracked and
untracked source files at startup and save time, so new local kernels cannot
escape source identity. External native libraries and weights need their own
manifests. Failed attempts include the child's stderr tail and process
status; a successful retry keeps the recovered failure visible. It is saved
after each completed or failed cell. The report
separately records total request wall time and actual-output throughput.
The decode columns use the first-to-last visible SSE interval: bursty chunks
can distort that interval, so it is not a GPU timing. Token throughput requires
valid server usage; chunk counting is no longer a fallback. Raw results also
record response-header, first-byte and first-SSE-event latency, then every
content/reasoning/tool-output event arrival. Event gaps measure stream
delivery, not individual token latency. Tool-only streams have an output TTFT.
Malformed/error SSE and responses without a finish reason or `[DONE]` fail
the measurement. Match output counts, finish reasons and text before
interpreting a speed difference. The exported `measureCompletionRequest`
helper applies the same timing and stream-validation contract to raw
`/v1/completions` requests, without chat-template preparation.

The inventory reads shard headers and config only, reconstructs matrix
shapes including trellis axis-0 storage, and counts actual tensors rather
than duplicate config aliases. Its matrix effective-bpw figure includes
scales/biases but excludes norms, convolutions and sidecars; it is explicitly
not whole-model bpw or peak memory. Config/index/layout hashes do not hash
weight payloads. Use existing shard hashes or hash weights outside timed runs
when certifying artifact identity. The complete Qwen campaign is in
[the performance program](../../design/decode-speed-program.md#7-qwen38-27b-research-program).

For native engine isolation, `scripts/bench/native.ts` runs dense Qwen3.5/3.8
with bf16 attention KV, f32 recurrent state and greedy decoding. Supply a
frozen JSON array of prompt token IDs and the exact local artifact to both
stacks. Each request starts with a fresh cache; warmups and every measured
sample are retained. Reports include actual output IDs, EOS policy, TTFT,
wall time through cache cleanup/GPU synchronization, memory and source pins.
They record the effective wiring policy and active/cached memory around each
request. The oracle worker enters mlx-lm's normal scoped wired limit; compare
that policy with Bun's model-sized scope before interpreting a ratio.
`--clear-before-request` is a separate allocator-cache experiment on both
stacks, with cleanup included in wall time. Keep it fixed within a pair;
it does not clear model weights or substitute for a fresh inference cache.
Stock mlx-lm rejects packed trellis. This worker uses the pinned oracle
environment and never starts a server or downloads a model.

```sh
bun scripts/bench/native.ts --model-path /path/to/affine --prompt-ids reports/prompt-ids.json --stack mlx-bun --json reports/native-bun.json --dry-run
bun scripts/bench/native.ts --model-path /path/to/affine --prompt-ids reports/prompt-ids.json --stack mlx-lm --json reports/native-oracle.json
```

Alternate stack order across predeclared process pairs. Check token IDs,
output counts and finish reasons before comparing request wall times.
`--diagnostic` permits a failed quiet-machine preflight and records that
failure. Native results remain diagnostic, including on a quiet machine;
they do not establish HTTP throughput, task quality or full logit parity.
The repaired legacy `bench-h2h.ts direct` command delegates to this worker,
requires `--models` and bf16 KV, and writes only `*-native-diagnostic` DB
rows with raw report paths. Its rates use actual emitted tokens and all
fixed samples. Use the worker directly to avoid registry ambiguity.

`all` runs the clean-machine preflight first (refuses headline numbers from
a loaded or swapped box) and holds `caffeinate` for the pass. Quotable
numbers and ratios need a quiet machine; loaded runs are diagnostic only.
Results land in the eval DB (`~/.cache/mlx-bun/evals.sqlite`) plus dated
Markdown and JSON reports under `reports/` by default. Developer lever A/Bs are NOT benchmarks — run
`scripts/bench-levers.ts <faithful-matrix|fused-prefill|compiled-decode>` or
`scripts/bench-matrix.ts <modes|features>` directly when touching those paths.

There are **three categorically different kinds of measurement** — kept in
separate sections because they answer different questions:

1. **Parity** — are we *bit-exact* with the upstream oracle? (pass/fail)
2. **Performance** — *numbers* under like-for-like config (tok/s, memory…).
3. **Quality** — for non-bit-exact optimizations, what does the speed cost
   in output quality? (6-test mean + KL)

**Default machine for older rows:** Apple M4 Pro, 24 GB unified
(`Joshs-MBP-2025`), ~273 GB/s. Newer subsections name their machine explicitly.
**Oracle toolchain:** Bun 1.3.14; Python 3.13.5 with mlx 0.31.2,
mlx-lm 0.31.3, mlx-optiq 0.2.1. Numbers below are the 2026-06-14
cleared-machine run (commits `97457e4` / `d1e0296`), preflight-gated,
median-of-N with warmups discarded.

**Model legend** (registry hash → repo):

| hash | model |
|---|---|
| `664aabaed233` | `MiniCPM5-1B-OptiQ-4bit` (sub-GB starter) |
| `fcdb12d740cd` | `gemma-4-e4b-it-OptiQ-4bit` |
| `5b1101065d20` | `gemma-4-12B-it-OptiQ-4bit` |
| `dbfd2a779b03` | `gemma-4-26B-A4B-it-OptiQ-4bit` (MoE) |

> **Legend corrected 2026-06-15.** An earlier revision had the gemma
> hashes cycled (`5b…`→e4b, `dbfd…`→12B, `fcdb…`→26B). The mapping above is
> the authoritative one from `tests/support/paths.ts` (`SNAPSHOT`=`5b…`=12B,
> `SNAPSHOT_26B`=`dbfd…`=26B) and the e4b snapshot hash used across
> `tests/*.test.ts` (`fcdb…`=e4b), corroborated by on-disk weight size
> (e4b 7.0G · 12B 8.4G · 26B 18G). The **Performance** rows below were
> labeled by the old legend; each gemma row has been relabeled to its true
> model, re-identified by its gen-peak / steady-RSS fingerprint —
> e4b≈6.6 GB, 12B≈9.0 GB, 26B≈17.7 GB — which is stable across runs. The
> row *data* was correct; only the model labels moved.

---

## 1. Parity (porting correctness) — bit-exact vs the oracle

Parity results moved to the [current benchmark reference](../../reference/benchmarks.md).

### GLM-5.2 direct-Colibri oracle closure — M1 Max 32 GB

The direct-container port uses pinned Colibri, rather than mlx-lm, as its
implementation oracle. The public artifact is
`mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp@3cc8db9`; direct component and
G0 controls use Colibri `44e489b`, while the later official DSA replay is
pinned to `ecade075` with indexers sourced from
`zai-org/GLM-5.2-FP8@ba978f7d`.

| gate | result | durable proof |
|---|---|---|
| tiny converted Q4 trajectory | 32/32 greedy tokens exact with `IDOT=0`; all 8,192 logits max abs `1.3113e-6`, RMSE `2.7423e-7` | `fixtures/colibri-glm52/tiny-teacher-forcing.json` |
| production Q4/router cells | layer-0 SwiGLU max abs `5.2387e-9`; layers 3/77 exact ordered top-8 | `fixtures/colibri-glm52/production-probe.json` |
| real-model oracle | 140 GLM/MLA/router/MTP/KV records reproduced byte-for-byte twice; both heads predict teacher token 16 | `fixtures/colibri-glm52/real-model-oracle.json` |
| full target trajectory | all 128 cold/warm, MTP-on/off target token IDs identical; first 64 also match direct Colibri | machine-local `runs/colibri-g5/summary.json` |
| first-sparse DSA | all 21 official score rows replay to exact ordered positions and float32 thresholds at context 2,049; both engines emit `[264,264]` | `~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/` |

These are quality-preserving gates: checkpoint precision, true top-8 routing,
and the 21-full/57-shared DSA schedule remain unchanged. Consequently there is
no KL/eval tradeoff row in section 3 for this path.

**Served-surface parity (2026-07-07, prefill tail-split fix):** the two
serve-bench parity residuals (cpm5 + 12B `/v1/completions` probe ✗ on the
07-07 run) are closed — with the oracle's step-0 prefill convention
adopted (drain to len−1, step 0 from an L=1 forward of the last prompt
token; `MLX_BUN_PREFILL_TAIL_SPLIT`), live HTTP probes are
**byte-identical** to `mlx_lm.server`/optiq serve for MiniCPM5-1B,
gemma-4-e4b, AND gemma-4-12B, on completion + chat probes, in both the
unified (`--batch 8` default) and `--batch 1` lanes; script-level A/B
shows 64/64 token ids + top-2 logprob values identical per step
(`serve-parity-probe.ts (deleted; git history)`,
`step0-top2-dump.ts (deleted; git history)`).

---

## Methodology change (2026-07-05)

The primary benchmark is now **`bun scripts/bench-serve.ts all` → `scripts/bench-serve.ts`**:
real servers on real paths — the mlx-bun arms spawn the ACTUAL CLI at its
actual defaults (the old harness used a bench-local wrapper, since deleted),
and every metric arrives over HTTP as a user would see it. One server per
cell yields: decode tok/s, cold TTFT (~1k, nonce-busted), warm/cached TTFT
(each stack's own prompt cache), prefill tok/s, long-context
prefill/TTFT/decode (ONE measured prefill; decode sampled on 64 tokens),
aggregate tok/s at 4 concurrent streams, and load→ready time. Context
lengths are recorded from usage.prompt_tokens (measured, not requested).
Engine-level questions (in-process kernel parity, gen-peak memory,
kill-switch A/Bs) live behind `bun scripts/bench-serve.ts all --engine`. Numbers below this
note predate the redesign; the next quiet-machine pass supersedes them.

## 2. Performance — like-for-like numbers

Two comparison axes: **vs the oracles**, and **our optimized path vs our
own bit-exact compat path** (does an optimization beat the baseline it
diverges from). Within mlx-bun, `bf16` is the L1-compatible path and
`mixed` is the L2-compatible path; both are bit-exact, so the bf16↔mixed
delta is the first "our-vs-our" axis. Lab experiment rows (no external
oracle; KL/eval-gated) land here once one beats the L1 baseline in a
paired A/B — none recorded yet (the 2026-07-05 candidates were deleted).

### Default batched h2h without serial controls — M4 Pro (2026-09-11)

Default batched h2h moved to the [current benchmark reference](../../reference/benchmarks.md).

### Released v0.4.0 packed Qwen with KV4/TQ and MTP2 — M4 Pro (2026-09-11)

Packed Qwen cache comparison moved to the [current benchmark reference](../../reference/benchmarks.md).

### Released v0.4.0 standard registry comparison — M4 Pro 24 GB (2026-09-11)

Released standard registry comparison moved to the [current benchmark reference](../../reference/benchmarks.md).

### Standard serve matrix — M4 Pro 24 GB (2026-09-08, incomplete acceptance)

Josh ran `bun scripts/bench-serve.ts all` at clean commit `86738ac` on
`Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, Bun 1.4.0, with the matching
MLX 0.32.2 reference. Quiet preflight passed. There were no runtime overrides;
the workload used `bench-serve-v2`, thinking enabled, five 192-token decode
requests and a requested context target of 16,384. The actual context probes
contained 9,062 MiniCPM tokens and 9,589 Gemma tokens. This is one ordered
suite, not an alternating before/after optimization comparison.

| Model | Default mlx-bun decode tok/s | mlx-lm decode tok/s | Default mlx-bun request time | mlx-lm request time | Request-time reduction |
|---|---:|---:|---:|---:|---:|
| MiniCPM5-1B | 278.65 | 223.55 | 0.710 s | 0.936 s | 24.2% — output mismatch |
| Gemma4-e4b | 57.86 | 53.63 | 3.402 s | 3.810 s | 10.7% |
| Gemma4-12B | 26.14 | 25.40 | 7.576 s | 7.969 s | 4.9% |
| Qwen3.8-27B 4/8-bit winner | 14.75 | 14.19 | 13.814 s | 14.523 s | 4.9% — output mismatch |

The table uses medians of the same five requests, all with exactly 192 output
tokens. Request hashes, input/output counts and cached-token counts match
between these arms. Both Gemma models also match all five timed output texts
and both short parity probes. MiniCPM and Qwen differ on all five timed
outputs despite matching counts; Qwen's separate 64-token probes match, while
MiniCPM's chat probe diverges. Their timing rows remain observations pending
the exact-token/logit investigation. The Gemma12B reference command invokes
OptiQ's model registration before its mlx-lm serving path.

For Gemma e4b, cold/cached TTFT is 559/72 ms versus 707/212 ms in the
reference, and the approximately 1K prefill estimate is 1,199 versus 947
tok/s. For Gemma 12B those values are 2,531/157 ms versus 2,677/333 ms and
265 versus 250 tok/s. The serial controls finish the same short requests in
3.360 s and 7.514 s, respectively. Cached TTFT is one warm sample per cell.

Acceptance is incomplete. Qwen hits Metal out-of-memory errors in both the
approximately 1K and context phases, in default and serial serving. Its
reference recovers an initial 1K timeout, then fails the context phase and
skips concurrency. MiniCPM and Gemma12B each report missing SSD snapshots on
the first restart-flush attempt in default and mixed serving; retries succeed.
Mixed-KV rows are not compared for L1 identity against bf16 KV. The complete
report retains eleven phase-failure records, including recovered failures.

The Qwen artifact is the registry's 4/8-bit winner, not the required 12.14 GiB
packed Trellis target. No MTP draft was configured. These numbers neither
replace the Trellis/KV4/MTP measurements nor establish a Kanban task-time gain.
Raw evidence: `reports/benchmarks-serve-2026-09-08-Joshs-MBP-2025.md` and its
`.md.json` companion; source hashes are unchanged across the run.

The SSD follow-up at `f144516` fixes flush ordering: an ancestor removed from
RAM can be covered by a longer trimmable snapshot written later in that same
flush. After all writes settle, the coordinator checks committed coverage
again and keeps uncovered prefixes dirty. The regression fails before the
change and all 29 SSD tests pass afterward. The same M4 Pro repeats pass all
phases on the first attempt for MiniCPM and Gemma12B in both default and mixed
serving, restoring 9,061 and 9,588 tokens after restart. Source hashes stay
fixed in both repeats. Default-arm timed request hashes and all ten output
texts match the original run. The original failure records remain intact;
this follow-up does not resolve their separate cross-oracle output differences.
Evidence: `reports/qwen38-rd/pr47-ssd-followup.md.json` and
`reports/qwen38-rd/pr47-ssd-followup-mixed.md.json`.

The subsequent boundary investigation identifies the timed-output difference
on MiniCPM and Qwen. For each model's first saved request, Bun and Python match all 192
complete native logit vectors. Stock Python HTTP instead splits at the
thinking marker: MiniCPM uses prefill lengths 29, 1, 1 instead of 30, 1;
Qwen uses 75, 1, 1 instead of 76, 1. Those segmented native Python runs
reproduce the original reference responses after HTTP thinking-tag removal.
The explicit unsplit reference control then reproduces all ten saved Bun
decode responses, with identical output counts and finish reasons. Request
hashes match. The first MiniCPM replay reuses zero tokens versus four in the
original run; the other nine cache counts match. These are M4 Pro correctness
diagnostics, not a replacement timing cohort or a speed claim. Qwen's Metal
prefill failures and quiet paired timing acceptance remain open. Evidence:
`reports/qwen38-closeout/prefill-segmentation-review.json` and its hashed
native/HTTP companions. The initial invalid-model-ID replay is retained on
the M4 Pro as `cpm5-replay-invalid-model-id.json`.

The Qwen memory follow-up on the same M4 Pro distinguishes a fresh-process
control from the suite's retained state. The saved “1K” request actually has
757 prompt tokens and succeeds after a fresh warmup. Replaying the preceding
warmup, completion/chat parity probes and five decode requests with SSD cache
enabled reproduces the Metal OOM on the original source. An isolated
per-layer prefill-evaluation prototype passes the fresh control; its full
history replay completes warmup and the raw completion probe, then times
out before the parity chat finishes. SSH subsequently became unavailable
and recovered without a reboot. The timeout has no resolved cause, and the
prototype is not integrated. Raising the fit estimate alone does not resolve
the observed OOM. Local fresh controls and recovered history trials are
`reports/qwen38-closeout/qwen27b-memory-{server,barrier}-{fresh,history}.json`;
the M4 keeps the history trials under the unsuffixed names. Preflight still
rejects retained swap. No speed or memory improvement is accepted from
these trials.

After the M4 reboot and unlock, the frozen candidate still fails the 1K
prefill phase on both attempts. Layer evaluation gets all four cold/warm 1K
requests through with the seven preceding outputs and usage unchanged, but
four-request serving then fails with a Metal OOM. Reserving successor state
for all batch rows gets all 15 requests through. Both changes are now in the
working candidate. Twelve same-version oracle cases (prefix lengths 0/64,
forward lengths 1/4/8/16/128/757) preserve complete logits, recurrent state
and continuation exactly. A longer replay completes 38 requests across
continuous and serial serving, including a 2,679-token context and SSD
restart restoring 2,678 tokens. All 15 individually issued requests match
across lanes in output and usage; the four concurrent responses differ and
are excluded from cross-lane speed comparisons.

These remain correctness diagnostics under their original run policy.
A subsequent control removes per-token memory polling from continuous
decode and reserves at batch joins. It completes 19 requests with a
5,239-token context and restores 5,238 tokens from SSD. The integrated
reservation also accounts for cache growth to the requested output caps;
its repeat preserves all 19 request identities, outputs and usage counts.
Josh then clarified that the isolated audio CPU load is acceptable with
memory and GPU availability; new acceptance runs record the explicit
allowance described above. Earlier diagnostics are not relabeled.
Evidence under `reports/qwen38-closeout/`:
`m4-{candidate,layer-eval,layer-batch}-memory.md.json`,
`m4-memory-review.json`, `m4-layer-state-{bun,reference,review}.json`,
`m4-memory-context{.md,-review}.json`,
`m4-{join-only,reserved-growth}-memory.md.json` and
`m4-join-reservation-review.json`; artifact hashes are in
`m4-candidate-preparation.json`. No speed default is promoted.

The first CPU-allowance R0 block (same M4 Pro, candidate on `0c355f4`,
Bun 1.4.0, MLX 0.32.2, stock GPU ceiling, explicit unsplit reference)
passes preflight before and after on fixed source. All five decode requests
match across continuous Bun, serial Bun and Python in complete output,
prompt/generated/reused tokens and finish reason. Within-arm decode spread
is 0.49%, 1.05% and 0.78%, respectively; this is one block, not a paired
speed verdict. Continuous serving completes all phases. Without the earlier
context leg's server restart, serial serving fails the fourth queued request
with Metal OOM. Python's 1K timeout and final aggregate failure also contain
Metal OOM tracebacks, at prompt-state evaluation and pipelined decode.
The earlier longer replay therefore does not close retained-history pressure.
A focused allocation trace reproduces the fourth-request failure with
18,783,888,604 active bytes, a four-byte allocator pool, 2,485,518,336 bytes
of RAM prefixes and a 199,133,984-byte reservation against the
19,069,665,280-byte GPU ceiling. The pool is not the missing memory; the
remaining 86,642,692 bytes do not establish room for overlapping asynchronous
state updates. A two-successor boundary reservation then completes all 30
requests across both Bun lanes without failures. The 29 successful requests
from R0 match output and usage; the formerly failed serial request matches
the earlier context/restart control. Full-output reservation and longer
generation are the next gates. Evidence:
`m4-serial-allocation-probe.md.json`, `m4-serial-allocation-review.json`,
`m4-two-state-memory.md.json` and `m4-two-state-memory-review.json` in
`reports/qwen38-closeout/`.
Raw: `reports/qwen38-closeout/m4-r0-audio-allowed-01.md.json` and
`m4-r0-audio-allowed-01-review.json`.

### Fresh Kanban candidate generation — M4 Pro (2026-09-09)

The frozen optimized candidate completed the pinned Luke Kanban prompt on
Joshs-MBP-2025.local (M4 Pro 24 GB, Bun 1.4.0, MLX 0.32.2, Pi 0.85.1)
in **5,085.387 seconds (1h 24m 45.387s)** from prompt submission to completion.
It generated 68,958 output tokens across 15 requests, with zero Pi retries,
compactions or tool errors. Pi and the server exited zero; the outcome parser
confirmed completion, profile requests were valid, and source hashes stayed fixed.
The run used packed interleave2, variant 13, KV4, MTP depth 2 and paired RAM
prefixes, with the authorized audio CPU allowance. R17 generated-history
checkpointing was not implemented in this candidate.

The untouched generated app passes all 18 required browser acceptance categories,
including native card/column dragging, combined filters, archive/restore,
keyboard operation and persistence in both themes. Source hashes are unchanged. The earlier successful task generated a different number of tokens
and tool turns, so this duration does not establish an engine-only speedup.
The first/new runs used 75/21 tool calls, 7/0 tool errors and 1/0 compactions.
Summed pre-first-output time is 3,399.895/814.988 seconds. New task time is
60.2% lower and output count 47.2% lower, without an engine-only attribution.
The sole initial-request difference is Pi's working-directory suffix:
`kanban-final-workspace` versus `kanban-closeout-candidate-r1-workspace`,
verified as five additional tokens by the model tokenizer. Both used batch 1
and MTP depth 2. Detailed acceptance and comparison:
`reports/qwen38-closeout/kanban-run-comparison.md`; raw evidence:
`reports/qwen38-closeout/kanban-final-candidate-r1/`.

### Direct scheduler B=1 versus serial — both machines (2026-09-08)

Josh's September 8 standard suites include both default scheduling and strict
serial controls. M1 Max 32 GB used clean commit `1ac8f61`; M4 Pro 24 GB used
clean commit `86738ac`. Both used Bun 1.4.0, no runtime overrides, and passed
quiet preflight. Compare arms within each machine; the machines have different
source commits. These are single ordered suites, not alternating repeat blocks.

Median short-decode SSE rates from five 192-token requests per arm:

| Model | M1 default / serial tok/s | M4 default / serial tok/s |
|---|---:|---:|
| MiniCPM5-1B | 268.79 / 267.81 | 278.65 / 275.86 |
| Gemma4-e4b | 63.85 / 64.01 | 57.86 / 59.03 |
| Gemma4-12B | 30.33 / 30.33 | 26.14 / 26.44 |
| Qwen3.8-27B 4/8-bit winner | 18.58 / 18.56 | 14.75 / 14.66 |

All 40 paired timed responses match between default and serial in request hash,
output text, prompt/cached/generated token counts, finish reason and DONE status.
Completion and chat parity probes also match for all eight model/machine cells.
This comparison is between our two executors; it does not erase the separate
Python-reference differences recorded in the M4 section above. Default B=1
short-decode rates are within 0.4% of serial on M1 and within 2.0% on M4.
The M1 suite has no phase failures. The M4 suite retains its recorded SSD retry
and Qwen prefill OOM failures; short-decode agreement is not whole-suite acceptance.

The M1 four-request aggregate rates, default versus serial, are 408.12/243.14
(MiniCPM), 101.60/60.91 (e4b), 41.32/27.95 (12B), and 20.08/15.72 (Qwen),
in tok/s. These measure aggregate throughput, not single-request latency.
The results support sharing a scheduler with a B=1 case; they do not establish
feature completeness for replacing the dedicated executor, including MTP.
Raw reports: `reports/benchmarks-serve-2026-09-08-Joshs-MacBook-Pro.md.json`
and the M4's `reports/benchmarks-serve-2026-09-08-Joshs-MBP-2025.md.json`
(local preserved copy: `reports/qwen38-closeout/m4-standard-20260908-original.json`).

### Batched logprob composition — M4 Pro, acceptance open (2026-09-09)

Two ordered/reversed `bench-serve.ts all` blocks use the packed interleave2
Qwen artifact on Joshs-MBP-2025.local, M4 Pro 24 GB, Bun 1.4.0 and MLX
0.32.2. Both pass preflight with the authorized audio CPU allowance. The
frozen sampler candidate uses selected logprobs plus top-3 capture, unchanged
kernels, five 192-token decode requests and the short-context suite with SSD
caching. Its source predates the subsequent explicit-seed placement change;
these benchmark requests have no explicit seed. Neither block has a failure.

| Block/order | Median decode request ms, serial / batch B=1 | Cached TTFT ms, serial / batch B=1 | Cached request ms, serial / batch B=1 |
|---|---:|---:|---:|
| 0, serial then batch | 17,833.47 / 17,785.57 | 261.16 / 307.45 | 800.68 / 846.69 |
| 1, batch then serial | 17,840.70 / 17,771.87 | 272.90 / 319.81 | 812.66 / 858.99 |

All 22 single-request pairs match request/output hashes, token counts, finish
reason and DONE status. Only three of eight concurrent pairs match complete
outputs across serial and batch execution, so their timing does not establish
an identical-work speedup. The cached response regression keeps performance
acceptance open. Existing ordinary-execution M1/M4 baselines above remain valid.

Raw reports and review: `reports/qwen38-closeout/composition-baseline/`
`logprobs-composition-{0,1}.md.json` and `logprobs-performance-review.json`.
A third block enables `MLX_BUN_EARLY_FIRST_TOKEN=1` in both arms using
block 0's requests. Source hashes remain fixed and no phase fails. Serial /
batch B=1 median decode request time is 17,847.38 / 17,782.37 ms, cached
TTFT 194.87 / 242.19 ms, and cached request time 809.63 / 860.77 ms. All
15 within-block response pairs match, including the four concurrent requests.
All 11 single-request outputs also match block 0; two concurrent batch outputs
change with the different admission timing. Early output improves delivery in
both arms but leaves the cached-request regression open. It is not a default
promotion. Raw: `logprobs-early-composition-0.md.json` and
`logprobs-early-performance-review.json` in the same directory.

Bounded P2R diagnostics there separate recurrent-boundary SSD persistence
from output-delivery delay. Traced timings are diagnostic only.

### Shared uniform KV4 composition — M4 Pro, acceptance open (2026-09-09)

One ordered serial/default block uses the packed interleave2 artifact with
uniform KV4, selected logprobs and top-3 capture on M4 Pro 24 GB, Bun 1.4.0,
MLX 0.32.2. Both commands receive identical KV options. Preflight passes with
the authorized audio allowance, source hashes stay fixed, and no phase fails.
Serial / shared B=1 median decode request time is 17,866.95 / 17,814.16 ms;
median SSE decode rate is 11.5556 / 11.5569 tok/s. Cached TTFT is 271.67 /
292.97 ms and cached request time 813.85 / 834.49 ms. The cached latency gap
keeps acceptance open; this single ordered block cannot establish stability.
All 11 single-request pairs match complete responses. Only one of four
concurrent pairs matches, so the aggregate timings do not establish an
identical-work speedup. The frozen candidate includes the shared KV conversion
and uniform placement change; later removal of an obsolete startup warning is
not part of this source snapshot.

Raw: `reports/qwen38-closeout/composition-baseline/`
`uniform-kv4-composition-0.md.json` and `uniform-kv4-performance-review.json`.

### Immutable RAM prefix prototype — M4 Pro (2026-09-09)

The first borrowed-prefix prototype uses the same packed artifact, selected
logprobs/top-3, SSD cache and workload as logprob block 0 above. On M4 Pro
24 GB, Bun 1.4.0, MLX 0.32.2, preflight passes with the authorized audio CPU
allowance. Source hashes remain fixed and no phase fails. Serial / shared
B=1 median decode request time is 17,874.77 / 17,758.63 ms, cached TTFT
256.93 / 168.77 ms and cached request time 796.78 / 707.51 ms.

All 11 single-request pairs match. Every output within each arm also matches
that arm in original logprob block 0. Two of four concurrent pairs match
across arms; aggregate timings do not establish identical-work performance.
This prototype still makes serial requests flush durability before generation.
The later removal of that flush must be measured in both arms before claiming
that shared B=1 dominates the best serial implementation.

Raw: `reports/qwen38-closeout/composition-baseline/`
`borrowed-prefix-composition-0.md.json` and
`borrowed-prefix-performance-review.json`.

### Eventual SSD persistence — M4 Pro, acceptance open (2026-09-09)

The next frozen candidate retains immutable RAM prefixes and removes the
serial request-time durability flush. It uses the same machine, toolchain,
artifact, capture settings and block-0 workload as the prototype above.
Preflight passes with the audio allowance, source hashes remain fixed and
there are no failures. Serial / shared B=1 median decode request time is
17,768.44 / 17,787.02 ms, cached TTFT 163.57 / 168.03 ms and cached request
time 703.55 / 706.67 ms. All 11 single-request pairs match, and every output
within each arm matches original logprob block 0. Two of four concurrent
pairs match across arms.

This removes the large cached-request regression in the earlier logprob
comparisons. One ordered block does not establish that the remaining small
difference is stable or that shared B=1 dominates serial. A subsequent change
makes background writes acquire idle ownership without requesting a batch
drain; its balanced serving comparisons are separate acceptance work.

Raw: `reports/qwen38-closeout/composition-baseline/`
`eventual-cache-composition-0.md.json` and
`eventual-cache-performance-review.json`.

### Idle persistence queue on Bun 1.4.2 — M4 Pro (2026-09-09)

Two ordered/reversed blocks measure immutable RAM reuse, removal of the
request-time flush, and background writes that acquire the engine only when
idle. Both use the packed Qwen artifact, bf16 KV, selected logprobs/top-3,
SSD caching and the same block-0 requests. M4 Pro 24 GB, Bun 1.4.2, MLX
0.32.2; preflight passes under the audio allowance. The source hash is identical
across both blocks and remains fixed; neither block has a failure.

| Order | Median decode request ms, serial / shared B=1 | Cached TTFT ms, serial / shared B=1 | Cached request ms, serial / shared B=1 |
|---|---:|---:|---:|
| Serial then batch | 17,772.00 / 17,750.51 | 163.13 / 167.44 | 703.25 / 706.08 |
| Batch then serial | 17,746.81 / 17,757.96 | 162.87 / 167.51 | 701.86 / 706.03 |

All 22 single-request pairs match complete response identity. Every output
within each arm also matches original logprob block 0. Four of eight concurrent
pairs match across arms, so aggregate timing does not establish identical-work
performance. Decode request time differs by less than 0.13%, while shared B=1
retains a consistent 4.3–4.6 ms cached first-output gap. Strict dominance is
still unproven. The later correction to the batch's reported first-token
clock is not included; these numbers come from client-observed timings.

Raw: `reports/qwen38-closeout/composition-baseline/`
`idle-persistence-bun142-composition-{0,1}.md.json` and
`idle-persistence-bun142-performance-review.json`.

### First-admission device pipeline — M4 Pro (2026-09-09)

The first ordinary row now enters the existing pending GPU-token register,
allowing the next forward to overlap its first readback. This also includes
the corrected first-token metric timestamp. The frozen candidate was measured
in both arm orders on M4 Pro 24 GB, Bun 1.4.2 and MLX 0.32.2, using the same
packed artifact, bf16 KV, logprobs/top-3, SSD and block-0 requests as the
idle-persistence comparison. Both preflights pass with the audio allowance,
source stays fixed across both blocks and no phase fails.

| Arm order | Decode request median ms, serial / shared B=1 | Cached TTFT ms, serial / shared B=1 | Cached request ms, serial / shared B=1 |
|---|---:|---:|---:|
| Serial first | 17,759.74 / 17,745.59 | 163.25 / 163.38 | 703.29 / 701.71 |
| Shared first | 17,754.03 / 17,746.97 | 162.61 / 163.53 | 701.91 / 702.64 |

All 22 single-request pairs match, and every output within each arm matches
the idle-persistence baseline. Four of eight concurrent pairs match across
arms; these do not support an identical-work aggregate speed claim. The
change reduces the prior cached-TTFT gap to 0.12–0.91 ms and is adopted in
the working tree. Shared B=1 does not strictly dominate every measured
latency, and this composition does not close the full feature matrix.

Raw: `reports/qwen38-closeout/composition-baseline/`
`first-row-pipeline-composition-{0,1}.md.json` and corresponding
`first-row-pipeline-composition-{0,1}-review.json`. Both blocks identify source
`5cd1cb0668b743303cd6b05ba8779fd9075280d97585b008ac2da9d03f462c7f`.

### Batched sliding-window correctness — M1 Max and M4 Pro (2026-09-09)

The shared executor passes the live, pinned same-B MLX-LM oracle on Gemma
12B and e4b on both M1 Max 32 GB and M4 Pro 24 GB, with Bun 1.4.2 and
MLX 0.32.2. Each cell compares 48 complete float32 logit vectors exactly.
Three unequal prompt lengths straddle the configured sliding window: two
cross it during decode and one starts beyond it. The two arrival schedules
include staggered retirement and a late join. This closes Phase 18's ordinary
Gemma ring-wrap gate; it does not qualify quantized layouts or other methods.

Raw: `reports/qwen38-closeout/composition-baseline/`
`m1-gemma12b-batch-ring-wrap.log`,
`m4-gemma12b-batch-ring-wrap-complete-inputs.log`,
`m1-gemmae4b-batch-ring-wrap.log`, and
`m4-gemmae4b-batch-ring-wrap.log`. The first M4 launch failed before model
loading because its scratch checkout lacked test support files; the complete
input rerun is the accepted result. No performance conclusion uses test time.

### Compatible adapter groups — M4 Pro (2026-09-09)

Gemma e4b OptiQ snapshot `98d7dc6`, `fixtures/adapters/upper`, bf16 KV and
SSD cache, on M4 Pro 24 GB with Bun 1.4.2 and MLX 0.32.2. The configured
adapter and block-0 requests are identical across the serial and shared arms.
Both arm orders pass preflight with the recorded audio allowance, retain a
fixed source, and finish every phase.

| Arm order | Decode request median ms, serial / shared B=1 | Cached TTFT ms, serial / shared B=1 | Cached request ms, serial / shared B=1 | Observed four-request throughput tok/s, serial / shared |
|---|---:|---:|---:|---:|
| Serial first | 3,654.29 / 3,671.12 | 36.88 / 37.66 | 162.18 / 161.73 | 51.76 / 161.42 |
| Shared first | 3,678.68 / 3,675.22 | 37.58 / 37.96 | 162.13 / 161.98 | 51.82 / 161.27 |

All 22 single-request output/usage pairs match. Six of eight concurrent
pairs match across arms; every output is stable within its own arm across
orders. The concurrent throughput figures therefore are observed workload
results, not an identical-output speedup. Single-request decode changes winner
with order; cached first output remains slightly slower on the shared path.
Strict serial-dominance acceptance remains open.

Native adapter B=1 control, compatible B=2, mixed queues, callback failure,
separate prefix reuse and queued adapter replacement pass on M1/M4. Both
machines match 48 full logit vectors against the pinned same-B adapter oracle.
KV4 plus logprobs also passes the native composition checks on both machines;
this is not an external quantized-batch oracle claim.

Raw: `reports/qwen38-closeout/composition-baseline/`
`adapter-composition-{0,1}.md.json` and
`adapter-composition-performance-review.json`. Frozen source:
`e92487827cbb4755f5bd0cb4880999b2aa1d1aba64a86b7bfc6042b0b458723c`.
Native logs: `m1-batch-adapters-replacement.log`,
`m1-batch-adapter-oracle.log`, `m4-batch-adapters-oracle.log`, and
`{m1,m4}-batch-adapters-kv4-logprobs.log`.


### State-only recurrent replay experiment — M4 Pro (2026-09-09)

Packed Qwen 27B with its folded RTN4 MTP companion, depth four and KV4,
Bun 1.4.2 and MLX 0.32.2 on the M4 Pro 24 GB. Both versions use the same
serial serving control and shared prefill cache. Only recurrent prefix replay
changes. The existing serving suite ran reference/candidate, then
candidate/reference, with matched requests within each block. Preflight passed
under Josh's audio-daemon CPU allowance; raw reports retain `canonical:false`.

| Block/order | Five decode requests, reference → candidate | Sum of four queued request times, reference → candidate | Cached TTFT, reference → candidate |
|---|---:|---:|---:|
| 0, reference/candidate | 135,674.99 → 135,614.72 ms | 176,655.25 → 176,192.41 ms | 94.03 → 94.10 ms |
| 1, candidate/reference | 130,083.45 → 129,893.97 ms | 189,279.10 → 189,066.15 ms | 93.98 → 93.78 ms |

All 30 recorded responses match in text, counts, cached coverage and finish
reason; both completion/chat probes match and no phase failed. The five-request
decode totals improve by only 0.044% and 0.146%. Warmup complete time regresses
in both blocks, by 8.41% and 0.32%. This is **inconclusive for default promotion**.
The independently required batched recurrence can use its row-length-aware
kernel; uniform replay retains its existing kernel pending a demonstrated win.

Raw files: `reports/qwen38-closeout/composition-baseline/`
`state-replay-{reference,candidate}-{0,1}.md.json` and
`state-replay-performance-review.json`. Both sources stay fixed across blocks:
reference `a01bee0b7e1962c8211f1ffd845d95f7923d6c04bddb18cf06f07483cab9e7e8`,
candidate `9ea170f63a70b143a978fd2f8519c265a363760fcc5921ab7fe7c51f6ff2a173`.
These reports measure the isolated replay experiment, not the subsequent
attention-cache and draft-interface work.


### Shared MTP drafting candidate — M4 Pro (2026-09-09)

Packed Qwen 27B, folded RTN4 companion, MTP depth two, KV4, Bun 1.4.2 and
MLX 0.32.2 on the M4 Pro 24 GB. The candidate replaces the request-local
draft/commit loop with the shared row method at B=1. Both use the existing
serving control and shared prefill cache. The official serving suite ran in
both orders with 192-token decode requests. Preflight passed under Josh's
audio-daemon CPU allowance; reports retain `canonical:false`.

| Block/order | Five decode requests, reference → candidate | Sum of four queued request times, reference → candidate |
|---|---:|---:|
| 0, reference/candidate | 53,764.24 → 53,884.42 ms | 80,319.89 → 81,191.39 ms |
| 1, candidate/reference | 56,025.69 → 56,363.44 ms | 78,935.80 → 81,001.15 ms |

All 30 recorded request hashes, response hashes, token counts, cached coverage
and finish reasons match, with no failures and unchanged source snapshots.
Decode complete time regresses by 0.22% and 0.60%; summed queued-request time
regresses by 1.09% and 2.62%. The four-request 1k-context phase also regresses,
by 2.09% and 3.04%. This candidate has not established equal-or-better serving
performance and is not adopted. Native before/after prefix continuations match
on both Macs; those correctness results do not close the timing gate.

Raw: `reports/qwen38-closeout/composition-baseline/`
`mtp-row-{reference,candidate}-{0,1}.md.json` and
`mtp-shared-draft-performance-review.json`. Frozen source hashes:
reference `a0f66ee4bbf357cdd7ace981e31c4f21d8e1705b7f052e5bd6ce0b8bccf68ab5`,
candidate `dcaf122ce30b38e60847af6c0fd4df59232ccb2552ec7fb98019d231e1757b75`.
Four queued requests here still execute one at a time; this is not B=4 MTP
serving acceptance.

The subsequent candidate replaces the B=1 hidden gather with a slice of the
same verification context. On the same machine/toolchain and settings, two
new matched blocks preserve all 30 responses, counts, cached coverage and
finish reasons, plus both parity probes, with no failures or source changes.

| Block/order | Five decode requests, reference → slice candidate | Sum of four queued request times, reference → slice candidate | Cached TTFT, reference → slice candidate |
|---|---:|---:|---:|
| 0, candidate/reference | 56,802.25 → 56,806.30 ms | 83,579.51 → 82,931.12 ms | 93.85 → 93.78 ms |
| 1, reference/candidate | 55,672.47 → 56,315.67 ms | 80,785.87 → 82,545.85 ms | 93.54 → 94.80 ms |

The first block's decode time is essentially flat; the reverse-order block
regresses by 1.16%. Queued-request gains also reverse, and the 1k-context phase
changes by -0.57% then +2.34%. This does not close the performance gate. The
source replacement and slice specialization remain isolated. Do not attribute
the full variation to the gather or claim a speedup from the first block.

Raw: `mtp-slice-{reference,candidate}-{0,1}.md.json` and
`mtp-slice-performance-review.json` in the same report directory. Reference
hash is unchanged; slice candidate hash is
`665acf5432f5cde64207a475edff0f999215f2fb9df014fce8db295e6cc20bd9`.

### Concurrent MTP serving candidate — M4 Pro (2026-09-09)

Packed Qwen 27B, folded RTN4 companion, MTP depth two and KV4, Bun 1.4.2
and MLX 0.32.2 on the M4 Pro 24 GB. The existing serving suite compares
strict serial with shared execution in both arm orders. Each block uses
matched requests and a fixed source, with 192-token decode requests and no
long-context leg. Preflight passes under the recorded audio CPU allowance.

| Arm order | Five decode requests, serial / shared | Cached TTFT, serial / shared | Observed four-request throughput, serial / shared |
|---|---:|---:|---:|
| Serial first | 56,130.19 / 55,549.00 ms | 93.58 / 214.00 ms | 15.88 / 16.18 tok/s |
| Shared first | 54,137.25 / 53,914.05 ms | 93.63 / 218.90 ms | 16.08 / 16.41 tok/s |

All 22 single-request output/usage pairs and both parity probes match, with
no phase failures. Single-request decode totals improve by 1.04% and 0.41%,
but cached first output regresses in both orders. This does not meet serial
dominance and is not adopted. Seven of eight concurrent outputs differ across
arms, so aggregate throughput is an observed result, not an identical-output
speed ratio. The separate native/HTTP gate confirms real B=4 MTP verification.

The next revision exposes preparation output through the shared scheduling
readiness interface. Scheduling yields after admission completes, before the
next graph. The same two arm orders give:

| Arm order | Five decode requests, serial / shared | Cached TTFT, serial / shared | Observed four-request throughput, serial / shared |
|---|---:|---:|---:|
| Serial first | 56,583.61 / 55,563.91 ms | 93.64 / 98.28 ms | 15.52 / 16.21 tok/s |
| Shared first | 54,175.23 / 53,514.51 ms | 93.48 / 99.70 ms | 16.09 / 16.19 tok/s |

All 22 single-request pairs match, with no phase failures. Decode totals
improve by 1.80% and 1.22%. The remaining cached TTFT gap is 4.64 and 6.22 ms,
so strict serial dominance remains open. Seven of eight concurrent outputs
again differ, preventing an identical-output aggregate speed claim.
Moving publication ahead of the remaining state admission gives these results:

| Arm order | Five decode requests, serial / shared | Cached TTFT, serial / shared | Observed four-request throughput, serial / shared |
|---|---:|---:|---:|
| Serial first | 56,139.21 / 55,564.02 ms | 93.64 / 97.75 ms | 15.76 / 16.24 tok/s |
| Shared first | 54,122.55 / 54,352.40 ms | 93.60 / 100.76 ms | 16.09 / 15.89 tok/s |

All 22 single-request pairs still match, with no failures. Decode totals change
by -1.02% and +0.42%; the cached first-output gap remains. Seven concurrent
outputs differ. This revision also does not establish dominance. The next
candidate removes allocator cache clearing from shared output delivery while
preserving the methods' own maintenance. It also fixes cleanup after state
admission. Its two arm orders produce:

| Arm order | Five decode requests, serial / shared | Cached TTFT, serial / shared | Observed four-request throughput, serial / shared |
|---|---:|---:|---:|
| Serial first | 56,857.65 / 55,535.73 ms | 94.48 / 99.33 ms | 15.50 / 16.24 tok/s |
| Shared first | 54,107.37 / 53,587.76 ms | 93.70 / 98.99 ms | 16.09 / 16.16 tok/s |

All 22 single-request pairs and parity probes match, with no failures. Decode
totals improve by 2.32% and 0.96%, but cached TTFT trails serial by 4.85 and
5.28 ms. Seven concurrent outputs differ. Allocator maintenance separation
therefore does not resolve the latency gap or qualify serial removal.

Raw reports and reviews in
`reports/qwen38-closeout/composition-baseline/`:
`mtp-serving-serial-shared-0.md.json`, `mtp-serving-shared-serial-1.md.json`,
`mtp-serving-performance-review.json`, `mtp-serving-output-yield-0.md.json`,
`mtp-serving-output-yield-1.md.json` and
`mtp-serving-output-yield-performance-review.json`, `mtp-serving-staged-0.md.json`,
`mtp-serving-staged-1.md.json`, `mtp-serving-staged-performance-review.json`,
`mtp-serving-method-maintenance-0.md.json`, `mtp-serving-method-maintenance-1.md.json`
and `mtp-serving-method-maintenance-performance-review.json`.
Initial frozen source:
`4799c307be193a2cd53c91d95940c40e7294f41b13a07693ab4a45097be60d25`.
First readiness revision:
`e7d6955ea0ae8133b6445a5180fd68a784c8913072a13579f08392896cff8904`.
Staged admission revision:
`309d671bdcdd4830765d6af2341fe3b68a04c2eb9795929f9d6bcfb12f55e04d`.
Method-owned maintenance revision:
`311043d3a1add4bebffffc820a96f83dc415ad3ac6d6a17133e75540909ff273`.

The subsequent combined source includes the TurboQuant codec/row components.
The first matched block keeps KV4/MTP2, so it measures overhead in the existing
workload rather than TurboQuant serving. Compared directly with the previous
method-maintenance block on the same M4:

| Metric | Previous shared | Combined shared |
|---|---:|---:|
| Five decode requests, complete time | 55,535.73 ms | 55,560.29 ms |
| Median decode | 19.211 tok/s | 19.196 tok/s |
| Cached TTFT | 99.33 ms | 99.55 ms |
| Four concurrent requests | 16.238 tok/s | 16.241 tok/s |

All 15 shared request/output/usage pairs match, as do all 15 serial-control
pairs. Shared decode time changes by +0.044%; this is effectively unchanged,
not a demonstrated speed gain. The serial control changes by -0.94%. No phase
fails and the combined source stays fixed. This is one arm-order block;
the reverse-order repeat remains open. The first settings sweep follows.
Raw report: `decode-composition-combined-0.md.json`; review:
`decode-composition-previous-run-review.json`, in the same reports directory.
Combined source:
`2b7b258c983729be4dc723493ad6a14eea853c0166df9f2a36a4a3b27344f51c`.

The first settings sweep uses that same frozen source, the same block-0
requests and the shared server. Each row includes five 192-token decode
requests, short cold/cached prompts and four concurrent requests. Long-context
and restart benchmark legs are excluded. Every report has zero failed phases
and a stable source snapshot; the audio CPU allowance remains recorded.

| KV / draft depth | Five decode requests | Median decode | Cached TTFT | Four concurrent requests |
|---|---:|---:|---:|---:|
| Affine 4 / MTP2 | 55.560 s | 19.196 tok/s | 99.55 ms | 16.241 tok/s |
| Affine 8 / MTP2 | 55.067 s | 19.442 tok/s | 98.96 ms | 16.329 tok/s |
| Affine 4 / MTP4 | 136.714 s | 7.493 tok/s | 97.23 ms | 14.522 tok/s |
| Affine 8 / MTP4 | 131.855 s | 7.683 tok/s | 97.48 ms | 15.170 tok/s |

MTP2 leads this first sweep. Changing precision or draft depth can change the
continuation; these are observed configuration rates, not identical-output
engine speedup ratios. The small KV8/MTP2 lead needs repetition. The expanded
screen below adds async weight expansion, no-MTP controls and TurboQuant
serving. No default changes are justified by this single block. Raw settings reports are
`decode-settings-{kv8-mtp2,kv4-mtp4,kv8-mtp4}-0.md.json`; the summary is
`decode-settings-first-sweep-review.json` in the same reports directory.

### Integrated settings screen and context repeat — M4 Pro (2026-09-09)

The isolated shared-serving candidate now includes TurboQuant ordinary/MTP
groups. All 20 reports below use stable source
`6e293a0efeb2f22e2557bf0e39373774545dc0737496c07e7bbe8cfbf6cd3939`,
the same packed Qwen artifact and folded RTN4 companion, Bun 1.4.2,
MLX 0.32.2 and the M4 Pro 24 GB. Preflight passes with Josh's audio-CPU
allowance. The server's batch capacity is eight; the aggregate leg submits
four requests. Separate native serving gates establish actual four-row MTP
verification. These reports retain `canonical:false`.

Short-context block 0 uses matching requests and five 192-token decode
samples. Fused TurboQuant decode is enabled; async Trellis expansion is off
unless labeled. No report has a failed phase.

| KV / method | Five requests, complete ms | Median decode tok/s | Cached TTFT ms | Aggregate ×4 tok/s |
|---|---:|---:|---:|---:|
| bf16 / ordinary | 88,763.10 | 11.593 | 163.76 | 25.776 |
| bf16 / MTP2 | 54,064.81 | 19.793 | 96.49 | 16.822 |
| bf16 / MTP3 | 53,904.19 | 20.089 | 98.79 | 16.952 |
| Affine 4 / ordinary | 89,551.02 | 11.521 | 164.78 | 25.689 |
| Affine 4 / MTP1 | 61,737.80 | 17.170 | 96.91 | 15.695 |
| Affine 4 / MTP2 | 55,544.22 | 19.200 | 99.49 | 16.247 |
| Affine 4 / MTP3 | 61,344.01 | 17.198 | 98.07 | 16.208 |
| Affine 4 / MTP2, async | 55,282.33 | 19.167 | 99.02 | 16.243 |
| Affine 4 / MTP4, async | 136,386.37 | 7.487 | 97.26 | 14.559 |
| Affine 8 / ordinary | 88,955.50 | 11.571 | 167.18 | 25.679 |
| Affine 8 / MTP1 | 62,207.00 | 17.003 | 97.45 | 15.510 |
| Affine 8 / MTP3 | 56,289.15 | 18.991 | 99.90 | 16.664 |
| TQ K8V3 / ordinary | 90,881.00 | 11.403 | 174.53 | 25.308 |
| TQ K8V3 / MTP2 | 56,578.08 | 19.242 | 102.53 | 16.429 |
| TQ K8V3 / MTP3 | 56,923.87 | 19.065 | 102.78 | 16.046 |
| TQ K8V3 / MTP4 | 131,849.48 | 7.593 | 101.34 | 14.481 |

The affine-4/MTP2 integration control preserves all 15 request/output pairs
against the preceding `2b7b…` source; complete decode time changes by -0.029%,
effectively unchanged. Its async arm also preserves all 15 outputs, with
complete time -0.47% in this one block. Async expansion does not remove the
MTP4 decode cliff. MTP3 uses its third proposal: affine-4 accepts 109 of 386
third-position drafts, affine-8 accepts 114 of 373. Acceptance alone does not
make the extra work profitable.

The four leading comparison profiles then run full `bench-serve all` with
block-1 inputs and `--context 16384`. The rendered prompt actually contains
**10,398 tokens**. Each context leg has a cold request and two RAM-cached
repeats, followed by an explicit durable flush and SSD restart.

| KV / method | Five short requests, complete ms | Short decode tok/s | Context decode tok/s | Cold context TTFT ms | SSD restart TTFT ms |
|---|---:|---:|---:|---:|---:|
| bf16 / MTP3 | 56,107.03 | 19.179 | 23.130 | 80,060.42 | 2,026.44 |
| TQ K8V3 / MTP3 | 58,195.34 | 18.350 | 19.580 | 79,777.84 | 1,936.05 |
| Affine 4 / MTP2 | 53,548.41 | 20.133 | 22.184 | 79,860.36 | 1,919.74 |
| Affine 4 / MTP3 | 56,923.65 | 18.999 | 22.826 | 79,912.94 | 1,930.17 |

Within each profile the three context responses match exactly. Every restart
restores 10,397 cached tokens, with zero pending, dropped or failed spills
after flush. Across settings, continuations can differ; these rates do not
establish an identical-output engine speedup. MTP2 leads affine-4 short
requests, while MTP3 has a small context-decode lead. Ordinary batching has
the strongest aggregate throughput in the short screen. The choice of one
default for typical single-user multi-turn/tool use remains open pending
late-task context measurements and balanced repeats; user overrides remain.

Raw files in `reports/qwen38-closeout/composition-baseline/`:
`decode-integrated-*-0.md.json`, `decode-default-*-context-1.md.json` and
`decode-integrated-settings-review.json`. Source archives remain frozen on
the M4; no candidate default has been promoted.

The subsequent late-context control uses the same frozen source and
`--context 125000`. KV4/MTP2 fails the context phase, including its retry,
with Metal command-buffer out-of-memory at the default 2,048-token prefill
chunk. It supplies no context decode or restart result. Preflight passed
with 96 MB retained swap and 93% free memory; swap remained 96 MB afterward.
Raw: `decode-default-kv4-mtp2-late-context-0.md.json` in the same directory.
The next depth-3 attempt was stopped before the context leg to avoid repeating
the same oversized configuration. A separate depth-2/3/1 comparison uses
`MLX_BUN_RD_PREFILL_CHUNK=256`, matching the published Kanban prefill profile;
depth 2 now completes at **78,678 actual prompt tokens**. Cold first-output time
is 884.14 seconds, context decode median is 12.828 tok/s, cached repeat
first-output time is 237.45 ms and fresh-process SSD restart first-output time
is 2,229.68 ms with 78,677 cached tokens. All three context outputs match;
the eight-token restart output matches their beginning. Flush is durable with
zero pending, dropped or failed writes, and the source hash remains unchanged.
Depth 3 also completes on unchanged source. Its cold first-output time is
884.68 seconds, context decode median 11.718 tok/s, cached first-output time
187.75 ms and SSD restart first-output time 2,235.34 ms with 78,677 tokens
restored. Its three context outputs match each other, but differ from depth 2;
these are settings comparisons, not identical-output engine comparisons.
Durability also passes with no pending, dropped or failed writes. Depth 1
completes at 10.582 tok/s context decode, with 884.59 seconds cold first-output
time, 189.69 ms cached first-output time and 2,243.35 ms after SSD restart.
It restores 78,677 tokens; all three context outputs match depth 2. Source
hashes are stable, both preflights pass and there are no phase failures or
pending, dropped or failed writes. These single profiles do not select a
default. Raw: `decode-default-kv4-mtp{1,2,3}-late-context-chunk256-0.md.json`.
Ordinary shared prefill in the frozen benchmark source does not read that
control. The adopted policy fix makes ordinary and speculative prefill use the group's
captured default and preserves the library request override. Its M1 seeded
native and MTP RAM/SSD gates, complete model-free suite and typecheck pass; a matched M4
ordinary late-context arm remains open.

The composed ownership/prefill-policy short control is complete on the M4
Pro, with source `04f518534d568d10cd570e3ecd671a69ccbe97513f803d3a29ac250269416a0d`.
It uses the same block-0 requests, KV4/MTP2, default prefill chunk and runtime
settings as the frozen `6e293a0...` arm. All 14 measured request hashes,
response texts, generated counts and cached counts match. Five decode requests
take 55,619.41 ms versus 55,544.22 ms, a 0.14% increase; median decode is
19.195 versus 19.200 tok/s. Cached first-output time is 97.56 versus 99.49 ms,
and four-request aggregate throughput is 16.203 versus 16.247 tok/s. This
single comparison is effectively unchanged, with no performance win claimed.
There are no phase failures and source hashes remain stable. The arm includes
the Gemma ownership fix and captured prefill policy, but not generated-output
publication. Raw: `composition-baseline/decode-prefill-policy-kv4-mtp2-short-0.md.json`
under `reports/qwen38-closeout/`.

The same composed source also completes the 78,678-token KV4/MTP2 context
control with 256-token chunks. All 19 request hashes, response texts,
generated counts and cached counts match the frozen arm. Cold first-output
time is 884.12 versus 884.14 seconds; context decode median is 12.918 versus
12.828 tok/s. Cached first-output time is 188.35 versus 237.45 ms and restart
time is 2,230.56 versus 2,229.68 ms, with 78,677 tokens restored. Durability
has no pending, dropped or failed writes; source hashes and both preflights
pass. This single comparison does not establish a latency or throughput win.
Raw: `composition-baseline/decode-prefill-policy-kv4-mtp2-late-context-chunk256-0.md.json`.
The wrapper failed before launching the ordinary arm because macOS Bash 3
rejects its empty-array expansion under `set -u`. That arm was resumed alone;
the completed MTP report was preserved.


The subsequent ordinary KV4 late-context arm on the same M4 Pro source did
**not** pass clean acceptance. Its first 78,678-token cold request completed
with 881,941 ms to first output, but the cached repeat failed with Metal
`kIOGPUCommandBufferCallbackErrorOutOfMemory`. The benchmark's built-in retry
restarted the phase with a different request hash and 78,677 prompt tokens.
That retry completed at 7.319 tok/s median context decode, 292.54 ms cached
first output and 2,262.76 ms after SSD restart, reusing 78,676 tokens. These
are recovery diagnostics, not a matched successful ordinary/MTP comparison.
Both machine checks passed and source stayed fixed; final swap was 294.69 MB.
The final flush retained 17 entries with no pending, dropped or failed spills.
The initial failure and both attempts remain in
`reports/qwen38-closeout/composition-baseline/decode-prefill-policy-kv4-plain-late-context-chunk256-0.md.json`.
The cached-repeat allocation failure needs investigation before repeating
ordinary late-context acceptance. Independent output-cache/prefill correctness
resumed without rerunning or reclassifying this failed benchmark.


The final generated-output/prefill composition also passes M4 native and
HTTP bf16/KV4/fused-TQ cache continuation, parser/template replay, full-suite
and typecheck gates. Its short KV4/MTP2 block-0 benchmark uses source
`af91e6a64649df5af9eb73e4a35739109f6799a5c8ba7ddc47c3543876cb19c0`.
All 14 measured requests plus warmup match the prefill-policy control's
request hashes, response text, prompt/generated counts and cached counts.
Five decode requests take 55,636.28 versus 55,619.41 ms, a 0.03% increase;
median decode is 19.171 versus 19.195 tok/s. Cached first output is 99.06
versus 97.56 ms, and aggregate throughput is 15.859 versus 16.203 tok/s.
Source and preflights are stable with no failures. This is one matched
composition check with flat decode; it establishes no overall speed win or
strict serial-domination result. Long Kanban and pressure acceptance remain.
Raw: `composition-baseline/decode-output-prefill-kv4-mtp2-short-0.md.json`.


The isolated variable-proposal verifier passes M4 uniform/variable bf16/KV4
native controls, the full suite and typecheck. Its first short KV4/MTP2
block-0 comparison is slower: five decode requests take 58,907.66 versus
55,636.28 ms, a 5.88% increase; median decode is 17.936 versus 19.171 tok/s.
Cached first output is 97.51 versus 99.06 ms and aggregate throughput is
15.911 versus 15.859 tok/s. All measured requests plus warmup preserve
request hashes, responses, prompt/generated/cache counts and speculation
statistics. Source `885f542f07ea48e119a6bdaf533b4e2605ff293c3d7eb373ac202410032e24dd`
and both preflights are stable, with no failures. This single ordered
comparison does not distinguish a code regression from machine drift.
Alternating frozen control/candidate repeats below test whether that slowdown
follows the source.
Raw: `composition-baseline/decode-variable-proposals-kv4-mtp2-short-0.md.json`.

The subsequent M4 Pro 24 GB A/B/B/A repeats use the same two frozen sources,
KV4, MTP2, 192-token limit, block-0 workload and runtime environment. All 15
requests per arm, including warmup, match request/output hashes, token counts,
finish reasons and complete usage/speculation records. Both preflights pass
and each source remains unchanged, with no request or phase failures.

| Arm | Five decode requests, total ms | Median decode tok/s | Cached first output ms | Aggregate tok/s |
|---|---:|---:|---:|---:|
| Control 1 | 55,559.96 | 19.154 | 98.90 | 15.853 |
| Candidate 1 | 55,618.37 | 19.152 | 97.29 | 15.674 |
| Candidate 2 | 55,566.01 | 19.189 | 97.23 | 15.880 |
| Control 2 | 55,604.33 | 19.166 | 99.06 | 15.917 |

Combined candidate decode wall time is **0.018% higher**. The initial 5.88%
slowdown does not reproduce; this screen supports preserving fixed-MTP decode
performance while adding variable proposals. Aggregate throughput varies and
establishes no gain. This does not qualify actual prompt-lookup performance,
long contexts or serial deletion. The verifier patch is adopted in the working
tree after the both-machine correctness gates; the main suite and typecheck pass.
Raw reports and derived identity/timing comparison:
`composition-baseline/variable-proposals/decode-variable-alternating-*.md.json`
and `composition-baseline/variable-proposals/alternating-comparison.json`.

The prompt-lookup integration's fixed-MTP regression screen uses the same M4
Pro 24 GB, KV4/MTP2, block-0 requests and runtime settings. Frozen source
`3df52152aac2289b9ed860c2789141acb5e8d6ce7a6170899f34bd9ef1ac9a39`
retains all 15 request/output hashes and complete usage/speculation records
against variable-verifier candidate2 above. Five decode requests take
55,620.03 versus 55,566.01 ms, a 0.097% increase; median decode is 19.176
versus 19.189 tok/s, cached first output 97.56 versus 97.23 ms, and aggregate
throughput 15.778 versus 15.880 tok/s. Source/preflights are stable with no
request or phase failures. This one short screen establishes no speedup;
actual prompt-lookup serial/shared comparisons remain separate.
Raw and comparison: `composition-baseline/ngram-group/decode-ngram-group-kv4-mtp2-short-0.md.json`
and `composition-baseline/ngram-group/fixed-mtp-comparison.json`.

The subsequent delayed-TQ/method composition passes M4 fused/unfused native,
SSD, complete-suite, typecheck and hygiene checks. Its short fixed-KV4/MTP2
screen, source `88da0dca100cdb012cbd4330638cc43b727dbb853a5b1ef6aded60bc6fe1eb0d`,
preserves all 15 request/output hashes and complete usage/speculation records
against the frozen lookup base. Five decode requests take 55,812.61 versus
55,620.03 ms, a 0.35% increase. Median decode is 19.123 versus 19.176 tok/s,
cached first output 98.72 versus 97.56 ms, and aggregate throughput 15.724
versus 15.778 tok/s. Source/preflights pass with no failures. This single
short composition screen establishes no gain and does not measure delayed
TurboQuant performance, since the workload uses KV4.
Raw: `composition-baseline/method-composed/decode-tq-method-composed-kv4-mtp2-short-0.md.json`
and `composition-baseline/method-composed/fixed-mtp-comparison.json`.

Two M4 Pro 24 GB prompt-lookup comparisons use KV4, draft depth 3,
192-token decode requests, and reversed arm order on two workload seeds.
Source is the same frozen lookup candidate above; both preflights and source
checks pass with no request or phase failures. All single-request response
pairs match, including their generated counts and finish reasons.

| Arm order | Five decode requests, serial / shared ms | Cached first output, serial / shared ms | Observed aggregate tok/s, serial / shared |
|---|---:|---:|---:|
| Serial first | 92,140.46 / 91,472.96 | 5,843.26 / 126.77 | 10.213 / 9.430 |
| Shared first | 89,953.79 / 89,279.30 | 5,863.21 / 126.66 | 10.798 / 9.608 |

Single-request decode totals improve by 0.72% and 0.75%. Shared prompt lookup
restores 758 and 757 tokens on the cached repetitions; serial restores zero.
That is an actual new cache benefit, with different prefill work. All eight
concurrent output pairs differ, and observed shared throughput is lower in
both orders. An identical-output aggregate comparison and shared-execution
dominance remain unproven. Wider verification cost and acceptance need further
measurement; the result does not qualify deleting serial. Default-depth-10
KV4 serving correctness subsequently passes 219 assertions on each Mac, with
all ten proposal positions exercised; this is not depth-10 timing acceptance.
Raw: `composition-baseline/ngram-group/decode-ngram-group-kv4-serial-shared-{0,1}.md.json`
and `composition-baseline/ngram-group/lookup-paired-comparison.json`.

A separate M1 Max first-output diagnostic uses a 758-token prompt, KV4/MTP2
and eight generated tokens through direct serial/shared execution. All eight
outputs match and warm requests restore 757 tokens. Draft seeding accounts
for roughly 93 ms on the warm traces; cache lookup is about 0.3–0.6 ms.
Instrumenting the native allocator cleanup then identifies 0–6.8 ms inside
`clearCache()` after the one-token target forward, on both execution paths.
The shared path does not consistently trail serial in this loaded diagnostic;
it does not explain the M4 gap by itself. A bounded candidate will skip this
cleanup for one-token prefill work while retaining larger-chunk cleanup, with
numerical, allocation and M4 request-time checks before adoption. Raw traces:
`composition-baseline/mtp-first-output-diagnostic-m1.jsonl` and
`composition-baseline/mtp-clear-diagnostic-m1.jsonl`.

The one-token maintenance candidate also completes a separate-process M1 Max
allocation comparison at 8,195 prompt tokens, MTP2/KV4, chunk256, eight output
tokens and a 4 GiB RAM cache without SSD. All three paired outputs, cache counts
and speculation records match. Both warm repeats restore 8,194 tokens.
Warm peak live allocation above the starting live state is 544.717 MiB for
control and 544.732 MiB for candidate, a 16,208-byte increase. Final live
allocation is effectively unchanged; the candidate's final allocator pool is
845.54 versus 709.29 MiB, so it retains about 136 MiB more unused capacity in
this run. This loaded M1 diagnostic establishes no speedup and does not replace
M4 long-context/SSD pressure coverage. Raw and derived records:
`composition-baseline/single-token-maintenance/m1-allocation-{control,candidate}.jsonl`
and `composition-baseline/single-token-maintenance/m1-allocation-comparison.json`.

Four alternating M4 Pro 24 GB fixed-MTP2/KV4 short runs compare the one-token
maintenance candidate against the composed source above. Bun is 1.4.2,
MLX is 0.32.2, fused TQ decode is enabled and asynchronous Trellis expansion
is disabled. Both arms use seed `mtp-serving-block-0`, 192 output tokens,
a 4 GiB prompt cache and the same packed target/RTN4 companion. Control source
is `88da0dca100cdb012cbd4330638cc43b727dbb853a5b1ef6aded60bc6fe1eb0d`;
candidate is `c12b60c1c7f39bf4ccdeaa7cdd16795a04d6ca2246eeb7609ec97cb9eee65315`.
All four source snapshots and preflights pass under the recorded audio-CPU
allowance. All 60 requests preserve request hashes, output text, complete
usage/acceptance records and finish reasons, with no failures.

| Order | Five decode requests, total ms | Cached first output, ms | Median decode, tok/s | Aggregate tok/s |
|---|---:|---:|---:|---:|
| Control 1 | 56,424.69 | 98.097 | 18.722 | 15.591 |
| Candidate 1 | 55,595.29 | 96.483 | 19.198 | 15.799 |
| Candidate 2 | 55,588.63 | 96.517 | 19.171 | 15.916 |
| Control 2 | 55,581.64 | 98.214 | 19.174 | 15.959 |

Cached latency averages 98.156 versus 96.500 ms, a 1.69% reduction. The
first control also has slower cold prefill and decode; both candidate decode
totals are effectively flat against the second control. This screen supports
the narrow cached-latency improvement, not a general throughput gain or
serial/shared dominance. The candidate remains isolated pending the direct
serial/shared comparison and pressure review. Raw and derived records:
`composition-baseline/single-token-maintenance/decode-single-token-maintenance-{control1,candidate1,candidate2,control2}.md.json`
and `composition-baseline/single-token-maintenance/alternating-comparison.json`.

The direct M4 Pro serial/shared follow-up uses that same candidate source,
MTP2/KV4 and two seeds with reversed arm order. All 22 single-request pairs
preserve output, usage except the lane label, and cache coverage; all request
hashes and generated budgets match. Source/preflights pass with no failures.

| Arm order | Five decode requests, serial / shared ms | Cached first output, serial / shared ms | Observed aggregate tok/s, serial / shared |
|---|---:|---:|---:|
| Serial first | 56,220.90 / 55,568.01 | 93.761 / 96.858 | 15.734 / 16.003 |
| Shared first | 54,119.93 / 54,093.31 | 93.782 / 95.060 | 16.111 / 15.925 |

The allocator change does not remove the B1 cached-latency regression. Seven
of eight concurrent output pairs differ, and observed aggregate throughput
moves in opposite directions across the two orders. These results do not
qualify shared dominance or serial deletion. The cleanup candidate remains
isolated; its narrow improvement against the prior shared implementation is
recorded separately above. Raw and derived records:
`composition-baseline/single-token-maintenance/decode-maintenance-serial-shared-{0,1}.md.json`
and `composition-baseline/single-token-maintenance/serial-shared-comparison.json`.

Four alternating M4 Pro 24 GB prompt-lookup runs compare wider packed
down-projection eligibility against the unchanged operation. Settings are
KV4, lookup depth3, 192 output tokens, seed `ngram-serving-block-0`, Bun 1.4.2
and MLX 0.32.2. Control source is
`88da0dca100cdb012cbd4330638cc43b727dbb853a5b1ef6aded60bc6fe1eb0d`;
candidate is `c399a3e7fa4d8e61d720476a53a3abb5055944dccfd32684a99157373a288343`.
All 60 requests preserve request hashes, response text, complete usage and
finish reasons. Source/preflights pass under the audio-CPU allowance, with no
failures. Both-machine projection and full-model B1/B2/B4/B8 state checks pass,
including every new projection width and the artifact's three bit widths.

| Order | Five decode requests, total ms | Cached first output, ms | Aggregate tok/s |
|---|---:|---:|---:|
| Control 1 | 91,973.51 | 126.671 | 9.456 |
| Candidate 1 | 92,261.32 | 129.677 | 9.305 |
| Candidate 2 | 91,413.34 | 126.650 | 9.324 |
| Control 2 | 91,750.52 | 126.872 | 9.473 |

Combined single-request time is effectively unchanged, decreasing 0.027%,
while aggregate throughput decreases 1.58%. Both candidate aggregate results
trail both controls. The wider eligibility is not adopted: exact arithmetic
and avoiding dense weight expansion do not establish a serving benefit.
Any further kernel tuning needs workload dispatch/cost attribution first.
Raw and comparison:
`composition-baseline/trellis-batch-width/decode-trellis-width-ngram-{control1,candidate1,candidate2,control2}.md.json`
and `composition-baseline/trellis-batch-width/alternating-comparison.json`.

A bounded M1 Max allocation diagnostic follows the ordinary M4 cached-repeat
OOM. At 8,195 prompt tokens, KV4, 12 generated tokens and a 4 GiB RAM cache
without SSD, normal pipelining, early first output and disabled pipelining
all retain two entries and add the same 375.28 MiB peak allocator demand
above the pre-request live allocation on warm repeats. All nine outputs
match. This loaded-machine native probe is not a speed benchmark, does not
reproduce the 78k failure, and supplies no evidence that pipeline overlap is
its allocation cause. Large-context retention and concurrent SSD persistence
remain untested by this probe.
Raw: `composition-baseline/ordinary-cached-allocation-m1.jsonl`.

### Current MTP depth two versus four — M4 Pro (2026-09-09)

Same packed artifact, RTN4 companion, KV4, Bun 1.4.2, MLX 0.32.2 and frozen
reference source as the replay experiment above. The source hash is
`a01bee0b7e1962c8211f1ffd845d95f7923d6c04bddb18cf06f07483cab9e7e8`.
Only the draft depth changes. Each block uses matching request hashes and
192 output tokens. Both depth-four blocks precede both depth-two blocks, so
this depth comparison is not balanced in execution order. Preflight passes
with the recorded audio-CPU allowance; reports retain `canonical:false`.

| Block | Depth two median decode | Depth four median decode | Five-request complete time, depth two / four | Matching responses |
|---|---:|---:|---:|---:|
| 0 | 19.33 tok/s | 7.36 tok/s | 56,275.71 / 135,674.99 ms | 6 / 15 |
| 1 | 18.31 tok/s | 7.60 tok/s | 57,859.37 / 130,083.45 ms | 6 / 15 |

Counts, cached coverage and finish reasons match for every request. All five
decode and four queued-concurrency responses differ in each block; no phase
fails. These are observed results from different continuations, not an
identical-output speed ratio or a depth-four acceptance. Depth two remains the
current choice. A depth-four verify processes five tokens including the pending
token, crossing the existing four-row packed-kernel boundary. R7 already records
that boundary's cost and arithmetic difference; the current runs do not isolate
its contribution from the changed continuation/acceptance trajectory.

Raw: `reports/qwen38-closeout/composition-baseline/mtp-depth2-{0,1}.md.json`,
`state-replay-reference-{0,1}.md.json` and `mtp-depth-performance-review.json`.
All requests here use the one-active-request control; four queued requests do
not establish actual batched MTP. Compare fixed-input verification at both
window sizes before changing the dispatch policy or promoting depth four.

### Current standard serve matrix — M1 Max 32 GB (2026-08-22)

Real-server HTTP matrix on commit `4103ae1`, with the canonical preflight
passing at the start of both runs: zero swap, ample free memory, and no large
foreign process. The Qwen extension ended with 944 MiB of inactive swap,
below the harness's 3 GiB mid-run rejection threshold. No benchmark phase
failed. Raw gitignored reports:
`benchmarks-serve-2026-08-22-Joshs-MacBook-Pro-2.md` and
`benchmarks-serve-2026-08-22-Joshs-MacBook-Pro-2-qwen27b.md`.

| model | arm | short decode tok/s | decode @ ~15.8k tok/s | aggregate ×4 tok/s | restart TTFT ms (cached tokens) |
|---|---|---:|---:|---:|---:|
| MiniCPM5-1B | mlx-bun | **267.7** | 122.0 | **420.1** | 207 (15,817) |
|  | mlx-bun serial | 266.4 | 124.6 | 245.9 | 182 (15,889) |
|  | mlx-lm | 179.7 | 96.2 | 181.4 | 10,355 (0) |
|  | mlx-bun mixed | 194.2 | **127.0** | 397.5 | **130 (15,815)** |
| gemma-4-e4b | mlx-bun | **61.5** | 43.7 | 20.7 | 18,863 (4) |
|  | mlx-bun serial | **61.5** | 43.1 | 59.7 | **661 (15,940)** |
|  | mlx-lm | 52.8 | 42.8 | 72.3 | 20,187 (0) |
|  | mlx-bun mixed | 57.3 | **49.0** | **97.4** | 20,510 (0) |
| gemma-4-12B | mlx-bun | **29.6** | 28.3 | 5.6 | 85,180 (4) |
|  | mlx-bun serial | **29.6** | **28.4** | 27.5 | **1,338 (15,866)** |
|  | mlx-lm | 27.1 | 25.8 | 32.5 | 89,504 (0) |
|  | mlx-bun mixed | 28.7 | 24.4 | **38.7** | 93,068 (6) |
| Qwen3.8-27B winner | mlx-bun | **18.5** | 16.5 | 19.3 | 173,215 (0) |
|  | mlx-bun serial | **18.5** | **16.7** | 15.8 | 172,400 (0) |
|  | mlx-lm | 16.5 | 14.9 | 18.3 | 177,066 (0) |
|  | mlx-bun mixed | 18.1 | 14.9 | **19.4** | **3,328 (15,112)** |

- All four models passed 64-token greedy completion and chat parity for
  mlx-bun bf16 versus mlx-lm, and unified scheduling versus `--batch 1`.
- Qwen's standard mlx-bun arm beat mlx-lm by 12.1% at short decode and
  10.7% at long-context decode. The mixed arm did not beat bf16 on decode;
  its useful result was restoring the full 15,112-token cache after restart.
- The e4b and 12B unified arms restored only four cached tokens after restart,
  while their serial controls restored the full cache. This is a real
  scheduler/SSD-persistence regression and explains their poor aggregate rows.
  Qwen bf16 restored no cache in either scheduler mode.
- Qwen mixed KV is a Lab characterization, not an L2 correctness claim. Its
  policy is copied from the official same-topology Qwen3.6 OptiQ artifact;
  Qwen3.8 has no model-specific mixed-KV oracle yet. Its 15,278 MB sampled peak
  RSS also failed the harness's `mixed < bf16` diagnostic, so the run proves
  that the policy loads and serves, but not that KV quantization was effective.

#### Bun 1.4.0 repeat

The full matrix repeated after upgrading from Bun 1.3.14 to 1.4.0. Starting
state was 401 MiB inactive swap, 93% free memory, load 3.7, and no large
foreign process, which passed the canonical preflight. All completion, chat,
and unified-versus-serial parity probes passed again. Core mlx-bun performance
was stable; the largest one-run movements were MiniCPM aggregate +5.0% and
Qwen long-context decode +3.0%, neither promoted as a Bun speed claim without
repeats.

| model | engine | short decode tok/s | short prefill tok/s | long decode tok/s | warm TTFT ms | aggregate ×4 tok/s |
|---|---|---:|---:|---:|---:|---:|
| MiniCPM5-1B | mlx-bun | **265.8** | **2,576** | **124.2** | **26** | **441.3** |
|  | mlx-lm | 177.0 | 1,907 | 96.5 | 86 | 185.8 |
| gemma-4-e4b | mlx-bun | **61.7** | **868** | **43.1** | **39** | 21.2 |
|  | mlx-lm | 52.4 | 676 | 42.5 | 268 | **72.4** |
| gemma-4-12B | mlx-bun | **29.7** | **191** | **28.4** | **77** | 6.0 |
|  | mlx-lm | 26.7 | 181 | 25.3 | 388 | **33.4** |
| Qwen3.8-27B winner | mlx-bun | **18.6** | 64 | **17.0** | **116** | **19.5** |
|  | mlx-lm | 16.5 | **85** | 14.8 | 284 | 18.6 |

The e4b and 12B aggregate losses remain contaminated by the SSD durability
race. Their unified arms restored 2 and 4 tokens; serial restored 15,939 and
15,794. Qwen's short-prefill loss is different: both mlx-bun schedulers lose
at the roughly 754-token shape, while sustained prefill reaches 87 tok/s at
15.1k versus mlx-lm's 88. This points to fixed graph-build or shape overhead,
not a slower sustained prefill kernel. Split timing is still required before
assigning the cause.

### Colibri G1/G3 component matrix — M1 Max 32 GB

Cleared-machine run on 2026-07-30, commit `47c4d6d`, Bun 1.3.14, pinned
Colibri `44e489b`, public artifact revision `3cc8db9`, ten warmups and fifteen
measured samples. Values are synchronized median milliseconds at identical
production shapes; every arm passed its correctness oracle. These are
component timings, not end-to-end generation claims.

| production-shape cell | direct Colibri Metal | selected mlx-bun path | decision |
|---|---:|---:|---|
| Q4 dense decode M=1 | 0.302 | 1.372 stock MLX | stock MLX (only mlx-bun dense candidate) |
| Q4 dense prefill M=32 | 1.286 | **1.030 stock MLX** | stock MLX |
| routed SwiGLU decode, top-8 M=1 | **1.401** | 4.282 custom Metal | custom Metal; 16.0% faster than stock MLX's 5.099 ms |
| routed SwiGLU ragged M=11/23 experts | **10.851** | 18.100 stock MLX | stock MLX |
| routed SwiGLU prefill M=32/64 experts | **32.906** | 45.558 stock MLX | stock MLX |
| absorbed MLA decode, position 128 | **1.014** | 11.506 stock MLX | stock MLX; largest remaining component gap |

For the selected custom decode path, max absolute delta versus stock is
`2.33e-9`, relative RMSE `5.56e-7`, and cosine
`0.9999999999998354`. A separate three-warmup/eleven-sample run also selected
custom Metal by 5.4%. Swap was unchanged at 339.25 MiB. Matched idle-power
arms (baseline, 1, 2, and 4 native workers, repeated in reverse order) show no
monotonic CPU/GPU/package-power increase, proving the condition-variable
workers are passive; two workers remain the default. Raw gitignored reports:
`runs/colibri-g1/*matrix*-2026-07-30.json` and
`runs/colibri-g1/passive-worker-power*-2026-07-30.json`.

### Colibri G4 serial native MTP — M1 Max 32 GB

Production-artifact separate-process A/B on 2026-07-30, Bun 1.3.14, pinned
Colibri `44e489b`, public artifact revision `3cc8db9`, greedy gamma=3, 32-token
prompt and 64 generated tokens. Both arms reproduced the same direct-Colibri
64/64 target-token trajectory. Generation wall time is the comparison metric;
the probe's prefill/decode sub-buckets place the first sample on different
sides of that boundary and are therefore not compared.

| arm | generation wall | wall throughput | target/verify forwards | draft acceptance |
|---|---:|---:|---:|---:|
| MTP off | 834.172 s | 0.0767 tok/s | 63 continuation | — |
| MTP on | **675.654 s** | **0.0947 tok/s (1.235x)** | **31 verify (32 saved)** | 32/92 |

MTP-on emitted 2.065 tokens per verify forward and reduced end-to-end
generation time by 19.0%. Its direct-oracle acceptance prefix was exact for
the tie-free first four rounds `[1,1,1,0]` (eight emitted tokens; minimum
first-draft margin 3.5675). Later acceptance is intentionally non-gating
across engines because direct Colibri's float64 RMSNorm reduction and MLX's
float32 graph produce different recurrent MTP hidden states while preserving
all target tokens. The machine was not swap-cleared, so the
14,679,224,320-byte completed MTP-on physical footprint is not a G5 memory
claim. Stable record:
`fixtures/colibri-glm52/g4-native-mtp-e2e.json`.

### Colibri G5–G7 full-model productization — M1 Max 32 GB

Final curated result for the streamed runtime. Bun 1.3.14, 32 GiB unified
memory, 25 GiB process ceiling, batch 1, 4,096-token supported context, 128
generated tokens, greedy decoding, true top-8, and quality-preserving defaults.
The G5 before/after run is 2026-08-15; G6 learning telemetry is a three-repeat
paired run on 2026-08-16; the DSA and API gates are 2026-08-17.

#### Resource contract

The current artifact-aware preflight, including the locally installed stock
DSA indexer overlay, reports:

| resource | bytes | GiB |
|---|---:|---:|
| full artifact on disk (streamed, not resident) | 383,739,826,712 | 357.39 |
| resident non-expert weights + DSA indexers | 11,074,469,760 | 10.31 |
| main Q4 expert slab (139 slots) | 2,632,646,656 | 2.45 |
| MTP Q8 expert slab (25 slots) | 945,356,800 | 0.88 |
| target + MTP compressed KV | 789,577,728 | 0.74 |
| reconstructed KV + verify + allocator/Bun/safety reserves | 5,910,612,992 | 5.50 |
| **planned process** | **21,352,663,936** | **19.89 / 25.00** |
| **process/macOS headroom** | **5,490,881,664** | **5.11** |

The original G5 measurement preceded the 197,202,400-byte stock indexer
overlay and planned 21,111,440,128 bytes. The overlay raises the current
preflight by 241,223,808 bytes but does not alter the short-context trajectory
or the observed G5 footprints below.

> **Measurement outcome:** the requested before/after observation closed the
> 32 GB fit question, but did **not** satisfy the harness's stricter
> zero-compression/zero-swap contract. Peak physical footprint stayed at or
> below 14,807,789,616 bytes (13.791 GiB), while maximum system/task compressor
> growth was 4,402,905,088 / 1,939,537,920 bytes; MTP-off observed 7,143,424
> bytes of swapout and MTP-on observed zero. The source result is correctly
> labeled `observed`, not `pass`.

#### Cold/warm MTP and memory

| arm / turn | decode tok/s | end-to-end tok/s | final physical footprint |
|---|---:|---:|---:|
| MTP off · cold | 0.1330 | 0.1274 | 13,490,515,008 B |
| MTP off · warm | 0.1190 | 0.1139 | 13,510,634,560 B (+19.2 MiB) |
| MTP on · cold | 0.1557 | 0.1456 | 14,673,342,512 B |
| MTP on · warm | **0.1577** | **0.1487** | 14,697,574,448 B (+23.1 MiB) |

MTP-on accepted 72/166 drafts over 56 verify forwards on each turn. Warm
end-to-end throughput was 1.306x MTP-off. It is also only 55% of the rounded
same-machine direct-Colibri MTP-on control (0.27 tok/s), and 0.1487 tok/s is
7.43% of the aspirational 2 tok/s target—a **13.45x** remaining gap. The
aspiration is not a release gate or a `fit` prediction.

#### Expert delivery and policy decisions

The replicated G6 control's median warm turn read exactly
1,974,949,363,712 logical bytes from the expert artifact, or
15.429291904 decimal GB per generated token. Its hit rate was 1.6597%; median
main-tier disk-service p95 was 90.98 ms, foreground-wait p95 92.66 ms, and
expert-layer-forward p95 167.84 ms. This is the measured reason the runtime is
disk/serialization-bound rather than compute-bound.

| MTP-on policy (three paired repeats) | warm hit rate | disk GB/token | warm e2e tok/s | decision |
|---|---:|---:|---:|---|
| control | 1.66% | 15.429 | **0.149** | default |
| startup auto-pin | 9.62% | 14.191 | 0.143 | off: 4.06% slower, +3.337 GiB footprint |
| auto-pin + live LFRU | 9.62% | 14.191 | 0.148 | off: zero swaps; no benefit beyond run-order noise |

PILOT measurement found 69.90% next-layer top-8 precision/recall, but advisory
`PILOT_K=4` left demand bytes unchanged and reduced warm throughput to 0.9746x.
Two-step correction improved recall to 73.01% while reducing warm throughput
10.13%. All learning/prediction/hint policies therefore remain off by default.

#### DSA and served API

The paired DSA matrix measured 24 eligible fresh-process cells (2K/8K × DSA
off/on × MTP off/on × three repeats), all with exact cold/warm/repeat/MTP
tokens. Positive decode delta means DSA was faster; negative wall delta means
less total time.

| context | MTP | paired median decode delta | paired median wall delta | decision |
|---:|---|---:|---:|---|
| 2,048 | off | -2.80% | +4.14% | no speed claim |
| 2,048 | on | -32.90% | +20.95% | regression |
| 8,192 | off | +12.38% | -1.89% | below 5% total-wall win gate |
| 8,192 | on | -34.33% | +8.19% | regression |
| 32,768 | off/on | not run | not run | ineligible: 27.320/28.540 GiB exceeds 25 GiB |

The checkpoint's 21-full/57-shared schedule remains a semantic requirement,
but no DSA product-speed claim is made. Stage-2 manifest SHA-256:
`90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.

Finally, the fresh real-artifact G7 smoke returned HTTP 200 with correct
envelopes for chat completions, text completions, Anthropic Messages, and
OpenAI Responses; SSE used `text/event-stream`, emitted four events, ended in
`[DONE]`, and reported the truthful `serial+spec` lane. Health, discovery,
exact-plan stats, and post-run idle rows also passed. This is protocol/API
evidence, not a throughput benchmark.

Primary raw records: machine-local `runs/colibri-g5/{summary,mtp-on,mtp-off}.json`,
`runs/colibri-g6-learning-shakeout-2026-08-15/summary.json`, and
`~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`.

### Served (warm) — the path agents actually use

decode tok/s · TTFT ms · server-ready s · steady RSS GB

| model | mlx-bun (mixed) | mlx-bun (bf16) | mlx-lm (bf16) | optiq (mixed)† |
|---|---|---|---|---|
| MiniCPM5-1B | **252.9** · 34 · 0.17 · 1.22 | — | — | 223.6 · 64 · 0.84 · 1.82 |
| gemma-4-e4b | 55.7 · 44 · 0.36 · 7.14 | **57.3** · 48 · 0.36 | 53.5 · 218 · 0.98 · 7.55 | 53.4 · 221 · 0.78 · 7.53 |
| gemma-4-12B | **25.9** · 85 · 0.38 · 9.46 | — | — | 25.5 · 326 · 1.24 · 9.86 |
| gemma-4-26B | 54.2 · **45** · 0.47 · 18.25 | **55.0** · 44 · 0.47 | 52.3 · 228 · 0.77 · 4.87 | — |

† **The served `optiq (mixed)` cells are effectively bf16** — optiq's
KV-quant patch is inert on mlx-lm 0.31.3's batched server path:
`install_mixed_kv` hooks `mlx_lm.generate.maybe_quantize_kv_cache` and
`mlx_lm.server.stream_generate`, but the server routes every *seedless*
text chat request through `BatchGenerator`, which calls neither hook, and
the h2h harness's server requests carry no `seed`. See
`lab/repro/optiq-mixed-kv-inert/` for the mechanism + repro. The data
fingerprint agrees: e4b optiq-mixed served 53.4 tok/s · 7.53 GB RSS ≡
mlx-lm bf16's 53.5 · 7.55. Same caveat applies to any serve-mode
optiq-mixed cell in raw `benchmarks-serve-*` artifacts dated ≤ 2026-07-06.
The **Direct** and **Long context** optiq (mixed) rows below DID measure
real quantized-KV execution (the legs passed `kv_bits=8` straight into
`mlx_lm.generate.stream_generate` — old `bench.ts --baseline-kv config` —
so the 64k collapse and the lower peaks are genuine quantized-KV
behavior), but a second installer defect means the scheme was **uniform
8-bit, not the per-layer map**: `install_mixed_kv`'s hook patch lands on
the `generate` *function* that shadows `mlx_lm.generate` in mlx-lm's
package namespace, never on the module, so mlx-lm's stock uniform
`maybe_quantize_kv_cache` is what ran (empirically proven in the repro
dir). Read "optiq (mixed)" in those two tables as "optiq (uniform kv8)".
mlx-bun (mixed) columns are unaffected — our engine implements the
per-layer scheme natively — and the L2 parity goldens stay valid: every
`regen-*` oracle script applies the scheme explicitly (direct per-layer
`to_quantized`, or calling optiq's patched hook by name), never through
the dead serve-path indirection.

Across every served model: mlx-bun has the fastest decode and the fastest
TTFT/startup (2–5×), at ~0% server tax vs its own direct engine.

### Served h2h post-consolidation (2026-08-22, e4b, single pass — directional)

Real servers via `bench-serve.ts` on merged main `4103ae1`; loaded machine
(ambient loadavg ~3), so treat as directional until a quiet-box pass. Full
findings + root-cause sweep: PLAN.md "Prefill vs mlx-lm (2026-08-22)".

| arm | prefill@1k tok/s | ttft cold/warm ms | decode tok/s | parity |
|---|---:|---|---:|---|
| mlx-bun | **1143** | 578 / **39** | **53.9** | ✓✓ byte-identical |
| mlx-lm | 866 | 772 / 230 | 50.3 | (oracle) |

Served prefill stays a decisive mlx-bun win (+32% @1k, warm TTFT 5.9×)
after the serving-architecture merge. Engine-direct prefill is
parity-within-noise elsewhere (cpm5/12B/26B; e4b@256 fresh-process −12%
is the one reproducible engine-level residual). Chunk-size tuning below
the 2048 convention is NOT L1-safe: logits are convention-pinned in BOTH
stacks (mlx reduction-order sensitivity; python drifts more than we do).
Open lead from this pass: e4b agg×4 read 26.6 vs mlx-lm 107.3 — RESOLVED
same day as a `443f333` regression (bf16 BatchedRotatingCache lost its
signature-based route in the join merge → whole-batch drop on joiners;
PLAN.md "agg×4 regression"). Post-fix: 122-126 tok/s aggregate, matching
pre-merge.

### Direct (engine only)

decode tok/s · prefill tok/s · gen-peak GB

| model | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| MiniCPM5-1B | 268.6 · 1817 · 1.01 | 241.9 · 1651 · 1.01 | **271.0** · 800 · 1.03 | 249.5 · 706 · 1.03 |
| gemma-4-e4b | **57.1** · 304 · 6.61 | 55.7 · 283 · 6.61 | 56.5 · 373 · 6.65 | 56.1 · 368 · 6.65 |
| gemma-4-12B | **26.0** · 168 · 8.99 | 25.8 · 166 · 8.99 | 25.9 · 141 · 9.10 | 25.7 · 137 · 9.00 |
| gemma-4-26B | 55.0 · 206 · 17.71 | 53.9 · 208 · 17.71 | **55.6** · 187 · 17.78 | 55.0 · 190 · 17.72 |

Direct decode is at parity-to-slightly-behind mlx-lm (the residual host
overhead per step); prefill leads on the larger models. See PLAN.md
"Decode gap RESOLVED" for the root-cause/fix history.

### Logprob metadata readback (2026-07-29)

Paired internal before/after measurement on the M1 Max 32 GB,
Qwen2.5-0.5B-Instruct-4bit, Bun 1.3.14: 256 generated tokens, two warmups,
five randomized measured rounds. This isolates mlx-bun's API metadata
readback; it is **not** a Bun-versus-Python FFI comparison.

| arm | before total / decode | after total / decode | overhead vs off, before → after |
|---|---:|---:|---:|
| off | 802.75 ms / 328.92 tok/s | 803.94 ms / 328.81 tok/s | control |
| `logprobs` | 1,185.89 ms / 220.52 tok/s | 802.77 ms / 329.18 tok/s | +47.7% → −0.1% |
| `top_logprobs=5` | 1,354.21 ms / 192.69 tok/s | 856.24 ms / 307.63 tok/s | +68.7% → +6.5% |

The fix reads uint32 IDs directly and expands the few bf16/f16 values on the
host instead of queueing `astype(float32)` behind the already-dispatched next
decode step. The off control stayed flat; all 40 parity checks and all 1,280
selected/top-k comparisons were exact. Clean commits: before `00e597e`, after
`b1cb7cb`. Raw artifacts are recorded in the Phase 22 ledger in
`docs/archive/investigations/pre-colibri-stabilization.md`.

### Long context (gemma-4-12B) — where the gap opens

decode tok/s · gen-peak GB

| context | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| 16k | 23.9 · 11.82 | 23.5 · 10.61 | 23.9 · 11.72 | 21.6 · 11.19 |
| 64k | **20.9** · 15.77 | 18.7 · 10.46 | 20.9 · 15.91 | 12.3 · 14.89 |

At 64k mlx-bun holds parity with mlx-lm on bf16 while optiq collapses to
12.3 tok/s; mlx-bun's mixed-KV trades ~2 tok/s for ~5 GB lower peak.

### Attempted but failed (2026-06-14)

- `gemma-4-12B/optiq/kv=config`: `quantized_matmul` weight/scales
  shape mismatch (upstream optiq bug; tracked). _(Relabeled from the
  old-legend name "e4b" = hash `5b…` = 12B; no gen-peak was recorded for
  this failed run, so the model id here is inferred from the legend, not
  fingerprinted.)_

---

## 3. Quality — for non-bit-exact (Lab) optimizations only

When a custom path trades bit-exactness for speed, quantify the cost so a
perf win is only claimed with its quality delta — e.g. *"+23% tok/s while
holding ±5% on the 6-test mean."*

- **6-test mean** — mean score across `src/eval/tasks/`: bfcl, gsm8k,
  hashhop, humaneval, ifeval, mmlu — optimized path vs the compatible
  upstream.
- **KL divergence** — optimized vs compatible token distribution.

This section is the home for a Lab experiment's quality measurements
when it's promoted (the bar: paired-A/B win vs L1 on a stable pass +
KL PASS — see docs/design/unified-engine-frontier-plan.md §6-7).

### TurboQuant KV quality-vs-bpw (2026-07-06, M1 Max 32 GB, MiniCPM5-1B)

> Note: measured on an M1 Max 32 GB, not this file's M4 Pro reference
> box — valid as a paired quality/KL measurement (machine-independent),
> not as a perf number.

Opt-in memory/context scheme (`--kv-quant turbo[:k<bits>v<bits>]`), not a
speed lever. Teacher-forced serving-decode KL vs bf16 KV (8×128 tokens, 32
decode steps, `eval-turboquant-curve.ts (deleted; git history)`); affine rows same harness:

| scheme | effective KV bits | KV compression | mean KL vs bf16 |
|---|---|---|---|
| uniform kv8 (g64) | 8.50 | 1.88× | 0.00246 |
| turbo k8v8 | 8.75 | 1.83× | 0.00214 |
| turbo k8v4 | 6.75 | 2.37× | 0.00936 |
| **turbo k8v3 (default)** | **6.25** | **2.56×** | **0.0325** |
| uniform kv4 (g64) | 4.50 | 3.56× | 0.0516 |
| turbo k4v3 | 4.25 | 3.76× | 0.0622 |
| turbo k4v2 | 3.75 | 4.27× | 0.205 |

Read: turbo k8v3 beats uniform kv4's KL at 2.56× compression; k4v3 is
on-curve with affine at matched bits; 2-bit values are the cliff (matches
the TurboQuant paper's law). Codec is bit-exact vs the vendored vllm-metal
reference (goldens/turboquant.json); details in
docs/design/turboquant.md.

## 4. Composition — feature-default decisions (measured, per pair)

The doctrine (docs/design/speculative-decoding.md Phase 4e): a feature is ON by
default for a (model, config) pair only when it WINS a clean-machine
paired A/B on that pair; losing configs stay documented default-off
levers. This section records the decisions and the numbers behind them.

### Packed Trellis with KV4/MTP and paired prefixes, M4 Pro, 2026-09-08

The configured serial suite passes every phase on the required 12.14 GiB
packed Trellis artifact at clean commit `1a80401`, with unchanged source
hashes throughout. Machine: `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB,
Bun 1.4.0, bundled MLX 0.32.2. Quiet preflight passes. This is one run,
not a matched original/final performance claim or a new Kanban task.

| Metric | Result |
|---|---:|
| Short-prompt decode, median of five 192-token samples | **18.806 tok/s** |
| Short complete-request time, median | **11.389 s** |
| Output / complete-request time, median | 16.859 tok/s |
| Cold TTFT, median of three approximately 1K probes | 6.537 s |
| Warm TTFT, 754 cached tokens | **94.586 ms** |
| Approximately 1K prefill estimate, median | 115.747 tok/s |
| Context probe, actual input tokens | 2,677 |
| Context prefill estimate | 116.808 tok/s |
| Context decode, median of three samples | 22.763 tok/s |
| Cached context TTFT | 95.434 ms |
| Peak sampled process RSS | 11,973.656 MiB (11.693 GiB) |
| Phase failures | 0 |

Arguments are `--draft-kind mtp --num-draft-tokens 2 --kv-quant 4
--prompt-cache 4`, with the folded RTN4 MTP draft. Runtime overrides select
Trellis variant 13, uniform KV4 speculation, paired MTP prefixes and prefill
chunks of 256. Async Trellis expansion, early-first-token and structural fill
are off. Workload seed is `pr47-block-0`, thinking is enabled, and the
requested context target is 4,096; the table reports the actual token count.
All five short samples emit exactly 192 tokens with no reused prefix.

The speculative prefix store is RAM-only. Restarting restores zero cached
tokens and the context request takes 24.404 seconds to first output. The
ordinary SSD flush returns durable with zero entries; this is not proof of
speculative SSD persistence. No stock mlx-lm arm supports this packed artifact.
The faster context decode sample reflects a different prompt and MTP acceptance
workload; it does not establish that increasing context makes inference faster.

Raw evidence: `reports/qwen38-rd/pr47-trellis-kv4-mtp-serve.md` and its `.md.json`
companion. These serving timings are separate from the completed fresh Pi
Kanban measurement below.

### Original and optimized serving diagnostics, M4 Pro, 2026-09-07

Machine: `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, Bun 1.4.0.
`bench-serve.ts all` used workload seed `kanban-final-0`, thinking enabled,
192 requested output tokens and five decode samples. These are earlier
diagnostic runs, with existing swap, rather than final-PR quiet acceptance.
All columns below use the serial serving lane and the required packed target
weights. Baseline uses `673b43f`, Trellis variant 6 and the older native library;
optimized arms use variant 13, the lossless interleaved artifact and the local
MLX 0.32.2 candidate. Each run's source stayed fixed.

All three serving arms use **bf16 KV**, with `--kv-quant off`. The MTP arm
adds two drafts and paired RAM prefixes. This differs from the completed
long Kanban task's KV4 configuration. These runs predate the later ownership
and bounded-range fixes, so they do not measure the exact final task revision.

| Serial serving metric | Original | Optimized, ordinary decode | Optimized, MTP + RAM cache |
|---|---:|---:|---:|
| Median decode, tok/s | 10.140 | 11.712 | 19.426 |
| Cold-request TTFT, ms | 5,923.576 | 6,164.498 | 5,801.504 |
| Cached TTFT, ms | 190.841 | 436.308 | 91.916 |
| 1K prefill, tok/s | 127.963 | 122.962 | 130.522 |
| Peak process RSS, reported MB | 11,958.984 | 13,859.828 | 12,061.219 |

Ordinary decode improves **15.5%**. The MTP configuration improves decode
**91.6%** relative to the original, with cached TTFT **51.8% lower**.
Its cold TTFT changes by -2.1%, prefill by +2.0%, and sampled RSS by +0.9%.
Ordinary decode's gain does not extend to every metric: its cached TTFT and
RSS regress in this diagnostic. The percentages describe these specific
serving configurations; they are not a measured Kanban task-time reduction.

The baseline context phase crashed and recovered on retry; no context-phase
speedup is claimed here. MTP prefix state is RAM-only: the restart probe
restored zero tokens and does not establish SSD persistence. Stock mlx-lm
cannot read this packed Trellis artifact, so it supplies no same-artifact
serving baseline for these rows.

Raw evidence: `reports/qwen38-rd/kanban-final/suite-driver.json`,
`baseline-suite.md.json`, `optimized-ordinary-suite.md.json`, and
`optimized-mtp-cache-suite.md.json`. The driver records all commands,
environments, source hashes and exits. The completed task and its separate
acceptance are recorded below.

### Fresh Pi kanban diagnostic, M4 Pro, 2026-09-07

Machine: `Joshs-MBP-2025.local`, M4 Pro, 24 GB; Bun 1.4.0, Pi 0.85.1,
MLX 0.32.2. These are task diagnostics with existing swap. The first attempt
also had a brief background browser-test CPU burst. Neither is a quiet-machine
speed claim.
The model is the required 12.14 GiB packed Qwen3.8-27B Trellis artifact with
lossless interleaving. The selected Luke profile is
`qwen3.8-27b-q3_k_xl-coding-128k`, pinned at repository commit
`3288d1918fa6140c10f3b2de2d37f9d717a5ab75`. It uses the unchanged prompt,
xhigh thinking, temperature 0.6, seed 42 and 131072 context. The MLX mapping
uses target affine KV4 group64, two MTP drafts, paired RAM prompt prefixes
and 256-token prefill chunks.

| Attempt | Time until Pi stopped | Output tokens | Overall tok/s | First-turn tok/s, including prefill | First reasoning TTFT | Peak server + Pi RSS | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| History fixed; original tool-value parser | 65m 30.245s | 53,631 | 13.646 | 15.965 | 22.869s | 12.042 GiB | Failed: only HTML and two JS modules; final edit call remained assistant text |
| History and tool-value parsing fixed | 106m 6.531s | 82,015 confirmed | 12.882 | 16.154 | 22.892s | 13.795 GiB | Failed inference: Metal out of memory at the 85,238-token request; Pi did not finish |

All four request prompt counts matched independent renders. Later requests
reused 2,549, 53,174 and 54,859 prompt tokens, with MTP active. Pi had no
automatic retries or compactions. Its clean process exit did not mean the
app was complete: the mandatory README was absent and most app files were
never written. The untouched output fails acceptance. No successful task
completion time or matched task-time speedup is established by this row.

The saved final edit parameter is valid JSON. The engine decoded XML
entities before JSON parsing and its repair pass misidentified the nested
array as the outer call. The corrected parser preserves the complete argument
array through the actual tokenizer and streaming path.

The fresh attempt with both fixes completed ten requests. Every completed
prompt count matched the independent render and every response used MTP.
The aggregate accepted/drafted ratio was 80.038%. The first tool transition
took 524.244 seconds to first output while processing newly generated history.
Later requests reused progressively longer prompt prefixes. The cache still
captures prompt boundaries rather than the newly generated history.

The eleventh request reached a Metal allocation failure after its first
reasoning fragment. Its terminal usage was unavailable, so the output total
counts only completed responses. The wall-clock interval includes that failed
request, prefill, tools and agent overhead. Ten completed response intervals,
excluding TTFT, average 15.270 output tokens/s. This is distinct from both
overall task throughput and the short-context serving-suite decode rate.
There were no retries, compactions or tool errors. Engine source hashes stayed
fixed. All inference processes exited during bounded cleanup.

The untouched app has HTML, CSS, twelve JavaScript modules and package.json,
but no README. Syntax checks pass. A separate browser smoke test after server
shutdown shows the default columns and keyboard card creation work, but opening
the editor throws `ReferenceError: renderLabels is not defined`. Remaining UI
checks were not run after that blocking failure. No app edits or repair prompts
were supplied. These are findings about an incomplete artifact, not a completed
model submission. No successful completion time or matched task-time gain exists.

Process RSS does not measure all Metal allocations. The out-of-memory failure
does not establish the model's architectural context limit; the tested KV4,
MTP and retained-prefix combination needs a separate memory diagnosis.

Protocol and design: [decode-speed-program §7.7](../../design/decode-speed-program.md#77-gates-scheduling-and-completion).
Raw evidence: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-history-fixed/`
and `luke-q3-128k-xhigh-tool-values-fixed/`, including `quality-static.json`,
`quality-browser.json` and screenshots. Portable report:
`reports/qwen38-rd/kanban-final/comparison.html`.

### Kanban capacity diagnosis, M4 Pro, 2026-09-08

Native Bun screen on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, using the
same 12.14 GiB target, MTP head, MLX 0.32.2 candidate and KV4/prefix settings
as the failed Pi attempt above. The saved failing history renders to 85,238
tokens. Fixed text tokens extend it to 110,000 for this capacity screen.
No Pi task runs in this screen. Sampling follows the selected profile, but
EOS stopping is disabled to require a short continuation. This is neither
a fresh task result nor a quiet-machine performance claim.

The unchanged control finished target prefill and emitted one token, then
failed with Metal out of memory in the first MTP draft round. Its wall time
was 1,482.497 seconds. Peak active Metal allocation reached 19,451,721,310
bytes against a recommended working set of 19,069,665,280 bytes. Immediately
before draft prefill, active allocation was 14,593,938,440 bytes; at the
first emitted token it was 17,494,527,842 bytes. The retained prefix reported
2,633,836,544 logical bytes. These counters measure different things from
process RSS and do not establish a model context limit. Source hashes stayed
fixed; the worker exited with failure and bounded cleanup completed.

Raw control: `reports/qwen38-rd/kanban-capacity-110k-control.json` and its
allocation event log. A focused small ownership regression retains 8,405,016
bytes before the fix, despite requiring only small KV state and one hidden
row. The isolated candidate now evaluates draft KV at each existing prefill
chunk and materializes the retained final hidden row. The ownership,
prefix-position and provider-disposal tests pass. Full-model exactness and
large-context acceptance are checked separately. A sampling-failure
regression retains 524,288 bytes before scoped disposal; it now passes the
under-4-KiB cleanup guard without running GC after the failure.

The final-source small native comparison uses the same first 8,192 history
tokens and generates 32 tokens twice. Before and after the ownership changes,
both responses and all MTP acceptance decisions match exactly. Each process
first prefills from zero, then restores 8,191 cached tokens. Peak active
allocation is 13,330,783,014 bytes before and 13,105,695,458 after. Both source
manifests stay fixed. This is one correctness/allocation comparison, not a
request-time speed claim. Typechecks pass. Evidence: `kanban-capacity-8k-final-comparison.json`
and its two referenced control/candidate reports in `reports/qwen38-rd/`.

The final native capacity screen passes at 110,000 prompt tokens. It completes
three identical 256-token continuations, with 109,999 tokens restored on each
cached request. Between the latter two, an intentional output-sink error after
eight emitted tokens exercises request cleanup. Retained active allocation is
14,911,641,794 bytes after every completed or intentionally failed request.
The next request recovers in the same process and reproduces the continuation.
Peak active allocation is 17,981,018,362 bytes, 1,470,702,948 bytes below the
failing control, despite the longer continuation. The first request takes
1,525.095 seconds including full prefill; the two complete cached requests take
33.148 and 33.175 seconds. Instrumented synthetic-context timings are not
Kanban completion estimates. Final provider/weight disposal leaves 101,892,102
active bytes; the equal per-request counters establish no incremental retention
from the injected failure, not zero global runtime allocation. The worker exits
successfully, its source hashes stay fixed and its deadline is not reached.

The main source has the same ownership fixes. Its focused memory/provider tests
and a real-target MTP/non-MTP short greedy identity gate pass, as do all
typechecks.
Native evidence: `reports/qwen38-rd/kanban-capacity-110k-owned-final.json`.

The saved-history HTTP gate also passes on the isolated candidate. It first
replays the exact failed request, then appends that response and synthetic
tool/user history to test growth. Tool calls are recorded but never executed
by this diagnostic. Each response allows up to 512 output tokens and stops
naturally. Both repeated responses preserve all text, tool arguments, output
counts and MTP acceptance decisions.

| Prompt tokens | Cached tokens | Output tokens | Complete request, s | TTFT, s |
|---:|---:|---:|---:|---:|
| 85,238 | 0 | 42 | 988.103 | 984.951 |
| 85,238 | 85,237 | 42 | 3.283 | 0.225 |
| 110,014 | 85,237 | 92 | 401.843 | 393.126 |
| 110,014 | 110,013 | 92 | 8.931 | 0.255 |

Source hashes stay fixed and server cleanup exits successfully. This validates
serving capacity and cache reuse, not a completed Kanban task. Raw evidence:
`reports/qwen38-rd/kanban-memory-http-owned.json` and the saved request/response
files beside it. These checks exercise short continuations. The fresh Pi
retry below still fails during sustained generation.

During the saved-history HTTP prefill, simultaneous read-only `/health` and
`/stats` requests both returned 200, taking 4,776.475 and 4,776.682 ms. This
single busy-server observation does not establish an idle baseline or latency
distribution. It identifies responsiveness during native prefill for a separate
serving check. Evidence: `reports/qwen38-rd/kanban-memory-http-responsiveness.json`.

### Fresh Pi Kanban after MTP ownership fixes, M4 Pro, 2026-09-08

The fresh retry on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, failed with
Metal out of memory after **106m 5.416s**. It used the same 12.14 GiB target,
published Luke Q3 128K xhigh profile and unchanged prompt as the preceding
attempt. The source and every saved request's profile pass the post-run audit.
The first request body is byte-identical to the preceding attempt; its entire
response and MTP acceptance trace also match. Later history includes actual
tool results, including changed directory timestamps.

Eight requests completed, reporting **73,831 output tokens**. The ninth
request started with **77,077 prompt tokens**, emitted its first output after
26.415 seconds and failed after 780.891 seconds, during sustained decode.
Its terminal usage is missing. Retokenizing delivered reasoning estimates
another 5,659 tokens, but excludes buffered tool arguments, so the full
generation count is unknown. The completed-response rate after first output
is 15.658 tok/s; this excludes prefill, tool time and the failed response.
Peak combined server/Pi RSS is **13.836 GiB**. Completed requests report
79.911% MTP acceptance. There were no retries, compactions or tool execution
errors. Pi exited with code zero but reported a terminal error; the task
therefore failed. No successful completion time or task-time speedup is
established.

The untouched app supplies its README and passes syntax, basic card creation,
board/theme persistence, column creation/rename and between-column card drag
checks. The card editor throws `ReferenceError: renderLabels is not defined`;
the archive panel throws `TypeError: K.render.renderArchive is not a function`.
Required functional acceptance fails. Reorder interaction probes remain
unconfirmed because their input simulation needs validation. Independent UI
checks ran only after inference exited. No app code was edited and no repair
prompts were supplied.

The short native and HTTP capacity checks above did not reproduce this long
decode failure. It motivated the sustained allocation check below. Raw result,
source/profile audit and untouched
app checks: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-mtp-memory-fixed/`
contains `result.json`, `measurement-audit.json`, `quality.json` and its
referenced evidence.

### Sustained Kanban decode allocation diagnosis, M4 Pro, 2026-09-08

A fresh native process loaded the failed task's saved **77,077-token** request
and generated **12,288 tokens** with the same model, MTP, KV and sampling
settings. EOS stopping was disabled for this bounded diagnostic; no tools
were executed. The unchanged control completed in 2,408.753 seconds including
923.348 seconds to first output. Decode was 8.272 tok/s. Peak active MLX
allocation was **18,204,808,450 bytes**; **1,593,360,390 bytes** remained active
after provider/weights disposal and allocator-cache clearing. Source hashes
stayed fixed. This is a saved-history diagnostic, not a fresh task result or
a quiet-machine speed claim.

The large-range cache retained every distinct causal-mask range above 65,536
elements. Early comparable rounds each added **311,296 bytes**, matching the
page-rounded int32 range allocation. A focused regression with 256 changing
context lengths retained **79,790,080 bytes** in the old implementation and
**7,258,112 bytes** after bounding cached array data to 8 MiB. Three oversized
ranges retained **37,748,736 bytes** before and **zero additional bytes** after.
The regression fails before the change and passes after it, including exact
range values, vocabulary reuse and lazy-view ownership after eviction. Eight
focused main-source tests, the candidate regression and both workspace
typechecks pass.

Reconstructing the target prefill lengths and verification windows from the
control's acceptance trace predicts 4,685 distinct large mask ranges occupying
1,592,344,576 page-rounded bytes. That accounts for more than 99.9% of the
observed allocation left after model disposal. This is allocation attribution
from the recorded execution and source, not a measurement of every cache entry.

The bounded-cache full-model repeat passes: all **12,288 output tokens** and
all **4,638 MTP acceptance decisions** are identical. Source and harness hashes
stay fixed, with `src/mlx/ops.ts` the only engine difference between arms.
Both runs exit normally without cleanup errors.

| Native diagnostic metric | Unbounded cache | Bounded cache |
|---|---:|---:|
| Complete request time | 2,408.753 s | 2,461.051 s |
| Time to first output | 923.348 s | 939.902 s |
| Decode rate | 8.272 tok/s | 8.078 tok/s |
| Peak active MLX allocation | 18,204,808,450 B | 16,622,195,970 B |
| Active MLX allocation after model disposal | 1,593,360,390 B | 8,224,774 B |
| Observed peak process RSS | 14,324,711,424 B | 12,745,523,200 B |
| OS lifetime peak process footprint | 18,969,882,768 B | 18,826,963,720 B |

Peak active allocation falls by **1,582,612,480 bytes**. The single diagnostic
pair takes **2.171% longer**, so it establishes a memory/ownership correction,
not a throughput gain. RSS, active allocation and physical footprint remain
distinct measurements. The process monitor started during control prefill
and before candidate prefill; native allocation instrumentation is identical.
The fresh Pi task with this correction completed; its separate task result
and functional acceptance are recorded below.

Raw evidence: `reports/qwen38-rd/kanban-sustained-77k-owned-control.json`, its
allocation/process-memory traces, `kanban-arange-allocation-evidence.json`,
`kanban-arange-regression.json`, `kanban-arange-micro-memory.json` and
`kanban-arange-reconstruction.json`. Full-model comparison:
`kanban-sustained-arange-comparison.json`, with both raw runs and their traces.

### Completed fresh Pi Kanban with bounded range cache, M4 Pro, 2026-09-08

The untouched app passes the required functional checks after a fresh Pi run
on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, using the required 12.14 GiB
Trellis target. The published Luke Q3 coding 128K profile, unchanged prompt,
xhigh thinking, sampling and seed 42 remain fixed. The candidate uses MLX
0.32.2, target KV4, MTP depth 2 and paired RAM prefixes. Processes, application
caches, Pi session and task workspace started fresh; OS file cache was not purged.

| Completed task metric | Result |
|---|---:|
| Prompt submitted to Pi settled | **3h 33m 7.685s** |
| Including server startup | 3h 33m 8.581s |
| First request time to first output | 23.145 s |
| Reported output tokens, including reasoning and compaction | **130,494** |
| Completed inference requests | 62 |
| Output / whole task elapsed time | 10.205 tok/s |
| Completed-response rate after first output | 13.904 tok/s |
| Sum of request time before first output | 56.665 min |
| MTP draft-token acceptance | 79.706% |
| Peak sampled combined server/Pi RSS | 11.916 GiB |

All 443 source, profile, request, usage and timing audit checks pass. Every
response has terminal usage; the output total is exact. Pi and the server
exit normally, with no inference error or automatic retry. Pi encounters
seven tool execution errors during its own debugging and completes the task
without external repair prompts.

One context compaction is included in the total. Its summary request uses
90,214 input tokens, reports 1,404 output tokens, and takes **19m 42.705s**,
including 17m 37.551s before first output. The following coding request has
28,126 input tokens and takes another 4m 22.552s before first output.
Both prompts have zero cached tokens because the summary changes the exact
serialized prefix. The first ordinary tool turn separately takes 8m 53.415s
before first output after the initial 50,533-token response; its cached prefix
contains only 2,549 tokens. These are measured targets for reducing repeated
prefill, not claimed savings. The frozen outcome helper recorded zero
compactions because it recognized only `auto_compaction_start`; derived
reports count the observed `compaction_start` while preserving the raw result.

The server's last observed OS lifetime peak physical footprint is
**18,913,094,336 bytes**. The external monitor began during the task and
sampled through five seconds before exit; lifetime counters include earlier
process history but may miss the final interval. Physical footprint and the
runner's sampled combined RSS are different measurements. Separate process
lifetime peaks are not added as though they were concurrent.

After inference exited, independent browser checks passed card creation,
required-title editing, description/labels/assignee fields, combined filters,
archive/restore, column creation/rename/safe deletion/restore, native card
and column reordering, the Done indicator, and persisted theme/board/order.
The app supplies run instructions and modular vanilla code. No generated
source was edited. Earlier automated reorder probes remain recorded; native
mouse motion with dragover before release confirms both reorder operations.

This establishes a completed task on the frozen candidate. There is no
matched successful original baseline, so it establishes no task-time speedup
percentage. The complete first response and every MTP acceptance decision
match the preceding failed attempt; its time changes from 3,152.595 to
3,147.633 seconds, effectively flat in one pair. The bounded range cache's
measured benefit remains retained-memory correction and successful completion.

Raw evidence: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-arange-bounded/`
contains `result.json`, `measurement-audit.json`, `quality.json`, referenced
browser evidence, `memory-summary.json`, the untouched app and saved sources.
The derived HTML report is `reports/qwen38-rd/kanban-final/comparison.html`.

Offline analysis of this successful trace reconciles all 62 terminal usage
records to 130,494 output tokens, including the 1,404-token compaction. The
server reports 3,980,688 cumulative prompt tokens and 3,701,542 cached tokens
through the enabled paired target/draft RAM prefix cache; these are repeated
request counts, not unique text or a measured time-saving percentage. An
exact-substring analysis of 593,994 Unicode characters from 380 original
input/output segments finds 2,830 maximal repeats of at least 32 characters
(after excluding separator noise). The longest is 10,304 characters, a file
write followed by a read. Replayed history and duplicated log events are
excluded; nested/overlapping repeat families remain, so counts do not imply
removable work. Local derived evidence and methodology:
`~/.cache/mlx-bun/analysis/kanban-success/{analysis,duplicates}/report.md`,
with the hashed source snapshot, per-request counts and repeat locations.
Token-ID analysis of those same independently retokenized segments contains
160,352 tokens and 2,756 maximal repeats of at least eight tokens after the
same noise filter; the longest is 2,732 tokens, occurring twice. This is
reconstructed-text tokenization, not the sampled-token stream. Methodology,
source/tokenizer hashes, all matches and histogram are retained alongside
that evidence under `kanban-success/token-duplicates/`.
Counting only later generated positions matching earlier generated content,
with first occurrences retained and overlapping intervals merged, gives
48,932 duplicated retokenized positions at the eight-token cutoff, including
26,965 tool-argument positions matching prior reasoning. At a 32-token cutoff
the total is 26,602. These are approximate 37.50%/20.39% shares of the 130,494
reported output tokens: the normalized generated corpus has 127,905 tokens
and excludes wire framing/escaping. They are not measured time savings.
Method and interval evidence: `generated-duplicate-report.md` and its JSON
companions in the same token-analysis directory.

A narrative reconstruction with an embedded source browser is saved at
`~/.cache/mlx-bun/analysis/kanban-success/timeline/kanban-story.html`.
Its clock uses cumulative completion tokens and places external actions at
completed assistant-response boundaries: the first tool action follows
50,533 generated tokens. The account distinguishes code drafted in reasoning, file writes,
repairs to the synthetic DOM test harness, and concrete application fixes.
The trace identifies candidates for shortening the run; it does not establish
which reasoning could be removed while preserving the successful outcome.

### Speculative decoding — "should spec be on?" (decision pending Phase 0/1 runs)

Decision rule: spec defaults ON for a (target, drafter) pair iff
serve-path decode ≥ 1.3× serial at the recommended γ, clean-machine
paired (`scripts/bench-serve.ts all` preflight, `bench-feature-matrix.ts --cells
serial,spec`), with acceptance within 3 pts of the bf16-drafter baseline
(`scripts/dspark.ts ab`). Prediction to test: ON for
12B + quantized DeepSpec drafter, OFF for e4b + anything.

| target | drafter | γ | acceptance | τ | spec tok/s | serial tok/s | verdict |
|---|---|---|---|---|---|---|---|
| 12B-OptiQ-4bit | DeepSpec bf16 (6.9 GB) | 7 | 26–33% | ≈2.8 | 14.6 agg | 49.8 agg | **OFF** — drafter tax −3.4× (2026-07-07 first live run, loaded box, conc-4; directional) |
| 12B-OptiQ-4bit | DeepSpec affine-q4-g64 (1.8 GB, built 2026-07-07) | best-of-0b | _1d run_ | _1d run_ | _0b/6 run_ | _0b/6 run_ | _pending_ |
| e4b-OptiQ-4bit | (expected-negative control) | — | — | — | — | — | _pending_ |

Runbook (Josh's shell; directional passes fine loaded, the FINAL pair
clean-machine per the house rule):
1. **1d acceptance A/B** (no server): `bun scripts/dspark.ts ab
   --target gemma-4-12B-it-OptiQ-4bit --drafter-a <bf16-snap>
   --drafter-b <q4-snap> --json ab-q4.json` — gate: drop ≤ 3 pts AND
   wall-clock strictly improves.
2. **0b γ sweep** (server): serve 12B `--draft-model <q4-snap>
   --num-draft-tokens {2,3,5,7}` × `bun scripts/bench-matrix.ts features
   --concurrency 1 --cells serial,spec` — pick best-γ by per-request tok/s.
3. **Phase 6 decision pair** (clean machine: reboot + `sudo purge`):
   best-γ config, `--cells serial,spec` at conc 1 AND agg×4 — fill the
   table, flip the features-matrix default cell if ≥ 1.3×.

### TurboQuant KV — decided OFF (2026-07-06, re-affirmed post-leak-fix)

Opt-in memory/context lever, not a speed feature (v1 dequant-on-fetch is
slower per step at long context; no speed claim made). The KL-vs-bpw
curve above is the quality evidence. NOTE: any turbo perf/RSS impression
formed before 2026-07-07 is invalid — the pre-fix build leaked
window-scale buffers per decode step (PLAN Phase 13 post-merge fix).


### Shared Gemma assistant drafting, M4 Pro 24 GB, 2026-09-10

Four `bench-serve.ts all` arms in control/candidate/candidate/control order,
Bun 1.4.2, MLX 0.32.2. Gemma4 12B OptiQ4 target with its bf16 assistant,
draft depth 2, bf16 target KV, 2 GiB RAM cache plus temporary SSD, 192 decode
tokens, four concurrent requests and default capacity eight. Workload seed
`assistant-spec-0`; diagnostic mode under Josh's CPU/swap policy. Source snapshots
`c8213540beb87f438fbafad7115b49f494e92526c28acca930f134883d5cfdcf`
→ `db38e64dbc3421ba5750485d8d6328afad63b64883bae8b945ff76e0ae6f1f21`.
The candidate includes the shared assistant graph/provider, hidden companions,
donor validity ports and the oracle-aligned strided weight views.

| Metric, mean of two arms | Previous implementation | Shared assistant | Change |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.637 | 26.583 | +3.69% |
| Four-request aggregate, tok/s | 24.815 | 34.129 | +37.53% |
| Four-request wall time, ms | 20,632.8 | 15,002.1 | −27.29% |
| Cached prefill, ms | 2,573.4 | 116.7 | −95.47% |
| Cold prefill, ms | 2,581.1 | 2,527.6 | −2.08% |
| Server readiness, ms | 723.5 | 1,016.1 | +40.45% |
| Cold start, ms | 2,244.1 | 2,094.7 | −6.66% |
| Peak RSS, MiB | 9,744.6 | 10,042.8 | +3.06% |

All 60 requests complete without failures with matching request bodies and token
budgets. Single-request text and raw completion/chat probes match. Three of four
concurrent responses differ across implementations; each implementation repeats
exactly, including usage. Shared cached requests reuse 668 tokens, versus zero.
Mean cold-start improvement is within substantial variation: candidate arms are
1.712 and 2.478 seconds. Readiness regresses by 293 ms; strict startup dominance
remains open. These numbers compare implementations with the same assistant,
not assistant speculation versus ordinary decoding. Defaults are unchanged.

Both-machine e4b/12B graph and serving/cache tests pass; e4b matches unmodified
optiq `spec_generate` end to end. The pinned 12B loader lacks tensor-presence head
detection, so its numerical test explicitly binds the artifact's tied embedding
head while retaining upstream layers. Both-machine Qwen MTP/TQ regressions, full
suites and all typechecks pass. Evidence:
`reports/qwen38-closeout/composition-baseline/assistant-batch/`.


### Shared DeepSpec drafting, M4 Pro 24 GB, 2026-09-10

Four `bench-serve.ts all` arms in control/candidate/candidate/control order,
Bun 1.4.2, MLX 0.32.2. Gemma4 12B OptiQ4 target with the DeepSpec affine-q4-g64
drafter, trained depth seven, bf16 target KV, 2 GiB RAM cache plus temporary SSD,
192 decode tokens, four concurrent requests and default capacity eight. Seed
`deepspec-spec-0`; diagnostic mode under Josh's CPU/swap policy. Frozen sources
`db38e64dbc3421ba5750485d8d6328afad63b64883bae8b945ff76e0ae6f1f21`
→ `39b289a30244e8f37bc8457c7e8f4e36deae428340157cd90c3a4c2287610dda`.
The candidate adds shared context projections, batched proposals and persisted
method companions. Both arms use the same target, drafter and settings.

| Metric, mean of two arms | Previous implementation | Shared DeepSpec | Change |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.288 | 25.950 | +2.62% |
| Four-request aggregate, tok/s | 25.191 | 53.187 | +111.14% |
| Four-request wall time, ms | 20,326.0 | 9,626.5 | −52.64% |
| Cached prefill, ms | 2,724.6 | 345.1 | −87.33% |
| Cold prefill, ms | 2,715.1 | 2,737.0 | +0.81% |
| Server readiness, ms | 612.5 | 1,319.1 | +115.37% |
| Cold start, ms | 2,509.8 | 2,918.0 | +16.26% |
| Peak RSS, MiB | 10,772.8 | 11,057.6 | +2.64% |

All 60 requests complete without failures and use matching request bodies and
budgets. Single-request text and raw completion/chat probes match. One of four
concurrent responses differs; both implementations repeat exactly, including
usage. Cached requests reuse 671 tokens versus zero. Decode samples within each
arm span roughly 15–16%, although the repeated medians agree. The small B1 gain
should be read with that variation. Readiness regresses by 707 ms and cold start
by 408 ms on average; strict startup dominance remains open. Defaults are unchanged.

Both-machine bf16/4-bit graph controls, depth-seven serving/generated RAM/SSD,
regression suites and all typechecks pass. The graph comparisons preserve the
frozen implementation; they are not a new external DeepSpec oracle. Real-window
checks confirm active shared speculation across wrap. Evidence:
`reports/qwen38-closeout/composition-baseline/deepspec-batch/`.


### Shared projected-context extraction, M4 Pro 24 GB, 2026-09-10

Four `bench-serve.ts all` arms, control/candidate/candidate/control, use the same
Gemma4 12B OptiQ4 target, trained DeepSpec q4-g64 drafter, depth seven, bf16 target
KV, 2 GiB RAM plus temporary SSD, 192 decode tokens, four concurrent requests,
default capacity eight and seed `deepspec-spec-0`. Bun 1.4.2, MLX 0.32.2,
diagnostic mode under Josh's CPU/swap policy. Frozen sources
`39b289a30244e8f37bc8457c7e8f4e36deae428340157cd90c3a4c2287610dda`
→ `9f8484fa9dca140b31ad685a2701563ed5a1e0a2638d27f48e31d1df4160f4ab`.
The candidate extracts context ownership for reuse by DSpark/DFlash and DeepSpec.
This measures the extraction with a trained DeepSpec drafter; no trained DSpark
checkpoint was available for its own performance comparison.

| Metric, mean of two arms | DeepSpec-specific owner | Shared context owner | Change |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.800 | 25.695 | −0.41% |
| Four-request aggregate, tok/s | 53.597 | 52.229 | −2.55% |
| Four-request wall time, ms | 9,552.8 | 9,805.0 | +2.64% |
| Cached prefill, ms | 342.2 | 348.3 | +1.79% |
| Cold prefill, ms | 2,722.4 | 2,778.2 | +2.05% |
| Server readiness, ms | 1,318.4 | 1,421.7 | +7.84% |
| Cold start, ms | 2,943.2 | 3,321.3 | +12.85% |
| Peak RSS, MiB | 11,070.5 | 11,068.2 | −0.02% |

All 60 requests complete without failures; every request body, response and usage
record matches across all four arms. Cached requests reuse 671 tokens in both.
The first control cold start is 2.615 seconds; the other three arms range from
3.272 to 3.337 seconds. Candidate aggregate arms are 52.99 and 51.47 tok/s versus
53.75 and 53.44 controls. The measured cost is retained; this is not a speed win
or strict dominance. Defaults are unchanged. Both-machine pinned Markov/RNN and
independent confidence/sampling tests, seeded real-Gemma serving/generated RAM/SSD,
trained DeepSpec regressions, full suites and typechecks pass. Evidence:
`reports/qwen38-closeout/composition-baseline/dflash-batch/`.


### Reused artifact identity, M4 Pro 24 GB, 2026-09-10

Four `bench-serve.ts all` arms, control/candidate/candidate/control, use Gemma4 12B
OptiQ4, trained DeepSpec q4-g64, depth seven, bf16 target KV, 2 GiB RAM plus temporary
SSD, 192 decode tokens, four concurrent requests, default capacity eight and seed
`deepspec-spec-0`. Bun 1.4.2, MLX 0.32.2, diagnostic mode under Josh's CPU/swap
policy. Frozen sources `9f8484fa9dca140b31ad685a2701563ed5a1e0a2638d27f48e31d1df4160f4ab`
→ `e17613b8496e5820bb8f4a193e735a4d9129b5333c851886bb22cbd0c9c41bed`.
The candidate resolves the same full configuration/name/byte SHA-256 through a
shared artifact-identity store. Its unchanged-file memo was populated during
native validation. These fresh server starts hit the identity memo; first-ever
identity calculation still reads all shard bytes. Memo writes are queued.

| Metric, mean of two arms | Rehash each load | Reuse unchanged identity | Change |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.881 | 25.975 | +0.37% |
| Four-request aggregate, tok/s | 52.449 | 52.831 | +0.73% |
| Four-request wall time, ms | 9,761.8 | 9,691.3 | −0.72% |
| Cached prefill, ms | 350.0 | 346.1 | −1.12% |
| Cold prefill, ms | 2,783.3 | 2,763.5 | −0.71% |
| Server readiness, ms | 1,422.2 | 713.1 | −49.86% |
| Cold start, ms | 3,332.1 | 2,709.7 | −18.68% |
| Peak RSS, MiB | 11,072.1 | 10,784.0 | −2.60% |

All 60 requests complete without failures; every request body, response and usage
record matches across all four arms. Cached requests reuse 671 tokens in both.
Candidate readiness is 610/816 ms versus 1,422/1,422 ms; cold start is 2,590/2,829 ms
versus 3,345/3,319 ms. Peak RSS decreases by 288.1 MiB on average. Throughput changes
are small; the material gain is repeat loading. Sampling, draft-depth and KV
defaults are unchanged. Both-machine Qwen MTP/TurboQuant and DeepSpec serving and
generated RAM/SSD, complete suites and typechecks pass. Identity tests cover the
previous digest, zero weight reads on memo hits, file/config/symlink mutation and
failed persistence. Existing KV namespaces remain compatible. Evidence:
`reports/qwen38-closeout/composition-baseline/artifact-identity/`.


### Affine rotating speculation, M4 Pro 24 GB, 2026-09-11

Six `bench-serve.ts all` arms run control/candidate/KV4/KV4/candidate/control.
All use Gemma4 12B OptiQ4 weights, trained DeepSpec q4-g64 at depth seven,
2 GiB RAM plus temporary SSD, 192 decode tokens, four concurrent requests,
default capacity eight and seed `deepspec-spec-0`. Bun 1.4.2 and MLX 0.32.2;
diagnostic mode follows Josh's background-CPU/swap policy. Control and candidate
use bf16 target KV; KV4 changes only that setting on the candidate source.
Frozen source hashes are
`e17613b8496e5820bb8f4a193e735a4d9129b5333c851886bb22cbd0c9c41bed`
and `9f8819cce7c759eab2e86f5ba35e20d99e436491fd46c39966c59048ab44e60d`.
Every arm retains its source hash through completion.

| Metric, mean of two arms | Control bf16 | Candidate bf16 | Candidate KV4 |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.778 | 25.895 | 25.880 |
| Four-request aggregate, tok/s | 52.947 | 52.995 | 55.398 |
| Four-request wall time, ms | 9,671.7 | 9,661.4 | 9,242.3 |
| Cached prefill, ms | 345.7 | 346.5 | 352.9 |
| Cold prefill, ms | 2,749.7 | 2,748.8 | 2,814.0 |
| Server readiness, ms | 611.5 | 611.7 | 612.1 |
| Cold start, ms | 2,600.5 | 2,427.5 | 2,424.3 |
| Peak RSS, MiB | 10,775.3 | 10,767.2 | 10,802.8 |

The source-only comparison is effectively flat: decode +0.45%, aggregate +0.09%,
cached prefill +0.22%, cold prefill −0.03%. All 60 bf16 requests have identical
request bodies, responses and usage records. Each setting repeats exactly.
All 90 requests complete without benchmark failures and reuse 671 cached tokens.

KV4 reaches +4.63% aggregate throughput versus the bf16 control, with +2.07%
cached and +2.34% cold prefill time. Ten of fifteen responses per KV4 arm differ
from bf16, and accepted draft tokens total 1,042 versus 1,032. This is a measured
precision/configuration tradeoff, not an isolated engine speed gain. Short-run
RSS does not establish a memory saving; startup varies within the candidate
arms. Defaults remain unchanged. Context/pressure and strict serial-dominance
acceptance are not covered by this short comparison. Native tests separately
cover generated RAM/SSD restoration, real-window rollback and KV4/KV8 provider
composition on both Macs. Evidence:
`reports/qwen38-closeout/composition-baseline/rotating-spec-quant/`.


### TurboQuant provider composition and centroid correction, M4 Pro 24 GB, 2026-09-11

Two six-arm `bench-serve.ts all` comparisons use
control/candidate/TQ/TQ/candidate/control. Both use Bun 1.4.2, MLX 0.32.2,
192 decode tokens, four concurrent requests, capacity eight, 2 GiB RAM plus
temporary SSD and fused TQ decoding enabled. Control/candidate target KV is
bf16; the TQ arms select K8/V3 on the candidate. The CLI keeps start zero;
sliding layers remain bf16. Diagnostic mode follows Josh's CPU/swap policy.
Sources stay fixed through every arm:
`9f8819cce7c759eab2e86f5ba35e20d99e436491fd46c39966c59048ab44e60d`
→ `f4c9fe17c9f0a691907ded7777e7814cc5eaed7811ac9941b4d1528ad75070bd`.

The candidate adds owned TQ donor attention and capability-based grouped draft
selection, captures immutable numerical options and distinct per-layer cache
identities, and corrects the small assistant's centroid head to the pinned
bf16 multiply/sum arithmetic and lowest-token-ID tie rule. The independent M1
oracle exposed the previous matmul shortcut; its decoded KV and hidden state
were exact but its selected token differed. This correction applies at every B.

#### Gemma4 12B + trained DeepSpec

OptiQ4 target weights, q4-g64 DeepSpec block7, draft depth seven and seed `deepspec-spec-0`.

| Metric, mean of two arms | Control bf16 | Candidate bf16 | Candidate K8/V3 |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 25.912 | 25.428 | 26.749 |
| Four-request aggregate, tok/s | 53.635 | 51.962 | 54.258 |
| Four-request wall time, ms | 9,546.956 | 9,854.496 | 9,436.373 |
| Cached prefill, ms | 341.823 | 343.041 | 352.446 |
| Cold prefill, ms | 2,688.505 | 2,758.072 | 2,772.306 |
| Server readiness, ms | 616.147 | 616.509 | 610.971 |
| Cold start, ms | 2,604.734 | 2,604.987 | 2,612.562 |
| Peak RSS, MiB | 10,784.125 | 10,762.719 | 10,780.617 |

Source-only bf16 decode decreases 1.87% and aggregate throughput decreases
3.12%; cached prefill is +0.36%, cold prefill +2.59%. All 60 bf16 requests have
identical bodies, responses and usage. The cost remains recorded and is under
separate attribution testing. It is not a refactor speed win.

K8/V3 increases decode 3.23% and aggregate throughput 1.16% versus the old bf16
control, with cached and cold prefill each about 3.1% slower. Nine of fifteen
responses per TQ arm differ from bf16. Accepted draft tokens total 1,044 versus
1,032. Each TQ repeat matches its own responses and usage exactly.

#### Gemma4 e4b + assistant

OptiQ4 target weights, bf16 assistant, draft depth three and seed `assistant-spec-0`.

| Metric, mean of two arms | Control bf16 | Candidate bf16 | Candidate K8/V3 |
|---|---:|---:|---:|
| Median single-request decode, tok/s | 55.374 | 55.106 | 57.532 |
| Four-request aggregate, tok/s | 94.152 | 93.340 | 91.267 |
| Four-request wall time, ms | 5,438.005 | 5,485.344 | 5,609.896 |
| Cached prefill, ms | 88.692 | 89.947 | 92.351 |
| Cold prefill, ms | 962.402 | 960.880 | 967.007 |
| Server readiness, ms | 621.475 | 610.243 | 611.252 |
| Cold start, ms | 1,309.033 | 894.498 | 906.810 |
| Peak RSS, MiB | 6,880.625 | 6,889.672 | 6,929.180 |

The centroid correction and interface changes decrease bf16 decode 0.49%
and aggregate throughput 0.86%. All bf16 response text is unchanged, while
draft-acceptance usage changes: 530 accepted tokens per candidate arm versus
532 in each control. Each arm repeats its own response and usage exactly.
The first control cold start is 1,726 ms; all later arms are 888–914 ms, so
the mean startup difference is not attributed to this change.

K8/V3 increases decode 3.90% versus the old bf16 control but decreases aggregate
throughput 3.06%; cached prefill is +4.13%, cold prefill +0.48%. Nine of fifteen
responses per TQ arm differ from bf16, and draft acceptance totals 557.
The TQ arms repeat exactly. This setting benefits single-request decode on
this workload and loses concurrent throughput.

All 180 requests complete without benchmark failures. Cached requests retain
671 tokens for 12B and 668 for e4b. These are short configuration tradeoffs, not
long-context memory or pressure acceptance. Defaults remain unchanged and strict
serial dominance stays open. Both-machine native coverage includes assistant,
DeepSpec, standalone and lookup serving/generated RAM/SSD, delayed conversion,
independent assistant codec/graph controls, seeded DSpark heads and Qwen MTP
regressions; the final suites and typechecks pass. Evidence and source manifests:
`reports/qwen38-closeout/composition-baseline/turboquant-donor/`.

### TurboQuant option-capture attribution (M4 Pro, 2026-09-11)

Same Gemma4-12B/DeepSpec7 workload and settings as the TurboQuant composition comparison above, all using bf16 KV. The sequence isolates request-option capture from numerical kernels. Frozen integrated source `f4c9fe17…` is unchanged; the key-restored variant is `cb063841…`, and the shallow-clone/conditional-assignment variant is `09e02ca6…`.

| Arm, in execution order | Decode median tok/s | Aggregate tok/s | Cached TTFT ms | Cold TTFT ms |
|---|---:|---:|---:|---:|
| deep-key-ablation-1 | 25.898 | 53.222 | 343.92 | 2728.18 |
| deep-candidate-attribution-1 | 25.899 | 52.984 | 346.27 | 2748.01 |
| deep-options-capture-1 | 25.910 | 53.942 | 339.04 | 2640.71 |
| deep-candidate-attribution-2 | 25.897 | 53.063 | 346.38 | 2752.70 |
| deep-options-capture-2 | 25.895 | 52.690 | 350.81 | 2769.67 |

The unchanged integrated build recovered the original decode rate on both repeats. Neither key restoration nor the option-copy variant establishes a repeatable speed benefit; retain the integrated implementation. The earlier measured source-only costs remain recorded, but attributing them to a code regression is not supported by these repeats. All five arms retain five distinct decode samples (reported within-arm spread about 1.15–1.16); these medians are comparisons of that fixed workload, not five identical requests. Raw requests, source identities and comparison: `reports/qwen38-closeout/composition-baseline/turboquant-donor/{m4,performance-attribution.json}`.

### Delayed/per-layer affine rotating speculation (M4 Pro, 2026-09-11)

Gemma4-12B OptiQ-4bit with the q4 DeepSpec block-7 drafter, depth seven, Bun 1.4.2/MLX 0.32.2, 192 decode tokens, four concurrent requests, scheduler capacity eight, 2 GiB RAM prompt cache plus temporary SSD. Same `deepspec-spec-0` workload as the previous composition comparison. Order: control bf16, candidate bf16, candidate per-layer, candidate per-layer, candidate bf16, control bf16. The control source is `f4c9fe17…`; candidate `072bf3ca…`. All six source snapshots remain fixed through completion.

| Setting (mean of two arms) | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Cached TTFT ms | Cold TTFT ms | Ready ms | Startup ms | Peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| control | 25.898 | 53.455 | 9579.865 | 344.315 | 2696.925 | 616.786 | 2603.127 | 10795.445 |
| candidate | 25.713 | 53.643 | 9545.352 | 339.185 | 2680.571 | 614.743 | 2544.107 | 10775.914 |
| per-layer | 27.430 | 52.456 | 9760.580 | 353.531 | 2655.698 | 616.945 | 2544.832 | 10816.516 |

Source-only bf16 comparison: decode −0.716%, aggregate +0.353%, cached TTFT −1.490%, cold TTFT −0.606%. Every bf16 request, response and usage record matches. The first candidate decode median is lower than its second repeat; the small source-only cost remains recorded and does not satisfy strict B1 dominance.

Model-defined mixed per-layer affine KV versus control bf16: decode +5.916%, aggregate −1.868%, cached TTFT +2.677%, cold TTFT −1.529%. Ten of fifteen responses differ from bf16; each configuration repeats exactly, including usage. All ninety requests complete with no phase failures. Precision changes affect the numerical trajectory and draft acceptance, so this setting comparison is not an engine-only same-output speedup. Defaults remain unchanged.

Both-machine native serving/generated RAM/SSD, delayed transition and real-window hidden/logit controls pass for the qualified providers. Seeded DSpark fixtures establish Markov/RNN execution and state contracts, not trained quality or acceptance. Raw arms and exact pair comparisons: `reports/qwen38-closeout/composition-baseline/delayed-rotating-spec/{m4,benchmark-comparison.json}`.


### Paged storage in the shared executor (M4 Pro, 2026-09-11)

Gemma4-12B OptiQ-4bit, bf16 KV, Bun 1.4.2/MLX 0.32.2, 192 decode tokens, four concurrent requests, 2 GiB RAM cache plus temporary SSD, workload `paged-compose-0`. Paged storage uses 256-token blocks and bypasses both cache tiers. The ordinary source comparison keeps continuous scheduling on both sides. The paged comparison uses the old serial executor versus the candidate shared executor (capacity eight). Frozen source: control `db451918…`, candidate `a9fe941c…`; both include identical benchmark argument plumbing. Each configuration runs twice, with reversed control/candidate order. All source snapshots remain fixed.

| Configuration (mean of two arms) | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Repeated-prompt TTFT ms | Cold TTFT ms | Ready ms | Startup ms | Peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Ordinary control | 26.455 | 72.894 | 7023.933 | 153.036 | 2436.522 | 616.814 | 1452.364 | 8936.141 |
| Ordinary candidate | 26.480 | 72.913 | 7022.101 | 154.218 | 2437.542 | 613.202 | 1588.357 | 8946.594 |
| Paged serial control | 26.310 | 24.832 | 20618.569 | 2462.690 | 2443.653 | 613.156 | 1425.283 | 8915.117 |
| Paged shared candidate | 26.289 | 70.240 | 7289.413 | 2490.439 | 2479.725 | 611.401 | 1218.411 | 8940.664 |

Ordinary source cost is effectively flat: decode +0.094%, aggregate +0.026%, cold TTFT +0.042% and cached TTFT +0.772%. Every paired response and usage record is identical. Startup varies more (+9.36% in the two-arm mean); this short comparison does not establish startup dominance.

Shared paged execution increases four-request throughput **182.86% (2.83×)** and reduces task wall time **64.65%**. Single-request decode changes −0.081%; cold TTFT increases 1.48% and repeated-prompt TTFT 1.13%. The first concurrent request reaches output in 365.84 versus 365.86 ms. Peak RSS increases 25.55 MiB. Two concurrent responses differ from serial in each pair; all single-request responses and token counts match. Every configuration repeats its own text and usage exactly. The repeated paged prompt restores zero tokens, as expected; ordinary restores 669. This is concurrent execution scaling, not a single-request decode-kernel speedup.

Eight successful arms complete 120 requests without phase failures. Four earlier paged setup attempts failed before readiness because the harness enables SSD while `--prompt-cache 0` disables its required RAM tier; those reports remain in the evidence, and both paged sides were rerun with the same 2 GiB setting. The machine retained about 1.65 GiB swap with 91% free memory and no competing GPU job; diagnostic mode follows Josh's campaign policy.

The long native comparison initially allowed ordinary cache snapshots to change prefill cohort/query boundaries while paging bypassed them. Holding arrivals alone did not equalize that graph. The corrected storage comparison holds arrivals and disables snapshot splitting on both sides; it checks full logits and tokens beyond the default block boundary. Separate HTTP coverage checks sampling, logprobs and grammar. Raw arms, source manifest, setup failures and exact request comparisons: `reports/qwen38-closeout/composition-baseline/paged-rows/`. Direct paged attention, block sharing and composed quantized/speculative paging remain open; defaults are unchanged.


### Adapter-qualified prompt lookup (M4 Pro, 2026-09-11)

Gemma4 e4b OptiQ-4bit with the existing `upper` LoRA adapter (weights SHA-256 `94f83569ba85df9e05557238809101cd19f9eabd0149c7931904e2a58774a05b`), bf16 KV, Bun 1.4.2/MLX 0.32.2, scheduler capacity eight, 192 decode tokens, four concurrent requests, 2 GiB RAM cache plus temporary SSD. Same `adapter-lookup-0` request bodies in every arm. Frozen control `a9fe941c…` and candidate `cce6e1e6…`; two repetitions per configuration in reversed control/candidate order.

The ordinary arms omit draft flags and isolate source cost. The lookup arms request ngram depth three: the old control disables speculation for adapters, while the candidate honors it through the grouped provider capability. This second comparison therefore measures newly enabled behavior.

| Configuration (mean of two arms) | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Cached TTFT ms | Cold TTFT ms | Ready ms | Startup ms | Peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| ordinary-control | 53.888 | 159.078 | 3218.551 | 38.040 | 526.635 | 610.894 | 893.690 | 6751.648 |
| ordinary-candidate | 53.800 | 158.943 | 3221.290 | 38.246 | 523.882 | 610.938 | 893.021 | 6763.688 |
| lookup-control | 53.746 | 159.064 | 3218.837 | 38.244 | 524.087 | 611.516 | 951.899 | 6731.523 |
| lookup-candidate | 53.136 | 78.537 | 6519.231 | 30.925 | 518.250 | 611.589 | 945.210 | 6766.641 |

Ordinary source cost is effectively flat: decode −0.163%, aggregate −0.085%, cold TTFT −0.523% and cached TTFT +0.543%. Every ordinary response and usage record matches across source versions.

Enabling lookup decreases single-request decode 1.14% and four-request throughput **50.63%**, increasing aggregate wall time **102.53%**. It lowers cached TTFT 19.14%. Each concurrent block accepts only 26 of 444 proposed tokens (5.86%); repeated rejection makes this configuration a poor throughput choice. Concurrent cached prefixes also change from 11 tokens under ordinary execution to zero under the paired lookup namespace. That small prefill difference does not establish the cause of the decode cost.

Eight of fifteen responses change with the enabled method, including five single-request decode probes and three concurrent responses; token counts and finish reasons match. Each configuration repeats its own responses and usage exactly. All 120 requests complete without phase failures. This is not a same-output speed gain and does not justify a default change. A stricter ngram-match screen follows separately.

Native composition checks cover bf16/KV4 and TurboQuant, compatible adapter cohorts, seeded logprobs, namespace replacement, callback failure and generated RAM/SSD restart identity on both Macs. The HTTP fixture explicitly checks token alignment with the generated SSD header: appending an extra newline changes the M4 KV4 boundary, so the original fixture correctly reused an earlier prompt checkpoint. Preserving the generated newline restores the complete generated boundary; no cache assertion was relaxed. Raw arms, source manifest and request comparison: `reports/qwen38-closeout/composition-baseline/adapter-lookup/`.


### Ngram match-length screen with the upper adapter (M4 Pro, 2026-09-11)

Same e4b/upper-adapter artifact, bf16 KV, depth three, cache settings and `adapter-lookup-0` workload as above. Source `ef832276…` differs only by adding benchmark forwarding for the existing `--ngram-min`/`--ngram-max` flags. Order is 1–3, 2–3, 3–3, 5–5, then the reverse. Each arm retains five decode samples; table values are means of the two arm medians for decode and means for other timings.

| Minimum–maximum match | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Cached TTFT ms | Cold TTFT ms | Aggregate accepted/proposed, arm A |
|---|---:|---:|---:|---:|---:|---:|
| min1-max3 | 53.949 | 78.566 | 6516.923 | 30.535 | 529.999 | 39/455 |
| min2-max3 | 56.532 | 115.274 | 4442.253 | 47.959 | 537.508 | 26/90 |
| min3-max3 | 53.552 | 130.850 | 3913.573 | 47.439 | 533.417 | 17/30 |
| min5-max5 | 50.495 | 134.898 | 3796.100 | 47.561 | 525.433 | 20/24 |

Requiring longer matches avoids many rejected proposals. Minimum two has the highest single-request decode in this screen; minimum five has the highest aggregate throughput. Neither dominates ordinary execution from the adjacent matched campaign (about 53.8 decode and 159 aggregate tok/s). Minimum two improves single-request decode but still gives up concurrent throughput; minimum five lowers both decode and aggregate throughput versus ordinary. Lookup stays opt-in; these results do not establish a global match-length default.

Three concurrent responses/usage records differ between the minimum-one repeats (39/455 versus 26/444 accepted/proposed); their aggregate timings remain close. The other settings repeat their own responses and usage exactly. Different match thresholds change response trajectories, so the timing differences are configuration results, not same-output engine speedups. All eight arms complete 120 requests without phase failures. Raw commands, request hashes, source identity and comparisons: `reports/qwen38-closeout/composition-baseline/ngram-settings/`.


### Independent greedy sampling across verification positions (M4 Pro, 2026-09-11)

Apple M4 Pro, 24 GB, Bun 1.4.2, MLX 0.32.2. Twelve matched `bench-serve.ts all` arms compare frozen control `ef832276f7a43d2a203e8d8e4b41c362459bf55d7389803af18ca8e995c83838` with candidate `22d1a38a761ea28c0dcd3ec90374a6a6931bbd9d2965bb7c64a65458aae45398`. Gemma e4b OptiQ with the upper adapter, bf16 KV, scheduler capacity eight, four concurrent requests, 192 decode tokens, 2 GiB prompt cache plus SSD, workload seed `adapter-lookup-0`. Each setting runs control/candidate/candidate/control. Diagnostic mode follows Josh's CPU/swap policy; retained swap and background App Store CPU activity are recorded in raw reports.

The sampler exposes a stateless operation for compatible greedy rows. Ordinary decode and speculative verification share normalized-score argmax; verification reads its independent token rectangle once. Grammar, processors, stochastic sampling, logprobs and custom sampler functions retain request-local sampling. Tests include rounding-created ties where raw-logit argmax would choose a different token.

Means of the two arm medians for single-request decode/cold latency; means of the two measured aggregate/cached values:

| Method | Decode control → candidate, tok/s | Aggregate control → candidate, tok/s | Aggregate change | Cached TTFT control → candidate, ms | Cold TTFT control → candidate, ms |
|---|---:|---:|---:|---:|---:|
| Ordinary | 54.198 → 54.278 | 162.724 → 162.721 | −0.002% | 38.378 → 37.283 | 530.258 → 522.210 |
| Lookup depth 3, min/max 1/3 | 55.101 → 54.898 | 79.716 → 80.779 | +1.334% | 30.760 → 30.517 | 518.664 → 516.427 |
| Lookup depth 3, min/max 5/5 | 51.405 → 51.712 | 136.141 → 138.956 | +2.067% | 47.652 → 47.348 | 539.549 → 536.417 |

Ordinary decode changes +0.148%; lookup 1/3 changes −0.368%, and lookup 5/5 changes +0.598%. Aggregate wall time changes +0.002%, −1.319% and −2.025%, respectively. Startup changes +0.045%, +10.505% and −7.777%, while ready time stays within 0.3%; the small source change does not establish startup dominance. Peak RSS changes −0.321%, −0.248% and +0.413%.

All 180 requests succeed and every arm retains its source hash. The first paired comparisons preserve every response and usage record. Ordinary and 5/5 repeats are exact, as are both candidate 1/3 runs. The 1/3 control repeat changes three concurrent responses and speculation usage; it is not an exact repeated trajectory. The stricter lookup setting still loses aggregate throughput to ordinary decoding, so no lookup default changes. Both-machine numerical, full-suite/typecheck and adapter native/generated RAM/SSD checks pass. Raw commands, source inventories, results and response comparisons are under `reports/qwen38-closeout/composition-baseline/independent-sampling/`.


### Shared ordinary checkpoints and queued persistence (M4 Pro, 2026-09-11)

Apple M4 Pro, 24 GB, Bun 1.4.2, MLX 0.32.2. Ten matched `bench-serve.ts all` arms compare frozen control `6ab45ad7bda4adf9760eb69312bbf1dacdb8fe17592df9bc8f5699e7c8b692a9` with candidate `4dcf90668b7a319538ba648de196b72d81a8a26aa1bcef7d45ba5ce4f393c6e8`. Gemma e4b OptiQ, bf16 KV, no adapter, 192 decode tokens, four concurrent requests, 2 GiB prompt cache plus SSD, workload seed `ordinary-continuation-0`. Shared scheduler capacity is eight. Ordinary arms run control/candidate/candidate/control; checkpoint interval 64 runs old serial/new serial/new shared/new shared/new serial/old serial. Diagnostic mode follows Josh's CPU/swap policy; retained swap and background App Store CPU activity are recorded.

The candidate shares ordinary restore/capture through a checkpoint-policy interface and queues owned SSD snapshots through the existing idle gate. Completion invalidates the checkpoint immediately and queues ordered disk cleanup. Means of the two arm medians for decode/cold latency; means of aggregate/cached measurements:

| Execution | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Cached TTFT ms | Cold TTFT ms |
|---|---:|---:|---:|---:|---:|
| Ordinary control | 59.401 | 169.043 | 3028.808 | 67.649 | 551.692 |
| Ordinary candidate | 59.258 | 168.873 | 3031.856 | 67.720 | 553.158 |
| Checkpoint, old serial | 58.702 | 57.265 | 8940.938 | 67.800 | 559.996 |
| Checkpoint, queued serial | 59.011 | 57.458 | 8910.919 | 67.758 | 565.658 |
| Checkpoint, queued shared | 58.905 | 168.159 | 3044.730 | 67.975 | 566.320 |

The ordinary source comparison changes decode −0.241%, aggregate throughput −0.101%, cached TTFT +0.105%, cold TTFT +0.266%, startup +0.480% and peak RSS +0.084%. Queuing serial persistence changes decode +0.526%, aggregate +0.337%, cold TTFT +1.011% and peak RSS −1.141% versus old serial. Moving checkpoint-enabled requests from queued serial to shared execution raises aggregate throughput **192.667% (2.927×)** and reduces aggregate wall time **65.831%**; single-request decode changes −0.179%, cached TTFT +0.321%, cold TTFT +0.117%, startup +0.648% and peak RSS +0.239%. This establishes concurrent throughput improvement on this workload, with the small single-request costs recorded.

All 150 requests succeed, source hashes stay fixed, and each arm repeats its own response/usage records exactly. Ordinary source and queued-serial comparisons preserve all responses and usage. Shared versus queued serial changes one concurrent response; all 15 usage records report the different execution lane and three concurrent requests reuse 11 rather than 13 prompt tokens. Other usage fields match. These timed requests complete normally; separate both-machine native and HTTP interruption/flush/fresh-server checks establish exact checkpoint restoration at matching batch geometry, including compiled and mixed-grammar bf16 controls. Those checks found a resumed shared cached-token counter could include replayed output; its clamp is under validation in the subsequent quantized candidate and is not part of this frozen timing source. This is not a process-crash durability or full Kanban acceptance result. Raw commands, source inventory and comparisons: `reports/qwen38-closeout/composition-baseline/ordinary-continuation-composition/`.

### Shared ordinary continuation composition (M4 Pro, 2026-09-11)

Eight completed `bench-serve.ts all` arms on the Apple M4 Pro, 24 GB, Bun 1.4.2 and MLX 0.32.2. Gemma e4b OptiQ, no adapter, 192 decode tokens, four concurrent requests, scheduler capacity eight, 2 GiB RAM cache plus temporary SSD, checkpoint interval 64 and workload seed `ordinary-continuation-0`. Diagnostic mode follows Josh's campaign policy. Frozen control `4dcf90668b7a319538ba648de196b72d81a8a26aa1bcef7d45ba5ce4f393c6e8` and candidate `c918d6e76e702f86d66f17095f33f0aa00d912e8c7f4a469e9992dfbe90a03a0` run control/candidate/KV4/TurboQuant, then the reverse. Context sweeps are omitted in this short comparison.

The candidate composes ordinary continuation with shared cache layouts, fixes resumed cached-token accounting and the pending-token dtype, and materializes Gemma's model constants before compiler capture. Separate native/HTTP tests cover actual interruption and restoration; the timed requests complete normally. Decode and cold latency are means of arm medians; other columns are means of the two arms.

| Shared checkpoint configuration | Decode tok/s | Aggregate tok/s | Aggregate wall ms | Cached TTFT ms | Cold TTFT ms | Startup ms | Peak RSS MiB |
|---|---:|---:|---:|---:|---:|---:|---:|
| Control, bf16 KV | 59.186 | 168.196 | 3044.070 | 67.724 | 556.523 | 904.388 | 6751.820 |
| Candidate, bf16 KV | 59.034 | 168.304 | 3042.116 | 67.836 | 558.943 | 908.403 | 6738.312 |
| Candidate, affine KV4 | 58.286 | 164.636 | 3109.894 | 70.515 | 564.785 | 916.674 | 6768.227 |
| Candidate, TurboQuant k8v3 | 57.197 | 165.002 | 3102.993 | 71.260 | 559.206 | 899.109 | 6744.930 |

At unchanged bf16 settings, decode changes −0.256%, aggregate throughput +0.064%, cached TTFT +0.166% and cold TTFT +0.435%. This is effectively flat performance. All source-comparison responses and usage records match. All four configurations repeat their own responses and usage exactly, all 120 requests succeed without phase failures, and every source hash remains fixed.

Compared with candidate bf16, KV4 changes decode −1.267% and aggregate throughput −2.179%; TurboQuant changes decode −3.112% and aggregate throughput −1.962%. KV4 changes ten response texts and TurboQuant nine, with unchanged usage records. These short-context settings do not improve speed or establish a memory advantage from peak RSS. They remain configuration tradeoffs rather than new defaults. Raw arms and derived response/timing comparisons: `reports/qwen38-closeout/composition-baseline/ordinary-continuation-final/`.
