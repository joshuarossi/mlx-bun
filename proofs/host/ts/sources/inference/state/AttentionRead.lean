import host.ts.Source
namespace Host.Ts.Sources.Inference.State.AttentionRead
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/attention-read.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Mask } from "../contracts/mlx/cache";
import { bidirMask } from "../kernels/attention/masks";
import { foldedSdpa, foldedSdpaEligible } from "../layers/folded-attention";
import { disposeResources } from "../runtime/resources";

/** A mask held by one attention read until that read is disposed. */
export interface MaskLease {
  readonly mask: Mask;
  /** Drops this read's hold on the mask. Call exactly once. */
  release(): void;
}

/** No mask: one query over every stored position. Nothing to release. */
export const unmaskedLease: MaskLease = { mask: { mode: "", arr: null }, release() {} };
/** The fused kernel's bottom-right-aligned causal mask. Nothing to release. */
export const causalLease: MaskLease = { mask: { mode: "causal", arr: null }, release() {} };

interface MaskSlot {
  readonly key: string;
  readonly source: object | null;
  readonly mask: Mask;
  /** This memo's hold plus one per unreleased lease. */
  holders: number;
}

/**
 * The attention masks of one forward, built once and shared by every layer
 * cache composed with this instance.
 *
 * A cache leases its mask here inside each named read, under a family and a
 * key. The family names how the mask is built and is fixed when the cache is
 * constructed: the cache's mask builder and its sliding window. The key holds
 * every input that builder reads from the cache before the append: the query
 * count and the row offsets, padding and ring position, plus `source`, compared
 * by identity, for a mask built from a caller's tensor. The first lease of a key
 * builds the mask. The other layers of the same forward stand at the same
 * positions, so they lease the same mask. The next forward's appends have moved
 * the offsets, so its first lease builds a new mask and drops this memo's hold
 * on the old one. Each family keeps one mask, so a model's sliding and full
 * layers do not evict each other. Equal keys always mean equal masks, so sharing
 * an instance can only save builds, never change a result; caches at different
 * positions that share one and alternate within a forward rebuild on each turn.
 *
 * A lease keeps its mask alive until the read holding it is disposed, so a read
 * stays valid after a later forward replaces the mask. `clear()` drops only this
 * memo's holds; a cache calls it from `dispose()`.
 *
 * Neither the graph nor the scheduler sees this. A model composes one instance
 * into the caches its `makeCache()` makes (each cache constructor takes it; a
 * cache built without one keeps its own); empty batches and the row layouts
 * made from a cache (`state/layout`) take their source's instance. Not a module
 * singleton: caches share masks only through an instance they were given.
 */
export class AttentionMasks {
  readonly #slots = new Map<string, MaskSlot>();
  #builds = 0;

  /** Masks built so far (diagnostic; tests count it). */
  get builds(): number { return this.#builds; }

  /** The mask `build` makes for `family` at `key` (and `source`), built on the
   * first lease of that key. The caller owns the lease, not the mask: release
   * the lease, never dispose `lease.mask.arr`. */
  lease(family: string, key: string, build: () => Mask, source: object | null = null): MaskLease {
    let slot = this.#slots.get(family);
    if (!slot || slot.key !== key || slot.source !== source) {
      const mask = build();
      this.#builds++;
      if (slot) drop(slot);
      slot = { key, source, mask, holders: 1 };
      this.#slots.set(family, slot);
    }
    const held = slot;
    held.holders++;
    return { mask: held.mask, release: () => drop(held) };
  }

  /** Drop this memo's holds. Leased masks stay valid until released. */
  clear(): void {
    for (const slot of this.#slots.values()) drop(slot);
    this.#slots.clear();
  }
}

function drop(slot: MaskSlot): void {
  if (--slot.holders === 0) slot.mask.arr?.dispose();
}

/** The encoder window's mask over an `L`-position first window
 * (`EncoderAttentionCache.appendEncoderWindow`): causal, OR'd with the overlay
 * of positions both flagged in `bidirectional`, with no sliding window, as one
 * [1, 1, L, L] bool array (the shape the DiffusionGemma encoder built on the
 * host). No cache's window enters it, so every cache of a model leases it
 * under one family and a forward builds it once. */
export function encoderWindowMask(masks: AttentionMasks, L: number, bidirectional: MlxArray): MaskLease {
  return masks.lease("encoder-window", `${L}`, () => {
    const { arr } = bidirMask(L, null, bidirectional);
    try { return { mode: "array", arr: ops.reshape(arr!, [1, 1, L, L]) }; }
    finally { arr!.dispose(); }
  }, bidirectional);
}

/** DiffusionGemma's sliding-layer decoder mask (its `#makeDecoderMasks`) for a
 * block read over a ring of `maxSize` holding `offset` positions:
 * `storedLength` stored positions in temporal order, of which the newest
 * `maxSize - 1` that hold a valid position are visible, then all `N` block
 * positions, as one bool [1, 1, 1, storedLength + N] row every query shares.
 * The rings of a model lease it under one family per window. */
export function rotatingBlockMask(masks: AttentionMasks, maxSize: number, offset: number, N: number,
  storedLength: number): MaskLease {
  const valid = Math.min(offset, storedLength);
  return masks.lease(`rotating-block:${maxSize}`, `${N}:${storedLength}:${valid}`, () => {
    const start = Math.max(0, valid - Math.max(maxSize - 1, 0));
    const positions = ops.arange(0, storedLength, 1, Dtype.int32);
    const startArr = ops.scalarLike(start, positions);
    const validArr = ops.scalarLike(valid, positions);
    const geStart = ops.greaterEqual(positions, startArr);
    const ltValid = ops.less(positions, validArr);
    const stored = ops.logicalAnd(geStart, ltValid);
    positions.dispose();
    startArr.dispose();
    validArr.dispose();
    geStart.dispose();
    ltValid.dispose();
    using ones = ops.fromInt32(new Array(N).fill(1), [N]);
    const block = ones.astype(stored.dtype);
    const row = ops.concatAxis([stored, block], 0);
    stored.dispose();
    block.dispose();
    const reshaped = ops.reshape(row, [1, 1, 1, storedLength + N]);
    row.dispose();
    return { mode: "array", arr: reshaped };
  });
}

/** A read over dense stored keys and values under a leased mask; it takes
 * ownership of `keys`, `values` and `mask`. A bf16 storage reads its windows
 * with the one its composition names (`KVCache.windowRead`). */
export type DenseRead = (keys: MlxArray, values: MlxArray, mask: MaskLease) => AttentionRead;

/** The read over dense stored keys and values: the stock fused SDPA kernel
 * (`ops.sdpa`) under the leased mask. Takes ownership of `keys`, `values` and
 * `mask`. */
export function sdpaRead(keys: MlxArray, values: MlxArray, mask: MaskLease): AttentionRead {
  return {
    attend: (q, scale) => ops.sdpa(q, keys, values, scale, mask.mask.mode, mask.mask.arr),
    dispose() { keys.dispose(); values.dispose(); mask.release(); },
  };
}

/** `sdpaRead`, reading each KV head's keys and values once for a causal window
 * MLX's fused SDPA hands to its unfused fallback (up to 8 queries per row, more
 * than 32 per KV head: `foldedSdpaEligible`), where that fallback reads them
 * once per query head: such a window folds GQA into rows (`foldedSdpa`: the
 * fallback's bits on `applegpu_g13s`, where it was measured, bf16 precision
 * elsewhere); every other read is the stock fused SDPA. Takes ownership of
 * `keys`, `values` and `mask`. */
export function foldedWindowRead(keys: MlxArray, values: MlxArray, mask: MaskLease): AttentionRead {
  return {
    attend: (q, scale) => mask.mask.mode === "causal" && foldedSdpaEligible(q, keys)
      ? foldedSdpa(q, keys, values, scale) : ops.sdpa(q, keys, values, scale, mask.mask.mode, mask.mask.arr),
    dispose() { keys.dispose(); values.dispose(); mask.release(); },
  };
}

/** A committed span (`CommittedAttentionCache.appendCommitted`) read one
 * position at a time: each of the span's `L` positions appends through
 * `cache.appendDecode` and keeps that one-position read, so query `i` attends
 * its own causal prefix with the decode arithmetic and the storage holds what
 * `L` decodes leave. The committed read of ring storage, whose window read is
 * not the one-position arithmetic (a ring writes a window by concatenation and,
 * once it wraps, reorders its keys). `k` and `v` are borrowed, as for every
 * append. */
export function decodeByPosition(cache: AttentionCache, k: MlxArray, v: MlxArray): AttentionRead {
  const L = k.shape[2]!;
  const at = (a: MlxArray, i: number) => a.slice([0, 0, i, 0], [a.shape[0]!, a.shape[1]!, i + 1, a.shape[3]!]);
  const reads: AttentionRead[] = [];
  try {
    for (let i = 0; i < L; i++) {
      using key = at(k, i), value = at(v, i);
      reads.push(cache.appendDecode(key, value));
    }
  } catch (error) { disposeResources(reads); throw error; }
  return {
    attend(q, scale) {
      const outputs: MlxArray[] = [];
      try {
        for (const [i, read] of reads.entries()) {
          using query = at(q, i);
          outputs.push(read.attend(query, scale));
        }
        return outputs.length === 1 ? ops.contiguous(outputs[0]!) : ops.concatAxis(outputs, 2);
      } finally { disposeResources(outputs); }
    },
    dispose() { disposeResources(reads); },
  };
}

/** Run a read's storage step under a mask leased before it, releasing the
 * lease if the step throws. */
export function withLease(mask: MaskLease, read: (mask: MaskLease) => AttentionRead): AttentionRead {
  try { return read(mask); }
  catch (error) { mask.release(); throw error; }
}

/** Retain an independent array handle for positions used across cache writes.
 * The contiguous view preserves the integer values and shares their storage;
 * callers release it with the fetched attention state. */
export function captureRopeOffsets(cache: { readonly ropeOffsetArr?: MlxArray }): MlxArray | undefined {
  const offsets = cache.ropeOffsetArr;
  return offsets ? ops.contiguous(offsets) : undefined;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.AttentionRead
