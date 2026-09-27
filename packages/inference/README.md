# @mlx-bun/inference

Composable inference components built on [`@mlx-bun/mlx`](../mlx/README.md).
Callers choose artifacts and graphs, own state, and invoke inference directly.
The package includes the existing specialized kernels and graph implementations,
input processing, sampling, generation, embeddings, transcription, and optional execution.

## Contracts and composition

The root API composes the lower layers for loading and generation. Component
subpaths remain available for direct use and custom graphs. See the
[architecture](../../ARCHITECTURE.md) for dependency direction and ownership.

`contracts/portable` contains platform-free inference interfaces and can be consumed
without Bun or MLX types. `contracts/mlx` describes tensor and state interactions
using MLX types. `contracts` exports both. Use the portable entry when sharing
inference output or scheduling types with application and browser code.
Application protocols and job contracts migrate with their owning apps.

Paged attention accepts numerical storage; adapter mounting accepts named LoRA
targets; prompt preparation accepts encoder interfaces. Callers can supply their
own implementations without subclassing a concrete model or cache.

## Numerical and execution policy

The inherited fidelity policy is L1 by default: bit-exact numerics against the
pinned mlx-lm oracle for matching artifacts, inputs, and settings. L2 covers
schemes with a different oracle, including mlx-optiq mixed-KV, and requires
bit-exact comparison to that scheme's reference. Lab paths without an oracle
need numerical/quality evaluation and a paired A/B before becoming defaults.
These are correctness obligations; the outstanding real-weight verification is
tracked in the [refactor plan](../../PLAN.md#verify-the-migrated-library).
They do not make application sampling or serving defaults identical to mlx-lm.

Execution policy treats default memory estimates as advisory. Attempt the
requested work without rejecting it or clamping output tokens solely because
of a predicted memory estimate. Explicit user limits, queue capacity, and actual
layout requirements still apply; release owned resources on failure. Application
composition must preserve this policy when binding the optional execution layer.

### External parity evidence

On 2026-09-24, inference at `5527989` and main at `02d723a` independently matched
the external mlx-lm reference for MiniCPM5-1B-OptiQ-4bit, snapshot
`664aabaed233c653f82716d8dc822234d0091f78`. On an Apple M1 Max with 32 GiB RAM,
macOS 27.0 (26A428), and Bun 1.4.2, all 100 greedy tokens and all 13,056,000
float32 logits were byte-identical; all logits were finite. The prompt was
`The capital of France is` (six matching tokenizer IDs), batch one, default
unquantized KV, with no `MLX_BUN_*` overrides and no EOS early stopping.

The external environment used Python 3.13.5, MLX/MLX-Metal 0.32.2 and mlx-lm
0.31.3. Reference generation used the unchanged Python body from
`02d723a:scripts/regen/minicpm5.ts`; model-file and per-step reference hashes
were checked. The reference manifest SHA-256 is
`e20d64193328d5dfe1c4b9681651730b35b2eeb2f5152b0ae3d8fb50b05dfd5f`.
The [MiniCPM5 parity test](tests/parity/minicpm5-parity.test.ts) is that harness:
public root, model, and scoring imports, forwarding the prompt once and each
selected token thereafter with the same live cache (plain KV from the model).
It requires byte-identical finite logits and the greedy token at all 100 steps.
Opt in with all of `MLX_BUN_TEST_MINICPM5_MODEL`, `MLX_BUN_TEST_MINICPM5_REFERENCE`
(the directory holding `minicpm5-parity.json` and the 100 step blobs) and
`MLX_BUN_TEST_MINICPM5_REFERENCE_SHA256`; absent all three it skips, any other
combination fails. Before native libraries load it verifies the manifest hash, the
pinned model files and shards by content (relocated copies pass) and every blob;
the runtime must match the reference's MLX version and GPU architecture.
This covers that path only, not other models, batching, quantized KV,
snapshot restore, long contexts, or speed. Raw outputs and the reference
remain external; Python is not a project dependency.

On 2026-09-27 UTC, the rotating live-window correction (source `5ec1f4ae`) was
checked on the same M1 Max (MLX 0.32.2, pinned native library) against selections
made independently of `temporalView`, main `02d723a`, and pinned optiq 0.2.7.
Gemma4 e2b and a custom graph over unchanged Llama-3.2-3B weights (alternating
sliding layers, window 8; not a published model) matched main's B1 logits byte for
byte in 13 cases. In 14 late-join and initial two-row cases, at both tail-split
settings, every projection, token and valid state equaled the same batching code
reading rows through the independent selection, and merged rows equaled their own
B1 state; before the correction, late joins without a tail split and initial
two-row batches merged the oldest window. Gemma4 e4b donor attention (plain and
affine) and the deterministic assistant-drafter chain
(`gemma-4-E4B-it-assistant-bf16` `844e008e`) equaled their independent references
byte for byte through prefill, a verify block, a rollback and a decode; below the
window the chain equaled main's. For DiffusionGemma 26B-A4B with a 1,500-token
prompt, the decoder-selected encoder K/V of all 30 layers and the full first-pass
logits equaled the pinned optiq reference byte for byte, and the opt-in real-weight
test passed with measured main references. This covers these paths only, not
stochastic speculative verification, other models, performance or full-candidate
qualification. Raw evidence remains external.

Three opt-in consumers repeat these checks. The
[rotating-join test](tests/execution/rotating-join.test.ts) takes
`MLX_BUN_TEST_ROTATING_JOIN_MODEL` (a Gemma4 artifact with sliding layers) and, for a
custom graph over a Llama-family artifact's unchanged weights,
`MLX_BUN_TEST_ROTATING_JOIN_WINDOW`; it runs late joins and two-row preparation with
the prompt tail split off and on, each against the same run reading rows through an
independent newest-window selection, and compares merged rows with their solo state.
The [Gemma4 assistant test](tests/parity/gemma4-assistant.test.ts) takes
`MLX_BUN_TEST_ASSISTANT_TARGET` and `MLX_BUN_TEST_ASSISTANT_DRAFT` and compares donor
attention and deterministic draft chains with independently selected donors past the
window. The [DiffusionGemma window test](tests/parity/diffusion-gemma-window.test.ts)
takes `MLX_BUN_TEST_DIFFUSION_WINDOW_MODEL`, `MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE`
(a directory holding `manifest.json` and raw tensors, produced outside this
repository) and `MLX_BUN_TEST_DIFFUSION_WINDOW_REFERENCE_SHA256`; the manifest pins
the inputs, artifact files, producing runtime and every tensor. The artifact, inputs,
geometry and reference tensors are verified before native libraries load; the
producing runtime (MLX version, GPU architecture) is checked right after the native
import, and each produced tensor's shape and dtype before its bytes. Each of these
tests skips only when none of its settings is present.


### Repeatable runtime comparison

The source-checkout tool `bun packages/inference/scripts/runtime-oracle.ts --help`
explains the plan schema and `emit`/`compare` commands. It hashes complete logits,
live cache planes and one-token continuation; `compare` is CPU-only. Supply local
weights and external reference reports. No Python environment or reference data
is installed by this repository. The opt-in test uses `MLX_BUN_PARITY_PLAN` and
`MLX_BUN_PARITY_REFERENCE`; it skips only when none of its settings (those two,
`MLX_BUN_PARITY_TIMEOUT_MS`, `MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG`) is set, and a
partial or blank opt-in fails. Legacy reports require explicit
`--allow-unrecorded-config` (test: `MLX_BUN_PARITY_ALLOW_UNRECORDED_CONFIG=1`), after
verifying their environment separately. New reports record runtime overrides,
source/harness/native hashes, machine and plan; `--hash-weights` adds weight hashes.

On 2026-09-25 UTC, `6b0fd69` matched main `02d723a` and its unchanged external
`02d723a:scripts/oracle/check-runtime.py` for the same MiniCPM snapshot above. All nine
cases (contexts 0/64/320 × append lengths 1/8/128, prefix chunk 128, batch one)
matched bit-for-bit for full logits, prefix/append state and continuation logits/state.
The machine was the same M1 Max; Python was 3.14.5, MLX/MLX-Metal 0.32.2,
mlx-lm 0.31.3. Runtime overrides were only `MLX_BUN_COMPILED_DECODE=0` and
`MLX_BUN_TEST_RUNTIME_ORACLE=1`; references ran sequentially with HF offline.
The weight SHA-256 was
`88bb686ed4a28f7c2065e27aabef7669f84961ac47c83efe2d003436c179e2e4`;
the Python report SHA-256 was
`bc034fd8f6aec39ec9f90c1aeeed1caed713efc58453e85f4cfc32b6046c86d5`.
This covers plain KV and chunked prefix continuation, not mixed KV, saved-state
restoration, compiled decode, sliding-window wrap, other families or performance.
Raw reports remain outside Git; the broader PLAN verification item stays open.

The plan can additionally request `kv: "artifact"` for the checkpoint's existing
mixed-KV policy and `restore: true` for persisted state and continuation checks.
Conversion happens after each forward, never on empty state. Restore verifies
tensor integrity, the saved token prefix, live planes and continuation against
the uninterrupted path; it does not restore sampling or execution sessions.
Temporary checkpoints are removed after each case.

Oracle goldens and recorded comparisons are published outside this repository;
run the tool against a pinned golden revision or regenerate one. A mixed-KV
comparison must use the documented per-path composition (stock mlx-lm attention
for one query, OptiQ tiled attention for multi-query input), not every default of
`optiq serve`, whose fused install also changes single-query decode.

### Compiled decode verification

The opt-in `tests/parity/compiled-decode.test.ts` accepts local checkpoint paths
through `MLX_BUN_COMPILED_GEMMA_E4B` and `MLX_BUN_COMPILED_GEMMA12B`. Run it with
`bun --no-env-file test packages/inference/tests/parity/compiled-decode.test.ts`
from the root. Each unset path skips that family; a supplied invalid path fails.
The checkpoints must include their existing mixed-KV configuration. No model or
reference data is downloaded.

The test compares native full-logit bytes for identical fixed tokens with plain
and artifact-configured KV, both before and after the sliding window fills.
Greedy trajectories and dense Gemma's mid-segment failure recovery use main's
original tokenizer-rendered prompts (12B targets 600/1100 tokens; e4b targets 700).
Those checks require actual compiled-step activation and zero unexpected retraces.
The forced-token full-logit matrix uses deterministic IDs independently of EOS. These are
compiled-versus-ordinary checks, not an external-oracle or performance claim.
Runtime compilation overrides stay inside the test; this adds no application option.


### Scheduler continuation and specialized-path checks

The opt-in [continuation test](tests/parity/ordinary-continuation.test.ts) takes
`MLX_BUN_TEST_CONTINUATION_MODEL=/cached/checkpoint`. It compares uninterrupted
and interrupted/restarted B1/B4 generation, including pending tokens, seeded
sampling history, byte-identical checkpoint planes, and actual restored-row
counts. `MLX_BUN_TEST_CONTINUATION_ADAPTER=/cached/adapter` adds adapter-context
and cache-namespace isolation without bundled fixtures. The existing KV matrix
uses `MLX_BUN_TEST_CONTINUATION_KV=bf16|4|8|per-layer|turbo`,
`MLX_BUN_TEST_CONTINUATION_KV_START=0` (or `prompt+N`), and
`MLX_BUN_TEST_CONTINUATION_INTERRUPT=6` (6–15).
The test uses the actual capability planner. With an adapter and positive affine
start it also checks grouped admission, an event-driven late join, cancellation
against a matched stop control, queued base-context isolation and reuse after
drain. Mounting must change full logits, and unmounting must restore the base.
Full-attention universal graphs accept ordinary adapter requests with uniform
or per-layer delayed affine KV and adapter-aware continuation. Paired B1
Qwen2.5-0.5B acceptance without a configured draft matched main for uniform
KV4/KV8 and partial mixed KV, greedy/seeded sampling, and fresh-process
continuation before and after conversion: full logits, every valid cache plane,
adapter identity and unmount restoration. Separate candidate B2/B4 tests without
a configured draft passed joins, cancellation, queued adapter/base isolation
and reuse after drain.

Gemma4 adapter rows also take ordinary generation checkpoints when the server's
paging option is enabled: the resolved row uses plain KV, so checkpoint identity
and continuation are the same with paging enabled or disabled. Paired B1 checks
on Gemma4 e2b OptiQ-4bit (snapshot `b0162532`, MacBookPro18,2, MLX 0.32.2)
matched main `02d723a` at capacity 1 against continuous capacity 8 for 16 tokens,
greedy and seeded sampling, and fresh-process restoration across both settings.
Full logits and all 15 donor KV states matched; all 35 layer outputs and the
final norm matched by hash. The nonzero adapter changed logits and unmounting
restored the base. Actual paged rows remained checkpoint-ineligible. This covers
one active row within the sliding window, not grouped rows, paged numerics,
hard-kill durability, external-oracle parity or performance.

MiniCPM5 and these universal graphs also ignore a configured draft and supplied
fill for adapter requests, as main did; requested logprobs remain available.
Without fill/logprobs/grammar, ordinary checkpoints remain eligible. The fallback
does not invoke the provider during a request; loading an artifact-backed draft
still performs its existing compatibility probe. Paired B1 acceptance on cached
Qwen2.5-0.5B and MiniCPM5-1B compared six scenarios per model, each with a matched
draftless adapter control, over 16 generated tokens. The scenarios cover
TwoModel and Ngram, uniform KV4/KV8 and partial mixed KV, ignored strict/verify/echo
fill, requested logprobs, and greedy or seeded sampling. Full logits and all valid
KV planes matched main and controls; request-time draft/fill counters stayed zero,
nonzero adapters changed logits, and physical unmount restored base logits.
The no-fill scenarios retained plain or encoded checkpoints and matched
uninterrupted output after graceful cancellation and fresh-process restoration.
This does not qualify every combination or multi-row configured-draft requests.

Only the first cold decode/resume token may have signed versus unsigned int32
metadata; its raw bytes, value and computed state must match exactly. Supplied
fill also falls back to ordinary decoding without adapters or a configured draft:
main ignored it on these graphs because no affine append binding exists.
Paired B1 acceptance on cached MiniCPM5-1B and Qwen2.5-0.5B matched main and
no-fill controls for supplied strict/echo fill, unseeded greedy sampling and
KV4 starting at token 8. Each request generated 16 tokens across conversion;
all 17 forward states, 16 full-vocabulary projections and valid cache planes
matched, and every fill hook stayed unused. Main planned fill and disabled it
inside generation; the new planner reports `fill-incompatible-with-request`
and selects ordinary continuous decoding. This pair does not qualify B2 or
cancellation.
Requests that supply fill remain ineligible for generation checkpoints. Actual
delayed speculation, sliding descriptors and softcap encoded KV remain excluded. These checks do not cover cross-version checkpoint
files, hard-kill durability, an external oracle or performance.

The [padded-prefill test](tests/parity/padded-prefill-model.test.ts) takes
`MLX_BUN_TEST_PADDED_PREFILL_MODEL` and `MLX_BUN_TEST_PADDED_PREFILL_REFERENCE`.
The external JSON report is `{ runtime, configSha256, rows }`, where `rows` is
the output of the unchanged Python body in
[`02d723a:tests/parity/padded-prefill-model.test.ts` lines 9–56](https://github.com/joshuarossi/mlx-bun/blob/02d723a/tests/parity/padded-prefill-model.test.ts#L9-L56): prompts, padding side, chunk counts,
recurrent-state hashes, four per-row logit hashes, and row offsets. The test
requires all 18 cases (36 with `MLX_BUN_TEST_PADDED_PREFILL_WIDE=1`), then compares
the full-vocabulary float32 logit slice at the last prompt position for each row
and each of three continuation steps via SHA-256, plus recurrent state.
`runtime` is the MLX core version (for example, `0.32.2`), not the mlx-lm version. Generate the reference outside this repository on the same machine with
the pinned oracle and identical weights; this test never starts Python.
`MLX_BUN_TEST_PADDED_FULL_LAYOUT=affine|turbo`,
`MLX_BUN_TEST_SPECULATIVE_ROTATING_LAYOUT=1`, or
`MLX_BUN_TEST_PADDED_ROTATING_LAYOUT=1` exercise the corresponding pre-conversion
cache layouts against the same plain-KV reference, not quantized arithmetic.

The [Gemma2 batching test](tests/models/universal/gemma2-batching.test.ts) runs
synthetic mask checks with `MLX_BUN_GEMMA2_NATIVE=1`; add
`MLX_BUN_GEMMA2_MODEL=/cached/gemma2` for real B1/B2/B4 continuous lifecycle checks.
Supplying a model or reference without the native opt-in, a reference without a
model, or an invalid model config fails before native initialization.
`MLX_BUN_GEMMA2_REFERENCE=/external/report.json` adds full-logit and KV hashes
against same-shaped pinned Python runs. The reference uses upstream Gemma2
and `BatchKVCache`, adding only a GQA axis to the upstream row mask. B1 is
compared exactly with direct execution; B>1 uses the same-shaped reference,
since quantized matmul dispatch can change numerical results across batch sizes.
The app gateway's real Gemma2 placement test uses the same
`MLX_BUN_GEMMA2_NATIVE=1` opt-in: importing the graph loads MLX even though
that test only checks placement and allocates no tensors. Native-blocked CPU
runs skip this check; synthetic gateway tests remain CPU-only.

With `MLX_BUN_GRAMMAR_JUMP=1`, Gemma2 plain-KV ordinary requests preserve
main's direct forced spans through the shared scheduler: one graph append for
`[pending, ...forced]`, with no sampling of forced IDs. Graphs already using
verified grammar proposals retain that behavior. Paired greedy Gemma2-2B checks
against main passed a terminating choice and nonterminal JSON schema, including
full-vocabulary logits, all 26 valid KV layers, masks and publication order.
Separate real-gateway checks passed callback stop inside a committed span,
retention and restoration of the complete prefix, fixed-suffix continuation,
mid-span cancellation with an active peer, and same-scheduler recovery. Graph
calls remain B1; this is not stacked batching or an all-model qualification.
The shared gateway owns prefix transfer and, as on main's shared path, returns
an empty `stats.cacheTokens`; direct generation retains its exact cache history.
No full-stats, HTTP cancellation, abort-last/abort-plus-stop, oracle or performance
identity is claimed by these checks.

Shared Gemma2 qualifies plain KV, including grammar-constrained and adapter
requests; the opt-in [constrained Gemma2 test](../../apps/mlx-bun/tests/engine/gemma2-constrained.test.ts)
compares them exactly with direct generation. Plain-KV fill uses the shared fill
binding: with `MLX_BUN_GEMMA2_MODEL`, the batching test replays main's serial fill
(one-position assert appends, one verify forward per echo span, trim on rejection)
and requires B1 logits bit for bit, then B2/B3/B4 tokens through joins and
cancellation, observing each capacity as the batch's high water. Fill also runs
inside a request's adapter context; the constrained test's grouped case checks
four-row adapter groups, partition from base rows, an event-driven join and a
replacement, a cancellation against a same-count stop control, and no leak. Plain-KV
generation continuation uses the shared continuation binding once persistence is
configured; the opt-in [Gemma2 continuation test](../../apps/mlx-bun/tests/engine/gemma2-continuation.test.ts)
runs it through the app's serving composition: interval snapshots, a durable
record surviving cancellation, its restore after a fresh engine, and cleanup on
completion. Plain-KV two-model speculation uses the shared speculative group
with a second loaded instance as the draft; the batching test's opt-in two-model
case checks B1 determinism, main's gate that greedy grammar with speculation
equals greedy grammar alone, a ragged joined group (its measured target batch),
cancellation, and a follow-on request that reproduces the fresh B1 run. N-gram
lookup drafting uses the same group; its opt-in case observes rounds where a
proposing row verifies beside an empty, right-padded peer and rounds where no row
proposes, swaps the padded peer's content without changing the target's forwards,
proposals, tokens or logits (greedy and seeded), cancels a ragged third row against
a same-count stop control, and checks main's grammar gate. Encoded
KV, draft providers whose rows tap target hidden layers (this graph has no tap
operation), and paging retain typed unsupported placement.
Its full-attention policy remains the pinned mlx-lm policy documented in the
[architecture descriptor](src/models/universal/archs.ts).
A plain-KV adapter request with a configured TwoModel or Ngram draft uses
ordinary continuous decoding and ignores both draft and fill, as main did.
This is an ordinary fallback, not adapter speculation support. Paired B1 greedy
acceptance against main passed with a synthetic nonzero adapter on Gemma2-2B:
full logits and valid KV match with either draft configured, with or without
fill and logprobs; draft and fill stay unused, and physical unmount restores
the base computation. This does not qualify multi-row adapter/draft requests.

A plain-KV request without adapters keeps two-model or n-gram speculation when
fill is supplied, but ignores the fill session (strict, verify or echo), as main
did. Logprobs instead select ordinary decoding and ignore both draft and fill.
Paired B1 greedy acceptance on Gemma2-2B matched main and each fill-off control:
full target/draft logits, valid KV, proposals, continuing commits, output and
logprobs; genuine drafting ran when selected, and every fill hook stayed unused.
Main omits its terminal speculative commit; the candidate's terminal state was
checked against its verified prefix, without a main-terminal parity claim.
This does not qualify B>1, external-oracle parity or performance, or enable
speculative fill.

The [Trellis specialization test](tests/parity/trellis-shared-m.test.ts) takes
`MLX_BUN_TEST_TRELLIS_MODEL=/cached/packed-qwen`. It preserves main's variant
comparison: `MLX_BUN_TRELLIS_AB_VARIANT` (default 7) against
`MLX_BUN_TRELLIS_AB_BASELINE` (default 6). Use variant 13 against baseline 12
for the optimized expansion path. M=1–5 compares complete logits, recurrent/KV
state and continuation; variant 13 also checks M=16/128/512 with the last-position
head. Six alternating-order blocks also screen the last-position head at
M=1–5/8/9/16, M=32 for variants 11–13, and M=128/512 for variant 13.
These are exact within-artifact specialization checks, not a Python oracle
or timing claim.

Run each file with `bun --no-env-file test <file>` and exclusive GPU access.
Unset required paths skip before native imports; supplied invalid model paths
or a partial padded-prefill opt-in fail. Open acceptance work lives in
[PLAN](../../PLAN.md#verify-the-migrated-library).
They extend rather than repeat [#61](https://github.com/joshuarossi/mlx-bun/pull/61)
(MiniCPM/Gemma plain and mixed state restore; Trellis against main),
[#62](https://github.com/joshuarossi/mlx-bun/pull/62) (Gemma e4b window-wrap state
restore), and [#64](https://github.com/joshuarossi/mlx-bun/pull/64) (compiled
Gemma e4b/12B). Those completed comparisons do not cover scheduler sampling
recovery, padded cohorts, or this real-model Trellis variant matrix.


## Direct library use

See [Qwen3 loading and generation](examples/qwen3-generate.ts). Run it from the
repository root with `bun packages/inference/examples/qwen3-generate.ts <checkpoint-directory> "Hello"`.
It loads the local tokenizer, streams tokens from the supplied graph, and releases
weights after generation completes.

Use the graph matching your checkpoint, or compose your own operations and supply
an explicit binding. The root export contains common loading and generation
helpers; the subpaths below expose individual components. These workspace packages
are version `0.0.0` during the refactor and have not been published to npm.

## Trellis weight expansion

See the runnable [Trellis expansion example](examples/trellis-expand.ts). Its
`expandWeights` function borrows codes and scales and returns an owned lazy tensor.
`bun packages/inference/examples/trellis-expand.ts` demonstrates the layout with
small generated inputs, without a model download.

The caller supplies uint32 packed codes, one floating-point scale per stored
row, and matching geometry. The eligibility helper checks the kernel's supported
geometry and output dtype; callers remain responsible for matching tensor
shapes and dtypes. This kernel supports the existing 1MAD codebook with L=12,
256-symbol blocks, and 2-, 3-, or 4-bit codes. Output is the stored matrix in
bfloat16, shaped `[rows, cols]`. For axis 0, that is the transposed weight layout.

The existing interleaved 3-bit layout uses `blockInterleave: 2` and codes shaped
`[cols / 512, rows, 48]`. Row-major codes use `[rows, cols * k / 32]`.

Expansion is lazy. The caller decides when to evaluate the result and owns its
array handle. The kernel does not load checkpoints or choose a model.

## Packed operations

All operations are imported from `@mlx-bun/inference/kernels/trellis`.
They borrow input arrays and return an owned, lazy output array.

| Operation | Input and purpose |
| --- | --- |
| `trellisReduce(x, codes, scales, geometry, variant)` | Axis-1 projection; `x` is `[M, inFeatures]`, M=1..4 |
| `trellisScatter(x, codes, scales, geometry, variant, useSharedScatterCodebook?)` | Axis-0 projection; same input shape and row budget |
| `fusedGateUpSwiglu(x, gate, up, variant)` | Matching axis-1 gate/up geometry and bit width; preserves leading input dimensions, with 1..4 total rows |
| `fusedGateUpSwigluMixed(x, gate, up, variant, tail?)` | Matching axis-1 geometry with independent bit widths; `tail` is `"fused"` or `"split"` |
| `expandTrellis(codes, scales, geometry, dtype, variant)` | Existing general expansion and variant-13 vector specialization |
| `tiledTrellisPrefill(x, codes, scales, geometry)` | Axis-1 packed prefill, M=5..32 |
| `splitKTrellisPrefill(x, codes, scales, geometry)` | Axis-0 packed prefill, M=5..8 |
| `wideTrellisPrefill(x, codes, scales, geometry)` | Axis-1 prefill following MLX's GemvWide arithmetic, M=5..15 |

`gate` and `up` are `TrellisWeights`: `{ codes, scales, geometry }`.
Callers supply compatible tensors and choose the variant explicitly. Existing
variant numbers are preserved: 6 uses the original packed f32 code/scale path;
13 adds the existing shared-work and expansion specializations. Variant 4 is
the inherited timing-only path and does not compute decoded weights correctly.
No application environment flags are read by these operations.

For prefill, use the corresponding `*Eligible(geometry, rowCount, dtype)` helper
to preserve the existing dispatch profile. Wide prefill additionally requires
caller-proven aligned, row-contiguous input. These profiles and numerical
contracts are unchanged; they are not universal dispatch rules for every shape.

## Artifact, input, and layer APIs

- `@mlx-bun/inference/artifacts`: model configuration, safetensors metadata,
  and lazy native weight loading through `Weights.open(directory)`. The caller
  supplies the local artifact directory and any graph-specific weight view.
- `@mlx-bun/inference/artifacts/auxiliary-files`: `copyAuxFiles(source, output)`
  copies tokenizer, template, and other non-weight checkpoint files when present,
  without loading MLX.
- `@mlx-bun/inference/input`: `loadTokenizer(directory)` consumes the existing
  Hugging Face tokenizer files; `ChatTemplate.load(directory)` loads the template.
- `@mlx-bun/inference/layers`: quantized linear and embedding layers, RMSNorm,
  and `TrellisLinear`, which composes the standalone Trellis kernels and retains
  the existing dispatch and expansion fallback.
- `@mlx-bun/inference/layers/lora`: inference-time LoRA state and weights.
- `@mlx-bun/inference/runtime/config`: immutable execution settings and scoped
  overrides. The existing `MLX_BUN_*` defaults are preserved during migration.

These modules do not download models or start services. Tensor handles returned
by `Weights.tensor()` are borrowed from the weights owner; release them through
`Weights.release()`, `releaseShard()`, or `dispose()`. Layer outputs are owned
by the caller.

## Concrete graphs

Import a graph directly, provide its weights and configuration, and own its state:

See [explicit forward passes and state ownership](examples/qwen3-forward.ts).
Run `bun packages/inference/examples/qwen3-forward.ts <checkpoint-directory> "[1,2,3]"`
with token IDs from your checkpoint’s tokenizer. The example forwards the prompt,
selects a token, continues with the same cache, and disposes cache before weights.

The direct graph imports currently include `models/gemma4`,
`models/gemma4/generated`, `models/minicpm5`, `models/qwen3`, `models/qwen3-moe`,
`models/qwen3_5`, `models/qwen38-27b-trellis-tq`, and `models/universal`.
`models/glm52`, `models/diffusion-gemma`, and `models/whisper` provide the other
existing graph families. These retain the dedicated and specialized implementations.
`@mlx-bun/inference/models` exposes the existing profile/implementation registry
and model construction helpers. Direct graph constructors remain available.

For explicit state and tensor operations, use `graph.makeCache()`,
`graph.forwardHidden(ids, state)`, and `graph.logitsFromHidden(hidden)`.
Release state with each cache's `dispose()` and release returned arrays when
finished. `bindMlxGraph` from `models/graph` adapts caller-supplied operations to
an explicit graph descriptor and logits selection contract without owning weights.

Shared dense/quantized layers, activations, normalization, and RoPE live under
`layers/`; architecture assembly lives under `models/<family>/`. DeltaNet
kernels remain independently importable through `kernels/delta`.

## Native expert I/O

GLM's expert I/O support is built from `native/expert-io.c` with
`bun run --filter @mlx-bun/inference build:native`. The resulting dylib lives in
`dist/native/` and is included in the package archive. `prepack` rejects missing
artifacts. An existing build can be staged with `bun run stage:native <directory>`
inside this package. Loading uses the bundled library, or the caller's explicit
`libraryPath` / `MLX_BUN_EXPERT_IO_DYLIB` override.

`artifacts/experts` owns native I/O bindings, residency, and usage accounting;
`artifacts/glm52` owns direct-container and quantized-weight loading. Numeric
streamed expert kernels are independently available through `kernels/glm52`.

## State and attention

`@mlx-bun/inference/state` exposes the existing plain, affine, rotating,
TurboQuant, recurrent, and GLM compressed caches, plus row batching, scoped KV
maintenance, cloning, and persistence. The caller creates and owns the state.
`@mlx-bun/inference/contracts` holds the shared cache and ownership interfaces.
A rotating cache's `temporalView()` is its live window: the newest
`min(offset, maxSize)` positions in chronological order, including right after a
multi-token write leaves the ring oversized. Serial, batched, speculative and
aligned rotating layouts select the same window.

- `state/`: storage layout, positions, row membership, precision transitions,
  snapshots, and persistence. `persistence.worker.js` performs CPU disk I/O.
- `layers/quantized-attention.ts`: existing fused/unfused attention dispatch.
- `kernels/turboquant/`: packing, rotation, codebooks, and packed decode kernels.
- `kernels/delta/gated.ts`: DeltaNet kernels; recurrent storage lives in
  `state/ssm.ts`.
- `state/paged/`: existing opt-in paged state and its persistence codec.
  The numerical attention implementation lives in `kernels/attention/paged.ts`.

Public kernel imports are `@mlx-bun/inference/kernels/turboquant`,
`@mlx-bun/inference/kernels/delta`, and
`@mlx-bun/inference/kernels/attention/paged`. Paged state is available through
`@mlx-bun/inference/state/paged`. No cache mode or experimental default changed.

## Source ownership

All kernel files below live under `src/kernels/trellis/`.

| File | Responsibility |
| --- | --- |
| `codebook.ts` | Shared 1MAD Metal helpers, host LUT, and decoder variant mapping |
| `geometry.ts` | Trellis geometry and borrowed weight types |
| `reduce.ts` | Axis-1 packed matvec and its shared-row variant |
| `scatter.ts` | Axis-0 packed matvec, balanced/shared variants, and partial reduction |
| `gate-up.ts` | Same-width fused gate/up SwiGLU |
| `mixed-gate-up.ts` | Independent-width gate/up and its two activation tails |
| `expand.ts` | General stored-matrix expansion and vector dispatch |
| `vector-expand.ts` | Four-weight vector expansion |
| `tiled-prefill.ts` | Axis-1 tiled prefill |
| `splitk-prefill.ts` | Axis-0 split-K prefill and ordered reduction |
| `wide-prefill.ts` | GemvWide-compatible prefill and hardware eligibility |
| `index.ts` | Public Trellis imports |

Tests in `tests/kernels/` cover the host decoding reference, variant equivalence,
activation tails, packing, strides, and existing prefill comparisons against MLX.
The wide-prefill native comparison runs only on supported hardware.

The MLX runtime libraries belong to `@mlx-bun/mlx`; this package bundles its
expert I/O and video helpers. Set up
that package's native artifacts, then run `bun run typecheck` and `bun run test`
from the repository root.


## Sampling, embeddings, and adapters

`@mlx-bun/inference/sampling` exposes `makeSampler`, `makeLogitsProcessors`,
`makeStepSampler`, and the individual top-p/top-k/min-p/XTC and tone-curve
operations. `sampling/types.ts` owns options; `filters.ts`, `processors.ts`,
`hlg.ts`, and `curve.ts` own transformations; `step.ts` owns token history and
per-step sampling; `extras.ts` owns captured log-probability readback and disposal.
The caller supplies scores and chooses options. Returned arrays belong to the caller.

`sampling/grammar` compiles constraints against the caller's loaded tokenizer
using the existing xgrammar dependency. Await `ready()`, apply the mask to logits,
accept the sampled token, and dispose the controller when finished. The normalized
argmax and token-bitmask kernels are exposed through `kernels/sampling`.

`embeddings` provides the existing Qwen3 embedding helpers: `embedOne`, `embedMany`,
and `withInstruction`. Supply the graph and tokenizer explicitly. `adapters`
provides `AdapterManager` for loading and applying existing mlx-lm and PEFT LoRA
artifacts to a caller-owned graph; adapter weight/state types are also exported.

## Generation

The [generation example](examples/qwen3-generate.ts) iterates over emitted tokens
and returns the final generation statistics. It uses the same public generation
API available through the root and `@mlx-bun/inference/generation`.

`generate` uses the graph supplied by the caller. `generateAutoregressive` accepts
an explicit `MlxAutoregressiveBinding` from `generation/bindings/autoregressive`, including
caller-defined graph operations, state construction, and optional compiled decode.
`generateDenoising` accepts a denoising binding; `generation/diffusion` also exposes
`denoiseSync` and `denoiseAsync` directly. No service or model selection is involved.

`generation/autoregressive.ts` owns prefill and token iteration;
`generation/diffusion.ts` owns canvas denoising; `generation/result.ts` owns the
async iterator and final stats. `generation/scopes.ts` owns adapter,
wired-memory, and expert-usage lifetimes. Existing cancellation and early-return
cleanup behavior is preserved. `generation/fill` exposes the existing optional
fill session and proposal interfaces.

## Speech and vision

- `input/audio`: WAV parsing, AudioToolbox decoding, transcoding, mel features,
  and the existing Whisper tokenizer. `loadWhisperTokenizer` reads local HF
  artifacts; it does not download them.
- `transcription`: Whisper decoding, long-form and streaming transcription,
  word timing, and text/SRT/VTT formatting. Callers supply the Whisper graph,
  tokenizer, and audio samples. `transcription/format` exposes the
  text/SRT/VTT/verbose-JSON formatters alone, without loading native MLX, for
  HTTP layers that only shape responses.
- `models/audio/conformer` and `models/audio/silero-vad`: existing audio encoder
  and voice-activity graphs.
- `input/vision`: image decoding/preprocessing, multimodal prompt assembly,
  and video frames. Qwen preprocessing and prompt assembly have separate
  `input/vision/qwen3vl` and `input/vision/qwen3vl-prompt` imports.
- `models/vision/siglip`, `models/vision/qwen3vl`, and `embeddings/vision`:
  concrete vision encoders and embedding components.

The AVFoundation frame extractor is built by `build:native` and bundled beside
expert I/O in `dist/native`. It needs no runtime download or compilation.
`MLX_BUN_FRAME_EXTRACT` remains an explicit override. AudioToolbox and `afconvert`
use macOS system facilities. Optional encoder caching lives in `state/encoder-cache`;
media fetching keeps the existing destination, size, and timeout controls.

## Speculative generation

`generation/speculative` exposes `generateSpeculative`, `specRun`, and the existing
assistant, two-model, Qwen/GLM MTP, DFlash, DeepSpec, and n-gram proposal providers.
Supply the target graph, draft provider, token budget, and token callback yourself.
`specRun` accepts an explicit binding from `generation/speculative/binding`; it does not
require a concrete model class. The former `specServeRun` name remains available.

Draft graphs live in `models/gemma4/assistant`, `models/qwen/mtp`, `models/glm52/mtp`,
and `models/speculative/*`. Proposal sources live in `generation/speculative/sources`;
verification and acceptance belong to `generation/speculative`; batched draft work
belongs to `generation/speculative/bindings`; draft checkpoints belong to `state/speculative`.
Existing sampling, rejection, rollback, and specialized kernel behavior is preserved.

Grouped speculation binds any provider whose operations the target meets: batchable
caches, row layouts for verification and rollback, and a forward that captures the
hidden layers the provider taps. A provider whose rows tap target layers declares
them with `targetTapLayers(target)` on its grouped provider; the binding resolves
the list once for the bound target, rows opened for it must tap exactly that list,
and placement refuses the provider when the target forward cannot capture those
layers. The post-final-norm sentinel (index = layer count) is the forward output.

`state` also exposes the byte-limited `PromptCache`, retention policies, row state,
and checkpoint attachments. The caller owns cache lifetime and reuse namespaces.

## Optional execution and persistence

`execution` exposes `createInferenceEngine`, method adapters, cancellation,
admission, and continuous batching. Supply an execution planner and its graph
bindings; the engine manages in-process session lifetimes and bounded output.
It opens no network listener. `createAutoregressiveMethod`,
`createSpeculativeMethod`, and `createDenoisingMethod` adapt the direct methods
when a consumer needs sessions. `MlxBatchExecutionGroup` owns batched rows;
`ExecutionCoordinator` and `driveExecutionGroup` coordinate its work.

DiffusionGemma requests share that group through `execution/denoising-group`.
This is interleaved execution, not stacked canvases: each row keeps its own
encoder state, canvas, feedback and MLX key sequence, and the group advances one
row by one bounded unit per iteration in round-robin order. The first unit is the
whole prompt prefill and first canvas draw; each later unit is one denoising step.
A row publishes only its finished result, and its decode time ends when that result
is computed. Rows borrow one dequantized embedding table, which the group releases
after the last row's run closes. Each unit runs with only its row's adapters
active. An image request passes its pixels as the row's prefill input: only the
first unit reads them (the vision encoder runs there), and the request owner
releases them after the row settles. Grammar, draft, logprobs, logits processors,
fill, encoded and paged KV requests are refused with typed plan reasons. `DenoisingKeys` reproduces MLX's
global key sequence per request, so denoising never reads or reseeds the process
key. The [denoising tests](tests/generation/denoising-binding.test.ts) take
`MLX_BUN_DIFFUSION_MODEL=/cached/diffusiongemma` for the real-weight check and
optionally `MLX_BUN_DIFFUSION_REFERENCE`, comma-separated trajectories in main's
`goldens/diffusion/gen*.json` or `goldens/diffusion/vision.json` format. An image
reference must have nonempty output and require more than one denoising step, so
its cancellation check interrupts unfinished image work. With the measured main
image reference, the real-weight check passed image cancellation beside a live
text survivor and image/text reuse on the same group, preserving survivor and
recovery tokens and checking state/table disposal calls and caller-owned pixels.
The disposal checks do not establish allocator leak freedom. Separate paired B1
HTTP acceptance against main passed image SSE disconnect after the first decoder
step, server cancellation, prepared-pixel release, drain and same-server image/text
recovery. Both clients received headers and the initial role frame, with no canvas
tokens published before cancellation. Recovery tokens, messages, finish, usage and
prepared inputs matched controls and main. Concurrent HTTP rows, full logits/KV
planes, external-oracle parity and performance remain unqualified.

`execution/fit` estimates whether a model fits a machine at a context length:
resident weights (bytes the caller supplies, such as a registry's), KV bytes from
`state/kv-scheme`, and the prefill transient, against RAM × `WIRED_FRACTION` or an
explicit budget. `fit` also solves the maximum safe context and predicts decode
tokens per second from memory bandwidth; `skuMatrix` repeats it across Apple Silicon
configurations. Estimates are advisory, and the entry imports without MLX. See the
runnable [fit example](examples/fit-model.ts):
`bun packages/inference/examples/fit-model.ts <checkpoint-directory> [context-tokens]`.

`state` exposes `SsdCacheStore`, `TieredPromptCache`, and
`SsdDurabilityCoordinator` for caller-configured persistence. Execution continuation
helpers retain the existing sampler, pending-token, adapter, and cache identities
when saving or restoring a generation. Applications choose their own storage paths,
capacity, scheduler settings, and shutdown lifecycle.

## Scoring

`scoring` exposes `forwardSequence` / `forwardSequenceHidden` for full-sequence
logits and hidden states, including the existing padded-batch masks. The original
`trainForward` names remain aliases for compatibility. `evalPpl` computes
perplexity over caller-provided token rows; `klPerToken` compares supplied logits.
Neither requires an evaluation dataset registry or runner. Tool-call parsing is
available from `input`; template/schema fill compilation lives in `generation/fill`.

Standalone app bundles keep the expert-I/O library and frame extractor beside
the executable. Explicit `MLX_BUN_EXPERT_IO_DYLIB` / `MLX_BUN_FRAME_EXTRACT`
overrides take precedence; ordinary source/package execution resolves the
package's `dist/native` directory. The app bundle verification covers relocation
without loading native numerical code.
