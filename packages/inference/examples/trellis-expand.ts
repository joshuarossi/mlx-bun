import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { vectorTrellisExpand, vectorTrellisExpandEligible,
  type TrellisGeometry } from "@mlx-bun/inference/kernels/trellis";

/** Borrow packed weights; return an owned lazy array for the caller's graph. */
export function expandWeights(codes: MlxArray, scales: MlxArray, geometry: TrellisGeometry) {
  if (!vectorTrellisExpandEligible(geometry, Dtype.bfloat16))
    throw new Error("This geometry is not supported by the vector expansion kernel");
  return vectorTrellisExpand(codes, scales, geometry);
}

if (import.meta.main) {
  // Small generated inputs demonstrate the layout; no checkpoint is needed.
  const geometry: TrellisGeometry = {
    k: 3, L: 12, T: 256, axis: 1,
    rows: 64, cols: 512, inFeatures: 512, outFeatures: 64,
  };
  using codes = ops.zeros([geometry.rows, geometry.cols * geometry.k / 32], Dtype.uint32);
  using scales = MlxArray.fromFloat32(new Float32Array(geometry.rows).fill(1), [geometry.rows]);
  using weights = expandWeights(codes, scales, geometry);
  weights.eval();
  console.log(weights.shape);
}
