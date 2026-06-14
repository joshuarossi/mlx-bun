// Training forward pass: full-sequence logits with no KV reuse.
//
// B=1 (no padding): trainForward runs the model's stock forwardHidden over a
// fresh cache exactly as before — bit-identical to the single-example trainer.
//
// B>1 (padded batch): every row in the batch is padded to a common length L,
// but the rows have different *true* lengths. A plain causal mask would let a
// real query attend to padded keys (and let padded queries pollute the cache
// view), so for batched forwards we build an explicit [B, 1, L, L] boolean
// mask that is the causal mask AND-ed with a per-row "key is within this row's
// valid length" mask, and route it through the model's attention via a cache
// wrapper whose makeMask returns it. The wrapper delegates every KV operation
// to a real cache (KVCache/RotatingKVCache are already shape-generic over B),
// so only the mask differs from the stock path. Window/offset handling is
// preserved: training always runs offset-0 full-sequence forwards, so the
// causal-with-window mask is built at offset 0, exactly matching what the
// underlying cache's makeMask would have produced for the unpadded case.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { createCausalMask, type Cache, type Mask } from "../model/gemma4-base";
import type { RuntimeModel } from "../model/factory";

/** Run a full-sequence forward for training.
 *  @param ids int32 array [B, L].
 *  @returns logits [B, L, V] (caller owns; dispose when done).
 *
 *  When `validLengths` is omitted (or every row is full-length L) the batch
 *  has no padding and the model's stock mask path is used unchanged — the
 *  B=1 result is bit-identical to the original trainer. When some row is
 *  shorter than L, a padding-aware batched mask is injected. */
export function trainForward(
  model: RuntimeModel,
  ids: MlxArray,
  validLengths?: number[],
): MlxArray {
  const [B, L] = ids.shape as [number, number];
  const needsPadMask =
    validLengths !== undefined && validLengths.some((v) => v < L);

  const realCache = model.makeCache();
  const cache: Cache[] = needsPadMask
    ? wrapWithBatchedMask(realCache, B, L, validLengths!)
    : realCache;
  try {
    const h = model.forwardHidden(ids, cache);
    const logits = model.logitsFromHidden(h);
    h.dispose();
    return logits;
  } finally {
    for (const c of realCache) c.dispose();
    if (cache !== realCache) for (const c of cache) (c as BatchedMaskCache).disposeOwnMask();
  }
}

/** Build the padding-aware additive-style boolean mask for one window type.
 *  Shape `[B, 1, L, L]`, true where query i may attend to key j:
 *    allow[b,0,i,j] = (j <= i)               (causal, offset 0)
 *                     AND (j < validLen[b])   (key within row b's true length)
 *                     [AND (i < j + window)   if a sliding window applies]
 *  Built from createCausalMask(L, 0, window) (the model's own [L, L] bool
 *  matrix) broadcast over B, masked by a per-row [B,1,1,L] key-validity mask.
 *  Caller owns the returned array. */
export function buildBatchedPadMask(
  B: number,
  L: number,
  validLengths: number[],
  windowSize: number | null,
): MlxArray {
  // [L, L] bool causal (+window) matrix at offset 0 — exactly the model's.
  const causal2d = createCausalMask(L, 0, windowSize); // [L, L] bool
  const causal4d = ops.reshape(causal2d, [1, 1, L, L]);
  causal2d.dispose();

  // Per-row key validity: keyValid[b, 0, 0, j] = j < validLengths[b].
  // Build as int32 {0,1} then compare to get bool, broadcasting over q (i).
  const keyValidData = new Int32Array(B * L);
  for (let b = 0; b < B; b++) {
    const vlen = validLengths[b]!;
    for (let j = 0; j < L; j++) keyValidData[b * L + j] = j < vlen ? 1 : 0;
  }
  const keyValidI = MlxArray.fromInt32(keyValidData, [B, 1, 1, L]);
  const zero = MlxArray.fromInt32(new Int32Array([0]), []);
  const keyValid = ops.less(zero, keyValidI); // 0 < x  → bool true where x==1
  zero.dispose();
  keyValidI.dispose();

  const allow = ops.logicalAnd(causal4d, keyValid); // broadcasts [1,1,L,L] & [B,1,1,L]
  causal4d.dispose();
  keyValid.dispose();
  return allow; // [B, 1, L, L] bool
}

/** Cache wrapper that forwards every KV op to a real cache but overrides
 *  makeMask to return a precomputed padding-aware batched mask. One mask is
 *  built per distinct window size (null = full attention, else the sliding
 *  window) and shared across all caches of that type; ownership of the mask
 *  arrays stays with the wrapper (disposeOwnMask), NOT the model — the model's
 *  forwardLayers only disposes the mask it pulled from makeMask, so makeMask
 *  hands back a fresh view each call and keeps the canonical copy itself. */
class BatchedMaskCache implements Cache {
  constructor(
    private readonly inner: Cache,
    private readonly window: number | null,
    private readonly maskStore: Map<number | null, MlxArray>,
  ) {}

  get offset(): number {
    return this.inner.offset;
  }

  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] {
    return this.inner.updateAndFetch(k, v);
  }

  makeMask(N: number, _windowSize: number | null): Mask {
    const canonical = this.maskStore.get(this.window)!;
    // Hand back a fresh full-range view so the model can dispose it without
    // touching our canonical copy. slice over all 4 axes = cheap view node.
    const [B, , L] = canonical.shape as [number, number, number, number];
    const view = canonical.slice([0, 0, 0, 0], [B, 1, L, L]);
    return { mode: "array", arr: view };
  }

  state(): MlxArray[] {
    return this.inner.state();
  }
  isTrimmable(): boolean {
    return this.inner.isTrimmable();
  }
  trim(n: number): void {
    this.inner.trim(n);
  }
  dispose(): void {
    this.inner.dispose();
  }
  /** Dispose the canonical mask copies (shared store; idempotent via clear). */
  disposeOwnMask(): void {
    for (const m of this.maskStore.values()) m.dispose();
    this.maskStore.clear();
  }
}

/** Wrap each real cache in a BatchedMaskCache, precomputing one padding-aware
 *  mask per distinct window. Caches without a sliding window get the
 *  full-attention (null) mask. */
function wrapWithBatchedMask(
  realCache: Cache[],
  B: number,
  L: number,
  validLengths: number[],
): Cache[] {
  const windows = realCache.map((c) => cacheWindow(c));
  const distinct = new Set(windows);
  const store = new Map<number | null, MlxArray>();
  for (const w of distinct) store.set(w, buildBatchedPadMask(B, L, validLengths, w));
  return realCache.map((c, i) => new BatchedMaskCache(c, windows[i]!, store));
}

/** The sliding-window size a cache enforces, or null for full attention.
 *  RotatingKVCache stores its window as `maxSize`; KVCache has none. Mirrors
 *  gemma4 forwardLayers, where sliding layers use windowSize == the rotating
 *  cache's maxSize. (Quantized KV caches are not used on the training path.) */
function cacheWindow(c: Cache): number | null {
  const maxSize = (c as { maxSize?: number }).maxSize;
  return typeof maxSize === "number" ? maxSize : null;
}
