# @mlx-bun/inference

Composable inference components built on [`@mlx-bun/mlx`](../mlx/README.md).
The migrated components are the existing Trellis expansion, matvec, fused gate/up,
and prefill kernels. Their Metal source stays inline in the owning TypeScript file.

## Trellis weight expansion

```ts
import { Dtype } from "@mlx-bun/mlx";
import {
  vectorTrellisExpand,
  vectorTrellisExpandEligible,
  type TrellisGeometry,
} from "@mlx-bun/inference/kernels/trellis";

// codes and scales are caller-owned MlxArrays containing packed model weights.
// This example describes 64 rows of 512 weights, packed at 3 bits per weight.
const geometry: TrellisGeometry = {
  k: 3, L: 12, T: 256, axis: 1,
  rows: 64, cols: 512, inFeatures: 512, outFeatures: 64,
};

if (vectorTrellisExpandEligible(geometry, Dtype.bfloat16)) {
  using weights = vectorTrellisExpand(codes, scales, geometry);
  // Compose weights with other MLX operations here.
}
```

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
- `@mlx-bun/inference/adapters/state`: inference-time LoRA state and weights.
- `@mlx-bun/inference/execution/config`: immutable execution settings and scoped
  overrides. The existing `MLX_BUN_*` defaults are preserved during migration.

These modules do not download models or start services. Tensor handles returned
by `Weights.tensor()` are borrowed from the weights owner; release them through
`Weights.release()`, `releaseShard()`, or `dispose()`. Layer outputs are owned
by the caller.

## Concrete graphs

Import a graph directly, provide its weights and configuration, and own its state:

```ts
import { loadModelConfig, Weights } from "@mlx-bun/inference/artifacts";
import { Qwen3Model } from "@mlx-bun/inference/models/qwen3";

const config = await loadModelConfig(modelDirectory);
const weights = await Weights.open(modelDirectory);
try {
  const graph = new Qwen3Model(weights, config);
  const tokens = graph.generate(promptTokenIds, 32, config.eosTokenIds);
} finally {
  weights.dispose();
}
```

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

`execution/experts` owns native I/O bindings, residency, and usage accounting;
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

Native libraries belong to `@mlx-bun/mlx`; this package depends on it. Set up
that package's native artifacts, then run `bun run typecheck` and `bun run test`
from the repository root. Generation methods and the remaining higher-level APIs are being migrated
incrementally.

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

```ts
import { generate } from "@mlx-bun/inference/generation";

const generation = generate(graph, promptTokenIds, {
  maxTokens: 128,
  temperature: 0,
});
for await (const { token } of generation) {
  // Feed the token to your own decoder or application.
}
console.log(generation.stats);
```

`generate` uses the graph supplied by the caller. `generateAutoregressive` accepts
an explicit `MlxAutoregressiveBinding` from `execution/autoregressive`, including
caller-defined graph operations, state construction, and optional compiled decode.
`generateDenoising` accepts a denoising binding; `generation/diffusion` also exposes
`denoiseSync` and `denoiseAsync` directly. No service or model selection is involved.

`generation/autoregressive.ts` owns prefill and token iteration;
`generation/diffusion.ts` owns canvas denoising; `generation/result.ts` owns the
async iterator and final stats. `execution/generation-scopes.ts` owns adapter,
wired-memory, and expert-usage lifetimes. Existing cancellation and early-return
cleanup behavior is preserved. `generation/fill` exposes the existing optional
fill session and proposal interfaces.
