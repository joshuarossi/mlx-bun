import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { PrefixLayout } from "../contracts/mlx/trainable";

// Prefix-shared training: while a layout is active, attention ropes the
// concatenated [prompt(P); chosen(Rc); rejected(Rr)] sequence BLOCK-WISE (prompt
// at offset 0, each response reset to offset P) instead of at the uniform cache
// offset, so ONE forward over the concat equals the two separate [prompt;response]
// forwards. The matching block-sparse mask rides in through the training cache.
// Set around a single forward (single-threaded) and cleared after; null means
// the normal uniform-offset rope, so every other forward is untouched.
let active: PrefixLayout | null = null;

/** The layout attention must rope block-wise, or null. */
export function activePrefixLayout(): PrefixLayout | null {
  return active;
}

/** Only a graph's declared training operations set this (they clear it when
 *  their pass ends). */
export function setActivePrefixLayout(layout: PrefixLayout | null): void {
  active = layout;
}

/** Block-wise RoPE for the prefix-shared concat [prompt; chosen; rejected] along
 *  the sequence axis (axis 2 of [B,H,T,D]): prompt rotated at offset 0, each
 *  response at offset P (reset). RoPE is per-token, so roping each contiguous
 *  block at its scalar offset and concatenating == roping with per-token
 *  position-ids [0..P-1, P..P+Rc-1, P..P+Rr-1]. `rope` applies the layer's own
 *  rotation (its base, frequency table and dims) to one block at a scalar
 *  offset. Caller disposes the input. */
export function ropeBlocks(
  x: MlxArray, plan: PrefixLayout, rope: (block: MlxArray, offset: number) => MlxArray,
): MlxArray {
  const { P, Rc, Rr } = plan;
  const [B, H, , D] = x.shape as [number, number, number, number];
  const blocks = [
    { start: 0, len: P, off: 0 },
    { start: P, len: Rc, off: P },
    { start: P + Rc, len: Rr, off: P },
  ].filter((b) => b.len > 0);
  const parts = blocks.map((b) => {
    const sl = x.slice([0, 0, b.start, 0], [B, H, b.start + b.len, D]);
    const r = rope(sl, b.off);
    sl.dispose();
    return r;
  });
  const out = ops.concatAxis(parts, 2);
  for (const p of parts) p.dispose();
  return out;
}
