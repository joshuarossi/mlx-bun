// A resolved KV scheme in the composition record's form.
import type { KvStorageScheme } from "../contracts/portable/composition";
import { affineQuantizedKvStart } from "./kv-maintenance";
import type { KvScheme } from "./kv-scheme";

/** The composition record's form of a resolved scheme, with the conversion
 * start its maintenance uses and the default affine group size filled in. */
export function kvStorageOf(scheme: KvScheme): KvStorageScheme {
  const { options } = scheme;
  const start = (tokens: number) => tokens > 0 ? { quantizedKvStart: tokens } : {};
  switch (scheme.kind) {
    case "bf16": return Object.freeze({ kind: "bf16" });
    case "affine-uniform":
      return Object.freeze({ kind: "affine", bits: options.kvBits!, groupSize: options.kvGroupSize ?? 64,
        ...start(affineQuantizedKvStart(options)) });
    case "affine-config":
      return Object.freeze({ kind: "affine-layers",
        layers: Object.freeze(options.kvConfig!.map(entry =>
          Object.freeze({ layer: entry.layerIdx, bits: entry.bits, groupSize: entry.groupSize }))),
        ...start(affineQuantizedKvStart(options)) });
    case "turbo":
      return Object.freeze({ kind: "turbo", kBits: options.turboQuant!.kBits, vBits: options.turboQuant!.vBits,
        ...start(options.quantizedKvStart ?? 0) });
  }
}
