import host.ts.Source
namespace Host.Ts.Sources.Inference.State.SoftcapAttention
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/softcap-attention.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The score-softcapped attention read (mlx-lm gemma2.py's manual attention):
// a graph whose layers softcap their attention scores composes it at
// construction in place of the cache's own read. The fused SDPA kernel cannot
// express the softcap, so this read fetches the window as plain keys and values
// and attends with the manual composition.
//
// It reads every KV storage through its dense fetch (`updateAndFetch`): plain
// and rotating storage and their row layouts hand their keys and values out as
// stored, TurboQuant storage decoded, affine storage dequantized (the delayed
// layouts per row, before and after a row's transition), paged storage
// gathered. Affine storage is dequantized and then read by the same manual
// attention, so a converted layer keeps the graph's own arithmetic over the
// values its storage holds. The read takes the storage's mask for the query
// count before the append, appends through `updateAndFetch`, then attends
// manually under that mask. The fetch and the mask are storage reads internal
// to `state/` (`KvStorage`); the cache contract carries neither.

import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionRead, Cache, Mask } from "../contracts/mlx/cache";
import { createCausalMask } from "../kernels/attention/masks";
import { logitSoftcap } from "../kernels/logits";
import { disposing } from "../layers/helpers";
import { FINFO_MIN } from "../layers/quantized-attention";
import { disposeResources } from "../runtime/resources";
import { kvStorage, type KvStorage } from "./kv-storage";

/** The softcapped reads of one attention layer, each appending `k` and `v`
 * (borrowed; positional encoding applied) to `cache` for the phase it names and
 * returning the read the layer attends once and disposes. `attend(q, scale)`
 * takes queries [B, Hq, L, D] (borrowed) and returns an owned [B, Hq, L, Dv]. */
export interface SoftcapAttentionReads {
  /** One new position per row. */
  appendDecode(cache: Cache, k: MlxArray, v: MlxArray): AttentionRead;
  /** `L` new positions per row, causal within the window. */
  appendWindow(cache: Cache, k: MlxArray, v: MlxArray): AttentionRead;
}

/** The softcapped reads of a layer whose attention scores are capped at
 * `softcap` (`tanh(scores / softcap) * softcap`). `window` is the layer's
 * sliding window (null for a full-attention layer), the window its cache masks
 * with. `arrayMasks` materializes the ordinary causal mask as a boolean array
 * (gemma2's `create_attention_mask(..., return_array=True)`); the manual
 * attention applies only array masks. Decode and window make the same call:
 * the cache's own mask for the query count, which is no mask for one unpadded
 * position. */
export function softcapAttentionReads(softcap: number, window: number | null, arrayMasks: boolean): SoftcapAttentionReads {
  const mask = (cache: KvStorage, L: number): Mask => {
    const own = cache.makeMask(L, window);
    return arrayMasks && own.mode === "causal" ? { mode: "array", arr: createCausalMask(L, cache.offset, window) } : own;
  };
  const read = (row: Cache, k: MlxArray, v: MlxArray): AttentionRead => {
    const cache = kvStorage(row);
    const held = mask(cache, k.shape[2]!);
    let keys: MlxArray, values: MlxArray;
    try { [keys, values] = cache.updateAndFetch(k, v); }
    catch (error) { held.arr?.dispose(); throw error; }
    return {
      attend: (q, scale) => softcapAttention(q, keys, values, held, scale, softcap),
      dispose() { disposeResources(held.arr ? [keys, values, held.arr] : [keys, values]); },
    };
  };
  return Object.freeze({ appendDecode: read, appendWindow: read });
}

/** gemma2.py's manual attention: scale, the GQA 5-d reshape, q·kᵀ, the tanh
 * softcap, a boolean mask through `where(mask, scores, finfo.min)`, the
 * precise softmax, then ·v. `q` [B, Hq, L, D], `keys` [B, Hkv, S, D] and
 * `values` [B, Hkv, S, Dv] are borrowed; only an array mask is applied. Returns
 * an owned [B, Hq, L, Dv]. */
export function softcapAttention(q: MlxArray, keys: MlxArray, values: MlxArray, mask: Mask, scale: number,
  softcap: number): MlxArray {
  const [B, numHeads, L, headDim] = q.shape as [number, number, number, number];
  const numKvHeads = keys.shape[1]!;
  const repeats = Math.floor(numHeads / numKvHeads);
  let queries = ops.mulScalar(q, scale); // queries * self.scale

  let kk = keys;
  let vv = values;
  let kExp: MlxArray | null = null;
  let vExp: MlxArray | null = null;
  if (repeats > 1) {
    queries = disposing(queries, ops.reshape(queries, [B, numKvHeads, repeats, L, headDim]));
    kExp = ops.expandDims(keys, 2);
    vExp = ops.expandDims(values, 2);
    kk = kExp;
    vv = vExp;
  }

  const kT = ops.transposeAxes(kk, repeats > 1 ? [0, 1, 2, 4, 3] : [0, 1, 3, 2]);
  let scores = ops.matmul(queries, kT);
  kT.dispose();
  queries.dispose();

  // tanh(scores / cap) * cap — same composition as logitSoftcap.
  scores = disposing(scores, logitSoftcap(scores, softcap));

  if (mask.mode === "array" && mask.arr) {
    // bool mask: where(mask, scores, finfo(scores.dtype).min)
    const minVal = FINFO_MIN[scores.dtype];
    if (minVal === undefined) throw new Error(`no finfo.min for dtype ${scores.dtypeName}`);
    const minArr = ops.scalarLike(minVal, scores);
    // GQA scores are [B, Hkv, repeats, L, S]. Row masks carry B,
    // unlike the ordinary [L, S] causal mask, so keep that axis aligned.
    using rowMask = repeats > 1 && mask.arr.shape.length === 4
      ? ops.expandDims(mask.arr, 2) : null;
    scores = disposing(scores, ops.where(rowMask ?? mask.arr, scores, minArr));
    minArr.dispose();
  }

  scores = disposing(scores, ops.softmaxAxis(scores, -1, true));
  let out = ops.matmul(scores, vv);
  scores.dispose();
  kExp?.dispose();
  vExp?.dispose();
  if (repeats > 1) out = disposing(out, ops.reshape(out, [B, numHeads, L, values.shape[3]!]));
  return out;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.SoftcapAttention
