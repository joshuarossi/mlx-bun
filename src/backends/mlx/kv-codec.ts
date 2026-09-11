import type { MlxArray } from "../../mlx/array";

/** A backend KV representation independent of row storage and scheduling.
 * Inputs are borrowed. Encoding and decoding return caller-owned arrays.
 * A codec may retain values in a rotated domain for attention to invert once. */
export interface KvCodec<Encoded> {
  encode(keys: MlxArray, values: MlxArray): Encoded;
  decode(encoded: Encoded, length: number, headDim: number, deferValues?: boolean): [MlxArray, MlxArray];
}
