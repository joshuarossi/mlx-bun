# STATUS — live handoff

The single "what's the state, what's next" doc. Durable phase history,
exit criteria, and findings live in [PLAN.md](PLAN.md); superseded session
summaries move to [PLAN-archive.md](PLAN-archive.md). Product/UX north star:
[docs/planning/PRODUCT_ROADMAP.md](docs/planning/PRODUCT_ROADMAP.md).

**Fidelity contract:** **L1** = mlx-lm bit-exact parity (the naked default) ·
**L2** = mlx-optiq bit-exact parity (mixed-KV composition) · **Lab** = original
optimizations with no external oracle, gated by KL/eval + a paired-A/B win vs
the L1 baseline before any default (docs/design/unified-engine-frontier-plan.md).

## Released: mlx-bun v0.0.13 (2026-08-17)

Qwen3.8-27B text support and the GLM fixed-context admission correction are
published on GitHub, npm, and the Homebrew tap. The signed/notarized arm64
archive is 80,421,168 bytes with SHA-256
`7766573a6693a6038b2e23cee67f337718d971e2cdbc310f511e4d9155cf5b17`;
Apple accepted notarization submission
`edde8b8f-1d8d-4722-878f-0b6eadc63ae5`. The two-shard release gate passed
1,940 tests with 71 intentional skips, zero failures, and 28,382 assertions.
Qwen native MTP is explicitly not part of this release: review proved its
recurrent target state cannot yet satisfy the shared verifier's rollback
contract, so companion artifacts fail early with the precise reason.

## Post-release on main (2026-08-18, unreleased)

Serving changes landed after the v0.0.13 tag: (1) **memory admission now
clamps instead of rejecting** — a fitting prompt with a broad client
`max_tokens` is capped to the room remaining under the safe context on every
model (v0.0.13 scoped this to GLM's fixed context; the generic path still
400'd a prompt with 8k of generation room over a 17-token overshoot —
regression-pinned in tests/server-admission.test.ts). Only a prompt that
leaves no generation slot rejects. (2) **Qwen native MTP is unblocked** —
see the 14g entry below. (3) **Qwen3.8 VISION (images) SERVES and the video
frames pipeline is gated** — 14v LANDED / 14w frames-complete, full detail
in PLAN 14v/14w: dedicated tower port (bit-exact vs mlx-vlm pinned to mlx
0.31.2; new conv3d binding; PIL-fixed-point bicubic; ensure_fused_sdpa's
72→80 pad), interleaved mRoPE via the reference's verbatim Metal kernel with
positions/delta exact, e2e greedy token-exact on 2/3 image fixtures +
step-0-argmax on all, HTTP serve smoke green (image_url content parts;
/v1/models now advertises vision), video preprocessor + gridT>1 tower
BIT-EXACT on the sidecar-extracted fixture clip. (4) **video FILES SERVE**
(14w complete): the AVFoundation sidecar is productized as
`mlx-bun-frame-extract` (src/native/frame_extract.swift → release bundle +
native pack v0.3.0 + dev compile-on-demand), `video_url`/`video` content
parts decode → frames → the gated pipeline on Qwen3.5-family models, and
the serve smoke covers image + video + text isolation on one server.
**RELEASE BLOCKER: publish `native-v0.3.0` and bake its sha256/size into
src/native-pack.ts before the next package tag** (PLAN 14w). A running
`serve` needs a restart to pick all of this up (the CLI symlink serves the
repo working tree).

## Active: TurboQuant weights — rotation-folded quantization (opened 2026-08-17)

New phase in PLAN.md ("TurboQuant weights"): QuaRot/SpinQuant-style
rotation folding ahead of quantization into mlx's existing formats
(affine/mxfp4/nvfp4 — no new kernels), targeting a
`Qwen3.8-27B-MTP-turbo` that beats OptiQ-4bit / plain 4bit at equal
effective bpw (ppl + frozen 6-task eval gate). HF scan: the entire MLX
ecosystem handles outliers by per-layer allocation; nobody ships a
rotation-based quant of this model — that's the gap. **W0 is DONE**
(2026-08-17, branch feature/turboquant-weights): src/quantize/rotate.ts
folds Llama-3.2-1B-Instruct-bf16 (untie → γ → R₁ → per-head R₂) and the
folded model passes the parity gate through the unmodified engine —
teacher-forced two-model KL mean 0.00131 (16×256), greedy trajectories
identical except near-tie flips (margins ≤0.125), per-tensor max|w|
down 3–5×. Evidence in the PLAN.md W0 entry. Next action: W3 small-model
curve ({rotated, plain} × {affine4, mxfp4, nvfp4} on the same 1B — needs
the W2 loader check for mxfp4/nvfp4 modes first) and the W1 Qwen3.8
corridor map. Source artifacts: the trunk
and MTP head are SEPARATE repos — mlx-community/Qwen3.8-27B-bf16
(11 shards, 54.7 GB, Josh-run `mlx-bun get`, needed by W4) +
mlx-community/Qwen3.8-27B-MTP-bf16 (MTP companion, ~850 MB, already
local + verified).

## Completed: pre-Colibri stabilization (2026-07-29)

Phase 22 is closed. The 25-item intake is tracked in
[docs/design/pre-colibri-stabilization.md](docs/design/pre-colibri-stabilization.md)
with stable IDs and evidence. Every P0/P1/P2 item is fixed; the conditional
WebSocket Origin, `/api/*` CSRF, and wildcard-CORS trio remains deferred while
loopback-only is the supported deployment.

PERF-01 is measured and fixed: bounded incremental detokenization is
byte/chunk-exact and 19.84× faster at 2,048 output tokens on the paired
MiniCPM5 harness. PERF-02 is also measured and fixed on the clean M1 Max
Qwen2.5-0.5B harness: selected-logprob overhead fell from 47.7% to no
measurable overhead (0.999× the off arm), and `top_logprobs=5` fell from
68.7% to 6.5%. The off control stayed flat, and all 40 parity checks plus
1,280/1,280 selected and top-k values remained exact.

The two isolated oracle drifts are resolved. The e4b chirp difference is an
allowed frontend residual crossing a later greedy near-tie: the actual bf16
language-model splice boundary is byte-exact from the oracle mel, so the e2e
fixture now gates the factual decode instead of asserting a contradictory
trajectory. The mixed-KV mismatch was stale machine-local `.bin` data; fresh
pinned-oracle blobs are bit-exact, and their manifest now binds provenance and
SHA-256 values. The final two-shard gate passed 1,857 tests with 71 intentional
skips and zero failures. Phase 21 is explicitly unpaused.

## Active: native Colibri/GLM-5.2 port (2026-08-17)

The G1–G3 foundation is landed on `main`. Phase 21 **G0–G8 are complete**.
Post-release first-prompt review found one API compatibility bug: a client-wide
`max_tokens: 8192` upper bound was rejected wholesale against GLM's fixed 4,096
context even when the prompt itself fit. The v0.0.13 fix caps that upper bound
to the remaining planned context (the reported 2,788-token prompt gets 1,308
completion tokens) and still rejects prompts that leave no generation slot.
The exact case is model-free gated on both chat-admission arithmetic and the
generic-budget non-regression.
Acquisition now has exact remaining
disk preflight/resume accounting, and the normal CLI/API/status surfaces show
the artifact-aware streamed plan, measured/direct/aspirational speed as
distinct quantities, and live main/MTP expert-tier telemetry. The landed
foundation has a strict versioned synthetic Colibri
gate/up/down artifact, fixed 16 KiB native slabs, passive bounded `pread`
workers, async Bun-side completion polling, generation-bound CPU/GPU leases,
lazy-graph evaluation plus stream synchronization before reuse, deterministic
LRU traces, and stock-MLX/custom-Metal zero-copy consumers. Forced churn covers
1,000 native reloads plus 100 GPU-fenced MLX reloads with flat allocator use.
The final adversarial audit reproduced and closed both a post-close bus error
and a lazy-graph stale-read/UAF class before passing. The Colibri checkout remains clean at
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c`; the public GLM-5.2 artifact is
pinned at revision `3cc8db99b1b13fc79325d987ba3c1c430766b3b8`. All 150 files
are accounted for and all 145 LFS payloads (383,760,044,154 bytes) match the
pinned Hugging Face SHA-256 metadata. The downloader now reads the current
`lfs.sha256` field, fixing the schema bug discovered during this audit.

Direct Colibri/Metal ran the full model on this 32 GiB M1 Max at an 18 GB
budget, 128-token context, true top-8 routing, one explicit LRU slot/layer,
`DIRECT=1`, and zero pins/learned routing. The authoritative matrix has three
independent processes per MTP mode and two requests per process. Fresh-turn
median throughput was 0.34 tok/s MTP-off versus 0.26 tok/s MTP-on; MTP accepted
34/90 raw proposals and reduced main forwards from 63 to 30, but raised expert
traffic from 836.909 to 1126.703 GB and total request time by 29.1%. Median peak
footprints were 13.631 and 17.475 GB. Every process reported zero swaps, and
the same pre-existing 0.75 MB of system swap remained unchanged in every cell.

The second request uses the same PID after RESET clears KV but preserves the
expert LRU. Median MTP-off TTFT improved 29.332 -> 28.431 s while throughput
remained 0.34 tok/s. MTP-on TTFT moved 31.132 -> 31.895 s and throughput only
reached 0.27 tok/s; acceptance shifted from 34 to 33 and required one extra
main forward. All twelve turns returned exactly the same 64 token IDs. Live
`mactop` telemetry during MTP-on showed ~4.9 GB/s reads, 0 B/s writes, 24% GPU,
16.1 GB/s unified-memory bandwidth, and 19.91/32 GB memory: the current limit is
expert delivery/serialization, not compute or DRAM bandwidth. A 140-record
real-model GLM/MLA/router/MTP/KV oracle reproduced byte-for-byte twice; both
heads predict teacher token 16 and the compact validated capture is tracked in
`fixtures/colibri-glm52/real-model-oracle.json`.

The published artifact has no DSA indexer tensors. The machine-local HF
snapshot now carries the exact stock overlay generated outside this repository:
20 `out-idx-*` files, 197,202,400 bytes, from pinned
`zai-org/GLM-5.2-FP8@ba978f7d`. Header validation finds all 21 full indexers,
57 shared layers with no indexer requirement, complete MTP metadata, 118,646
tensors, and no layout errors. The original G0 waiver and model-free fixtures
remain historical evidence; the patched HF model is the long-context target.
At the original 128-token G0 context DSA still selects densely because the
context is below `topk=2048`; sparse behavior begins only at token 2,049.
Commands, caveats, and current evidence are in
[docs/investigations/indexshare-performance-spike.md](docs/investigations/indexshare-performance-spike.md).

G2 now has a dedicated `glm_moe_dsa` config/model and artifact-aware
`openModel()` path, exact GLM template fallback and multiple EOS, direct
Colibri shard catalog/layout validation, lazy MLX Q4/Q8 loading, compressed MLA
KV, reconstructed prefill plus absorbed serial decode, exact DSA selection and
shared-state reuse, exact lower-ID-tie top-8 routing, and shared+routed expert
composition. Focused synthetic/reference gates are green. Header-only
validation of the pinned public artifact found 59,003 quantized tensors, 472
float tensors, 19,456 routed experts, complete MTP metadata, and—as expected—
no DSA sidecar, without executing the full model.

The G2 tiny-model gate is now closed with the pinned Colibri code. An isolated
generator environment reproduced the committed BF16 trajectory exactly, then
Colibri's converter produced the production-relevant 353 KiB per-row Q4 direct
container. The apparent 26/32 discrepancy was entirely an oracle-mode mismatch:
Colibri defaults to activation-int8 `IDOT` on Apple Silicon, while G2's
quality-preserving contract is exact dequant-to-f32-MAC. With `IDOT=0`, Colibri
C and mlx-bun match at 32/32 positions on identical Q4 bytes. Across all 8,192
logits, max absolute delta is 1.3113e-6 and RMSE is 2.7423e-7; mlx-bun's
minimum top-two margin is 0.003425. The tracked fixture records the pinned
commit, exact conversion/oracle arguments, both exact and default-IDOT
trajectories, numeric bounds, and SHA-256 values. The artifact is preserved
machine-locally at `runs/colibri-glm52-tiny-i4`.

The manual production-Q4 gate is now closed too. A selected-shard runner used
the real G0 decode inputs without constructing the full model, experts, cache,
or generation loop. Layer 0's complete Q4 gate/up/down SwiGLU matched pinned
Colibri `dense_mlp` under `IDOT=0` at max absolute delta 5.2387e-9 and RMSE
9.7823e-10. Layer-3 and layer-77 router projections reproduced the exact eight
expert IDs and `keff=8`; sigmoid max deltas were 4.7684e-7 and 7.1526e-7.
Two fresh processes produced identical numeric results. The run exposed and
fixed one production-only bug: Colibri's whole-row scale implied unsupported
MLX affine-dequant group size 6144, so the same scale is now repeated over
supported 32-value groups with identical dequantized values. With the tiny
artifact gate enabled, the focused GLM suite is 55 pass, 0 fail.

Peak MLX allocation was 1,566,883,896 bytes and observed process RSS peaked at
290,455,552 bytes. System free memory remained 78%; the pre-existing 1,840.25
MiB of swap did not change. Stable evidence is tracked at
`fixtures/colibri-glm52/production-probe.json`. No performance benchmark or
full-model generation was performed; this was the bounded G2 correctness
probe authorized for the production artifact.

G3 now has the direct-artifact residency path in worktree. Native slabs accept
up to eight positioned segments across the 141 main shards, which covers the
19,114 ordinary four-segment experts and 86 cross-shard six-segment experts
without constructing a converted copy. The canonical production Q4 slot is
18,939,904 bytes (down/gate/up packed weights followed by their F32 scales);
every directly wrapped component starts on its own 16 KiB boundary.
The native layer also exposes physical-footprint sampling and safe decommit of
idle generations while preserving fixed virtual addresses.

The TypeScript policy derives capacity from a fixed byte budget and refuses
startup below the global 64-slot working bank plus one persistent slot per
sparse layer. It implements deterministic per-layer LRU, a separate pinned
tier, generation-tagged async loads, reverse-order miss promotion by logical
slot-role swap (no 19 MB copy), one shared GPU fence per wave, stable row/rank
batch union, and safe-point-only downward pressure correction. Read failures
are drained and discarded before a scratch slot can be reused.

The GLM execution chain has a parallel async path from model through layer and
MLP. It submits resident expert graphs and the shared expert before miss reads,
materializes each <=64-unique wave before releasing its slab leases, and
composes rows afterward in exact route order. Resident weights explicitly
reject every `.mlp.experts.*` access, preventing fallback to the G2 mmap
backend. The stock-MLX candidate wraps canonical packed Q4 bytes directly as
uint32 lanes and uses affine QMM with the exact `-8*scale` bias. The machine-
local tiny direct container passes the complete streamed 32/32 trajectory with
64 global working slots, one LRU slot for each sparse layer, and no live leases
or loads after the forward. Focused G3 policy/layout/async/native tests are
green.

The post-alignment bounded production expert gate also passes. Layer 3
reproduces exact top-8 `[250,64,199,172,129,191,82,63]`; the complete weighted
routed sum plus unweighted shared expert is byte-identical across cold, warm,
and forced-eviction reruns and matches the direct Colibri capture at max
absolute delta 1.8626e-9 / RMSE 3.6290e-10. The forced trace records cold
`0H/8M/0E`, warm `1H/7M/0E`, replacement `0H/1M/1E`, and post-eviction
`0H/8M/1E`. Final physical footprint is 726,549,944 bytes and swap growth is
zero. Stable evidence:
`fixtures/colibri-glm52/g3-production-expert-probe.json`.

The full streamed two-forward gate now passes: the 32-token prefix predicts
16 and the following decode predicts 13, with tie-free margins 2.9581 and
7.0824. The run used the required 64-slot global bank plus one LRU slot for
each of 75 sparse layers; final physical footprint was 13,474,688,232 bytes,
MLX peak allocation was 11,007,206,184 bytes, and no load or lease remained.
The first attempt exposed and fixed a G2-only full-table Q8 embedding/head
transient: streamed embedding now gathers rows before signed-int8 dequant,
the output head is evaluated in bounded output-row tiles, resident Q4 spine
linears use MLX affine quantized matmul, and every layer is an explicit safe
point. A live per-wave swap guard now records and bounds system-wide swap
activity. The passing non-cleared run recorded 397,148,160 bytes of swapout
with other applications open; that is not a zero-swap claim, whose cleared
machine gate remains G5. Stable evidence is
`fixtures/colibri-glm52/g3-full-model-trajectory.json`.

The final adversarial G3 review found no numeric, alignment, ownership/UAF, or
budget blocker. Its two error-path findings (double release after a failed
lease release and post-close guard sampling) are fixed, and the 98-test
focused/native suite plus both entry bundles pass afterward.

The cleared-machine G1/G3 matrix is now complete. At the production M=1 top-8
decode shape, custom Metal measured 4.282 ms versus stock MLX at 5.099 ms
(16.0% faster after ten warmups; an independent shorter run also won by 5.4%)
with max absolute output delta `2.33e-9` and relative RMSE `5.56e-7`.
Therefore custom Metal is selected for routed decode; stock MLX remains
selected for Q4 dense operations, routed M=11/M=32, and absorbed MLA. The
same-shape direct-Colibri matrix remains the performance oracle and exposes
the largest residual gap at MLA decode (1.014 ms direct vs 11.506 ms stock
MLX). Two matched idle-power matrices show no monotonic CPU/GPU/package-power
increase from 1, 2, or 4 sleeping workers, confirming passive waits; the
chosen default remains two workers. Swap stayed exactly 339.25 MiB through
the kernel runs. Raw reports are under `runs/colibri-g1/`.

G4 serial native MTP is complete. The in-process source shares the target
embedding, output head, dense weights, and sampler; the signed-int8 MTP routed
row has a bounded 24-working + 1-resident expert tier whose 945,356,800-byte
slab is included in the main plan. Partial and zero-accept tests lock exact
target/MTP rollback, and fixed Q4/Q8 Metal families are row-stable across
draft and verify widths. Grammar remains in the common constrained verify
walk; prompt lookup is the alternative model-free provider, so one draft
history owns each request.

The direct `IDOT=0,SPEC_PIN=1` capture and mlx-bun match all 64 target tokens
and the tie-free first four acceptance rounds `[1,1,1,0]`. Later direct
acceptance is retained as non-gating evidence because direct Colibri reduces
RMSNorm in float64 while MLX uses its established float32 graph. The
separate-process production A/B passed: 675.654 s MTP-on versus 834.172 s off
for 64 tokens, a 1.235x wall-throughput win / 19.0% less generation time.
MTP accepted 32/92 drafts over 31 verify forwards, emitted 2.065
tokens/forward, and saved 32 target forwards. The machine was not swap-cleared,
so the 14,679,224,320-byte completed footprint is not a G5 memory claim.
Stable evidence:
`fixtures/colibri-glm52/g4-native-mtp-e2e.json`.

The G5 implementation, model-free gates, and full-model measurement are now
complete on
`codex/colibri-g5-memory-contract`. The pinned artifact's header-only MTP-on
plan is 21,111,440,128 bytes, leaving 5,732,105,472 bytes below the 25 GiB
process ceiling plus an explicit 7 GiB OS reserve. The planner total is
byte-for-byte the same equation handed to runtime expert residency; impossible
starts fail before resident weights are mapped. The manual lane harness runs
cold then warm 128-token turns, samples physical footprint/MLX/compressor/swap,
and the paired evaluator requires exact first-64 direct-oracle and complete
128-token cold/warm/on/off identity.

The 2026-08-15 fresh-process observational pair completed all four turns with
exact identity. MTP-on measured 13.791 GiB peak footprint, 13.666 -> 13.688
GiB cold-to-warm final footprint (+23.1 MiB), and 0.146 -> 0.149 tok/s
end-to-end. MTP-off measured 12.644 GiB peak, 12.564 -> 12.583 GiB (+19.2
MiB), and 0.127 -> 0.114 tok/s. Warm MTP-on was 1.306x MTP-off. MTP accepted
72/166 drafts per turn, emitted 2.286 tokens/target forward, and saved 71
target forwards. Both peaks are far below the 25 GiB process ceiling.

Josh changed this execution from hard compressor enforcement to an explicit
before/after observation: strict mode remains the default and its thresholds
are still reported, while `--memory-mode observe` does not abort generation.
Accordingly the paired report is truthfully marked `observed` and
`strictContractSatisfied: false`: system compressor growth peaked at 4.101
GiB, task-compressed memory at 1.806 GiB, and the MTP-off lane recorded 6.8
MiB of swapout (MTP-on zero). These were bounded rather than a footprint
spiral; warm final footprint stayed nearly flat. Production/spec generation
now applies the full streamed process plan to MLX's scoped wired limit, and
native expert slabs wire slots before reads then unlock before discard.
Stable machine-local evidence is under `runs/colibri-g5/`.

G6 is active. Its first production slice adds a shared target/MTP
Colibri-compatible `.coli_usage` ledger: every top-k route is counted before
batch-union deduplication, startup history is kept separate from live
heat/recency, and generation safe points atomically replace the profile. A
damaged derived profile warns and restarts empty rather than preventing model
load; `usagePath: false` is the diagnostic opt-out. The scheduler inventory
also confirms that stable batch-union, bounded positioned-read/F_NOCACHE
workers, per-layer LRU, and resident-first Metal submission are already
implemented.

The second slice consumes that history through an opt-in startup auto-pin
candidate. It matches Colibri's 5k/200k confidence ramp, half-tier share, and
0.5 GB minimum, but adds deterministic ties and cost-aware Q4/Q8 budgeting.
Pins are clamped behind the one-slot-per-layer floor, represented in the exact
main/MTP slab plans, and loaded before the first forward. It remains off by
default until the required MTP-on comparison wins.

The third slice adds opt-in safe-turn live LFRU: exact uint32 recency scoring,
25%+4 hysteresis, session-heat decay, and one four-swap cap shared across main
and MTP. Completed loads change logical tier roles without copying a 19/38 MB
expert, while live maps now expose tier, persistent count, heat, recency,
hits/misses, and repin totals. Controlled probes explicitly disable usage
learning so benchmark traffic cannot contaminate a real model profile.

The three-repeat MTP-on learning matrix is complete. All nine cold/warm arm
runs were token-identical from the same 308,592-selection seed. Startup
auto-pin moved median warm hit rate 1.66% -> 9.62% and reduced disk GB/token
8.02%, but median warm throughput fell 4.06% (0.149 -> 0.143 tok/s), model open
rose 526 ms, and warm physical footprint rose 3.337 GiB (13.694 -> 17.032
GiB). Its 3.329 GiB preload therefore did not pay back. Live LFRU made zero
swaps across every measured turn and landed at 0.148 tok/s, 0.38% below
control; that is run-order noise over the unchanged startup placement, not an
adaptation win. Both policies remain off by default. The default-eligible
summary and raw per-turn telemetry are machine-local under
`runs/colibri-g6-learning-shakeout-2026-08-15/`.

The isolated measurement-only PILOT arm and bounded hint-only `PILOT_K=4` arm
are now implemented. The latter uses a separate bounded native advisory queue
to issue scale-tail-only `F_RDADVISE`; it skips resident experts and never
allocates/publishes slots or mutates demand/LRU state. A one-repeat MTP-on
paired full-model shakeout kept tokens exact. Each turn completed all 48,162
submitted hints (144,486 operations / 1.973 GB advised) with zero drops,
errors, queue backlog, or in-flight work at turn end. Warm logical demand bytes
were exactly unchanged, while disk-service p95 was 1.0065x control,
foreground-wait p95 was 1.0193x, and warm throughput was 0.9746x (0.14031 ->
0.13675 tok/s); final footprint increased only ~3.8 MB. Hint-only therefore
remains off and does not justify real speculative loads. This is a correctness
shakeout, not a replicated performance result. Evidence is machine-local under
`runs/colibri-g6-pilot-hint-k4-shakeout-2026-08-16/`; the preceding predictor
quality result remains under `runs/colibri-g6-pilot-measure-shakeout-2026-08-16/`.

Two-step and coupling measurement are now complete. The two-step predictor
reproduces Colibri's current-layer shared-expert correction without feeding
its output into execution. It improved top-8 precision/recall from 69.90% to
73.01% and exact rows from 5.35% to 7.90%, but the one-repeat MTP-on warm arm
fell 10.13% in throughput (0.14978 -> 0.13461 tok/s) with exactly unchanged
logical demand bytes/token. A separate 23,250-record route trace used only the
cold segment and a temporal 108-position train / 47-position held-out split.
At budget 8, coupling reached 31.02% recall for delta 1 and 30.81% for delta 2,
8.06 and 7.66 points above the marginal baselines but far below direct PILOT;
budget 32 still reached only 57.35% / 56.74%. Both mechanisms remain
default-off and real speculative loads are rejected. Evidence is machine-local
under `runs/colibri-g6-pilot-two-step-shakeout-2026-08-16/` and
`runs/colibri-g6-coupling-shakeout-2026-08-16/`.

The controlled Atlas workflow and real-model gate are complete. The 30-prompt
sweep retained 13,236 replicated experts, including 1,065 strong specialists
(8.05%), and global leave-one-prompt-out classification scored 29/30 (96.7%,
chance 10.0%). That exactly reproduces Colibri's published held-out accuracy;
its published population was 13,260 replicated / 1,041 strong (7.85%). The
single miss was Chinese prompt 1 classified as poetry. Detailed JSON,
Colibri-compatible `experts.json`, and the verified standalone interactive map
are machine-local under `runs/colibri-g6-atlas/analysis/`. Atlas-informed
warm-start and the optional G4R prompt-seeding spike remain explicitly deferred
and default-off.

**G8 productization is complete:** the downloader computes
the exact remaining payload before transfer, credits complete shared blobs and
valid `.incomplete` prefixes, and refuses before the first payload when the
target volume cannot fit the remainder plus a fixed 1 GiB reserve. The pinned
~357 GiB artifact, cache-volume selection, resume/recovery flow, exact 32 GB /
25 GiB launch command, model lineage, and Apache-2.0 Colibri attribution are
documented. The CLI/API/status surfaces now show the exact streamed resource
plan, measured/direct/aspirational speed separately, and live main/MTP expert
telemetry. `benchmarks/RESULTS.md` curates the final oracle, memory, speed,
expert-I/O, policy, DSA, and API cells, including the 13.45x gap to the 2 tok/s
aspiration. The focused G8b gate passes TypeScript plus 55 tests / 1,910
assertions. Native-pack publication and the public fresh-cache check are also
complete, closing G8d and Phase 21.

G8d is complete. Native pack v0.2.0
and the compiled/Homebrew bundle now contain `libmlx_bun_expert_io.dylib`; an
isolated empty-cache run downloaded and extracted the real 52,307,647-byte
archive, loaded MLX, and completed a positioned expert read. The compiled
bundle passed version/help/ls/pi smokes, and TypeScript, docs-map, plus 74
focused tests / 4,335 assertions are green. GitHub release `native-v0.2.0` is
published with both assets; the archive's remote size and SHA-256 match the
baked constants. Anonymous HTTP resolution and a clean default-URL
download/checksum/extraction passed with all five required files.

The actual mlx-bun v0.0.12 package release is also complete (2026-08-17).
GitHub publishes the signed/notarized 80,420,638-byte arm64 bundle under both
versioned and stable asset names with SHA-256
`64c4d697faba65789c2af7c1344ee39024f8a03bd6839d2c8df4ec7dce872a74`;
`mlx-bun@0.0.12` is live on npm (registry shasum
`0dcc5c200fa81dbea1f8be854e21a0efbbdebbfa`), and the public Homebrew tap
points to the same archive and checksum. The full two-shard release gate passed
1,936 tests / 28,378 assertions with 71 skips and zero failures. Remote `main`
contains the release implementation and in-repo formula mirror.

**G6R Stage 0 complete:** at context 2,049, the patched model produced all 21
expected full-layer top-2,048 selections. All 21 official Colibri score rows
were tie-free and replayed through mlx-bun with exact ordered positions and
float32 thresholds. Both runtimes emitted greedy tokens `[264, 264]` and the
sparse-step top-1 logit matched; full-vector cosine was 0.997645. Direct
full-runtime positions were 10/21 ordered-exact and 14/21 set-exact because
the two runtimes accumulate quantized model matmuls differently before DSA;
the official-score replay isolates and closes the DSA selection contract.
Machine-local evidence and the 20-file SHA-256 manifest live outside the repo
at `~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/`. The current
correctness scaffold has now been replaced by Stage 1's production-shaped
device path.

**G6R Stage 1 complete:** score accumulation is tiled `[H,D] @ [D,L]`, the
deterministic uint64 device top-k preserves Colibri's threshold/lower-position
tie contract, and one 8 KiB FULL index buffer is borrowed by SHARED MLA layers
without normal-path host copies or re-uploads. Random, tied, all-equal,
2,049/2,048, borrowed-gather, and 21/21 captured official score rows pass. A
fresh live model run reproduced all 21 prior selection vectors, greedy
`[264,264]`, and byte-identical decode logits; tiled score accumulation moved
nine diagnostic thresholds by at most 3.05e-5 without moving a boundary. Warm
model-free score+top-k medians are 0.929 ms at 8K and 1.269 ms at 32K; these are
component numbers, not end-to-end claims. Evidence:
`~/.cache/mlx-bun/evidence/glm52-dsa-stage1-2026-08-17/`. Plan and source audit:
`docs/investigations/indexshare-performance-spike.md`.

**G6R Stage 2 complete:** the quiet-machine direct-library matrix completed 24
eligible fresh-process cells: 2K/8K, DSA off/on, MTP off/on, and three repeats,
with cold and warm turns in each process. All cold/warm, repeat, and MTP token
gates are exact. The 12 planned 32K cells are recorded as contract-ineligible:
the exact planner requires 27.320 GiB MTP-off and 28.540 GiB MTP-on, both above
G5's 25 GiB process ceiling. At 8K without MTP, DSA improved paired median
decode throughput 12.38% but total wall time only 1.89%, below the 5% product
gate. With MTP, DSA slowed decode 34.33% and increased total wall time 8.19%; it
also reduced the deterministic MTP trace from 3.2 to 2.286 tokens/target
forward. The result is therefore negative for product performance. The exact
21F/57S schedule remains required model semantics; sparse prefill is deferred,
and no prefill or end-to-end speed claim is made. Evidence:
`~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`; manifest SHA-256
`90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.

**G7a compressed persistence complete:** the existing v3 `kv-store` format
remains backward-compatible and now discriminates target `mla`, target
`mla-dsa`, and native `mtp-mla` rows. It streams only compressed latent, RoPE,
and owning-layer DSA tensors; clone, prompt-cache bytes, SSD restart scanning,
trim eligibility, atomic async writes, verified copy-restore, and exact offsets
all use that state without reconstructing full K/V. Restore validates model id,
config/tokenizer metadata, cache role, and exact GLM geometry before opening the
tensor mmap. Tiny-model forks prove uninterrupted versus restored target hidden
state and offsets at two prefix lengths, while a restored MTP row produces the
same next draft sequence and offset. The focused GLM/kv-store/SSD gate passes
42 tests with 881 assertions.

**G7b continuous batching complete:** GLM's checkpoint-native cache now exposes
a structural dynamic-row capability with logical offsets, right-justified
latent/RoPE/DSA tensors, exact compressed-byte projection, merge, independent
extraction, filtering, and context bounds. Mixed-length batched DSA hidden
states and extracted tips match serial rows exactly. The streamed async path
receives the live `[B,1,H]` batch and constructs one cross-row expert plan;
scheduler coverage proves join, cancellation, sibling completion, filtering,
and exact admission bytes. Gateway and `GET /stats` report the actual
`off`/`serial`/`batch` capability mode. Requests with native MTP continue to
route serial by the explicit `hasDraft` contract; per-row batched MTP remains
post-release. The broader GLM/persistence/gateway gate passes 115 tests with
1,701 assertions. G7c implementation follows below.

**G7c serving parity is complete:** the
generic `generate()` path now awaits streamed expert layers, and the bounded
Colibri opener is wired through `openModel`, `loadContext`, `serve`, embedded
`pi`, and one-shot `generate`. GLM's native MTP row mounts by default through
the serial speculative lane (`--mtp off` enables ordinary batching); the
native `arg_key`/`arg_value` tool format parses; `/v1/models` explicitly marks
unsupported embeddings/vision/audio/adapters/training false; and `/stats.glm52`
reports the exact pre-open resource equation. Tiny streamed-model HTTP tests
cover chat/text completions, Anthropic Messages, Responses, SSE, discovery,
and native MTP. The fresh real-artifact CLI gate then passed under the exact
25 GiB contract: health, discovery, and stats were correct; chat completions,
text completions, Anthropic Messages, Responses, and SSE all returned HTTP 200
with their correct envelopes; SSE ended in `[DONE]`; and chat/SSE reported the
live `serial+spec` lane. Post-run telemetry returned to zero active/pending rows
with the 21,352,663,936-byte plan inside the 26,843,545,600-byte limit.
The final focused static/synthetic sweep passes TypeScript, diff hygiene, and
152 tests with 2,536 assertions; the refreshed full code graph covers every
operated G7c source/test file (18,774 nodes, 81,629 edges, zero skipped files).

## Where we are (2026-07-10 — v0.0.11 released)

**v0.0.11 is live on every distribution channel.** PR #29 merged the
final release notes and reference-doc accuracy sweep into main; CI and
CodeRabbit were green. The Developer-ID build passed its binary/pi smoke,
was signed and notarized (submission `434ac11a-09c3-4f74-94dd-bb9fdf94f793`),
and shipped as both versioned and stable-name GitHub assets with SHA-256
`e9178d264a375694ed1b704eb2b9f717b91e40038781f874c9ec015619ac64e5`.
The `joshuarossi/homebrew-tap` formula and npm `mlx-bun@0.0.11` are live;
the in-repo formula is synchronized in the release follow-up commit.
Release notes: [docs/planning/release-notes-v0.0.11.md](docs/planning/release-notes-v0.0.11.md).

Still owed (all opt-in surfaces, judged non-blocking for the release):
paged-kv try-body temp leaks + GRAMMAR_JUMP×paged-kv verify-or-refuse;
write-behind max-defer design decision.

## Where we were (2026-07-07, later — review sweep over everything landed + in flight)

**Four-agent review pass (docs drift / defaults+serving path / web-chat
worktree / paged-kv worktree), fixes on branch `josh/review-sweep-0707`.**
Two CONFIRMED serving bugs found and fixed: (1) grammar controllers
compiled before the reject paths leaked their WASM matcher on EVERY
early 400 (both API surfaces; attacker-loopable via `response_format` +
an SSRF-blocked `image_url`) — every pre-run reject now disposes, and
`GrammarController.dispose()` is idempotent; (2) the documented grammar
degrade path (prompt injection + Warning header) was dead code since the
feature landed — `compileGrammarRequest` dropped its `degradeHint`, so
malformed grammars served 200 unconstrained with no Warning; now
reachable and re-pinned in tests. Plus: `MLX_BUN_SSD_SPILL_QUEUE_GB=0`
un-coerced, refuse-loudly warnings for silently-ignored flag combos
(ssd sub-flags / --model-pool / --ngram-*), stale default-comments fixed,
docs drift closed (8 findings — far cleaner than the 2026-07-03 sweep),
openwiki-evaluation investigation landed. Full report + the worktree
findings: `reports/review-sweep-2026-07-07.md` (local). Web-chat tranche:
2 confirmed findings, the big one being the wrapperless tool-call repair
that can EXECUTE JSON-shaped assistant CONTENT as a real tool call —
owed before that tranche commits. Paged-kv was reviewed PRE-merge
(REDIRECT verdict); the merged v1 (below) addressed the
record-engagement + refusal-gate items — still owed from that review:
two try-body temp leaks (paged-kv.ts gather/updateAndFetch throw paths)
and a verify-or-refuse for `MLX_BUN_GRAMMAR_JUMP` + `--paged-kv`
(jumped spans can overflow the exactly-`prompt+maxTokens`-sized pool →
mid-request 500). OPEN design decision: write-behind flush has NO
max-defer — a continuously busy server never flushes (SpillQueue pins up
to 2 GB through exactly the loaded window; restart survival degrades to
nothing under sustained traffic).

## Where we were (2026-07-07b — optional paged KV cache v1, `--paged-kv`)

**`PagedKVCache`/`BlockPool` landed behind default-off `--paged-kv`**
(docs/design/paged-kv-cache.md — plan produced by a multi-agent design
pass, judged synthesis of 3 proposals): vLLM-style block-pool storage
for full-attention layers, host-side block table, `takeAxis` gather to
contiguous before the UNCHANGED stock SDPA (no new kernel, no new FFI
binding — the plan's proposed `mlx_gather` binding proved unnecessary).
Scope v1: serial batch=1, Gemma4-family, bf16; CLI pins `--batch 1`,
createServer REFUSES `--batch N>1`/`--kv-quant`/`--draft-model`; paged
requests bypass the prompt cache and run uncompiled decode (automatic:
`PagedKVCache` is deliberately not a `KVCache` subclass, so every
instanceof gate excludes it — the TurboQuant pattern). Gates:
tests/paged-kv.test.ts (model-free storage-layout parity incl. block
boundaries + trim/regrow + typed pool exhaustion) and
tests/paged-kv-parity.test.ts (12B: single-forward logits BIT-EXACT,
48-token greedy trajectory IDENTICAL, paged-on vs paged-off).
Honest framing: at batch=1 the gather is pure bandwidth tax — v1 is the
correctness-proven rung-3 abstraction (parallel-slots.md updated);
the payoff (batched block allocation, block-CoW prefix sharing, fused
paged kernel) is the documented follow-up chain. This does NOT reverse
the 2026-07-07 mining-pass rejection (paged-as-prompt-cache) or
ssd-kv-cold-tier D1 (paged SSD spill) — different axes, reconciled in
the design doc. **Next:** quiet-machine perf disclosure via
benchmark.sh (paged-on vs off, 12B/e4b) → benchmarks/RESULTS.md.

## Where we were (2026-07-07 — two vLLM-inspired serving features: ngram drafter + grammar jump-forward)

**Both landed with gates + reference docs, from a vLLM-mining pass that
first killed three other candidates against the code** (chunked-prefill
interleave: already built; paged KV: physical sharing already exists via
take()'s zero-copy view clones + paging explicitly rejected in
ssd-kv-cold-tier.md D1; block-hash prefix keying: our token-granular LCP
is strictly finer). The two that survived:

1. **`--draft-kind ngram` — MODEL-FREE prompt-lookup speculative drafting**
   (src/spec/ngram-source.ts; port of Saxena's prompt-lookup decoding /
   vLLM's `ngram` proposer — longest-k-first, first occurrence). No
   artifact, no dir: drafts are copied from the request's own
   prompt+generation; the shared verify makes it lossless at any
   temperature; a no-match round degrades to one plain step. Directly
   answers the DSpark drafter-tax finding (τ≈2.8 eaten by a 6.9 GB bf16
   drafter — this drafter is free). The subtle part is token-history
   reconstruction from the seam's feed/commit discipline (an all-accept
   round's last draft arrives via the NEXT feed — mlx-lm's re-feed rule);
   pinned model-free in tests/spec-ngram.test.ts. **Real-weights gates
   GREEN on this box: serve-loop ngram spec TOKEN-IDENTICAL to non-spec
   greedy on e4b (γ=3 and γ=10, tie-free prompt) + echo prompt lands
   accepts.** Flags: `--ngram-max/--ngram-min` (3/1), `--num-draft-tokens`
   defaults 10 for this kind; mounting it WITH `--draft-model` (or another
   kind without one) refuses at load. Docs: cli.md, server-config.md,
   features-matrix.md.
2. **`MLX_BUN_GRAMMAR_JUMP=1` — jump-forward decoding for structured
   output** (opt-in Lab lever, serial lane): xgrammar's
   `findJumpForwardString` (shipped in our WASM build, previously
   uncalled) + a generate() jump iteration that carries grammar-forced
   spans into the KV with ONE multi-token forward instead of per-token
   masked forwards. String-lossless + always grammar-valid; the token
   stream may legally differ (retokenized forced spans) → opt-in, no
   oracle. Partial-accept keeps matcher/emitted lockstep with no rollback;
   SP-family raw-encode mismatch degrades to normal decode (never invalid
   output). Gated: tests/grammar-jump.test.ts (contract + Llama-3.2-1B
   e2e on/off). Batch-lane #stepGrammar deliberately doesn't jump yet.
   Design: structured-output.md 2026-07-07 addendum. **Drive-by fix found
   by its tests: disposing a GrammarController with a queued bitmask fill
   called into the deleted WASM matcher and poisoned the module-wide
   wasmChain (BindingError) — fireFill() now no-ops after dispose (latent
   for any exception between accept() and ready(), both lanes).**

Open follow-ups from the same pass (small, backlog): mid-flight
preemption (demote a running row's KV to the SSD tier to admit a
higher-priority request — the restore primitive exists, only an idleness
trigger today); ngram + jump-forward composition cells in
bench-feature-matrix on a quiet box.

## Where we were (2026-07-07 — merge wave landed + post-merge review fixed; drafter-quant Phase 1 code done)

**All three threads merged within hours: PR #18 (bench residuals), PR #19
(DSpark spec decoding), PR #20 (TurboQuant KV).** A 4-agent post-merge
review over the union found and FIXED same-day: (1) CRITICAL — the
TurboQuant bit-pack/unpack helpers leaked window-scale GPU buffers per
decode step (bare `split().map(reshape)` + or-chain reassignment; measured
~8.4 MB/call at 2k ctx → OOM within dozens of tokens; splitLanes + orInto
now dispose, regression test at window scale); (2) `--kv-quant turbo` +
`--draft-model` silently dropped turbo (spec eligibility gate now excludes
turboQuant like the affine axes + startup warning); (3) turbo state()
try/finally on the eval chokepoints. The two #18-thread operational
findings are ALSO FIXED (same day): the write-behind snapshot timer now
carries demoteIdle's activity guard (re-arms while rows are active instead
of registering a serial waiter that froze batch admission), and pending
spill clones go through the new bounded `SpillQueue` (kv-store.ts; 2 GB
default cap, `MLX_BUN_SSD_SPILL_QUEUE_GB`, drop-oldest with immediate
clone disposal, `/stats.ssd_cache` pending/dropped counters;
no-shutdown-flush documented as accepted in ssd-kv-cold-tier.md's
2026-07-07 addendum). The error-path leak batch is ALSO drained (same
day): samplePos try/finally (grammar-reject orphaned a [1,V] row/hit),
spec caches+source allocated inside the try + loadContext PROBE-OPENS the
(target, drafter) pairing at startup (mismatch now refuses at load, not
500-per-request), loadKvCache pending[]-drains mid-entry orphans under
--ssd-cache-verify (regression test: repeated corrupt-file loads, flat
active memory), and the batch-scheduler quantized-rotating join no longer
takes the unused bf16 temporalView (6 arrays/join, pre-existing from
859572d). The robustness triple is CLOSED too: turbo head-dim validated at
createServer (was a per-request 500 mid-prefill for unsupported dims),
StreamDecoder's revised-text path is a truncate-safe resync + once-per-
stream warning (was whole-stream duplication for future cleanup-rule
tokenizers; regression-tested with a fake cleanup tokenizer), and the
two-model draft prefill drains in PREFILL_CHUNK=2048 chunks like its
oracle (was one unchunked forward — a 32k prompt ran a 32k-position
draft forward). **DSpark serving program
Phase 1 CODE is done** (1a quantize script, 1b quantized drafter forward,
1c acceptance A/B harness — all tested); 1d awaits Josh's GPU run:
`bun scripts/dspark-quantize-drafter.ts <bf16-drafter-dir>` then
`bun scripts/dspark-drafter-ab.ts --target gemma-4-12B-it-OptiQ-4bit
--drafter-a <bf16> --drafter-b <q4>`.

## Previous (2026-07-07 — decode@ctx gap closed: SSD write-behind flush is now idle-gated)

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

## Parallel thread: web chat redesign (2026-07-06/07, branch feat/web-chat-phase2)

[docs/design/web-chat-redesign.md](docs/design/web-chat-redesign.md) is the
working UI plan (supersedes web-ui-pass-plan.md; revised 2026-07-06 to the
**superset doctrine** — concede nothing, differentiate on top — with
[web-chat-beat-matrix.md](docs/design/web-chat-beat-matrix.md) (12 axes,
116 rows, MATCH/BEAT/SKIP) as the coverage contract, §6.6 the app-aware
assistant, and principle 9: the bar for done is perfect visual polish).

**Phases 0, 1, AND 2 are done + visually QA'd on this branch, rebased on
post-merge main (PR #18/#19/#20).** Phase 1: block-memoized streaming
render + vendored hljs; per-turn `lane` → live perf strip (verified live:
"230 tok/s · TTFT 292ms · BATCHED"); full sampling popover w/ per-model
defaults; message actions (regenerate/edit-as-sibling via navigateTree);
mobile drawer, light theme, Cmd+/ sheet; gc endpoints; /v1/models
tier+vision+gen_defaults. Phase 2 (248a85d): app.html's inline script →
12 typed modules (type-only WS-contract imports from pi-web; generated
committed src/web/app.js + freshness gate; tsconfig.web.json; happy-dom
harness incl. streaming-parity fixtures); /api/memory/* REST + POST init
(confined to vaultRoot/tmpdir after review caught arbitrary-path git-
commit exposure); Memory panel (vault browser, git History+diff view,
Reference docs, provenance chips, personalized hero, consent card —
full flow verified live on a scratch vault); adapter routing table
(three-state + ramBytes + "a+b" stacking test-proven); model picker w/
/fit verdicts (live swap deferred to Phase 3 Hub); per-chat system
prompt (before_agent_start layering) + presets v1; approval gate wired
(codingTools opt-in, editable args via SDK event.input mutation,
durable ~/.mlx-bun/tool-approvals.json); Developer IA toggle; "#"
mention. Lane semantics re-verified against merged DSpark GenerateStats.
Visual QA (3228734) fixed a placeholder-wrap regression + .bubble-scoped
markdown chrome missing in the panel. Follow-ups: # mention doesn't
search Reference/ docs; wikilink graph view (plan §5.5) still line-only.
**Phase 3 done + visually QA'd, rebased through main@ca0ba91 (PRs
#21–#27 incl. the audio-capability ready-frame union).** Files-RAG v1
(client BM25, [n] citations, Sources panel); Model Hub (/api/hub/* w/
real /fit verdicts; live swap honestly deferred — the isolate proxy
501s /ws/chat); Canvas v1 (allow-scripts-only iframe, verified live);
self-healing tool calls (format-aware repair in OUR parsers + envelope
guard after a critical review catch — bare-JSON replies can't execute
as tools); set_sampling scope:"next_turn"; **app-aware assistant v1
verified live: "take me to quantize" navigated the real app via
navigate_app** (§6.6 never-hijack spotlight, ambient context line,
catalog-validated tools); Cmd+K palette (live); full-text session BODY
search (live over HTTP); MD/JSON export; PWA manifest+sw (200s).
Phase-3 follow-ups: RAG [n]-citation compliance unproven on 1B-class
models; spec-lane badge demo needs a compatible draft artifact;
history-replay citations need a HistoryItem field. Next: Phase 4
(plan §9 — trust & speed: temporary chat, disk-touch tally, cache-hit
telemetry, logprobs overlay, HLG in composer, ambient assistant panel
+ process-state snapshot maturity).

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
oracle (known). Spec-decode serve lane re-anchor: **DONE 2026-07-07,
merged in PR #19** — and its oracle's true shape turned out to be
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
serving-UX/defaults pass). TurboQuant merged 2026-07-07 (PR #20) — the
Phase-5 gate is CLEAR; Phase 1's code boxes (1a/1b/1c) landed the same
day, 1d is the next GPU run.**

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
(merged in PR #19):** DSpark + the optiq Gemma
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
2. **Phase 14 retarget — Qwen3.8-27B, full support** (supersedes the
   3.6-27B confirmation; findings + sub-phases in PLAN.md "Phase 14
   retarget"). Scope per Josh: text + thinking controls + tools + MTP
   + vision + video, then retire 3.6. **Text parity is GREEN
   (2026-08-16, M4 Pro): full prefill grid plus 32 decode steps bit-exact
   vs mlx-lm on the published
   `mlx-community/Qwen3.8-27B-OptiQ-4bit` artifact, first try** —
   `MLX_BUN_TEST_QWEN38=1 bun test tests/qwen-parity.test.ts`. The MTP
   drafter (`Qwen3.8-27B-MTP-bf16`, the Qwen-trained head split from
   the release's shard 18) is also downloaded. 14r-c serving features
   LANDED (reasoning_effort depths, preserve_thinking, think-tag
   streaming, tool format verified; docs in server-api/README/matrix);
   live-serve smoke on the M4 Pro: thinking + instruct/eos PASS, the
   reasoning_effort + tool round-trips hit 30-min swap-starvation
   timeouts (logic verified model-free; re-run on the M1 Max).
   **14g MTP: the rollback blocker is SOLVED post-release (2026-08-18, M1
   Max).** The serve loop now speculates on gated-DeltaNet targets via the
   spec-round contract (SSMCache snapshot/replay — free snapshot from MLX
   array immutability; partial rejects bit-exactly replay the kept prefix
   from recorded position-local inputs). Provider/tap/CLI (`--draft-kind
   mtp`) restored. Gates green: kernel prefix property + round lifecycle
   (tests/qwen-ssm-specround.test.ts, model-free) and REAL-WEIGHTS serve-loop
   losslessness with real rollbacks on Qwen3.5-0.8B
   (tests/qwen35-spec-ngram.test.ts — also newly enables ngram/two-model
   spec for the whole qwen3_5 family). The 27B pairing gate is ALSO GREEN
   (2026-08-18, M1 Max): `MLX_BUN_TEST_QWEN38_MTP=1` token-identical to
   non-spec greedy, acceptance 88% (30/34), 2.82 tokens/target-forward.
   ALL 14g follow-ups are closed (2026-08-18, quiet M1 Max — full detail in
   PLAN 14g): the quiet-machine interleaved TPS A/B is a durable NEGATIVE
   perf verdict (median MTP-on 12.93 vs off 15.75 tok/s = 0.821× at γ=2,
   61% acceptance, arms token-identical, spreads ≤4.4%) — the head's serial
   full-vocab lm-head cost per draft eats the saved forwards, so MTP is
   correct-but-slower and stays opt-in; direct drafter-logit parity vs the
   mlx-vlm 0.6.14 reference on identical hidden inputs is EXACT in tokens
   and top-8 ordering (worst |Δlogprob| 1.9e-1 = bf16 logprob floor); and
   the M4-Pro-swap-starved serve smokes pass here 4/4 (pressure theory
   confirmed). Harnesses: scripts/experiments/qwen38-mtp-ab.ts,
   oracle-qwen38-mtp-logits.py, qwen38-mtp-logit-parity.ts.
   Separately, qwen3_5-27B serial-lane decode dies with a
   GPU command-buffer failure surfacing as an uncatchable Metal-
   completion-thread C++ throw (full finding + .ips backtrace in PLAN
   14g; leading theory = command buffers failing under the 20.35 GB +
   swap regime — parity/sync is bit-exact and the pipelined repro
   passes standalone). ~~M1 MAX PICKUP~~ **DONE 2026-08-18**:
   `MLX_BUN_TEST_QWEN38_SERVE=1` passed 4/4 on the M1 Max in 17.5s —
   pressure theory confirmed (the M4 Pro timeouts were swap starvation,
   not logic). 14z (TQ×weights, ~4 bpw) is PROMOTED as the
   M4-Pro fit lever (interim: the uniform -4bit artifact). Then:
   perplexity provenance check, 14v vision / 14w video (mlx-vlm
   reference), TurboQuant KL cell (14r-d), retire 3.6 (14r-b2).
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
