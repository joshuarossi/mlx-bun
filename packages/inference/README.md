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
The external Bun harness used public root, model, and scoring imports, forwarding
the prompt once and each selected token thereafter with the same live cache.
This result covers that path only, not other models, batching, quantized KV,
snapshot restore, long contexts, or speed. Raw outputs and the comparison
harness remain external; Python is not a project dependency.

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
  tokenizer, and audio samples.
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
