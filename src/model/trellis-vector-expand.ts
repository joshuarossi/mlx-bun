// Four adjacent weights share one circular packed-word window. Keep the
// precise expansion values and MLX's matmul/evaluation boundary unchanged.
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import type { TrellisGeometry } from "./trellis-linear";

const kernel = new MetalKernel({
  name: "mlx_bun_trellis_vector_expand",
  inputNames: ["codes", "scales"], outputNames: ["out"],
  source: String.raw`
    uint c = thread_position_in_grid.x * 4;
    uint r = thread_position_in_grid.y;
    if constexpr (ROW_TILE > 0) {
      constexpr uint groups = C / (BT * 2);
      const uint tg = threadgroup_position_in_grid.x;
      const uint tile = tg / (groups * ROW_TILE), within = tg % (groups * ROW_TILE);
      r = tile * ROW_TILE + within % ROW_TILE;
      c = (within / ROW_TILE) * BT * 2 + thread_position_in_threadgroup.x * 4;
    }
    if (c >= C || r >= R) return;
    constexpr uint wpb = BT * BITS / 32;
    const uint block = c / BT, t = c % BT;
    const device uint* bw = codes + (INTERLEAVE
      ? (ulong)(block / 2) * R * 2 * wpb + (ulong)r * 2 * wpb + (block % 2) * wpb
      : (ulong)r * (C / BT) * wpb + block * wpb);
    const float scale = float(scales[r]);
    // The last of four weights starts the window. Earlier weights occupy
    // its higher bits; a second word also handles the circular block edge.
    const uint pos = (BT - 1 - (t + 3)) * BITS, wi = pos >> 5, off = pos & 31u;
    const ulong window = (ulong(bw[wi]) | (ulong(bw[wi + 1 == wpb ? 0 : wi + 1]) << 32)) >> off;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 4; i++) {
      const uint s = uint(window >> ((3 - i) * BITS)) & ((1u << L) - 1);
      const uint z = s * 34038481u + 76625530u;
      const uint p = (z & 0x00FF00FFu) + ((z >> 8) & 0x00FF00FFu);
      const float y = float(int((p & 0xFFFFu) + (p >> 16)) - 510);
      // Residual refinement reproduces the host f32 LUT before scaling.
      const float reciprocal = 1.0f / 147.800537109375f;
      const float q = y * reciprocal;
      const float value = metal::fma(metal::fma(-q, 147.800537109375f, y), reciprocal, q);
      out[(ulong)r * C + c + i] = T(value * scale);
    }
  `,
});

export function vectorTrellisExpandEligible(g: TrellisGeometry, dtype: Dtype): boolean {
  return dtype === Dtype.bfloat16 && g.L === 12 && g.T === 256 &&
    (g.k === 2 || g.k === 3 || g.k === 4) && g.rows > 0 && g.cols > 0 && g.cols % 256 === 0;
}

/** Decode the stored matrix; the caller owns the projection's evaluation boundary. */
export function vectorTrellisExpand(codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  const rowTile = g.blockInterleave && g.rows % 128 === 0 ? 128 : 0;
  return kernel.apply([codes, scales], {
    outputs: [{ shape: [g.rows, g.cols], dtype: Dtype.bfloat16 }],
    grid: rowTile ? [g.cols / 4 * g.rows, 1, 1] : [g.cols / 4, g.rows, 1], threadGroup: [128, 1, 1],
    templateDtypes: { T: Dtype.bfloat16 },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, BITS: g.k, L: g.L,
      INTERLEAVE: g.blockInterleave ?? 0, ROW_TILE: rowTile },
  })[0]!;
}
