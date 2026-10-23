// MOSS-Image's rotary embedding (`_RoPE` and `_rotate`): rotate-half RoPE whose
// head is split over four coordinate axes (reserved, text index, row, column).
// Image positions come first in raster order, `(0, textLength, row - (h-1)/2,
// col - (w-1)/2)`; text positions follow, `(0, i, 0, 0)`. Pair `a * K + k`
// rotates by `coordinate[a] * bands[k]` with `bands[k] = 1 / base ** (k / K)`.
// Tables are computed on the host at the reference's float32 rounding points and
// cast once to bf16, the activation dtype the reference casts them to.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

const f32 = Math.fround;
const AXES = 4;

/** cos/sin `[1, N, 1, headDim]` (bf16), broadcast over heads. Owned. */
export interface MossRopeTables extends Disposable {
  readonly cos: MlxArray;
  readonly sin: MlxArray;
}

function owned(cos: MlxArray, sin: MlxArray): MossRopeTables {
  return { cos, sin, [Symbol.dispose]() { cos.dispose(); sin.dispose(); } };
}

/** Per-axis frequencies as the reference builds them on the CPU in float32
 * (equal, bit for bit, to the checkpoint's `rope.bands`). */
export function mossRopeBands(headDim: number, base: number): Float32Array {
  const bands = headDim / (2 * AXES);
  return Float32Array.from({ length: bands }, (_, k) => f32(1 / f32(Math.pow(base, f32(k / bands)))));
}

/** The four coordinates of every position: image tokens, then text tokens. */
export function mossRopeCoordinates(height: number, width: number, textLength: number): Float32Array {
  const out = new Float32Array((height * width + textLength) * AXES);
  const rowCenter = (height - 1) / 2, colCenter = (width - 1) / 2;
  let at = 0;
  for (let row = 0; row < height; row++)
    for (let col = 0; col < width; col++) {
      out[at + 1] = textLength; out[at + 2] = row - rowCenter; out[at + 3] = col - colCenter;
      at += AXES;
    }
  for (let i = 0; i < textLength; i++) { out[at + 1] = i; at += AXES; }
  return out;
}

/** The rotation for one position layout: the whole joint sequence and its text rows. */
export interface MossRopeLayout {
  readonly joint: MossRopeTables;
  readonly text: MossRopeTables;
}

/** Builds and applies the rotation. Tables are kept per (height, width, text
 * length) for the life of the layer: the positive and negative prompts of a
 * request reuse theirs at every step. */
export class MossRope {
  readonly #bands: Float32Array;
  readonly #layouts = new Map<string, MossRopeLayout>();

  constructor(readonly headDim: number, base: number) {
    this.#bands = mossRopeBands(headDim, base);
  }

  layout(height: number, width: number, textLength: number): MossRopeLayout {
    const key = `${height}x${width}+${textLength}`;
    const cached = this.#layouts.get(key);
    if (cached) return cached;
    const coordinates = mossRopeCoordinates(height, width, textLength), bands = this.#bands;
    const positions = coordinates.length / AXES, half = AXES * bands.length, head = 2 * half;
    const cos = new Float32Array(positions * head), sin = new Float32Array(positions * head);
    for (let n = 0; n < positions; n++)
      for (let a = 0; a < AXES; a++)
        for (let k = 0; k < bands.length; k++) {
          const phase = f32(coordinates[n * AXES + a]! * bands[k]!);
          const at = n * head + a * bands.length + k, c = Math.cos(phase), s = Math.sin(phase);
          cos[at] = c; cos[at + half] = c;
          sin[at] = s; sin[at + half] = s;
        }
    const table = (values: Float32Array) => { using wide = MlxArray.fromFloat32(values, [1, positions, 1, head]); return wide.astype(Dtype.bfloat16); };
    const joint = owned(table(cos), table(sin));
    const tokens = height * width;
    const text = owned(joint.cos.slice([0, tokens, 0, 0], [1, positions, 1, head]), joint.sin.slice([0, tokens, 0, 0], [1, positions, 1, head]));
    const layout = { joint, text };
    this.#layouts.set(key, layout);
    return layout;
  }

  /** `x * cos + rotate_half(x) * sin` for `x` `[1, N, H, D]` (borrowed) with
   * `rotate_half(x) = [-x2, x1]`. Returns an owned result. */
  apply(x: MlxArray, tables: MossRopeTables): MlxArray {
    const [b, n, h, d] = x.shape as [number, number, number, number], half = d / 2;
    using first = x.slice([0, 0, 0, 0], [b, n, h, half]);
    using second = x.slice([0, 0, 0, half], [b, n, h, d]);
    using negated = ops.neg(second);
    using rotated = ops.concatAxis([negated, first], -1);
    using direct = ops.mul(x, tables.cos);
    using turned = ops.mul(rotated, tables.sin);
    return ops.add(direct, turned);
  }

  dispose(): void {
    for (const { joint, text } of this.#layouts.values()) { text[Symbol.dispose](); joint[Symbol.dispose](); }
    this.#layouts.clear();
  }
}
