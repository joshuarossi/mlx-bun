import type { PrefillPadding } from "./gemma4-base";
import type { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";

/** ArraysCache's remaining lengths and padding from mlx-lm (MIT).
 * Recurrent state has no token axis to roll: masked tokens must not update it. */
export class SsmPrefillPadding {
  #left: number[];
  #lengths: number[];
  constructor(padding: PrefillPadding) {
    this.#left = padding.leftPadding ? [...padding.leftPadding] : padding.lengths.map(() => 0);
    this.#lengths = [...padding.lengths];
  }
  convolutionLengths(tokens: number): number[] {
    return this.#lengths.map(length => Math.max(0, Math.min(tokens, length)));
  }
  makeMask(tokens: number): MlxArray {
    const B = this.#lengths.length;
    using arange = ops.arange(0, tokens, 1, Dtype.int32);
    using positions = ops.reshape(arange, [1, tokens]);
    using left = ops.fromInt32(this.#left, [B, 1]);
    using ends = ops.fromInt32(this.#lengths, [B, 1]);
    using after = ops.greaterEqual(positions, left);
    using before = ops.less(positions, ends);
    return ops.logicalAnd(after, before);
  }
  advance(tokens: number): number[] {
    const counts = this.#lengths.map((length, row) => Math.max(0,
      Math.min(tokens, length) - Math.max(0, Math.min(tokens, this.#left[row]!))));
    this.#lengths = this.#lengths.map(length => length - tokens);
    this.#left = this.#left.map(left => left - tokens);
    return counts;
  }
  filter(keep: readonly number[]): void {
    this.#left = keep.map(row => this.#left[row]!);
    this.#lengths = keep.map(row => this.#lengths[row]!);
  }
}
