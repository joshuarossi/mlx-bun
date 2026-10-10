import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionRead, Mask } from "../contracts/mlx/cache";

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

/** The read over dense stored keys and values: the stock fused SDPA kernel
 * (`ops.sdpa`) under the leased mask. Takes ownership of `keys`, `values` and
 * `mask`. */
export function sdpaRead(keys: MlxArray, values: MlxArray, mask: MaskLease): AttentionRead {
  return {
    attend: (q, scale) => ops.sdpa(q, keys, values, scale, mask.mask.mode, mask.mask.arr),
    dispose() { keys.dispose(); values.dispose(); mask.release(); },
  };
}

/** Run a read's storage step under a mask leased before it, releasing the
 * lease if the step throws. */
export function withLease(mask: MaskLease, read: (mask: MaskLease) => AttentionRead): AttentionRead {
  try { return read(mask); }
  catch (error) { mask.release(); throw error; }
}
