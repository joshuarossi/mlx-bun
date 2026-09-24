# @mlx-bun/inference

Composable inference components built on [`@mlx-bun/mlx`](../mlx/README.md).
The first migrated component is the existing Trellis vector-expansion kernel.

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

## Source ownership

- `src/kernels/trellis/vector-expand.ts` owns the unchanged inline Metal source,
  launch configuration, and eligibility rules from the existing implementation.
- `src/kernels/trellis/geometry.ts` owns the shared Trellis geometry type.
- `src/kernels/trellis/index.ts` exposes the public Trellis imports.
- `tests/kernels/trellis-vector-expand.test.ts` compares decoded bytes against
  the scalar host codec across codebook states, packing, scales, and strides.

Native libraries belong to `@mlx-bun/mlx`; this package depends on it. Set up
that package's native artifacts, then run `bun run typecheck` and `bun run test`
from the repository root. Model graphs and the remaining inference components
will be migrated incrementally.
