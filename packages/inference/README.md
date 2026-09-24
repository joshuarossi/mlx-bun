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
from the repository root. Model graphs and the remaining inference components
will be migrated incrementally.
