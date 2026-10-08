import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import type { TrellisGeometry } from "./geometry";
import { HEADER, lutFor, decoderVariant } from "./codebook";

import { vectorTrellisExpand, vectorTrellisExpandEligible } from "./vector-expand";

const EXPAND_SOURCE = String.raw`
  const uint c = thread_position_in_grid.x;
  const uint r = thread_position_in_grid.y;
  if (c >= (uint)C || r >= (uint)R) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint blk = c / (uint)BT;
  const uint t = c - blk * (uint)BT;
  const device uint32_t* block = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (ulong)r * 2 * wpb + (blk % 2) * wpb
    : (ulong)r * (C / BT) * wpb + blk * wpb);
  const uint s = trellis_state(block, wpb, t, (uint)BT, (uint)K, (uint)L);
  out[(ulong)r * (uint)C + c] = T(((VARIANT) >= 2 ? lut[s] : (VARIANT) == 1 ? trellis_val_rcp(s) : trellis_val(s)) * float(scales[r]));
`;

let kernel: MetalKernel | undefined;
function expandKernel(): MetalKernel {
  return kernel ??= new MetalKernel({ name: "mlx_bun_trellis_expand",
    inputNames: ["codes", "scales", "lut"], outputNames: ["out"],
    source: EXPAND_SOURCE, header: HEADER, ensureRowContiguous: true });
}

/** Decode the stored matrix ([rows, cols], coded along cols) to `dtype`. */
export function expandTrellis(codes: MlxArray, scales: MlxArray, g: TrellisGeometry, dtype: Dtype, selected: number): MlxArray {
  if (selected === 13 && vectorTrellisExpandEligible(g, dtype)) return vectorTrellisExpand(codes, scales, g);
  const [out] = expandKernel().apply([codes, scales, lutFor(g.L)], {
    outputs: [{ shape: [g.rows, g.cols], dtype }],
    grid: [g.cols, g.rows, 1],
    threadGroup: [Math.min(256, g.cols), 1, 1],
    templateDtypes: { T: dtype },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L,
      VARIANT: decoderVariant(selected), INTERLEAVE: g.blockInterleave ?? 0 },
  });
  return out!;
}
