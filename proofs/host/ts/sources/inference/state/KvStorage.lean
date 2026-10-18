import host.ts.Source
namespace Host.Ts.Sources.Inference.State.KvStorage
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/kv-storage.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// The storage-level reads and conversions state's own caches use on one
// another: a row layout fetching its serial rows' keys and values, a delayed
// lego converting the storage it holds, a donor capture reading packed or
// rotated storage. They are internal to `state/`. Graphs, layers and every
// other caller read a cache through the cache contract (`AttentionCache` and
// its named reads, `GatedDeltaCache`), which carries none of these.

import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
import type * as ops from "@mlx-bun/mlx/ops";
import type { Cache, KvAttentionView, Mask } from "../contracts/mlx/cache";

/** Affine-quantized storage: appends and hands back its packed keys and values. */
export interface QuantizedAttentionState {
  readonly groupSize: number;
  readonly bits: number;
  updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor];
}

/** TurboQuant storage whose values stay in the codec's rotated domain until
 * after attention. */
export interface RotatedValueAttentionState {
  /** Capture a fetched value domain independently of later row changes. */
  captureValueTransform?(): (output: MlxArray) => MlxArray;
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
}

/** Storage that appends once and hands every attention consumer the same view. */
export interface KvAttentionState {
  appendAndFetch(k: MlxArray, v: MlxArray): KvAttentionView;
}

/** A cache as `state/` sees its storage. */
export interface KvStorage extends Cache {
  /** Appends `k` and `v` and returns the stored keys and values (owned views). */
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  /** The mask an `N`-position append would read under, from this storage's state. */
  makeMask(N: number, windowSize: number | null): Mask;
  /** Affine conversion of this storage. Logical position can differ from the
   * physical write head in a padded rotating layout. `kernels` builds the
   * kernel set the converted storage attends with (`AffineKernelSet`) for its
   * bits, group size and activation dtype. */
  readonly affineConversion?: { readonly offset: number;
    toQuantized(groupSize: number, bits: number, kernels: (bits: number, groupSize: number, dtype: Dtype) => unknown): Cache };
  /** TurboQuant conversion of this storage. */
  readonly turboConversion?: { readonly offset: number; toTurboQuantized(kBits: number, vBits: number): Cache };
  readonly attentionState?: KvAttentionState;
  readonly rotatedValueAttention?: RotatedValueAttentionState;
  readonly quantizedAttention?: QuantizedAttentionState;
}

/** `cache` as storage, for a caller inside `state/` holding a KV storage
 * (every key/value storage here implements these reads; the contract does not
 * promise them, so nothing outside `state/` may call them). */
export function kvStorage(cache: Cache): KvStorage {
  return cache as KvStorage;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.KvStorage
