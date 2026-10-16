import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Dtype } from "@mlx-bun/mlx/ffi";
/** Each request owns its recurrence. State arrays never alias another request. */
export interface TdtState {
  h: MlxArray[];
  c: MlxArray[];
}
export interface TdtDecodeState extends TdtState {
  /** int32 [time, last emitted token, symbols at current frame, next gather index]. */
  control: MlxArray;
}
/** Speech graph consumed by token-duration decoding. Inputs are borrowed;
 * encode, initialState and advance transfer returned arrays to the caller. */
export interface TdtGraph {
  readonly vocabulary: readonly string[];
  readonly blank: number;
  readonly frameSeconds: number;
  readonly dtype: Dtype;
  readonly weightsBytes: number;
  initialState(): TdtDecodeState;
  /** [1,T,128] normalized mel -> [1,ceil(T/8),640] projected encoder. */
  encode(mel: MlxArray): MlxArray;
  /** Greedy step entirely on device. record is int32 [token or -1, time, duration]. */
  advance(
    encoded: MlxArray,
    state: TdtDecodeState,
    maxLength: MlxArray,
  ): {
    record: MlxArray;
    state: TdtDecodeState;
  };
  dispose(): void;
}
